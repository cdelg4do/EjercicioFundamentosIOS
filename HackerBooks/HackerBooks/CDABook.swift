//
//  CDABook.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 03/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

//
//  Class CDABook with information about a book in the library
//


import Foundation
import UIKit


class CDABook: Comparable {
    
    let title:      String
    let authors:    [String]
    let tags:       [CDABookTag]
    
    var coverUrl:   URL
    var pdfUrl:     URL
    var isFavorite: Bool
    
    
    // Designated & convenience initializers
    init(title: String, authors: [String], tags: [CDABookTag], coverUrl: URL, pdfUrl: URL, isFavorite: Bool) {
        
        self.title = title
        self.authors = authors
        self.tags = tags
        self.coverUrl = coverUrl
        self.pdfUrl = pdfUrl
        self.isFavorite = isFavorite
    }
    
    convenience init(title: String, authors: [String], tags: [CDABookTag], coverUrl: URL, pdfUrl: URL) {
        
        self.init(title: title,
                  authors: authors,
                  tags: tags,
                  coverUrl: coverUrl,
                  pdfUrl: pdfUrl,
                  isFavorite: false)
    }
    
    
    // Gets a String with the book authors: "author1, author2, author3, ..."
    func authorsToString() -> String {
        
        var bookAuths = ""
        var i = 0
        
        for a in authors {
            
            bookAuths += a
            i += 1
            if (i<authors.count) {  bookAuths += ", "   }
        }
        
        return bookAuths
    }
    
    
    // Gets a String with the book tags: "tag1, tag2, tag3, ..."
    func tagsToString() -> String {
        
        var bookTags = ""
        var i = 0
        
        for t in tags {
            
            bookTags += "\(t)"
            i += 1
            if (i<tags.count) { bookTags += ", "    }
        }
        
        return bookTags
    }
    
    
    // Gets a UIImage from the book cover url (or nil in case the operation fails)
    func getCoverImage() -> UIImage? {
        
        do {
            
            let imageData = try Data(contentsOf: coverUrl, options: NSData.ReadingOptions.mappedIfSafe)
            return UIImage(data: imageData)
        }
        catch {
            
            print("** ERROR ** : failed to load the cover image")
            return nil
        }
    }
    
    
    // Gets a Data object from the book pdf url (or nil in case the operation fails)
    func getPdfData() -> Data? {
        
        do {
            
            let pdfData = try Data(contentsOf: pdfUrl, options: NSData.ReadingOptions.mappedIfSafe)
            return pdfData
        }
        catch {
            
            print("** ERROR ** : fallo al cargar pdf del libro")
            return nil
        }
    }
    
    
    // Gets a String with all relevant data of the book (useful for debugging)
    func toJsonString() -> String {
        
        var json = " {\n"
        
        json += "  \"title\": \"" + self.title + "\",\n"
        json += "  \"authors\": \"" + self.authorsToString() + "\",\n"
        json += "  \"tags\": \"" + self.tagsToString() + "\",\n"
        json += "  \"image_url\": \"" + self.coverUrl.absoluteString + "\",\n"
        json += "  \"pdf_url\": \"" + self.pdfUrl.absoluteString + "\",\n"
        json += "  \"favorite\": " + self.isFavorite.description + "\n"
        
        json += " }"
        
        return json
    }
    
    
    // Indicates if the stored cover url is a local url or not
    func isLocalCoverUrl() -> Bool {
        
        let urlString = self.coverUrl.absoluteString
        let firstChar = urlString[urlString.startIndex]
        
        if firstChar == "f" {
            return true
        }
        else {
            return false
        }
    }
    
    
    // Indicates if the stored PDF url is a local url or not
    func isLocalPdfUrl() -> Bool {
        
        let urlString = self.pdfUrl.absoluteString
        let firstChar = urlString[urlString.startIndex]
        
        if firstChar == "f" {
            return true
        }
        else {
            return false
        }
    }
    
    
    // Gets a the name of a file, from a url pointing to it
    func getFileName(fromUrl url: URL) -> String {
        
        return url.absoluteString.components(separatedBy: "/").last!
    }
    
    
    // Proxies to compare and sort books, by title (computed variables)
    var proxyForComparison: String {
        
        get {
            return title
        }
    }
    
    var proxyForSorting: String {
        
        get {
            return proxyForComparison
        }
    }
}


// Operator oveload for the Comparable protocol
func == (left: CDABook, right: CDABook) -> Bool {
    
    guard (left !== right) else {
        return true
    }
    
    return left.proxyForComparison == right.proxyForComparison
}

func < (left: CDABook, right: CDABook) -> Bool {
    
    return left.proxyForComparison < right.proxyForComparison
}


//MARK: Extensions

// Extension to implement the Hashable protocol
extension CDABook: Hashable {
    
    var hashValue: Int {
        
        get {
            return proxyForComparison.hashValue
        }
    }
}


// Extension to implement the CustomStringConvertible protocol, inherited from NSObject
// (useful for debugging, to transform the object into a String in the form "'title' by 'authors'. ('tags')"
extension CDABook: CustomStringConvertible {
    
    var description: String {
        
        get {
            return "'\(self.title)' by \(authorsToString()). (\(tagsToString()))"
        }
    }
}
