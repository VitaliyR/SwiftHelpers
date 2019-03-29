import UIKit

public extension UIView {
    static var defaultBorderColor: UIColor = .black
    
    @IBInspectable var cornerRadius: CGFloat {
        set { layer.cornerRadius = newValue  }
        get { return layer.cornerRadius }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor  }
        get { return layer.borderColor?.uiColor }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        set { layer.shadowOffset = newValue  }
        get { return layer.shadowOffset }
    }
    
    @IBInspectable var shadowOpacity: Float {
        set { layer.shadowOpacity = newValue }
        get { return layer.shadowOpacity }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        set {  layer.shadowRadius = newValue }
        get { return layer.shadowRadius }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        set { layer.shadowColor = newValue?.cgColor }
        get { return layer.shadowColor?.uiColor }
    }
    
    @IBInspectable var _clipsToBounds: Bool {
        set { clipsToBounds = newValue }
        get { return clipsToBounds }
    }
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    enum BorderDirection: String {
        case top, bottom
        case all = ""
    }
    
    private func getBorderLayerName(for direction: BorderDirection) -> String {
        let directionName = direction.rawValue.count > 0 ? "-\(direction.rawValue)" : ""
        return "border\(directionName)"
    }
    
    func addBorder(_ direction: BorderDirection = .all, color: UIColor? = nil, height: CGFloat = 1) {
        let layerName = getBorderLayerName(for: direction)
        let newBorder = layer.sublayers?.filter { $0.name == layerName }.first ?? CALayer()
        let posY = direction == .top ? 0 : (frame.height - height)
        
        newBorder.frame = CGRect(x: 0, y: posY, width: frame.size.width, height: height)
        newBorder.backgroundColor = color?.cgColor ?? UIView.defaultBorderColor.cgColor
        newBorder.name = layerName
        
        layer.addSublayer(newBorder)
    }
    
    func updateBorders() {
        let borders = layer.sublayers?.filter { $0.name?.starts(with: "border") ?? false }
        borders?.forEach {
            let directionString = $0.name!.replacingOccurrences(of: "border-?", with: "", options: [.regularExpression], range: $0.name!.range(of: $0.name!))
            if let direction = BorderDirection(rawValue: directionString) {
                addBorder(direction, color: $0.backgroundColor?.uiColor ?? .black, height: $0.frame.height)
            }
        }
    }
    
    func removeBorder(_ direction: BorderDirection) {
        let borderLayer = layer.sublayers?.filter { $0.name == getBorderLayerName(for: direction) }.first
        borderLayer?.removeFromSuperlayer()
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func doLayout(_ animated: Bool = false, completion: (() -> Void)? = nil) {
        if !animated {
            layoutIfNeeded()
            completion?()
        } else if UIView.areAnimationsEnabled {
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            }) { (a) in
                completion?()
            }
        }
    }
    
    class func empty() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = .clear
        return view
    }
}
