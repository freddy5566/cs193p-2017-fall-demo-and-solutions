//
//  ViewController.swift
//  Concentration
//
//  Created by jamfly on 2017/12/26.
//  Copyright © 2017年 jamfly. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var emojiChoices = ["👻", "🎃", "👻", "🎃"]
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet var cardsButton: [UIButton]!
    
    @IBAction func touchCard(_ sender: UIButton) {
        flipCount += 1
        if let cardNumber = cardsButton.index(of: sender) {
             flipcard(withEmoji: emojiChoices[cardNumber], on: sender)
        } else {
            print("chosen card was not in cardButtons")
        }
       
        
    }
    
    
    
    var flipCount = 0 {
        didSet {
            countLabel.text = "Flips: \(flipCount)"
        }
    }
    
    func flipcard(withEmoji emoji: String, on button: UIButton) {
        if button.currentTitle ==  emoji {
            button.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            button.setTitle("", for: .normal)
        } else {
            button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            button.setTitle(emoji, for: .normal)
        }
    }
    
    
}












