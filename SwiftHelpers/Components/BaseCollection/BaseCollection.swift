import Foundation

public protocol BaseCollectionRequest {
    func cancel()
}

open class BaseCollection<T>: NSObject {
    public typealias DictionaryType = [T]
    public typealias UpdateListenerHandler = (BaseCollection<T>, AppError?) -> Void
    public typealias UpdateStartListenerHandler = (BaseCollection<T>) -> Void
    
    public struct UpdateListener {
        public let persistent: Bool
        public let start: UpdateStartListenerHandler?
        public let complete: UpdateListenerHandler
    }
    
    public var items = DictionaryType()
    public var request: BaseCollectionRequest? {
        didSet {
            guard request != nil else { return }
            updateListeners.forEach { $0.start?(self) }
        }
    }
    
    open func reload() {}
    
    override open var description: String {
        return String(describing: items)
    }
    
    open var isUpdating: Bool {
        return request != nil
    }
    
    public func cancelUpdate() {
        request?.cancel()
    }
    
    public override init() {
        super.init()
        reload()
    }
    
    open func update() {}
    open func save() {}
    
    func forIn(_ handler: (T) -> Bool) -> T? {
        for item in self {
            if handler(item) {
                return item
            }
        }
        return nil
    }
    
    public var updateListeners: [UpdateListener] = []
    public func addUpdateListener(persistent: Bool = false, onStart: UpdateStartListenerHandler? = nil, _ handler: @escaping UpdateListenerHandler) {
        let listener = UpdateListener(persistent: persistent, start: onStart, complete: handler)
        updateListeners.append(listener)
    }
    
    open func notifyUpdated(error: AppError? = nil) {
        updateListeners.forEach { $0.complete(self, error) }
        updateListeners = updateListeners.filter { $0.persistent }
    }
    
    internal func changeItems(items: DictionaryType) {
        self.items = items
    }
    
    internal func getItems() -> [T] {
        return items
    }
}

extension BaseCollection: Collection {
    public typealias Index = DictionaryType.Index
    public typealias Element = DictionaryType.Element
    
    public var startIndex: Index { return items.startIndex }
    public var endIndex: Index { return items.endIndex }
    
    public subscript(index: Index) -> Element {
        get {
            return items[index]
        }
        set {
            items[index] = newValue
            save()
        }
    }
    
    public func makeIterator() -> IndexingIterator<BaseCollection<T>> {
        return IndexingIterator(_elements: self)
    }
    
    public func index(after i: Index) -> Index {
        return items.index(after: i)
    }
    
    func append(_ newElement: T) {
        items.append(newElement)
        save()
    }
    
    func append(contentsOf: [T]) {
        items.append(contentsOf: contentsOf)
        save()
    }
    
    func remove(at: Int) {
        items.remove(at: at)
        save()
    }
    
    public var last: T? {
        return items.last
    }
}
