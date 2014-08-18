//
//  AppDelegate.swift
//  Dolia
//
//  Created by Sidney San Martín on 6/13/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CHDoliaListenerDelegate {
                            
    var window: UIWindow?
    let listener = CHDoliaListener()
    
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
    
    func gotOffer(offer: CHDoliaOffer) {
        println("Got an offer: \(offer)")
    }
}

