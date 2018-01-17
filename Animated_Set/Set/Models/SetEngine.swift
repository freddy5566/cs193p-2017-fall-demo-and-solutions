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
    var selectedCard = [Card]()
    var hintCard = [Int]()
    
    mutating func chooseCard(at index: Int) {
        if selectedCard.contains(cardOnTable[index]) {
            selectedCard.remove(at: selectedCard.index(of: cardOnTable[index])!)
            return
        }
        
        selectedCard += [cardOnTable[index]]
        
        if selectedCard.count == 3 {
            if isSet(on: selectedCard) {
                let drawCard = draw()
                for index in selectedCard.indices {
                    let removeIndex = cardOnTable.index(of: selectedCard[index])!
                   
                    if !drawCard.isEmpty {
                        cardOnTable[removeIndex] = drawCard[index]
                    } else {
                        cardOnTable.remove(at: removeIndex)
                    }
                }
                score += 1
            } else {
                score -= 1
            }
            
        }
    
    }
    
    mutating func shuffle() {
        let number = cardOnTable.count / 3
        for cards in cardOnTable {
            deck.append(cards)
        }
        cardOnTable.removeAll()
        for _ in 1...number {
            cardOnTable += draw()
        }
    }
    
    mutating func isSet(on selectedCard: [Card]) -> Bool {
        if selectedCard.count == 0 { return false }
        
        let color = Set(selectedCard.map{ $0.color }).count
        let shape = Set(selectedCard.map{ $0.shape }).count
        let number = Set(selectedCard.map{ $0.number }).count
        let fill = Set(selectedCard.map{ $0.fill }).count
        
        return color != 2 && shape != 2 && number != 2 && fill != 2 
        
       
    }
    
    mutating func hint() {
        hintCard.removeAll()
        for i in 0..<cardOnTable.count {
            for j in (i + 1)..<cardOnTable.count {
                for k in (j + 1)..<cardOnTable.count {
                    let hints = [cardOnTable[i], cardOnTable[j], cardOnTable[k]]
                    if isSet(on: hints) {
                        hintCard += [i, j, k]
                    }
                }
            }
        }
    }
    
    mutating func drawThreeToDeck() {
        let card = draw()
        for cards in card {
            cardOnTable.append(cards)
        }
    }
    
    private mutating func draw() -> [Card]{
        if deck.count > 0 {
            var drawCards = [Card]()
            for _ in 1...3 {
                drawCards.append(deck.remove(at: deck.randomIndex))
            }
            return drawCards
        }
        return []
    }
    
    private mutating func initDeck() {
        for _ in 1...4 {
            drawThreeToDeck()
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



