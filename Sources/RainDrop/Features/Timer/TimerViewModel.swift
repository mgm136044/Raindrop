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
    @Published private(set) var sessionGoalSeconds: Int = 25 * 60
    @Published private(set) var isInfinityMode: Bool = false
    @Published private(set) var cycleCount: Int = 0
    @Published private(set) var isCycleDraining: Bool = false
    @Published private(set) var lastCycleCount: Int = 0
    @Published private(set) var isOverflowing: Bool = false

    private let timerService: TimerService
    private let repository: FocusSessionRepositoryProtocol
    private let dateService: DateService
    private let settingsRepository: SettingsRepositoryProtocol
    private let notificationService: NotificationService
    private let shopViewModel: ShopViewModel
    private let syncService: FirebaseSyncService?
    private let whiteNoiseService: WhiteNoiseService?
    private var cachedSettings: AppSettings = AppSettings()
    private var sessionStartTime: Date?
    private var activeGoalSeconds: Int = 0
    private var activeInfinityMode: Bool = false
    private var cancellables = Set<AnyCancellable>()

    init(
        timerService: TimerService,
        repository: FocusSessionRepositoryProtocol,
        dateService: DateService,
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationService,
        shopViewModel: ShopViewModel,
        syncService: FirebaseSyncService? = nil,
        whiteNoiseService: WhiteNoiseService? = nil
    ) {
        self.timerService = timerService
        self.repository = repository
        self.dateService = dateService
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.shopViewModel = shopViewModel
        self.syncService = syncService
        self.whiteNoiseService = whiteNoiseService
        loadSettings()
        loadTodayTotal()
        observeSessionChanges()
        observeSettingsChanges()
        observeFocusCheckTimeout()
    }

    var timerText: String {
        TimeFormatter.clockString(from: elapsedSeconds)
    }

    var todayTotalText: String {
        TimeFormatter.clockString(from: todayTotalSeconds)
    }

    var goalText: String {
        if isInfinityMode {
            return "무한 모드 — 순환마다 코인 적립"
        }
        return "\(sessionGoalSeconds / 60)분 집중 시 양동이 가득"
    }

    var cycleText: String? {
        guard isInfinityMode, (timerState == .running || timerState == .paused) else { return nil }
        return "\(cycleCount + 1)번째 순환 중"
    }

    var isRunning: Bool {
        timerState == .running
    }

    var waterLevelDescription: String {
        switch currentProgress {
        case 0..<0.05: return "바닥"
        case 0.05..<0.3: return "조금"
        case 0.3..<0.55: return "반쯤"
        case 0.55..<0.85: return "많이"
        case 0.85..<1.0: return "거의 가득"
        default: return "가득!"
        }
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
        cycleCount = 0
        isCycleDraining = false
        activeGoalSeconds = sessionGoalSeconds
        activeInfinityMode = isInfinityMode
        let now = Date()
        sessionStartTime = now
        timerState = .running
        startTimerTicks()
        scheduleFocusChecksIfNeeded()
        Task { await syncService?.setFocusing(true, startTime: now) }
        if cachedSettings.whiteNoiseEnabled {
            whiteNoiseService?.setup()
            whiteNoiseService?.setVolume(cachedSettings.whiteNoiseVolume)
            whiteNoiseService?.resumeAudio()
        }
    }

    func pause() {
        guard canPause else { return }
        timerService.stop()
        timerState = .paused
        notificationService.cancelFocusChecks()
        whiteNoiseService?.pauseAudio()
    }

    func resume() {
        guard canResume else { return }
        timerState = .running
        startTimerTicks()
        scheduleFocusChecksIfNeeded()
        if cachedSettings.whiteNoiseEnabled {
            whiteNoiseService?.resumeAudio()
        }
    }

    func stop() {
        guard canStop else { return }
        timerService.stop()
        notificationService.cancelFocusChecks()
        whiteNoiseService?.pauseAudio()

        let endTime = Date()
        let elapsed = elapsedSeconds
        let goalSeconds = activeGoalSeconds
        lastCycleCount = cycleCount

        defer {
            timerState = .completed
            sessionStartTime = nil
            elapsedSeconds = 0
            cycleCount = 0
            isCycleDraining = false
            isDraining = true
            triggerOverflow()
        }

        guard let startTime = sessionStartTime, elapsed > 0 else { return }

        let session = FocusSession(
            startTime: startTime,
            endTime: endTime,
            durationSeconds: elapsed,
            dateKey: dateService.dateKey(for: startTime),
            goalSeconds: activeInfinityMode ? nil : goalSeconds
        )

        do {
            try repository.save(session)
            lastCompletedSession = session

            if !activeInfinityMode && elapsed >= goalSeconds {
                shopViewModel.earnBucket()
            }

            shopViewModel.recordFocusMinutes(elapsed / 60, dateKey: session.dateKey)
            loadTodayTotal()

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
        clearOverflow()
    }

    func finishCycleDraining() {
        cycleCount += 1
        shopViewModel.earnBucket()
        let goal = activeGoalSeconds
        guard goal > 0 else { return }
        let elapsedInCycle = elapsedSeconds % goal
        currentProgress = Double(elapsedInCycle) / Double(goal)
        isCycleDraining = false
        clearOverflow()
    }

    func triggerOverflow() {
        isOverflowing = true
        Task {
            try? await Task.sleep(for: .seconds(3.0))
            isOverflowing = false
        }
    }

    private func clearOverflow() {
        isOverflowing = false
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

            if self.activeInfinityMode {
                let goal = self.activeGoalSeconds
                guard goal > 0 else { return }
                let elapsedInCycle = self.elapsedSeconds % goal

                if elapsedInCycle == 0 && !self.isCycleDraining {
                    self.currentProgress = 1.0
                    self.isCycleDraining = true
                    self.triggerOverflow()
                } else if !self.isCycleDraining {
                    self.currentProgress = Double(elapsedInCycle) / Double(goal)
                }
            } else {
                self.currentProgress = min(
                    Double(self.elapsedSeconds) / Double(self.activeGoalSeconds),
                    1.0
                )
            }
        }
    }

    private func scheduleFocusChecksIfNeeded() {
        let settings = cachedSettings
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
        let previousFocusCheckEnabled = cachedSettings.focusCheckEnabled
        let settings = settingsRepository.load()
        cachedSettings = settings
        sessionGoalSeconds = settings.sessionGoalSeconds
        isInfinityMode = settings.infinityModeEnabled

        // 알림 토글 변경 시 처리
        if previousFocusCheckEnabled && !settings.focusCheckEnabled {
            notificationService.cancelFocusChecks()
        } else if !previousFocusCheckEnabled && settings.focusCheckEnabled && timerState == .running {
            scheduleFocusChecksIfNeeded()
        }
    }

    private func loadTodayTotal() {
        do {
            let todayKey = dateService.dateKey(for: Date())
            let total = try repository.fetchByDateKey(todayKey)
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

    private func observeFocusCheckTimeout() {
        NotificationCenter.default
            .publisher(for: .focusCheckTimedOut)
            .sink { [weak self] _ in
                self?.pause()
            }
            .store(in: &cancellables)
    }
}
