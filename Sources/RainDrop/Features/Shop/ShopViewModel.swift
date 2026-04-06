import Foundation

@MainActor
final class ShopViewModel: ObservableObject {
    @Published private(set) var shopState: ShopState
    @Published private(set) var latestError: String?

    private let repository: ShopRepositoryProtocol

    init(repository: ShopRepositoryProtocol) {
        self.repository = repository
        self.shopState = repository.load()
    }

    var balance: Int { shopState.balance }

    var catalog: [ShopItem] { ShopCatalog.allItems }

    var categories: [String] { ShopCatalog.categories }

    func items(for category: String) -> [ShopItem] {
        catalog.filter { $0.category == category }
    }

    func isPurchased(_ item: ShopItem) -> Bool {
        shopState.purchasedItemIDs.contains(item.id)
    }

    func canAfford(_ item: ShopItem) -> Bool {
        shopState.balance >= item.price
    }

    func purchase(_ item: ShopItem) {
        guard !isPurchased(item), canAfford(item) else { return }
        shopState.totalBucketsSpent += item.price
        shopState.purchasedItemIDs.insert(item.id)
        saveState()
    }

    func addPlacement(_ placement: StickerPlacement) {
        shopState.placements.append(placement)
        saveState()
    }

    func removePlacement(id: UUID) {
        shopState.placements.removeAll { $0.id == id }
        saveState()
    }

    func earnBucket() {
        shopState.totalBucketsEarned += 1
        saveState()
    }

    func reload() {
        shopState = repository.load()
    }

    private func saveState() {
        do {
            try repository.save(shopState)
            latestError = nil
        } catch {
            latestError = "상점 데이터 저장에 실패했습니다."
        }
    }

}
