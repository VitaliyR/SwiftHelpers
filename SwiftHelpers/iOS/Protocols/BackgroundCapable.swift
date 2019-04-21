import UIKit

public protocol BackgroundCapable: class {
    var backgroundTask: UIBackgroundTaskIdentifier? { get set }
    var registerBackgroundTask: Bool { get }
    func didBackground()
    func didBecomeActive()
}

public extension BackgroundCapable {
    func cancelBackgroundTask() {
        DispatchQueue.main.async {
            if self.backgroundTask != UIBackgroundTaskIdentifier.invalid && self.backgroundTask != nil {
                UIApplication.shared.endBackgroundTask(self.backgroundTask!)
                self.backgroundTask = UIBackgroundTaskIdentifier.invalid
            }
        }
    }
    
    func willBackground(_ notification: Notification) {
        if !registerBackgroundTask { return }
        self.backgroundTask = UIApplication.shared.beginBackgroundTask(withName: NSObject.getClassNameUnderscored(for: self)) {
            self.cancelBackgroundTask()
        }
        didBackground()
    }
    
    func becomeActive(_ notification: Notification) {
        cancelBackgroundTask()
        didBecomeActive()
    }
    
    func toggleBackgroundStateObservers(state: Bool) {
        if state {
            NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] (notification) in
                if self == nil { return }
                self!.willBackground(notification)
            }
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] (notification) in
                if self == nil { return }
                self!.becomeActive(notification)
            }
        } else {
            NotificationCenter.default.removeObserver(self)
            cancelBackgroundTask()
        }
    }
}
