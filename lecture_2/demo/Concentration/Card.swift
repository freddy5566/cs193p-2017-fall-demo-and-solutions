//
//  Card.swift
//  Concentration
//
//  Created by jamfly on 2017/12/27.
//  Copyright © 2017年 jamfly. All rights reserved.
//

import Foundation

struct Card {
    
    var isFaceUp = false
    var isMatched = false
    var identifier: Int
    
    static var identifierFactor = 0
    
    static func getUniqueIdentifier() -> Int {
        identifierFactor += 1
        return identifierFactor
    }
    
    
    init() {
        self.identifier = Card.getUniqueIdentifier()
    }
    
}






