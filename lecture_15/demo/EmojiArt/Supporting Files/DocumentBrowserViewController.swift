//
//  DocumentBrowserViewController.swift
//  EmojiArt
//
//  Created by CS193p Instructor.
//  Copyright © 2017 CS193p Instructor. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate
{
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        allowsPickingMultipleItems = false
        allowsDocumentCreation = false
        // only allow document creation on iPad
        // since that's the only place with multitasking
        // that allows us to set a background image for our EmojiArt
        if UIDevice.current.userInterfaceIdiom == .pad {
            // create a blank document in our Application Support directory
            // this template will be copied to Documents directory for new docs
            // see didRequestDocumentCreationWithHandler delegate method
            template = try? FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
//              ).appendingPathComponent("Untitled.json")
                ).appendingPathComponent("Untitled.emojiart")
            // CHANGE MADE AFTER LECTURE 14
            // the above change to the name of our blank template
            // combined with the addition of an emojiart file type
            // in Exported UTIs in Project Settings for Target's Info tab
            // and changing the Document Type in that tab to edu.stanford.cs193p.emojiart
            // makes it so documents can now be opened in our app from the Files app!
            if template != nil {
                // if we can't create the template
                // don't enable the Create Document button in the UI
                allowsDocumentCreation = FileManager.default.createFile(atPath: template!.path, contents: Data())
            }
        }
    }
    
    var template: URL? // blank template for new documents
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        // just call the passed-in handler with our template
        // we .copy it to make new documents
        importHandler(template, .copy)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL)
    {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        // get the VC(s) we're going to use to show our EmojiArt document
        let documentVC = storyBoard.instantiateViewController(withIdentifier: "DocumentMVC")
        // configure our EmojiArtViewController with a new EmojiArtDocument
        // at the requested documentURL
        // note that we must use the documentVC's .contents (defined in Utilities.swift)
        // to look inside the navigation controller that is wrapped around our EmojiArtViewController
        if let emojiArtViewController = documentVC.contents as? EmojiArtViewController {
            emojiArtViewController.document = EmojiArtDocument(fileURL: documentURL)
        }
        // now present the MVC to show a document modally
        // this will take over the entire screen until it dismisses itself
        present(documentVC, animated: true)
    }
}
