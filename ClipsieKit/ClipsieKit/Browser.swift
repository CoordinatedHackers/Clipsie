import Foundation

public protocol BrowserDelegate {
    func foundPeer(peer: PeerID)
    func lostPeer(peer: PeerID)
}

public class Browser: NSObject, NSNetServiceBrowserDelegate {
    public var delegate: BrowserDelegate? = nil
    
    let myPeerID: PeerID
    let browser: NSNetServiceBrowser
    var peersByName = [String: PeerID]()
    
    public init(_ myPeerID: PeerID) {
        self.myPeerID = myPeerID
        browser = NSNetServiceBrowser()
        super.init()
        browser.delegate = self
    }
    
    public func start() {
        browser.searchForServicesOfType(CLIPSIE_NS_SERVICE_TYPE, inDomain: "local.")
    }
    public func stop() { browser.stop() }
    
    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        let peer = PeerID(netService: aNetService)
        if peer == myPeerID { return }
        self.peersByName[peer.displayName] = peer
        self.delegate?.foundPeer(peer)
    }
    
    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        if let peer = peersByName.removeValueForKey(aNetService.name) {
            delegate?.lostPeer(peer)
        }
    }
}