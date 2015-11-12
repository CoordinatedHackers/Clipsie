import Foundation

private let URLRegex = try! NSRegularExpression(pattern: "^https?://[^\\s]+$", options: .CaseInsensitive)

extension String {
    func truncate(length: Index.Distance, overflow: String) -> String {
        if length >= characters.count { return self }
        return self[startIndex...startIndex.advancedBy(length-1)] + overflow
    }
    
    var asURL: NSURL? { get {
        if URLRegex.numberOfMatchesInString(self, options: NSMatchingOptions(rawValue: 0), range: NSRange(location: 0, length: characters.count)) == 1 {
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