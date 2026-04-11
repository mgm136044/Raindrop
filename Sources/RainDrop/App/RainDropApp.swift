import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    var onTerminate: (() -> Void)?

    func applicationWillTerminate(_ notification: Notification) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        onTerminate?()
    }
}

@main
struct RainDropApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var container = AppContainer()
    @State private var showUpdateAlert = false
    @State private var showUpdateResult = false

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
                friendsViewModel: container.friendsViewModel,
                backgroundSoundService: container.backgroundSoundService,
                growthRepository: container.growthRepository
            )
            .frame(width: 1040, height: 700)
            .overlay {
                if container.updateService.isUpdating {
                    ZStack {
                        Color.black.opacity(0.3)
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("업데이트 중...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .padding(24)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .ignoresSafeArea()
                }
            }
            .onAppear {
                container.shopViewModel.isDeveloperMode = container.settingsViewModel.settings.developerMode
                let soundService = container.backgroundSoundService
                appDelegate.onTerminate = {
                    soundService.teardown()
                }
            }
            .task {
                await container.updateService.checkForUpdate()
                showUpdateAlert = container.updateService.availableVersion != nil
            }
            .alert(
                "새로운 버전이 있습니다",
                isPresented: $showUpdateAlert
            ) {
                Button("예") {
                    container.updateService.performUpdate()
                }
                Button("아니오", role: .cancel) {}
            } message: {
                if let version = container.updateService.availableVersion {
                    Text("v\(version) 버전이 출시되었습니다.\n업데이트 하시겠습니까?")
                }
            }
            .onChange(of: container.updateService.updateResult) { _,result in
                if result != nil {
                    showUpdateResult = true
                }
            }
            .alert(
                "업데이트",
                isPresented: $showUpdateResult
            ) {
                Button("확인") {
                    container.updateService.updateResult = nil
                }
            } message: {
                if let result = container.updateService.updateResult {
                    Text(result)
                }
            }
        }
        .windowResizability(.contentSize)

        MenuBarExtra("RainDrop", systemImage: "drop.fill") {
            MenuBarContent(viewModel: container.timerViewModel)
        }
    }
}
