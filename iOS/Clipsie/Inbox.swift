//
//  History.swift
//  Clipsie
//
//  Created by Sidney San Martín on 8/11/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

import UIKit
import CoreData

class InboxViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Offer")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "received", ascending: false)]
        return NSFetchedResultsController(
            fetchRequest: fetchRequest, managedObjectContext: appDelegate().managedObjectContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
    }()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.fetchedResultsController.performFetch(nil)
        self.fetchedResultsController.delegate = self
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - Table view stuff

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.fetchedObjects!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("history", forIndexPath: indexPath) as UITableViewCell
        let offer = self.fetchedResultsController.objectAtIndexPath(indexPath) as ClipsieOffer
        configureCell(cell, withOffer: offer)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let offer = self.fetchedResultsController.objectAtIndexPath(indexPath) as ClipsieOffer
        if let offer = offer as? ClipsieTextOffer {
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = offer.string
        } else if let offer = offer as? ClipsieURLOffer {
            if let urlString = offer.url {
                if let url = NSURL(string: urlString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        appDelegate().managedObjectContext.deleteObject(
            self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        )
        appDelegate().managedObjectContext.save(nil)
    }
    
    func configureCell(cell: UITableViewCell, withOffer offer: ClipsieOffer) {
        cell.textLabel.text = offer.preview
    }
    
    // MARK: - Core data stuff
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: ClipsieOffer, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath)!, withOffer: anObject)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
}
