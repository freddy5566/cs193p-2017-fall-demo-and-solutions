//
//  SetGrid.swift
//  Set
//
//  Created by jamfly on 2018/1/12.
//  Copyright © 2018年 jamfly. All rights reserved.
//

import UIKit

struct SetGrid {
    
    private var bounds: CGRect { didSet { calculateGrid() } }
    private var numberOfFrames: Int  { didSet { calculateGrid() } }
    static var idealAspectRatio: CGFloat = 0.7
    
    var row: Int {
        if let rows = bestGridDimensions?.rows {
            return rows
        }
        return 0
    }
    
    var col: Int {
        if let rows = bestGridDimensions?.cols {
            return rows
        }
        return 0
    }
    
    init(for bounds: CGRect, withNoOfFrames: Int, forIdeal aspectRatio: CGFloat = SetGrid.idealAspectRatio) {
        self.bounds = bounds
        self.numberOfFrames = withNoOfFrames
        SetGrid.idealAspectRatio = aspectRatio
        calculateGrid()
    }
    
    subscript(index: Int) -> CGRect? {
        return index < cellFrames.count ? cellFrames[index] : nil
    }
    
    private struct GridDimensions: Comparable {
        static func <(lhs: SetGrid.GridDimensions, rhs: SetGrid.GridDimensions) -> Bool {
            return lhs.isCloserToIdeal(aspectRatio: rhs.aspectRatio)
        }
        
        static func ==(lhs: SetGrid.GridDimensions, rhs: SetGrid.GridDimensions) -> Bool {
            return lhs.cols == rhs.cols && lhs.rows == rhs.rows
        }
        
        var cols: Int
        var rows: Int
        var frameSize: CGSize
        var aspectRatio: CGFloat {
            return frameSize.width/frameSize.height
        }
        
        func isCloserToIdeal(aspectRatio: CGFloat) -> Bool {
            return (SetGrid.idealAspectRatio - aspectRatio).abs < (SetGrid.idealAspectRatio - self.aspectRatio).abs
        }
    }
    
    private var bestGridDimensions: GridDimensions?
    
    private mutating func calculateGridDimensions() {
        for cols in 1...numberOfFrames {
            let rows = numberOfFrames % cols == 0 ? numberOfFrames / cols: numberOfFrames/cols + 1
         
            let calculatedframeDimension = GridDimensions(
                cols: cols,
                rows: rows,
                frameSize: CGSize(width: bounds.width / CGFloat(cols), height: bounds.height / CGFloat(rows))
            )
            
            if let bestFrameDimension = bestGridDimensions, bestFrameDimension > calculatedframeDimension {
                return
            } else {
                self.bestGridDimensions = calculatedframeDimension
            }
        }
        return
    }
    
    private var cellFrames: [CGRect] = []
    
    private mutating func calculateGrid() {
        var grid = [CGRect]()
        calculateGridDimensions()
        
        guard let bestGridDimensions = bestGridDimensions else {
            grid = []
            return
        }
        
        for row in 0..<bestGridDimensions.rows {
            for col in 0..<bestGridDimensions.cols {
                let origin = CGPoint(x: CGFloat(col) * bestGridDimensions.frameSize.width, y: CGFloat(row) * bestGridDimensions.frameSize.height)
                let rect = CGRect(origin: origin, size: bestGridDimensions.frameSize)
                grid.append(rect)
            }
        }
        self.cellFrames = grid
    }
}

extension CGFloat {
    var abs: CGFloat {
        return self<0 ? -self: self
    }
}









