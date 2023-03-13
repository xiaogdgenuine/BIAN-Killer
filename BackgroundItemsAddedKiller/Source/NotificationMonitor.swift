//
//  NotificationMonitor.swift
//  BackgroundItemsAddedKiller
//
//  Created by xiaogd on 2023/2/20.
//

import AppKit
import AXSwift

class NotificationMonitor: ObservableObject {

    var observer: Observer?
    var scheduledClean: DispatchWorkItem?
    var sequence: TimedSequence<AXUIElement>?
    var isRunning = false
    var descriptions:[String]{
      get { getDescriptions() }
      set {
        UserDefaults.standard.setValue(newValue, forKey: descriptionsOfNotification)
      }
    }

    @discardableResult
    func setup() -> Bool {
        guard !isRunning,
              UIElement.isProcessTrusted(withPrompt: true) else {
            return false
        }

        if !monitorNewNotifications() {
            return false
        }

        isRunning = true
        
        clearNotifications()

        return true
    }

    func cleanup() {
        observer?.stop()
        scheduledClean?.cancel()
        isRunning = false
    }

}

private extension NotificationMonitor {

    func monitorNewNotifications() -> Bool {
        guard let process = Application.allForBundleID(notificationCenterBundleId).first,
              let processId = try? process.pid() else {
            return false
        }

        do {
            observer = try Observer(processID: processId) { [weak self] ob, element, notification in
                guard let self = self else { return }

                self.scheduledClean?.cancel()
                self.scheduledClean = DispatchWorkItem {
                    self.clearNotifications()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: self.scheduledClean!)
            }
            try observer?.addNotification(.layoutChanged, forElement: UIElement(process.element))
            try observer?.addNotification(.windowCreated, forElement: UIElement(process.element))
            try observer?.addNotification(.created, forElement: UIElement(process.element))

            observer?.start()

            return true
        } catch {
            print(error)
            return false
        }
    }

    func clearNotifications() {
        observer?.stop()

        let screenHeight = NSScreen.main?.frame.height ?? 0
        let mouseLocation = NSEvent.mouseLocation
        let restorePoint = CGPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)

        func finishBatch() {
            print("Handle next batch.")
            observer?.start()
            let moveBackEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: restorePoint, mouseButton: .left)
            moveBackEvent?.post(tap: .cghidEventTap)
            print("restore originalPoint", restorePoint)
        }

        guard let process = Application.allForBundleID(notificationCenterBundleId).first else {
            finishBatch()
            return
        }

        guard let loginItemElements = (NotificationMonitor.getSubElements(root: process.element) {
            let description: String? = try? UIElement($0).attribute(.description)

          return descriptions.contains{ $0 == description }
        }) else {
            return finishBatch()
        }

        // Dismiss notification items from tail to head so the y offset of all items won't shift.
        let itemsToBeDismiss = loginItemElements.reversed()
        let lastItem = itemsToBeDismiss.last

        if itemsToBeDismiss.isEmpty {
            return finishBatch()
        }

        sequence = TimedSequence(array: loginItemElements.reversed(), interval: 0.3) { item in
            let element = UIElement(item)

            if item == lastItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    finishBatch()
                }
            }

            guard let origin: CGPoint = try? element.attribute(.position) else {
                return
            }

            // Move mouse to a notification
            let closeNotificationBtnTriggerPoint = CGPoint(x: origin.x + 10, y: origin.y + 10)
            let moveToCloseBtnEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: closeNotificationBtnTriggerPoint, mouseButton: .left)
            moveToCloseBtnEvent?.post(tap: .cghidEventTap)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                // Wait for the close button of that notification to show
                guard let closeBtn = (NotificationMonitor.getSubElements(root: item) { (try? UIElement($0).role()) == .button })?.first else {
                    print("No close btn found")
                    return
                }

                print("Close login item notification")
                try? UIElement(closeBtn).performAction(.press)
            }
        }
    }

    static func getSubElements(root: AXUIElement, filter: (AXUIElement) -> Bool) -> [AXUIElement]? {
        var childrenCount: CFIndex = 0
        var err = AXUIElementGetAttributeValueCount(root, "AXChildren" as CFString, &childrenCount)
        var result: [AXUIElement] = []

        if case .success = err {
            var subElements: CFArray?;
            err = AXUIElementCopyAttributeValues(root, "AXChildren" as CFString, 0, childrenCount, &subElements)
            if case .success = err {
                if let children = subElements as? [AXUIElement] {
                    let filteredSubElements = children.filter(filter)
                    result.append(contentsOf: filteredSubElements)
                    children.forEach { element in
                        if let nestedChildren = getSubElements(root: element, filter: filter) {
                            result.append(contentsOf: nestedChildren)
                        }
                    }
                }

                return result
            }
        }

        print("Error \(err.rawValue)")
        return nil
    }

}

extension NotificationMonitor {
  func getDescriptions() -> [String] {
    if let descriptions = UserDefaults.standard.array(forKey: descriptionsOfNotification) as? [String] {
      return descriptions
    }
    UserDefaults.standard.set(defaultDescriptions, forKey: descriptionsOfNotification)
    return defaultDescriptions
  }
}

let defaultDescriptions = [
   "Login Items",
   "磁盘没有正常推出"
]
