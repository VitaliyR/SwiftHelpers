import Foundation

public extension Array {
    subscript(safe range: Range<Index>) -> [Element] {
        guard
            range.startIndex >= self.startIndex,
            range.endIndex <= self.endIndex
            else {
                return []
        }
        
        return Array(self[range])
    }
    
    __consuming func suffix(fromSafe start: Int) -> ArraySlice<Element> {
        guard start < count else  { return [] }
        return self.suffix(from: start)
    }
}
