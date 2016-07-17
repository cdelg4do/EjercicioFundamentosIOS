//
//  CDASimplePDFViewController.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 07/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import UIKit


let PdfUrlUpdatedNotification = "A book has updated its pdf url to a relative local path"
let PdfUrlUpdatedKey = "PdfUrlUpdated"


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
        
        guard let pdf = model.getPdfData() else {
            return
        }
        
        pdfWebView.loadData(pdf, MIMEType: "application/pdf", textEncodingName: "utf-8", baseURL: NSURL())
        
        
        // Si no es una url local, guardamos el pdf obtenido en el sandbox, y actualizamos la url del modelo
        
        if !model.isLocalPdfUrl() {
            
            print("\nLa ruta del fichero es remota, convirténdola en local...")
            
            // Ruta en la que almacenar el fichero
            let dirNamePdfs = "Pdf"
            let documentsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let fileName = model.getFileName(fromUrl: model.pdfUrl)
            
            let relativePath = "/" + fileName
            let fullPath = documentsDir + "/" + dirNamePdfs + relativePath
            
            
            // Guardar el NSData en la sandbox
            pdf.writeToFile(fullPath, atomically: true)
            
            
            // Actualizar la url del modelo
            model.pdfUrl = NSURL(fileURLWithPath: fullPath)
            
            // Enviar una notficación al TableViewController para que salve los cambios en la librería
            let nc = NSNotificationCenter.defaultCenter()
            
            let notifName = PdfUrlUpdatedNotification
            let notifObject = self
            let notifUserInfo = [PdfUrlUpdatedKey: model]
            let notif = NSNotification(name: notifName, object: notifObject, userInfo: notifUserInfo)
            
            nc.postNotification(notif)
        }
        
        
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
        
        
        // Suscripción de este controlador a las notificaciones
        // (para cuando el usuario selecciona un nuevo libro en la tabla)
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self,
                       selector: #selector(bookDidChange),
                       name: BookDidChangeNotification,
                       object: nil)                                 // con objetct: nil --> a todas las notificaciones
    }
    
    
    // Tareas cuando se va a mostrar la vista en pantalla (se invocan una o más veces)
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Sincronizar la vista con el modelo
        syncModelWithView()
    }

}
