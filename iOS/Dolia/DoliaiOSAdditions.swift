//
//  DoliaiOSAdditions.swift
//  Dolia
//
//  Created by Sidney San Martín on 8/12/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit

extension CHDoliaOffer {
    class func offerWithClipboard(managedObjectContext: NSManagedObjectContext) -> CHDoliaOffer? {
        let pasteboard = UIPasteboard.generalPasteboard()
        if let url = pasteboard.URL {
            let offer = CHDoliaURLOffer(inManagedObjectContext: managedObjectContext)
            offer.url = url
            return offer
        } else if let string = pasteboard.string {
            let offer = CHDoliaTextOffer(inManagedObjectContext: managedObjectContext)
            offer.string = string
            return offer
        }
        return nil
    }
}

extension CHDoliaTextOffer {
    override public func accept() {
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = string
    }
}

extension CHDoliaURLOffer {
    override public func accept() {
        UIApplication.sharedApplication().openURL(url)

    }
}