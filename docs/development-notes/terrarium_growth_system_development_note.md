# 테라리움 성장 시스템 도입

**날짜**: 2026-04-12
**유형**: 기능 추가 | 리팩토링

## 변경 사항
- 구 환경/날씨 시스템 완전 제거 (EnvironmentLevel, WeatherState, WaterColorProgression, EnvironmentView, WeatherOverlayView)
- 온보딩 기능 완전 제거 (4개 뷰 + hasSeenOnboarding)
- 테라리움 성장 시스템 신규 구축:
  - 50 바이탈리티 레벨, 4단계 (발아→개화→만개→초월)
  - 이차 곡선: 9000분(~150시간) → 레벨 50
  - 6 바이옴: 숲(Wood), 산업(Iron), 크리스털(Platinum), 왕실(Gold), 얼음(Diamond), 마법(Rainbow)
  - SeededRNG 결정적 식물 배치 (시드 디스크 영구 저장)
  - Canvas 30fps 렌더링, 10개 PlantType, 발광/파티클
- 가든 탭 추가 (Activity Ring 레벨 링, 4단계 캡슐 바, 통계)
- 설정 탭 4개 (집중/스킨/가든/기타)

## 이유
- 기존 환경/날씨 시스템이 "변화가 너무 미묘해서 안 보임" — 사용자가 성장을 인지하지 못함
- Gemini 리서치: 테라리움이 "채운다→키운다" 심리적 전환에 가장 적합
- Codex 권고: 별도 GrowthState 모델 + TerrariumView가 BucketView 래핑

## 기술적 결정
- **GrowthState 분리 vs ShopState 통합**: 분리 선택 — 경제 로직과 성장 로직 독립 진화
- **TerrariumView 래핑 vs BucketView 내장**: 래핑 선택 — BucketView 재사용성 유지
- **drawingGroup 범위**: Canvas 레이어에만 적용 (BucketView 자체 애니메이션 독립 유지)
- **식물 배치**: 템플릿 + 시드 변형 — 큐레이션된 느낌 + 다양성

## 변경 파일
- `Features/Terrarium/Model/` (Biome, GrowthState, GrowthSnapshot, PlantTemplate — 4개 신규)
- `Features/Terrarium/Services/` (GrowthCurve, GrowthEngine, PlantLayoutEngine — 3개 신규)
- `Features/Terrarium/Views/` (TerrariumCanvasLayer, TerrariumView — 2개 신규)
- `Core/Repositories/GrowthRepository.swift` (신규)
- `Core/Models/AppSettings.swift` (hasSeenOnboarding, waterColorEvolution 제거)
- `Features/Settings/SettingsScreen.swift` (가든 탭 추가, 성장 탭 제거)
- `Features/Timer/TimerSceneView.swift` (TerrariumView 통합)
- 삭제: EnvironmentLevel, WeatherState, WaterColorProgression, EnvironmentView, WeatherOverlayView, Onboarding/* (9개)

## 관련 커밋
- `586d4b3` feat: terrarium growth system — 50 levels, 6 biomes, plant ecosystem
- `285126f` refactor: remove onboarding feature entirely
- `9f40126` feat: v2.8.0 — terrarium growth system + onboarding removal
