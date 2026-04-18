# 소셜 기능 활성화 + 보안 강화 (v3.0.0)

**날짜**: 2026-04-18 ~ 2026-04-19
**유형**: 기능 추가 | 보안 강화 | 리팩토링

## 변경 사항

### 소셜 기능 활성화
- `socialEnabled = true` 전환
- 이메일/비밀번호 로그인 (Firebase Auth)
- Apple Sign-In 제거 (AppleSignInCoordinator 삭제)
- Google Sign-In 시도 → executor 충돌로 폐기 (Firebase SDK + Swift 6 + macOS 26 비호환)
- 친구 시스템, 실시간 집중 상태, 일간/주간 랭킹 활성화

### Swift 동시성 안정화
- `BucketShapeProvider` 프로토콜에서 `@MainActor` 제거 → `nonisolated` + `Sendable`
- `AnyBucketSkin`: path 클로저 `@MainActor` → `@Sendable`
- `BucketBodyShape`/`BucketRimShape`: `MainActor.assumeIsolated` 완전 제거
- `BucketSkin.shapeProvider`/`customDropGradient` 에서 `@MainActor` 제거

### 보안 강화 (KISA 감사 기반)
- 비밀번호 8자+ 영문+숫자 필수 (클라이언트 + signUp 내부 이중 검증)
- 로그인 5회 실패 시 30초 잠금 (UserDefaults 영속화, 앱 재시작 후에도 유지)
- attempts 초기화 로직: `object(forKey:) != nil` 검사로 저장된 0 정확히 복원
- 닉네임 ASCII 영숫자+한글(가~힣)+공백/밑줄/하이픈만 허용
- 초대코드 생성: rejection sampling 적용 (모듈러 바이어스 제거)
- Firestore 보안 규칙: friendRequests/friendships 소유권 기반 접근 제어
- 자기 자신 친구 요청 차단 (UID 검증 + UI 피드백)
- `firestore.rules` 프로젝트 코드 관리

### 배포 프로세스 정비
- `deploy.sh`: 기본 모드에서도 엔타이틀먼트 포함 서명
- `--social` 플래그: 개발 기기 전용 (프로비저닝 프로파일 포함)
- Homebrew 배포: 프로비저닝 프로파일 없는 빌드로 Release 생성

## 이유
- 소셜 기능(친구, 랭킹)을 사용자에게 제공하기 위해
- Google Sign-In SDK가 macOS 26 + Swift 6 환경에서 Swift concurrency executor를 오염시켜 SIGSEGV 발생 → 이메일/비밀번호 방식으로 전환
- KISA 보안 감사 결과 82점 → 93점으로 개선

## 기술적 결정
- **Google Sign-In 폐기**: `GIDSignIn.sharedInstance.signIn(withPresenting:)` 호출 시 백그라운드 GCD 큐에서 콜백 → `@MainActor` hop 시 executor 오염된 상태에서 SIGSEGV. Apple Sign-In은 메인 런루프에서 delegate 호출이라 문제 없었음
- **Firebase 초기화 위치**: `App.init()` → `AppContainer.init()`으로 이동. `@StateObject` 생성이 `applicationDidFinishLaunching`보다 먼저 실행되므로 AppContainer에서 초기화해야 Auth.auth() 접근 가능
- **@MainActor 제거**: path 계산은 순수 기하학 → actor isolation 불필요. Firebase SDK가 executor 참조를 오염시키므로 `assumeIsolated` 사용 자체가 위험
- **Rate limiting 영속화**: UserDefaults 선택 (Keychain은 과도). `object(forKey:) != nil`로 키 존재 확인 (integer의 기본값 0과 구분)
- **inviteCode rejection sampling**: `256 % 36 = 4`로 앞 4글자가 1.5% 더 빈번 → `threshold = 252` 미만만 채택

## 변경 파일
- `Core/Utils/AppConstants.swift` (socialEnabled = true, v3.0.0)
- `Features/Auth/AppleSignInCoordinator.swift` (**삭제**)
- `Features/Auth/AuthViewModel.swift` (이메일 전용, rate limiting, 닉네임 검증, inviteCode 수정)
- `Features/Auth/SignInScreen.swift` (비밀번호 검증 UI)
- `Features/Social/FriendsViewModel.swift` (self-guard)
- `Features/Timer/Bucket/BucketShapeProvider.swift` (@MainActor 제거, nonisolated, Sendable)
- `Features/Timer/Bucket/BucketView.swift` (assumeIsolated 제거)
- `Core/Models/BucketSkin.swift` (@MainActor 제거)
- `Core/Firebase/FirebaseConfig.swift` (이중 초기화 방지 guard)
- `App/RainDropApp.swift` (Firebase init 제거)
- `App/AppContainer.swift` (Firebase init 이동)
- `RainDrop.entitlements` (Keychain access groups)
- `firestore.rules` (신규, 소유권 기반 규칙)
- `deploy.sh` (기본 모드 엔타이틀먼트 포함)
- `Features/Settings/PatchNotesView.swift` (v3.0.0 패치노트)

## 관련 커밋
- `3f81e35` refactor: remove @MainActor from BucketShapeProvider
- `68a7361` feat: enable social with email/password auth only
- `ecb3c03` security: fix 5 KISA audit findings
- `ad66672` security: address review issues — tighter rules, persistent lockout, ASCII nicknames
- `ce301f5` feat: v3.0.0 — social features + security hardening
- `39e1130` fix: deploy.sh always includes entitlements
- `26e7ac1` security: fix inviteCode bias + attempts init + signUp validation
