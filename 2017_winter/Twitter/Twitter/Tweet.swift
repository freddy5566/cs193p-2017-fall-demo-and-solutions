//
//  Tweet.swift
//  Twitter
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015-17 Stanford University. All rights reserved.
//

import Foundation

// a simple container which just holds the data in a Tweet
// a Mention is a substring of the Tweet's text
// for example, a hashtag or other user or url that is mentioned in the Tweet
// note carefully the comments on the range property in a Mention
// Tweet instances are created by fetching from Twitter using a Twitter.Request

public struct Tweet : CustomStringConvertible
{
    public let text: String
    public let user: User
    public let created: Date
    public let identifier: String
    public let media: [MediaItem]
    public let hashtags: [Mention]
    public let urls: [Mention]
    public let userMentions: [Mention]
    
    public var description: String { return "\(user) - \(created)\n\(text)\nhashtags: \(hashtags)\nurls: \(urls)\nuser_mentions: \(userMentions)" + "\nid: \(identifier)" }
    
    // MARK: - Internal Implementation
    
    init?(data: NSDictionary?)
    {
        guard
            let user = User(data: data?.dictionary(forKeyPath: TwitterKey.user)),
            let text = data?.string(forKeyPath: TwitterKey.text),
            let created = twitterDateFormatter.date(from: data?.string(forKeyPath: TwitterKey.created) ?? ""),
            let identifier = data?.string(forKeyPath: TwitterKey.identifier)
        else {
            return nil
        }

        self.user = user
        self.text = text
        self.created = created
        self.identifier = identifier

        self.media = Tweet.mediaItems(from: data?.array(forKeyPath: TwitterKey.media))
        self.hashtags = Tweet.mentions(from: data?.array(forKeyPath: TwitterKey.Entities.hashtags), in: text, with: "#")
        self.urls = Tweet.mentions(from: data?.array(forKeyPath: TwitterKey.Entities.urls), in: text, with: "http")
        self.userMentions = Tweet.mentions(from: data?.array(forKeyPath: TwitterKey.Entities.userMentions), in: text, with: "@")
    }
    
    private static func mediaItems(from twitterData: NSArray?) -> [MediaItem] {
        var mediaItems = [MediaItem]()
        for mediaItemData in twitterData ?? [] {
            if let mediaItem = MediaItem(data: mediaItemData as? NSDictionary) {
                mediaItems.append(mediaItem)
            }
        }
        return mediaItems
    }
    
    private static func mentions(from twitterData: NSArray?, in text: String, with prefix: String) -> [Mention] {
        var mentions = [Mention]()
        for mentionData in twitterData ?? [] {
            if let mention = Mention(from: mentionData as? NSDictionary, in: text as NSString, with: prefix) {
                mentions.append(mention)
            }
        }
        return mentions
    }
    
    struct TwitterKey {
        static let user = "user"
        static let text = "text"
        static let created = "created_at"
        static let identifier = "id_str"
        static let media = "entities.media"
        struct Entities {
            static let hashtags = "entities.hashtags"
            static let urls = "entities.urls"
            static let userMentions = "entities.user_mentions"
            static let indices = "indices"
            static let text = "text"
        }
    }
}

public struct Mention: CustomStringConvertible
{
    public let keyword: String              // will include # or @ or http prefix
    public let nsrange: NSRange             // index into an NS[Attributed]String made from the Tweet's text
    
    public var description: String { return "\(keyword) (\(nsrange.location), \(nsrange.location+nsrange.length-1))" }
    
    init?(from data: NSDictionary?, in text: NSString, with prefix: String)
    {
        guard
            let indices = data?.array(forKeyPath: Tweet.TwitterKey.Entities.indices),
            let start = (indices.firstObject as? NSNumber)?.intValue, start >= 0,
            let end = (indices.lastObject as? NSNumber)?.intValue, end > start
        else {
            return nil
        }
        
        var prefixAloneOrPrefixedMention = prefix
        if let mention = data?.string(forKeyPath: Tweet.TwitterKey.Entities.text) {
            prefixAloneOrPrefixedMention = mention.prependPrefixIfAbsent(prefix)
        }
        let expectedRange = NSRange(location: Int(start), length: end - start)
        guard
            let nsrange = text.rangeOfSubstring(withPrefix: prefixAloneOrPrefixedMention, expectedRange: expectedRange)
        else {
            return nil
        }
        
        self.keyword = text.substring(with: nsrange)
        self.nsrange = nsrange
    }
}

private let twitterDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

private extension String {
    func prependPrefixIfAbsent(_ prefix: String) -> String {
        return hasPrefix(prefix) ? self : prefix + self
    }
}

private extension NSString
{
    func rangeOfSubstring(withPrefix prefix: String, expectedRange: NSRange) -> NSRange?
    {
        var offset = 0
        var substringRange = expectedRange
        while range.contains(substringRange) && substringRange.intersects(expectedRange) {
            if substring(with: substringRange).hasPrefix(prefix) {
                return substringRange
            }
            offset = offset > 0 ? -(offset+1) : -(offset-1)
            substringRange.location += offset
        }
        
        // the prefix does not intersect the expectedRange
        // let's search for it elsewhere and if we find it,
        // pick the one closest to expectedRange
        
        var searchRange = range
        var bestMatchRange = NSRange.NotFound
        var bestMatchDistance = Int.max
        repeat {
            substringRange = self.range(of: prefix, options: [], range: searchRange)
            let distance = substringRange.distance(from: expectedRange)
            if distance < bestMatchDistance {
                bestMatchRange = substringRange
                bestMatchDistance = distance
            }
            searchRange.length -= substringRange.end - searchRange.start
            searchRange.start = substringRange.end
        } while searchRange.length > 0
        
        if bestMatchRange.location != NSNotFound {
            bestMatchRange.length = expectedRange.length
            if range.contains(bestMatchRange) {
                return bestMatchRange
            }
        }
        
        print("NSString.rangeOfSubstring(withPrefix:expectedRange:) couldn't find a keyword with the prefix \(prefix) near the range \(expectedRange) in \(self)")

        return nil
    }
    
    var range: NSRange { return NSRange(location:0, length: length) }
}

private extension NSRange
{
    func contains(_ range: NSRange) -> Bool {
        return range.location >= location && range.location+range.length <= location+length
    }

    func intersects(_ range: NSRange) -> Bool {
        if range.location == NSNotFound || location == NSNotFound {
            return false
        } else {
            return (range.start >= start && range.start < end) || (range.end >= start && range.end < end)
        }
    }
    
    func distance(from range: NSRange) -> Int {
        if range.location == NSNotFound || location == NSNotFound {
            return Int.max
        } else if intersects(range) {
            return 0
        } else {
            return (end < range.start) ? range.start - end : start - range.end
        }
    }
    
    static let NotFound = NSRange(location: NSNotFound, length: 0)
    
    var start: Int {
        get { return location }
        set { location = newValue }
    }

    var end: Int { return location+length }
}
