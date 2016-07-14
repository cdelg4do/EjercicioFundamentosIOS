//
//  CDABook.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 03/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import Foundation
import UIKit


class CDABook: Comparable {
    
    // Propiedades de la clase
    
    let title:      String
    let authors:    [String]
    let tags:       [CDABookTag]
    
    var coverUrl:   NSURL
    var pdfUrl:     NSURL
    var isFavorite: Bool
    
    
    
    // Inicializadores designado y de conveniencia de la clase
    
    init(title: String, authors: [String], tags: [CDABookTag], coverUrl: NSURL, pdfUrl: NSURL, isFavorite: Bool) {
        
        self.title = title
        self.authors = authors
        self.tags = tags
        self.coverUrl = coverUrl
        self.pdfUrl = pdfUrl
        self.isFavorite = isFavorite
    }
    
    convenience init(title: String, authors: [String], tags: [CDABookTag], coverUrl: NSURL, pdfUrl: NSURL) {
        
        self.init(title: title,
                  authors: authors,
                  tags: tags,
                  coverUrl: coverUrl,
                  pdfUrl: pdfUrl,
                  isFavorite: false)
    }
    
    
    // Función que obtiene una representación textual de los autores: "autor1, autor2, autor3, ..."
    
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
    
    
    // Función que obtiene una representación textual de los tags: "tag1, tag2, tag3, ..."
    
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
    
    
    // Función que obtiene un objeto UIImage a partir de la url de la portada del libro
    
    func getCoverImage() -> UIImage? {
        
        do {
            
            let imageData = try NSData(contentsOfURL: coverUrl, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            return UIImage(data: imageData)
        }
        catch {
            
            print("** ERROR ** : fallo al cargar imagen del libro")
            return nil
        }
    }
    
    
    
    // Función que obtiene un objeto NSData a partir de la url del pdf del libro
    
    func getPdfData() -> NSData? {
        
        do {
            
            let pdfData = try NSData(contentsOfURL: pdfUrl, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            return pdfData
        }
        catch {
            
            print("** ERROR ** : fallo al cargar pdf del libro")
            return nil
        }
    }
    
    
    
    // Función que convierte el objeto en una cadena JSON
    
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
    
    
    // Función que indica si la URL de la portada es local
    
    func isLocalCoverUrl() -> Bool {
        
        let urlString = self.coverUrl.absoluteString
        let firstChar = urlString[urlString.startIndex]
        
        if firstChar == "/" {
            return true
        }
        else {
            return false
        }
    }
    
    
    // Función que indica si la URL del PDF es local
    
    func isLocalPdfUrl() -> Bool {
        
        let urlString = self.pdfUrl.absoluteString
        let firstChar = urlString[urlString.startIndex]
        
        if firstChar == "/" {
            return true
        }
        else {
            return false
        }
    }
    
    
    // Función que indica el nombre de un fichero, a partir de una url al mismo
    
    func getFileName(fromUrl url: NSURL) -> String {
        
        return url.absoluteString.componentsSeparatedByString("/").last!
    }
    
    
    
    // Proxys para comparación y ordenación de libros (por título)
    
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



// Sobrecarga de operadores para el protocolo Comparable

func == (left: CDABook, right: CDABook) -> Bool {
    
    guard (left !== right) else {
        return true
    }
    
    return left.proxyForComparison == right.proxyForComparison
}


func < (left: CDABook, right: CDABook) -> Bool {
    
    return left.proxyForComparison < right.proxyForComparison
}


// Extensión para implementar el protocolo Hashable,
// necesario para poder construir sets de CDABook

extension CDABook: Hashable {
    
    var hashValue: Int {
        
        get {
            return proxyForComparison.hashValue
        }
    }
}


// Debug: extensión para transformar el objeto en una cadena de la forma: "'título' by autores. (tags)"
// (protocolo CustomStringConvertible, heredado de NSObject)

extension CDABook: CustomStringConvertible {
    
    var description: String {
        
        get {
            return "'\(self.title)' by \(authorsToString()). (\(tagsToString()))"
        }
    }
}

