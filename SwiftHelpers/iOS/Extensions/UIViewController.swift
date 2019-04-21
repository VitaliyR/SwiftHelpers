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
    
    @objc open func didBecomeActive() {}
    @objc open func didBackground() {}
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
}
