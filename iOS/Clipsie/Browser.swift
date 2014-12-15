import UIKit
import CoreData

class BrowserViewController: UITableViewController, ClipsieBrowserDelegate {
    var browser = ClipsieBrowser(appDelegate().peerID)
    var peers = [ClipsiePeer]()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        browser.delegate = self
        browser.start()
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    // MARK: Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("peer", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = peers[indexPath.row].theirPeerID.displayName
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peers.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        let peer = self.peers[indexPath.row]
        
        
        showAlert(self, style: .ActionSheet, sourceView: cell, completion: {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        },
            (.Default, "Send clipboard", {
                // Use a temporary managed object context. Right now we don't care about saving sent offers
                let managedObjectContext = NSManagedObjectContext()
                managedObjectContext.parentContext = appDelegate().managedObjectContext
                if let offer = ClipsieOffer.offerWithClipboard(managedObjectContext) {
                    peer.send(offer)
                    return
                }
                // TODO: Handle this more gracefully, e.g. by disabling sending if nothing's on your clipboard
                showAlert(self, title: "Nothing to send", message: "The clipboard is empty.", completion: nil,
                    (.Cancel, "OK", nil)
                )
                self.dismiss()
            }),
            (.Cancel, "Cancel", nil)
        )
    }
    
    // MARK: ClipsieBrowser delegate
    
    func foundPeer(peer: ClipsiePeer) {
        self.peers.append(peer)
        self.tableView.reloadData()
    }
    
    func lostPeer(peer: ClipsiePeer) {
        self.peers = self.peers.filter({$0 !== peer})
        self.tableView.reloadData()
    }
}
