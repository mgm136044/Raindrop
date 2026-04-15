# RainDrop 보안 취약점 분석평가 보고서

> 평가 기준: KISA 주요정보통신기반시설(CII) + 시큐어코딩 가이드
> 평가 대상: RainDrop macOS 집중 타이머 앱 v2.9.0
> 평가 일시: 2026-04-11 (2차 감사)
> 이전 감사: 2026-04-09 (v2.5.0)

---

## 평가 요약

| 등급 | 항목 수 | 설명 |
|:----:|:------:|------|
| 긴급 | **0** | - |
| 높음 | **1** | 개발자 코드 Release 빌드 포함 (CWE-259) |
| 보통 | **5** | 셸 스크립트 인용, force unwrap, 에러 노출, 세션 타임아웃 |
| 낮음 | **4** | 평문 JSON 저장, print문, Task 생명주기 |
| 양호 | **26** | 나머지 모든 항목 |

### 점수: 87 / 100 (양호)

### v2.5.0 대비 개선사항
- [FIXED] SC-02: `mktemp` 도입으로 셸 스크립트 경로 예측 불가능화
- [FIXED] SC-05: 초대코드 생성이 `SecRandomCopyBytes` 기반으로 교체됨
- [IMPROVED] SC-01: Firebase API Key는 `.gitignore` + git 이력 미포함 확인됨 (부분이행→부분이행 유지, App Check 적용 필요)
- [IMPROVED] SC-03: Firestore fallback이 `#if DEBUG`로 격리됨

---

## Audit 1: Secure Coding (KISA 7 Categories)

### 높음 (1건)

#### [SC-SF-02] 개발자 코드 Release 빌드 포함 (CWE-259)
| 항목 | 내용 |
|------|------|
| 파일 | `Features/Settings/SettingsScreen.swift:264` |
| 중요도 | **높음** |
| 판단 | **취약** |

- `if devCode == "0530"` — `#if DEBUG` 없이 Release 빌드에 포함
- `strings RainDrop` 명령으로 코드 추출 가능
- 개발자 모드: 전 아이템 해금 (상점 코인 우회)
- 시도 횟수 제한 없음

**조치 방안:** `#if DEBUG`로 감싸거나, 숨김 제스처 + Keychain 기반으로 전환

---

### 보통 (4건)

#### [SC-IV-04] 셸 스크립트 변수 인용 누락
| 항목 | 내용 |
|------|------|
| 파일 | `Core/Services/UpdateService.swift:91-109` |
| 판단 | **부분이행** |

- mktemp 도입으로 경로 예측 불가능화 (v2.5.0 대비 개선)
- 단, scriptPath/logPath가 셸 스크립트 내에서 인용 없이 보간됨
- **조치:** 셸 변수를 `"$var"` 형태로 인용 처리

#### [SC-CQ-01] Force Unwrap 크래시 위험 (CWE-476)
| 항목 | 내용 |
|------|------|
| 파일 | `Features/Auth/AppleSignInCoordinator.swift:80` |
| 판단 | **취약** |

- `NSApp.windows.first!` — 윈도우 없을 때 크래시
- **조치:** `NSApp.windows.first ?? NSWindow()`로 교체

#### [SC-EN-01] 개발자 모드 UI가 Release에 포함
| 항목 | 내용 |
|------|------|
| 파일 | `Features/Settings/SettingsScreen.swift:256-270` |
| 판단 | **부분이행** |

- SC-SF-02와 동일 근본 원인

#### [SC-EH-01] 내부 에러 정보 UI 노출 (CWE-209)
| 항목 | 내용 |
|------|------|
| 파일 | `Features/Auth/AuthViewModel.swift:208,210` |
| 판단 | **부분이행** |

- Firebase 에러코드 17999: 내부 에러 메시지를 사용자에게 그대로 표시
- default 케이스: 에러 코드 + localizedDescription 노출
- **조치:** 사용자 메시지를 일반화하고 상세 정보는 logger로만 기록

---

### 낮음 (4건)

| 코드 | 항목 | 파일 | 상세 |
|------|------|------|------|
| SC-SF-03 | 평문 JSON 로컬 저장 | `JSONFileStore.swift` | 집중 세션 기록이 평문 JSON. 민감도 낮으나 암호화 없음 |
| SC-EH-03 | print문 사용 | `FirestoreService.swift:24,29` | `#if DEBUG` 내부이나 `os.Logger` 통일 권장 |
| SC-CQ-03 | Task 생명주기 미관리 | `AuthViewModel`, `TimerViewModel` | fire-and-forget Task. @MainActor 격리로 위험 낮음 |
| SC-AM-02 | UpdateService Process 실행 | `UpdateService.swift` | Process() 사용. brewPath 검증 존재하나 방어적 코딩 권장 |

---

### 양호 (16건)

| 코드 | 항목 | 판단 |
|------|------|:----:|
| SC-IV-02 | TextField 입력 정제 (trim) | 양호 |
| SC-IV-03 | URL 구성 (상수 기반) | 양호 |
| SC-IV-05 | JSONFileStore 파일명 (상수) | 양호 |
| SC-IV-06 | Firestore 문서 필드 (Auth UID 기반) | 양호 |
| SC-SF-01 | Firebase 키 git 미추적 | 양호 |
| SC-SF-04 | Keychain 사용 (Firebase Auth) | 양호 |
| SC-SF-05 | 암호학적 난수 (SecRandomCopyBytes) | 양호 |
| SC-SF-06 | HTTPS 전용 통신 | 양호 |
| SC-TS-01 | @MainActor 격리 (경쟁조건 방지) | 양호 |
| SC-TS-02 | repeatForever 애니메이션 (SwiftUI 관리) | 양호 |
| SC-TS-03 | Timer 리소스 관리 (invalidate + nil) | 양호 |
| SC-EH-02 | Logger privacy 어노테이션 | 양호 |
| SC-EH-04 | UpdateService 에러 메시지 (일반화) | 양호 |
| SC-EN-02 | #if DEBUG 블록 격리 | 양호 |
| SC-EN-03 | TODO/FIXME 미존재 | 양호 |
| SC-AM-01 | URL 스킴 보안 (HTTPS only) | 양호 |

---

## Audit 2: CII Unix/PC (macOS Adapted)

| 코드 | 항목 | 판단 | 상세 |
|------|------|:----:|------|
| U-01 | 원격 root 로그인 제한 | 양호 | `PermitRootLogin` 기본값 `prohibit-password` |
| U-02 | 패스워드 정책 | 양호 | 시스템 패스워드 정책 설정됨 |
| U-12 | 세션 타임아웃 | **보통** | `$TMOUT` 미설정. `export TMOUT=3600` 권장 |
| U-14 | PATH 무결성 | 양호 | 이중 콜론/후행 콜론/현재 디렉터리 없음 |
| U-16 | /etc/passwd 권한 | 양호 | 644 (root:wheel) |
| U-23 | SUID 파일 | 양호 | /usr/local에 SUID 파일 없음 |
| U-25 | 프로젝트 내 world-writable 파일 | 양호 | 없음 |
| U-28 | 방화벽 상태 | 양호 | Application Firewall 활성화 (State = 1) |
| U-60 | SSH 버전 | 양호 | OpenSSH 10.2p1, LibreSSL 3.3.6 |
| U-62 | syslog 설정 | 양호 | Unified Logging 활성 |
| U-67 | OS 패치 수준 | 양호 | macOS 26.4.1 (최신) |

---

## 해당없음

| CII 항목 | 사유 |
|----------|------|
| SQL Injection | DB 직접 접근 없음 (Firestore SDK) |
| XSS | 웹 렌더링 없음 (네이티브 SwiftUI) |
| CSRF | 웹 폼 없음 |
| File Upload | 파일 업로드 기능 없음 |
| Brute Force | Firebase Auth 자체 제한 적용 |
| Session Management | Firebase Auth 토큰 관리 위임 |

---

## 시큐어코딩 평가 결과 (7개 카테고리)

| # | 카테고리 | 항목 수 | 양호 | 부분이행 | 취약 | 해당없음 |
|---|---------|:------:|:----:|:------:|:----:|:------:|
| 1 | 입력데이터 검증 | 6 | 4 | 1 | 0 | 1 |
| 2 | 보안기능 | 6 | 4 | 1 | 1 | 0 |
| 3 | 시간 및 상태 | 3 | 3 | 0 | 0 | 0 |
| 4 | 에러처리 | 4 | 2 | 2 | 0 | 0 |
| 5 | 코드오류 | 3 | 1 | 1 | 1 | 0 |
| 6 | 캡슐화 | 4 | 3 | 1 | 0 | 0 |
| 7 | API 오용 | 3 | 2 | 1 | 0 | 0 |
| | **합계** | **29** | **19** | **7** | **2** | **1** |

---

## 조치 우선순위 로드맵

```
[높음] SC-SF-02 / SC-EN-01: 개발자 코드 → #if DEBUG 감싸기
  |
[보통] SC-CQ-01: force unwrap → safe fallback
[보통] SC-IV-04: 셸 스크립트 변수 인용 처리
[보통] SC-EH-01: 에러 메시지 일반화
[보통] U-12: TMOUT 환경변수 설정
  |
[낮음] SC-SF-03: JSON 저장소 암호화 검토
[낮음] SC-EH-03: print → os.Logger 통일
[낮음] SC-CQ-03: Task 핸들 저장 + cancellation
[낮음] SC-AM-02: Process 실행 방어적 코딩
```

---

## 상세 보고서

- [Secure Coding (KISA 7 Categories)](technical/secure-coding.md)
- [Unix/PC System Checks](technical/unix-pc.md)
