# 물 애니메이션 버그 수정 모음

**날짜**: 2026-04-12 ~ 2026-04-13
**유형**: 버그 수정

## 변경 사항

### 물 슬로싱 제거 (v2.8.1)
- WaterSurfaceShape/Highlight에서 tiltAngle, slopeFactor, slosh 완전 제거
- BucketView에서 tiltAngle 파라미터 제거
- 양동이 탭 워블(rotationEffect)은 유지 — 물과 분리

### 물 마스크 바닥 정렬 (v2.8.2)
- `.scale(waterMaskScale)` → `.scaleEffect(waterMaskScale, anchor: .bottom)` 변경
- `.scale()`은 중앙 기준 축소라 마스크 바닥이 위로 올라가 물이 안 보였음
- bottomInsetFraction을 실제 bodyPath 바닥에 정밀 맞춤 (Wood/Iron/Platinum=1.0, Gold/Diamond/Rainbow=0.92)

### 물 빠짐(drain) 애니메이션 복원 (v2.8.3)
- animatableData에 progress 추가 — withAnimation 보간 가능해짐
- AnimatablePair에서 waveOffset 제거 — TimelineView 직접 구동과 충돌 방지

### 무한 모드 물 채움 고착 수정 (v2.8.3)
- drain의 easeIn 애니메이션 컨텍스트가 다음 사이클 progress에 상속되는 문제
- isDraining/isCycleDraining Task 완료 후 withTransaction(animation: nil)로 강제 클리어
- onChange(of: currentProgress)에서는 implicit animation 유지 (부드러운 채움)

## 이유
- 물 슬로싱이 파도 애니메이션과 충돌하여 물이 뚝뚝 끊겨 보임
- bottomInsetFraction 변경 후 마스크 위치가 안 맞아 물이 보이지 않는 버그
- animatableData에 waveOffset만 있어 progress 변화를 Shape가 보간하지 못함
- withAnimation의 easeIn 컨텍스트가 다음 프레임까지 상속되어 progress가 0에 고착

## 기술적 결정
- **animatableData: progress만**: waveOffset은 TimelineView가 매 프레임 직접 값을 주므로 animatableData에 포함하면 충돌
- **withTransaction(animation: nil)**: drain 완료 시점에만 적용, 일반 fill에는 implicit animation 유지

## 변경 파일
- `Features/Timer/Bucket/WaterSurfaceView.swift`
- `Features/Timer/Bucket/BucketView.swift`
- `Features/Timer/StickerPlacementView.swift`
- `Features/Timer/TimerSceneView.swift`
- `Features/Timer/Bucket/Skins/*.swift` (bottomInsetFraction 수정)

## 관련 커밋
- `c8f0ed1` fix: remove wobble/tilt physics
- `c03be3e` fix: restore bucket wobble on tap, keep water slosh removed
- `6fdaee7` fix: water mask anchor from center to bottom
- `098bd1e` fix: restore water drain animation — add progress to animatableData
- `14b29a6` fix: separate progress animation from waveOffset in animatableData
- `1de8e36` fix: infinite mode water freeze
- `1a5f01c` fix: restore implicit animation for normal fill
