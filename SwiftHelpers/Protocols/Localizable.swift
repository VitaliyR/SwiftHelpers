import UIKit

public extension UIView {
    private static let localizableControllerAssociation = ObjectAssociation<String>()
    
    @IBInspectable var localizableControllerKey: String? {
        get {
            return UIView.localizableControllerAssociation[self]
        }
        set {
            UIView.localizableControllerAssociation[self] = newValue?.uppercased()
        }
    }
    
    func findLocalizableControllerKey() -> String? {
        return localizableControllerKey ?? superview?.findLocalizableControllerKey()
    }
}

public protocol Localizable {
    var localizableKey: String? { get set }
}

public extension Localizable where Self:UIView {
    func getTranslation(_ key: String?) -> String? {
        guard let key = key?.uppercased() else { return nil }
        let translation = key.localized
        if translation != key {
            return translation
        }
        return UIViewController.getTranslation(key, controller: findLocalizableControllerKey() ?? findViewController())
    }
}

extension UILabel: Localizable {
    @IBInspectable public var localizableKey: String? {
        get { return nil }
        set(key) {
            DispatchQueue.main.async {
                self.text = self.getTranslation(key)
            }
        }
    }
}

extension UITextView: Localizable {
    @IBInspectable public var localizableKey: String? {
        get { return nil }
        set(key) {
            DispatchQueue.main.async {
                self.attributedText = self.getTranslation(key)?.html
            }
        }
    }
}

extension UIBarItem: Localizable {
    @IBInspectable public var localizableKey: String? {
        get { return nil }
        set(key) {
            DispatchQueue.main.async {
                self.title = key?.uppercased().localized
            }
        }
    }
}

extension UIButton: Localizable {
    @IBInspectable public var localizableKey: String? {
        get { return nil }
        set(key) {
            DispatchQueue.main.async {
                self.setTitle(self.getTranslation(key), for: .normal)
            }
        }
    }
}

extension UITextField: Localizable {
    @IBInspectable public var localizableKey: String? {
        get { return nil }
        set(key) {
            DispatchQueue.main.async {
                self.placeholder = self.getTranslation(key)
            }
        }
    }
}
