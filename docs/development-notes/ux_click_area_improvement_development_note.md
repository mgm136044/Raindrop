# UX 클릭 영역 개선

**날짜**: 2026-04-12 ~ 2026-04-13
**유형**: 디자인 수정

## 변경 사항
- 7건 `.contentShape(Rectangle/Circle())` 추가:
  - SettingsScreen: 스킨 선택 버튼 행 전체
  - CalendarHeatmapView: 월 이동 chevron 2개 (32x32 탭 영역) + 날짜 셀
  - TimerControlsView: compact 원형 버튼 (.contentShape(Circle()))
  - StickerEditorScreen: 스티커 팔레트 + "전체 삭제" 버튼
- PrimaryButtonStyle에 `.contentShape(RoundedRectangle)` 추가 — 집중 시작/정지 등 전체 버튼
- 스티커 에디터: 양동이+스티커 동시 워블 (onTapGesture를 BucketView에만 → 제스처 충돌 해소)
- 워블 타이밍 0.05s → 0.35s 전체 통일

## 이유
- macOS에서 `.buttonStyle(.plain)` 사용 시 텍스트만 클릭 가능 — 행 전체를 클릭할 수 없어 UX 저하
- 스티커 에디터에서 양동이만 흔들리고 스티커는 가만히 있는 부자연스러움
- 워블 0.05s는 스프링 애니메이션(~300ms)이 정착하기 전에 리셋되어 끊김

## 기술적 결정
- **contentShape 위치**: 버튼 label 내부 (buttonStyle 이전) — SwiftUI 제스처 시맨틱에 부합
- **Circle vs Rectangle**: 원형 버튼은 `.contentShape(Circle())`, 행은 `.contentShape(Rectangle())`
- **스티커 에디터 제스처**: onTapGesture를 BucketView에만, rotationEffect는 ZStack 전체 — 드래그와 충돌 없음

## 변경 파일
- `Features/Settings/SettingsScreen.swift`
- `Features/History/CalendarHeatmapView.swift`
- `Features/Timer/TimerControlsView.swift`
- `Features/Shop/StickerEditorScreen.swift`
- `Shared/Components/PrimaryButtonStyle.swift`
- `Features/Timer/StickerPlacementView.swift`
- `Features/History/WeeklyDensityView.swift`

## 관련 커밋
- `b624d00` fix: add contentShape to all clickable areas
- `e158d4b` fix: add contentShape to PrimaryButtonStyle
- `da96c54` fix: wobble bucket + stickers together in sticker editor
- `ccfb099` fix: resolve gesture conflict + unify wobble timing to 0.35s
