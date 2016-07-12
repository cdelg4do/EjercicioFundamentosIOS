//
//  CDALibraryTableViewController.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 09/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import UIKit


let BookDidChangeNotification = "Selected book has changed"
let BookDidChangeKey = "SelectedBook"


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
        
        title = "HackerBooks 1.0 (\(model.totalBookCount) books)"
    }
    
    // Inicializador requerido para el uso de UIKit en Swift
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Función que se ejecuta cuando el usuario selecciona una nueva fila de la tabla
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("\nNueva fila seleccionada en la tabla: (\(indexPath.section), \(indexPath.row))")
        
        // Obtener el nuevo libro seleccionado
        let newBook = getBook(forIndexPath: indexPath)
        
        // Hacer que el delegado del controlador ejecute el código que corresponde
        // (en este caso el delegado es un BookViewController --> actualizarse con los detalles del nuevo libro)
        delegate?.cdaLibraryTableViewController(self, didSelectBook: newBook)
        
        // Enviar una notificación de cambio de fila
        // (para que el PDF View Controller muestre el PDF del nuevo libro seleccionado)
        let nc = NSNotificationCenter.defaultCenter()
        
        let notifName = BookDidChangeNotification
        let notifObject = self
        let notifUserInfo = [BookDidChangeKey: newBook]
        let notif = NSNotification(name: notifName, object: notifObject, userInfo: notifUserInfo)
        
        nc.postNotification(notif)
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
        // ( título -> título del libro, subtítulo -> autor(es) )
        
        cell?.textLabel?.text = book.title
        cell?.detailTextLabel?.text = book.authorsToString()
        
        
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
    
    
    
    //MARK: Eventos del ciclo de vida de la vista
    
    // Tareas tras crearse el controlador (se invocan una sola vez)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        // Suscripción de este controlador a las notificaciones
        // (para cuando hay un cambio de favorito en un libro)
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self,
                       selector: #selector(favoriteDidChange),
                       name: FavoriteDidChangeNotification,
                       object: nil)                                 // con objetct: nil --> a todas las notificaciones
    }
    
    
    
    //MARK: Otras funciones auxiliares
    
    // Función para buscar un libro concreto en la libería a partir de un NSIndexPath
    func getBook(forIndexPath indexPath: NSIndexPath) -> CDABook {
        
        // Obtenemos la sección (el tag) y la fila a buscar
        let sectionNum = indexPath.section
        let rowNum = indexPath.row
        
        let book = model.getBook(atPosition: rowNum, inSection: sectionNum)
        
        // Asumimos que el libro buscado existe, en caso contrario la app cascará
        // (en ese caso, hay algo mal hecho)
        return book!
    }
    
    
    // Función que se ejecuta cuando se recibe una notificación de cambio de favorito en un libro
    func favoriteDidChange(notification: NSNotification) {
        
        print("\nTableViewController recibió una notificación de cambio de favorito")
        
        // Obtener el libro que ha sido añadido/eliminado de favoritos
        let info = notification.userInfo!
        let book = info[FavoriteDidChangeKey] as? CDABook
        
        // Actualizar el modelo
        model.toggleFavorite(book!)
        
        // Serializar el modelo actualizado
        do {
            try model.saveToFile()
        }
        catch {
            print("\n** ERROR: no pudo guardarse el fichero JSON en la Sandbox **")
        }
        
        
        
        // Refrescar el contenido de la tabla
        self.tableView.reloadData()
    }

}


//MARK: Definición del protocolo del delegado para este controlador

protocol CDALibraryTableViewControllerDelegate {
    
    func cdaLibraryTableViewController(vc: CDALibraryTableViewController, didSelectBook book: CDABook)
}



//MARK: Hacemos que el propio CDATableViewController implemente el protocolo CDALibraryTableViewControllerDelegate
//      (para funcionar como su propio delegado cuando no estemos en un iPad y no se pueda usar un SplitVC)

extension CDALibraryTableViewController: CDALibraryTableViewControllerDelegate {
    
    // Crear un nuevo BookVC con los datos del nuevo libro seleccionado y mostrarlo
    func cdaLibraryTableViewController(vc: CDALibraryTableViewController, didSelectBook book: CDABook) {
        
        let bookVC = CDABookViewController(forBook: book)
        self.navigationController?.pushViewController(bookVC, animated: true)
    }
    
}


