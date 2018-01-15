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
    private var selectedcard = [CardView]()
    private var hintedCard = [CardView]()
    private var cardsOnScreen = [CardView]()
    
    @IBOutlet weak var setView: SetView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(draw(_:)))
            swipe.direction = [.left, .right]
            setView.addGestureRecognizer(swipe)
            setView.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(shuffle(_:))))
        }
    }
    
    @IBOutlet weak private var moreThreeButton: UIButton!
    @IBOutlet weak private var hintButton: UIButton!
    @IBOutlet weak private var newGameButton: UIButton!
    @IBOutlet weak private var scorceLabel: UILabel!
    
    
    private func updateScore() {
        scorceLabel.text = "\(engine.score)"
    }
    
    @objc private func shuffle(_ recognizer: UIRotationGestureRecognizer) {
        cardsOnScreen.forEach {
            $0.removeFromSuperview()
        }
        cardsOnScreen.removeAll()
        engine.shuffle()
        updateViewFromModel()
    }
    
    @objc private func draw(_ recognizer: UISwipeGestureRecognizer) {
        
        engine.drawThreeToDeck()
        cardsOnScreen.forEach {
            $0.removeFromSuperview()
        }
        cardsOnScreen.removeAll()
        updateViewFromModel()
        hiddenButtonIfNeed()
        
    }
    
    
    @IBAction private func moreThreeButtonPressed(_ sender: UIButton) {
        
        engine.drawThreeToDeck()
        cardsOnScreen.forEach {
            $0.removeFromSuperview()
        }
        cardsOnScreen.removeAll()
        updateViewFromModel()
        hiddenButtonIfNeed()
    }
    
    @IBAction private func hintButtonPressed(_ sender: UIButton) {
        engine.hint()
        if engine.hintCard.count < 3 { return }
        for index in 0...2 {
            hintedCard.append(cardsOnScreen[engine.hintCard[index]])
            cardsOnScreen[engine.hintCard[index]].state = State.stateOfSeclection.hinted
            cardsOnScreen[engine.hintCard[index]].setNeedsDisplay()
        }
        hintedCard.removeAll()
    }
    
    @IBAction private func newGameButtonPressed(_ sender: UIButton) {
        engine = SetEngine()
        cardsOnScreen.forEach {
            $0.removeFromSuperview()
        }
        cardsOnScreen.removeAll()
        updateViewFromModel()
        hiddenButtonIfNeed()
        updateScore()
        selectedcard.removeAll()
        hintedCard.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cardsOnScreen.forEach { $0.removeFromSuperview() }
        cardsOnScreen.removeAll()
        updateViewFromModel()
    }
    
    private func hiddenButtonIfNeed() {
        if engine.numberOfCard == 0 {
            moreThreeButton.isHidden = true
        } else {
            moreThreeButton.isHidden = false
        }
    }
    
    
    private func updateViewFromModel() {
        let grid = SetGrid(for: setView.bounds, withNoOfFrames: engine.cardOnTable.count)
        for index in engine.cardOnTable.indices {
            // print(index, ": ", grid[index]!)
            cardsOnScreen.append(CardView(frame: grid[index]!, card: engine.cardOnTable[index])) 
            setView.addSubview(cardsOnScreen[index])
            cardsOnScreen[index].contentMode = .redraw
            cardsOnScreen[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(_:))))
            
        }
    }
    
    private var isSet: Bool {
        if selectedcard.count == 3 {
            return engine.isSet(on: engine.selectedCard)
        }
        return false
    }

    
    @objc private func tapCard(_ recognizer: UITapGestureRecognizer) {
        guard let tappedCard = recognizer.view as? CardView else { return }
        print(tappedCard.card!)
        engine.chooseCard(at: cardsOnScreen.index(of: tappedCard)!)
        
        if let state = tappedCard.state {
            switch state {
            case .selected:
                tappedCard.state = State.stateOfSeclection.unselected
                selectedcard.remove(at: selectedcard.index(of: tappedCard)!)
            case .unselected:
                tappedCard.state = State.stateOfSeclection.selected
                selectedcard.append(tappedCard)
            case .hinted:
                tappedCard.state = State.stateOfSeclection.selected
                selectedcard.append(tappedCard)
            }
        }
        tappedCard.setNeedsDisplay()
        
        if selectedcard.count == 3  {
            
            if isSet {
                selectedcard.removeAll()
                cardsOnScreen.forEach {
                    $0.removeFromSuperview()
                }
                cardsOnScreen.removeAll()
                updateViewFromModel()
                
            } else {
                cardsOnScreen.forEach() {
                    $0.state = State.stateOfSeclection.unselected
                    $0.setNeedsDisplay()
                }
                selectedcard.removeAll()
            }
            updateScore()
        }
        
        print(selectedcard.count)
        
    }
    


    
}







