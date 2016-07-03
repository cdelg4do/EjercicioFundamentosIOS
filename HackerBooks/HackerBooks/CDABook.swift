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
    
    var portrait:   UIImage
    var pdfUrl:     NSURL
    var isFavorite: Bool
    
    
    
    // Inicializador designado de la clase
    
    init(title: String, authors: [String], tags: [CDABookTag], portrait: UIImage, pdfUrl: NSURL) {
        
        self.title = title
        self.authors = authors
        self.tags = tags
        self.portrait = portrait
        self.pdfUrl = pdfUrl
        
        self.isFavorite = false
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



// Extensión para poder transformar el objeto en una cadena "'título' by autores. (tags)"
// (protocolo CustomStringConvertible, heredado de NSObject)

extension CDABook: CustomStringConvertible {
    
    var description: String {
        
        get {
            var bookAuths = ""
            var i = 0
            
            for a in authors {
            
                bookAuths += a
                i += 1
                if (i<authors.count) {  bookAuths += ", "   }
            }
            
            var bookTags = ""
            var j = 0
            
            for t in tags {
                
                bookTags += "\(t)"
                j += 1
                if (j<tags.count) { bookTags += ", "    }
            }
            
            return "'\(self.title)' by \(bookAuths). (\(bookTags))"
        }
    }
}

