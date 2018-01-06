//
//  SetView.swift
//  Set
//
//  Created by jamfly on 2018/1/3.
//  Copyright © 2018年 jamfly. All rights reserved.
//

import UIKit

class SetView: UIView {
    private let deck = SetEngine()
    
    
    private var cardOnTable: [Card]? {
        
        if deck.cardOnTable.count > 0 {
            return deck.cardOnTable
        } else {
            return nil
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setNeedsLayout()
    }
    
    private let objectSizeToLineWidthRatio: CGFloat = 10
    
    var bezierPath: UIBezierPath {
        let paths = UIBezierPath()
        
        return paths
    }
    
    
    override func draw(_ rect: CGRect) {
        let grid = SetGrid(frame: self.bounds, number: 12)
                let paths = UIBezierPath(arcCenter: CGPoint(x: (grid[1]?.midX)!, y: (grid[1]?.midY)!), radius: 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
//        let path = UIBezierPath()
//        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        UIColor.green.setFill()
        UIColor.green.setFill()
        UIColor.red.setStroke()
        paths.stroke()
        paths.fill()
        
        
        
    }
    
    enum StateOfSetCardButton {
        case unselected
        case selected
        case hinted
        case selectedAndMatched
    }
    
    var stateOfSetCard: StateOfSetCardButton = .unselected {
        didSet {
            switch stateOfSetCard {
            case .unselected:
                layer.borderWidth = LayOutMetricsForCardView.borderWidth
                layer.borderColor = LayOutMetricsForCardView.borderColor
            case .selected:
                layer.borderWidth = LayOutMetricsForCardView.borderWidthIfSelected
                layer.borderColor = LayOutMetricsForCardView.borderColorIfSelected
            case .selectedAndMatched:
                layer.borderWidth = LayOutMetricsForCardView.borderWidthIfMatched
                layer.borderColor = LayOutMetricsForCardView.borderColorIfMatched
            case .hinted:
                layer.borderWidth = LayOutMetricsForCardView.borderWidthIfHinted
                layer.borderColor = LayOutMetricsForCardView.borderColorIfHinted
            }
        }
    }
}


struct LayOutMetricsForCardView {
    static var borderWidth: CGFloat = 1.0
    static var borderWidthIfSelected: CGFloat = 4.0
    static var borderColorIfSelected: CGColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
    
    static var borderWidthIfHinted: CGFloat = 4.0
    static var borderColorIfHinted: CGColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1).cgColor
    
    static var borderWidthIfMatched: CGFloat = 4.0
    static var borderColorIfMatched: CGColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).cgColor
    
    static var borderColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
    static var borderColorForDrawButton: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
    static var borderWidthForDrawButton: CGFloat = 3.0
    static var cornerRadius: CGFloat = 8.0
}

