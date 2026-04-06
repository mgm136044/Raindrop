import Foundation
import FirebaseFirestore

@MainActor
final class FriendsViewModel: ObservableObject {
    @Published private(set) var friends: [UserProfile] = []
    @Published private(set) var incomingRequests: [FriendRequest] = []
    @Published private(set) var searchResults: [UserProfile] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let firestoreService: FirestoreService
    private let authViewModel: AuthViewModel
    nonisolated(unsafe) private var requestListener: ListenerRegistration?

    init(firestoreService: FirestoreService, authViewModel: AuthViewModel) {
        self.firestoreService = firestoreService
        self.authViewModel = authViewModel
    }

    deinit {
        requestListener?.remove()
    }

    var myUID: String? { authViewModel.currentUser?.id }

    // MARK: - Load

    func loadFriends() {
        guard let uid = myUID else { return }
        isLoading = true

        Task {
            do {
                let friendships = try await firestoreService.fetchFriendships(uid: uid)
                let friendUIDs = friendships.flatMap { $0.members }.filter { $0 != uid }
                friends = try await firestoreService.fetchFriendProfiles(friendUIDs: friendUIDs)
            } catch {
                errorMessage = "친구 목록을 불러오지 못했습니다."
            }
            isLoading = false
        }
    }

    func listenToRequests() {
        guard let uid = myUID else { return }
        requestListener?.remove()
        requestListener = firestoreService.listenToIncomingRequests(uid: uid) { [weak self] requests in
            Task { @MainActor in
                self?.incomingRequests = requests
            }
        }
    }

    func stopListening() {
        requestListener?.remove()
        requestListener = nil
    }

    // MARK: - Search

    func searchByNickname(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }

        Task {
            do {
                let results = try await firestoreService.queryUsersByNickname(trimmed)
                searchResults = results.filter { $0.id != myUID }
            } catch {
                errorMessage = "검색에 실패했습니다."
            }
        }
    }

    func searchByInviteCode(_ code: String) {
        let trimmed = code.trimmingCharacters(in: .whitespaces).uppercased()
        guard trimmed.count == 6 else {
            searchResults = []
            return
        }

        Task {
            do {
                if let user = try await firestoreService.queryUserByInviteCode(trimmed),
                   user.id != myUID {
                    searchResults = [user]
                } else {
                    searchResults = []
                    errorMessage = "해당 초대 코드의 사용자를 찾을 수 없습니다."
                }
            } catch {
                errorMessage = "검색에 실패했습니다."
            }
        }
    }

    // MARK: - Friend Requests

    func sendRequest(to user: UserProfile) {
        guard let uid = myUID,
              let myNickname = authViewModel.currentUser?.nickname else { return }

        Task {
            do {
                let request = FriendRequest(
                    id: "\(uid)_\(user.id)",
                    fromUID: uid,
                    toUID: user.id,
                    fromNickname: myNickname,
                    status: .pending,
                    createdAt: Date()
                )
                try await firestoreService.sendFriendRequest(request)
                errorMessage = nil
            } catch {
                errorMessage = "친구 요청을 보내지 못했습니다."
            }
        }
    }

    func acceptRequest(_ request: FriendRequest) {
        Task {
            do {
                try await firestoreService.acceptFriendRequest(
                    request.id,
                    fromUID: request.fromUID,
                    toUID: request.toUID
                )
                loadFriends()
            } catch {
                errorMessage = "요청 수락에 실패했습니다."
            }
        }
    }

    func rejectRequest(_ request: FriendRequest) {
        Task {
            do {
                try await firestoreService.rejectFriendRequest(request.id)
            } catch {
                errorMessage = "요청 거절에 실패했습니다."
            }
        }
    }

    func clearSearch() {
        searchResults = []
    }
}
