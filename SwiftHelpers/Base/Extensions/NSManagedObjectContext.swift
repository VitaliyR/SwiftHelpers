import Foundation
import CoreData

public extension NSManagedObjectContext {
    func get<T: NSManagedObject>(_ object: T?) -> T? {
        guard let object = object else { return nil }
        return self.object(with: object.objectID) as? T
    }
}
