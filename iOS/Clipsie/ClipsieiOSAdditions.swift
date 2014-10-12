//
//  ClipsieiOSAdditions.swift
//  Clipsie
//
//  Created by Sidney San Martín on 8/12/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit

extension CHClipsieOffer {
    class func offerWithClipboard(managedObjectContext: NSManagedObjectContext) -> CHClipsieOffer? {
        let pasteboard = UIPasteboard.generalPasteboard()
        if let url = pasteboard.URL {
            let offer = CHClipsieURLOffer(inManagedObjectContext: managedObjectContext)
            offer.url = url.absoluteString
            return offer
        } else if let string = pasteboard.string {
            let offer = CHClipsieTextOffer(inManagedObjectContext: managedObjectContext)
            offer.string = string
            return offer
        }
        return nil
    }
}

extension CHClipsieTextOffer {
    override public func accept() {
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = string
    }
}

extension CHClipsieURLOffer {
    override public func accept() {
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)

    }
}
