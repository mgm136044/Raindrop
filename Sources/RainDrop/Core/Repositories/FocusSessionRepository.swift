import Foundation

protocol FocusSessionRepositoryProtocol {
    func fetchAll() throws -> [FocusSession]
    func save(_ session: FocusSession) throws
}

struct FocusSessionRepository: FocusSessionRepositoryProtocol {
    private let fileStore: JSONFileStore

    init(fileStore: JSONFileStore) {
        self.fileStore = fileStore
    }

    func fetchAll() throws -> [FocusSession] {
        let sessions: [FocusSession] = try fileStore.load(
            [FocusSession].self,
            filename: AppConstants.storageFilename
        )
        return sessions.sorted { $0.startTime > $1.startTime }
    }

    func save(_ session: FocusSession) throws {
        var sessions = try fetchAll()
        sessions.append(session)
        sessions.sort { $0.startTime > $1.startTime }
        try fileStore.save(sessions, filename: AppConstants.storageFilename)
        NotificationCenter.default.post(name: .focusSessionsDidChange, object: nil)
    }
}

extension Notification.Name {
    static let focusSessionsDidChange = Notification.Name("focusSessionsDidChange")
}
