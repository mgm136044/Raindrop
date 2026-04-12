import Foundation

final class GrowthRepository: Sendable {
    private let store: JSONFileStore

    init() {
        store = JSONFileStore()
    }

    /// Load existing state, or create + save new one if first launch
    func loadOrCreate() -> GrowthState {
        if let existing = try? store.load(GrowthState.self, filename: GrowthState.storageFilename) {
            return existing
        }
        let newState = GrowthState()
        save(newState)
        return newState
    }

    func save(_ state: GrowthState) {
        try? store.save(state, filename: GrowthState.storageFilename)
    }
}
