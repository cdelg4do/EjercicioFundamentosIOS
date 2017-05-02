//
//  Errors.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 11/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

// This file contains the definition of errors that can be thrown during the execution
// (all derived from Error, so that they can be returned with throw)

import Foundation


//MARK: errors that can be thrown while processing a JSON file

enum JsonError: Error {
    
    case wrongURLFormatForJSONResource
    case resourcePointedByURLNotReachable
    case jsonParsingError
    case wrongJSONFormat
    case nilJSONObject
    case unableToWriteJSONFile
}


//MARK: errors that can be thrown while accessing the file system

enum FilesystemError: Error {
    
    case unableToCreateCacheFolders
}
