import Foundation

struct ShopState: Codable, Equatable, Sendable {
    var totalBucketsEarned: Int = 0
    var totalBucketsSpent: Int = 0
    var purchasedItemIDs: Set<String> = []
    var placements: [StickerPlacement] = []

    var balance: Int { totalBucketsEarned - totalBucketsSpent }

    static let storageFilename = "shop_state.json"
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
