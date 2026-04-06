import Foundation
import FirebaseAuth
import FirebaseFirestore
import os

private let logger = Logger(subsystem: "com.mingyeongmin.RainDrop", category: "Sync")

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
            let todayKey = dateService.dateKey(for: Date())
            let weekKey = dateService.weekKey(for: Date())
            try await incrementTotals(uid: uid, seconds: session.durationSeconds, todayKey: todayKey, weekKey: weekKey)
            logger.notice("세션 동기화 완료: \(session.durationSeconds)초")
        } catch {
            let nsError = error as NSError
            logger.error("세션 동기화 실패: domain=\(nsError.domain, privacy: .public) code=\(nsError.code) — \(nsError.localizedDescription, privacy: .public)")
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
            let nsError = error as NSError
            logger.error("집중 상태 업데이트 실패: domain=\(nsError.domain, privacy: .public) code=\(nsError.code) — \(nsError.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Private

    private nonisolated func incrementTotals(uid: String, seconds: Int, todayKey: String, weekKey currentWeekKey: String) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        let _: Any? = try await db.runTransaction { transaction, errorPointer in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let data = snapshot.data() else { return nil }

            let lastTodayKey = data["lastTodayResetDateKey"] as? String ?? ""
            let lastWeekKey = data["lastWeekResetWeekKey"] as? String ?? ""
            let currentTodaySeconds = data["todayTotalSeconds"] as? Int ?? 0
            let currentWeekSeconds = data["weekTotalSeconds"] as? Int ?? 0

            var fields: [String: Any] = [:]

            if lastTodayKey != todayKey {
                fields["todayTotalSeconds"] = seconds
                fields["lastTodayResetDateKey"] = todayKey
            } else {
                fields["todayTotalSeconds"] = currentTodaySeconds + seconds
            }

            if lastWeekKey != currentWeekKey {
                fields["weekTotalSeconds"] = seconds
                fields["lastWeekResetWeekKey"] = currentWeekKey
            } else {
                fields["weekTotalSeconds"] = currentWeekSeconds + seconds
            }

            transaction.updateData(fields, forDocument: userRef)
            return nil
        }
    }
}
