import Foundation

struct GrowthCurve: Sendable {
    static let maxLevel = 50
    static let totalMinutesToMax = 9000 // ~150 hours

    /// Minutes required to reach a specific level (cumulative)
    static func cumulativeMinutes(for level: Int) -> Int {
        guard level > 0 else { return 0 }
        let clamped = min(level, maxLevel)
        // Quadratic: minutes = k * level^2 where k = totalMinutesToMax / maxLevel^2
        let k = Double(totalMinutesToMax) / Double(maxLevel * maxLevel)
        return Int(k * Double(clamped * clamped))
    }

    /// Current level for given total minutes
    static func level(for totalMinutes: Int) -> Int {
        guard totalMinutes > 0 else { return 0 }
        let k = Double(totalMinutesToMax) / Double(maxLevel * maxLevel)
        let level = Int(sqrt(Double(totalMinutes) / k))
        return min(level, maxLevel)
    }

    /// Progress within current level (0.0 - 1.0)
    static func progress(for totalMinutes: Int) -> Double {
        let currentLevel = level(for: totalMinutes)
        guard currentLevel < maxLevel else { return 1.0 }
        let currentLevelMinutes = cumulativeMinutes(for: currentLevel)
        let nextLevelMinutes = cumulativeMinutes(for: currentLevel + 1)
        let range = nextLevelMinutes - currentLevelMinutes
        guard range > 0 else { return 0 }
        return Double(totalMinutes - currentLevelMinutes) / Double(range)
    }
}
