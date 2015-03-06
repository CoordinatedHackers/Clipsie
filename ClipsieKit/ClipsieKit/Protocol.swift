import Foundation

class Protocol {
    
    let supportedVersion: UInt8
    var version: UInt8? = nil
    
    init(_ version: UInt8) {
        supportedVersion = version
    }
    
    var versionLength: Int { get { return sizeofValue(supportedVersion) } }
    
    var versionData: NSData { get {
        var v = version != nil ? version! : supportedVersion
        return NSData(bytes: &v, length: sizeofValue(v))
    } }
    
    var frameCountLength: Int { get { return sizeof(UInt8) } }
    
    var frameLengthLength: Int { get { return sizeof(UInt64) } }
    
    func expectedFrames(frameCountData: NSData) -> UInt8 {
        var frameCount: UInt8 = 0
        frameCountData.getBytes(&frameCount, length: sizeofValue(frameCount))
        return frameCount
    }
    
    func frameLength(frameLengthData: NSData) -> Int {
        var frameLength: UInt64 = 0
        frameLengthData.getBytes(&frameLength, length: sizeofValue(frameLength))
        return Int(frameLength)
    }
    
    func negotiateVersion(versionData: NSData) {
        var theirVersion: UInt8 = 0
        versionData.getBytes(&theirVersion, length: sizeofValue(theirVersion))
        version = min(supportedVersion, theirVersion)
    }
    
    func frameCountData(count: UInt8) -> NSData {
        var c = count
        return NSData(bytes: &c, length: sizeofValue(c))
    }
    
    func frameData(content: NSData) -> NSData {
        var length = UInt64(content.length)
        let frame = NSMutableData(capacity: sizeofValue(length) + content.length)!
        frame.appendBytes(&length, length: sizeofValue(length))
        frame.appendData(content)
        return frame
    }
    
    func frameData(content: String) -> NSData {
        return frameData(content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    }
}