# 배경 사운드 품질 업그레이드

**날짜**: 2026-04-11
**유형**: 기능 추가 | 디자인 수정

## 변경 사항
- 노이즈 3종(WhiteNoise/PinkNoise/BrownNoise) 삭제
- Rain, Ocean, Fire를 Apple ComfortSounds HQ 버전으로 교체 (~10분, 48kHz AAC)
- Airplane 앰비언스 추가 (Apple ComfortSounds, 19MB)
- 총 10종 → 8종으로 축소
- BackgroundSound enum에 하위 호환 커스텀 디코더 추가 (기존 노이즈 선택 → .rain 폴백)
- 배경 사운드 선택 UX 개선 (.contentShape로 행 전체 클릭 가능)

## 이유
- 핑크/화이트/브라운 노이즈의 질감이 너무 거칠어 사용자 불만
- 기존 파일 9초 루프 vs Apple ComfortSounds ~10분 — 품질 차이 극심
- macOS 손쉬운 사용 → 배경 사운드에서 동일 파일 확인, 프로젝트 에셋으로 복사 (시스템 경로 참조 아님)

## 기술적 결정
- **시스템 파일 참조 vs 복사**: 복사 선택 — 시스템 경로 의존 시 업데이트/삭제에 취약
- **노이즈 제거 vs 교체**: 제거 + Airplane 추가 — 노이즈 대안으로 비행기 엔진 저주파 앰비언스가 적합

## 변경 파일
- `Core/Services/BackgroundSoundService.swift` (enum 변경 + 커스텀 디코더)
- `Resources/BackgroundSounds/` (3파일 삭제, 4파일 교체/추가)
- `Features/WhiteNoise/WhiteNoiseScreen.swift` (.contentShape 추가)

## 관련 커밋
- `eca57a8` feat: v2.7.0 — bucket skin redesign + sound quality upgrade
