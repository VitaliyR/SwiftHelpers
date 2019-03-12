import Foundation

fileprivate typealias `Self` = AppError

open class AppError: NSError {
    let message: String
    
    public init(code: Int = 0, message: String, userInfo: [String: Any]? = nil) {
        self.message = message
        super.init(domain: Self.getClassName(for: Self.self), code: code, userInfo: userInfo)
    }
    
    public convenience init(error: Error) {
        self.init(code: 0, message: error.localizedDescription, userInfo: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.message = ""
        super.init(coder: aDecoder)
    }
    
    var localizedMessage: String {
        let msg = "\(getClassNameUnderscored())_\(message.uppercased())"
        return msg.localized != msg ? msg.localized : msg
    }
}

