import UIKit

public protocol LabelsCapableView: class {
    var labels: [UILabel] { get set }
    var labelsContainer: UIView { get }
    func createLabels(numberOfColumns: Int, cellSizes: [CGFloat], cellSpacing: UIEdgeInsets)
}

public extension LabelsCapableView {
    func createLabels(numberOfColumns: Int, cellSizes: [CGFloat], cellSpacing: UIEdgeInsets) {
        if labels.count > numberOfColumns {
            labels.suffix(labels.count - numberOfColumns).forEach { $0.removeFromSuperview() }
            self.labels = Array(labels.prefix(numberOfColumns))
        }
        
        var constraints: [NSLayoutConstraint] = []
        
        for i in 0..<numberOfColumns {
            let label = labels[safe: i] ?? UILabel(frame: .zero)
            let prevLabel = labels[safe: i - 1]
            let hasNext = i + 1 < numberOfColumns
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.lineBreakMode = .byTruncatingTail
            
            let spacingConstant = cellSpacing.left + cellSpacing.right
            
            constraints.append(contentsOf: [
                label.topAnchor.constraint(equalTo: labelsContainer.topAnchor, constant: cellSpacing.top),
                labelsContainer.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: cellSpacing.bottom),
                label.leadingAnchor.constraint(equalTo: prevLabel?.trailingAnchor ?? labelsContainer.leadingAnchor, constant: spacingConstant),
                label.widthAnchor.constraint(lessThanOrEqualToConstant: cellSizes[i])
                ])
            
            if !hasNext {
                constraints.append(labelsContainer.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: spacingConstant))
            }
            
            labelsContainer.addSubview(label)
            if labels.index(of: label) == nil {
                labels.append(label)
            }
        }
        
        NSLayoutConstraint.activate(constraints)
    }
}
