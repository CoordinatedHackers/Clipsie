//
//  AppDelegate.swift
//  Dolia
//
//  Created by Sidney San Martín on 6/13/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CHDoliaListenerDelegate {
                            
    var window: UIWindow?
    let listener = CHDoliaListener()
    
    var managedObjectContext: NSManagedObjectContext = {
        let managedObjectModel = NSManagedObjectModel(
            contentsOfURL: NSBundle.mainBundle().URLForResource("Dolia", withExtension: "momd")!
        )
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        var err: NSError? = nil
        
        persistentStoreCoordinator.addPersistentStoreWithType(
            NSSQLiteStoreType,
            configuration: nil,
            URL: NSFileManager.defaultManager().URLsForDirectory(
                .DocumentDirectory, inDomains: .UserDomainMask
            )[0].URLByAppendingPathComponent("Dolia/Dolia.sqlite"),
            options: nil,
            error: &err
        )
        
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    override init() {
        super.init()
        listener.delegate = self
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        listener.start()
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        listener.stop()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        listener.start()
    }

    // MARK: CHDoliaListener delegate
    
    func managedObjectContextForOffer() -> NSManagedObjectContext {
        return managedObjectContext
    }
}

func appDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as AppDelegate
}