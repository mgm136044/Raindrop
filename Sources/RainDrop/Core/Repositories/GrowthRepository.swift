import Foundation

final class GrowthRepository: Sendable {
    private let store: JSONFileStore

    init() {
        store = JSONFileStore()
    }

    func load() -> GrowthState {
        (try? store.load(GrowthState.self, filename: GrowthState.storageFilename)) ?? GrowthState()
    }

    func save(_ state: GrowthState) {
        try? store.save(state, filename: GrowthState.storageFilename)
    }
}
