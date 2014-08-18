//
//  DoliaiOSAdditions.swift
//  Dolia
//
//  Created by Sidney San Martín on 8/12/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit

extension CHDoliaOffer {
    class func offerWithClipboard() -> CHDoliaOffer? {
        let pasteboard = UIPasteboard.generalPasteboard()
        if let url = pasteboard.URL {
            return CHDoliaURLOffer(URL: url)
        } else if let string = pasteboard.string {
            return CHDoliaTextOffer(string: string)
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
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.URL = url
    }
}