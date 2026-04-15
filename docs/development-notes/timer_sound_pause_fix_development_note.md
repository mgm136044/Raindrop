# 타이머 중 배경 사운드 활성화 수정

**날짜**: 2026-04-10
**유형**: 버그 수정

## 변경 사항
- 타이머 실행 중 배경 사운드 활성화 시 정상 동작하도록 수정
- 일시정지 상태에서 배경 사운드 설정 변경 지원
- loadSettings()에서 사운드 변경 감지 로직 추가
- isSessionActive (running + paused) 조건 사용

## 이유
- 타이머가 실행 중일 때 배경 사운드를 켜면 적용되지 않는 버그
- isTimerRunning 가드가 pause 상태를 고려하지 않아 일시정지 중 설정 변경 불가

## 기술적 결정
- **isRunning vs isSessionActive**: isSessionActive (running || paused) 사용 — 일시정지도 "세션 중"에 포함

## 변경 파일
- `Features/Timer/TimerViewModel.swift`
- `Features/WhiteNoise/WhiteNoiseScreen.swift`

## 관련 커밋
- v2.6.1 타이머 실행 중 배경 사운드 활성화 시 정상 동작
