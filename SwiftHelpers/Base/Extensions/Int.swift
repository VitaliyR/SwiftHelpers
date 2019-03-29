import Foundation

public extension Int {
    func times(iteration: (Int) -> Void) {
        (0..<self).forEach(iteration)
    }
    
    func times(iteration: () -> Void) {
        (0..<self).forEach { _ in iteration() }
    }
}
