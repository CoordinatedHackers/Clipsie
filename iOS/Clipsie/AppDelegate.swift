//
//  AppDelegate.swift
//  Clipsie
//
//  Created by Sidney San Martín on 6/13/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit
import CoreData
import MultipeerConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ClipsieAdvertiserDelegate {
                            
    var window: UIWindow?
    let peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
    let advertiser: ClipsieAdvertiser
    
    override init() {
        advertiser = ClipsieAdvertiser(peerID)
        super.init()
        advertiser.delegate = self
        advertiser.start()
    }
    
    var managedObjectContext: NSManagedObjectContext = {
        let managedObjectModel = NSManagedObjectModel(
            contentsOfURL: NSBundle.mainBundle().URLForResource("Clipsie", withExtension: "momd")!
        )
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        
        var err: NSError? = nil
        
        persistentStoreCoordinator.addPersistentStoreWithType(
            NSSQLiteStoreType,
            configuration: nil,
            URL: NSFileManager.defaultManager().URLsForDirectory(
                .DocumentDirectory, inDomains: .UserDomainMask
            )[0].URLByAppendingPathComponent("Clipsie.sqlite"),
            options: nil,
            error: &err
        )
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    // MARK: ClipsieAdvertiser delegate
    
    func gotOffer(offer: ClipsieOffer) {
        dispatch_after(0, dispatch_get_main_queue()) {
            self.managedObjectContext.save(nil)
            return
        }
    }
    
}

func appDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as AppDelegate
}
