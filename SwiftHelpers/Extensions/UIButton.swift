import UIKit

public extension UIButton {
    private static let assocToggleSpinnerTimer = ObjectAssociation<Timer>()
    
    func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
    
    func toggleSpinner(state: Bool, delayed: Bool = false) {
        UIButton.assocToggleSpinnerTimer[self]?.invalidate()
        isEnabled = !state
        
        if delayed {
            UIButton.assocToggleSpinnerTimer[self] = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (t) in
                self.toggleSpinner(state: state)
            })
            return
        }
        
        titleLabel?.alpha = state ? 0 : 1
        
        let existingSpinners = subviews.filter { $0 is UIActivityIndicatorView }
        
        if state {
            guard existingSpinners.count == 0 else { return }
            let spinner = Helpers.getSpinner()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.color = titleLabel?.textColor
            addSubview(spinner)
            NSLayoutConstraint.activate([
                spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
                ])
        } else {
            existingSpinners.forEach { $0.removeFromSuperview() }
        }
        
        setNeedsLayout()
    }
}
