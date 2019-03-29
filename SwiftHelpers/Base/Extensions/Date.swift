import Foundation

public extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}
