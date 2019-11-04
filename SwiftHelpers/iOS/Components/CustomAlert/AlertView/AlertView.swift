import UIKit

public class AlertView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = Colors.foregroundColor
    }
}

public class AlertBackgroundView: UIView {
    public static var color = Colors.backgroundColor
}
