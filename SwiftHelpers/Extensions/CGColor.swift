import UIKit

public extension CGColor {
    var uiColor: UIColor {
        return UIColor(cgColor: self)
    }
}
