# 양동이 스킨 전면 리디자인

**날짜**: 2026-04-11
**유형**: 리팩토링 | 디자인 수정

## 변경 사항
- 모놀리식 BucketView(332줄)를 BucketShapeProvider 프로토콜 기반 어셈블러로 전환
- 6종 스킨에 고유 형태/재질 부여 (Wood 배럴, Iron 직벽, Platinum 숄더, Gold 챌리스, Diamond 팔각, Rainbow 웨이브)
- Canvas 텍스처 오버레이 전면 제거 → 그래디언트 + blendMode 기반 재질 표현
- 1pt 엣지 림 라이트, .screen specular 하이라이트
- 손잡이(handle) 제거, handlePath 프로토콜에서 삭제
- 동적 비/물 프로퍼티 5종 추가 (topOpeningFraction, bottomWidthFraction, waterMaskScale, maxFillHeight, bottomInsetFraction)
- TimelineView 기반 물 애니메이션으로 전환 (@State repeatForever 프리즈 버그 수정)
- iOS v1.1.0에도 동일 적용

## 이유
- 기존 6개 스킨이 색상만 다르고 형태가 동일 → 스킨 간 차별화 부족
- Canvas 오버레이(나무결, 리벳 등)가 "공예품" 느낌 → Apple 디자인 철학에 부합하지 않음
- Gemini 리서치: "빛이 재질을 정의한다, 텍스처를 그리지 않는다"

## 기술적 결정
- **프로토콜 기반 vs 모놀리식 switch**: 프로토콜 선택 — 스킨별 파일 분리로 Single Responsibility, 각 ~150줄
- **AnyBucketSkin 타입 이레이저**: enum 경계에서 1회만 적용 (Codex 권고)
- **TimelineView vs @State repeatForever**: TimelineView 선택 — 시스템 클록 기반이라 뷰 라이프사이클에 안정적
- **animatableData: progress만 유지**: waveOffset은 TimelineView가 직접 구동, progress는 drain 보간용

## 변경 파일
- `Features/Timer/Bucket/BucketShapeProvider.swift` (신규)
- `Features/Timer/Bucket/BucketView.swift` (전면 재작성)
- `Features/Timer/Bucket/WaterSurfaceView.swift` (추출)
- `Features/Timer/Bucket/Skins/*.swift` (6개 신규)
- `Core/Models/BucketSkin.swift` (색상 프로퍼티 제거, shapeProvider 추가)
- `Features/Timer/TimerSceneView.swift` (동적 비/물 영역)
- `Features/Settings/SettingsScreen.swift` (팔레트 참조 변경)

## 관련 커밋
- `51ce188` redesign: Apple-style premium bucket skins v2
- `1e7cc17` feat: add dynamic rain area and water fill per skin
- `f12f7e2` fix: address code review issues
