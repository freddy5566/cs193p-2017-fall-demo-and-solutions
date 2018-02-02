//
//  DocumentInfoViewController.swift
//  EmojiArt
//
//  Created by CS193p Instructor.
//  Copyright © 2017 CS193p Instructor. All rights reserved.
//

import UIKit

class DocumentInfoViewController: UIViewController
{
    // MARK: - Model
    
    var document: EmojiArtDocument? {
        didSet { updateUI() }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    // any time we get re-layed out
    // we reset our preferredContentSize
    // to tightly fit our top-level stack view
    // using autolayout, i.e., sizeThatFits(UILayoutFittingCompressedSize)

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let fittedSize = topLevelView?.sizeThatFits(UILayoutFittingCompressedSize) {
            preferredContentSize = CGSize(width: fittedSize.width + 30, height: fittedSize.height + 30)
        }
    }
    
    // MARK: - UI Updating
    
    // we always want to use a DateFormatter
    // to present Dates
    // it's part of the internationalization process

    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    // simply makes our UI reflect our Model
    // by looking up the document's url in the file system
    // to get various attributes of the file
    // also we show the document's thumbnail
    // with the correct aspect ratio
    // by removing and then adding back an appropriate NSLayoutConstraint
    
    private func updateUI() {
        if sizeLabel != nil, createdLabel != nil,
            let url = document?.fileURL,
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
            sizeLabel.text = "\(attributes[.size] ?? 0) bytes"
            if let created = attributes[.creationDate] as? Date {
                createdLabel.text = shortDateFormatter.string(from: created)
            }
        }
        if thumbnailImageView != nil, thumbnailAspectRatio != nil, let thumbnail = document?.thumbnail {
            thumbnailImageView.image = thumbnail
            thumbnailImageView.removeConstraint(thumbnailAspectRatio)
            // an aspect ratio constraint
            // is just a relationship (by multiplier)
            // between a view's own width and height
            thumbnailAspectRatio = NSLayoutConstraint(
                item: thumbnailImageView,
                attribute: .width,
                relatedBy: .equal,
                toItem: thumbnailImageView,
                attribute: .height,
                multiplier: thumbnail.size.width / thumbnail.size.height,
                constant: 0
            )
            thumbnailImageView.addConstraint(thumbnailAspectRatio)
        }
        // here we configure our UI to look a bit different in a popover
        // be careful, this will also affect "adapted" modal presentations
        // in horizontally compact trait environments
        if presentationController is UIPopoverPresentationController {
            thumbnailImageView?.isHidden = true
            returnToDocumentButton?.isHidden = true
            view.backgroundColor = .clear
        }
    }
    
    // MARK: - Storyboard
    
    // here we dismiss (but don't Unwind)
    // as a result of the Return to Document button
    // see the Close Document button for an example of Unwind Segue
    
    @IBAction func done() {
        presentingViewController?.dismiss(animated: true)
    }

    @IBOutlet weak var returnToDocumentButton: UIButton! // hide dismiss button in popover
    @IBOutlet weak var topLevelView: UIStackView!        // for preferredContentSize
    @IBOutlet weak var thumbnailAspectRatio: NSLayoutConstraint!  // we replace this

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
}
