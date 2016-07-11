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
    print("\nDescargando JSON remoto de \(urlString)...")
    
    let fileData: NSData?
    
    guard let url = NSURL(string: urlString) else {
        
        return nil
    }
    
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



// Función que trata de construir una lista de CDABook a partir de una lista de objetos JsonDictionary

func decodeBookList(fromList jsonList: JsonList) -> [CDABook] {
    
    var bookList = [CDABook]()
    print("\nConstruyendo lista de libros a partir de los datos parseados...")
    
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
// obtenida con el método synchronousDownloadRemoteJson()

func decodeBook(fromElement json: JsonDictionary) throws -> CDABook {
    
    print("\nDecodificando elemento: \(json)...")
    
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
    
    
    // Llegados a este punto, disponemos de toda la información necesaria para crear el correspondiente CDABook
    
    let newBook = CDABook(title:    bookTitle,
                          authors:  bookAuthors,
                          tags:     bookTags,
                          cover:    bookCoverUrl,
                          pdfUrl:   bookPdfUrl)
    
    return newBook
}



// Función sobrecargada de la anterior, que acepta un opcional como parámetro

func decodeBook(fromElement json: JsonDictionary?) throws -> CDABook {
    
    if case .Some(let jsonDict) = json {
        
        return try decodeBook(fromElement: jsonDict)
    }
    else {
        
        throw JsonError.nilJSONObject
    }
}




