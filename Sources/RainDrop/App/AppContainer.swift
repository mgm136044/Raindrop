import Foundation

@MainActor
final class AppContainer: ObservableObject {
    private let dateService: DateService
    private let fileStore: JSONFileStore
    private let repository: FocusSessionRepository
    private let settingsRepository: SettingsRepository
    private let shopRepository: ShopRepository
    private let notificationService: NotificationService
    let whiteNoiseService = WhiteNoiseService()
    let updateService = UpdateService()

    // Firebase services (소셜 기능 활성화 시에만 사용)
    private lazy var firestoreService: FirestoreService = FirestoreService()
    private lazy var syncService: FirebaseSyncService = FirebaseSyncService(
        firestoreService: firestoreService,
        dateService: dateService
    )

    // Shared view models
    lazy var shopViewModel: ShopViewModel = ShopViewModel(repository: shopRepository)

    lazy var timerViewModel: TimerViewModel = TimerViewModel(
        timerService: TimerService(),
        repository: repository,
        dateService: dateService,
        settingsRepository: settingsRepository,
        notificationService: notificationService,
        shopViewModel: shopViewModel,
        syncService: AppConstants.socialEnabled ? syncService : nil,
        whiteNoiseService: whiteNoiseService
    )

    init() {
        self.dateService = DateService()
        self.fileStore = JSONFileStore()
        self.repository = FocusSessionRepository(fileStore: fileStore)
        self.settingsRepository = SettingsRepository(fileStore: fileStore)
        self.shopRepository = ShopRepository(fileStore: fileStore)
        self.notificationService = NotificationService()

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

    // 소셜 기능 (socialEnabled = true 일 때만 사용)
    lazy var authViewModel: AuthViewModel? = AppConstants.socialEnabled
        ? AuthViewModel(firestoreService: firestoreService, dateService: dateService) : nil

    lazy var socialViewModel: SocialViewModel? = {
        guard AppConstants.socialEnabled, let auth = authViewModel else { return nil }
        return SocialViewModel(firestoreService: firestoreService, authViewModel: auth)
    }()

    lazy var friendsViewModel: FriendsViewModel? = {
        guard AppConstants.socialEnabled, let auth = authViewModel else { return nil }
        return FriendsViewModel(firestoreService: firestoreService, authViewModel: auth)
    }()
}
