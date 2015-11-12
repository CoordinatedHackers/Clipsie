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

class HeaderView: UIToolbar {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for view in subviews {
            print("subview: \(view)")
        }
    }
}

class InboxViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
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
        try! self.fetchedResultsController.performFetch()
        self.fetchedResultsController.delegate = self
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return editing ? 1 : 2
    }
    
    // MARK: - Table view stuff

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && !editing {
            return 1
        }
        return self.fetchedResultsController.fetchedObjects!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("history", forIndexPath: indexPath) as UITableViewCell
        let offer = self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! ClipsieKit.StoredOffer
        configureCell(cell, withOffer: offer)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if true || editing {
            return
        }
        if let offer = (self.fetchedResultsController.objectAtIndexPath(indexPath) as? ClipsieKit.StoredOffer)?.getOffer() {
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
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: animated ? .Fade : .None)
        } else {
            tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: animated ? .Fade : .None)
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        appDelegate().managedObjectContext.deleteObject(
            self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
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
    
    func configureCell(cell: UITableViewCell, withOffer storedOffer: ClipsieKit.StoredOffer) {
        if let offer = storedOffer.getOffer() {
            switch offer {
            case .Text(let text):
                cell.textLabel?.text = text
            }
        }
    }
    
    // MARK: - Core data stuff
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withOffer: anObject as! ClipsieKit.StoredOffer)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
}
