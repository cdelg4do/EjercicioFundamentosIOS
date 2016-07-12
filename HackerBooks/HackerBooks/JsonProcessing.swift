//
//  JsonProcessing.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 10/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import Foundation
import UIKit


// Tipos auxiliares para el tratamiento de JSON

typealias JsonObject        = AnyObject
typealias JsonDictionary    = [String : JsonObject]
typealias JsonList          = [JsonDictionary]



// Función que trata de descargar un fichero remoto y parsear su contenido,
// devolviendo el objeto JsonList correspondiente (si no lo consigue, devuelve nil)

func synchronousDownloadRemoteJson(from urlString: String) -> JsonList? {
    
    // Intentar descargar el contenido del fichero remoto en un objeto NSData
    print("\nDescargando JSON remoto desde \(urlString)...")
    
    let fileData: NSData?
    
    guard let url = NSURL(string: urlString) else { return nil }
    
    do {     
        fileData = try NSData(contentsOfURL: url, options: NSDataReadingOptions())
    }
    catch { return nil }
    
    if fileData == nil { return nil }
    
    
    // Intentar parsear los datos recibidos como JsonList
    print("\nParseando datos descargados...")
    
    guard let maybeList = try? NSJSONSerialization.JSONObjectWithData(fileData!, options: NSJSONReadingOptions.MutableContainers) as? JsonList,
        let jsonList = maybeList else {
            
        return nil
    }
    
    return jsonList
}


// Función que trata de parsear el contenido del fichero JSON local, devolviendo el objeto JsonList correspondiente
// (si no lo consigue, intentará descargar el JSON remoto y si también fallase entonces devuelve nil)

func synchronousParseLocalJson(ifErrorThenTryFrom remoteUrlString: String) -> JsonList? {
    
    // Ruta al fichero JSON local
    let fileName = "books.json"
    let documentsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let filePath = documentsDir + "/" + fileName
    
    
    // Intentar cargar el contenido del fichero local en un objeto NSData
    print("\nCargando información del JSON local desde \(filePath)...")
    
    let fileData: NSData?
    let url = NSURL.fileURLWithPath(filePath)
    
    do {
        fileData = try NSData(contentsOfURL: url, options: NSDataReadingOptions())
    }
    catch { fileData = nil }
    
    
    // Si se pudieron obtener los datos localmente, intentar parsearlos a un JsonList
    if fileData != nil {
        
        print("\nParseando datos del fichero local...")
        
        guard let maybeList = try? NSJSONSerialization.JSONObjectWithData(fileData!, options: NSJSONReadingOptions.MutableContainers) as? JsonList,
            let jsonList = maybeList else {
                
                return nil
        }
        
        return jsonList
    }
    
    // Si no pudo obtenerse información del JSON local,
    // entonces se intenta obtener la información del JSON remoto
    else {
        
        print("\n** ERROR: no fue posible cargar los datos del JSON local **")
        return synchronousDownloadRemoteJson(from: remoteUrlString)
    }
    
}



// Función que trata de construir una lista de CDABook a partir de una lista de objetos JsonDictionary

func decodeBookList(fromList jsonList: JsonList) -> [CDABook] {
    
    var bookList = [CDABook]()
    print("\nConstruyendo lista de libros a partir de los datos obtenidos...")
    
    for jsonElement in jsonList {
        
        do {
            let newBook = try decodeBook(fromElement: jsonElement)
            bookList.append(newBook)
            print("\nLibro decodificado: \(newBook)")
        }
        catch {
            print("\n** Error al procesar elemento JSON: \(jsonElement) **")
        }
    }
    
    return bookList
}



// Función que trata de construir un objeto CDABook a partir de un objeto JsonDictionary

func decodeBook(fromElement json: JsonDictionary) throws -> CDABook {
    
    //print("\nDecodificando elemento: \(json)...")
    
    // Título del libro
    guard let bookTitle = json["title"] as? String else { throw JsonError.wrongJSONFormat }
    
    
    // Autores del libro
    guard let authorsString = json["authors"] as? String else { throw JsonError.wrongJSONFormat }
    
    let bookAuthors = authorsString.componentsSeparatedByString(", ")
    
    
    // Tags del libro
    var bookTags = [CDABookTag]()
    
    guard let tagsString = json["tags"] as? String else { throw JsonError.wrongJSONFormat }
    
    for tagString in tagsString.componentsSeparatedByString(", ") {
        
        bookTags.append( CDABookTag(name: tagString) )
    }
    
    
    // URL de la portada
    guard let imageUrlString = json["image_url"] as? String else {  throw JsonError.wrongJSONFormat }
    guard let bookCoverUrl = NSURL(string: imageUrlString) else { throw JsonError.wrongURLFormatForJSONResource }
    
    
    // URL del PDF
    guard let pdfUrlString = json["pdf_url"] as? String else {  throw JsonError.wrongJSONFormat }
    guard let bookPdfUrl = NSURL(string: pdfUrlString) else { throw JsonError.wrongURLFormatForJSONResource }
    
    
    // El indicador de favorito es opcional (no existe en el JSON descargado de internet, pero sí en el que se almacena localmente)
    var bookIsFavorite = false
    
    let favorite = json["favorite"] as? Bool
    
    if favorite != nil && favorite == true {
        
        bookIsFavorite = true
    }
    
    
    // Llegados a este punto, disponemos de toda la información necesaria para crear el correspondiente CDABook
    
    let newBook = CDABook(title:        bookTitle,
                          authors:      bookAuthors,
                          tags:         bookTags,
                          coverUrl:     bookCoverUrl,
                          pdfUrl:       bookPdfUrl,
                          isFavorite:   bookIsFavorite)
    
    return newBook
}


/*
// Función sobrecargada de la anterior, que acepta un opcional como parámetro

func decodeBook(fromElement json: JsonDictionary?) throws -> CDABook {
    
    if case .Some(let jsonDict) = json {
        
        return try decodeBook(fromElement: jsonDict)
    }
    else {
        
        throw JsonError.nilJSONObject
    }
}
*/



