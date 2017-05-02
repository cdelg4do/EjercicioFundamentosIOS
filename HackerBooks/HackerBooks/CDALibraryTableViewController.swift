//
//  CDALibraryTableViewController.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 09/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import UIKit


let BookDidChangeNotification = "Selected book has changed"
let BookDidChangeKey = "SelectedBook"


class CDALibraryTableViewController: UITableViewController {

    let model: CDALibrary
    var delegate: CDALibraryTableViewControllerDelegate?  // It is optional, since it can be undefined

    
    //MARK: Class initializers
    
    // Designated initializer
    init(model: CDALibrary, showTitleNewData: Bool) {
        
        self.model = model
        
        super.init(nibName: nil, bundle: nil)   // There is no .xib file associated to this controller, the method loadView()
                                                // will be invoked to generate an automatic view hierarchy (an UITableView in this case)
        
        // Title to show
        let titleString = "HackerBooks 1.0 (\(model.totalBookCount) books)"
        
        if showTitleNewData {
            title = titleString + " - New"
        }
        else {
            title = titleString
        }
    }
    
    // Required initializer to use UIKit in Swift
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Action to do when a table row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("\nA row has been selected from the book list: (\((indexPath as NSIndexPath).section), \((indexPath as NSIndexPath).row))")
        
        let selectedBook = getBook(forIndexPath: indexPath)
        
        // Call the delegate (if any) to update the book detail with the selected book
        delegate?.delegateAction(self, didSelectBook: selectedBook)
        
        // Send a notification of selected row
        // (so that the PDF View Controller changes to the PDF of the selected book)
        let nc = NotificationCenter.default
        
        let notifName = BookDidChangeNotification
        let notifObject = self
        let notifUserInfo = [BookDidChangeKey: selectedBook]
        let notif = Notification(name: Notification.Name(rawValue: notifName), object: notifObject, userInfo: notifUserInfo)
        
        nc.post(notif)
    }
    

    //MARK: methods to access data in the table view
    
    // Number of sections in the table
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return model.sectionCount
    }
    
    // Number of rows in a given section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return model.bookCount(forSectionPos: section)
    }
    
    // Building a table row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Id. for the cell type (in this case, all cells will be the same type)
        let cellId = "CDAHackerBooks"
        
        // Get the book that corresponds to that cell
        let book = getBook(forIndexPath: indexPath)
        
        
        // Try to recycle a cell of the proper type.
        // If not possible, create a new one with the .subtitle style.
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        }
        
        // Load the book data into the cell:
        // ( first line: book title, second line: author(s) )
        cell?.textLabel?.text = book.title
        cell?.detailTextLabel?.text = book.authorsToString()
        
        
        return cell!
    }
    
    
    // Title for a given section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sectionName = model.getTag(atSectionPos: section)?.name.capitalized {
            
            let sectionCount = model.bookCount(forSectionPos: section)
            return sectionName + " (\(sectionCount))"
        }
        
        return nil
    }
    
    
    
    //MARK: View life cycle events
    
    // Tasks to do after the controller is created (invoked once)
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Suscribe the controller to notifications
        let nc = NotificationCenter.default
        
        // When a book changes its favorite status
        nc.addObserver(self,
                       selector: #selector(favoriteDidChange),
                       name: NSNotification.Name(rawValue: FavoriteDidChangeNotification),
                       object: nil)
        
        // When a book updates its cover url
        nc.addObserver(self,
                       selector: #selector(coverUrlUpdated),
                       name: NSNotification.Name(rawValue: CoverUrlUpdatedNotification),
                       object: nil)
        
        // When a book updates its pdf url
        nc.addObserver(self,
                       selector: #selector(pdfUrlUpdated),
                       name: NSNotification.Name(rawValue: PdfUrlUpdatedNotification),
                       object: nil)
    }
    
    
    //MARK: Auxiliary functions
    
    // Get a specific book in the library from a given NSIndexPath
    func getBook(forIndexPath indexPath: IndexPath) -> CDABook {
        
        let sectionNum = (indexPath as NSIndexPath).section
        let rowNum = (indexPath as NSIndexPath).row
        
        let book = model.getBook(atPosition: rowNum, inSection: sectionNum)
        
        return book!
    }
    
    // What to do when a notification of favorite changed is received
    func favoriteDidChange(_ notification: Notification) {
        
        print("\nTableViewController received a notification of favorite changed")
        
        let info = (notification as NSNotification).userInfo!
        let book = info[FavoriteDidChangeKey] as? CDABook
        
        model.toggleFavorite(book!)
        
        do {
            try model.saveToFile()
        }
        catch {
            print("\n** ERROR: failed to save the JSON file in the sandbox **")
        }
        
        // Refresh the table to show the changes
        self.tableView.reloadData()
    }
    
    // What to do when a notification of cover url updated is received
    func coverUrlUpdated(_ notification: Notification) {
        
        print("\nTableViewController received a notification of cover url updated")
        
        do {
            try model.saveToFile()
        }
        catch {
            print("\n** ERROR: failed to save the JSON file in the sandbox **")
        }
    }
    
    // What to do when a notification of pdf url updated is received
    func pdfUrlUpdated(_ notification: Notification) {
        
        print("\nTableViewController received a notification of pdf url updated")
        
        do {
            try model.saveToFile()
        }
        catch {
            print("\n** ERROR: failed to save the JSON file in the sandbox **")
        }
    }
    

}


//MARK: delegate protocol for this controller

// Definition of the protocol
protocol CDALibraryTableViewControllerDelegate {
    
    func delegateAction(_ vc: CDALibraryTableViewController, didSelectBook book: CDABook)
}


//MARK: Extensions

// We make the CDATableViewController implement its own delegate protocol
// (so that it can act as its own delegate when we are not using iPad hardware and the SplitViewController is not available)
extension CDALibraryTableViewController: CDALibraryTableViewControllerDelegate {
    
    func delegateAction(_ vc: CDALibraryTableViewController, didSelectBook book: CDABook) {
        
        // Create a new Book view controller to show the data of the selected book, and navigate to it
        let bookVC = CDABookViewController(forBook: book)
        self.navigationController?.pushViewController(bookVC, animated: true)
    }
}

