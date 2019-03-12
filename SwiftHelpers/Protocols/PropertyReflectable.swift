import Foundation

public protocol PropertyReflectable { }

public extension PropertyReflectable {
    subscript(key: String) -> Any? {
        let m = Mirror(reflecting: self)
        let v = m.children.first { $0.label == key }?.value
        guard let value = v else { return nil }
        if case Optional<Any>.none = value {
            return nil
        }
        return CommonHelpers.unwrap(v)
    }
}
