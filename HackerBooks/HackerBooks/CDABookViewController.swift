//
//  CDABookViewController.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 07/05/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import UIKit


let FavoriteDidChangeNotification = "A book was added or removed from Favorites"
let FavoriteDidChangeKey = "FavoriteBookToggled"

let CoverUrlUpdatedNotification = "A book has updated its cover url to a relative local path"
let CoverUrlUpdatedKey = "CoverUrlUpdated"



class CDABookViewController: UIViewController {

    var model: CDABook
    
    
    // Reference to UI elements
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var tagList: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var favoriteStatus: UILabel!
    
    
    //MARK: Class initializers
    
    // Designated initializer
    init(forBook model: CDABook) {
        
        self.model = model
        super.init(nibName: "CDABookViewController", bundle: nil)
    }
    
    // Required initializer to use UIKit in Swift
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Auxiliary methods
    
    // Updates the view with the model data
    // (optionally, the cover image will be updated too)
    func syncModelWithView(includingCover syncCover: Bool) {
        
        title = model.title
        
        authorName.text = model.authorsToString()
        tagList.text = model.tagsToString()
        
        if syncCover {

            syncCoverImage()
        }
        
        if model.isFavorite {
            favoriteStatus.text = "Yes"
        }
        else {
            favoriteStatus.text = "No"
        }
    }
    
    // Updates the cover image on screen
    func syncCoverImage() {
        
        print("\nLoading cover image from: \(model.coverUrl)...")
        
        guard let coverImage = model.getCoverImage() else {
            return
        }
        
        bookImage.image = coverImage
        
        
        // If the url used is a remote url, save the image in the sandbox and update the model with a local url
        if !model.isLocalCoverUrl() {
            
            print("\nSaving remote image for future use...")
            
            let dirNameImages = "Images"
            let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let fileName = model.getFileName(fromUrl: model.coverUrl)
            
            let relativePath = "/" + fileName
            let fullPath = documentsDir + "/" + dirNameImages + relativePath
            
            guard let imageData = UIImageJPEGRepresentation(coverImage, 1.0) else {
                return
            }
            
            try? imageData.write(to: URL(fileURLWithPath: fullPath), options: [.atomic])
            
            model.coverUrl = URL(fileURLWithPath: fullPath)
            
            // Send a notification to the TableViewController (to persist the changes)
            let nc = NotificationCenter.default
            
            let notifName = CoverUrlUpdatedNotification
            let notifObject = self
            let notifUserInfo = [CoverUrlUpdatedKey: model]
            let notif = Notification(name: Notification.Name(rawValue: notifName), object: notifObject, userInfo: notifUserInfo)
            
            nc.post(notif)
        }
        
    }
    
    
    //MARK: Events from UI elements
    
    // Add/remove book from favorites
    @IBAction func toggleFavorite(_ sender: AnyObject) {
        
        print("\nChanging favorite status of the current book...")
        
        model.isFavorite = !model.isFavorite
        syncModelWithView(includingCover: false)
        
        // Send a notification to the LibraryTableViewController to show the changes in the book list
        let nc = NotificationCenter.default
        
        let notifName = FavoriteDidChangeNotification
        let notifObject = self
        let notifUserInfo = [FavoriteDidChangeKey: model]
        let notif = Notification(name: Notification.Name(rawValue: notifName), object: notifObject, userInfo: notifUserInfo)
        
        nc.post(notif)
    }
    
    // Show the PDF
    @IBAction func showPdf(_ sender: AnyObject) {
        
        // Create a new SimplePDFViewController with the model, then push it to the NavigatorController
        let pdfVC = CDASimplePDFViewController(forBook: model)
        navigationController?.pushViewController(pdfVC, animated: true)
    }
    
    
    //MARK: View life cycle events
    
    // Tasks to do after the controller is created (invoked once)
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    // Tasks to do just before the view is shown (could be invoked more than once)
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        syncModelWithView(includingCover: false)
    }
    
    // Tasks to do right after the view is shown (could be invoked more than once)
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        syncCoverImage()
    }

}



//MARK: Extensions

// Implementation of the CDALibraryTableViewControllerDelegate protocol
// (to update the book detail when another book is selected in the list)
extension CDABookViewController: CDALibraryTableViewControllerDelegate {
    
    func delegateAction(_ vc: CDALibraryTableViewController, didSelectBook book: CDABook) {
        
        print("\nDelegate BookViewController updating the detail of the selected book...")
        
        model = book
        
        syncModelWithView(includingCover: false)
        syncCoverImage()
    }
}

