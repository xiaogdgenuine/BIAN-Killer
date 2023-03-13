//
//  AppDelegate.swift
//  BackgroundItemsAddedKiller
//
//  Created by xiaogd on 2023/2/20.
//

import Foundation
import AppKit
import SwiftUI
import AXSwift

let notificationCenterBundleId = "com.apple.notificationcenterui"
let descriptionsOfNotification = "descriptionsOfNotification"
let windowSize = CGSize(width: 600, height: 400)
var configWindow = NSWindow(contentRect: NSRect(origin: .zero, size: windowSize), styleMask: [.closable, .titled], backing: .buffered, defer: false)

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        let bundleIdentifier = Bundle.main.bundleIdentifier

        if NSWorkspace.shared.runningApplications.filter({ $0.bundleIdentifier == bundleIdentifier }).count > 1 {
            print("App already running.")
            exit(0)
        }

        if let window = NSApplication.shared.windows.first {
            // Close default window, we will manage window manually
            window.close()
        }

        let event = NSAppleEventManager.shared().currentAppleEvent
        let launchedAsLogInItem =
            event?.eventID == kAEOpenApplication &&
            event?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem

        if launchedAsLogInItem {
            if Application.allForBundleID(notificationCenterBundleId).first != nil {
                monitor.setup()
            } else {
                var observer: NSObjectProtocol?
                observer = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: OperationQueue.main) { notification in
                    if notification.userInfo?["NSApplicationBundleIdentifier"] as? String == notificationCenterBundleId {
                        monitor.setup()
                        NSWorkspace.shared.notificationCenter.removeObserver(observer!, name: NSWorkspace.didLaunchApplicationNotification, object: nil)
                    }
                }
            }
        } else {
            showConfigWindow()
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        showConfigWindow()
    }

}

private extension AppDelegate {

    func showConfigWindow() {
        configWindow.isReleasedWhenClosed = false
        configWindow.isOpaque = true
        configWindow.title = "Background item added notification Killer"
        configWindow.contentViewController = NSHostingController(rootView: ContentView())
        configWindow.setContentSize(windowSize)
        configWindow.center()
        configWindow.orderFrontRegardless()
        configWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

}
