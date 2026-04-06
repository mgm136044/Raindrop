import Foundation

struct DailyFocusSummary: Identifiable {
    let dateKey: String
    let displayDate: String
    let totalSeconds: Int
    let sessions: [FocusSession]

    var id: String { dateKey }
}
