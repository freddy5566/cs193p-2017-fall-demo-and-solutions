//
//  ViewController.swift
//  Set
//
//  Created by freddy on 30/12/2017.
//  Copyright © 2017 jamfly. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    
   
    private var selectedCard = [CardView]()
    private var hintedCard = [CardView]()
    private var cardsOnScreen = [CardView]()
    private var cardsNeedAnimated = [CardView]()
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
        
    }
    
    
    @IBAction private func moreThreeButtonPressed(_ sender: UIButton) {
        
        engine.drawThreeToDeck()
        cardsOnScreen.forEach {
            $0.removeFromSuperview()
        }
        cardsOnScreen.removeAll()
        updateViewFromModel()
    }
    
    @IBAction private func hintButtonPressed(_ sender: UIButton) {
        engine.hint()
        hintedCard.removeAll()
        if engine.hintCard.count < 3 { return }
        for index in 0...2 {
            hintedCard.append(cardsOnScreen[engine.hintCard[index]])
            cardsOnScreen[engine.hintCard[index]].state = State.stateOfSeclection.hinted
            cardsOnScreen[engine.hintCard[index]].setNeedsDisplay()
        }
    }
    
    @IBAction private func newGameButtonPressed(_ sender: UIButton) {
        engine = SetEngine()
        cardsOnScreen.forEach {
            $0.removeFromSuperview()
        }
        cardsOnScreen.removeAll()
        updateViewFromModel()
        updateScore()
        selectedCard.removeAll()
        hintedCard.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        cardsOnScreen.forEach { $0.removeFromSuperview() }
//        cardsOnScreen.removeAll()
//        updateViewFromModel()
//    }

    
    
    private func updateViewFromModel() {
        if cardsNeedAnimated.count != 0 { cardsNeedAnimated = [] }
        for index in engine.cardOnTable.indices {
            // print(index, ": ", grid[index]!)
            let dealToStView = setView.convert(moreThreeButton.bounds, from: moreThreeButton)
            cardsOnScreen.append(CardView(frame: dealToStView, card: engine.cardOnTable[index]))
            setView.addSubview(cardsOnScreen[index])
            cardsOnScreen[index].contentMode = .redraw
            cardsOnScreen[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(_:))))
            cardsNeedAnimated.append(cardsOnScreen[index])
        }
        flyIn()
    }
    
    private func flyIn() {
        
        let grid = SetGrid(for: setView.bounds, withNoOfFrames: engine.cardOnTable.count)

        var delayTime = 0.0
        for timeOfAnimate in 0..<cardsNeedAnimated.count {
            let gridIndex = cardsOnScreen.index(of: cardsNeedAnimated[timeOfAnimate])
            delayTime = 0.1 * Double(timeOfAnimate)
            
            UIView.animate(withDuration: 0.4,
                           delay: delayTime,
                           options: .curveEaseInOut,
                           animations: {
                            self.cardsNeedAnimated[timeOfAnimate].frame = grid[gridIndex!]!
            },
                           completion: { finisehed in
                            UIView.transition(with: self.cardsNeedAnimated[timeOfAnimate],
                                              duration: 0.2,
                                              options: .transitionFlipFromLeft,
                                              animations: {
                                                self.cardsNeedAnimated[timeOfAnimate].isFaceUp = true
                                                self.cardsNeedAnimated[timeOfAnimate].setNeedsDisplay()
                            })
            })
        }

    }
    
    
    
    private var isSet: Bool {
       
        return engine.isSet(on: engine.selectedCard)
    }
    
    
    
    private var engine = SetEngine() {
        didSet {
            if engine.deck.count == 0 {
                moreThreeButton.isHidden = true
            } else {
                moreThreeButton.isHidden = false
            }
        }
    }
    
    @objc private func tapCard(_ recognizer: UITapGestureRecognizer) {
        guard let tappedCard = recognizer.view as? CardView else { return }
        print(tappedCard.card!)
        engine.chooseCard(at: cardsOnScreen.index(of: tappedCard)!)
        
        if let state = tappedCard.state {
            switch state {
            case .selected:
                tappedCard.state = State.stateOfSeclection.unselected
                selectedCard.remove(at: selectedCard.index(of: tappedCard)!)
            case .unselected:
                tappedCard.state = State.stateOfSeclection.selected
                selectedCard.append(tappedCard)
            case .hinted:
                tappedCard.state = State.stateOfSeclection.selected
                selectedCard.append(tappedCard)
            }
        }
        tappedCard.setNeedsDisplay()
        
        if selectedCard.count == 3  {
            if isSet {
                let dealToStView = setView.convert(moreThreeButton.bounds, from: moreThreeButton)
                if cardsNeedAnimated.count != 0 { cardsNeedAnimated = [] }
                selectedCard.forEach {
                    let index = cardsOnScreen.index(of: $0)!
                    let card = cardsOnScreen[index]
                    if engine.deck.count > 0 {
                        cardsOnScreen[index] = CardView(frame: dealToStView, card: engine.cardOnTable[index])
                        card.removeFromSuperview()
                        setView.addSubview(cardsOnScreen[index])
                        cardsOnScreen[index].contentMode = .redraw
                        cardsOnScreen[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(_:))))
                        cardsNeedAnimated.append(cardsOnScreen[index])
                    } else {
                        $0.removeFromSuperview()
                        
                    }
                }
                ifSetFlayIn()
               
            } else {
                cardsOnScreen.forEach() {
                    $0.state = State.stateOfSeclection.unselected
                    $0.setNeedsDisplay()
                    print("cool")
                }
            }
            selectedCard.removeAll()
            engine.selectedCard.removeAll()
            updateScore()
        }
 
    }
    
    
    private func ifSetFlayIn() {
        if engine.deck.count > 0 {
            flyIn()
        } else {
            cardsOnScreen.forEach {
                $0.removeFromSuperview()
            }
            cardsOnScreen.removeAll()
            updateViewFromModel()
        }
    }

    
}







