import Foundation

public protocol AdvertiserDelegate {
    func gotOffer(offer: Offer)
}

public class Advertiser: NSObject, NSNetServiceDelegate {
    public var delegate: AdvertiserDelegate? = nil
    public let myPeerID: PeerID
    
    public init(_ myPeerID: PeerID) {
        self.myPeerID = myPeerID
        super.init()
        myPeerID.netService.delegate = self
    }
    
    public func start() {
        myPeerID.netService.publishWithOptions(.ListenForConnections)
    }
    public func stop() {
        myPeerID.netService.stop()
    }
    
    public func netService(sender: NSNetService, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream) {
        InboundSession(inputStream, outputStream).getOffer().then {
            self.delegate?.gotOffer($0)
        }
    }
}