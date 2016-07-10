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
    
    let model: CDABook
    
    
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
        
        let request = NSURLRequest(URL: model.pdfUrl)
        
        pdfWebView.scalesPageToFit = true
        pdfWebView.contentMode = UIViewContentMode.ScaleAspectFit
        pdfWebView.loadRequest(request)
    }
    
    
    //MARK: Eventos del ciclo de vida de la vista
    
    // Tareas tras crearse el controlador (se invocan una sola vez)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    
    // Tareas cuando se va a mostrar la vista en pantalla (se invocan una o más veces)
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        syncModelWithView()
    }

}
