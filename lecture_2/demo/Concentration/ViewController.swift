//
//  ViewController.swift
//  Concentration
//
//  Created by jamfly on 2017/12/26.
//  Copyright © 2017年 jamfly. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    lazy var game = Concentration(numberOfPairsOfCards: (cardsButton.count + 1) / 2)
    
    var flipCount = 0 {
        didSet {
            countLabel.text = "Flips: \(flipCount)"
        }
    }
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet var cardsButton: [UIButton]!
    
    @IBAction func touchCard(_ sender: UIButton) {
        flipCount += 1
        if let cardNumber = cardsButton.index(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("chosen card was not in cardButtons")
        }
    }
    
    
    func updateViewFromModel() {
        for index in cardsButton.indices {
            let button = cardsButton[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControlState.normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                button.setTitle("", for: UIControlState.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 0) : #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
                
            }
        }
    }
    var emojiChoices =  ["🦇", "😱", "🙀", "😈", "🎃", "👻", "🍭", "🍬", "🍎"]
    
    var emoji = [Int: String]()
    
    func emoji(for card: Card) -> String {
        if emoji[card.identifier] == nil, emojiChoices.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(emojiChoices.count - 1)))
            emoji[card.identifier] = emojiChoices.remove(at: randomIndex)
        }
        return emoji[card.identifier] ?? "?"
    }
    
    
}












