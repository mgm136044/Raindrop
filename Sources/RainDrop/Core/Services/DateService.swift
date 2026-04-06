import Foundation

struct DateService {
    private let keyFormatter: DateFormatter
    private let sectionFormatter: DateFormatter
    private let timeFormatter: DateFormatter

    init() {
        let keyFormatter = DateFormatter()
        keyFormatter.calendar = .current
        keyFormatter.locale = Locale(identifier: "ko_KR")
        keyFormatter.dateFormat = "yyyy-MM-dd"
        self.keyFormatter = keyFormatter

        let sectionFormatter = DateFormatter()
        sectionFormatter.calendar = .current
        sectionFormatter.locale = Locale(identifier: "ko_KR")
        sectionFormatter.dateFormat = "M월 d일 EEEE"
        self.sectionFormatter = sectionFormatter

        let timeFormatter = DateFormatter()
        timeFormatter.calendar = .current
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "HH:mm"
        self.timeFormatter = timeFormatter
    }

    func dateKey(for date: Date) -> String {
        keyFormatter.string(from: date)
    }

    func historyTitle(for dateKey: String) -> String {
        guard let date = keyFormatter.date(from: dateKey) else { return dateKey }
        return sectionFormatter.string(from: date)
    }

    func sessionTimeRange(start: Date, end: Date) -> String {
        "\(timeFormatter.string(from: start)) - \(timeFormatter.string(from: end))"
    }

    func weekKey(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return "\(components.yearForWeekOfYear ?? 0)-W\(components.weekOfYear ?? 0)"
    }
}
