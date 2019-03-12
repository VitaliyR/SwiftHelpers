import Foundation
import CoreData

open class BaseDataCollection<T: NSManagedObject>: BaseCollection<T> {
    public var predicate: NSPredicate?
    public var context: NSManagedObjectContext?
    public var sortDescriptors: [NSSortDescriptor] = []
    open var entityName: String {
        return ""
    }
    
    public override convenience init() {
        self.init(nil, context: nil)
    }
    
    public init(_ predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = [], context: NSManagedObjectContext? = nil) {
        super.init()
        self.predicate = predicate
        self.context = context
        self.sortDescriptors = sortDescriptors
        self.reload()
    }
    
    override open func reload() {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        let items = try! context?.fetch(fetchRequest) ?? []
        changeItems(items: items)
    }
    
    var objectIDs: [NSManagedObjectID] {
        return self.map { $0.objectID }
    }
}
