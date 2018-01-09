//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by CS193p Instructor.
//  Copyright © 2017 CS193p Instructor. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate, EmojiArtViewDelegate
{
    // MARK: - Model
    
    // computed property for our Model
    // if someone sets this, we'll update our UI
    // if someone asks for this, we'll cons up a Model from the UI

    var emojiArt: EmojiArt? {
        get {
            if let url = emojiArtBackgroundImage.url {
                let emojis = emojiArtView.subviews.flatMap { $0 as? UILabel }.flatMap { EmojiArt.EmojiInfo(label: $0) }
                return EmojiArt(url: url, emojis: emojis)
            }
            return nil
        }
        set {
            emojiArtBackgroundImage = (nil, nil)
            emojiArtView.subviews.flatMap { $0 as? UILabel }.forEach { $0.removeFromSuperview() }
            if let url = newValue?.url {
                imageFetcher = ImageFetcher(fetch: url) { (url, image) in
                    DispatchQueue.main.async {
                        self.emojiArtBackgroundImage = (url, image)
                        newValue?.emojis.forEach {
                            let attributedText = $0.text.attributedString(withTextStyle: .body, ofSize: CGFloat($0.size))
                            self.emojiArtView.addLabel(with: attributedText, centeredAt: CGPoint(x: $0.x, y: $0.y))
                        }
                    }
                }
            }

        }
    }
    
    // MARK: - Document Handling

    var document: EmojiArtDocument?
    
    // MODIFIED AFTER LECTURE 14
    // we no longer need a save method or button
    // because now we are the EmojiArtView's delegate
    // (search for "delegate = self" below)
    // and we get notified when the EmojiArtView changes
    // (we also note when a new image is dropped, search "documentChanged" below)
    // and so we can just update our UIDocument's Model to match ours
    // and tell our UIDocument that it has changed
    // and it will autosave at the next opportune moment

//  @IBAction func save(_ sender: UIBarButtonItem? = nil) {
    func documentChanged() {
        // NO CHANGES *INSIDE* THIS METHOD WERE MADE AFTER LECTURE 14
        // JUST ITS NAME WAS CHANGED (FROM save TO documentChanged)
        
        // update the document's Model to match ours
        document?.emojiArt = emojiArt
        // then tell the document that something has changed
        // so it will autosave at next best opportunity
        if document?.emojiArt != nil {
            document?.updateChangeCount(.done)
        }
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        // MODIFIED AFTER LECTURE 14
        // the call to save() that used to be here has been removed
        // because we no longer explicitly save our document
        // we just mark that it has been changed
        // and since we are reliably doing that now
        // we don't need to try to save it when we close it
        // UIDocument will automatically autosave when we close()
        // if it has any unsaved changes
        // the rest of this method is unchanged from lecture 14

        // set a nice thumbnail instead of an icon for our document
        if document?.emojiArt != nil {
            document?.thumbnail = emojiArtView.snapshot
        }
        // dismiss ourselves from having been presented modally
        // and when we're done, close our document
        dismiss(animated: true) {
            self.document?.close()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // whenever we appear, we'll open our document
        // (might want to close it in viewDidDisappear, by the way)
        document?.open { success in
            if success {
                self.title = self.document?.localizedName
                // update our Model from the document's Model
                self.emojiArt = self.document?.emojiArt
            }
        }
    }
    
    // MARK: - Storyboard

    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiArtView)
        }
    }
    
    // change our scroll view's width and height constraints
    // in the storyboard
    // to be the same as the scroll view's content area's size
    // the width and height are lower priority constraints
    // than "stay within the edges" and "keep the scroll view centered"
    // so this will still work for very large content area sizes
    // (a scroll view's content area gets very large when you zoom in on it)

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant = scrollView.contentSize.width
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    // MARK: - Emoji Art View

    // MODIFIED AFTER LECTURE 14
    // when we create our EmojiArtView, we also set ourself as its delegate
    // so that we can get emojiArtViewDidChange messages sent to us

    lazy var emojiArtView: EmojiArtView = {
        let eav = EmojiArtView()
        eav.delegate = self
        return eav
    }()
    
    // EmojiArtViewDelegate
    
    func emojiArtViewDidChange(_ sender: EmojiArtView) {
        // just let our document know that the document has changed
        // that way it can autosave it at an opportune time
        documentChanged()
    }

    // we make this a tuple
    // so that whenever a background image is set
    // we also capture the url of that image

    var emojiArtBackgroundImage: (url: URL?, image: UIImage?) {
        get {
            return (_emojiArtBackgroundImageURL, emojiArtView.backgroundImage)
        }
        set {
            _emojiArtBackgroundImageURL = newValue.url
            scrollView?.zoomScale = 1.0
            emojiArtView.backgroundImage = newValue.image
            let size = newValue.image?.size ?? CGSize.zero
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            scrollViewHeight?.constant = size.height
            scrollViewWidth?.constant = size.width
            if let dropZone = self.dropZone, size.width > 0, size.height > 0 {
                scrollView?.zoomScale = max(dropZone.bounds.size.width / size.width, dropZone.bounds.size.height / size.height)
            }
        }
    }

    // this starts with _ because it's not something we set directly
    // the value of this is owned by the non-_ var emojiArtBackgroundImage

    private var _emojiArtBackgroundImageURL: URL?

    // MARK: - Emoji Collection View

    // a String is a Collection of Character
    // we want this var to be an Array of String
    // so we use .map to convert it

    var emojis = "😀🎁✈️🎱🍎🐶🐝☕️🎼🚲♣️👨‍🎓✏️🌈🤡🎓👻☎️".map { String($0) }

    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet {
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            emojiCollectionView.dragDelegate = self
            emojiCollectionView.dropDelegate = self
            // dragging in a Collection View is disabled by default on iPhone
            // we want it enabled on all platforms
            emojiCollectionView.dragInteractionEnabled = true
        }
    }
    
    private var font: UIFont {
        // adjust for the user's Accessibility font size preference
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }
    
    // addingEmoji is a mode we go into when we want to put up a text field
    // in section 0 of our Collection View
    // which allows us to type in more emoji to add to our Collection View

    private var addingEmoji = false
    
    @IBAction func addEmoji() {
        addingEmoji = true
        // reload section zero because now it contains a text field
        // instead of a button
        emojiCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section 0: button or text field to add emoji
        // section 1: our emoji
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
            case 0: return 1            // either a button or a text field cell
            case 1: return emojis.count // our emoji
            default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            // our emoji are shown using an EmojiCollectionViewCell
            // which has an outlet to a lable to show the emoji
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            if let emojiCell = cell as? EmojiCollectionViewCell {
                let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font:font])
                emojiCell.label.attributedText = text
            }
            return cell
        } else if addingEmoji {
            // if we're addingEmoji (and we're being asked for a cell in section 0)
            // then we need our EmojiInputCell which has a text field in it
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiInputCell", for: indexPath)
            if let inputCell = cell as? TextFieldCollectionViewCell {
                // the resignationHandler is called when the cell's text field
                // resigns first responder (i.e. it is not the text field receiving keyboard input)
                inputCell.resignationHandler = { [weak self, unowned inputCell] in
                    // have to make self weak and inputCell unowned to prevent memory cycle
                    if let text = inputCell.textField.text {
                        self?.emojis = (text.map { String($0) } + self!.emojis).uniquified
                    }
                    self?.addingEmoji = false
                    // reload the Collection View
                    // because section 0 is going to change (back to a + button)
                    // and because we've added new emoji to section 1
                    self?.emojiCollectionView.reloadData()
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddEmojiButtonCell", for: indexPath)
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    // section 0's cell should be wider
    // but only if it's showing the text field (i.e. we're addingEmoji)
    // note that we are using constants here
    // that's bad
    // we should calculate our cell height based on the size of our emoji font
    // we should also set the height of our Collection View itself based on that
    // (via an outlet to a constraint on the Collection View in the storyboard)

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if addingEmoji && indexPath.section == 0 {
            return CGSize(width: 300, height: 80)
        } else {
            return CGSize(width: 80, height: 80)
        }
    }
    
    // MARK: - UICollectionViewDelegate

    // just before we ever display the text field for addingEmoji
    // let's make it the first responder and so bring up the keyboard

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let inputCell = cell as? TextFieldCollectionViewCell {
            inputCell.textField.becomeFirstResponder()
        }
    }

    // MARK: - UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView // so we know when a drag "is us"
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        // prevent dragging when we're addingEmoji (just smoother that way)
        // cellForItem(at:) only works for visible cells
        // but if we're dragging from a cell, it definitely will be visible
        if !addingEmoji, let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            dragItem.localObject = attributedString
            return [dragItem]
        } else {
            return []
        }
    }

    // MARK: - UICollectionViewDropDelegate

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if let indexPath = destinationIndexPath, indexPath.section == 1 {
            // if we're dropping a drag from ourself, .move, else .copy
            let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
            return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
        } else {
            // only allow dragging around in section 1 (the emoji)
            // not in section 0 (the button or text field for addingEmoji)
            return UICollectionViewDropProposal(operation: .cancel)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
    ) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        // go through all the things that are being dropped on us
        for item in coordinator.items {
            // the item will only have a sourceIndexPath
            // if this drag was initiated inside ourself
            if let sourceIndexPath = item.sourceIndexPath {
                if let attributedString = item.dragItem.localObject as? NSAttributedString {
                    // drag and drop from ourself
                    collectionView.performBatchUpdates({
                        // update our Model to move the emoji to the new spot
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributedString.string, at: destinationIndexPath.item)
                        // update the Collection View
                        // note that since this takes us two steps
                        // we have to do this inside performBatchUpdates()
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    // ask the coordinator to animate the drop happening
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                // this drag is from somewhere else
                // we can only get the data from that somewhere else asynchronously
                // so we have to put a placeholder into our Collection View
                // while we wait for that asynchronous data to appear
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell")
                )
                // go get the data asynchronously
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                    // when it arrives, go back to the main queue ...
                    DispatchQueue.main.async {
                        // ... and grab the dropped string ...
                        if let attributedString = provider as? NSAttributedString {
                            // ... and then replace the placeholder
                            // we are only responsible for updating our Model here
                            // the Collection View will take care of replacing the placeholder
                            // with a cell by calling our cellForItem(at:) dataSource method
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.emojis.insert(attributedString.string, at: insertionIndexPath.item)
                            })
                        } else {
                            // hmm, couldn't get the data for some reason
                            // so delete the placeholder
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }

    // MARK: - UIDropInteractionDelegate

    // this is for dropping into our dropZone (not the Collection View)
    // we only accept drops that can provide both URL and UIImage data
    // we're hoping that the URL is a URL to that UIImage (not guaranteed to be so)

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    // ImageFetcher is defined in Utilities.swift
    // it fetches a url but also allows a "backup" image to be defined
    // if it has to resort to the backup, then it puts it in the filesystem
    // so this will not work very well for documents stored on iCloud Drive for example
    // makes the demos a bit smoother though :)
    
    var imageFetcher: ImageFetcher!
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFetcher = ImageFetcher() { (url, image) in
            DispatchQueue.main.async {
                // we've received the dropped image from the url
                // (or we've fallen back on using the backup image)
                // now go set this as the background of our EmojiArt document
                self.emojiArtBackgroundImage = (url, image)
                // ADDED AFTER LECTURE 14
                // in addition to emoji being added in our EmojiArtView
                // causing our document to change
                // whenever a new background image is dropped
                // our document changes as well
                // so we note that
                self.documentChanged()
            }
        }

        session.loadObjects(ofClass: NSURL.self) { nsurls in
            if let url = nsurls.first as? URL {
                self.imageFetcher.fetch(url)
            }
        }
        session.loadObjects(ofClass: UIImage.self) { images in
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        }
    }
}

// an extension to our Model
// note that this has "UI stuff" in it
// because it uses UILabel
// that's okay because this code is in our Controller
// (even though it extends code in our Model)
// for MVC purposes, it's where the code is defined that matters

// just creates an EmojiArt.EmojiInfo from a UILabel
// is a failable initializer
// returns nil if we can't create the EmojiInfo from the given UILabel

extension EmojiArt.EmojiInfo
{
    init?(label: UILabel) {
        if let attributedText = label.attributedText, let font = attributedText.font {
            x = Int(label.center.x)
            y = Int(label.center.y)
            text = attributedText.string
            size = Int(font.pointSize)
        } else {
            return nil
        }
    }
}
