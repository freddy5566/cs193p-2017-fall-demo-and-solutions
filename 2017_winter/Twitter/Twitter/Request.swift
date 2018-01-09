//
//  TwitterRequest.swift
//  Twitter
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015-17 Stanford University. All rights reserved.
//

import Foundation
import Accounts
import Social
import CoreLocation

// Simple Twitter query class
// Create an instance of it using one of the initializers
// Set the requestType and parameters (if not using a convenience init that sets those)
// Call fetch (or fetchTweets if fetching Tweets)
// The handler passed in will be called when the information comes back from Twitter
// Once a successful fetch has happened,
//   a follow-on TwitterRequest to get more Tweets (newer or older) can be created
//   using the requestFor{Newer,Older} methods

private var twitterAccount: ACAccount?

public class Request: NSObject
{
    public let requestType: String
    public let parameters: [String:String]
    
    public var searchTerm: String? {
        return parameters[TwitterKey.query]?.components(separatedBy: "-").first?.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    public enum SearchResultType: Int {
        case mixed
        case recent
        case popular
    }
    
    // designated initializer
    public init(_ requestType: String, _ parameters: Dictionary<String, String> = [:]) {
        self.requestType = requestType
        self.parameters = parameters
    }
    
    // convenience initializer for creating a TwitterRequest that is a search for Tweets
    public convenience init(search: String, count: Int = 0) { // , resultType resultType: SearchResultType = .Mixed, region region: CLCircularRegion? = nil) {
        var parameters = [TwitterKey.query : search]
        if count > 0 {
            parameters[TwitterKey.count] = "\(count)"
        }
//        switch resultType {
//        case .Recent: parameters[TwitterKey.ResultType] = TwitterKey.ResultTypeRecent
//        case .Popular: parameters[TwitterKey.ResultType] = TwitterKey.ResultTypePopular
//        default: break
//        }
//        if let geocode = region {
//            parameters[TwitterKey.Geocode] = "\(geocode.center.latitude),\(geocode.center.longitude),\(geocode.radius/1000.0)km"
//        }
        self.init(TwitterKey.searchForTweets, parameters)
    }
        
    // convenience "fetch" for when self is a request that returns Tweet(s)
    // handler is not necessarily invoked on the main queue
    
    public func fetchTweets(_ handler: @escaping ([Tweet]) -> Void) {
        fetch { results in
            var tweets = [Tweet]()
            var tweetArray: NSArray?
            if let dictionary = results as? NSDictionary {
                if let tweets = dictionary[TwitterKey.tweets] as? NSArray {
                    tweetArray = tweets
                } else if let tweet = Tweet(data: dictionary) {
                    tweets = [tweet]
                }
            } else if let array = results as? NSArray {
                tweetArray = array
            }
            if tweetArray != nil {
                for tweetData in tweetArray! {
                    if let tweet = Tweet(data: tweetData as? NSDictionary) {
                        tweets.append(tweet)
                    }
                }
            }
            handler(tweets)
        }
    }
    
    public typealias PropertyList = Any
    
    // send the request specified by our requestType and parameters off to Twitter
    // calls the handler (not necessarily on the main queue)
    //   with the JSON results converted to a Property List
    
    public func fetch(_ handler: @escaping (PropertyList?) -> Void) {
        performTwitterRequest(.GET, handler: handler)
    }
    
    // generates a request for older Tweets than were returned by self
    // only makes sense if self has completed a fetch already
    // only makes sense for requests for Tweets
    
    public var older: Request? {
        if min_id == nil {
            if parameters[TwitterKey.maxID] != nil {
                return self
            }
        } else {
            return modifiedRequest(parametersToChange: [TwitterKey.maxID : min_id!])
        }
        return nil
    }
    
    // generates a request for newer Tweets than were returned by self
    // only makes sense if self has completed a fetch already
    // only makes sense for requests for Tweets
    
    public var newer: Request? {
        if max_id == nil {
            if parameters[TwitterKey.sinceID] != nil {
                return self
            }
        } else {
            return modifiedRequest(parametersToChange: [TwitterKey.sinceID : max_id!], clearCount: true)
        }
        return nil
    }
    
    // MARK: - Internal Implementation
    
    // creates an appropriate SLRequest using the specified SLRequestMethod
    // then calls the other version of this method that takes an SLRequest
    // handler is not necessarily called on the main queue
    
    func performTwitterRequest(_ method: SLRequestMethod, handler: @escaping (PropertyList?) -> Void) {
        let jsonExtension = (self.requestType.range(of: Constants.JSONExtension) == nil) ? Constants.JSONExtension : ""
        let url = URL(string: "\(Constants.twitterURLPrefix)\(self.requestType)\(jsonExtension)")
        if let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: method, url: url, parameters: parameters) {
            performTwitterSLRequest(request, handler: handler)
        }
    }
    
    // sends the request to Twitter
    // unpackages the JSON response into a Property List
    // and calls handler (not necessarily on the main queue)
    
    func performTwitterSLRequest(_ request: SLRequest, handler: @escaping (PropertyList?) -> Void) {
        if let account = twitterAccount {
            request.account = account
            request.perform { (jsonResponse, httpResponse, _) in
                var propertyListResponse: PropertyList?
                if jsonResponse != nil {
                    propertyListResponse = try? JSONSerialization.jsonObject(with: jsonResponse!, options: .mutableLeaves)
                    if propertyListResponse == nil {
                        let error = "Couldn't parse JSON response."
                        self.log(error)
                        propertyListResponse = error
                    }
                } else {
                    let error = "No response from Twitter."
                    self.log(error)
                    propertyListResponse = error
                }
                self.synchronize {
                    self.captureFollowonRequestInfo(propertyListResponse)
                }
                handler(propertyListResponse)
            }
        } else {
            let accountStore = ACAccountStore()
            let twitterAccountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
            accountStore.requestAccessToAccounts(with: twitterAccountType, options: nil) { (granted, _) in
                if granted {
                    if let account = accountStore.accounts(with: twitterAccountType)?.last as? ACAccount {
                        twitterAccount = account
                        self.performTwitterSLRequest(request, handler: handler)
                    } else {
                        let error = "Couldn't discover Twitter account type."
                        self.log(error)
                        handler(error)
                    }
                } else {
                    let error = "Access to Twitter was not granted."
                    self.log(error)
                    handler(error)
                }
            }
        }
    }
    
    private var min_id: String? = nil
    private var max_id: String? = nil
    
    // modifies parameters in an existing request to create a new one
    
    private func modifiedRequest(parametersToChange: Dictionary<String,String>, clearCount: Bool = false) -> Request {
        var newParameters = parameters
        for (key, value) in parametersToChange {
            newParameters[key] = value
        }
        if clearCount { newParameters[TwitterKey.count] = nil }
        return Request(requestType, newParameters)
    }
    
    // captures the min_id and max_id information
    // to support requestForNewer and requestForOlder
    
    private func captureFollowonRequestInfo(_ propertyListResponse: PropertyList?) {
        if let responseDictionary = propertyListResponse as? NSDictionary {
            self.max_id = responseDictionary.value(forKeyPath: TwitterKey.SearchMetadata.maxID) as? String
            if let next_results = responseDictionary.value(forKeyPath: TwitterKey.SearchMetadata.nextResults) as? String {
                for queryTerm in next_results.components(separatedBy: TwitterKey.SearchMetadata.separator) {
                    if queryTerm.hasPrefix("?\(TwitterKey.maxID)=") {
                        let next_id = queryTerm.components(separatedBy: "=")
                        if next_id.count == 2 {
                            self.min_id = next_id[1]
                        }
                    }
                }
            }
        }
    }
    
    // debug println with identifying prefix
    
    private func log(_ whatToLog: Any) {
        debugPrint("TwitterRequest: \(whatToLog)")
    }
    
    // synchronizes access to self across multiple threads
    
    private func synchronize(_ closure: () -> Void) {
        objc_sync_enter(self)
        closure()
        objc_sync_exit(self)
    }
    
    // constants
    
    private struct Constants {
        static let JSONExtension = ".json"
        static let twitterURLPrefix = "https://api.twitter.com/1.1/"
    }
    
    // keys in Twitter responses/queries
    
    struct TwitterKey {
        static let count = "count"
        static let query = "q"
        static let tweets = "statuses"
        static let resultType = "result_type"
        static let resultTypeRecent = "recent"
        static let resultTypePopular = "popular"
        static let geocode = "geocode"
        static let searchForTweets = "search/tweets"
        static let maxID = "max_id"
        static let sinceID = "since_id"
        struct SearchMetadata {
            static let maxID = "search_metadata.max_id_str"
            static let nextResults = "search_metadata.next_results"
            static let separator = "&"
        }
    }
}
