import Foundation

struct Friendship: Codable, Identifiable, Sendable {
    let id: String
    let members: [String]
    let createdAt: Date
}
