import UIKit

public extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func localizedPlural(value: CVarArg) -> String {
        return String.localizedStringWithFormat(self.localized, value)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.width
    }
    
    func encode() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    func decode() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression))   // "Mar 22, 2017, 10:22 AM"
    }
    
    var html: NSMutableAttributedString? {
        let wrappedHtml = "<span style=\"font-family: '-apple-system', 'HelveticaNeue';\">\(self)</span>"
        let htmlData = wrappedHtml.data(using: String.Encoding.utf16, allowLossyConversion: false)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        
        return try! NSMutableAttributedString(data: htmlData!, options: options, documentAttributes: nil)
    }
}
