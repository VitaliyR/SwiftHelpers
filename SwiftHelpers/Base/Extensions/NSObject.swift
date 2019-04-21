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
    
    func getTranslation(_ key: String, values: [Any] = [], controller: Any? = nil) -> String {
        return NSObject.getTranslation(key, values: values, controller: controller ?? self)
    }
    
    class func getTranslation(_ key: String, values: [Any] = [], controller: Any? = nil) -> String {
        var translationKey: String
        
        if let controllerName = controller as? String {
            translationKey = controllerName
        } else {
            translationKey = getClassNameUnderscored(for: controller ?? self)
        }
        
        let translation = "\(translationKey)_\(key.uppercased())".localized
        return values.count > 0 ? String(format: translation, arguments: values.map { "\($0)" }) : translation
    }
}
