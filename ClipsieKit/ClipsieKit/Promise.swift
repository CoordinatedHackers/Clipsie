import Foundation

private class PromiseHandlers<T> {
    var resolved: [T -> ()] = []
    var rejected: [NSError -> ()] = []
}

private enum PromiseState<T> {
    case Pending(PromiseHandlers<T>)
    case Resolved(() -> T) // Plain T isn't supported by Swift yet
    case Rejected(NSError)
}

public class Promise<T> {
    
    private var state = PromiseState<T>.Pending(PromiseHandlers())
    
    init(setup: (T -> (), NSError -> ()) -> ()) {
        setup(
            { val in
                switch self.state {
                case .Pending(let handlers):
                    self.state = .Resolved({val})
                    for f in handlers.resolved { f(val) }
                default: break
                }
            }, {
                switch self.state {
                case .Pending(let handlers):
                    self.state = .Rejected($0)
                    for f in handlers.rejected { f($0) }
                default: break
                }
            }
        )
    }
    
    public func then<U>(f: T -> Promise<U>) -> Promise<U> {
        return Promise<U> { resolve, reject in
            func forward(val: T) {
                switch f(val).state {
                case .Pending(let handlers):
                    handlers.resolved.append(resolve)
                    handlers.rejected.append(reject)
                case .Resolved(let valFn):
                    resolve(valFn())
                case .Rejected(let err):
                    reject(err)
                }
            }
            switch self.state {
            case .Pending(let handlers):
                handlers.resolved.append(forward)
                handlers.rejected.append(reject)
            case .Resolved(let valFn):
                forward(valFn())
            case .Rejected(let err):
                reject(err)
            }
        }
    }
    
    public func then<U>(f: T -> U) -> Promise<U> {
        return then { val in Promise<U> { resolve, reject in
            resolve(f(val))
        } }
    }
    
    public func catch(f: NSError -> Promise) -> Promise {
        return Promise { resolve, reject in
            func forward(err: NSError) {
                switch f(err).state {
                case .Pending(let handlers):
                    handlers.resolved.append(resolve)
                    handlers.rejected.append(reject)
                case .Resolved(let valFn):
                    resolve(valFn())
                case .Rejected(let err):
                    reject(err)
                }
            }
            switch self.state {
            case .Pending(let handlers):
                handlers.resolved.append(resolve)
                handlers.rejected.append(forward)
            case .Resolved(let valFn):
                resolve(valFn())
            case .Rejected(let err):
                forward(err)
            }
        }
    }
    
    public func catch(f: NSError -> T) -> Promise {
        return catch { err in Promise { resolve, reject in
            resolve(f(err))
        } }
    }
    
    public class func defer() -> (Promise, T -> (), NSError -> ()) {
        var resolve: (T -> ())? = nil
        var reject: (NSError -> ())? = nil
        
        return (Promise {
            resolve = $0
            reject = $1
            }, resolve!, reject!)
    }
    
    public class func resolve(val: T) -> Promise {
        return Promise { resolve, _ in resolve(val) }
    }
    
    public class func reject(err: NSError) -> Promise {
        return Promise { _, reject in reject(err) }
    }
}