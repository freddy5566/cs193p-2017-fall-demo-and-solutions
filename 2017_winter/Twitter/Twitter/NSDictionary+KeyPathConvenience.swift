//
//  NSDictionary+KeyPathConvenience.swift
//  Twitter
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015-17 Stanford University. All rights reserved.
//

import Foundation

extension NSDictionary {
    func double(forKeyPath keyPath: String) -> Double? {
        return value(forKeyPath: keyPath) as? Double
    }
    func int(forKeyPath keyPath: String) -> Int? {
        return value(forKeyPath: keyPath) as? Int
    }
    func string(forKeyPath keyPath: String) -> String? {
        return value(forKeyPath: keyPath) as? String
    }
    func bool(forKeyPath keyPath: String) -> Bool? {
        return (value(forKeyPath: keyPath) as? NSNumber)?.boolValue
    }
    func url(forKeyPath keyPath: String) -> URL? {
        if let urlString = string(forKeyPath: keyPath), urlString.characters.count > 0, let url = URL(string: urlString) {
            return url
        } else {
            return nil
        }
    }
    func dictionary(forKeyPath keyPath: String) -> NSDictionary? {
        return value(forKeyPath: keyPath) as? NSDictionary
    }
    func array(forKeyPath keyPath: String) -> NSArray? {
        return value(forKeyPath: keyPath) as? NSArray
    }
}
