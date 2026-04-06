import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings

    private let repository: SettingsRepositoryProtocol
    @Published private(set) var latestError: String?

    init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
        self.settings = repository.load()
    }

    func save() {
        do {
            try repository.save(settings)
            latestError = nil
        } catch {
            latestError = "설정 저장에 실패했습니다."
        }
    }

    func reload() {
        settings = repository.load()
    }
}
