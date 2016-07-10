//
//  CDASimplePDFViewController.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 07/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import UIKit

class CDASimplePDFViewController: UIViewController {
    
    //MARK: Propiedades de la clase
    
    var model: CDABook
    
    
    // Referencia a los objetos de la interfaz
    
    @IBOutlet weak var pdfWebView: UIWebView!
    
    
    //MARK: Inicializadores de la clase
    
    // Inicializador designado
    init(forBook model: CDABook) {
        
        self.model = model
        super.init(nibName: "CDASimplePDFViewController", bundle: nil)
    }
    
    // Inicializador requerido para el uso de UIKit en Swift
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Otros métodos de la clase
    
    // Función para actualizar la vista con los datos del modelo
    func syncModelWithView() {
        
        print("\nCargando PDF de: \(model.pdfUrl)...")
        
        let request = NSURLRequest(URL: model.pdfUrl)
        
        pdfWebView.scalesPageToFit = true
        pdfWebView.contentMode = UIViewContentMode.ScaleAspectFit
        pdfWebView.loadRequest(request)
    }
    
    
    // Función que se ejecuta cuando se recibe una notificación de cambio de libro seleccionado en la biblioteca
    func bookDidChange(notification: NSNotification) {
        
        print("\nPdfViewController recibió una notificación de nuevo libro seleccionado")
        
        // Obtener el nuevo libro que ha sido seleccionado
        let info = notification.userInfo!
        let newBook = info[BookDidChangeKey] as? CDABook
        
        // Si es un libro diferente al actual, actualizar el modelo y la vista
        if newBook != model {
            
            self.model = newBook!
            syncModelWithView()
        }
        else {
            print("\n** Se seleccionó el mismo libro que ya se estaba mostrando, no se realizan operaciones. **")
        }
    }
    
    
    //MARK: Eventos del ciclo de vida de la vista
    
    // Tareas tras crearse el controlador (se invocan una sola vez)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    
    // Tareas cuando se va a mostrar la vista en pantalla (se invocan una o más veces)
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Suscripción de este controlador a las notificaciones
        // (para cuando el usuario selecciona un nuevo libro en la tabla)
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self,
                       selector: #selector(bookDidChange),
                       name: BookDidChangeNotification,
                       object: nil)                                 // con objetct: nil --> a todas las notificaciones
        
        // Sincronizar la vista con el modelo
        syncModelWithView()
    }

}
