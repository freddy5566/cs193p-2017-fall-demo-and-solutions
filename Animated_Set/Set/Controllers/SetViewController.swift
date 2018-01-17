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
    @IBOutlet weak var setView: SetView!
       
    
    @IBOutlet weak private var moreThreeButton: UIButton!
    @IBOutlet weak private var hintButton: UIButton!
    @IBOutlet weak private var newGameButton: UIButton!
    @IBOutlet weak private var scorceLabel: UILabel!
    
    
    private func updateScore() {
        scorceLabel.text = "\(engine.score)"
    }
    
    @IBAction private func moreThreeButtonPressed(_ sender: UIButton) {
        drawCard()
    }
    
    private func smallCardOnScreen() {
        let grid = SetGrid(for: setView.frame, withNoOfFrames: engine.cardOnTable.count)
        for index in cardsOnScreen.indices  {
            UIView.transition(with: cardsOnScreen[index],
                              duration: 0.7,
                              options: .allowAnimatedContent,
                              animations: {
                                self.moreThreeButton.isUserInteractionEnabled = false
                                let scaleY = grid[index]!.height / self.cardsOnScreen[index].frame.height
                                let scaleX = grid[index]!.width / self.cardsOnScreen[index].frame.width
                                self.cardsOnScreen[index].transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                                
            },
                              completion: { finished in
                                UIView.animate(withDuration: 0.5,
                                               animations: {
                                                self.cardsOnScreen[index].frame = grid[index]!
                                                self.cardsOnScreen[index].setNeedsDisplay(grid[index]!)
                                                if index == self.cardsOnScreen.endIndex - 1 {
                                                    self.moreThreeButton.isUserInteractionEnabled = false
                                                }
                                })
            })
        }
    }
    
    private func drawCard() {
       
        engine.drawThreeToDeck()
        smallCardOnScreen()
        cardsNeedAnimated.removeAll()
        let indxOfLastThreeCardBegine = engine.cardOnTable.count - 3
   
        let dealToStView = setView.convert(moreThreeButton.bounds, from: moreThreeButton)
        for index in indxOfLastThreeCardBegine..<engine.cardOnTable.count {
            let cards = CardView(frame: dealToStView, card: engine.cardOnTable[index])
            cards.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(_:))))
            setView.addSubview(cards)
            cardsNeedAnimated.append(cards)
            cardsOnScreen.append(cards)
        }
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(flyIn), userInfo: nil, repeats: false)
        
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
  
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let grid = SetGrid(for: setView.bounds, withNoOfFrames: engine.cardOnTable.count)
        for index in cardsOnScreen.indices {
            cardsOnScreen[index].frame = grid[index]!
            cardsOnScreen[index].setNeedsDisplay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
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



    private func updateViewFromModel() {
        cardsOnScreen.removeAll()
        cardsNeedAnimated.removeAll()
        for index in engine.cardOnTable.indices {
            // print(index, ": ", grid[index]!)
            let dealToStView = setView.convert(moreThreeButton.bounds, from: moreThreeButton)
            cardsOnScreen.append(CardView(frame: dealToStView, card: engine.cardOnTable[index]))
            setView.addSubview(cardsOnScreen[index])
            cardsOnScreen[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(_:))))
            cardsNeedAnimated.append(cardsOnScreen[index])
        }
        flyIn()
    }
    
    @objc private func flyIn() {
        
        let grid = SetGrid(for: setView.bounds, withNoOfFrames: engine.cardOnTable.count)

        var delayTime = 0.0
        for timeOfAnimate in 0..<cardsNeedAnimated.count {
            let gridIndex = cardsOnScreen.index(of: cardsNeedAnimated[timeOfAnimate])
            delayTime = 0.1 * Double(timeOfAnimate)
            
            UIView.animate(withDuration: 0.7,
                           delay: delayTime,
                           options: .curveEaseInOut,
                           animations: {
                            // print(self.cardsNeedAnimated[timeOfAnimate].isFaceUp)
                            self.moreThreeButton.isUserInteractionEnabled = false
                            self.cardsNeedAnimated[timeOfAnimate].frame = grid[gridIndex!]!
                            
            },
                           completion: { finisehed in
                            UIView.transition(with: self.cardsNeedAnimated[timeOfAnimate],
                                              duration: 0.2,
                                              options: .transitionFlipFromLeft,
                                              animations: {
                                                self.cardsNeedAnimated[timeOfAnimate].isFaceUp = true
                                                self.cardsNeedAnimated[timeOfAnimate].setNeedsDisplay()
                                                
                                            }, completion: { finisehed in
                                                if timeOfAnimate == self.cardsNeedAnimated.endIndex - 1 {
                                                    self.moreThreeButton.isUserInteractionEnabled = true
                                                }
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
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    private func flayaway() {
        let flyBehavior = Flyaway(in: animator)
        var flayCards = [CardView]()
        var flipCards = [CardView]()
        let dealToStView = setView.convert(scorceLabel.bounds, from: scorceLabel)
        selectedCard.forEach {
            let index = cardsOnScreen.index(of: $0)
            let card = CardView(frame: $0.frame, card: engine.cardOnTable[index!])
            card.isFaceUp = true
            let flipCard = CardView(frame: dealToStView, card: engine.cardOnTable[index!])
            flipCard.isFaceUp = true
            flayCards.append(card)
            flipCards.append(flipCard)
            setView.addSubview(flipCard)
            setView.addSubview(card)
        }
       
        selectedCard.forEach() {
            $0.alpha = 0
        }
        
        flayCards.forEach() {
            flyBehavior.addItem($0)
        }
        
        
        
        for cards in flayCards {
            UIView.animate(withDuration: 0.7,
                           animations: {
                            cards.alpha = 0
                            flipCards.forEach {
                                self.setView.addSubview($0)
                            }
            },
                           completion: { finished in
                            UIView.transition(with: cards,
                                              duration: 1,
                                              options: .transitionFlipFromLeft,
                                              animations: {
                                                flipCards.forEach {
                                                    $0.isFaceUp = false
                                                    $0.alpha = 1
                                                }
                                        },
                                              completion: { finished in
                                                cards.removeFromSuperview()
                                                flipCards.forEach {
                                                    $0.removeFromSuperview()
                                                }
                                                
                            })
            })
        }
        putCardIntoScreen()
       
    }
    
   private func putCardIntoScreen() {
        selectedCard.forEach {
            $0.alpha = 1
        }
        
        var isNeedSmall = false
        let dealToStView = setView.convert(moreThreeButton.bounds, from: moreThreeButton)
        if cardsNeedAnimated.count != 0 { cardsNeedAnimated = [] }
        
        selectedCard.forEach {
            
            let index = cardsOnScreen.index(of: $0)!
            let card = cardsOnScreen[index]
            if engine.deck.count > 0 || engine.cardOnTable.count == cardsOnScreen.count {
                cardsOnScreen[index] = CardView(frame: dealToStView, card: engine.cardOnTable[index])
                card.removeFromSuperview()
                setView.addSubview(cardsOnScreen[index])
                cardsOnScreen[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(_:))))
                cardsNeedAnimated.append(cardsOnScreen[index])
            } else {
                $0.removeFromSuperview()
                cardsOnScreen.remove(at: cardsOnScreen.index(of: $0)!)
                isNeedSmall = true
            }
        }
        
        if isNeedSmall {
            smallCardOnScreen()
        } else {
            flyIn()
        }
    }
    
    @objc private func tapCard(_ recognizer: UITapGestureRecognizer) {
        guard let tappedCard = recognizer.view as? CardView else { return }
        // print(tappedCard.card!)
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
                flayaway()
                
            } else {
                cardsOnScreen.forEach() {
                    $0.state = State.stateOfSeclection.unselected
                    $0.setNeedsDisplay()
                }
            }
            selectedCard.removeAll()
            engine.selectedCard.removeAll()
            updateScore()
        }
 
    }
    
    
}







