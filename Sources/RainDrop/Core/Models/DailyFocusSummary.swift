import Foundation

struct DailyFocusSummary: Identifiable, Sendable {
    let dateKey: String
    let displayDate: String
    let totalSeconds: Int
    let sessions: [FocusSession]

    var id: String { dateKey }
}
