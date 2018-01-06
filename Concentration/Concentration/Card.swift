//
//  Card.swift
//  Concentration
//
//  Created by jamfly on 2017/12/27.
//  Copyright © 2017年 jamfly. All rights reserved.
//

import Foundation

struct Card {
    
    // API
    var isFaceUp = false
    var isMatched = false
    var isSeenBefore = false
    private(set) var identifier: Int
    
    
    private static var identifierFactor = 0
    
    private static func getUniqueIdentifier() -> Int {
        identifierFactor += 1
        return identifierFactor
    }
    
    
    init() {
        self.identifier = Card.getUniqueIdentifier()
    }
    
}






