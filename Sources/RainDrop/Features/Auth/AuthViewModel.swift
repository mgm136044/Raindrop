import Foundation
import FirebaseAuth
import FirebaseFirestore
import os

enum AuthState: Equatable {
    case signedOut
    case needsProfile
    case signedIn
}

private let logger = Logger(subsystem: "com.mingyeongmin.RainDrop", category: "Auth")

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var authState: AuthState = .signedOut
    @Published private(set) var currentUser: UserProfile?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let firestoreService: FirestoreService
    private let dateService: DateService

    var isSignedIn: Bool { authState == .signedIn }

    init(firestoreService: FirestoreService, dateService: DateService = DateService()) {
        self.firestoreService = firestoreService
        self.dateService = dateService
        checkCurrentAuth()
    }

    func signInWithEmail(email: String, password: String) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                await handleAuthResult(uid: result.user.uid)
            } catch {
                errorMessage = mapAuthError(error, context: "로그인")
            }
            isLoading = false
        }
    }

    func signUpWithEmail(email: String, password: String) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                await handleAuthResult(uid: result.user.uid)
            } catch {
                errorMessage = mapAuthError(error, context: "회원가입")
            }
            isLoading = false
        }
    }

    private func handleAuthResult(uid: String) async {
        do {
            if let profile = try await firestoreService.fetchUserProfile(uid: uid) {
                currentUser = profile
                authState = .signedIn
                NotificationCenter.default.post(name: .authStateDidChange, object: nil)
            } else {
                authState = .needsProfile
            }
        } catch {
            errorMessage = mapProfileError(error)
        }
    }

    func createProfile(nickname: String) {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "닉네임을 입력해주세요."
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let inviteCode = try await generateUniqueInviteCode()

                let profile = UserProfile(
                    id: uid,
                    nickname: trimmed,
                    inviteCode: inviteCode,
                    createdAt: Date(),
                    isCurrentlyFocusing: false,
                    currentSessionStartTime: nil,
                    todayTotalSeconds: 0,
                    weekTotalSeconds: 0,
                    lastTodayResetDateKey: dateService.dateKey(for: Date()),
                    lastWeekResetWeekKey: dateService.weekKey(for: Date())
                )

                try await firestoreService.createUserProfile(profile)
                currentUser = profile
                authState = .signedIn
                NotificationCenter.default.post(name: .authStateDidChange, object: nil)
            } catch {
                logger.error("프로필 생성 실패: \(error.localizedDescription, privacy: .public)")
                errorMessage = "프로필 생성에 실패했습니다. 잠시 후 다시 시도해 주세요."
            }
            isLoading = false
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            authState = .signedOut
            NotificationCenter.default.post(name: .authStateDidChange, object: nil)
        } catch {
            errorMessage = "로그아웃에 실패했습니다."
        }
    }

    // MARK: - Private

    private func checkCurrentAuth() {
        guard let user = Auth.auth().currentUser else {
            authState = .signedOut
            return
        }

        Task {
            do {
                if let profile = try await firestoreService.fetchUserProfile(uid: user.uid) {
                    currentUser = profile
                    authState = .signedIn
                } else {
                    authState = .needsProfile
                }
            } catch {
                logger.error("세션 복원 실패: \(error.localizedDescription, privacy: .public)")
                errorMessage = "네트워크 오류로 프로필을 확인할 수 없습니다. 다시 시도해주세요."
            }
        }
    }

    private func generateUniqueInviteCode() async throws -> String {
        let chars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        for _ in 0..<10 {
            // CWE-330: 암호학적 보안 난수 사용 (SecRandomCopyBytes)
            var randomBytes = [UInt8](repeating: 0, count: 6)
            _ = SecRandomCopyBytes(kSecRandomDefault, 6, &randomBytes)
            let code = String(randomBytes.map { chars[Int($0) % chars.count] })
            let existing = try await firestoreService.queryUserByInviteCode(code)
            if existing == nil { return code }
        }
        return UUID().uuidString.prefix(6).uppercased()
    }

    private func mapAuthError(_ error: Error, context: String) -> String {
        let nsError = error as NSError

        // Firebase Auth 에러 코드 매핑
        switch nsError.code {
        case 17008:
            return "올바른 이메일 형식이 아닙니다."
        case 17009:
            return "비밀번호가 일치하지 않습니다."
        case 17011:
            return "등록되지 않은 이메일입니다."
        case 17007:
            return "이미 등록된 이메일입니다."
        case 17026:
            return "비밀번호는 6자 이상이어야 합니다."
        case 17020:
            return "네트워크 연결을 확인해주세요."
        case 17010:
            logger.fault("Firebase API key invalid (17010) during \(context, privacy: .public)")
            return "\(context)에 실패했습니다. 잠시 후 다시 시도해 주세요."
        case 17995:
            let reason = nsError.userInfo[NSLocalizedFailureReasonErrorKey] as? String
                ?? error.localizedDescription
            logger.error("Keychain error 17995 during \(context, privacy: .public): \(reason, privacy: .public)")
            return "\(context) 실패: 앱을 재설치하거나 개발자에게 문의하세요."
        case 17999:
            // Internal error — log details, show generic message to user
            let underlyingMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String
                ?? error.localizedDescription
            logger.error("Auth internal error 17999 during \(context, privacy: .public): \(underlyingMessage, privacy: .public)")
            return "\(context)에 실패했습니다. 잠시 후 다시 시도해 주세요."
        default:
            logger.error("Auth error \(nsError.code) during \(context, privacy: .public): \(error.localizedDescription, privacy: .public)")
            return "\(context)에 실패했습니다. 잠시 후 다시 시도해 주세요."
        }
    }

    private func mapProfileError(_ error: Error) -> String {
        let nsError = error as NSError

        if nsError.domain == FirestoreErrorDomain,
           let code = FirestoreErrorCode.Code(rawValue: nsError.code) {
            switch code {
            case .permissionDenied:
                logger.error("Firestore permission denied: \(nsError.localizedDescription, privacy: .public)")
                return "프로필을 확인할 수 없습니다. 다시 로그인해 주세요."
            case .unauthenticated:
                logger.error("Firestore unauthenticated: \(nsError.localizedDescription, privacy: .public)")
                return "인증 상태가 유효하지 않습니다. 다시 로그인해 주세요."
            case .unavailable:
                logger.error("Firestore unavailable: \(nsError.localizedDescription, privacy: .public)")
                return "네트워크 연결을 확인해 주세요."
            default:
                logger.error("Firestore error \(nsError.code): \(nsError.localizedDescription, privacy: .public)")
                return "프로필 확인에 실패했습니다. 잠시 후 다시 시도해 주세요."
            }
        }

        logger.error("Profile error \(nsError.code): \(nsError.localizedDescription, privacy: .public)")
        return "프로필 확인에 실패했습니다. 잠시 후 다시 시도해 주세요."
    }
}

extension Notification.Name {
    static let authStateDidChange = Notification.Name("authStateDidChange")
}
