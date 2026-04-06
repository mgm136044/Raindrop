import Foundation
import FirebaseFirestore

@MainActor
final class SocialViewModel: ObservableObject {
    @Published private(set) var friendProfiles: [UserProfile] = []
    @Published private(set) var isLoading = false

    private let firestoreService: FirestoreService
    private let authViewModel: AuthViewModel
    private var listeners: [ListenerRegistration] = []

    init(firestoreService: FirestoreService, authViewModel: AuthViewModel) {
        self.firestoreService = firestoreService
        self.authViewModel = authViewModel
    }

    var myUID: String? { authViewModel.currentUser?.id }

    var focusingFriends: [UserProfile] {
        friendProfiles.filter { $0.isCurrentlyFocusing }
    }

    var dailyRanking: [UserProfile] {
        let all = allIncludingMe
        return all.sorted { $0.todayTotalSeconds > $1.todayTotalSeconds }
    }

    var weeklyRanking: [UserProfile] {
        let all = allIncludingMe
        return all.sorted { $0.weekTotalSeconds > $1.weekTotalSeconds }
    }

    private var allIncludingMe: [UserProfile] {
        var profiles = friendProfiles
        if let me = authViewModel.currentUser {
            profiles.append(me)
        }
        return profiles
    }

    func loadAndListen() {
        guard let uid = myUID else { return }
        isLoading = true

        Task {
            do {
                let friendships = try await firestoreService.fetchFriendships(uid: uid)
                let friendUIDs = friendships.flatMap { $0.members }.filter { $0 != uid }

                guard !friendUIDs.isEmpty else {
                    friendProfiles = []
                    isLoading = false
                    return
                }

                // Start realtime listener
                stopListening()
                listeners = firestoreService.listenToFriendProfiles(friendUIDs: friendUIDs) { [weak self] profiles in
                    Task { @MainActor in
                        self?.friendProfiles = profiles
                    }
                }

                // Also do initial fetch
                friendProfiles = try await firestoreService.fetchFriendProfiles(friendUIDs: friendUIDs)
            } catch {
                // Silently fail
            }
            isLoading = false
        }
    }

    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
}
