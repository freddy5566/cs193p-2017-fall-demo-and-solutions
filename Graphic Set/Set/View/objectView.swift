//
//  objectView.swift
//  Set
//
//  Created by jamfly on 2018/1/12.
//  Copyright © 2018年 jamfly. All rights reserved.
//

import UIKit

class objectView: UIView {

    private var shape: Card.Shape?
    private var color: Card.Color?
    private var fill: Card.Fill?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect, shape: Card.Shape, color: Card.Color, fill: Card.Fill) {
        self.init(frame: frame)
        self.shape = shape
        self.color = color
        self.fill = fill
    }
    
    private var path: UIBezierPath {
        if let shape = shape {
            switch shape {
            case .circle:
                return UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                    radius: bounds.height / 2,
                                    startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            case .square:
                return UIBezierPath(rect: CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height))
            case .triangle:
                let path = UIBezierPath()
                path.move(to: CGPoint(x: bounds.width / 2, y: bounds.origin.y))
                path.addLine(to: CGPoint(x: bounds.origin.x, y: bounds.height))
                path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
                path.close()
                return path
            }
        }
        return UIBezierPath()
    }
    
    
    
    
    
    override func draw(_ rect: CGRect) {
        let shape = path
        var objectColor: UIColor
        if let color = color {
            switch color {
            case .green:
                objectColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            case .purple:
                objectColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            case .red:
                objectColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            }
        }
        
        if let fill = fill {
            switch fill {
            case .empty:
                shape.stroke()
            case .solid:
                shape.fill()
            case .stripe:
                break
            }
        }
    }
    

}
