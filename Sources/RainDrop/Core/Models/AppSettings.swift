import Foundation

struct AppSettings: Codable, Equatable, Sendable {
    var sessionGoalMinutes: Int = 25
    var focusCheckEnabled: Bool = false
    var focusCheckIntervalMinutes: Int = 5
    var infinityModeEnabled: Bool = false

    var sessionGoalSeconds: Int { sessionGoalMinutes * 60 }

    static let `default` = AppSettings()
    static let storageFilename = "app_settings.json"

    // 기존 JSON 파일에 infinityModeEnabled 키가 없어도 정상 디코딩
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionGoalMinutes = try container.decodeIfPresent(Int.self, forKey: .sessionGoalMinutes) ?? 25
        focusCheckEnabled = try container.decodeIfPresent(Bool.self, forKey: .focusCheckEnabled) ?? false
        focusCheckIntervalMinutes = try container.decodeIfPresent(Int.self, forKey: .focusCheckIntervalMinutes) ?? 5
        infinityModeEnabled = try container.decodeIfPresent(Bool.self, forKey: .infinityModeEnabled) ?? false
    }

    init(
        sessionGoalMinutes: Int = 25,
        focusCheckEnabled: Bool = false,
        focusCheckIntervalMinutes: Int = 5,
        infinityModeEnabled: Bool = false
    ) {
        self.sessionGoalMinutes = sessionGoalMinutes
        self.focusCheckEnabled = focusCheckEnabled
        self.focusCheckIntervalMinutes = focusCheckIntervalMinutes
        self.infinityModeEnabled = infinityModeEnabled
    }
}
