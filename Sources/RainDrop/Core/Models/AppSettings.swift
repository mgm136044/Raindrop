import Foundation

struct AppSettings: Codable, Equatable, Sendable {
    var sessionGoalMinutes: Int = 25
    var focusCheckEnabled: Bool = false
    var focusCheckIntervalMinutes: Int = 5

    var sessionGoalSeconds: Int { sessionGoalMinutes * 60 }

    static let `default` = AppSettings()
    static let storageFilename = "app_settings.json"
}
