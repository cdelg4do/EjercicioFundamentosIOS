//
//  CDABookViewController.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 07/05/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import UIKit

class CDABookViewController: UIViewController {

    //MARK: Propiedades de la clase
    
    let model: CDABook
    
    
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
    
    // Inicializador requerido para el uso de XIBs en Swift
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
 
        
        if model.isFavorite {
            favoriteStatus.text = "Sí"
        }
        else {
            favoriteStatus.text = "No"
        }
    }
    
    
    // Función que actualiza la portada del libro en pantalla
    
    func syncCoverImage() {
        
        do {
            let imageData = try NSData(contentsOfURL: model.cover, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            bookImage.image = UIImage(data: imageData)
        }
        catch {
            print("** ERROR ** : fallo al cargar imagen del libro")
        }
    }
    
    
    
    //MARK: Eventos desde los objetos de la interfaz
    
    // Añadir/eliminar el libro de Favoritos
    @IBAction func toggleFavorite(sender: AnyObject) {
        
        model.isFavorite = !model.isFavorite
        syncModelWithView(includingCover: false)
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
