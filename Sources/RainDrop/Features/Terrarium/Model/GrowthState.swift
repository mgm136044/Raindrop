import Foundation

struct GrowthState: Codable, Sendable {
    var lastAcknowledgedLevel: Int = 0
    var seed: UInt64 = UInt64.random(in: 0...UInt64.max)

    static let storageFilename = "growth_state.json"
}
