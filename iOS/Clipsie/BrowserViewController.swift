import UIKit
import CoreData
import ClipsieKit

class BrowserViewController: UITableViewController, ClipsieKit.BrowserDelegate {
    var browser = ClipsieKit.Browser()
    var peers: [ClipsieKit.PeerID] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        browser.delegate = self
        browser.start()
    }
    
    @IBAction func done() {
        if let extensionContext = extensionContext {
            return extensionContext.completeRequestReturningItems(nil, completionHandler: nil)
        }
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    // MARK: Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("peer", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = peers[indexPath.row].displayName
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peers.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let send: String -> () = {
            defer { onMainThread { tableView.cellForRowAtIndexPath(indexPath)?.setSelected(false, animated: true) } }
            let peer = self.peers[indexPath.row]
            guard let session = ClipsieKit.OutboundSession.with(peer) else { return }
            session
                .offerText($0)
                .catchError { print("Failed to send an offer: \($0)") }
        }
        
        let item = (extensionContext!.inputItems.first as! NSExtensionItem).attachments!.first as! NSItemProvider
        
        if item.hasItemConformingToTypeIdentifier("public.url") {
            item.loadItemForTypeIdentifier("public.url", options: nil) { send(($0.0 as! NSURL).absoluteString) }
        } else {
            item.loadItemForTypeIdentifier("public.plain-text", options: nil) { send($0.0 as! String) }
        }
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
