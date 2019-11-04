import UIKit

public class SeparatorView: UIView {}

public class SeparatorContainer: UIView {
    @IBOutlet var separatorView: SeparatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle(for: SeparatorContainer.self).loadNibNamed("SeparatorContainer", owner: self, options: nil)
        
        self.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: self.topAnchor),
            separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separatorView.leftAnchor.constraint(equalTo: self.leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])
        
        self.backgroundColor = Colors.separatorColor
    }
}
