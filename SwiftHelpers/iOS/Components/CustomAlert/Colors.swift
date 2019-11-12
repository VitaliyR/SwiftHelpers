import UIKit

public enum Colors {
    public static var separatorColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.2196078431, alpha: 1)
                default:
                    return #colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8470588235, alpha: 1)
                }
            }
        } else {
            return #colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8470588235, alpha: 1)
        }
    }()
    
    public static var backgroundColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.1098039216, alpha: 0.4)
                default:
                    return #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.1098039216, alpha: 0.3)
                }
            }
        } else {
            return #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.1098039216, alpha: 0.3)
        }
    }()
    
    public static var foregroundColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return #colorLiteral(red: 0.1959999949, green: 0.1959999949, blue: 0.1959999949, alpha: 0.200000003)
                default:
                    return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)
                }
            }
        } else {
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)
        }
    }()
    
    public static var textFieldBorderColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2666666667, alpha: 1)
                default:
                    return #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7921568627, alpha: 1)
                }
            }
        } else {
            return #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7921568627, alpha: 1)
        }
    }()
}
