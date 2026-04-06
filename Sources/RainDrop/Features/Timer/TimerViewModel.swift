import Combine
import Foundation

@MainActor
final class TimerViewModel: ObservableObject {
    @Published private(set) var timerState: TimerState = .idle
    @Published private(set) var elapsedSeconds: Int = 0
    @Published private(set) var todayTotalSeconds: Int = 0
    @Published private(set) var currentProgress: Double = 0
    @Published private(set) var isDraining: Bool = false
    @Published private(set) var lastCompletedSession: FocusSession?
    @Published private(set) var latestError: String?
    @Published private(set) var sessionGoalSeconds: Int = AppConstants.sessionGoalSeconds

    private let timerService: TimerService
    private let repository: FocusSessionRepositoryProtocol
    private let dateService: DateService
    private let settingsRepository: SettingsRepositoryProtocol
    private let notificationService: NotificationService
    private let shopViewModel: ShopViewModel
    private let syncService: FirebaseSyncService?
    private var sessionStartTime: Date?
    private var cancellables = Set<AnyCancellable>()

    init(
        timerService: TimerService,
        repository: FocusSessionRepositoryProtocol,
        dateService: DateService,
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationService,
        shopViewModel: ShopViewModel,
        syncService: FirebaseSyncService? = nil
    ) {
        self.timerService = timerService
        self.repository = repository
        self.dateService = dateService
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.shopViewModel = shopViewModel
        self.syncService = syncService
        loadSettings()
        loadTodayTotal()
        observeSessionChanges()
        observeSettingsChanges()
    }

    var timerText: String {
        TimeFormatter.clockString(from: elapsedSeconds)
    }

    var todayTotalText: String {
        TimeFormatter.clockString(from: todayTotalSeconds)
    }

    var goalText: String {
        "\(sessionGoalSeconds / 60)분 집중 시 양동이 가득"
    }

    var isRunning: Bool {
        timerState == .running
    }

    var canStart: Bool {
        timerState == .idle || timerState == .completed
    }

    var canPause: Bool {
        timerState == .running
    }

    var canResume: Bool {
        timerState == .paused
    }

    var canStop: Bool {
        timerState == .running || timerState == .paused
    }

    func start() {
        guard canStart else { return }
        latestError = nil
        lastCompletedSession = nil
        elapsedSeconds = 0
        currentProgress = 0
        let now = Date()
        sessionStartTime = now
        timerState = .running
        startTimerTicks()
        scheduleFocusChecksIfNeeded()
        Task { await syncService?.setFocusing(true, startTime: now) }
    }

    func pause() {
        guard canPause else { return }
        timerService.stop()
        timerState = .paused
        notificationService.cancelFocusChecks()
    }

    func resume() {
        guard canResume else { return }
        timerState = .running
        startTimerTicks()
        scheduleFocusChecksIfNeeded()
    }

    func stop() {
        guard canStop else { return }
        timerService.stop()
        notificationService.cancelFocusChecks()

        let endTime = Date()
        let elapsed = elapsedSeconds
        let goalSeconds = sessionGoalSeconds

        defer {
            timerState = .completed
            sessionStartTime = nil
            elapsedSeconds = 0
            // progress는 즉시 0으로 만들지 않고 draining 애니메이션 트리거
            isDraining = true
        }

        guard let startTime = sessionStartTime, elapsed > 0 else { return }

        let session = FocusSession(
            startTime: startTime,
            endTime: endTime,
            durationSeconds: elapsed,
            dateKey: dateService.dateKey(for: startTime),
            goalSeconds: goalSeconds
        )

        do {
            try repository.save(session)
            lastCompletedSession = session

            // Award bucket coin if goal was reached
            if elapsed >= goalSeconds {
                shopViewModel.earnBucket()
            }

            loadTodayTotal()

            // Firebase sync (fire-and-forget)
            Task {
                await syncService?.syncSession(session)
                await syncService?.setFocusing(false, startTime: nil)
            }
        } catch {
            latestError = "기록 저장에 실패했습니다."
        }
    }

    func finishDraining() {
        currentProgress = 0
        isDraining = false
    }

    func resetCompletionStateIfNeeded() {
        lastCompletedSession = nil
        if timerState == .completed {
            timerState = .idle
        }
    }

    private func startTimerTicks() {
        timerService.start { [weak self] in
            guard let self else { return }
            self.elapsedSeconds += 1
            self.currentProgress = min(
                Double(self.elapsedSeconds) / Double(self.sessionGoalSeconds),
                1.0
            )
        }
    }

    private func scheduleFocusChecksIfNeeded() {
        let settings = settingsRepository.load()
        guard settings.focusCheckEnabled else { return }

        Task {
            let granted = await notificationService.requestPermission()
            if granted {
                notificationService.scheduleFocusChecks(
                    intervalMinutes: settings.focusCheckIntervalMinutes
                )
            }
        }
    }

    private func loadSettings() {
        let settings = settingsRepository.load()
        sessionGoalSeconds = settings.sessionGoalSeconds
    }

    private func loadTodayTotal() {
        do {
            let todayKey = dateService.dateKey(for: Date())
            let total = try repository.fetchAll()
                .filter { $0.dateKey == todayKey }
                .reduce(0) { $0 + $1.durationSeconds }
            todayTotalSeconds = total
        } catch {
            latestError = "기록을 불러오지 못했습니다."
        }
    }

    private func observeSessionChanges() {
        NotificationCenter.default
            .publisher(for: .focusSessionsDidChange)
            .sink { [weak self] _ in
                self?.loadTodayTotal()
            }
            .store(in: &cancellables)
    }

    private func observeSettingsChanges() {
        NotificationCenter.default
            .publisher(for: .settingsDidChange)
            .sink { [weak self] _ in
                self?.loadSettings()
            }
            .store(in: &cancellables)
    }
}
