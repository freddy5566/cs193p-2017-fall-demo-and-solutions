//
//  ViewController.swift
//  Set
//
//  Created by freddy on 30/12/2017.
//  Copyright © 2017 jamfly. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    
    private var engine = SetEngine()
    private var selectedButton = [UIButton]()
    private var hintedButton = [UIButton]()
    
    @IBOutlet private var cardsButton: [UIButton]!
    @IBOutlet weak private var moreThreeButton: UIButton!
    @IBOutlet weak private var hintButton: UIButton!
    @IBOutlet weak private var newGameButton: UIButton!
    @IBOutlet weak private var scorceLabel: UILabel!
    
    @IBAction private func cardsButtonPressed(_ sender: UIButton) {
        if let cardIndex = cardsButton.index(of: sender) {
            if cardIndex < engine.cardOnTable.count {
                engine.chooseCard(at: cardIndex)
                chooseButton(at: sender)
                updateViewFromModel()
            }
        } else {
            print("chosen card was not in cardButtons")
        }
        print(selectedButton.count)
    }
    
    private func updateScore() {
        scorceLabel.text = "\(engine.score)"
    }
    
    private func chooseButton(at card: UIButton) {
        if selectedButton.contains(card) {
            card.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            card.layer.borderWidth = 3.0
            selectedButton.remove(at: selectedButton.index(of: card)!)
            return
        } else if selectedButton.count == 3 {
                cardsButton.forEach() { $0.layer.borderColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0) }
                selectedButton.removeAll()
                updateScore()
            }
            selectedButton += [card]
            card.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            card.layer.borderWidth = 3.0
        }
    
    @IBAction private func moreThreeButtonPressed(_ sender: UIButton) {
        if selectedButton.count == 3 {
            
        }
        engine.draw()
        updateViewFromModel()
        hiddenButtonIfNeed()
    }
    
    @IBAction private func hintButtonPressed(_ sender: UIButton) {
        engine.hint()
        if engine.hintCard.count > 0 {
            for hint in 0...2 {
                let index = engine.hintCard[hint]
                cardsButton[index].layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                cardsButton[index].layer.borderWidth = 3.0
                hintedButton.append(cardsButton[index])
            }
            hintedButton.removeAll()
        }
    }
    
    @IBAction private func newGameButtonPressed(_ sender: UIButton) {
        engine = SetEngine()
        resetButton()
        updateViewFromModel()
        hiddenButtonIfNeed()
        updateScore()
        selectedButton.removeAll()
        hintedButton.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }
    
    private func hiddenButtonIfNeed() {
        if engine.cardOnTable.count == 24 || engine.numberOfCard == 0 {
            moreThreeButton.isHidden = true
        } else {
            moreThreeButton.isHidden = false
        }
    }
    
    private func resetButton() {
        for button in cardsButton {
            let nsAttributedString = NSAttributedString(string: "")
            button.setAttributedTitle(nsAttributedString, for: .normal)
            button.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        }
    }
    
    private func updateViewFromModel() {

        for index in engine.cardOnTable.indices {
            cardsButton[index].titleLabel?.numberOfLines = 0
            cardsButton[index].setAttributedTitle(setCardTitle(with: engine.cardOnTable[index]), for: .normal)
        }
    }
    
    private func setCardTitle(with card: Card) -> NSAttributedString {
        
        let attributes: [NSAttributedStringKey: Any] = [
            .strokeColor: ModelToView.colors[card.color]!,
            .strokeWidth: ModelToView.strokeWidth[card.fill]!,
            .foregroundColor: ModelToView.colors[card.color]!.withAlphaComponent(ModelToView.alpha[card.fill]!),
            ]
        var cardTitle = ModelToView.shapes[card.shape]!
        switch card.number {
        case .two: cardTitle = "\(cardTitle)\n\(cardTitle)"
        case .three: cardTitle = "\(cardTitle)\n\(cardTitle)\n\(cardTitle)"
        default:
            break
        }
        
        return NSAttributedString(string: cardTitle, attributes: attributes)
    }
    
}

struct ModelToView {
    
    static let shapes: [Card.Shape: String] = [.circle: "●", .triangle: "▲", .square: "■"]
    static var colors: [Card.Color: UIColor] = [.red: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), .purple: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), .green: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)]
    static var alpha: [Card.Fill: CGFloat] = [.solid: 1.0, .empty: 0.40, .stripe: 0.15]
    static var strokeWidth: [Card.Fill: CGFloat] = [.solid: -5, .empty: 5, .stripe: -5]
}








