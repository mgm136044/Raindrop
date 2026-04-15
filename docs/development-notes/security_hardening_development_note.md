# 보안 강화 (KISA 감사 기반)

**날짜**: 2026-04-15
**유형**: 버그 수정 | 설정 변경

## 변경 사항
- 개발자 코드 검증: 평문 비교 → XOR 난독화 → SHA256 해시 (3단계 진화)
  - `strings` 바이너리 추출로 코드 역추출 불가
  - CryptoKit SHA256 사용, 해시값만 바이너리에 포함
- Firebase 에러 메시지: 내부 에러코드/localizedDescription 사용자 노출 제거
  - logger.error()로만 상세 기록, 사용자에겐 일반화된 메시지
- UpdateService 셸 스크립트: 모든 변수 인용 처리 (brewPath, scriptPath, logPath)
  - 공백/특수문자 포함 경로에서 인젝션 방지
- AppleSignInCoordinator: `NSApp.windows.first!` → optional 안전 처리

## 이유
- KISA 시큐어코딩 + CII(Unix/PC) 보안 감사 수행 결과 10건 발견 (0 Critical, 1 High, 5 Medium, 4 Low)
- High: 개발자 코드 평문 노출 → SHA256 해시로 해결
- Medium: force unwrap 크래시 위험, 셸 인젝션 가능성, 에러 정보 누출

## 기술적 결정
- **SHA256 vs Keychain**: SHA256 해시 선택 — Keychain은 초기 설정이 필요하고 개발자 도구 수준에는 과도함
- **XOR → SHA256**: Code Reviewer가 XOR은 바이너리 분석으로 역추출 가능하다고 지적하여 업그레이드
- **에러 메시지 일반화**: 사용자에겐 "실패했습니다" + 복구 안내, 개발자에겐 logger로 상세 기록

## 변경 파일
- `Features/Settings/SettingsScreen.swift` (CryptoKit import + SHA256 isValidDevCode)
- `Features/Auth/AppleSignInCoordinator.swift` (force unwrap 제거)
- `Features/Auth/AuthViewModel.swift` (에러 메시지 일반화)
- `Core/Services/UpdateService.swift` (셸 변수 인용)

## 추가 수정 (Codex 리뷰 후속)
- UpdateService: `updateResult`에 `error.localizedDescription` 직접 노출 → 일반화 메시지로 교체
- AuthViewModel 17010: "잘못된 API 키입니다. Firebase 설정을 확인하세요." → logger.fault + 일반 메시지 ("실패했습니다. 잠시 후 다시 시도해 주세요.")
- AuthViewModel 17995: "Keychain 접근 오류" 기술 용어 제거 → "앱을 재설치하거나 개발자에게 문의하세요."

## 관련 커밋
- `a097180` security: fix audit findings (1 high, 3 medium)
- `c23be59` security: upgrade dev code from XOR to SHA256 hash
- `3d0382e` feat: v2.9.1 — security hardening
- `7e48adb` security: generalize remaining error messages (Codex review follow-up)
