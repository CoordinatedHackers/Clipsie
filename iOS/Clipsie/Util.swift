//
//  Util.swift
//  Clipsie
//
//  Created by Sidney San Martín on 8/16/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit

// Notes:
// - You must explicitly weak link to UIKit to support iOS 7
// - Action sheets on iOS 7 only show a title

class Helper: NSObject {
    
    var holdSelf: Helper?
    var cb: (Int) -> ()
    
    init(cb: (Int) -> ()) {
        self.cb = cb
        super.init()
        self.holdSelf = self
    }
    
    func finish(index: Int) {
        self.cb(index)
        self.holdSelf = nil
    }
}

class ActionSheetHelper : Helper, UIActionSheetDelegate {
    init(_ actionSheet: UIActionSheet, cb: (Int) -> ()) {
        super.init(cb: cb)
        actionSheet.delegate = self
        
    }
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        actionSheet.delegate = nil
        self.finish(buttonIndex)
    }
}

class AlertHelper : Helper, UIAlertViewDelegate {
    init(_ alertView: UIAlertView, cb: (Int) -> ()) {
        super.init(cb: cb)
        alertView.delegate = self
        
    }
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        alertView.delegate = nil
        self.finish(buttonIndex)
    }
}

func showAlert(viewController: UIViewController, style: UIAlertControllerStyle = .Alert, title: String? = nil, message: String? = nil, sourceView: UIView? = nil, completion: (() -> ())? = nil, buttons: (UIAlertActionStyle, String, (() -> ())?)...) {
    
    if (NSClassFromString("UIAlertController") != nil) {
        // iOS 8+
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        for button in buttons {
            alertController.addAction(UIAlertAction(title: button.1, style: button.0) { (_: UIAlertAction!) in
                if let completion = completion { completion() }
                if let cb = button.2 { cb() }
            })
        }
        if let sourceView = sourceView {
            if let popoverPresentationController = alertController.popoverPresentationController {
                popoverPresentationController.sourceView = sourceView
                popoverPresentationController.sourceRect = sourceView.bounds
            }
        }
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
        
    } else {
        // iOS 7

        switch style {
        case .ActionSheet:
            let actionSheet = UIActionSheet()
            if let title = title {
                actionSheet.title = title
            }
            for button in buttons {
                actionSheet.addButtonWithTitle(button.1)
                switch button.0 {
                case .Default:
                    break
                case .Cancel:
                    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1
                case .Destructive:
                    actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 1
                }
            }
            ActionSheetHelper(actionSheet) {
                if let completion = completion { completion() }
                if let cb = buttons[$0].2 { cb() }
            }
            if let sourceView = sourceView {
                actionSheet.showFromRect(sourceView.bounds, inView: sourceView, animated: true)
            } else {
                actionSheet.showInView(viewController.view)
            }
        case .Alert:
            let alertView = UIAlertView()
            if let title = title {
                alertView.title = title
            }
            if let message = message {
                alertView.message = message
            }
            for button in buttons {
                alertView.addButtonWithTitle(button.1)
                switch button.0 {
                case .Cancel:
                    alertView.cancelButtonIndex = alertView.numberOfButtons - 1
                default:
                    break
                }
            }
            AlertHelper(alertView) {
                if let completion = completion { completion() }
                if let cb = buttons[$0].2 { cb() }
            }
            alertView.show()
        }
        
    }
}
