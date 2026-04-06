import Foundation

struct FocusSession: Identifiable, Codable, Equatable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let durationSeconds: Int
    let dateKey: String
    let goalSeconds: Int?

    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date,
        durationSeconds: Int,
        dateKey: String,
        goalSeconds: Int? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.durationSeconds = durationSeconds
        self.dateKey = dateKey
        self.goalSeconds = goalSeconds
    }
}
