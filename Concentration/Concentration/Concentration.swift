//
//  Concentration.swift
//  Concentration
//
//  Created by jamfly on 2017/12/27.
//  Copyright © 2017年 jamfly. All rights reserved.
//

import Foundation

struct Concentration {
    
    // MARK: variable
    private(set) var cards = [Card]()
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            var foundIndex: Int?
            for index in cards.indices {
                if cards[index].isFaceUp {
                    if foundIndex == nil {
                        foundIndex = index
                    } else {
                        return nil
                    }
                }
            }
            return foundIndex
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    private(set) var flipCount = 0
    private(set) var scorce: Int
    
    // MARK: function
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen index")
        flipCount += 1
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                // check if cards match
                if cards[matchIndex].identifier == cards[index].identifier {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    scorce += 2
                } else {
                    if (cards[matchIndex].isSeenBefore || cards[index].isSeenBefore) {
                        scorce -= 1
                    }
                    cards[index].isSeenBefore = true
                    cards[matchIndex].isSeenBefore = true
                }
                cards[index].isFaceUp = true
            } else {
                // either no card or two cards face up
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concentraion.init(\(numberOfPairsOfCards)")
        scorce = 0
        for _ in 1...numberOfPairsOfCards {
            let card = Card()
            cards += [card, card]
        }
        //    TODO: Shuffle the cards
        //    Shulle 1000 times 
        for _ in 1...1000 {
            for index in cards.indices {
                let randomIndex = cards.count.arc4random
                let temp = cards[index]
                cards[index] = cards[randomIndex]
                cards[randomIndex] = temp
            }
        }
    }
    
    
    
}












