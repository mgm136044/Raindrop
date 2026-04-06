import Foundation
import FirebaseFirestore

@MainActor
final class FirestoreService {
    private let db = Firestore.firestore()

    // MARK: - User Profile

    func createUserProfile(_ profile: UserProfile) async throws {
        try db.collection("users").document(profile.id).setData(from: profile)
    }

    func fetchUserProfile(uid: String) async throws -> UserProfile? {
        let snapshot = try await db.collection("users").document(uid).getDocument()
        guard snapshot.exists else { return nil }
        do {
            return try snapshot.data(as: UserProfile.self)
        } catch let decodingError as DecodingError {
            // 구버전/수동 입력 문서에서 필드 누락이 있어도 복구 가능한 경우 fallback 파싱
            guard let raw = snapshot.data() else { return nil }
            if let recovered = Self.decodeUserProfileFallback(data: raw, uid: uid) {
                #if DEBUG
                print("[FirestoreService] UserProfile fallback decode applied for \(uid): \(decodingError)")
                #endif
                return recovered
            }
            #if DEBUG
            print("[FirestoreService] UserProfile decode failed and fallback unavailable for \(uid): \(decodingError)")
            #endif
            return nil
        }
    }

    func updateUserFields(uid: String, fields: [String: Any]) async throws {
        try await db.collection("users").document(uid).updateData(fields)
    }

    // MARK: - User Search

    func queryUsersByNickname(_ prefix: String) async throws -> [UserProfile] {
        let end = prefix + "\u{f8ff}"
        let snapshot = try await db.collection("users")
            .whereField("nickname", isGreaterThanOrEqualTo: prefix)
            .whereField("nickname", isLessThan: end)
            .limit(to: 20)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: UserProfile.self) }
    }

    func queryUserByInviteCode(_ code: String) async throws -> UserProfile? {
        let snapshot = try await db.collection("users")
            .whereField("inviteCode", isEqualTo: code)
            .limit(to: 1)
            .getDocuments()
        return snapshot.documents.first.flatMap { try? $0.data(as: UserProfile.self) }
    }

    // MARK: - Friend Requests

    func sendFriendRequest(_ request: FriendRequest) async throws {
        try db.collection("friendRequests").document(request.id).setData(from: request)
    }

    func fetchIncomingRequests(uid: String) async throws -> [FriendRequest] {
        let snapshot = try await db.collection("friendRequests")
            .whereField("toUID", isEqualTo: uid)
            .whereField("status", isEqualTo: FriendRequestStatus.pending.rawValue)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: FriendRequest.self) }
    }

    func fetchOutgoingRequests(uid: String) async throws -> [FriendRequest] {
        let snapshot = try await db.collection("friendRequests")
            .whereField("fromUID", isEqualTo: uid)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: FriendRequest.self) }
    }

    func acceptFriendRequest(_ requestID: String, fromUID: String, toUID: String) async throws {
        let batch = db.batch()

        // Update request status
        let requestRef = db.collection("friendRequests").document(requestID)
        batch.updateData(["status": FriendRequestStatus.accepted.rawValue], forDocument: requestRef)

        // Create friendship
        let friendshipID = [fromUID, toUID].sorted().joined(separator: "_")
        let friendship = Friendship(
            id: friendshipID,
            members: [fromUID, toUID],
            createdAt: Date()
        )
        let friendshipRef = db.collection("friendships").document(friendshipID)
        try batch.setData(from: friendship, forDocument: friendshipRef)

        try await batch.commit()
    }

    func rejectFriendRequest(_ requestID: String) async throws {
        try await db.collection("friendRequests").document(requestID).updateData([
            "status": FriendRequestStatus.rejected.rawValue
        ])
    }

    // MARK: - Friends

    func fetchFriendships(uid: String) async throws -> [Friendship] {
        let snapshot = try await db.collection("friendships")
            .whereField("members", arrayContains: uid)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Friendship.self) }
    }

    func fetchFriendProfiles(friendUIDs: [String]) async throws -> [UserProfile] {
        guard !friendUIDs.isEmpty else { return [] }

        var profiles: [UserProfile] = []
        // Firestore `in` query limited to 30 items
        for batch in friendUIDs.chunked(into: 30) {
            let snapshot = try await db.collection("users")
                .whereField(FieldPath.documentID(), in: batch)
                .getDocuments()
            let batchProfiles = snapshot.documents.compactMap { try? $0.data(as: UserProfile.self) }
            profiles.append(contentsOf: batchProfiles)
        }
        return profiles
    }

    // MARK: - Focus Sessions

    func writeSession(uid: String, session: FocusSession) async throws {
        try db.collection("focusSessions").document(uid)
            .collection("sessions").document(session.id.uuidString)
            .setData(from: session)
    }

    func updateFocusStatus(uid: String, isFocusing: Bool, startTime: Date?) async throws {
        var fields: [String: Any] = [
            "isCurrentlyFocusing": isFocusing,
        ]
        if let startTime {
            fields["currentSessionStartTime"] = Timestamp(date: startTime)
        } else {
            fields["currentSessionStartTime"] = FieldValue.delete()
        }
        try await db.collection("users").document(uid).updateData(fields)
    }

    // MARK: - Realtime Listener

    func listenToFriendProfiles(
        friendUIDs: [String],
        onChange: @escaping @Sendable ([UserProfile]) -> Void
    ) -> [ListenerRegistration] {
        guard !friendUIDs.isEmpty else { return [] }

        var listeners: [ListenerRegistration] = []
        for batch in friendUIDs.chunked(into: 30) {
            let listener = db.collection("users")
                .whereField(FieldPath.documentID(), in: batch)
                .addSnapshotListener { snapshot, _ in
                    guard let snapshot else { return }
                    let profiles = snapshot.documents.compactMap {
                        try? $0.data(as: UserProfile.self)
                    }
                    onChange(profiles)
                }
            listeners.append(listener)
        }
        return listeners
    }

    func listenToIncomingRequests(
        uid: String,
        onChange: @escaping @Sendable ([FriendRequest]) -> Void
    ) -> ListenerRegistration {
        db.collection("friendRequests")
            .whereField("toUID", isEqualTo: uid)
            .whereField("status", isEqualTo: FriendRequestStatus.pending.rawValue)
            .addSnapshotListener { snapshot, _ in
                guard let snapshot else { return }
                let requests = snapshot.documents.compactMap {
                    try? $0.data(as: FriendRequest.self)
                }
                onChange(requests)
            }
    }
}

// MARK: - Array Chunking Helper

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - UserProfile Fallback Decoder

private extension FirestoreService {
    static func decodeUserProfileFallback(data: [String: Any], uid: String) -> UserProfile? {
        guard
            let nickname = data["nickname"] as? String,
            !nickname.isEmpty,
            let inviteCode = data["inviteCode"] as? String,
            !inviteCode.isEmpty
        else {
            return nil
        }

        let now = Date()
        let id = (data["id"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? uid
        let createdAt = decodeDate(data["createdAt"]) ?? now
        let currentSessionStartTime = decodeDate(data["currentSessionStartTime"])
        let todayTotalSeconds = decodeInt(data["todayTotalSeconds"]) ?? 0
        let weekTotalSeconds = decodeInt(data["weekTotalSeconds"]) ?? 0
        let lastTodayResetDateKey = (data["lastTodayResetDateKey"] as? String) ?? dateKey(for: now)
        let lastWeekResetWeekKey = (data["lastWeekResetWeekKey"] as? String) ?? weekKey(for: now)
        let isCurrentlyFocusing = data["isCurrentlyFocusing"] as? Bool ?? false

        return UserProfile(
            id: id,
            nickname: nickname,
            inviteCode: inviteCode,
            createdAt: createdAt,
            isCurrentlyFocusing: isCurrentlyFocusing,
            currentSessionStartTime: currentSessionStartTime,
            todayTotalSeconds: todayTotalSeconds,
            weekTotalSeconds: weekTotalSeconds,
            lastTodayResetDateKey: lastTodayResetDateKey,
            lastWeekResetWeekKey: lastWeekResetWeekKey
        )
    }

    static func decodeDate(_ value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }
        if let date = value as? Date {
            return date
        }
        if let string = value as? String {
            return iso8601Formatter.date(from: string)
        }
        return nil
    }

    static func decodeInt(_ value: Any?) -> Int? {
        if let intValue = value as? Int {
            return intValue
        }
        if let number = value as? NSNumber {
            return number.intValue
        }
        if let string = value as? String {
            return Int(string)
        }
        return nil
    }

    private static let iso8601Formatter = ISO8601DateFormatter()

    private static let fallbackKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .current
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func dateKey(for date: Date) -> String {
        fallbackKeyFormatter.string(from: date)
    }

    /// DateService.weekKey(for:)와 동일한 로직 — fallback decoder용 static 버전
    static func weekKey(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return "\(components.yearForWeekOfYear ?? 0)-W\(components.weekOfYear ?? 0)"
    }
}
