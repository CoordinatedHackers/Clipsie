import Foundation

extension String {
    func truncate(length: Index.Distance, overflow: String) -> String {
        if length >= countElements(self) { return self }
        return self[startIndex...advance(startIndex, length-1)] + overflow
    }
}

func onMainThread(closure: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), closure)
}