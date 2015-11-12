import Foundation

private class StreamInterface: NSObject, NSStreamDelegate {
    
    var holdSelf: StreamInterface? = nil
    let stream: NSStream
    
    init(_ stream: NSStream) {
        self.stream = stream
        super.init()
        holdSelf = self
        stream.delegate = self
        stream.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func finish(cb: () -> ()) {
        stream.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        stream.delegate = nil
        cb()
        self.holdSelf = nil
    }
}

private func connectionClosedError(message: String) -> NSError {
    return NSError(domain: "ClipsieKitStreamExtensionsErrorDomain", code: 0, userInfo:[
        NSLocalizedDescriptionKey: message
    ])
}

extension NSInputStream {
    func read(length: Int) -> Promise<NSData> {
        class StreamReader: StreamInterface {
            
            let inputStream: NSInputStream
            let data: NSMutableData
            var pos: Int = 0
            let promise: Promise<NSData>
            let resolve: NSData -> ()
            let reject: NSError -> ()
            
            init(stream: NSInputStream, length: Int) {
                inputStream = stream
                data = NSMutableData(length: length)!
                (promise, resolve, reject) = Promise<NSData>.new()
                super.init(stream)
            }
            
            @objc func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
                switch(eventCode) {
                case NSStreamEvent.OpenCompleted:
                    break
                case NSStreamEvent.HasBytesAvailable:
                    let bytesRead = inputStream.read(UnsafeMutablePointer<UInt8>(data.mutableBytes) + pos, maxLength: data.length - pos)
                    if bytesRead >= 0 {
                        pos += bytesRead
                        if pos == data.length { finish { self.resolve(self.data) } }
                    }
                case NSStreamEvent.ErrorOccurred:
                    finish { self.reject(aStream.streamError!) }
                case NSStreamEvent.EndEncountered:
                    finish { self.reject(connectionClosedError("The connection was closed while reading.")) }
                default:
                    NSLog("Unhandled read stream event, \(eventCode)")
                }
            }
        }
        
        return StreamReader(stream: self, length: length).promise
    }
}

extension NSOutputStream {
    func write(data: NSData) -> Promise<()> {
        class StreamWriter: StreamInterface {
            
            let outputStream: NSOutputStream
            let data: NSData
            var pos: Int = 0
            let promise: Promise<()>
            let resolve: () -> ()
            let reject: NSError -> ()
            
            init(stream: NSOutputStream, data: NSData) {
                outputStream = stream
                self.data = data
                (promise, resolve, reject) = Promise<()>.new()
                super.init(stream)
            }
            
            @objc func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
                switch(eventCode) {
                case NSStreamEvent.OpenCompleted:
                    break
                case NSStreamEvent.HasSpaceAvailable:
                    let bytesWritten = outputStream.write(UnsafeMutablePointer<UInt8>(data.bytes) + pos, maxLength: data.length - pos)
                    if bytesWritten >= 0 {
                        pos += bytesWritten
                        if pos == data.length { finish { self.resolve() } }
                    }
                case NSStreamEvent.ErrorOccurred:
                    finish { self.reject(aStream.streamError!) }
                case NSStreamEvent.EndEncountered:
                    finish { self.reject(connectionClosedError("The connection was closed while writing.")) }
                default:
                    NSLog("Unhandled write stream event, \(eventCode)")
                }
            }
        }
        
        return StreamWriter(stream: self, data: data).promise
    }
}