import Foundation

struct FocusSession: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let durationSeconds: Int
    let dateKey: String
    let goalSeconds: Int?
    let bucketsEarned: Int

    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date,
        durationSeconds: Int,
        dateKey: String,
        goalSeconds: Int? = nil,
        bucketsEarned: Int = 0
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.durationSeconds = durationSeconds
        self.dateKey = dateKey
        self.goalSeconds = goalSeconds
        self.bucketsEarned = bucketsEarned
    }

    // 하위호환: 기존 JSON에 bucketsEarned 필드가 없어도 0으로 디코딩
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
        dateKey = try container.decode(String.self, forKey: .dateKey)
        goalSeconds = try container.decodeIfPresent(Int.self, forKey: .goalSeconds)
        bucketsEarned = try container.decodeIfPresent(Int.self, forKey: .bucketsEarned) ?? 0
    }
}
