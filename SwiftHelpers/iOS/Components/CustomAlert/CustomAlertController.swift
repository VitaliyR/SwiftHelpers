import UIKit

public class CustomAlertController: UIViewController {
    public enum Style: String {
        case alert = "alertController"
        case actionSheet = "actionSheetController"
    }
    
    @IBOutlet var alertView: AlertView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var buttonsStackView: UIStackView!
    @IBOutlet var buttonsScrollView: UIScrollView! // TODO: add scroll view to alert (style == .alert)
    
    internal static var alertQueue = [CustomAlertController]() {
        didSet {
            if alertQueue.count < oldValue.count { // item has been removed
                guard let alertToShow = alertQueue.first else {
                    isAnyAlertShowing = false
                    return
                }
                alertToShow.present()
            } else if alertQueue.count >= 2 {
                isAnyAlertShowing = true
            }
        }
    }
    private static var isAnyAlertShowing = false
    
    private weak var rootController: UIViewController?
    private var animatedShowing: Bool?
    private var completionHandler: (() -> Void)?
    
    private var alertStyle: Style!
    public var alertTitle: String?
    public var alertMessage: String?
    public private(set) var actions = [AlertAction]()
    private var buttonsStackViewAxis: NSLayoutConstraint.Axis {
        guard alertStyle == .alert else { return .vertical }
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
    private var actionButtonHeight: CGFloat {
        switch alertStyle {
        case .alert:
            return 44
        case .actionSheet:
            return 57
        default:
            fatalError()
        }
    }
    
    
    // MARK: alert style
    @IBOutlet var textFieldsStackView: UIStackView!
    @IBOutlet var alertWidthConstraint: NSLayoutConstraint!
    @IBOutlet var containerBottonConstraint: NSLayoutConstraint!
    
    private var textFieldContainers = [AlertTextFieldContainer]()
    public var textFields: [AlertTextField] {
        return textFieldContainers.map { container in
            return container.textField
        }
    }
    
    
    // MARK: actionSheet style
    @IBOutlet var alertViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var alertViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var footerView: UIView!
    @IBOutlet var cancelActionContainer: UIView!
    
    private var cancelAction: AlertAction?
    private var startPositionAlertView: CGFloat { // need for actionSheet alert start position only
        guard alertViewTopConstraint != nil else { return 0 }
        let top = alertViewTopConstraint.constant
        
        return min( 24 + (alertTitle == nil ? 0 : 16) + (alertMessage == nil ? 0 : 16) + (alertTitle == nil || alertMessage == nil ? 0 : 8) + CGFloat(actions.count) * (actionButtonHeight + 1) + (cancelAction == nil ? 0 : actionButtonHeight + 8), UIScreen.main.bounds.height - top )
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
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let textFieldContainer = textFieldContainers.first {
            textFieldContainer.textField.becomeFirstResponder()
        }
        if buttonsScrollView != nil { // TODO: remove this if statement after adding buttons scroll view to alert (style == .alert)
            buttonsScrollView.delaysContentTouches = buttonsStackView.frame.height != buttonsScrollView.frame.height
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - methods
extension CustomAlertController {
    public static func create(title: String?, message: String?, style: Style) -> CustomAlertController {
        let storyboard = UIStoryboard(name: "CustomAlert", bundle: Bundle(for: CustomAlertController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: style.rawValue) as! CustomAlertController
        
        vc.alertTitle = title
        vc.alertMessage = message
        vc.alertStyle = style
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc
        
        return vc
    }
    
    public func present(via controller: UIViewController, animated: Bool, completionHandler: (() -> Void)? = nil) {
        CustomAlertController.alertQueue.append(self)
        
        if CustomAlertController.isAnyAlertShowing { // save data for showing alert later
            self.rootController = controller
            self.animatedShowing = animated
            self.completionHandler = completionHandler
        } else {
            controller.present(self, animated: animated, completion: completionHandler)
        }
    }
    
    private func present() {
        guard let controller = rootController, let animated = animatedShowing else {
            CustomAlertController.alertQueue.remove(at: 0)
            return
        }
        controller.present(self, animated: animated, completion: completionHandler)
    }
    
    public func addTextField(configurationHandler: (_ textField: AlertTextField) -> Void) {
        let textFieldContainer = AlertTextFieldContainer()
        textFieldContainers.append(textFieldContainer)
        configurationHandler(textFieldContainer.textField)
    }
    
    public func addAction(_ action: AlertAction) {
        action.alertController = self
        
        let existCancelAction = alertStyle == .actionSheet ? cancelAction : (actions.filter { $0.style == .cancel }.first)
        guard existCancelAction == nil else {
            fatalError("Must be only one cancel action.")
        }
        
        switch alertStyle {
        case .alert:
            actions.append(action)
        case .actionSheet:
            if action.style == .cancel {
                cancelAction = action
            } else {
                actions.append(action)
            }
        default:
            fatalError("Alert must have alert style.")
        }
    }
    
    
    // MARK: helpers
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
    
    private func setCancelAction() {
        let isHidden = cancelAction == nil
        
        footerView.isHidden = isHidden
        (footerView.constraints + footerView.superview!.constraints).forEach { constraint in
            if constraint.firstItem as? UIView == footerView || constraint.secondItem as? UIView == footerView {
                constraint.isActive = !isHidden
            }
        }
        
        if let cancelAction = cancelAction {
            cancelActionContainer.subviews.forEach { view in
                view.removeFromSuperview()
            }
            cancelActionContainer.addSubview(cancelAction.buttonContainer)
            cancelAction.buttonContainer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cancelAction.buttonContainer.topAnchor.constraint(equalTo: cancelActionContainer.topAnchor),
                cancelAction.buttonContainer.bottomAnchor.constraint(equalTo: cancelActionContainer.bottomAnchor),
                cancelAction.buttonContainer.leftAnchor.constraint(equalTo: cancelActionContainer.leftAnchor),
                cancelAction.buttonContainer.rightAnchor.constraint(equalTo: cancelActionContainer.rightAnchor)
            ])
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
        
        switch alertStyle {
        case .alert:
            toggleTextFieldsStackView(textFieldContainers.count != 0)
            for textFieldContainer in textFieldsStackView.arrangedSubviews {
                textFieldContainer.removeFromSuperview()
            }
            for textFieldContainer in textFieldContainers {
                textFieldsStackView.addArrangedSubview(textFieldContainer)
            }
        case .actionSheet:
            setCancelAction()
        default:
            fatalError("Alert must have alert style.")
        }
        
        buttonsStackView.axis = buttonsStackViewAxis
        toggleBottomView(actions.count != 0)
        for view in buttonsStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        for index in 0..<actions.count {
            buttonsStackView.addArrangedSubview(actions[index].buttonContainer)
            actions[index].buttonContainer.heightAnchor.constraint(equalToConstant: actionButtonHeight).isActive = true
            
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
    
    func prepareTo(_ action: AlertAnimationController.Action) {
        switch action {
        case .present:
            configure()
            
            view.backgroundColor = .clear
            switch alertStyle {
            case .alert:
                alertView.transform = CGAffineTransform(scaleX: 1.24, y: 1.24)
                alertView.alpha = 0
            case .actionSheet:
                alertView.transform = CGAffineTransform(translationX: 0, y: (startPositionAlertView + alertViewBottomConstraint.constant))
            default:
                fatalError("Alert must have alert style.")
            }
        case .dismiss:
            view.backgroundColor = Colors.backgroundColor
        }
    }
    
    func animateTransition(for action: AlertAnimationController.Action, duration: TimeInterval, completionHandler: @escaping (_ finished: Bool) -> Void) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            switch action {
            case .present:
                self.view.backgroundColor = Colors.backgroundColor
                self.alertView.transform = .identity
                self.alertView.alpha = 1
            case .dismiss:
                self.view.backgroundColor = .clear
                switch self.alertStyle {
                case .alert:
                    self.alertView.alpha = 0
                case .actionSheet:
                    self.alertView.transform = CGAffineTransform(translationX: 0, y: (self.alertView.frame.height + self.alertViewBottomConstraint.constant))
                default:
                    fatalError("Alert must have alert style.")
                }
            }
        }) { finished in
            completionHandler(finished)
        }
    }
}

extension CustomAlertController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertAnimationController(action: .present)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertAnimationController(action: .dismiss)
    }
}
