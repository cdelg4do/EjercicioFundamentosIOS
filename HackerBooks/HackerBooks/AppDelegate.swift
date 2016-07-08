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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Modelo hardcodeado
        
        /*
        let libro1 = CDABook(title: "Libro 1",
                             authors: ["Autor1", "Autor2"],
                             tags: [CDABookTag(name: "tag1"), CDABookTag(name: "tag2")],
                             portrait: UIImage(),
                             pdfUrl: NSURL(fileURLWithPath: "path1"))
        
        let libro2 = CDABook(title: "Libro 2",
                             authors: ["Autor3", "Autor4", "Autor5"],
                             tags: [CDABookTag(name: "tag3"), CDABookTag(name: "tag4")],
                             portrait: UIImage(),
                             pdfUrl: NSURL(fileURLWithPath: "path2"))
        
        let libro3 = CDABook(title: "Libro 3",
                             authors: ["Autor1", "Autor6"],
                             tags: [CDABookTag(name: "tag1"), CDABookTag(name: "tag3")],
                             portrait: UIImage(),
                             pdfUrl: NSURL(fileURLWithPath: "path3"))
        
        let libro4 = CDABook(title: "Libro 4",
                             authors: ["Autor7"],
                             tags: [CDABookTag(name: "tag5"), CDABookTag(name: "tag6")],
                             portrait: UIImage(),
                             pdfUrl: NSURL(fileURLWithPath: "path4"))
        
        let libro5 = CDABook(title: "Libro 5",
                             authors: ["Autor3", "Autor4", "Autor5"],
                             tags: [CDABookTag(name: "tag2"), CDABookTag(name: "tag4")],
                             portrait: UIImage(),
                             pdfUrl: NSURL(fileURLWithPath: "path5"))
        
        let libro6 = CDABook(title: "Salgo en todas partes",
                             authors: ["Autor4"],
                             tags: [CDABookTag(name: "tag1"), CDABookTag(name: "tag2"), CDABookTag(name: "tag3"), CDABookTag(name: "tag4"), CDABookTag(name: "tag5"), CDABookTag(name: "tag6")],
                             portrait: UIImage(),
                             pdfUrl: NSURL(fileURLWithPath: "path6"))
        
        libro6.isFavorite = true
         
        let listaLibros = [libro6, libro5, libro4, libro1, libro3, libro2]
        */
        
        
        let libro1 = CDABook(title: "Data Structures and Algorithm Analysis in C++",
                             authors: ["Clifford A. Shaffer"],
                             tags: [CDABookTag(name: "algorithms"), CDABookTag(name: "programming")],
                             cover: NSURL(string: "http://hackershelf.com/media/cache/03/9c/039c5dc17d213a9bd8995d787fc9e45e.jpg")!,
                             pdfUrl: NSURL(string: "http://people.cs.vt.edu/~shaffer/Book/C++3elatest.pdf")!)
        
        let libro2 = CDABook(title: "PHP 5 Power Programing",
                             authors: ["Andi Gutmans", "Stig Bakken", "Derick Rethans"],
                             tags: [CDABookTag(name: "programming"), CDABookTag(name: "php")],
                             cover: NSURL(string: "http://hackershelf.com/media/cache/03/9c/039c5dc17d213a9bd8995d787fc9e45e.jpg")!,
                             pdfUrl: NSURL(string: "https://ptgmedia.pearsoncmg.com/images/013147149X/downloads/013147149X_book.pdf")!)
        
        let libro3 = CDABook(title: "Data + Design",
                             authors: ["Trinna Chiasson", "Dyanna Gregory", "Contributors"],
                             tags: [CDABookTag(name: "design"), CDABookTag(name: "data visualization")],
                             cover: NSURL(string: "http://hackershelf.com/media/cache/d5/c1/d5c1bb30894ecee940da27d00c0498ed.jpg")!,
                             pdfUrl: NSURL(string: "http://orm-atlas2-prod.s3.amazonaws.com/pdf/13a07b19e01a397d8855c0463d52f454.pdf")!)
        
        let libro4 = CDABook(title: "Data Structures and Algorithm Analysis in Java",
                             authors: ["Clifford A. Shaffer"],
                             tags: [CDABookTag(name: "algorithms"), CDABookTag(name: "programming"), CDABookTag(name: "java")],
                             cover: NSURL(string: "http://hackershelf.com/media/cache/f7/f5/f7f572bf7f234f8bd068e608c0d3ef22.jpg")!,
                            pdfUrl: NSURL(string: "http://people.cs.vt.edu/~shaffer/Book/JAVA3elatest.pdf")!)
        
        let libro5 = CDABook(title: "Combinatorial Algorithms",
                             authors: ["Herbert S. Wilf", "Albert Nijenhuis"],
                             tags: [CDABookTag(name: "algorithms"), CDABookTag(name: "math")],
                             cover: NSURL(string: "http://hackershelf.com/media/cache/d5/c1/d5c1bb30894ecee940da27d00c0498ed.jpg")!,
                             pdfUrl: NSURL(string: "http://www.math.upenn.edu/~wilf/website/CombinatorialAlgorithms.pdf")!)
        
        libro4.isFavorite = true
        libro2.isFavorite = true
        
        
        let listaLibros = [libro1, libro2, libro3, libro4, libro5]
        
        let libreria = CDALibrary(books: listaLibros)
        
        libreria.printLibraryContents()
        
        
        
        // crear una window
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
            
        // crear un VC
        
        let rnd = Int(arc4random_uniform(UInt32(listaLibros.count)))
        let choosenBook = listaLibros[rnd]
        print("\nMostrando libro #\(rnd): \(choosenBook)")
        
        let vc = CDABookViewController(forBook: choosenBook)
        
        // empotrarlo en un navigation
        let nav = UINavigationController(rootViewController: vc)
            
        // asignar el nav como rootVC
        window?.rootViewController = nav
         
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

