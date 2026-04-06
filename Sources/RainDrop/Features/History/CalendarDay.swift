import Foundation

struct CalendarDay: Identifiable, Hashable {
    let date: Date
    let dateKey: String
    let totalSeconds: Int

    var id: String { dateKey }

    var level: Int {
        let minutes = totalSeconds / 60
        if minutes == 0 { return 0 }
        if minutes < 15 { return 1 }
        if minutes < 30 { return 2 }
        if minutes < 60 { return 3 }
        return 4
    }
}
