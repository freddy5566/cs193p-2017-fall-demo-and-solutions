//
//  ImageGallery.swift
//  PresistentImageGallery
//
//  Created by jamfly on 2018/2/2.
//  Copyright © 2018年 jamfly. All rights reserved.
//

import Foundation


struct ImageGallery: Codable {
    
    var imgaesURL = [URL]()
    var scale: Float
    
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(ImageGallery.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init(imagesURL: [URL], scale: Float) {
        self.imgaesURL = imagesURL
        self.scale = scale
    }
    
}
