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
    
    // Alias para tipos compuestos
    
    typealias TagList = [CDABookTag]
    typealias CategoryIndex = [CDABookTag : Int]
    typealias BookList = [CDABook]
    typealias BookCatalog = [BookList]
    
    
    // Propiedades de la biblioteca
    
    var sections: CategoryIndex = CategoryIndex()
    var library: BookCatalog = BookCatalog()
    
    var totalBookCount = 0
    
    
    // Inicializador designado de la clase
    
    init(books: BookList) {
        
        // Crear un conjunto con los tags existentes (para eliminar posibles duplicados)
        var tagSet = Set<String>()
        for b in books {
            for tag in b.tags {
                tagSet.insert(normalizeTagName(tag.name))
            }
        }
        
        // Volcar el contenido del set en un array de tags, para su posterior ordenación
        var tagList = TagList()
        for tagName in tagSet {
            let newTag = CDABookTag(name: tagName)
            tagList.append(newTag)
        }
        
        
        // Construir el indice de secciones a partir de los tags obtenidos
        sections = createCategoryIndex(withTags: tagList)
        
        
        // Por último, incorporar los libros al catálogo
        library = populateLibrary(withBooks: books)
        
        totalBookCount = books.count
    }
    
    
    
    // FUNCIONES DE CONFIGURACIÓN INICIAL DE LA BIBLIOTECA
    
    
    // Función que crea el índice ordenado de categorías, a partir de una lista de tags
    
    func createCategoryIndex(withTags tags: TagList) -> CategoryIndex {
        
        var index = CategoryIndex()
        
        // La categoría de favoritos, siempre en primer lugar
        index[CDABookTag.getFavTag()] = 0
        
        // El resto de categorías a continuación, por orden alfabético
        var i = 1
        for tag in tags.sort() {
            
            index[tag] = i
            i += 1
        }
        
        return index
    }
    
    
    // Función que rellena un catalogo con una lista de libros
    
    func populateLibrary(withBooks books: BookList) -> BookCatalog {
        
        var lib = BookCatalog()
        
        
        // Creamos un bookCatalog con el número de secciones necesarias (todas vacías)
        var sectionNum: Int = 0
        while sectionNum < sectionCount {
            
            lib.append(BookList())
            sectionNum += 1
        }
        
        
        // Añadimos cada libro por orden alfabético a las secciones correspondientes a sus tags.
        // Si además está marcado como favorito, lo añadimos a la sección de favoritos.
        
        for book in books.sort() {
            
            for tag in book.tags {
                
                sectionNum = sectionPos(forTag: tag)
                
                if sectionNum < 0 {
                    print("\n** Error ** : Section position for tag '\(tag)' could not be retreived!\n")
                }
                else {
                    lib[sectionNum].append(book)
                }
            }
            
            if book.isFavorite {
                sectionNum = sectionPos(forTag: CDABookTag.getFavTag())
                lib[sectionNum].append(book)
            }
        }
        
        return lib
    }
    
    
    // Función que añade/elimina un libro de la lista de favoritos
    func toggleFavorite(book: CDABook) {
        
        let favSection = sectionPos(forTag: CDABookTag.getFavTag())
        
        // Si hay que añadir el libro a favoritos (se añade y se reordena el listado)
        if book.isFavorite {
            
            library[favSection].append(book)
            library[favSection] = library[favSection].sort()
            print("\nAñadido a favoritos: \(book)")
        }
            
        // Si hay que eliminar el libro de favoritos
        else {
            
            var i = 0
            var keepSearching = true
            
            while keepSearching && i<library[favSection].count {
                
                if library[favSection][i] == book {
                    
                    keepSearching = false
                    library[favSection].removeAtIndex(i)
                    print("\nEliminado de favoritos: \(book)")
                }
                
                i += 1
            }
        }
        
    }
    
    
    // Función que normaliza una cadena de texto para el nombre de un tag
    // (convirtitiéndola a todo minúsculas)
    
    func normalizeTagName(name: String) -> String {
        
        return name.lowercaseString
    }
    
    
    // Función que determina cuál será el libro a mostrar por defecto al iniciar la app
    func getDefaultBook() -> CDABook {
        
        let defaultBook: CDABook
        
        // Si hay algún favorito, se escoge el primer favorito
        if self.bookCount(forTag: CDABookTag.getFavTag()) > 0 {
            
            defaultBook = self.getBook(atPosition: 0, forTag: CDABookTag.getFavTag())!
        }
            
            // Si no hay favoritos, se escoge el primer libro de la siguiente sección
        else {
            
            defaultBook = self.getBook(atPosition: 0, inSection: 1)!
        }
        
        return defaultBook
    }
    
    
    
    // FUNCIONES AUXILIARES PARA ACCEDER AL CONTENIDO DE LA BIBLIOTECA
    
    
    // Función que obtiene la posición de una seccion correspondiente al tag indicado
    // Si el tag indicado no existe en el índice de secciones, devuelve -1
    
    func sectionPos(forTag tag: CDABookTag) -> Int {
        
        guard let pos = sections[tag] else {
            return -1
        }
        
        return pos
    }
    
    
    // Función que obtiene la tag correspondiente a un número de sección
    
    func getTag(atSectionPos position: Int) -> CDABookTag? {
        
        for (tag, pos) in sections {
            
            if pos == position {
                return tag
            }
        }
        
        return nil
    }
    
    
    // Variable que indica el número de secciones existentes
    // (incluyendo la de libros favoritos)
    
    var sectionCount: Int {
        
        get {
            return sections.count
        }
    }
    
    
    // Función que obtiene el número de libros existentes en una sección determinada
    
    func bookCount(forSectionPos pos: Int) -> Int {
        
        if pos < 0 || pos >= sections.count {
            return 0
        }
        
        return library[pos].count
    }
    
    
    // Función que obtiene el número de libros existentes para un tag determinado
    
    func bookCount(forTag tag: CDABookTag) -> Int {
        
        let pos = sectionPos(forTag: tag)
        
        if pos < 0 {
            return 0
        }
        else {
            return bookCount(forSectionPos: pos)
        }
    }
    
    
    // Función que obtiene el listado de libros de una sección determinada
    
    func books(forSectionPos pos: Int) -> BookList {
        
        if pos < 0 || pos >= sections.count {
            
            return BookList()
        }
        
        return library[pos]
    }
    
    
    // Función que obtiene el listado de libros para un tag determinado
    
    func books(forTag tag: CDABookTag) -> BookList {
        
        let pos = sectionPos(forTag: tag)
        
        if pos < 0 {
            return BookList()
        }
        
        return books(forSectionPos: pos)
    }
    
    
    // Función que obtiene un libro en una posición y en una sección determinadas
    
    func getBook(atPosition bookPos: Int, inSection sectionPos: Int) -> CDABook? {
        
        let bookList = books(forSectionPos: sectionPos)
        
        if bookList.count == 0 || bookPos >= bookList.count {
            return nil
        }
        
        return bookList[bookPos]
    }
    
    
    // Función que obtiene un libro en una posición y para un tag determinados
    
    func getBook(atPosition bookPos: Int, forTag tag: CDABookTag) -> CDABook? {
        
        let secPos = sectionPos(forTag: tag)
        
        if secPos < 0 {
            return nil
        }
        
        return getBook(atPosition: bookPos, inSection: secPos)
    }
    
    
    // Debug: función que imprime por consola el contenido de la librería
    
    func printLibraryContents() {
        
        if sectionCount == 0 {
            
            print("\n** Warning ** : No sections were created yet\n")
            return
        }
        
        var sectionNum = 0
        
        while sectionNum < sectionCount {
            
            guard let tag = getTag(atSectionPos: sectionNum) else {
                
                print("\n** Error ** : Could not retrieve tag at section #\(sectionNum)!\n")
                return
            }
            
            
            let sectionName = tag.name
            let booksInSection = bookCount(forSectionPos: sectionNum)
            
            print("\n\(sectionNum) - Section '\(sectionName)' (contains \(booksInSection) books):")
            print("------------------------------------------------------------------------------\n")
            
            
            let bookList = books(forSectionPos: sectionNum)
            
            
            var bookPos: Int = 0
            
            while bookPos < booksInSection {
                
                let book = getBook(atPosition: bookPos, inSection: sectionNum)
                
                if book == nil {
                    print("\n** Error ** : Could not retrieve book #\(bookPos) in section \(sectionNum)!\n")
                }
                else {
                    print("   \(book!)\n")
                }
                
                bookPos += 1
            }
            
            sectionNum += 1
        }
    }
    
    
}


