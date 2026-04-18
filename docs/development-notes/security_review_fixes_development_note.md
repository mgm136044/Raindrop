# Security Review Fixes

**날짜**: 2026-04-17
**유형**: 버그 수정 / 보안 강화

## 변경 사항

### Fix 1: Firestore rules — friendRequests / friendships 소유권 제한
- `friendRequests`: 기존 `allow read, write: if request.auth != null` (인증만 확인) →
  - read: fromUID 또는 toUID가 본인일 때만
  - create: fromUID가 본인이고, 자기 자신에게 요청 불가 (fromUID != toUID)
  - update: toUID(수신자)만 가능 (수락/거절)
  - delete: fromUID 또는 toUID 모두 가능
- `friendships`: 기존 open write → members 배열에 본인 uid가 포함된 경우만 read/create/delete 허용

### Fix 2: Rate limiting 영속화 + signUpWithEmail 적용
- `lockoutUntil`: 인메모리 변수 → UserDefaults `auth_lockout_until` (TimeInterval) 기반 computed property
- `loginAttemptsRemaining`: init 시 UserDefaults `auth_attempts_remaining`에서 복원
- `setAttemptsRemaining(_:)` 헬퍼 추가 — Published 값과 UserDefaults를 동시에 갱신
- `signUpWithEmail`에 동일한 lockout 체크 추가 (계정 열거 공격 방지)

### Fix 3: Nickname — ASCII 범위로 CharacterSet 교체
- 기존 `CharacterSet.alphanumerics`는 Unicode 전체 알파벳 포함 (예: 아랍어, 키릴 문자 등 허용됨)
- 명시적 범위 `"a"..."z"`, `"A"..."Z"`, `"0"..."9"` + 한글 음절(`\u{AC00}`...`\u{D7A3}`) + `" _-"`로 교체

### Fix 4: Self-guard — UI 에러 메시지 추가
- `FriendsViewModel.sendRequest(to:)`의 자기 자신 guard에 `errorMessage` 피드백 추가
- 사용자가 실수로 자신에게 요청 시 "자신에게는 친구 요청을 보낼 수 없습니다." 표시

## 이유
- Firestore rules가 인증 여부만 확인하여 임의 사용자가 타인의 친구 요청을 읽거나 수정 가능한 취약점 존재
- lockout이 인메모리에만 저장되어 앱 재시작 시 브루트포스 카운터가 초기화되는 문제
- `CharacterSet.alphanumerics`가 비ASCII 유니코드 문자를 허용해 닉네임 필터링 우회 가능
- self-guard가 silently return 하여 UI에 피드백 없음

## 기술적 결정
- lockoutUntil을 computed property로 구현해 get/set 시 자동으로 UserDefaults 동기화 — 호출부 변경 최소화
- signUp에도 동일 lockout 적용: 계정 열거(account enumeration) 공격에서 signIn과 signUp을 별도로 제한하면 우회 가능하기 때문
- CharacterSet range init(`"a"..."z"`)은 Swift 표준 API로 가독성과 정확성 모두 확보

## 변경 파일
- `firestore.rules`
- `Sources/RainDrop/Features/Auth/AuthViewModel.swift`
- `Sources/RainDrop/Features/Social/FriendsViewModel.swift`

## 관련 커밋
- `ad66672` security: address review issues — tighter rules, persistent lockout, ASCII nicknames
