import UIKit

public class AlertAction {
    public typealias Handler = (_ alertAction: AlertAction) -> Void
    
    public enum Style {
        case `default`, destructive, cancel
    }
    
    weak var alertController: CustomAlertController!
    var style: Style!
    private var handler: Handler?
    public private(set) var buttonContainer = ActionButtonContainer()
    public var isEnabled: Bool = true {
        didSet {
            buttonContainer.actionButton.isEnabled = isEnabled
        }
    }
    
    public init(title: String, style: AlertAction.Style, handler: AlertAction.Handler? = nil) {
        self.style = style
        self.handler = handler
        
        buttonContainer.actionButton.setTitle(title, for: .normal)
        buttonContainer.actionButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        buttonContainer.actionButton.setup(with: style)
    }
    
    @objc private func buttonClicked(_ sender: UIButton) {
        handler?(self)
        alertController.dismiss(animated: true, completion: {
            CustomAlertController.alertQueue.remove(at: 0)
        })
    }
    
    public func setImage(_ image: UIImage) {
        buttonContainer.setImage(image)
    }
}
