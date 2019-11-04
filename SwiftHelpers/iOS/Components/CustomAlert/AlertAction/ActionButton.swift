import UIKit

class ActionButton: UIButton {
    func setup(with style: AlertAction.Style) {
        setBackgroundColor(#colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.431372549, alpha: 0.1017638644), forState: .highlighted)
        
        titleLabel?.adjustsFontSizeToFitWidth = true
        updateEdgeInsets(hasImage: false)
        switch style {
        case .cancel:
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            fallthrough
        case .destructive:
            setTitleColor(#colorLiteral(red: 0.862745098, green: 0.3137254902, blue: 0.2352941176, alpha: 1), for: .normal)
        default:
            break
        }
        setTitleColor(titleColor(for: .normal)?.withAlphaComponent(0.8), for: .highlighted)
        setTitleColor(titleColor(for: .normal)?.withAlphaComponent(0.4), for: .disabled)
    }
    
    fileprivate func updateEdgeInsets(hasImage: Bool) {
        let inset: CGFloat = hasImage ? 46 : 8
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

public class ActionButtonContainer: UIView {
    @IBOutlet var containerView: UIView!
    @IBOutlet var actionButton: ActionButton!
    @IBOutlet var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle(for: ActionButtonContainer.self).loadNibNamed("ActionButtonContainer", owner: self, options: nil)
        
        self.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.leftAnchor.constraint(equalTo: self.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])
        
        setImage(nil)
        actionButton.setup(with: .default)
    }
    
    func setImage(_ image: UIImage?) {
        if let image = image {
            imageView.isHidden = false
            imageView.image = image
        } else {
            imageView.isHidden = true
        }
        actionButton.updateEdgeInsets(hasImage: image != nil)
    }
}
