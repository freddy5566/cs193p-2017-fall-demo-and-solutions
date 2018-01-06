//
//  ViewController.swift
//  Concentration
//
//  Created by jamfly on 2017/12/26.
//  Copyright © 2017年 jamfly. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet private var cardsButton: [UIButton]!
    @IBAction private func touchCard(_ sender: UIButton) {
        if let cardNumber = cardsButton.index(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("chosen card was not in cardButtons")
        }
    }
    
    // MARK: IBAction
    @IBAction private func newGameButtonPressed(_ sender: UIButton) {
        setup()
    }
    
    // MARK: variable
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
    
    var numberOfPairsOfCards: Int {
        return (cardsButton.count + 1) / 2
    }
    
    private var theme: [[String]] = []
    private var themeColorButton: UIColor = #colorLiteral(red: 0.9176470588, green: 0.662745098, blue: 0.2666666667, alpha: 1)
    private var themeColorBackground: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    private var randomTheme: [String] = []
    private var animals: [String] = []
    private var sports: [String] = []
    private var faces: [String] = []
    private var cars: [String] = []
    private var flags: [String] = []
    private var foods: [String] = []
    private var emoji = [Int: String]()
    
    // MARK: function
    private func setupTheme() {
        animals = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮"]
        sports = ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉", "🎱", "🏓", "🏸", "🥅", "🏒"]
        faces = ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "☺️", "😊", "😇", "🙂"]
        cars = ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎", "🚓", "🚑", "🚒", "🚐", "🚚", "🚛"]
        flags = ["🇹🇼", "🇯🇵", "🏳️", "🏴", "🏁", "🚩", "🏳️‍🌈", "🇱🇷", "🎌", "🇨🇦", "🇳🇵", "🇬🇪"]
        foods = ["🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🍈", "🍒", "🍑"]
        theme = [animals, sports, faces, cars, flags, foods]
        randomTheme = getRandomTheme()
    }
    
    private func emoji(for card: Card) -> String {
        if emoji[card.identifier] == nil {
            emoji[card.identifier] = randomTheme.remove(at: randomTheme.count.arc4random)
        }
        return emoji[card.identifier] ?? "?"
    }
    
    private func getRandomTheme() -> [String] {
        let index = theme.count.arc4random
        print(theme[index])
        setColor(at: index)
        return theme[index]
    }
    
    private func setColor(at theme: Int) {
        switch theme {
        case 0:
            themeColorButton = #colorLiteral(red: 0.4274509804, green: 0.737254902, blue: 0.3882352941, alpha: 1)
            themeColorBackground = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        case 1:
            themeColorButton = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            themeColorBackground = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
        case 2:
            themeColorButton = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
            themeColorBackground = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case 3:
            themeColorButton = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
            themeColorBackground = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case 4:
            themeColorButton = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            themeColorBackground = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        case 5:
            themeColorButton = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            themeColorBackground = #colorLiteral(red: 0.4274509804, green: 0.737254902, blue: 0.3882352941, alpha: 1)
        default:
            themeColorButton = #colorLiteral(red: 0.9176470588, green: 0.662745098, blue: 0.2666666667, alpha: 1)
            themeColorBackground = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }

    }
    
    private func updateViewFromModel() {
        for index in cardsButton.indices {
            let button = cardsButton[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControlState.normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                button.setTitle("", for: UIControlState.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 0) : themeColorButton
                
            }
        }
        countLabel.text = "Flips: \(game.flipCount)"
        scoreLabel.text = "Scorce: \(game.scorce)"
    }
    
    private func setup() {
        game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
        setupTheme()
        updateViewFromModel()
        view.backgroundColor = themeColorBackground
        for cards in cardsButton {
            cards.backgroundColor = themeColorButton
        }
        scoreLabel.textColor = themeColorButton
        countLabel.textColor = themeColorButton
        newGameButton.setTitleColor(themeColorButton, for: .normal)
    }
    
    // MARK: lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        setup()
    }
    
}

// MARK: extention
extension Int {
    
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(self)))
        } else {
            return 0
        }
        
    }
    
    
}











