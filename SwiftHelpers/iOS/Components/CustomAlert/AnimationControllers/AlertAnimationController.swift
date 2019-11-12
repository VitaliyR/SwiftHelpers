import UIKit

class AlertAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    enum Action {
        case present, dismiss
    }
    private let action: Action
    
    init(action: Action) {
        self.action = action
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
            let alertVC = toVC as! CustomAlertController
            
            alertVC.prepareTo(.present)
            
            containerView.addSubview(toVC.view)
            
            alertVC.animateTransition(for: .present, duration: duration) { finished in
                transitionContext.completeTransition(true)
            }
        case .dismiss:
            let alertVC = fromVC as! CustomAlertController
            
            alertVC.prepareTo(.dismiss)
            
            alertVC.animateTransition(for: .dismiss, duration: duration) { finished in
                alertVC.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}
