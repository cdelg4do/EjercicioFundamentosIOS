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
    
    var cover:   NSURL
    var pdfUrl:     NSURL
    var isFavorite: Bool
    
    
    
    // Inicializador designado de la clase
    
    init(title: String, authors: [String], tags: [CDABookTag], cover: NSURL, pdfUrl: NSURL) {
        
        self.title = title
        self.authors = authors
        self.tags = tags
        self.cover = cover
        self.pdfUrl = pdfUrl
        
        self.isFavorite = false
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
            
            let imageData = try NSData(contentsOfURL: cover, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            return UIImage(data: imageData)
        }
        catch {
            
            print("** ERROR ** : fallo al cargar imagen del libro")
            return nil
        }
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


// Debug: extensión para transformar el objeto en una cadena de la forma: "'título' by autores. (tags)"
// (protocolo CustomStringConvertible, heredado de NSObject)

extension CDABook: CustomStringConvertible {
    
    var description: String {
        
        get {
            return "'\(self.title)' by \(authorsToString()). (\(tagsToString()))"
        }
    }
}

