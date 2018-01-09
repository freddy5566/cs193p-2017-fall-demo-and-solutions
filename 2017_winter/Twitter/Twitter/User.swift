//
//  User.swift
//  Twitter
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015-17 Stanford University. All rights reserved.
//

import Foundation

// container to hold data about a Twitter user

public struct User: CustomStringConvertible
{
    public let screenName: String
    public let name: String
    public let id: String
    public let verified: Bool
    public let profileImageURL: URL?
    
    public var description: String { return "@\(screenName) (\(name))\(verified ? " ✅" : "")" }
    
    // MARK: - Internal Implementation
    
    init?(data: NSDictionary?) {
        guard
            let screenName = data?.string(forKeyPath: TwitterKey.screenName),
            let name = data?.string(forKeyPath: TwitterKey.name),
            let id = data?.string(forKeyPath: TwitterKey.identifier)
        else {
            return nil
        }
        
        self.screenName = screenName
        self.name = name
        self.id = id
        self.verified = data?.bool(forKeyPath: TwitterKey.verified) ?? false
        self.profileImageURL = data?.url(forKeyPath: TwitterKey.profileImageURL)
    }
    
    var asPropertyList: [String:String] {
        return [
            TwitterKey.name : name,
            TwitterKey.screenName : screenName,
            TwitterKey.identifier : id,
            TwitterKey.verified : verified ? "YES" : "NO",
            TwitterKey.profileImageURL : profileImageURL?.absoluteString ?? ""
        ]
    }
    
    struct TwitterKey {
        static let name = "name"
        static let screenName = "screen_name"
        static let identifier = "id_str"
        static let verified = "verified"
        static let profileImageURL = "profile_image_url"
    }
}
