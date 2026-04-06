import Foundation

enum FriendRequestStatus: String, Codable, Sendable {
    case pending, accepted, rejected
}

struct FriendRequest: Codable, Identifiable, Sendable {
    let id: String
    let fromUID: String
    let toUID: String
    let fromNickname: String
    var status: FriendRequestStatus
    let createdAt: Date
}
