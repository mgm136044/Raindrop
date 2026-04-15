# 성능 최적화 (CPU 35-65% 감소)

**날짜**: 2026-04-14
**유형**: 리팩토링 | 버그 수정

## 변경 사항

### 1차 최적화 (Codex 분석 기반)
- **OverflowAnimationView**: sparkles.isEmpty 게이트 — 비활성 시 TimelineView 완전 중단
- **BucketView**: bodyPath 6회→1회 통합 (local let), 30fps 캡 (ProMotion 120Hz 대응)
- **TerrariumCanvasLayer**: reduceAnimations 게이트 — 시트/일시정지 시 정적 렌더
- **WaterSplashView**: @State frameCount → Date 기반 계산 (이중 무효화 해소)

### 2차 최적화 (Gemini + Codex 전체 감사)
- **DeepOceanParticleView**: RunLoop Timer → TimelineView(.animation(minimumInterval: 1/15)) — 가시성 자동 일시정지
- **CloudView**: repeatForever 애니메이션 → TimelineView sin 기반 drift — 애니메이션 누적 완전 제거
- **SkyBackgroundView**: onChange(of: progress) 가드 — progress ≥ 0.5이면 NSColor 변환 스킵 + 임계값 crossing 감지

### 리뷰에서 발견된 추가 수정
- compositingGroup() 제거 (.screen blendMode 깨짐 방지)
- WaterSplashView: timeline.date 파라미터 전달 + startDate 리셋
- OverflowAnimationView: fade-in 1사이클 지연 (TimelineView 삽입 대기)
- TerrariumCanvasLayer: 정적 렌더에 ambient particles 포함
- Sky progress guard: 임계값 crossing 시 업데이트 허용 (storm 전환 누락 방지)

## 이유
- 사용자가 높은 리소스 소비를 보고
- Codex 분석: 매 프레임 ~4,770회 path 재계산, 비활성 TimelineView 3개 계속 동작
- Gemini 감사: DeepOceanParticleView RunLoop 타이머, CloudView repeatForever 누적, 불필요한 NSColor 변환

## 기술적 결정
- **drawingGroup() 제거**: compositingGroup()도 .screen blendMode를 깨뜨릴 수 있어 완전 제거
- **CloudView repeatForever → TimelineView sin()**: repeatForever는 SwiftUI에서 취소 불가 — TimelineView 기반 시간 함수가 유일한 안전한 대안
- **BucketView 30fps 캡**: `.animation(minimumInterval: 1.0/30.0)` — 물 파도에 60fps 불필요
- **reduceAnimations 스레딩**: TimerSceneView → TerrariumView → TerrariumCanvasLayer 3단계 파라미터 전달

## 변경 파일
- `Features/Timer/Bucket/BucketView.swift`
- `Features/Timer/OverflowAnimationView.swift`
- `Features/Timer/WaterSplashView.swift`
- `Features/Timer/CloudView.swift`
- `Features/Timer/SkyBackgroundView.swift`
- `Features/Terrarium/Views/TerrariumCanvasLayer.swift`
- `Features/Terrarium/Views/TerrariumView.swift`
- `Features/Timer/TimerSceneView.swift`

## 관련 커밋
- `59cf762` perf: 5 resource optimizations
- `8ad9502` fix: address optimization review issues
- `3ac9e2e` perf: cap BucketView TimelineView to 30fps
- `3e967d7` perf: final resource audit fixes
- `bd27fa3` fix: CloudView repeatForever → TimelineView
- `8ac72d6` fix: sky progress guard — allow update when crossing 0.5 threshold
