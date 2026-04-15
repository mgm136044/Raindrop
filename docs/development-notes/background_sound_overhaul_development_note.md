# 배경 사운드 기능 전면 개편

**날짜**: 2026-04-10
**유형**: 기능 추가 | 리팩토링

## 변경 사항
- WKWebView 기반 백색소음 재생 → AVAudioPlayer + 번들 m4a 방식으로 완전 교체
- BackgroundSound enum 신규 정의 (10종: 빗소리, 지붕 위 빗소리, 바다, 시냇물, 모닥불, 밤, 고요한 밤, 화이트/핑크/브라운 노이즈)
- BackgroundSoundService: AVAudioPlayer 기반 재생/정지/볼륨 제어
- BackgroundSoundScreen(WhiteNoiseScreen): 사운드 선택 UI + 볼륨 슬라이더 + 미리듣기
- deploy.sh에 SPM 리소스 번들(.bundle) 자동 복사 로직 추가
- 무한 모드 양동이 코인이 히스토리에 반영되지 않는 버그 수정 (FocusSession.bucketsEarned 필드 추가)

## 이유
- WKWebView 기반은 인터넷 연결 필수 + 로딩 시간 + 불안정
- 오프라인 사용 가능한 앱 내장 사운드로 전환 필요
- 무한모드 코인이 히스토리에 안 나오는 사용자 보고

## 기술적 결정
- **AVAudioPlayer vs AVPlayer**: AVAudioPlayer 선택 — 짧은 루프 파일에 적합, 메모리 직접 로딩으로 재생 지연 없음
- **WKWebView 완전 제거**: 인터넷 의존성 0으로 만들기 위해
- **번들 m4a**: 9초 루프 파일로 용량 최소화 (이후 v2.7.0에서 HQ로 교체됨)

## 변경 파일
- `Core/Services/BackgroundSoundService.swift` (신규)
- `Features/WhiteNoise/WhiteNoiseScreen.swift` (전면 재작성)
- `Resources/BackgroundSounds/` (10개 m4a 파일)
- `Core/Models/FocusSession.swift` (bucketsEarned 필드)
- `deploy.sh` (리소스 번들 복사)

## 관련 커밋
- v2.6.0 배경 사운드 전면 개편
- v2.6.1 타이머 중 배경 사운드 활성화 수정
