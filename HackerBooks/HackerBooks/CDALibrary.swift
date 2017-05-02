//
//  CDALibrary.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 03/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

//
//  This class stores all the information about the library.
//


import Foundation
import UIKit


class CDALibrary {
    
    // Aliases for compound types
    typealias TagList = [CDABookTag]
    typealias CategoryIndex = [CDABookTag : Int]
    typealias BookList = [CDABook]
    typealias BookCatalog = [BookList]
    
    
    var library: BookCatalog = BookCatalog()            // Array of book lists (one list per category/tag)
    var sections: CategoryIndex = CategoryIndex()       // Dictionary that associates each tag with a position in the previous array
    var totalBookCount = 0                              // Total number of books in the library (to show it on screen)
    
    
    // Designated initializer
    init(books: BookList) {
        
        // Create a set with all existing tags, to remove duplicates.
        // Then, dump the set contents to a tag list, to sort them.
        
        var tagSet = Set<String>()
        for b in books {
            for tag in b.tags {
                tagSet.insert(normalizeTagName(tag.name))
            }
        }
        
        var tagList = TagList()
        for tagName in tagSet {
            let newTag = CDABookTag(name: tagName)
            tagList.append(newTag)
        }
        
        // Build the category index from the tag list
        sections = createCategoryIndex(withTags: tagList)
        
        // Last, add the books to the libray and save the book count
        library = populateLibrary(withBooks: books)
        totalBookCount = books.count
    }
    
    
    
    //MARK: Initial setup methods
    
    // Creates a new category index from a list of tags
    func createCategoryIndex(withTags tags: TagList) -> CategoryIndex {
        
        var index = CategoryIndex()
        
        // "My Favorites" is always first
        index[CDABookTag.getFavTag()] = 0
        
        // Next, all the other categories/tags (alphabetically)
        var i = 1
        for tag in tags.sorted() {
            
            index[tag] = i
            i += 1
        }
        
        return index
    }
    
    // Creates a new dictionary of book lists (one list per category), from a book list
    // (requires that the "sections" variable has been previously initialized with createCategoryIndex() )
    func populateLibrary(withBooks books: BookList) -> BookCatalog {
        
        var lib = BookCatalog()
        
        // Create a bookCatalog with the appropriate amount of sections (all empty)
        var sectionNum: Int = 0
        while sectionNum < sectionCount {
            
            lib.append(BookList())
            sectionNum += 1
        }
        
        
        // Add each book alphabetically to its corresponding sections (according to the book tags).
        // Also, if the book is marked as favorite add it to "My Favorites" section
        for book in books.sorted() {
            
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
    
    
    // Changes the favorite status of a book
    func toggleFavorite(_ book: CDABook) {
        
        let favSection = sectionPos(forTag: CDABookTag.getFavTag())
        
        // Adding the book to favorites -> add it and then re-sort the list
        if book.isFavorite {
            
            library[favSection].append(book)
            library[favSection] = library[favSection].sorted()
            print("\nAdded to favorites: \(book)")
        }
            
        // Removing the book from favorites
        else {
            
            var i = 0
            var keepSearching = true
            
            while keepSearching && i<library[favSection].count {
                
                if library[favSection][i] == book {
                    
                    keepSearching = false
                    library[favSection].remove(at: i)
                    print("\nRemoved from favorites: \(book)")
                }
                
                i += 1
            }
        }
    }
    
    
    // Converts to lowercase a String for a book tag
    func normalizeTagName(_ name: String) -> String {
        
        return name.lowercased()
    }
    
    
    // Gets the default book of the library (to be shown when the app starts, if needed)
    func getDefaultBook() -> CDABook {
        
        let defaultBook: CDABook
        
        // If there are books marked as favorite, choose the first one
        if self.bookCount(forTag: CDABookTag.getFavTag()) > 0 {
            
            defaultBook = self.getBook(atPosition: 0, forTag: CDABookTag.getFavTag())!
        }
            
        // If not, choose the first book from the next section
        else {
            
            defaultBook = self.getBook(atPosition: 0, inSection: 1)!
        }
        
        return defaultBook
    }
    
    
    //MARK: Methods to persist the library state
    
    // Returns a String with the JSON representation of all the library contents
    func toJsonString() -> String {
        
        var json = "[\n"
        
        // Dump all books in the library to a set (to remove duplicates)
        var bookSet = Set<CDABook>()
        
        for bookList in library {
            for book in bookList {
                
                bookSet.insert(book)
            }
        }
        
        // For each book in the set, add its JSON representation
        var i = 0
        
        for book in bookSet {
            
            json += book.toJsonString()
            
            i += 1
            if (i<bookSet.count) { json += ",\n" }
        }
        
        json += "\n]\n"
        
        return json
    }
    
    // Dumps all library contents to a JSON file in the sandbox
    func saveToFile() throws {
        
        let fileName = "books.json"
        let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = documentsDir + "/" + fileName
        
        print("\nSaving local JSON: \(filePath)...")
        
        do {
            try self.toJsonString().write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            throw JsonError.unableToWriteJSONFile
        }
    }
    
    
    //MARK: Auxiliary functions to access the library data
    
    // Gets the section position corresponding to a given tag
    // (or -1, if there is no section for that tag)
    func sectionPos(forTag tag: CDABookTag) -> Int {
        
        guard let pos = sections[tag] else {
            return -1
        }
        
        return pos
    }
    
    // Gets the tag corresponding to a given section number
    // (or nil, if there is no match)
    func getTag(atSectionPos position: Int) -> CDABookTag? {
        
        for (tag, pos) in sections {
            
            if pos == position {
                return tag
            }
        }
        
        return nil
    }
    
    // Computed variable that gets the amount of existing sections in the library (including "My Favorites")
    var sectionCount: Int {
        
        get {
            return sections.count
        }
    }
    
    // Gets the number of books in a given section
    func bookCount(forSectionPos pos: Int) -> Int {
        
        if pos < 0 || pos >= sections.count {
            return 0
        }
        
        return library[pos].count
    }
    
    // Gets the amount of books for a given tag
    func bookCount(forTag tag: CDABookTag) -> Int {
        
        let pos = sectionPos(forTag: tag)
        
        if pos < 0 {
            return 0
        }
        else {
            return bookCount(forSectionPos: pos)
        }
    }
    
    // Gets the list with the books in a given section
    func books(forSectionPos pos: Int) -> BookList {
        
        if pos < 0 || pos >= sections.count {
            
            return BookList()
        }
        
        return library[pos]
    }
    
    // Gets teh list with the books with a given tag
    func books(forTag tag: CDABookTag) -> BookList {
        
        let pos = sectionPos(forTag: tag)
        
        if pos < 0 {
            return BookList()
        }
        
        return books(forSectionPos: pos)
    }
    
    // Gets the book in a given position of a given section
    // (or nil, if that book does not exist)
    func getBook(atPosition bookPos: Int, inSection sectionPos: Int) -> CDABook? {
        
        let bookList = books(forSectionPos: sectionPos)
        
        if bookList.count == 0 || bookPos >= bookList.count {
            return nil
        }
        
        return bookList[bookPos]
    }
    
    // Gets the book in a given position of a given tag
    // (or nil, if that book does not exist)
    func getBook(atPosition bookPos: Int, forTag tag: CDABookTag) -> CDABook? {
        
        let secPos = sectionPos(forTag: tag)
        
        if secPos < 0 {
            return nil
        }
        
        return getBook(atPosition: bookPos, inSection: secPos)
    }
    
    
    // Prints the library contents (for debugging)
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


