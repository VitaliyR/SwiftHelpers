import UIKit

class AlertAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    enum Action {
        case present, dismiss
    }
    private let action: Action
    private let alertView: AlertView
    
    init(action: Action, view: AlertView) {
        self.action = action
        self.alertView = view
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.24
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        switch action {
        case .present:
            toVC.view.backgroundColor = .clear
            alertView.transform = CGAffineTransform(scaleX: 1.24, y: 1.24)
            alertView.alpha = 0
            containerView.addSubview(toVC.view)
            
            UIView.animate(withDuration: duration, animations: {
                toVC.view.backgroundColor = AlertBackgroundView.color
                self.alertView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.alertView.alpha = 1
            }) { _ in
                transitionContext.completeTransition(true)
            }
        case .dismiss:
            fromVC.view.backgroundColor = AlertBackgroundView.color
            UIView.animate(withDuration: duration, animations: {
                fromVC.view.backgroundColor = .clear
                self.alertView.alpha = 0
            }) { _ in
                fromVC.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}
