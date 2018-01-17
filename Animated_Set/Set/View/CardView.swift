//
//  CardView.swift
//  Set
//
//  Created by freddy on 10/01/2018.
//  Copyright © 2018 jamfly. All rights reserved.
//

import UIKit

class CardView: UIView {

    
  
    var state: State.stateOfSeclection?
    var card: Card?
    var isFaceUp: Bool
    
    private var color: Card.Color? {
        return card?.color
    }
    private var shape: Card.Shape? {
        return card?.shape
    }
    private var number: Card.Number? {
        return card?.number
    }
    private var fill: Card.Fill? {
        return card?.fill
    }
    
    private var heightOfObject: CGFloat {
        return bounds.height / 4
    }
    
    private var marginToObject: CGFloat {

        return bounds.midX - heightOfObject / 2
    }
    
    private var spaceBetweenObject: CGFloat {
        if let number = number {
            switch number {
            case .one:
                return bounds.height * 3 / 8
            case .two:
                return bounds.height * 1 / 6
            case .three:
                return bounds.height * 1 / 16
            }
        }
        return bounds.height * 3 / 8
    }
    
    override init(frame: CGRect) {
        isFaceUp = false
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        isFaceUp = false
        super.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect, card: Card) {
        self.init(frame: frame)
        self.card = card
        self.state = State.stateOfSeclection.unselected
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    private var objectFrame: [CGRect] {
        var frames = [CGRect]()
        guard let number = number else { return []}
        var y = spaceBetweenObject
        // first object
        var objectFrame = CGRect(x: marginToObject, y: y, width: heightOfObject, height: heightOfObject)
        frames.append(objectFrame)
        
        // second and third if there is one
        for _ in 1..<number.rawValue {
            y += (spaceBetweenObject + heightOfObject)
            objectFrame = CGRect(x: marginToObject, y: y, width: heightOfObject, height: heightOfObject)
            frames.append(objectFrame)
        }
       return frames
    }
    
    private func drawObject() {
        for object in subviews {
            object.removeFromSuperview()
        }
        if let number = number?.rawValue {
            for index in 0..<number {
                if let shape = shape, let color = color, let fill = fill {
                    
                    let object = ObjectView(frame: objectFrame[index], shape: shape, color: color, fill: fill)
                    
                    addSubview(object)
                }
            }
        }
    }
    
    private var boarderColor: UIColor {
        
        if let state = state {
            switch state {
            case .hinted:
                return #colorLiteral(red: 0.423529923, green: 0.6870478392, blue: 0.8348321319, alpha: 1)
            case .selected:
                return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            case .unselected:
                return #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            }
        }
        
        return #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
    override func draw(_ rect: CGRect) {
        
        if isFaceUp {
            drawObject()
            let boarder = UIBezierPath(rect: CGRect(x: bounds.origin.x,
                                                    y: bounds.origin.y,
                                                    width: bounds.width,
                                                    height: bounds.height))
            
            boarder.lineWidth = state == State.stateOfSeclection.unselected ?
                Boarder.unselectedBoarderWidth :
                Boarder.selectedBoarderWidth
            boarderColor.setStroke()
            boarder.stroke()
        } else {
            let back = UIBezierPath(rect: bounds)
            #colorLiteral(red: 0.423529923, green: 0.6870478392, blue: 0.8348321319, alpha: 1).setFill()
            back.fill()
        }
       
    }
    

}

struct Boarder {
    static let unselectedBoarderWidth: CGFloat = 3
    static let selectedBoarderWidth: CGFloat = 5
}

struct State {
    
    enum stateOfSeclection {
        case selected
        case unselected
        case hinted
    }
    
}

