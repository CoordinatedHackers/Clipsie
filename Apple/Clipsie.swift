import MultipeerConnectivity
import CoreData

let serviceType = "clipsie"

class ClipsiePeer: Hashable, Equatable {
    class OutboundSessionDelegate: NSObject, MCSessionDelegate {
        var holdSelf: OutboundSessionDelegate? = nil
        let holdSession: MCSession
        let data: NSData
        let completion: (Bool) -> ()
        
        init(_ session: MCSession, _ data: NSData, completion: (Bool) -> ()) {
            self.holdSession = session
            self.data = data
            self.completion = completion
            super.init()
            holdSelf = self
        }
        
        private func finish(success: Bool) {
            holdSelf = nil
            holdSession.delegate = nil
            completion(success)
        }
        
        func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
            switch state {
            case .NotConnected:
                finish(false)
            case .Connecting:
                break
            case .Connected:
                finish(session!.sendData(data, toPeers: [peerID], withMode: .Reliable, error: nil))
            }
        }
        
        func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {}
        func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {}
        func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {}
        func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {}
    }
    
    let browser: MCNearbyServiceBrowser
    let theirPeerID: MCPeerID
    init(_ browser: MCNearbyServiceBrowser, _ theirPeerID: MCPeerID) {
        self.browser = browser
        self.theirPeerID = theirPeerID
    }
    
    func send(offer: ClipsieOffer, completion: ((Bool) -> ())? = nil) {
        let session = MCSession(peer: browser.myPeerID, securityIdentity: nil, encryptionPreference: .Required)
        session.delegate = OutboundSessionDelegate(session, offer.data) {
            if completion != nil { completion!($0) }
        }
        browser.invitePeer(theirPeerID, toSession: session, withContext: nil, timeout: 30)
    }
    
    // MARK: Hashable
    
    var hashValue: Int {
        get { return theirPeerID.hashValue }
    }
    
}

func ==(lhs: ClipsiePeer, rhs: ClipsiePeer) -> Bool {
    return lhs.theirPeerID == rhs.theirPeerID
}

protocol ClipsieAdvertiserDelegate {
    var managedObjectContext: NSManagedObjectContext { get }
    func gotOffer(offer: ClipsieOffer)
}

protocol ClipsieBrowserDelegate {
    func foundPeer(peer: ClipsiePeer)
    func lostPeer(peer: ClipsiePeer)
}

class ClipsieAdvertiser: NSObject, MCNearbyServiceAdvertiserDelegate {
    class InboundSessionDelegate: NSObject, MCSessionDelegate {
        var holdSelf: InboundSessionDelegate? = nil
        let holdSession: MCSession
        let managedObjectContext: NSManagedObjectContext
        let completion: (ClipsieOffer) -> ()
        
        init(_ session: MCSession, _ managedObjectContext: NSManagedObjectContext, completion: (ClipsieOffer) -> ()) {
            holdSession = session
            self.managedObjectContext = managedObjectContext
            self.completion = completion
            super.init()
            holdSelf = self
        }
        
        private func finish(offer: ClipsieOffer?) {
            holdSession.delegate = nil
            holdSelf = nil
            if let offer = offer { completion(offer) }
        }
        
        func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
            if state == .NotConnected {
                finish(nil)
            }
        }
        
        func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
            if let offer = ClipsieOffer.fromData(data, managedObjectContext) {
                offer.received = NSDate()
                offer.senderName = peerID.displayName
                finish(offer)
            } else { finish(nil) }
        }
        
        // Possibly fix some failures to connect: http://stackoverflow.com/a/19696074/84745
        // At some point we should poke this to make sure it's necessary
        func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
            certificateHandler(true)
        }
        
        func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {}
        func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {}
        func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {}
    }
    
    let advertiser: MCNearbyServiceAdvertiser
    var delegate: ClipsieAdvertiserDelegate? = nil
    
    init(_ peerID: MCPeerID) {
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: ["v": "1"], serviceType: serviceType)
        super.init()
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }
    
    func start() { advertiser.startAdvertisingPeer() }
    func stop() { advertiser.stopAdvertisingPeer() }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        let session = MCSession(peer: advertiser.myPeerID, securityIdentity: nil, encryptionPreference: .Required)
        session.delegate = InboundSessionDelegate(session, delegate!.managedObjectContext) {
            self.delegate?.gotOffer($0)
            return
        }
        invitationHandler(true, session)
    }
}

class ClipsieBrowser: NSObject, MCNearbyServiceBrowserDelegate {
    let browser: MCNearbyServiceBrowser
    var peers = [MCPeerID: ClipsiePeer]()
    var delegate: ClipsieBrowserDelegate? = nil
    
    init(_ peerID: MCPeerID) {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        super.init()
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
    
    func start() { browser.startBrowsingForPeers() }
    func stop() { browser.stopBrowsingForPeers() }

    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        let peer = ClipsiePeer(browser, peerID)
        peers[peerID] = peer
        delegate?.foundPeer(peer)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        let peer = peers[peerID]
        if let peer = peer {
            peers[peerID] = nil
            delegate?.lostPeer(peer)
        }
    }
}