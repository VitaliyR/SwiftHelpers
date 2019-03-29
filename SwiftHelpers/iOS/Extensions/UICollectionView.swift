import UIKit

public extension UICollectionView {
    func messageForEmptyState(_ message: String?) {
        guard let message = message else { backgroundView = nil; return }
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.bounds.size.width, height: self.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        
        backgroundView = messageLabel
    }
}
