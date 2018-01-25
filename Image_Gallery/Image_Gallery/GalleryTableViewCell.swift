//
//  GalleryTableViewCell.swift
//  Image_Gallery
//
//  Created by jamfly on 2018/1/25.
//  Copyright © 2018年 jamfly. All rights reserved.
//

import UIKit

class GalleryTableViewCell: UITableViewCell, UITextFieldDelegate {

    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
            textField.clearsOnBeginEditing = false
            textField.isUserInteractionEnabled = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(editName(_:)))
            tap.numberOfTapsRequired = 2
            self.addGestureRecognizer(tap)
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc private func editName(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            textField.isUserInteractionEnabled = true
            textField.becomeFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.isUserInteractionEnabled = false
        return true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
