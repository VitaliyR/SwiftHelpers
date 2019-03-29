import UIKit

public extension UITextField {
    enum Side {
        case left, right, both
    }
    
    func addPadding(side: Side, size: CGFloat) {
        let createView = { () -> UIView in
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: self.frame.height))
            paddingView.backgroundColor = .clear
            return paddingView
        }
        
        if side == .both {
            leftViewMode = .always
            rightViewMode = .always
            leftView = createView()
            rightView = createView()
        } else if side == .left {
            leftViewMode = .always
            leftView = createView()
        } else {
            rightViewMode = .always
            rightView = createView()
        }
    }
}
