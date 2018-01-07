//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by jamfly on 2018/1/7.
//  Copyright © 2018年 jamfly. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {

    var backgroundImage: UIImage? { didSet{ setNeedsDisplay() } }
    
    
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
 
    

}
