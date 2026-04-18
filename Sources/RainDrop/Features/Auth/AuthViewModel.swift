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
    @Published private(set) var loginAttemptsRemaining: Int = 5  // backed by UserDefaults

    private var lockoutUntil: Date? {
        get {
            let ts = UserDefaults.standard.double(forKey: "auth_lockout_until")
            return ts > 0 ? Date(timeIntervalSince1970: ts) : nil
        }
        set {
            if let date = newValue {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "auth_lockout_until")
            } else {
                UserDefaults.standard.removeObject(forKey: "auth_lockout_until")
            }
        }
    }

    private let firestoreService: FirestoreService
    private let dateService: DateService

    var isSignedIn: Bool { authState == .signedIn }

    init(firestoreService: FirestoreService, dateService: DateService = DateService()) {
        self.firestoreService = firestoreService
        self.dateService = dateService
        // Restore persisted attempts count (default 5 if never set)
        // Use object(forKey:) to distinguish "key absent" from "stored value is 0"
        if UserDefaults.standard.object(forKey: "auth_attempts_remaining") != nil {
            loginAttemptsRemaining = UserDefaults.standard.integer(forKey: "auth_attempts_remaining")
        } else {
            loginAttemptsRemaining = 5
        }
        checkCurrentAuth()
    }

    func signInWithEmail(email: String, password: String) {
        guard !isLoading else { return }

        // Rate limiting: check lockout
        if let lockout = lockoutUntil, Date() < lockout {
            errorMessage = "로그인 시도가 초과되었습니다. 30초 후 다시 시도해 주세요."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                setAttemptsRemaining(5)
                lockoutUntil = nil
                await handleAuthResult(uid: result.user.uid)
            } catch {
                let remaining = loginAttemptsRemaining - 1
                if remaining <= 0 {
                    lockoutUntil = Date().addingTimeInterval(30)
                    setAttemptsRemaining(5)
                    errorMessage = "로그인 시도가 초과되었습니다. 30초 후 다시 시도해 주세요."
                } else {
                    setAttemptsRemaining(remaining)
                    errorMessage = mapAuthError(error, context: "로그인")
                }
            }
            isLoading = false
        }
    }

    func signUpWithEmail(email: String, password: String) {
        guard !isLoading else { return }

        // Rate limiting: same lockout applies to sign-up to prevent account enumeration
        if let lockout = lockoutUntil, Date() < lockout {
            errorMessage = "로그인 시도가 초과되었습니다. 30초 후 다시 시도해 주세요."
            return
        }

        // Client-side password validation before hitting Firebase
        guard password.count >= 8,
              password.rangeOfCharacter(from: .letters) != nil,
              password.rangeOfCharacter(from: .decimalDigits) != nil else {
            errorMessage = "비밀번호는 8자 이상, 영문과 숫자를 포함해야 합니다."
            return
        }

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

        // Nickname character whitelist: ASCII a-z A-Z 0-9, Korean syllables, space/underscore/hyphen
        // Using explicit ASCII ranges instead of .alphanumerics to exclude non-ASCII Unicode letters
        let allowed = CharacterSet(charactersIn: "a"..."z")
            .union(CharacterSet(charactersIn: "A"..."Z"))
            .union(CharacterSet(charactersIn: "0"..."9"))
            .union(CharacterSet(charactersIn: "\u{AC00}"..."\u{D7A3}"))  // Korean syllables
            .union(CharacterSet(charactersIn: " _-"))
        let isClean = trimmed.unicodeScalars.allSatisfy { allowed.contains($0) }
        guard isClean else {
            errorMessage = "닉네임에 사용할 수 없는 문자가 포함되어 있습니다."
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

    private func setAttemptsRemaining(_ count: Int) {
        loginAttemptsRemaining = count
        UserDefaults.standard.set(count, forKey: "auth_attempts_remaining")
    }

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
        let threshold = 256 - (256 % chars.count) // 252: rejection sampling to eliminate modular bias
        for _ in 0..<10 {
            var code = ""
            while code.count < 6 {
                var byte: UInt8 = 0
                _ = SecRandomCopyBytes(kSecRandomDefault, 1, &byte)
                if byte < threshold {
                    code.append(chars[Int(byte) % chars.count])
                }
            }
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
            return "비밀번호는 8자 이상, 영문과 숫자를 포함해야 합니다."
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
