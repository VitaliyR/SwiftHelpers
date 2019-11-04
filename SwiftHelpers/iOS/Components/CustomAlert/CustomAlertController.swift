import UIKit

public class CustomAlertController: UIViewController {
    @IBOutlet var alertView: AlertView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var textFieldsStackView: UIStackView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var buttonsStackView: UIStackView!
    @IBOutlet var alertWidthConstraint: NSLayoutConstraint!
    @IBOutlet var containerBottonConstraint: NSLayoutConstraint!
    
    private var textFieldContainers = [AlertTextFieldContainer]()
    public var textFields: [AlertTextField] {
        return textFieldContainers.map { container in
            return container.textField
        }
    }
    
    private var alertTitle: String?
    private var alertMessage: String?
    public private(set) var actions = [AlertAction]()
    
    private var buttonsStackViewAxis: NSLayoutConstraint.Axis {
        if actions.count > 2 { return .vertical }
        
        let separatorsWidth: CGFloat = (actions.count > 0) ? CGFloat(actions.count - 1) : 0
        let alertWidth = alertWidthConstraint?.constant ?? 264
        let buttonWidth: CGFloat = (alertWidth - separatorsWidth) / CGFloat(actions.count)
        let accuracy: CGFloat = 4
        
        for action in actions {
            guard let buttonTitle = action.buttonContainer.actionButton.titleLabel else { return .horizontal }
            
            let titleEdgeInsets = action.buttonContainer.actionButton.titleEdgeInsets
            let possibleWidth = buttonWidth - titleEdgeInsets.left - titleEdgeInsets.right - accuracy
            
            if buttonTitle.intrinsicContentSize.width > possibleWidth {
                return .vertical
            }
        }
        
        return .horizontal
    }
    
    public static func create(title: String?, message: String?) -> CustomAlertController {
        let storyboard = UIStoryboard(name: "CustomAlert", bundle: Bundle(for: CustomAlertController.self))
        let vc = storyboard.instantiateInitialViewController() as! CustomAlertController
        
        vc.alertTitle = title
        vc.alertMessage = message
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc
        
        return vc
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            containerBottonConstraint.constant = keyboardSize.height
            UIView.animate(withDuration: animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        containerBottonConstraint.constant = 0
        if let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.animate(withDuration: animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let textFieldContainer = textFieldContainers.first {
            textFieldContainer.textField.becomeFirstResponder()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func addTextField(configurationHandler: (_ textField: AlertTextField) -> Void) {
        let textFieldContainer = AlertTextFieldContainer()
        textFieldContainers.append(textFieldContainer)
        configurationHandler(textFieldContainer.textField)
    }
    
    public func addAction(_ action: AlertAction) {
        action.alertController = self
        actions.append(action)
    }
    
    private func setTitle(_ title: String?) {
        titleLabel.isHidden = title == nil
        titleLabel.text = title
    }
    
    private func setMessage(_ message: String?) {
        messageLabel.isHidden = message == nil
        messageLabel.text = message
    }
    
    private func addButtonsSeparator() {
        let separator = SeparatorContainer()
        switch buttonsStackView.axis {
        case .horizontal:
            separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        case .vertical:
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        @unknown default:
            fatalError()
        }
        buttonsStackView.addArrangedSubview(separator)
    }
    
    private func toggleTextFieldsStackView(_ isShow: Bool) {
        textFieldsStackView.isHidden = !isShow
        for constraint in textFieldsStackView.superview?.constraints ?? [] where constraint.firstItem as? UIStackView == textFieldsStackView || constraint.secondItem as? UIStackView == textFieldsStackView {
            constraint.isActive = isShow
        }
    }
    
    private func toggleBottomView(_ isShow: Bool) {
        bottomView.isHidden = !isShow
        for constraint in bottomView.superview?.constraints ?? [] where constraint.firstItem as? UIView == bottomView || constraint.secondItem as? UIView == bottomView {
            constraint.isActive = isShow
        }
    }
    
    private func configure() {
        if let title = alertTitle, let message = alertMessage {
            setTitle(title)
            setMessage(message)
        } else if let title = alertTitle {
            setTitle(title)
            setMessage(nil)
        } else if let message = alertMessage {
            setTitle(nil)
            setMessage(message)
        } else {
            fatalError("Must be at least one alert property: title or message.")
        }
        
        toggleTextFieldsStackView(textFieldContainers.count != 0)
        for textFieldContainer in textFieldsStackView.arrangedSubviews {
            textFieldContainer.removeFromSuperview()
        }
        for textFieldContainer in textFieldContainers {
            textFieldsStackView.addArrangedSubview(textFieldContainer)
        }
        
        buttonsStackView.axis = buttonsStackViewAxis
        toggleBottomView(actions.count != 0)
        for view in buttonsStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        for index in 0..<actions.count {
            buttonsStackView.addArrangedSubview(actions[index].buttonContainer)
            
            if index == actions.count - 1 { continue }
            addButtonsSeparator()
        }
        for index in 0..<buttonsStackView.arrangedSubviews.count where index % 2 == 1 {
            let separator = buttonsStackView.arrangedSubviews[index], prevButton = buttonsStackView.arrangedSubviews[index - 1], nextButton = buttonsStackView.arrangedSubviews[index + 1]
            
            switch buttonsStackView.axis {
            case .horizontal:
                separator.leftAnchor.constraint(equalTo: prevButton.rightAnchor).isActive = true
                separator.rightAnchor.constraint(equalTo: nextButton.leftAnchor).isActive = true
            case .vertical:
                separator.topAnchor.constraint(equalTo: prevButton.bottomAnchor).isActive = true
                separator.bottomAnchor.constraint(equalTo: nextButton.topAnchor).isActive = true
            @unknown default:
                fatalError()
            }
        }
        
    }
}

extension CustomAlertController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertAnimationController(action: .present, view: alertView)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertAnimationController(action: .dismiss, view: alertView)
    }
}
