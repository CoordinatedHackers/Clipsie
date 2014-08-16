//
//  DoliaiOSAdditions.swift
//  Dolia
//
//  Created by Sidney San Martín on 8/12/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit

func offerWithClipboard() -> CHDoliaOffer? {
    let pasteboard = UIPasteboard.generalPasteboard()
    if let url = pasteboard.URL {
        return CHDoliaURLOffer(URL: url)
    } else if let string = pasteboard.string {
        return CHDoliaTextOffer(string: string)
    }
    return nil
}