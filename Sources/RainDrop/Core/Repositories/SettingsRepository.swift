import Foundation

protocol SettingsRepositoryProtocol: Sendable {
    func load() -> AppSettings
    func save(_ settings: AppSettings) throws
}

struct SettingsRepository: SettingsRepositoryProtocol {
    private let fileStore: JSONFileStore

    init(fileStore: JSONFileStore) {
        self.fileStore = fileStore
    }

    func load() -> AppSettings {
        (try? fileStore.load(AppSettings.self, filename: AppSettings.storageFilename)) ?? .default
    }

    func save(_ settings: AppSettings) throws {
        try fileStore.save(settings, filename: AppSettings.storageFilename)
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
}

extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
}
