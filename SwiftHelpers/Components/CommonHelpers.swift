import Foundation

public class CommonHelpers {
    public static func getVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "\(version).\(build)"
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
    
    public static func unwrap<T>(_ any: T) -> Any {
        let mirror = Mirror(reflecting: any)
        guard mirror.displayStyle == .optional, let first = mirror.children.first else {
            return any
        }
        return unwrap(first.value)
    }
}
