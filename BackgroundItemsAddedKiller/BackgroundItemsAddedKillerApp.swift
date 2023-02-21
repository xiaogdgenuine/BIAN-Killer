//
//  BackgroundItemsAddedKillerApp.swift
//  BackgroundItemsAddedKiller
//
//  Created by xiaogd on 2023/2/19.
//

import SwiftUI

@main
struct BackgroundItemsAddedKillerApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fixedSize()
        }
        .windowResizability(.contentSize)
    }

}
