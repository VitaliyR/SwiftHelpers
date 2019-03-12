import Foundation

public enum CollectionPosition {
    case first, middle, last
    
    public init(_ current: Int, total: Int) {
        if current == 0 {
            self = .first
        } else if current == total - 1 {
            self = .last
        } else {
            self = .middle
        }
    }
}
