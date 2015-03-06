import Foundation

private let URLRegex = NSRegularExpression(pattern: "^https?://[^\\s]+$", options: .CaseInsensitive, error: nil)!

extension String {
    func truncate(length: Index.Distance, overflow: String) -> String {
        if length >= count(self) { return self }
        return self[startIndex...advance(startIndex, length-1)] + overflow
    }
    
    var asURL: NSURL? { get {
        if URLRegex.numberOfMatchesInString(self, options: NSMatchingOptions(0), range: NSRange(location: 0, length: count(self))) == 1 {
            if let url = NSURL(string: self) {
                return url
            }
        }
        return nil
    } }
}

func onMainThread(closure: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), closure)
}