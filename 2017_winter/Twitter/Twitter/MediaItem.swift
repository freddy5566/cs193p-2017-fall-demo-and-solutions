//
//  MediaItem.swift
//  Twitter
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015-17 Stanford University. All rights reserved.
//

import Foundation

// holds the network url and aspectRatio of an image attached to a Tweet
// created automatically when a Tweet object is created

public struct MediaItem: CustomStringConvertible
{
    public let url: URL
    public let aspectRatio: Double
    
    public var description: String { return "\(url.absoluteString) (aspect ratio = \(aspectRatio))" }
    
    // MARK: - Internal Implementation
    
    init?(data: NSDictionary?) {
        guard
            let height = data?.double(forKeyPath: TwitterKey.height), height > 0,
            let width = data?.double(forKeyPath: TwitterKey.width), width > 0,
            let url = data?.url(forKeyPath: TwitterKey.mediaURL)
        else {
            return nil
        }
        self.url = url
        self.aspectRatio = width/height
    }
    
    struct TwitterKey {
        static let mediaURL = "media_url_https"
        static let width = "sizes.small.w"
        static let height = "sizes.small.h"
    }
}
