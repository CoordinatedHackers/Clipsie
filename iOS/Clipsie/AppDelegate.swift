//
//  AppDelegate.swift
//  Clipsie
//
//  Created by Sidney San Martín on 6/13/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit
import CoreData
import ClipsieKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ClipsieKit.AdvertiserDelegate {
                            
    var window: UIWindow?
    let peerID = ClipsieKit.PeerID()
    let advertiser: ClipsieKit.Advertiser
    
    override init() {
        advertiser = ClipsieKit.Advertiser(peerID)
        super.init()
        advertiser.delegate = self
        advertiser.start()
    }
    
    var managedObjectContext: NSManagedObjectContext = {
        let managedObjectModel = NSManagedObjectModel(
            contentsOfURL: NSBundle(identifier: "com.coordinatedhackers.ClipsieKit")!.URLForResource("Clipsie", withExtension: "momd")!
        )
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        
        var err: NSError? = nil
        
        try! persistentStoreCoordinator.addPersistentStoreWithType(
            NSSQLiteStoreType,
            configuration: nil,
            URL: NSFileManager.defaultManager().URLsForDirectory(
                .DocumentDirectory, inDomains: .UserDomainMask
            )[0].URLByAppendingPathComponent("Clipsie.sqlite"),
            options: nil
        )
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    func applicationDidEnterBackground(application: UIApplication) {
        advertiser.stop()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        advertiser.start()
    }
    
    // MARK: ClipsieKit.AdvertiserDelegate
    
    func gotOffer(offer: ClipsieKit.Offer) {
        offer.toStored(managedObjectContext)
        try! managedObjectContext.save()
    }
}

func appDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}
