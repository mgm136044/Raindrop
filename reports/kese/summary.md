# RainDrop 보안 취약점 분석평가 보고서

> 평가 기준: KISA 주요정보통신기반시설(CII) + 시큐어코딩 가이드
> 평가 대상: RainDrop macOS 집중 타이머 앱 v2.5.0
> 평가 일시: 2026-04-09

---

## 평가 요약

| 등급 | 항목 수 | 설명 |
|:----:|:------:|------|
| 긴급 | **1** | Firebase API Key 소스코드 하드코딩 |
| 높음 | **2** | 셸 스크립트 생성, Firestore 역직렬화 |
| 보통 | **3** | 개발자 코드 하드코딩, 초대코드 난수, Keychain 불일치 |
| 양호 | **6** | HTTPS, 경로처리, 리소스해제, 디버그코드, TLS, 랜덤(UI) |

### 점수: 79 / 100 (양호)

---

## 긴급 (즉시 조치)

### [SC-01] Firebase API Key 하드코딩 (CWE-259, CWE-321)

| 항목 | 내용 |
|------|------|
| 파일 | `Core/Firebase/FirebaseSecrets.swift:5-8` |
| 중요도 | **긴급** |
| 판단 | **취약** |

- `apiKey`, `googleAppID`, `gcmSenderID`, `projectID` 평문 하드코딩
- .gitignore 적용으로 저장소 노출 방지 (부분 이행)
- 컴파일된 바이너리에 키가 포함되어 리버스 엔지니어링으로 추출 가능

**조치 방안:**
1. Firebase Console에서 API Key 재생성
2. Firebase App Check 활성화 (앱 인증 토큰 필수화)
3. API Key 제한 설정 (번들 ID 바인딩)

---

## 높음 (일정 내 조치)

### [SC-02] 셸 스크립트 문자열 보간 생성 (CWE-78)

| 항목 | 내용 |
|------|------|
| 파일 | `Core/Services/UpdateService.swift:69-87` |
| 중요도 | **높음** |
| 판단 | **부분이행** |

- `brewPath`를 문자열 보간으로 셸 스크립트에 삽입
- `/tmp/raindrop_update.sh`에 작성 (world-writable 디렉터리)
- `brewPath`는 2개 고정 경로만 허용 (검증 존재)

**조치 방안:**
1. `mktemp`으로 임시 파일 경로 생성 (예측 불가)
2. `Process.arguments` 배열로 인자 전달 (셸 해석 우회)

### [SC-03] Firestore 역직렬화 타입 강제변환 (CWE-502)

| 항목 | 내용 |
|------|------|
| 파일 | `Core/Firebase/FirestoreService.swift:204-236` |
| 중요도 | **높음** |
| 판단 | **부분이행** |

- `decodeInt`: String→Int, NSNumber→Int 등 유연한 타입 변환
- Codable 디코딩 실패 시 fallback으로 진입
- 악의적 타입 주입 시 예상치 못한 동작 가능

**조치 방안:**
1. Strict 스키마 검증 (타입 일치 강제)
2. Fallback 제거 후 Codable 실패 시 nil 반환

---

## 보통 (개선 권고)

### [SC-04] 개발자 모드 코드 하드코딩 (CWE-259)

| 항목 | 내용 |
|------|------|
| 파일 | `Features/Settings/SettingsScreen.swift:304` |
| 중요도 | **보통** |
| 판단 | **부분이행** |

- `if devCode == "0530"` — 바이너리에서 추출 가능
- 개발자 모드: 전 아이템 해금 (상점 코인 우회)
- 금전적 영향 없음 (인앱 결제 미사용)

**조치 방안:** 원격 플래그 또는 빌드 설정 기반으로 전환 권고

### [SC-05] 초대코드 생성 시 비암호학적 난수 (CWE-330)

| 항목 | 내용 |
|------|------|
| 파일 | `Features/Auth/AuthViewModel.swift:170` |
| 중요도 | **보통** |
| 판단 | **부분이행** |

- `.randomElement()` 사용 (Swift stdlib, 비암호학적)
- DB 유니크 제약으로 충돌 방지 (완화)

**조치 방안:** `SecRandomCopyBytes` 기반으로 교체

### [SC-06] Keychain 설정 불일치

| 항목 | 내용 |
|------|------|
| 파일 | `FirebaseConfig.swift:20` + `RainDrop.entitlements:8` |
| 중요도 | **보통** |
| 판단 | **부분이행** |

- entitlements에 keychain-access-groups 선언
- 런타임에서 `useUserAccessGroup(nil)` 호출 (기본 키체인 사용)
- 사용하지 않는 entitlement 잔존

**조치 방안:** 미사용 시 entitlements에서 제거

---

## 양호 (보안 설정 적절)

| 코드 | 항목 | 판단 |
|------|------|:----:|
| SC-07 | HTTPS 전용 통신 | 양호 |
| SC-08 | 파일 경로 안전 처리 (appendingPathComponent) | 양호 |
| SC-09 | 리소스 해제 (Timer, WKWebView, Firestore Listener) | 양호 |
| SC-10 | 디버그 코드 `#if DEBUG` 격리 | 양호 |
| SC-11 | SSL/TLS 인증서 검증 (URLSession 기본값) | 양호 |
| SC-12 | 암호학적 보안 난수 (Apple Sign-In nonce) | 양호 |

---

## 해당없음

| CII 항목 | 사유 |
|----------|------|
| SQL Injection (SI) | DB 직접 접근 없음 (Firestore SDK) |
| XSS (XS) | 웹 렌더링 없음 (네이티브 SwiftUI) |
| CSRF (CF) | 웹 폼 없음 |
| File Upload (FU) | 파일 업로드 기능 없음 |
| Brute Force (BF) | Firebase Auth 자체 제한 적용 |
| Session Management (IS) | Firebase Auth 토큰 관리 위임 |

---

## 시큐어코딩 평가 결과 (7개 카테고리)

| # | 카테고리 | 항목 수 | 양호 | 부분이행 | 취약 | 해당없음 |
|---|---------|:------:|:----:|:------:|:----:|:------:|
| 1 | 입력데이터 검증 | 16 | 2 | 1 | 0 | 13 |
| 2 | 보안기능 | 16 | 4 | 3 | 1 | 8 |
| 3 | 시간 및 상태 | 2 | 2 | 0 | 0 | 0 |
| 4 | 에러처리 | 3 | 2 | 1 | 0 | 0 |
| 5 | 코드오류 | 3 | 2 | 0 | 0 | 1 |
| 6 | 캡슐화 | 4 | 3 | 1 | 0 | 0 |
| 7 | API 오용 | 2 | 1 | 0 | 0 | 1 |
| | **합계** | **46** | **16** | **6** | **1** | **23** |

---

## 조치 우선순위 로드맵

```
[긴급] SC-01 Firebase API Key → App Check 활성화 + Key 재생성
  ↓
[높음] SC-02 셸 스크립트 → mktemp + Process.arguments
[높음] SC-03 Firestore fallback → Strict 스키마
  ↓
[보통] SC-04 개발자 코드 → 빌드 설정 기반
[보통] SC-05 초대코드 → SecRandomCopyBytes
[보통] SC-06 Keychain → entitlements 정리
```
