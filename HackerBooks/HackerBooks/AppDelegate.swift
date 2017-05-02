//
//  AppDelegate.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 03/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    // URL of the remote JSON that contains the info about the books
    let remoteJsonUrlString = "https://t.co/K9ziV0z3SJ"
    
    // Key for the flag that indicates if the JSON was already downloaded in previous executions
    let jsonAlreadyDownloadedKey = "JSON Already Downloaded on this device"
    
    // Flag that indicates if the table title should show that the data shown have just been downloaded
    // (if false, means that the data are already cached)
    var showTitleNewData = false
    
    // Computed variable that indicates if the device hardware is a tablet or not
    var HARDWARE_IS_IPAD: Bool {
        get {
            if UIDevice.current.userInterfaceIdiom == .pad { return true }
            else { return false }
        }
    }
    
    // Computed variable that indicates if the JSON file was already downloaded in previous executions
    var JSON_ALREADY_DOWNLOADED: Bool {
        
        get {
            return UserDefaults.standard.bool(forKey: jsonAlreadyDownloadedKey)
        }
    }
    
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Book list to build the library
        let myBookList: [CDABook]
        let myLibrary: CDALibrary
        
        
        // If the remote JSON was already downloaded in previous executions, load the book list from the local cache
        if JSON_ALREADY_DOWNLOADED {
            
            // Read the local JSON and, if it fails (i.e. corrput file), try to download the remote JSON again
            guard let jsonList = synchronousParseLocalJson(ifErrorThenTryFrom: remoteJsonUrlString) else {
                
                fatalError("\n** ERROR: unable to get data from the local JSON nor the remote JSON **")
            }
            
            print("\nLocal JSON successfully processed")
            
            // Build the book list from the parsed data, then build the model from it
            myBookList = decodeBookList(fromList: jsonList)
            myLibrary = CDALibrary(books: myBookList)
            
            // By default, the title will not indicate anything when the data is local
            showTitleNewData = false
        }
        
        // If the remote JSON was never downloaded, do it now. Then, bould the book list and the model from it
        else {
            
            guard let jsonList = synchronousDownloadRemoteJson(from: remoteJsonUrlString) else {
                
                fatalError("\n** ERROR: failed to download remote JSON, or it is not a valid JSON document **")
            }
            
            print("\nRemote JSON successfully processed")
            
            // Build the book list from the parsed data, then build the model from it
            myBookList = decodeBookList(fromList: jsonList)
            myLibrary = CDALibrary(books: myBookList)
            
            
            // Serialize the model in the sandbox and set the flag to use the local data in future executions
            do {
                try myLibrary.saveToFile()
                UserDefaults.standard.set(true, forKey: jsonAlreadyDownloadedKey)
            }
            catch {
                print("\n** ERROR: unable to serialize data to the sandbox **")
            }
            
            // Also in the sandbox, create the cache folders to store the cover images and the pdf documents
            do {
                try createCacheFolders()
            }
            catch {
                fatalError("\n** ERROR: unable to create the local cache folders **")
            }
            
            
            // The title will show that the data have been just downloaded
            showTitleNewData = true
        }
        
        
        // Debug: show info about the model
        //myLibrary.printLibraryContents()
        //print("\n\(myLibrary.toJsonString())")
        
        
        // Window to use in the app
        window = UIWindow(frame:UIScreen.main.bounds)
        
        // Get the appropriate ViewController that will be used as root (depending on the device hardware the app is running)
        var rootVC: UIViewController
        
        if HARDWARE_IS_IPAD {
            print("\nSetting rootViewController for iPad...")
            rootVC = rootViewControllerForPad(withLibrary: myLibrary)
        }
        else {
            print("\nSetting rootViewController for iPhone...")
            rootVC = rootViewControllerForPhone(withLibrary: myLibrary)
        }
        
        // Set the window view controller and show it
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        
        
        return true
    }
    
    
    //MARK: Auxiliary functions
    
    // Cache folder creation (for cover images and pdf documents)
    func createCacheFolders() throws {
        
        let dirNameImages = "Images"
        let dirNamePdf = "Pdf"
        let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let imagesPath = documentsDir + "/" + dirNameImages
        let pdfPath = documentsDir + "/" + dirNamePdf
        
        print("\nCreating local cache folders:\n - \(imagesPath)\n - \(pdfPath)")
        
        do {
            try FileManager.default.createDirectory(atPath: imagesPath, withIntermediateDirectories: false, attributes: nil)
            try FileManager.default.createDirectory(atPath: pdfPath, withIntermediateDirectories: false, attributes: nil)
        }
        catch {
            throw FilesystemError.unableToCreateCacheFolders
        }
    }
    
    
    // Method to create the rootViewController for iPad hardware (a SplitViewController)
    func rootViewControllerForPad(withLibrary library: CDALibrary) -> UIViewController {
        
        // Controllers
        let libraryVC = CDALibraryTableViewController(model: library, showTitleNewData: showTitleNewData)
        let bookVC = CDABookViewController(forBook: library.getDefaultBook())
        
        // Combinators
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        let bookNav = UINavigationController(rootViewController: bookVC)
        
        // SplitViewController with both combinators
        let splitVC = UISplitViewController()
        splitVC.viewControllers = [libraryNav, bookNav]
        
        // Delegate assignation
        libraryVC.delegate = bookVC
        
        return splitVC
    }
    
    
    // Method to create the rootViewController for iPhone hardware (a NavigationController)
    func rootViewControllerForPhone(withLibrary library: CDALibrary) -> UIViewController {
        
        // Controller
        let libraryVC = CDALibraryTableViewController(model: library, showTitleNewData: showTitleNewData)
        
        // Combinator
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        
        // Delegate assignation
        libraryVC.delegate = libraryVC
        
        return libraryNav
    }


}

