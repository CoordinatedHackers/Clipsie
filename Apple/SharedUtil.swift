extension String {
    func truncate(length: Index.Distance, overflow: String) -> String {
        if length >= countElements(self) { return self }
        return self[startIndex...advance(startIndex, length-1)] + overflow
    }
}