//
//  CDABookViewController.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 07/05/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import UIKit


let FavoriteDidChangeNotification = "A book was added or removed from Favorites"
let FavoriteDidChangeKey = "FavoriteBookToggled"

let CoverUrlUpdatedNotification = "A book has updated its cover url to a relative local path"
let CoverUrlUpdatedKey = "CoverUrlUpdated"



class CDABookViewController: UIViewController {

    //MARK: Propiedades de la clase
    
    var model: CDABook
    
    
    // Referencia a los objetos de la interfaz
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var tagList: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var favoriteStatus: UILabel!
    
    
    //MARK: Inicializadores de la clase
    
    // Inicializador designado
    init(forBook model: CDABook) {
        
        self.model = model
        super.init(nibName: "CDABookViewController", bundle: nil)
    }
    
    // Inicializador requerido para el uso de UIKit en Swift
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Otros métodos de la clase
    
    // Función para actualizar la vista con los datos del modelo
    // (opcionalmente, se actualizará también la portada del libro)
    
    func syncModelWithView(includingCover syncCover: Bool) {
        
        title = model.title
        
        authorName.text = model.authorsToString()
        tagList.text = model.tagsToString()
        
        if syncCover {

            syncCoverImage()
        }
        else {
            
            // bookImage.image = UIImage(named: "book_cover.png")!
        }
 
        
        if model.isFavorite {
            favoriteStatus.text = "Yes"
        }
        else {
            favoriteStatus.text = "No"
        }
    }
    
    
    // Función que actualiza la portada del libro en pantalla
    
    func syncCoverImage() {
        
        
        print("\nCargando portada de: \(model.coverUrl)...")
        
        // Obtenemos la imagen de la url del modelo (sin preocuparnos si es local o remota)
        guard let coverImage = model.getCoverImage() else {
            return
        }
        
        
        bookImage.image = coverImage
        
        
        // Si no es una url local, guardamos la imagen obtenida en el sandbox, y actualizamos la url del modelo
        
        if !model.isLocalCoverUrl() {
            
            print("\nLa ruta del fichero es remota, convirténdola en local...")
            
            // Ruta en la que almacenar el fichero
            let dirNameImages = "Images"
            let documentsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let fileName = model.getFileName(fromUrl: model.coverUrl)
            
            let relativePath = "/" + fileName
            let fullPath = documentsDir + "/" + dirNameImages + relativePath
            
            
            // Convertir el UIImage en NSData y guardarlo en la sandbox
            guard let imageData = UIImageJPEGRepresentation(coverImage, 1.0) else {
                return
            }
            
            imageData.writeToFile(fullPath, atomically: true)
            
            
            // Actualizar la url del modelo
            model.coverUrl = NSURL(fileURLWithPath: fullPath)
            
            
            // Enviar una notficación al TableViewController para que salve los cambios en la librería
            let nc = NSNotificationCenter.defaultCenter()
            
            let notifName = CoverUrlUpdatedNotification
            let notifObject = self
            let notifUserInfo = [CoverUrlUpdatedKey: model]
            let notif = NSNotification(name: notifName, object: notifObject, userInfo: notifUserInfo)
            
            nc.postNotification(notif)
        }
        
    }
    
    
    
    //MARK: Eventos desde los objetos de la interfaz
    
    // Añadir/eliminar el libro de Favoritos
    @IBAction func toggleFavorite(sender: AnyObject) {
        
        print("\nSe modificó el status de favorito del libro actual")
        
        model.isFavorite = !model.isFavorite
        syncModelWithView(includingCover: false)
        
        // Enviar una notificación para que el LibraryTableViewController refleje el cambio
        let nc = NSNotificationCenter.defaultCenter()
        
        let notifName = FavoriteDidChangeNotification
        let notifObject = self
        let notifUserInfo = [FavoriteDidChangeKey: model]
        let notif = NSNotification(name: notifName, object: notifObject, userInfo: notifUserInfo)
        
        nc.postNotification(notif)
    }
    
    // Mostrar el PDF del libro
    @IBAction func showPdf(sender: AnyObject) {
        
        // Crear un SimplePDFViewController con los datos del modelo
        let pdfVC = CDASimplePDFViewController(forBook: model)
        
        // Hacer un push sobre mi NavigatorController
        navigationController?.pushViewController(pdfVC, animated: true)
    }
    
    
    //MARK: Eventos del ciclo de vida de la vista
    
    // Tareas tras crearse el controlador (se invocan una sola vez)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    
    // Tareas cuando se va a mostrar la vista en pantalla (se invocan una o más veces)
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        syncModelWithView(includingCover: false)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        syncCoverImage()
    }

}



//MARK: Implementación del protocolo CDALibraryTableViewControllerDelegate
//      (para cuando se selecciona un libro en la tabla)

extension CDABookViewController: CDALibraryTableViewControllerDelegate {
    
    // Actualizar el modelo y la vista con el nuevo libro seleccionado
    func cdaLibraryTableViewController(vc: CDALibraryTableViewController, didSelectBook book: CDABook) {
        
        print("\nDelegado BookViewController actualizando los detalles del nuevo libro seleccionado...")
        
        model = book
        
        syncModelWithView(includingCover: false)
        syncCoverImage()
    }
    
}


