//
//  CDALibraryTableViewController.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 09/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import UIKit


let BookDidChangeNotification = "Selected book has changed"

let BookKey = "key"



class CDALibraryTableViewController: UITableViewController {

    //MARK: Propiedades de la clase
    
    let model: CDALibrary
    var delegate: CDALibraryTableViewControllerDelegate?  // Opcional porque puede no haber delegado en un momento dado
    
    

    //MARK: Inicializadores de la clase
    
    // Inicializador designado
    init(model: CDALibrary) {
        
        self.model = model
        super.init(nibName: nil, bundle: nil)   // En este caso no existe un XIB asociado, se llama al método loadView() para
                                                // generar una jerarquía de vistas automática (en este caso un UITableView)
    }
    
    // Inicializador requerido para el uso de UIKit en Swift
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Delegado
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let book = getBook(forIndexPath: indexPath)
        
        delegate?.cdaLibraryTableViewController(self, didSelectBook: book)
    }
    
    

    //MARK: Funciones para la carga de datos en la tabla
    
    // Número de secciones de la tabla (tantos como tags diferentes, y una sección más para los favoritos)
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return model.sectionCount
    }
    
    // Número de filas en una sección (el número de libros que contiene)
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return model.bookCount(forSectionPos: section)
    }
    
    
    // Construcción de cada celda de la tabla
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Obtener el libro correspondiente a la celda
        let book = getBook(forIndexPath: indexPath)
        
        // Id. para el tipo de celda (en este caso, todas las celdas serán del mismo tipo)
        let cellId = "CDAHackerBooks"
        
        
        // Intentamos reciclar una celda del tipo correspondiente
        // (si no es posible, creamos una desde cero del estilo Subtitle)
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
        }
        
        
        // Cargar los datos del libro en la celda:
        // (título -> título del libro, subtítulo -> autor(es), imagen -> portada del libro)
        
        cell?.textLabel?.text = book.title
        cell?.detailTextLabel?.text = book.authorsToString()
        
        var coverImage = book.getCoverImage()
        
        if coverImage == nil {
            coverImage = UIImage(named: "book_cover.png")!
        }
        
        //cell?.imageView?.image = coverImage
        
        
        // Devolver la celda construida
        return cell!
    }
    
    
    // Título para las secciones de la tabla (el nombre de cada categoría, incluyendo la de favoritos y el número de libros que contiene)
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sectionName = model.getTag(atSectionPos: section)?.name.capitalizedString {
            
            let sectionCount = model.bookCount(forSectionPos: section)
            
            return sectionName + " (\(sectionCount))"
        }
        
        return nil
        
        // return model.getTag(atSectionPos: section)?.name + " (\(model.bookCount(forSectionPos: section)))"
    }
    
    
    // Función auxiliar para buscar un libro concreto en la libería a partir de un NSIndexPath
    func getBook(forIndexPath indexPath: NSIndexPath) -> CDABook {
        
        // Obtenemos la sección (el tag) y la fila a buscar
        let sectionNum = indexPath.section
        let rowNum = indexPath.row
        
        let book = model.getBook(atPosition: rowNum, inSection: sectionNum)
        
        // Asumimos que el libro buscado existe, en caso contrario la app cascará
        // (en ese caso, hay algo mal hecho)
        return book!
    }

}


//MARK: Definición del protocolo del delegado para este controlador

protocol CDALibraryTableViewControllerDelegate {
    
    func cdaLibraryTableViewController(vc: CDALibraryTableViewController, didSelectBook book: CDABook)
}


