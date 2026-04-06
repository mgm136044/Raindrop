import Foundation

struct ShopItem: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let description: String
    let price: Int
    let emoji: String
    let category: String
}
