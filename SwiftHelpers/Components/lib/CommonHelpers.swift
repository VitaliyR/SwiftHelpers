import UIKit

public class CommonHelpers {
    public static func getVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "\(version).\(build)"
    }
    
    public static func presentMessage(title: String? = nil, message: String? = nil, via controller: UIViewController, handler: (() -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (a) in handler?() }))
        alertVC.preferredAction = alertVC.actions.first
        controller.present(alertVC, animated: true)
    }
    
    public static func getChildControllers(for window: UIWindow) -> [UIViewController] {
        guard let vc = window.rootViewController else { return [] }
        var controllers = [vc]
        controllers.append(contentsOf: getChildControllers(for: vc))
        return controllers
    }
    
    public static func getChildControllers(for controller: UIViewController) -> [UIViewController] {
        var controllers: [UIViewController] = []
        for vc in controller.childViewControllers {
            controllers.append(vc)
            controllers.append(contentsOf: getChildControllers(for: vc))
        }
        return controllers
    }
    
    public static func getChildViews(for view: UIView) -> [UIView] {
        var views: [UIView] = []
        for v in view.subviews {
            views.append(v)
            views.append(contentsOf: getChildViews(for: v))
        }
        return views
    }
    
    public static func getFirstResponder(for controller: UIViewController) -> UIView? {
        return getFirstResponder(for: controller.view)
    }
 
    public static func getFirstResponder(for view: UIView) -> UIView? {
        guard !view.isFirstResponder else { return view }
        for v in getChildViews(for: view) {
            if v.isFirstResponder {
                return v
            }
        }
        return nil
    }
    
    public static func getLabelColor(for backgroundColor: UIColor) -> UIColor {
        let threshold: CGFloat = 105/255
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let bgDelta = (red * 0.299) + (green * 0.587) + (blue * 0.114)
        
        return 1 - bgDelta < threshold ? .black : .white
    }
    
    public static func getIndexForContentSizeCategory(in traitCollection: UITraitCollection) -> Int {
        return getIndexForContentSizeCategory(for: traitCollection.preferredContentSizeCategory)
    }
    
    public static func getIndexForContentSizeCategory(for preferredContentSizeCategory: UIContentSizeCategory) -> Int {
        if #available(iOS 11, *) {
            if preferredContentSizeCategory.isAccessibilityCategory {
                return 6
            }
        }
        
        switch (preferredContentSizeCategory) {
        case UIContentSizeCategory.unspecified, UIContentSizeCategory.extraSmall:
            return 0
        case UIContentSizeCategory.small:
            return 1
        case UIContentSizeCategory.medium:
            return 2
        case UIContentSizeCategory.large:
            return 3
        case UIContentSizeCategory.extraLarge:
            return 4
        case UIContentSizeCategory.extraExtraLarge:
            return 5
        default:
            return 6
        }
    }
    
    public static func getContentSizeCategoryForIndex(_ index: Int) -> UIContentSizeCategory {
        switch index {
        case 0:
            return UIContentSizeCategory.extraSmall
        case 1:
            return UIContentSizeCategory.small
        case 2:
            return UIContentSizeCategory.medium
        case 3:
            return UIContentSizeCategory.large
        case 4:
            return UIContentSizeCategory.extraLarge
        case 5:
            return UIContentSizeCategory.extraExtraLarge
        case 6:
            return UIContentSizeCategory.extraExtraExtraLarge
        default:
            return UIContentSizeCategory.medium
        }
    }
    
    public static func formatDate(_ date: Date, dateTimeDelimiter: String = " ") -> String {
        let isToday = Calendar.current.isDateInToday(date)
        let formatter = DateFormatter()
        formatter.dateFormat = "\(isToday ? "" : "dd.MM\(dateTimeDelimiter)")HH:mm"
        return formatter.string(from: date)
    }
    
    public static func formatTimer(_ interval: TimeInterval, dateTimedelimiter: String = " ") -> String {
        let intervalAbs = abs(interval)
        let days = floor(intervalAbs / 86400)
        let hours = floor(intervalAbs / 3600)
        
        let timeParts = [
            days > 0 ? days : nil,
            hours > 0 ? hours : nil,
            (intervalAbs / 60).truncatingRemainder(dividingBy: 60), // minutes
            intervalAbs.truncatingRemainder(dividingBy: 60) // seconds
            ].compactMap { $0 == nil ? nil : String(format:"%02d", Int(floor($0!))) }
        
        return timeParts.joined(separator: ":")
    }
    
    public static func formatCurrency(count: Double, using sign: String) -> String {
        let priceStr = count.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", count) : String(format: "%.2f", count)
        return priceStr + sign
    }
    
    public static func getSpinner(style: UIActivityIndicatorView.Style = .gray) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.sizeToFit()
        spinner.startAnimating()
        spinner.activityIndicatorViewStyle = style
        return spinner
    }
    
    public static func getSpinnerBarButton(style: UIActivityIndicatorView.Style = .gray) -> UIBarButtonItem {
        return UIBarButtonItem(customView: getSpinner(style: style))
    }
    
    public static func beginRefreshing(in tableView: UITableView) {
        guard let refreshControl = tableView.refreshControl else { return }
        refreshControl.beginRefreshing()
        if tableView.contentOffset.y == 0 {
            UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                tableView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
            })
        }
    }
    
    public static func createTextView(message: NSAttributedString, color: UIColor? = nil) -> UITextView {
        let textView = UITextView(frame: .zero)
        
        textView.backgroundColor = UIColor.clear
        textView.isUserInteractionEnabled = true
        textView.attributedText = message
        textView.textColor = color
        textView.dataDetectorTypes = .all
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isSelectable = true
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 11.5, bottom: 10, right: 11.5)
        textView.bounces = false
        textView.isScrollEnabled = false
        
        return textView
    }
    
    public enum Side {
        case top, bottom
    }
    public static func safeAreaHeight(_ side: Side, for controller: UIViewController) -> CGFloat {
        var margin = side == .top ? controller.topLayoutGuide.length : controller.bottomLayoutGuide.length
        if #available(iOS 11.0, *) {
            margin = side == .top ? controller.view.safeAreaInsets.top : controller.view.safeAreaInsets.bottom
        }
        return margin
    }
    
    public static func checkTableView(_ tableView: UITableView, newIndex: Int?, oldIndex: Int?) {
        if let oldSelectedIndex = oldIndex, let oldCell = tableView.cellForRow(at: IndexPath(row: oldSelectedIndex, section: 0)) {
            oldCell.accessoryType = .none
        }
        if let newSelectedIndex = newIndex, let newCell = tableView.cellForRow(at: IndexPath(row: newSelectedIndex, section: 0)) {
            newCell.accessoryType = .checkmark
        }
    }
    
    public static func getSliderView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        view.clipsToBounds = true
        view.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 30),
            view.heightAnchor.constraint(equalToConstant: 5)
            ])
        return view
    }
    
    public static func constraint(_ view: UIView, to parent: UIView) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: parent.topAnchor),
            view.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
            ])
    }
    
    public static func unwrap<T>(_ any: T) -> Any {
        let mirror = Mirror(reflecting: any)
        guard mirror.displayStyle == .optional, let first = mirror.children.first else {
            return any
        }
        return unwrap(first.value)
    }
}
