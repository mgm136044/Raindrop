import Foundation
import UserNotifications
import os

private let logger = Logger(subsystem: "com.mingyeongmin.RainDrop", category: "Notification")

@MainActor
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    private var permissionGranted = false
    private var delegateRegistered = false
    private var focusCheckTimeoutWork: DispatchWorkItem?

    /// 앱 시작 직후 호출 — delegate를 최대한 빨리 등록
    func initialize() {
        ensureDelegate()
        setupCategories()
        logger.notice("initialized — bundleID: \(Bundle.main.bundleIdentifier ?? "nil", privacy: .public)")
        Task { await logNotificationSettings() }
    }

    func requestPermission() async -> Bool {
        ensureDelegate()
        do {
            permissionGranted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
            await logNotificationSettings()
            return permissionGranted
        } catch {
            logger.error("권한 요청 실패: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    // 앱이 포그라운드일 때도 배너 + 소리 + 리스트로 알림 표시
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        logger.notice("willPresent 호출됨: \(notification.request.identifier, privacy: .public)")
        completionHandler([.banner, .list, .sound])

        if notification.request.identifier.hasPrefix("focusCheck-") {
            Task { @MainActor in
                self.focusCheckTimeoutWork?.cancel()
                let work = DispatchWorkItem {
                    NotificationCenter.default.post(name: .focusCheckTimedOut, object: nil)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: work)
                self.focusCheckTimeoutWork = work
            }
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.notification.request.identifier.hasPrefix("focusCheck-") {
            Task { @MainActor in
                self.focusCheckTimeoutWork?.cancel()
                self.focusCheckTimeoutWork = nil
            }
            logger.notice("집중 확인 응답: 사용자가 알림을 클릭함")
        }
        completionHandler()
    }

    func scheduleFocusChecks(intervalMinutes: Int, maxCount: Int = 20) {
        ensureDelegate()
        cancelFocusChecks()

        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "RainDrop"
        content.body = "집중하고 계신가요? 계속 파이팅!"
        content.sound = .default
        content.categoryIdentifier = "focusCheck"

        let count = min(maxCount, max(1, 120 / intervalMinutes))
        logger.notice("\(count)개 알림 스케줄 시작 (간격: \(intervalMinutes)분)")

        for i in 1...count {
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: Double(intervalMinutes * 60 * i),
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: "focusCheck-\(i)",
                content: content,
                trigger: trigger
            )
            center.add(request) { error in
                if let error {
                    logger.error("스케줄 실패 focusCheck-\(i): \(error.localizedDescription, privacy: .public)")
                }
            }
        }

        // 스케줄 확인
        center.getPendingNotificationRequests { requests in
            let focusRequests = requests.filter { $0.identifier.hasPrefix("focusCheck-") }
            logger.notice("대기 중인 알림: \(focusRequests.count)개")
        }
    }

    func cancelFocusChecks() {
        let ids = (1...20).map { "focusCheck-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        focusCheckTimeoutWork?.cancel()
        focusCheckTimeoutWork = nil
    }

    /// pending 알림만 제거, 이미 표시된 알림의 타임아웃은 보존
    func cancelPendingFocusChecks() {
        let ids = (1...20).map { "focusCheck-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// 배너 알림이 가능한 상태인지 확인
    func checkBannerEnabled() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.alertStyle != .none
    }

    // MARK: - Private

    private func logNotificationSettings() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        let statusName: String
        switch settings.authorizationStatus {
        case .authorized: statusName = "authorized"
        case .denied: statusName = "denied"
        case .notDetermined: statusName = "notDetermined"
        case .provisional: statusName = "provisional"
        case .ephemeral: statusName = "ephemeral"
        @unknown default: statusName = "unknown(\(settings.authorizationStatus.rawValue))"
        }
        let alertName: String
        switch settings.alertStyle {
        case .banner: alertName = "banner"
        case .alert: alertName = "alert"
        case .none: alertName = "none"
        @unknown default: alertName = "unknown(\(settings.alertStyle.rawValue))"
        }
        logger.notice("status: \(statusName, privacy: .public), alertStyle: \(alertName, privacy: .public), sound: \(settings.soundSetting.rawValue)")
        if settings.alertStyle == .none {
            logger.warning("⚠️ 배너가 비활성 상태! 시스템 설정 > 알림 > RainDrop에서 '배너'로 변경 필요")
        }
    }

    private func ensureDelegate() {
        guard !delegateRegistered else { return }
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        delegateRegistered = true
        logger.notice("delegate 등록됨 (확인: \(center.delegate === self))")
    }

    private func setupCategories() {
        let confirmAction = UNNotificationAction(
            identifier: "confirmFocus",
            title: "집중 중!",
            options: .foreground
        )
        let category = UNNotificationCategory(
            identifier: "focusCheck",
            actions: [confirmAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

extension Notification.Name {
    static let focusCheckTimedOut = Notification.Name("focusCheckTimedOut")
}
