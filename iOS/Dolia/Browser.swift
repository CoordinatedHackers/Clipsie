//
//  Browser.swift
//  Dolia
//
//  Created by Sidney San Martín on 8/11/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit

class BrowserViewController: UITableViewController, CHDoliaBrowserDelegate {
    var browser = CHDoliaBrowser()
    var destinations = [CHDoliaDestination]()
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        browser.delegate = self
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    // MARK: Table view data source

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = tableView.dequeueReusableCellWithIdentifier("destination", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = destinations[indexPath.row].name()
        return cell
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.destinations.count
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        let destination = self.destinations[indexPath.row]
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet);
        actionController.addAction(UIAlertAction(title: "Send clipboard", style: .Default, { (action: UIAlertAction!) in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if let offer = offerWithClipboard() {
                destination.sendOffer(offer)
                return
            }
            // TODO: Handle this more gracefully, e.g. by disabling sending if nothing's on your clipboard
            let alertController = UIAlertController(title: "Nothing to send", message: "The clipboard is empty.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
            self.presentViewController(alertController, animated: true, completion: nil)
        }))
        actionController.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction!) in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        })
        
        if let popoverPresentationController = actionController.popoverPresentationController {
            popoverPresentationController.sourceView = cell
            popoverPresentationController.sourceRect = cell.bounds
        }
        self.presentViewController(actionController, animated: true, completion: nil)
    }
    
    // MARK: CHDoliaBrowser delegate
    
    func foundDestination(destination: CHDoliaDestination, moreComing: Bool) {
        self.destinations.append(destination)
        self.tableView.reloadData()
    }
    
    func lostDestination(destination: CHDoliaDestination, moreComing: Bool) {
        self.destinations = self.destinations.filter({$0 != destination})
        self.tableView.reloadData()
    }
}