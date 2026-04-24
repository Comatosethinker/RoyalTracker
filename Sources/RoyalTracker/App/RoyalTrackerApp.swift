import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct RoyalTrackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var matchStore = MatchStore()
    @State private var captureStore = CaptureStore()

    var body: some Scene {
        WindowGroup("RoyalTracker", id: "main") {
            ContentView(store: matchStore, captureStore: captureStore)
                .frame(minWidth: 1040, minHeight: 680)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Match") {
                    matchStore.resetMatch()
                }
                .keyboardShortcut("n", modifiers: [.command])

                Button(matchStore.isRunning ? "Pause Timer" : "Start Timer") {
                    matchStore.toggleRunning()
                }
                .keyboardShortcut(.space, modifiers: [])
            }
        }
    }
}
