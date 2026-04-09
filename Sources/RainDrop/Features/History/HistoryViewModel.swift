import Combine
import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var summaries: [DailyFocusSummary] = []
    @Published private(set) var latestError: String?
    @Published private(set) var dailyBucketCounts: [String: Int] = [:]

    private let repository: FocusSessionRepositoryProtocol
    let dateService: DateService
    private let settingsRepository: SettingsRepositoryProtocol
    private var notificationObserver: AnyCancellable?

    init(
        repository: FocusSessionRepositoryProtocol,
        dateService: DateService,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.repository = repository
        self.dateService = dateService
        self.settingsRepository = settingsRepository
        observeChanges()
        load()
    }

    var isEmpty: Bool {
        summaries.isEmpty
    }

    var dailyTotals: [String: Int] {
        Dictionary(uniqueKeysWithValues: summaries.map { ($0.dateKey, $0.totalSeconds) })
    }

    func load() {
        do {
            let sessions = try repository.fetchAll()
            let grouped = Dictionary(grouping: sessions, by: \.dateKey)
            summaries = grouped.keys.sorted(by: >).map { key in
                let items = grouped[key, default: []].sorted { $0.startTime > $1.startTime }
                let total = items.reduce(0) { $0 + $1.durationSeconds }
                return DailyFocusSummary(
                    dateKey: key,
                    displayDate: dateService.historyTitle(for: key),
                    totalSeconds: total,
                    sessions: items
                )
            }
            latestError = nil
            dailyBucketCounts = computeBucketCounts()
        } catch {
            summaries = []
            dailyBucketCounts = [:]
            latestError = "기록을 불러오지 못했습니다."
        }
    }

    /// 세션별 양동이 수 계산 (일반 모드: goal 달성 여부, 무한 모드: bucketsEarned)
    private func computeBucketCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        for summary in summaries {
            var dayBuckets = 0
            for session in summary.sessions {
                if let goal = session.goalSeconds {
                    // 일반 모드: 목표 달성 시 1개
                    if goal > 0 && session.durationSeconds >= goal {
                        dayBuckets += 1
                    }
                } else {
                    // 무한 모드: 순환 횟수만큼
                    dayBuckets += session.bucketsEarned
                }
            }
            counts[summary.dateKey] = dayBuckets
        }
        return counts
    }

    func timeRangeText(for session: FocusSession) -> String {
        dateService.sessionTimeRange(start: session.startTime, end: session.endTime)
    }

    private func observeChanges() {
        notificationObserver = NotificationCenter.default
            .publisher(for: .focusSessionsDidChange)
            .sink { [weak self] _ in
                self?.load()
            }
    }
}
