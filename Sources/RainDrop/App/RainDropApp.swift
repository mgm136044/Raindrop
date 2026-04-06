import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

@main
struct RainDropApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var container = AppContainer()

    init() {
        if AppConstants.socialEnabled {
            FirebaseConfig.configure()
        }
    }

    var body: some Scene {
        WindowGroup("RainDrop", id: "main") {
            TimerScreen(
                viewModel: container.timerViewModel,
                historyViewModel: container.historyViewModel,
                settingsViewModel: container.settingsViewModel,
                shopViewModel: container.shopViewModel,
                authViewModel: container.authViewModel,
                socialViewModel: container.socialViewModel,
                friendsViewModel: container.friendsViewModel
            )
            .frame(width: 1040, height: 700)
        }
        .windowResizability(.contentSize)

        MenuBarExtra("RainDrop", systemImage: "drop.fill") {
            MenuBarContent(viewModel: container.timerViewModel)
        }
    }
}
