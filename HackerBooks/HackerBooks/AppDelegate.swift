//
//  AppDelegate.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 03/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    // Url de descarga del JSON remoto con la información de los libros
    let remoteJsonUrlString = "https://t.co/K9ziV0z3SJ"
    
    // Key para el flag que indica que ya se cargó el JSON en el pasado
    let jsonAlreadyDownloadedKey = "JSON Already Downloaded on this device"
    
    // Variable que determina si hay que indicar en el título de la librería que se están cargando datos descargados
    var showTitleNewData = false
    
    // Variable que discrimina si el hardware es una tablet o no
    var HARDWARE_IS_IPAD: Bool {
        get {
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad { return true }
            else { return false }
        }
    }
    
    // Variable calculada que discrimina si el fichero JSON remoto ya fue descargado en anteriores ejecuciones del programa
    var JSON_ALREADY_DOWNLOADED: Bool {
        
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(jsonAlreadyDownloadedKey)
        }
    }
    
    
    var window: UIWindow?
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Lista de libros con la que construir la librería
        let myBookList: [CDABook]
        let myLibrary: CDALibrary
        
        
        // Si ya se descargó el JSON remoto en el pasado, cargamos la lista de libros a partir de los datos almacenados localmente
        if JSON_ALREADY_DOWNLOADED {
            
            // Leer el JSON local y si falla (p.ej. el fichero está corrupto), intentar descargar el JSON remoto de nuevo
            
            guard let jsonList = synchronousParseLocalJson(ifErrorThenTryFrom: remoteJsonUrlString) else {
                
                fatalError("\n** ERROR: no ha sido posible obtener los datos del JSON local ni del remoto **")
            }
            
            print("\nJSON local procesado con éxito")
            //print("\n\(jsonList)\n")
            
            // Construir la lista de libros a partir de los datos parseados
            myBookList = decodeBookList(fromList: jsonList)
            
            // Construir el modelo a partir de la lista de libros
            myLibrary = CDALibrary(books: myBookList)
            
            // No se mostrará nada en el título de la librería acerca de si los datos son locales (se asume que sí)
            showTitleNewData = false
        }
        
        // Si nunca se había descargado el JSON remoto, se descarga y se construye la lista de libros a partir de los datos que contiene
        else {
            
            // Descargar el JSON de Internet
            guard let jsonList = synchronousDownloadRemoteJson(from: remoteJsonUrlString) else {
                
                fatalError("\n** ERROR: la descarga del JSON remoto falló o no es un documento JSON correcto **")
            }
            
            print("\nJSON remoto procesado con éxito")
            //print("\n\(jsonList)\n")
            
            // Construir la lista de libros a partir de los datos parseados
            myBookList = decodeBookList(fromList: jsonList)
            
            // Construir el modelo a partir de la lista de libros
            myLibrary = CDALibrary(books: myBookList)
            
            
            // Guardarlo en la sandbox y crear el flag que indica que en próximas ejecuciones los datos se carguen localmente
            do {
                try myLibrary.saveToFile()
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: jsonAlreadyDownloadedKey)
            }
            catch {
                print("\n** ERROR: no pudo guardarse el fichero JSON en la Sandbox **")
            }
            
            
            // También en la Sandbox, crear los directorios para almacenar las portadas y los pdf
            do {
                try createCacheFolders()
            }
            catch {
                fatalError("\n** ERROR: no fue posible crear los directorios para la caché local **")
            }
            
            
            // Se mostrará en el título que los datos se acaban de descargar (new)
            showTitleNewData = true
        }
        
        
        // Debug: mostrar información sobre el modelo construido
        
        //myLibrary.printLibraryContents()
        //print("\n\(myLibrary.toJsonString())")
        
        
        // Crear una window
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        
        
        // Determinar el ViewController que usaremos como root (variará dependiendo del hardware en que estemos)
        var rootVC: UIViewController
        
        if HARDWARE_IS_IPAD {
            print("\nEstableciendo rootViewController para iPad...")
            rootVC = rootViewControllerForPad(withLibrary: myLibrary)
        }
        else {
            print("\nEstableciendo rootViewController para iPhone...")
            rootVC = rootViewControllerForPhone(withLibrary: myLibrary)
        }
        
        window?.rootViewController = rootVC
        
 
        // hacer visible & key a la window
        window?.makeKeyAndVisible()
        
        
        return true
    }

/*
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
*/
    
    
    //MARK: Funciones auxiliares
    
    
    // Creación de los directorios para las cachés de imágenes y pdf
    
    func createCacheFolders() throws {
        
        let dirNameImages = "Images"
        let dirNamePdf = "Pdf"
        let documentsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        let imagesPath = documentsDir + "/" + dirNameImages
        let pdfPath = documentsDir + "/" + dirNamePdf
        
        print("\nCreando directorios de caché local en:\n - \(imagesPath)\n - \(pdfPath)")
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(imagesPath, withIntermediateDirectories: false, attributes: nil)
            try NSFileManager.defaultManager().createDirectoryAtPath(pdfPath, withIntermediateDirectories: false, attributes: nil)
        }
        catch {
            throw FilesystemError.unableToCreateCacheFolders
        }
    }
    
    
    // Método para la creación del root view controller para hardware iPad
    
    func rootViewControllerForPad(withLibrary library: CDALibrary) -> UIViewController {
        
        // Controladores
        let libraryVC = CDALibraryTableViewController(model: library, showTitleNewData: showTitleNewData)
        let bookVC = CDABookViewController(forBook: library.getDefaultBook())
        
        // Combinadores
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        let bookNav = UINavigationController(rootViewController: bookVC)
        
        // SplitViewController con ambos combinadores
        let splitVC = UISplitViewController()
        splitVC.viewControllers = [libraryNav, bookNav]
        
        
        // Asignación de delegados
        libraryVC.delegate = bookVC
        
        
        return splitVC
    }
    
    
    // Método para la creación del root view controller para hardware iPhone
    
    func rootViewControllerForPhone(withLibrary library: CDALibrary) -> UIViewController {
        
        // Controlador
        let libraryVC = CDALibraryTableViewController(model: library, showTitleNewData: showTitleNewData)
        
        // Combinador
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        
        // Asignación de delegados
        libraryVC.delegate = libraryVC
        
        
        return libraryNav
    }


}

