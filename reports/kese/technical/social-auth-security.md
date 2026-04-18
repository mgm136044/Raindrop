# RainDrop macOS - Social/Auth 보안 감사 보고서

**날짜**: 2026-04-17
**대상 버전**: v2.9.1
**감사 범위**: Auth, Social, Firebase 연동 코드 (Apple Sign-In 제거 후)
**기준**: KISA 시큐어코딩 가이드 + CWE Top 25

---

## 종합 점수: 82/100 (양호)

| 영역 | 점수 | 등급 |
|------|------|------|
| 입력 검증 | 16/20 | 양호 |
| 보안 기능 | 15/20 | 부분이행 |
| 에러 처리 | 19/20 | 양호 |
| 캡슐화 | 17/20 | 양호 |
| 데이터 보호 | 15/20 | 부분이행 |

---

## 1. 입력 검증 (Input Validation)

| 코드 | 항목 | 판정 | 상세 |
|------|------|------|------|
| CWE-20 | 이메일 입력 검증 | 양호 | 클라이언트: 빈 문자열 체크. 서버: Firebase Auth가 RFC 5322 형식 검증 (에러코드 17008). 이중 검증 구조 적절함 |
| CWE-20 | 비밀번호 길이 검증 | 양호 | 클라이언트: `password.count >= 6` (SignInScreen L13). 서버: Firebase Auth 기본 정책 6자 이상 (에러코드 17026). 일관됨 |
| CWE-20 | 닉네임 입력 검증 | 부분이행 | 길이만 검증 (2~12자). **HTML/스크립트 태그, 특수문자, 이모지 폭탄 필터링 없음**. Firestore에 저장 후 다른 사용자 UI에 표시되므로 stored XSS 우려 (SwiftUI Text는 HTML 렌더링 안 하므로 실질적 위험은 낮지만, 모욕적 닉네임/유니코드 남용 가능) |
| CWE-89 | 쿼리 인젝션 (Firestore) | 양호 | Firestore SDK 파라미터 바인딩 사용 (`.whereField(_, isEqualTo:)`). SQL/NoSQL 인젝션 경로 없음 |
| CWE-20 | 초대코드 검증 | 양호 | 6자 고정 + uppercase 변환 + 영대문자/숫자만 사용 (생성 시). 검색 시 `trimmed.count == 6` 가드 적용 |
| CWE-20 | 닉네임 검색 입력 | 부분이행 | `queryUsersByNickname`에서 prefix 검색 사용. 빈 문자열 체크는 있으나, 매우 짧은 1자 검색으로 전체 사용자 열거 가능 (limit 20으로 완화됨) |

## 2. 보안 기능 (Security Features)

| 코드 | 항목 | 판정 | 상세 |
|------|------|------|------|
| CWE-521 | 비밀번호 복잡도 | 부분이행 | **6자 최소 길이만 적용**. 대/소문자, 숫자, 특수문자 혼합 요구사항 없음. Firebase Auth 기본 정책만 의존. KISA 권고: 8자 이상 + 3종 조합 |
| CWE-259 | 하드코딩된 자격증명 | 양호 | FirebaseSecrets.swift가 `.gitignore`에 포함됨. git history에 커밋 이력 없음 (확인 완료). 바이너리 내 API 키 포함은 불가피하나, SC-01 보안 권고 주석으로 App Check/API Key 제한 안내 적절 |
| CWE-321 | 개발자 코드 보안 | 양호 | SHA256 해시 비교 (`isValidDevCode`). 평문 노출 없음. 역산 불가. 적절한 구현 |
| CWE-307 | 무차별 대입 방어 | 부분이행 | **클라이언트 측 로그인 시도 제한 없음**. Firebase Auth 서버 측 rate limiting에만 의존. 잠금(lockout) 메커니즘 부재. `guard !isLoading` 중복 제출만 방지 |
| CWE-306 | 세션 관리 | 양호 | Firebase Auth ID Token 자동 관리. `checkCurrentAuth()`로 앱 재시작 시 세션 복원. 로그아웃 시 `currentUser = nil` + `authState = .signedOut` 적절한 상태 초기화 |
| CWE-330 | 난수 생성 | 양호 | `SecRandomCopyBytes` (암호학적 보안 난수) 사용 (AuthViewModel L155-156). CWE-330 주석도 적절. 단, fallback으로 `UUID().uuidString.prefix(6)` 사용 시 예측 가능성 소폭 증가 (10회 충돌 시에만 해당, 확률 극히 낮음) |
| CWE-287 | 인증 상태 검증 | 양호 | `guard let uid = myUID else { return }` 패턴으로 모든 데이터 접근 전 인증 확인. `Auth.auth().currentUser` 활용 |

## 3. 에러 처리 (Error Handling)

| 코드 | 항목 | 판정 | 상세 |
|------|------|------|------|
| CWE-209 | 에러 메시지 정보 누출 | 양호 | `mapAuthError`: 내부 에러코드를 사용자 친화적 한국어 메시지로 변환. 17010(API key invalid), 17999(internal error) 등 민감한 에러는 `logger.error`로만 기록하고 사용자에게는 일반 메시지 표시. **매우 적절한 구현** |
| CWE-209 | Firestore 에러 매핑 | 양호 | `mapProfileError`: permissionDenied, unauthenticated, unavailable 등 서버 에러를 적절히 매핑. 기술적 상세는 logger로만 전달 |
| CWE-209 | 소셜 기능 에러 | 양호 | SocialViewModel, FriendsViewModel: 모든 catch 블록에서 일반화된 한국어 메시지만 사용자에게 노출 |
| CWE-209 | 디버그 출력 | 부분이행 | FirestoreService L24-29: `#if DEBUG print(...)` 사용. UID가 디버그 로그에 포함됨. Release 빌드에서는 제거되므로 양호하나, **디버그 빌드에서도 os.Logger 사용이 더 적절** |

## 4. 캡슐화 (Encapsulation)

| 코드 | 항목 | 판정 | 상세 |
|------|------|------|------|
| CWE-615 | 민감 정보 주석 | 양호 | 소스코드 주석에 비밀번호, 키 등 민감 정보 없음 |
| CWE-615 | 디버그 코드 (Release) | 양호 | `#if DEBUG`로 적절히 분기. Release 빌드에 디버그 출력 포함 안 됨 |
| - | FirebaseSecrets .gitignore | 양호 | `.gitignore`에 포함 확인. git history에 커밋 이력 없음 확인 완료 |
| - | Keychain 접근 그룹 | 양호 | `RainDrop.entitlements`에 앱 고유 Keychain 그룹만 설정. `useUserAccessGroup(nil)`로 공유 Keychain 미사용. 격리 적절 |
| - | 접근 제어자 | 양호 | `private(set)` 적극 사용. `AuthViewModel.authState`, `currentUser` 등 외부 쓰기 차단. `firestoreService` private |
| CWE-362 | 동시성 안전 | 양호 | `@MainActor` 적용 (AuthViewModel, FirestoreService, SocialViewModel, FriendsViewModel). `nonisolated(unsafe)` 사용은 listeners 제거에만 한정 (허용 범위) |

## 5. 데이터 보호 (Data Protection)

| 코드 | 항목 | 판정 | 상세 |
|------|------|------|------|
| - | PII 저장 범위 | 양호 | UserProfile: nickname, inviteCode, 집중 통계만 저장. 이메일/비밀번호는 Firebase Auth에서만 관리. 최소한의 데이터 수집 원칙 준수 |
| - | Firestore 보안 규칙 | 확인불가 | **프로젝트에 `firestore.rules` 파일 없음**. Firebase Console에서 직접 관리 중으로 추정. 코드 리뷰만으로는 서버 측 규칙 검증 불가. **소유자 확인(uid == request.auth.uid) 규칙이 반드시 적용되어야 함** |
| - | 데이터 전송 암호화 | 양호 | Firebase SDK 기본 TLS 1.2+ 적용. 별도 HTTP 통신 없음 |
| - | 친구 요청 검증 | 부분이행 | `sendRequest(to:)`에서 **중복 요청 방지 로직 없음**. 동일 사용자에게 반복 요청 가능. requestID `\(uid)_\(user.id)` 형식이라 Firestore에서 덮어쓰기로 완화되나, **자기 자신에게 요청 방지도 없음** (UI에서 `filter { $0.id != myUID }` 검색 결과 필터링은 있으나, API 레벨에서 미검증) |
| - | 랭킹 데이터 무결성 | 부분이행 | `todayTotalSeconds`, `weekTotalSeconds` 값이 클라이언트에서 산출. **악의적 클라이언트가 `updateUserFields`를 통해 비정상 값 주입 가능**. Firestore 보안 규칙에서 값 범위 검증 필요 |
| - | Certificate Pinning | 해당없음 | Firebase SDK 사용 시 별도 pinning 불필요 (Google 인프라 신뢰 체인) |

---

## 주요 발견사항 요약

### 취약 (Critical/High)

없음

### 부분이행 (Medium)

| # | 항목 | 위험도 | 설명 |
|---|------|--------|------|
| M-1 | 비밀번호 복잡도 미흡 | Medium | 6자 최소 길이만 적용. KISA 권고 8자+3종 조합 미준수 |
| M-2 | 클라이언트 rate limiting 없음 | Medium | 로그인 시도 무제한. Firebase 서버 rate limit에만 의존 |
| M-3 | Firestore 보안 규칙 미확인 | Medium | 프로젝트 내 rules 파일 부재. Console 직접 확인 필요 |
| M-4 | 닉네임 문자 필터링 없음 | Low-Medium | 특수문자/이모지 무제한. 모욕적 콘텐츠 가능 |
| M-5 | 친구 요청 중복/자기 요청 검증 | Low | API 레벨 검증 부재 (UI 필터링에만 의존) |
| M-6 | 랭킹 데이터 클라이언트 무결성 | Low-Medium | 서버 측 값 범위 검증 필요 |

---

## Top 3 권장사항

### 1. Firestore 보안 규칙 코드 관리 (우선순위: 긴급)

```
// firestore.rules (프로젝트 루트에 추가, Firebase CLI로 배포)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // users: 본인만 쓰기, 인증된 사용자 읽기
    match /users/{uid} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == uid;
      allow update: if request.auth.uid == uid
        && request.resource.data.todayTotalSeconds is int
        && request.resource.data.todayTotalSeconds >= 0
        && request.resource.data.weekTotalSeconds is int
        && request.resource.data.weekTotalSeconds >= 0;
    }
    // friendRequests: 발신자만 생성, 수신자만 수락/거절
    match /friendRequests/{requestId} {
      allow create: if request.auth.uid == request.resource.data.fromUID
                    && request.resource.data.fromUID != request.resource.data.toUID;
      allow update: if request.auth.uid == resource.data.toUID;
      allow read: if request.auth.uid == resource.data.fromUID
                  || request.auth.uid == resource.data.toUID;
    }
  }
}
```

**이유**: 서버 측 규칙이 코드로 관리되지 않으면 실수로 규칙이 변경되거나 검증 누락이 발생할 수 있음.

### 2. 비밀번호 복잡도 강화 + 클라이언트 Rate Limiting (우선순위: 높음)

```swift
// AuthViewModel.swift 또는 별도 PasswordValidator
private static let MIN_PASSWORD_LENGTH = 8
private static let MAX_LOGIN_ATTEMPTS = 5
private static let LOCKOUT_DURATION: TimeInterval = 300 // 5 minutes

private var loginAttemptCount = 0
private var lockoutUntil: Date?

private func validatePasswordComplexity(_ password: String) -> String? {
    if password.count < 8 { return "비밀번호는 8자 이상이어야 합니다." }
    let hasLetter = password.rangeOfCharacter(from: .letters) != nil
    let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
    if !hasLetter || !hasNumber {
        return "비밀번호에 영문자와 숫자를 모두 포함해 주세요."
    }
    return nil
}
```

**이유**: 6자 비밀번호는 무차별 대입에 취약. 클라이언트 lockout으로 사용자 경험 보호.

### 3. 닉네임 입력 정제 및 친구 요청 서버 검증 (우선순위: 중간)

```swift
// Nickname sanitization
private func sanitizeNickname(_ input: String) -> String {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
    // Remove control characters, zero-width characters
    let filtered = trimmed.unicodeScalars.filter {
        !CharacterSet.controlCharacters.contains($0) &&
        !CharacterSet(charactersIn: "\u{200B}\u{200C}\u{200D}\u{FEFF}").contains($0)
    }
    return String(String.UnicodeScalarView(filtered))
}

// Friend request: self-request guard
func sendRequest(to user: UserProfile) {
    guard let uid = myUID, uid != user.id else { return }  // self-request 방지
    // ... existing code
}
```

**이유**: 유니코드 남용 방지 + API 레벨에서 비즈니스 로직 검증.

---

## 양호 사항 (좋은 구현)

1. **에러 메시지 매핑**: `mapAuthError`, `mapProfileError`에서 기술적 상세를 로거로만 기록하고 사용자에게는 일반 메시지만 노출. CWE-209 완벽 대응
2. **암호학적 난수**: 초대코드 생성에 `SecRandomCopyBytes` 사용. CWE-330 대응 완료
3. **FirebaseSecrets 보호**: `.gitignore` 포함 + git history 미포함 확인. SC-01 보안 권고 주석 포함
4. **@MainActor 일관 적용**: 동시성 안전성 확보. `nonisolated(unsafe)` 사용 최소화
5. **Keychain 격리**: 앱 고유 접근 그룹만 사용, 공유 Keychain 미사용
6. **Firestore SDK 파라미터 바인딩**: NoSQL 인젝션 경로 차단
7. **SHA256 개발자 코드**: 평문 노출 없이 해시 비교

---

*감사 수행: Claude Code Security Audit*
*기준: KISA 시큐어코딩 가이드 (2024), CWE Top 25 (2024), OWASP Mobile Top 10*
