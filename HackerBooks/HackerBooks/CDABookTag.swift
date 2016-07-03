//
//  CDABookTag.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 03/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import Foundation


class CDABookTag: Comparable {
    
    // Propiedades de la clase
    let name: String
    
    
    // Inicializador designado de la clase
    
    init(name: String) {
        
        self.name = name
    }
    
    
    
    // Función de clase que devuelve un objeto tag de Favoritos
    static func getFavTag() -> CDABookTag {
        
        return CDABookTag(name: "My Favorites")
    }
    
    
    // Proxys para comparación y ordenación de tags (alfabéticamente por su nombre)
    
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


// Sobrecarga de operadores para el protocolo Comparable

func == (left: CDABookTag, right: CDABookTag) -> Bool {
    
    guard (left !== right) else {
        return true
    }
    
    return left.proxyForComparison == right.proxyForComparison
}


func < (left: CDABookTag, right: CDABookTag) -> Bool {
    
    return left.proxyForComparison < right.proxyForComparison
}


// Extensión para implementar el protocolo Hashable,
// necesario para poder construir arrays de (CDABookTag : [CDABook])

extension CDABookTag: Hashable {
    
    var hashValue: Int {
        
        get {
            return name.hashValue
        }
    }
}


// Extensión para poder transformar el objeto en una cadena
// (protocolo CustomStringConvertible, heredado de NSObject)

extension CDABookTag: CustomStringConvertible {
    
    var description: String {
        
        get {
            return name
        }
    }
}