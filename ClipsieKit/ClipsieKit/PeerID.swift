import Foundation

public class PeerID: Hashable {
    public var displayName: String {
        get { return netService.name }
    }
    
    let netService: NSNetService
    
    public init() {
        netService = NSNetService(
            domain: "", type: CLIPSIE_NS_SERVICE_TYPE, name: "", port: 0
        )
        netService.includesPeerToPeer = true
    }
    
    init(netService: NSNetService) {
        self.netService = netService
    }
    
    // MARK: Hashable
    
    public var hashValue: Int {
        // NSNetServices can't be compared reliably — foundPeer
        // and lostPeer, for instance, return different instances.
        get { return displayName.hashValue }
    }
}

public func ==(lhs: PeerID, rhs: PeerID) -> Bool {
    // See above
    return lhs.displayName == rhs.displayName
}