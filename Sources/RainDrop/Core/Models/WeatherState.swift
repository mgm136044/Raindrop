import Foundation

enum WeatherCondition: Int, Codable, CaseIterable, Sendable {
    case cloudy = 0
    case drizzle = 1
    case rain = 2
    case rainbow = 3

    var requiredConsecutiveDays: Int {
        switch self {
        case .cloudy: return 1
        case .drizzle: return 3
        case .rain: return 7
        case .rainbow: return 14
        }
    }

    var displayName: String {
        switch self {
        case .cloudy: return "흐림"
        case .drizzle: return "이슬비"
        case .rain: return "비"
        case .rainbow: return "무지개"
        }
    }

    var emoji: String {
        switch self {
        case .cloudy: return "☁️"
        case .drizzle: return "🌦️"
        case .rain: return "🌧️"
        case .rainbow: return "🌈"
        }
    }

    static func condition(for consecutiveDays: Int) -> WeatherCondition {
        for condition in Self.allCases.reversed() {
            if consecutiveDays >= condition.requiredConsecutiveDays {
                return condition
            }
        }
        return .cloudy
    }
}
