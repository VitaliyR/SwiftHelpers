import Foundation

public extension NSObject {
    class func getClassName(for object: Any) -> String {
        return String(describing: type(of: object))
            .components(separatedBy: ".")
            .compactMap { $0 != "Type" ? $0 : nil }
            .last!
    }
    
    class func getClassNameUnderscored(for object: Any) -> String {
        let className = getClassName(for: object)
        return className.snakeCase.uppercased()
    }
    
    func getClassName() -> String {
        return NSObject.getClassName(for: self)
    }
    
    func getClassNameUnderscored() -> String {
        return NSObject.getClassNameUnderscored(for: self)
    }
}
