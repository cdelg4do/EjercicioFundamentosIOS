//
//  JsonProcessing.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 10/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import Foundation
import UIKit


// Aliases for compound types
typealias JsonObject        = AnyObject
typealias JsonDictionary    = [String : JsonObject]
typealias JsonList          = [JsonDictionary]


// This function attempts to download a remote file and parse its contents.
// If the operation is successful, returns a JsonList object with all the contents.
// If the operation fails, returns nil.
func synchronousDownloadRemoteJson(from urlString: String) -> JsonList? {
    
    print("\nDownloading remote JSON from \(urlString)...")
    
    let fileData: Data?
    
    guard let url = URL(string: urlString) else { return nil }
    
    do {     
        fileData = try Data(contentsOf: url, options: NSData.ReadingOptions())
    }
    catch { return nil }
    
    if fileData == nil { return nil }
    
    
    print("\nParsing downloaded data...")
    
    guard let maybeList = try? JSONSerialization.jsonObject(with: fileData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? JsonList,
        let jsonList = maybeList
    
        else {
            return nil
        }
    
    return jsonList
}


// Attempts to parse the contents of the JSON file stored in the local cache, returning the appropriate JsonList object.
// If ot fails, attempts to download the remote JSON and parse it. If that fails too, returns nil.
func synchronousParseLocalJson(ifErrorThenTryFrom remoteUrlString: String) -> JsonList? {
    
    let fileName = "books.json"
    let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let filePath = documentsDir + "/" + fileName
    
    print("\nLoading local JSON file from \(filePath)...")
    
    let fileData: Data?
    let url = URL(fileURLWithPath: filePath)
    
    do {
        fileData = try Data(contentsOf: url, options: NSData.ReadingOptions())
    }
    catch { fileData = nil }
    
    
    if fileData != nil {
        
        print("\nParsing local file data...")
        
        guard let maybeList = try? JSONSerialization.jsonObject(with: fileData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? JsonList,
            let jsonList = maybeList
            
            else {
                return nil
            }
        
        return jsonList
    }
    
    else {
        
        print("\n** ERROR: unable to load data from local JSON file, trying to download it again **")
        return synchronousDownloadRemoteJson(from: remoteUrlString)
    }
    
}


// Attempts to build a list of books from a JsonList object
func decodeBookList(fromList jsonList: JsonList) -> [CDABook] {
    
    var bookList = [CDABook]()
    print("\nBuilding book list from loaded data...")
    
    for jsonElement in jsonList {
        
        do {
            let newBook = try decodeBook(fromElement: jsonElement)
            bookList.append(newBook)
            print("\nDecoded book: \(newBook)")
        }
        catch {
            print("\n** Error while processing JSON element: \(jsonElement) **")
        }
    }
    
    return bookList
}


// Attempts to get a new book object from a JsonDictionary object
func decodeBook(fromElement json: JsonDictionary) throws -> CDABook {
    
    guard let bookTitle = json["title"] as? String else { throw JsonError.wrongJSONFormat }
    
    guard let authorsString = json["authors"] as? String else { throw JsonError.wrongJSONFormat }
    let bookAuthors = authorsString.components(separatedBy: ", ")
    
    var bookTags = [CDABookTag]()
    guard let tagsString = json["tags"] as? String else { throw JsonError.wrongJSONFormat }
    
    for tagString in tagsString.components(separatedBy: ", ") {
        
        bookTags.append( CDABookTag(name: tagString) )
    }
    
    guard let imageUrlString = json["image_url"] as? String else {  throw JsonError.wrongJSONFormat }
    guard let bookCoverUrl = URL(string: imageUrlString) else { throw JsonError.wrongURLFormatForJSONResource }
    
    guard let pdfUrlString = json["pdf_url"] as? String else {  throw JsonError.wrongJSONFormat }
    guard let bookPdfUrl = URL(string: pdfUrlString) else { throw JsonError.wrongURLFormatForJSONResource }
    
    
    // The "favorite" field is optional (it only exists in the locally stored JSON file)
    var bookIsFavorite = false
    let favorite = json["favorite"] as? Bool
    
    if favorite != nil && favorite == true {
        
        bookIsFavorite = true
    }
    
    
    // Now we have all the necessary data to create the book object
    let newBook = CDABook(title:        bookTitle,
                          authors:      bookAuthors,
                          tags:         bookTags,
                          coverUrl:     bookCoverUrl,
                          pdfUrl:       bookPdfUrl,
                          isFavorite:   bookIsFavorite)
    
    return newBook
}
