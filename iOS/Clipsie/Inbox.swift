//
//  History.swift
//  Clipsie
//
//  Created by Sidney San Martín on 8/11/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit
import CoreData
import ClipsieKit

class InboxViewController: UITableViewController, NSFetchedResultsControllerDelegate, ClipsieKit.BrowserDelegate {
    var browser = ClipsieKit.Browser(appDelegate().peerID)
    var peers: [ClipsieKit.PeerID] = []
    
    let fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Offer")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "received", ascending: false)]
        return NSFetchedResultsController(
            fetchRequest: fetchRequest, managedObjectContext: appDelegate().managedObjectContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        try! fetchedResultsController.performFetch()
        fetchedResultsController.delegate = self
        navigationItem.leftBarButtonItem = self.editButtonItem()
        browser.delegate = self
        browser.start()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    // MARK: - Table view stuff

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return peers.count }
        return self.fetchedResultsController.fetchedObjects!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("peer", forIndexPath: indexPath)
            configureCell(cell, withPeer: peers[indexPath.row])
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("history", forIndexPath: indexPath)
        let offer = self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! ClipsieKit.StoredOffer
        configureCell(cell, withOffer: offer)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if editing { return }
        if indexPath.section == 0 {
            showAlert(self, style: .ActionSheet, sourceView: tableView.cellForRowAtIndexPath(indexPath)!, completion: {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            },
                (.Default, "Send clipboard", {
                    if let pasteboardString = UIPasteboard.generalPasteboard().string {
                        if let session = ClipsieKit.OutboundSession.with(self.peers[indexPath.row]) {
                            session.offerText(pasteboardString)
                                .catchError { print("Failed to send an offer: \($0)") }
                            return
                        }
                    }
                    // TODO: Handle this more gracefully, e.g. by disabling sending if nothing's on your clipboard
                    showAlert(self, title: "Nothing to send", message: "The clipboard is empty.", completion: nil,
                        (.Cancel, "OK", nil)
                    )
                }),
                (.Cancel, "Cancel", nil)
            )
            return
        }
        if let offer = (self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as? ClipsieKit.StoredOffer)?.getOffer() {
            switch offer {
            case .Text(let text):
                if let url = text.asURL {
                    UIApplication.sharedApplication().openURL(url)
                } else {
                    UIPasteboard.generalPasteboard().string = text
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        appDelegate().managedObjectContext.deleteObject(
            self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! NSManagedObject
        )
        try! appDelegate().managedObjectContext.save()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Nearby"
        case 1:
            return "Received"
        default:
            return nil
        }
    }
    
    func configureCell(cell: UITableViewCell, withPeer peer: ClipsieKit.PeerID) {
        cell.textLabel!.text = peer.displayName
    }
    
    func configureCell(cell: UITableViewCell, withOffer storedOffer: ClipsieKit.StoredOffer) {
        if let offer = storedOffer.getOffer() {
            switch offer {
            case .Text(let text):
                cell.textLabel!.text = text
            }
        }
    }
    
    // MARK: - Core data stuff
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, var atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, var newIndexPath: NSIndexPath?) {
        indexPath = indexPath != nil ? NSIndexPath(forRow: indexPath!.row, inSection: 1) : nil
        newIndexPath = newIndexPath != nil ? NSIndexPath(forRow: newIndexPath!.row, inSection: 1) : nil
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withOffer: anObject as! ClipsieKit.StoredOffer)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    // MARK: - ClipsieKit.BrowserDelegate
    
    func foundPeer(peer: PeerID) {
        peers.append(peer)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: peers.count - 1, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func lostPeer(peer: PeerID) {
        let index = peers.indexOf(peer)!
        peers.removeAtIndex(index)
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
    }
    
}
