import UIKit

extension UIViewController: BackgroundCapable {
    private static let associationBackgroundTaskIdentifier = ObjectAssociation<UIBackgroundTaskIdentifier>()
    
    public var backgroundTask: UIBackgroundTaskIdentifier? {
        get {
            return UIViewController.associationBackgroundTaskIdentifier[self]
        }
        set {
            UIViewController.associationBackgroundTaskIdentifier[self] = newValue
        }
    }
    
    @objc open var registerBackgroundTask: Bool {
        return false
    }
}

public extension UIViewController {
    func removeChild(_ controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        controller.didMove(toParent: nil)
    }
    
    @objc func doLayout(_ animated: Bool = false, completion: (() -> Void)? = nil) {
        view.doLayout(animated, completion: completion)
    }
    
    var controllerName: String {
        return UIViewController.getClassName(for: self)
    }
    
    func getTranslation(_ key: String, values: [Any] = [], controller: Any? = nil) -> String {
        return UIViewController.getTranslation(key, values: values, controller: controller ?? self)
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
