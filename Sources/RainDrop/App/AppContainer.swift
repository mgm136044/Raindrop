import Foundation

@MainActor
final class AppContainer: ObservableObject {
    private let dateService: DateService
    private let fileStore: JSONFileStore
    private let repository: FocusSessionRepository
    private let settingsRepository: SettingsRepository
    private let shopRepository: ShopRepository
    private let notificationService: NotificationService

    // Firebase services
    let firestoreService: FirestoreService
    private lazy var syncService: FirebaseSyncService = FirebaseSyncService(
        firestoreService: firestoreService,
        dateService: dateService
    )

    // Shared view models
    lazy var shopViewModel: ShopViewModel = ShopViewModel(repository: shopRepository)
    lazy var authViewModel: AuthViewModel = AuthViewModel(firestoreService: firestoreService)
    lazy var timerViewModel: TimerViewModel = TimerViewModel(
        timerService: TimerService(),
        repository: repository,
        dateService: dateService,
        settingsRepository: settingsRepository,
        notificationService: notificationService,
        shopViewModel: shopViewModel,
        syncService: syncService
    )

    init() {
        self.dateService = DateService()
        self.fileStore = JSONFileStore()
        self.repository = FocusSessionRepository(fileStore: fileStore)
        self.settingsRepository = SettingsRepository(fileStore: fileStore)
        self.shopRepository = ShopRepository(fileStore: fileStore)
        self.notificationService = NotificationService()
        self.firestoreService = FirestoreService()

        // delegate를 앱 시작 직후 등록 (알림 수신 전에 반드시 설정되어야 함)
        notificationService.initialize()
    }

    lazy var historyViewModel: HistoryViewModel = HistoryViewModel(
        repository: repository,
        dateService: dateService,
        settingsRepository: settingsRepository
    )

    lazy var settingsViewModel: SettingsViewModel = SettingsViewModel(
        repository: settingsRepository
    )

    lazy var socialViewModel: SocialViewModel = SocialViewModel(
        firestoreService: firestoreService,
        authViewModel: authViewModel
    )

    lazy var friendsViewModel: FriendsViewModel = FriendsViewModel(
        firestoreService: firestoreService,
        authViewModel: authViewModel
    )
}
