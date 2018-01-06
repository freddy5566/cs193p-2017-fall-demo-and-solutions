//
//  CardView.swift
//  Set
//
//  Created by jamfly on 2018/1/6.
//  Copyright © 2018年 jamfly. All rights reserved.
//

import UIKit

class CardView: UIView {

    
    var number: Card.Number?
    var shape: Card.Shape?
    var color: Card.Color?
    var fill: Card.Fill?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(card: Card) {
        self.init(frame: .zero)
        self.number = card.number
        self.shape = card.shape
        self.color = card.color
        self.fill = card.fill
    }
    
  
    
   
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
