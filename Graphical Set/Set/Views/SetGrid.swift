//
//  SetGrid.swift
//  Set
//
//  Created by jamfly on 2018/1/5.
//  Copyright © 2018年 jamfly. All rights reserved.
//

import UIKit

struct SetGrid {
   
    var frame: CGRect { didSet { recalculate() } }

    init(frame: CGRect = CGRect.zero, number: Int) {
        self.frame = frame
        self.cellCount = number
        recalculate()
    }
    
    subscript(row: Int, column: Int) -> CGRect? {
        return self[row * dimensions.columnCount + column]
    }
    
    subscript(index: Int) -> CGRect? {
        return index < cellFrames.count ? cellFrames[index] : nil
    }
    
    var cellCount: Int {
        get {
            return cellCountForAspectRatioLayout
        }
        set { cellCountForAspectRatioLayout = newValue }
    }
    
    var cellSize: CGSize {
        get { return cellFrames.first?.size ?? CGSize.zero }
    }
    
    var dimensions: (rowCount: Int, columnCount: Int) {
        get { return calculatedDimensions }
    }
    
    var aspectRatio: CGFloat = 0.7
    private var cellFrames = [CGRect]()
    private var cellCountForAspectRatioLayout = 0 { didSet { recalculate() } }
    private var calculatedDimensions: (rowCount: Int, columnCount: Int) = (0, 0)
    
    private mutating func recalculate() {
        
        assert(aspectRatio > 0, "Grid: for aspectRatio layout, aspectRatio must be a positive number")
        let cellSize = largestCellSizeThatFitsAspectRatio()
        if cellSize.area > 0 {
            calculatedDimensions.columnCount = Int(frame.size.width / cellSize.width)
            calculatedDimensions.rowCount = (cellCount + calculatedDimensions.columnCount - 1) / calculatedDimensions.columnCount
        } else {
            calculatedDimensions = (0, 0)
        }
        updateCellFrames(to: cellSize)
    }
    
    private mutating func updateCellFrames(to cellSize: CGSize) {
        cellFrames.removeAll()
        
        let boundingSize = CGSize(
            width: CGFloat(dimensions.columnCount) * cellSize.width,
            height: CGFloat(dimensions.rowCount) * cellSize.height
        )
        let offset = (
            dx: (frame.size.width - boundingSize.width) / 2,
            dy: (frame.size.height - boundingSize.height) / 2
        )
        var origin = frame.origin
        origin.x += offset.dx
        origin.y += offset.dy
        
        if cellCount > 0 {
            for _ in 0..<cellCount {
                cellFrames.append(CGRect(origin: origin, size: cellSize))
                origin.x += cellSize.width
                if round(origin.x) > round(frame.maxX - cellSize.width) {
                    origin.x = frame.origin.x + offset.dx
                    origin.y += cellSize.height
                }
            }
        }
    }
    
    private func largestCellSizeThatFitsAspectRatio() -> CGSize {
        var largestSoFar = CGSize.zero
        if cellCount > 0 && aspectRatio > 0 {
            for rowCount in 1...cellCount {
                largestSoFar = cellSizeAssuming(rowCount: rowCount, minimumAllowedSize: largestSoFar)
            }
            for columnCount in 1...cellCount {
                largestSoFar = cellSizeAssuming(columnCount: columnCount, minimumAllowedSize: largestSoFar)
            }
        }
        return largestSoFar
    }
    
    private func cellSizeAssuming(rowCount: Int? = nil, columnCount: Int? = nil, minimumAllowedSize: CGSize = CGSize.zero) -> CGSize {
        var size = CGSize.zero
        if let columnCount = columnCount {
            size.width = frame.size.width / CGFloat(columnCount)
            size.height = size.width / aspectRatio
        } else if let rowCount = rowCount {
            size.height = frame.size.height / CGFloat(rowCount)
            size.width = size.height * aspectRatio
        }
        if size.area > minimumAllowedSize.area {
            if Int(frame.size.height / size.height) * Int(frame.size.width / size.width) >= cellCount {
                return size
            }
        }
        return minimumAllowedSize
    }
    

}
private extension CGSize {
    var area: CGFloat {
        return width * height
    }
}








