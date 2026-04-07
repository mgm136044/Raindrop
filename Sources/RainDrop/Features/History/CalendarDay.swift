import Foundation

struct CalendarDay: Identifiable, Hashable {
    let date: Date
    let dateKey: String
    let totalSeconds: Int
    var bucketCount: Int = 0

    var id: String { dateKey }

    var level: Int {
        let minutes = totalSeconds / 60
        if minutes == 0 { return 0 }
        if minutes < 15 { return 1 }
        if minutes < 30 { return 2 }
        if minutes < 60 { return 3 }
        return 4
    }

    /// 0.0~1.0, 4시간(240분)을 1.0으로 기준
    var fillRatio: Double {
        let minutes = Double(totalSeconds) / 60.0
        return min(minutes / 240.0, 1.0)
    }
}
