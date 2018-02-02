//
//  GalleryCollectionViewController.swift
//  Image_Gallery
//
//  Created by jamfly on 2018/1/26.
//  Copyright © 2018年 jamfly. All rights reserved.
//

import UIKit


class GalleryCollectionViewController: UICollectionViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout {
   

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.dropDelegate = self
        collectionView?.dragDelegate = self
        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(scalCell(_:))))
        collectionView?.dragInteractionEnabled = true
    }
    
    private var scaleForCollectionViewCell: CGFloat = 1.0
    
    @objc private func scalCell(_ reconizer: UIPinchGestureRecognizer) {
        switch reconizer.state {
        case .changed, .ended:
            scaleForCollectionViewCell *= reconizer.scale
            reconizer.scale = 1
            flowLayout?.invalidateLayout()
        default:
            break
        }
    }
    
    private var galleryImageURL = [URL]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var imageGallery: ImageGallery? {
        get {
            return ImageGallery(imagesURL: galleryImageURL, scale: Float(scaleForCollectionViewCell))
        }
        set {
            guard let scale = newValue?.scale else { return }
            guard let imagesURL = newValue?.imgaesURL else { return }
            scaleForCollectionViewCell = CGFloat(scale)
            galleryImageURL = imagesURL
        }
    }
    
    // MARK: - storyBoard
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        document?.imageGallery = imageGallery
        
        if document?.imageGallery != nil {
            document?.updateChangeCount(.done)
        }
    }
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        if document?.imageGallery != nil {
            document?.thumbnail = self.view.snapshot
        }
        dismiss(animated: true) {
            self.document?.close()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document?.open { success in
            if success {
                self.title = self.document?.localizedName
                self.imageGallery = self.document?.imageGallery
            }
            
        }
    }
    // MARK: - Document
    
    var document: ImageGalleryDocument?
    
    // MARK: - drag and drop
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
          return session.canLoadObjects(ofClass: NSURL.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItem(at: indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }
    
    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        if let galleryImageURL = (collectionView?.cellForItem(at: indexPath) as? GalleryCollectionViewCell)?.imageURL {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: galleryImageURL as NSItemProviderWriting))
            dragItem.localObject = dragItem
            return [dragItem]
        }
        return []
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?)
        -> UICollectionViewDropProposal {
        
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        let destionationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let url = item.dragItem.localObject as? URL {
                    collectionView.performBatchUpdates({
                        galleryImageURL.remove(at: sourceIndexPath.item)
                        galleryImageURL.insert(url, at: destionationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destionationIndexPath])
                    })
                    coordinator.drop(item.dragItem,
                                     toItemAt: destionationIndexPath)
                }
            } else {
                let placeHolderContext = coordinator.drop(item.dragItem,
                                                          to: UICollectionViewDropPlaceholder(insertionIndexPath: destionationIndexPath,
                                                                                              reuseIdentifier: "GalleryCircleCell"))
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? URL {
                            
                            placeHolderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.galleryImageURL.insert(url.imageURL, at: insertionIndexPath.item)
                                
                            })
                        } else {
                            placeHolderContext.deletePlaceholder()
                        }
                    }
                    
                }
            }
        }
    }
    
    

   
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let cell = sender as? GalleryCollectionViewCell {
            return cell.imageURL != nil
        } else {
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination.contents as? ImageViewController else { return }
        if let cell = sender as? GalleryCollectionViewCell {
            vc.imageURL = cell.imageURL
        }
    }
 

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
     
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryImageURL.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionCell", for: indexPath) as! GalleryCollectionViewCell
        
        cell.imageURL = galleryImageURL[indexPath.item]
        
        
        return cell
    }
    
    // MARK: - UICollectionViewLayout
    private var flowLayout: UICollectionViewLayout? {
        return collectionView?.collectionViewLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = 200 * scaleForCollectionViewCell
        
        return CGSize(width: cellWidth, height: cellWidth)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}


