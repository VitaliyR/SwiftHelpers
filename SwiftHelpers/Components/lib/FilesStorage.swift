import UIKit

open class FilesStorage: NSObject {
    public typealias StorageType = String
    
    private static var instances: [StorageType: FilesStorage] = [:]
    public static func getInstance(storageType: StorageType) -> FilesStorage {
        if let instance = instances[storageType] {
            return instance
        } else {
            instances[storageType] = FilesStorage(storageType: storageType)
            return instances[storageType]!
        }
    }
    
    private let fileManager: FileManager = FileManager.default
    private let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let storageType: StorageType
    
    public init(storageType: StorageType) {
        self.storageType = storageType
    }
    
    private func getFolder() -> URL {
        let url = documentsFolder.appendingPathComponent(storageType)
        var isDir = ObjCBool(true)
        if !fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            } catch {
            }
        }
        return url
    }
    
    public func save(image: UIImage, name: String) -> String? {
        let fileUrl = getFolder().appendingPathComponent(name)
        if fileManager.fileExists(atPath: fileUrl.path) {
            do {
                try fileManager.removeItem(at: fileUrl)
            } catch {
                return nil
            }
        }
        if let data = UIImagePNGRepresentation(image) {
            do {
                try data.write(to: fileUrl)
                return fileUrl.lastPathComponent
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public func load(name: String) -> UIImage? {
        let fileUrl = getFolder().appendingPathComponent(name)
        if exists(name: name) {
            return UIImage(contentsOfFile: fileUrl.path)
        }
        return nil
    }
    
    public func exists(name: String) -> Bool {
        let fileUrl = getFolder().appendingPathComponent(name)
        return fileManager.fileExists(atPath: fileUrl.path)
    }
    
    public func remove(name: String) {
        let fileUrl = getFolder().appendingPathComponent(name)
        if fileManager.fileExists(atPath: fileUrl.path) {
            do {
                try fileManager.removeItem(at: fileUrl)
            } catch {
            }
        }
    }
    
    public func removeAll(confirm: Bool) {
        guard confirm else { return }
        
        do {
            try fileManager.removeItem(at: getFolder())
        } catch {}
    }
    
    public func move(name: String, another storage: FilesStorage) {
        let fileUrl = getFolder().appendingPathComponent(name)
        let newUrl = storage.getFolder().appendingPathComponent(name)
        
        if fileManager.fileExists(atPath: fileUrl.path) && !fileManager.fileExists(atPath: newUrl.path) {
            do {
                try fileManager.moveItem(at: fileUrl, to: newUrl)
            } catch {}
        }
    }
}