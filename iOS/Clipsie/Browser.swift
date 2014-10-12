//
//  Browser.swift
//  Clipsie
//
//  Created by Sidney San Martín on 8/11/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit

class BrowserViewController: UITableViewController, CHClipsieBrowserDelegate {
    var browser = CHClipsieBrowser()
    var destinations = [CHClipsieDestination]()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        browser.delegate = self
        browser.start()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    // MARK: Notifications
    
    func applicationDidEnterBackground() {
        browser.stop()
    }
    
    func applicationWillEnterForeground() {
        browser.start()
    }
    
    // MARK: Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("destination", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = destinations[indexPath.row].name()
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.destinations.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        let destination = self.destinations[indexPath.row]
        
        
        showAlert(self, style: .ActionSheet, sourceView: cell, completion: {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.dismiss()
        },
            (.Default, "Send clipboard", {
                // Use a temporary managed object context. Right now we don't care about saving sent offers
                let managedObjectContext = NSManagedObjectContext()
                managedObjectContext.parentContext = appDelegate().managedObjectContext
                if let offer = CHClipsieOffer.offerWithClipboard(managedObjectContext) {
                    destination.sendOffer(offer)
                    return
                }
                // TODO: Handle this more gracefully, e.g. by disabling sending if nothing's on your clipboard
                showAlert(self, title: "Nothing to send", message: "The clipboard is empty.", completion: nil,
                    (.Cancel, "OK", nil)
                )
            }),
            (.Cancel, "Cancel", nil)
        )
    }
    
    // MARK: CHClipsieBrowser delegate
    
    func foundDestination(destination: CHClipsieDestination, moreComing: Bool) {
        self.destinations.append(destination)
        self.tableView.reloadData()
        if !moreComing {
            self.tableView.reloadData()
        }
    }
    
    func lostDestination(destination: CHClipsieDestination, moreComing: Bool) {
        self.destinations = self.destinations.filter({$0 !== destination})
        if !moreComing {
            self.tableView.reloadData()
        }
    }
}
