//
//  Errors.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 11/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import Foundation


// MARK: JSON Errors

// Definiciones de los diferentes errores al procesar un fichero JSON
// (derivados de ErrorType para poder devolverlos con un throw)

enum JsonError: ErrorType {
    
    case wrongURLFormatForJSONResource
    case resourcePointedByURLNotReachable
    case jsonParsingError
    case wrongJSONFormat
    case nilJSONObject
    case unableToWriteJSONFile
}


enum FilesystemError: ErrorType {
    
    case unableToCreateCacheFolders
}
