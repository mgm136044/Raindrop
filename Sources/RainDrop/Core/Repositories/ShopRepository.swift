import Foundation

protocol ShopRepositoryProtocol: Sendable {
    func load() -> ShopState
    func save(_ state: ShopState) throws
}

struct ShopRepository: ShopRepositoryProtocol {
    private let fileStore: JSONFileStore

    init(fileStore: JSONFileStore) {
        self.fileStore = fileStore
    }

    func load() -> ShopState {
        (try? fileStore.load(ShopState.self, filename: ShopState.storageFilename)) ?? ShopState()
    }

    func save(_ state: ShopState) throws {
        try fileStore.save(state, filename: ShopState.storageFilename)
        NotificationCenter.default.post(name: .shopStateDidChange, object: nil)
    }
}

extension Notification.Name {
    static let shopStateDidChange = Notification.Name("shopStateDidChange")
}
