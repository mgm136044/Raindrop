import Foundation

enum AppConstants {
    static let appDirectoryName = "RainDrop"
    static let storageFilename = "focus_sessions.json"
    static let sessionGoalSeconds = 25 * 60

    /// 소셜/로그인 기능 활성화 여부 — false면 Firebase Auth/Sync 비활성화, entitlements 불필요
    static let socialEnabled = false

    static let appVersion = "1.6.0"
    static let githubReleasesAPI = "https://api.github.com/repos/mgm136044/Raindrop/releases/latest"
}
