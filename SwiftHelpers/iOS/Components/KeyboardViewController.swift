import UIKit

open class KeyboardViewController: UIViewController {
    @IBOutlet open var scrollView: UIScrollView!
    @IBOutlet var contentViewHeightConstraint: NSLayoutConstraint!
    
    open private(set) var keyboardSize: CGFloat = 0 {
        didSet {
            self.reposition()
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.reposition()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size
        self.keyboardSize = keyboardSize.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboardSize = 0
    }
    
    func reposition() {
        guard let view = scrollView.subviews.first?.subviews.first else { return }
        let viewportWithoutKeyboard = UIScreen.main.bounds.height - keyboardSize
        var inset: UIEdgeInsets!
        
        if view.frame.height > viewportWithoutKeyboard {
            contentViewHeightConstraint.constant = -1 * (UIScreen.main.bounds.height - view.frame.height)
            let bottomInset = keyboardSize > 0 ? keyboardSize - CommonHelpers.safeAreaHeight(.bottom, for: self) : keyboardSize
            inset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        } else {
            let bottomSize = keyboardSize > 0 ? keyboardSize : CommonHelpers.safeAreaHeight(.bottom, for: self)
            contentViewHeightConstraint.constant = -1 * bottomSize
            inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        scrollView.contentInset = inset
        scrollView.scrollIndicatorInsets = getScrollIndicatorInsets(for: inset)
    }
    
    open func getScrollIndicatorInsets(for contentInset: UIEdgeInsets) -> UIEdgeInsets {
        return contentInset
    }
}
