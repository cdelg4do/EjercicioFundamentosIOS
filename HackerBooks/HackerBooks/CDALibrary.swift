//
//  CDALibrary.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 03/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import Foundation
import UIKit


class CDALibrary {
    
    typealias tagNamesList = [String]
    typealias BookList = [CDABook]
    typealias BookCatalog = [CDABookTag : BookList]
    
    var library: BookCatalog = BookCatalog()
    
    
    
    init(books: BookList) {
        
        // Crear un conjunto con los tags existentes (para eliminar posibles duplicados)
        var tagSet = Set<String>()
        for b in books {
            for tag in b.tags {
                tagSet.insert(tag.name)
            }
        }
        
        // Volcar el contenido del set en un array, para su posterior ordenación
        var tagList = tagNamesList()
        for t in tagSet {
            tagList.append(t)
        }
        
        // Construir el catalogo de libros vacío, incluyendo al tag de Favoritos en primer lugar
        // y a continuación el resto de tags, ordenados alfabéticamente
        library = createEmptyLibrary(tagList.sort())
        
        
        // Por último, incorporar los libros al catálogo, en orden alfabético
        populateLibrary(books.sort())
    }
    
    
    // Función que construye un catálogo de libros vacío, solo con las tags
    
    func createEmptyLibrary(existingTags: tagNamesList) -> BookCatalog {
        
        var c = BookCatalog()
        
        // Siempre debe existir un tag para los favoritos del usuario, en primer lugar
        print("Creando tag de favoritos")
        let favTag = CDABookTag.getFavTag()
        c[favTag] = BookList()
        
        // Posteriormente se añaden todos los demás tags que se indican
        for tagName in existingTags {
            print("Creando tag '\(tagName)'")
            let newTag = CDABookTag(name: tagName)
            c[newTag] = BookList()
        }
        
        return c
    }
    
    
    // Función que rellena con una lista de libros una librería previamente creada
    
    func populateLibrary(books: BookList) {
        
        // Para cada libro de la lista, lo añadimos a la sección de cada uno de sus tags.
        // Si además está marcado como favorito, lo añadimos a la sección de favoritos.
        for book in books {
            
            for tag in book.tags {
                
                library[tag]?.append(book)
            }
            
            if book.isFavorite {
                library[CDABookTag.getFavTag()]?.append(book)
            }
        }
    }
    
    
    
    // Debug: función que imprime por consola el contenido de la librería
    
    func printLibraryContents() {
        
        for (tag, list) in library {
            
            print("\n - TAG \(tag) (\(list.count) libros):")
            print("   ----------------------------------------------------\n")
            
            for book in list {
                print("   \(book)\n")
            }
        }
    }
    
}


