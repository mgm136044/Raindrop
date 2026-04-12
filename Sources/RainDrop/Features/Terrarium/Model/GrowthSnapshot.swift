import Foundation

struct GrowthSnapshot: Sendable {
    let level: Int              // 0-50
    let progressToNext: Double  // 0.0-1.0
    let phase: GrowthPhase
    let totalMinutes: Int
    let biome: Biome

    enum GrowthPhase: Int, Sendable, CaseIterable {
        case germination = 1    // Lv 1-10
        case bloom = 2          // Lv 11-25
        case flourish = 3       // Lv 26-40
        case transcendence = 4  // Lv 41-50

        static func from(level: Int) -> GrowthPhase {
            switch level {
            case 0...10: return .germination
            case 11...25: return .bloom
            case 26...40: return .flourish
            default: return .transcendence
            }
        }

        var displayName: String {
            switch self {
            case .germination: return "발아"
            case .bloom: return "개화"
            case .flourish: return "만개"
            case .transcendence: return "초월"
            }
        }
    }
}
