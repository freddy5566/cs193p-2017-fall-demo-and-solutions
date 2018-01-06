//
//  SetEngine.swift
//  Set
//
//  Created by freddy on 30/12/2017.
//  Copyright © 2017 jamfly. All rights reserved.
//

import Foundation

struct SetEngine {
    
    private(set) var deck = [Card]()
    private(set) var score = 0
    
    var numberOfCard: Int {
        return deck.count
    }
    
    private(set) var cardOnTable = [Card]()
    private var selectedCard = [Card]()
    
    
    mutating func chooseCard(at index: Int) {
        if selectedCard.contains(cardOnTable[index]) && selectedCard.count < 3 {
            selectedCard.remove(at: selectedCard.index(of: cardOnTable[index])!)
        }
        if selectedCard.count == 3 {
            if isSet() {
                for cards in selectedCard {
                    cardOnTable.remove(at: cardOnTable.index(of: cards)!)
                }
                clearSelectedCards()
                draw()
                score += 1
            }
        }
        selectedCard += [cardOnTable[index]]
    }
    
    private mutating func isSet() -> Bool {
        let first = selectedCard.first
        var numberOfSame = 0
        for cards in selectedCard {
            if cards.color == first?.color { numberOfSame += 1 }
            if cards.fill == first?.fill { numberOfSame += 1 }
            if cards.number == first?.number { numberOfSame += 1 }
            if cards.shape == first?.shape { numberOfSame += 1 }
        }
        
        return numberOfSame % 3 == 0 || numberOfSame == 0
    }
    
    mutating func clearSelectedCards() {
        selectedCard.removeAll()
    }
    
    mutating func draw() {
        if deck.count > 0 {
            for _ in 1...3 {
                cardOnTable += [deck.remove(at: deck.randomIndex)]
            }
        }
    }
    
    mutating func reset() {
        let numberOfCardOnTable = cardOnTable.count
        for _ in 0..<numberOfCardOnTable {
            deck += [cardOnTable.remove(at: 0)]
        }
        initDeck()
        score = 0
    }
    
    private mutating func initDeck() {
        for _ in 1...4 {
            draw()
        }
    }
    
    
    init() {
        for color in Card.Color.all {
            for number in Card.Number.all {
                for shape in Card.Shape.all {
                    for fill in Card.Fill.all {
                        let card = Card(with: color, number, shape, fill)
                        deck += [card]
                    }
                }
            }
        }
        initDeck()
    }
    
}

extension Array {
    
    var randomIndex: Int {
        return Int(arc4random_uniform(UInt32(count - 1)))
    }
    
    
}



