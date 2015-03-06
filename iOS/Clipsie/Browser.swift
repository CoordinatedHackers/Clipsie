import UIKit
import CoreData
import ClipsieKit

class BrowserViewController: UITableViewController, ClipsieKit.BrowserDelegate {
    var browser = ClipsieKit.Browser(appDelegate().peerID)
    var peers: [ClipsieKit.PeerID] = []
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        browser.delegate = self
        browser.start()
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    // MARK: Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("peer", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = peers[indexPath.row].displayName
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
                if let pasteboardString = UIPasteboard.generalPasteboard().string {
                    if let session = ClipsieKit.OutboundSession.with(peer) {
                        session.offerText(pasteboardString)
                            .catch { println("Failed to send an offer: \($0)") }
                        return
                    }
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
    
    // MARK: ClipsieKit.BrowserDelegate
    
    func foundPeer(peer: ClipsieKit.PeerID) {
        self.peers.append(peer)
        self.tableView.reloadData()
    }
    
    func lostPeer(peer: ClipsieKit.PeerID) {
        self.peers = self.peers.filter({$0 !== peer})
        self.tableView.reloadData()
    }
}
