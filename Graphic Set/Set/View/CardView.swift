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
    
    var factorOfFill: CGFloat = 0.7
    var spaceBetweenObject: CGFloat {
        return bounds.height / 4 * (1 - factorOfFill)
    }
    
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
    
    private var objectFrame: [CGRect] {
        guard let numberOfObject = number?.rawValue else { return []}
        let objectHeight = (bounds.height - CGFloat((numberOfObject + 1)) * spaceBetweenObject) / CGFloat(numberOfObject)
        var frames = [CGRect]()
        var y = spaceBetweenObject
        for _ in 1..<numberOfObject {
            let frame = CGRect(x: (bounds.width - objectHeight) / 2,
                               y: y, width: objectHeight, height: objectHeight)
            frames.append(frame)
            y += (spaceBetweenObject + objectHeight)
        }
        
       return frames
    }
    
    private func drawObject() {
        if let number = number?.rawValue {
            for index in 0...number {
                if let shape = shape, let color = color, let fill = fill {
                    let object = objectView(frame: objectFrame[index], shape: shape, color: color, fill: fill)
                    addSubview(object)
                }
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        drawObject()
    }
 

}
