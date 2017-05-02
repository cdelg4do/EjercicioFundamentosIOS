//
//  CDABookTag.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 03/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

//
//  Clase CDABookTag to represent a book tag
//


import Foundation


class CDABookTag: Comparable {
    
    let name: String
    
    
    // Designated initializer
    init(name: String) {
        
        self.name = name
    }
    
    // Returns the tag for Favorites
    static func getFavTag() -> CDABookTag {
        
        return CDABookTag(name: "My Favorites")
    }
    
    // Proxies for tag comparison and tag sorting, by tag name
    var proxyForComparison: String {
        
        get {
            return name
        }
    }
    
    var proxyForSorting: String {
        
        get {
            return proxyForComparison
        }
    }
}


// Operator overload for the Comparable protocol
func == (left: CDABookTag, right: CDABookTag) -> Bool {
    
    guard (left !== right) else {
        return true
    }
    
    return left.proxyForComparison == right.proxyForComparison
}

func < (left: CDABookTag, right: CDABookTag) -> Bool {
    
    return left.proxyForComparison < right.proxyForComparison
}


//MARK: Extensions

// Extension to implement the Hashable protocol
// (needed to build arrays of pairs (CDABookTag : Int)
extension CDABookTag: Hashable {
    
    var hashValue: Int {
        
        get {
            return name.hashValue
        }
    }
}


// Extension to implement the CustomStringConvertible protocol, inherited from NSObject
// (useful for debugging, to transform the object into a String in the form "'tag name')"
extension CDABookTag: CustomStringConvertible {
    
    var description: String {
        
        get {
            return name
        }
    }
}
