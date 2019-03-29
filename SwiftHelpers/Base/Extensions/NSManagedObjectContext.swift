import Foundation
import CoreData

public extension NSManagedObjectContext {
    func get<T: NSManagedObject>(_ object: T) -> T? {
        return self.object(with: object.objectID) as? T
    }
}
