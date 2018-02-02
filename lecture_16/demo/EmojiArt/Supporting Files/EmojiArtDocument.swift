//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by CS193p Instructor.
//  Copyright © 2017 CS193p Instructor. All rights reserved.
//

import UIKit

class EmojiArtDocument: UIDocument
{
    var emojiArt: EmojiArt?  // the Model for this Document
    
    var thumbnail: UIImage?  // thumbnail image for this Document
    
    // turn the Model into a JSON Data
    // the return value is an Any (not Data)
    // because it's allowed to be a FileWrapper
    // if an application would rather represent its documents that way
    // the forType: argument is a UTI (e.g. "public.json" or "edu.stanford.cs193p.emojiart")
    
    override func contents(forType typeName: String) throws -> Any {
        return emojiArt?.json ?? Data()
    }
    
    // turn a JSON Data into the Model

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data {
            emojiArt = EmojiArt(json: json)
        }
    }
    
    // overridden to add a key-value pair
    // to the dictionary of "file attributes" on the file UIDocument writes
    // the added key-value pair sets a thumbnail UIImage for the UIDocument
    
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocumentSaveOperation) throws -> [AnyHashable : Any] {
        var attributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail {
            attributes[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey:thumbnail]
        }
        return attributes
    }
}
