//
//  CDASimplePDFViewController.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 07/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import UIKit


let PdfUrlUpdatedNotification = "A book has updated its pdf url to a relative local path"
let PdfUrlUpdatedKey = "PdfUrlUpdated"


class CDASimplePDFViewController: UIViewController {
    
    var model: CDABook
    
    
    // Reference to UI elements
    @IBOutlet weak var pdfWebView: UIWebView!
    
    
    //MARK: Class initializers
    
    // Designated initializer
    init(forBook model: CDABook) {
        
        self.model = model
        super.init(nibName: "CDASimplePDFViewController", bundle: nil)
    }
    
    // Required initializer to use UIKit in Swift
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Auxiliary methods
    
    // Updates the view with the model data
    func syncModelWithView() {
        
        print("\nLoading PDF from: \(model.pdfUrl)...")
        
        guard let pdf = model.getPdfData() else {
            return
        }
        
        pdfWebView.load(pdf as Data, mimeType: "application/pdf", textEncodingName: "utf-8", baseURL: URL(fileURLWithPath: ""))
        
        // If the url of the document is a remote url, store the document in the sandbox and update the model with the local url
        if !model.isLocalPdfUrl() {
            
            print("\nSaving PDF document for future use...")
            
            let dirNamePdfs = "Pdf"
            let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let fileName = model.getFileName(fromUrl: model.pdfUrl)
            
            let relativePath = "/" + fileName
            let fullPath = documentsDir + "/" + dirNamePdfs + relativePath
            
            try? pdf.write(to: URL(fileURLWithPath: fullPath), options: [.atomic])
            
            model.pdfUrl = URL(fileURLWithPath: fullPath)
            
            // Send a notification to the TableViewController (to persist the changes)
            let nc = NotificationCenter.default
            
            let notifName = PdfUrlUpdatedNotification
            let notifObject = self
            let notifUserInfo = [PdfUrlUpdatedKey: model]
            let notif = Notification(name: Notification.Name(rawValue: notifName), object: notifObject, userInfo: notifUserInfo)
            
            nc.post(notif)
        }
    }
    
    // This function will be called when a notification of new book selected in the list is received
    func bookDidChange(_ notification: Notification) {
        
        print("\nPdfViewController received a notification of new book selected")
        
        // Get the selected book from the notification data
        // and, if it is different than the current one, update the model and the view
        
        let info = (notification as NSNotification).userInfo!
        let newBook = info[BookDidChangeKey] as? CDABook
        
        if newBook != model {
            
            self.model = newBook!
            syncModelWithView()
        }
        else {
            print("\n** Selected book is current book, no action required **")
        }
    }
    
    
    //MARK: View life cycle events
    
    // Tasks to do after the controller is created (invoked once)
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        // Suscribe to receive notifications
        // (needed when the user selects a new book from the list)
        let nc = NotificationCenter.default
        
        nc.addObserver(self,
                       selector: #selector(bookDidChange),
                       name: NSNotification.Name(rawValue: BookDidChangeNotification),
                       object: nil)                                 // objetct: nil --> suscribe to all notifications
    }
    
    // Tasks to do just before the view is shown (could be invoked more than once)
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        syncModelWithView()
    }

}
