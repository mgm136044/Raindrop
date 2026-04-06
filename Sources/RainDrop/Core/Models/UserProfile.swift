import Foundation

struct UserProfile: Codable, Identifiable, Sendable {
    let id: String
    var nickname: String
    var inviteCode: String
    var createdAt: Date
    var isCurrentlyFocusing: Bool
    var currentSessionStartTime: Date?
    var todayTotalSeconds: Int
    var weekTotalSeconds: Int
    var lastTodayResetDateKey: String
    var lastWeekResetWeekKey: String
}
