//
//  Card.swift
//  Set
//
//  Created by freddy on 30/12/2017.
//  Copyright © 2017 jamfly. All rights reserved.
//

import Foundation

struct Card{
    
   
    var color: Color
    var number: Number
    var shape: Shape
    var fill: Fill

    lazy var matrix = [color.rawValue, number.rawValue, shape.rawValue, fill.rawValue]
    
    enum Color: String, CustomStringConvertible {
        case red = "red"
        case green = "green"
        case purple = "purple"
        var description: String { return rawValue }
        static let all = [Color.red, .green, .purple]
        
    }
    
    enum Number: Int, CustomStringConvertible {
        
        case one = 1
        case two
        case three
        var description: String { return String(rawValue) }
        static let all = [Number.one, .two, .three]
    }
    
    enum Shape: String, CustomStringConvertible {
        case circle = "circle"
        case square = "square"
        case triangle = "triangle"
        var description: String { return rawValue }
        static let all = [Shape.circle, .square, .triangle]
    }
    
    enum Fill: String, CustomStringConvertible {
        case solid = "solid"
        case stripe = "stripe"
        case empty = "empty"
        var description: String { return rawValue }
        static let all = [Fill.solid, .stripe, .empty]
    }
    
    init(with c: Color, _ n: Number, _ s: Shape, _ f: Fill) {
        color = c
        number = n
        shape = s
        fill = f
    }
    
}

extension Card: CustomStringConvertible {
    
    var description: String {
        return "color: \(color) number: \(number) shpae: \(shape) fill: \(fill)\n"
    }
    
}

extension Card: Equatable{
   
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.color == rhs.color &&
                lhs.shape == rhs.shape &&
                lhs.number == rhs.number &&
                lhs.fill == rhs.fill
    }
    
    
    
    
}









