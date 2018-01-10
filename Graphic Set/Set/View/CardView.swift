//
//  CardView.swift
//  Set
//
//  Created by freddy on 10/01/2018.
//  Copyright © 2018 jamfly. All rights reserved.
//

import UIKit

class CardView: UIView {

    
    var color: Card.Color?
    var shape: Card.Shape?
    var number: Card.Number?
    var fill: Card.Fill?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect, card: Card) {
        self.init(frame: frame)
        self.color = card.color
        self.shape = card.shape
        self.number = card.number
        self.fill = card.fill
    }
    
    var path: UIBezierPath? {
        
    }
    
    
    
    
    
    
    
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
 

}
