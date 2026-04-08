import Foundation

@MainActor
final class ShopViewModel: ObservableObject {
    @Published private(set) var shopState: ShopState
    @Published private(set) var latestError: String?
    @Published var isDeveloperMode: Bool = false

    private let repository: ShopRepositoryProtocol

    init(repository: ShopRepositoryProtocol) {
        self.repository = repository
        self.shopState = repository.load()
    }

    var balance: Int { shopState.balance }

    var catalog: [ShopItem] { ShopCatalog.allItems }

    var categories: [String] { ShopCatalog.categories }

    var selectedBackground: BackgroundTheme {
        BackgroundTheme.theme(for: shopState.selectedBackgroundID)
    }

    func items(for category: String) -> [ShopItem] {
        catalog.filter { $0.category == category }
    }

    func selectBackground(_ theme: BackgroundTheme) {
        guard theme == .defaultTheme || shopState.purchasedItemIDs.contains(theme.shopItemID ?? "") else { return }
        shopState.selectedBackgroundID = theme.shopItemID
        saveState()
    }

    func isBackgroundSelected(_ item: ShopItem) -> Bool {
        shopState.selectedBackgroundID == item.id
    }

    func isPurchased(_ item: ShopItem) -> Bool {
        isDeveloperMode || shopState.purchasedItemIDs.contains(item.id)
    }

    /// 스티커 전용 — 배경 아이템 제외
    var purchasedStickerIDs: Set<String> {
        let bgIDs = Set(BackgroundTheme.allCases.compactMap(\.shopItemID))
        if isDeveloperMode {
            return Set(ShopCatalog.allItems.map(\.id)).subtracting(bgIDs)
        }
        return shopState.purchasedItemIDs.subtracting(bgIDs)
    }

    func canAfford(_ item: ShopItem) -> Bool {
        isDeveloperMode || shopState.balance >= item.price
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

    func updatePlacementPosition(id: UUID, relativeX: Double, relativeY: Double) {
        guard let index = shopState.placements.firstIndex(where: { $0.id == id }) else { return }
        shopState.placements[index].relativeX = min(max(relativeX, 0.05), 0.95)
        shopState.placements[index].relativeY = min(max(relativeY, 0.05), 0.95)
        saveState()
    }

    func removeAllPlacements() {
        shopState.placements.removeAll()
        saveState()
    }

    func earnBucket() {
        shopState.totalBucketsEarned += 1
        saveState()
    }

    // MARK: - Environment & Weather

    var currentEnvironmentStage: EnvironmentStage {
        EnvironmentStage.stage(for: shopState.totalFocusMinutes)
    }

    var currentWeather: WeatherCondition {
        WeatherCondition.condition(for: shopState.consecutiveFocusDays)
    }

    var minutesToNextStage: Int? {
        guard let next = currentEnvironmentStage.nextStage else { return nil }
        return next.requiredTotalMinutes - shopState.totalFocusMinutes
    }

    func recordFocusMinutes(_ minutes: Int, dateKey: String) {
        shopState.totalFocusMinutes += minutes

        if let lastKey = shopState.lastFocusDateKey {
            if lastKey == dateKey {
                // Same day, no streak change
            } else if isConsecutiveDay(lastKey: lastKey, currentKey: dateKey) {
                shopState.consecutiveFocusDays += 1
            } else {
                shopState.consecutiveFocusDays = 1
            }
        } else {
            shopState.consecutiveFocusDays = 1
        }
        shopState.lastFocusDateKey = dateKey

        saveState()
    }

    private static let dateKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private func isConsecutiveDay(lastKey: String, currentKey: String) -> Bool {
        let formatter = Self.dateKeyFormatter
        guard let lastDate = formatter.date(from: lastKey),
              let currentDate = formatter.date(from: currentKey) else { return false }
        let diff = Calendar.current.dateComponents([.day], from: lastDate, to: currentDate).day ?? 0
        return diff == 1
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
