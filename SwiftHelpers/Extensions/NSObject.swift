import Foundation

fileprivate typealias `Self` = NSObject

public extension NSObject {
    class func getClassName(for object: Any) -> String {
        return String(describing: type(of: object))
            .components(separatedBy: ".")
            .compactMap { $0 != "Type" ? $0 : nil }
            .last!
    }
    
    class func getClassNameUnderscored(for object: Any) -> String {
        let className = getClassName(for: object)
        return className
            .replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression, range: className.range(of: className))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
            .uppercased()
    }
    
    func getClassName() -> String {
        return Self.getClassName(for: self)
    }
    
    func getClassNameUnderscored() -> String {
        return Self.getClassNameUnderscored(for: self)
    }
}
