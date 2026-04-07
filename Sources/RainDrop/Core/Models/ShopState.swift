import Foundation

struct ShopState: Codable, Equatable, Sendable {
    var totalBucketsEarned: Int = 0
    var totalBucketsSpent: Int = 0
    var purchasedItemIDs: Set<String> = []
    var placements: [StickerPlacement] = []
    var totalFocusMinutes: Int = 0
    var consecutiveFocusDays: Int = 0
    var lastFocusDateKey: String?

    var balance: Int { totalBucketsEarned - totalBucketsSpent }

    static let storageFilename = "shop_state.json"

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalBucketsEarned = try container.decode(Int.self, forKey: .totalBucketsEarned)
        totalBucketsSpent = try container.decode(Int.self, forKey: .totalBucketsSpent)
        purchasedItemIDs = try container.decode(Set<String>.self, forKey: .purchasedItemIDs)
        placements = try container.decode([StickerPlacement].self, forKey: .placements)
        totalFocusMinutes = try container.decodeIfPresent(Int.self, forKey: .totalFocusMinutes) ?? 0
        consecutiveFocusDays = try container.decodeIfPresent(Int.self, forKey: .consecutiveFocusDays) ?? 0
        lastFocusDateKey = try container.decodeIfPresent(String.self, forKey: .lastFocusDateKey)
    }
}

struct StickerPlacement: Codable, Equatable, Sendable, Identifiable {
    let id: UUID
    let itemID: String
    var relativeX: Double
    var relativeY: Double

    init(id: UUID = UUID(), itemID: String, relativeX: Double, relativeY: Double) {
        self.id = id
        self.itemID = itemID
        self.relativeX = relativeX
        self.relativeY = relativeY
    }
}
