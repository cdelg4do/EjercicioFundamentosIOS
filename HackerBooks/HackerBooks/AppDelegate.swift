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

    var window: UIWindow?
    
    var HARDWARE_IS_IPAD: Bool {
        
        get {
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                return true
            }
            else {
                return false
            }
        }
    }
    
    
    //MARK: Métodos para la creación del root view controller para cada tipo de hardware
    
    func rootViewControllerForPad(withLibrary library: CDALibrary) -> UIViewController {
        
        // Controladores
        let libraryVC = CDALibraryTableViewController(model: library)
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
    
    
    func rootViewControllerForPhone(withLibrary library: CDALibrary) -> UIViewController {
        
        // Controlador
        let libraryVC = CDALibraryTableViewController(model: library)
        
        // Combinador
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        
        // Asignación de delegados
        libraryVC.delegate = libraryVC
        
        
        return libraryNav
    }
    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Modelo hardcodeado
        
        let book1 = CDABook(title: "Data Structures and Algorithm Analysis in C++",
                             authors: ["Clifford A. Shaffer"],
                             tags: [CDABookTag(name: "algorithms"), CDABookTag(name: "programming")],
                             cover: NSURL(string: "http://hackershelf.com/media/cache/03/9c/039c5dc17d213a9bd8995d787fc9e45e.jpg")!,
                             pdfUrl: NSURL(string: "http://people.cs.vt.edu/~shaffer/Book/C++3elatest.pdf")!)
        
        let book2 = CDABook(title: "PHP 5 Power Programing",
                             authors: ["Andi Gutmans", "Stig Bakken", "Derick Rethans"],
                             tags: [CDABookTag(name: "programming"), CDABookTag(name: "php")],
                             cover: NSURL(string: "http://hackershelf.com/media/cache/c0/cb/c0cb7c7b9e516eb257ee873cd2eaf455.jpg")!,
                             pdfUrl: NSURL(string: "https://ptgmedia.pearsoncmg.com/images/013147149X/downloads/013147149X_book.pdf")!)
        
        let book3 = CDABook(title: "Data + Design",
                             authors: ["Trinna Chiasson", "Dyanna Gregory", "Contributors"],
                             tags: [CDABookTag(name: "design"), CDABookTag(name: "data visualization")],
                             cover: NSURL(string: "http://hackershelf.com/media/cache/d5/c1/d5c1bb30894ecee940da27d00c0498ed.jpg")!,
                             pdfUrl: NSURL(string: "http://orm-atlas2-prod.s3.amazonaws.com/pdf/13a07b19e01a397d8855c0463d52f454.pdf")!)
        
        let book4 = CDABook(title: "Data Structures and Algorithm Analysis in Java",
                             authors: ["Clifford A. Shaffer"],
                             tags: [CDABookTag(name: "algorithms"), CDABookTag(name: "programming"), CDABookTag(name: "java")],
                             cover: NSURL(string: "http://hackershelf.com/media/cache/f7/f5/f7f572bf7f234f8bd068e608c0d3ef22.jpg")!,
                            pdfUrl: NSURL(string: "http://people.cs.vt.edu/~shaffer/Book/JAVA3elatest.pdf")!)
        
        let book5 = CDABook(title: "Combinatorial Algorithms",
                             authors: ["Herbert S. Wilf", "Albert Nijenhuis"],
                             tags: [CDABookTag(name: "algorithms"), CDABookTag(name: "math")],
                             cover: NSURL(string: "http://hackershelf.com/media/cache/35/98/3598f6116dedc9ad6fddb43e63914264.jpg")!,
                             pdfUrl: NSURL(string: "http://www.math.upenn.edu/~wilf/website/CombinatorialAlgorithms.pdf")!)
        
        book4.isFavorite = true
        book5.isFavorite = true
        
        let myBookList = [book1, book2, book3, book4, book5]
        
        let myLibrary = CDALibrary(books: myBookList)
        
        myLibrary.printLibraryContents()
        
        
        
        // crear una window
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        
        
        // Determinar el ViewController que usaremos como root (variará dependiendo del hardware en que estemos)
        var rootVC: UIViewController
        
        if HARDWARE_IS_IPAD {
            print("\n** HARDWARE ES IPAD: SÍ **")
            rootVC = rootViewControllerForPad(withLibrary: myLibrary)
        }
        else {
            print("\n** HARDWARE ES IPAD: NO **")
            rootVC = rootViewControllerForPhone(withLibrary: myLibrary)
        }
        
        window?.rootViewController = rootVC
        
 
        // hacer visible & key a la window
        window?.makeKeyAndVisible()
        
        
        return true
    }

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


}

