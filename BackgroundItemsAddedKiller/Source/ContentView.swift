//
//  ContentView.swift
//  BackgroundItemsAddedKiller
//
//  Created by xiaogd on 2023/2/19.
//

import SwiftUI
import LaunchAtLogin
import AVKit

let monitor = NotificationMonitor()
let player = AVPlayer(url: Bundle.main.url(forResource: "demo", withExtension: "mp4")!)

struct ContentView: View {

    @State var showingAboutView = false

    var body: some View {
        Group {
            if showingAboutView {
                AboutView { showingAboutView = false }
            } else {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()

                        Button("About") {
                            showingAboutView = true
                        }
                    }
                    HStack {
                        Text("No more shaking movements!")
                            .foregroundColor(.green)
                        Text("Let me click it for you!")
                            .foregroundColor(.red)
                    }
                        .font(.largeTitle)

                    VideoPlayer(player: player)

                    HStack {
                        LaunchAtLogin
                            .Toggle {
                                Text("Launch at login")
                            }
                            .padding([.top])
                    }

                    Group {
                        if monitor.isRunning {
                            RectangleButton(text: "Disable and quit", highlightByDefault: true) {
                                monitor.cleanup()
                                NSRunningApplication.current.terminate()
                            }
                        } else {
                            RectangleButton(text: "Monitor & kill \"Background item added...Disk Disk Not Ejected...\" notifications", highlightByDefault: true) {
                                player.pause()

                                if monitor.setup() {
                                    configWindow.close()
                                }
                            }
                        }
                    }
                    .padding([.top])
                }
            }
        }
        .frame(width: windowSize.width, height: windowSize.height)
        .onAppear {
            player.seek(to: .zero)
            player.play()
        }
        .onDisappear {
            player.pause()
        }
        .padding()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
