import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class FirebaseSyncService {
    private let firestoreService: FirestoreService
    private let dateService: DateService

    init(firestoreService: FirestoreService, dateService: DateService) {
        self.firestoreService = firestoreService
        self.dateService = dateService
    }

    private var currentUID: String? {
        Auth.auth().currentUser?.uid
    }

    func syncSession(_ session: FocusSession) async {
        guard let uid = currentUID else { return }

        do {
            try await firestoreService.writeSession(uid: uid, session: session)
            try await incrementTotals(uid: uid, seconds: session.durationSeconds)
        } catch {
            // 로컬이 primary — 동기화 실패는 조용히 무시
        }
    }

    func setFocusing(_ isFocusing: Bool, startTime: Date?) async {
        guard let uid = currentUID else { return }

        do {
            try await firestoreService.updateFocusStatus(
                uid: uid,
                isFocusing: isFocusing,
                startTime: startTime
            )
        } catch {
            // 조용히 무시
        }
    }

    // MARK: - Private

    private func incrementTotals(uid: String, seconds: Int) async throws {
        let todayKey = dateService.dateKey(for: Date())
        let currentWeekKey = weekKey(for: Date())

        guard let profile = try await firestoreService.fetchUserProfile(uid: uid) else { return }

        var fields: [String: Any] = [:]

        // 일간 리셋 체크
        if profile.lastTodayResetDateKey != todayKey {
            fields["todayTotalSeconds"] = seconds
            fields["lastTodayResetDateKey"] = todayKey
        } else {
            fields["todayTotalSeconds"] = FieldValue.increment(Int64(seconds))
        }

        // 주간 리셋 체크
        if profile.lastWeekResetWeekKey != currentWeekKey {
            fields["weekTotalSeconds"] = seconds
            fields["lastWeekResetWeekKey"] = currentWeekKey
        } else {
            fields["weekTotalSeconds"] = FieldValue.increment(Int64(seconds))
        }

        try await firestoreService.updateUserFields(uid: uid, fields: fields)
    }

    private func weekKey(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return "\(components.yearForWeekOfYear ?? 0)-W\(components.weekOfYear ?? 0)"
    }
}
