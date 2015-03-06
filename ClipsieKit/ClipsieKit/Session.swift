import Foundation

public class Session {

    private let inStream: NSInputStream
    private let outStream: NSOutputStream
    private let proto = Protocol(0)
    private var fence = Promise<()>.resolve()
    
    private init(_ inStream: NSInputStream, _ outStream: NSOutputStream) {
        inStream.open()
        outStream.open()
        self.inStream = inStream
        self.outStream = outStream
    }
    
    private func read(length: Int) -> Promise<NSData> {
        return self.inStream.read(length)
    }
    
    private func write(data: NSData) -> Promise<()> {
        return self.outStream.write(data)
    }
    
    private func fenced<T>(f: () -> Promise<T>) -> Promise<T> {
        let ret = f()
        fence = ret.then { _ -> () in }
        return ret
    }
    
}

public class OutboundSession: Session {
    
    public override init(_ inStream: NSInputStream, _ outStream: NSOutputStream) {
        super.init(inStream, outStream)
        
        fenced {
            self.write(self.proto.versionData)
                .then { self.read(self.proto.versionLength) }
                .then { self.proto.negotiateVersion($0) }
        }
    }
    
    public func offerText(text: String) -> Promise<()> {
        let frames = map(["textoffer", text], proto.frameData)
        return fenced {
            self.write(self.proto.frameCountData(UInt8(frames.count))).then { () -> Promise<()> in
                var fence = Promise<()>.resolve()
                for frame in frames {
                    fence = fence.then { self.write(frame) }
                }
                return fence
            }
        }
    }
    
    public class func with(peerID: PeerID) -> OutboundSession? {
        var inStream: NSInputStream? = nil
        var outStream: NSOutputStream? = nil
        peerID.netService.getInputStream(&inStream, outputStream: &outStream)
        if let inStream = inStream {
            if let outStream = outStream {
                return OutboundSession(inStream, outStream)
            }
        }
        return nil;
    }
}

public class InboundSession: Session {
    
    var frames = [NSData]()
    
    public override init(_ inStream: NSInputStream, _ outStream: NSOutputStream) {
        super.init(inStream, outStream)
        
        fenced {
            self.read(self.proto.versionLength).then { versionData -> Promise<()> in
                self.proto.negotiateVersion(versionData)
                return self.write(self.proto.versionData)
            }
        }
    }
    
    func getOffer() -> Promise<Offer> {
        return fenced {
            self.read(self.proto.frameCountLength).then { data -> Promise<()> in
                var fence = Promise<()>.resolve()
                for i in 0..<self.proto.expectedFrames(data) {
                    fence = fence.then {
                        self.read(self.proto.frameLengthLength).then {
                            self.read(self.proto.frameLength($0)).then {
                                self.frames.append($0)
                            }
                        }
                    }
                }
                return fence
            }.then { Promise<Offer> { resolve, reject in
                if self.frames.isEmpty {
                    reject(NSError(domain: "ClipsieKitErrorDomain", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "Got an empty message"
                    ]))
                    return
                }
                if let offerType = NSString(data: self.frames[0], encoding: NSUTF8StringEncoding) {
                    switch offerType {
                    case "textoffer":
                        if self.frames.count == 2 {
                            if let text = NSString(data: self.frames[1], encoding: NSUTF8StringEncoding) as? String {
                                resolve(Offer.Text(text))
                                return
                            }
                        }
                    default:
                        reject(NSError(domain: "ClipsieKitErrorDomain", code: 2, userInfo: [
                            NSLocalizedDescriptionKey: "Got a message with an unknown leading frame"
                        ]))
                        return
                    }
                }
                reject(NSError(domain: "ClipsieKitErrorDomain", code: 3, userInfo: [
                    NSLocalizedDescriptionKey: "Got a malformed offer"
                ]))
            } }
        }
    }
    
}