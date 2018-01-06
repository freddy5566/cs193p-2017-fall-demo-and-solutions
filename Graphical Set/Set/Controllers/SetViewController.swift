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
  
    @IBOutlet weak private var moreThreeButton: UIButton!
    @IBOutlet weak private var hintButton: UIButton!
    @IBOutlet weak private var newGameButton: UIButton!
    @IBOutlet weak private var scorceLabel: UILabel!
    
    @IBOutlet weak var playAgainButton: UIButton!
    
    @IBOutlet weak var setView: UIView!
    
    
    @IBAction func playAfainButtonPressed(_ sender: UIButton) {
    }
    
    
    private func updateScore() {
        scorceLabel.text = "\(engine.score)"
    }
    
 
    @IBAction private func moreThreeButtonPressed(_ sender: UIButton) {
        engine.draw()
        hiddenButtonIfNeed()
        
    }
    
    @IBAction private func hintButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction private func newGameButtonPressed(_ sender: UIButton) {
        engine.reset()
        hiddenButtonIfNeed()
        updateScore()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playAgainButton.isHidden = true
    }
    
    private func hiddenButtonIfNeed() {
        if engine.cardOnTable.count == 24 || engine.numberOfCard == 0 {
            moreThreeButton.isHidden = true
        } else {
            moreThreeButton.isHidden = false
        }
    }
    
    
}








