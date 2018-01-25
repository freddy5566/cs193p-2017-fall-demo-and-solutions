//
//  GalleryCollectionViewCell.swift
//  Image_Gallery
//
//  Created by jamfly on 2018/1/26.
//  Copyright © 2018年 jamfly. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    var imageURL: URL? {
        didSet {
            image = nil
            // check if on screen
            if self.window != nil {
                fetchImage()
            }
        }
    }

    private var image: UIImage? {
        get {
            return imageView?.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents, url == self?.imageURL {
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    // MARK: - storyboard
    
    @IBOutlet weak var imageView: UIImageView!
    
  
    
}
