//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by CS193p Instructor.
//  Copyright © 2017 CS193p Instructor. All rights reserved.
//

import Foundation

// the Model for an EmojiArt document
// is Codable so it can easily be converted to/from a JSON format

struct EmojiArt: Codable
{
    var url: URL
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo: Codable {
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
    // this object is Codable with no other effort
    // than saying it implements Codable
    // since all of its vars' data types are Codable
    // if that weren't true, you could still make it Codable
    // by adding init and encode methods
    
    // if you wanted the JSON keys for this to be different
    // you'd uncomment this out (as an example) ...
    // private enum CodingKeys: String, CodingKey {
    //    case url = "background_url"
    //    case emojis
    // }
    
    
    init?(json: Data) // take some JSON and try to init an EmojiArt from it
    {
        if let newValue = try? JSONDecoder().decode(EmojiArt.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    var json: Data? // return this EmojiArt as a JSON data
    {
        return try? JSONEncoder().encode(self)
    }
    
    init(url: URL, emojis: [EmojiInfo]) {
        self.url = url
        self.emojis = emojis
    }
}

