# RainDrop Design Document

## Overview

macOS/iOS focus timer app. "Fill your life's density." Water fills a bucket as the user focuses. Apple design philosophy + macOS 26 Liquid Glass.

## Architecture

### Core Pattern
- **MVVM + DI Container** — `AppContainer` with lazy var services/viewmodels
- **BucketShapeProvider Protocol** — Each skin defines its own shape, colors, animation, and dynamic properties
- **AnyBucketSkin Type Erasure** — Applied once at `BucketSkin` enum boundary
- **TimelineView-based Animation** — Continuous wave animation driven by system clock (not @State repeatForever)

### Rendering Pipeline (BucketView)
```
ZStack {
  1. Body fill (gradient)
  2. Water back layer (WaterSurfaceShape, 0.45 opacity)
  3. Water front layer (WaterSurfaceShape, full opacity)
  4. Surface highlight (WaterSurfaceHighlight)
  5. Skin overlay (gradient-based material, NOT Canvas textures)
  6. Bands (thin, 1pt)
  7. Edge rim light (1pt white→transparent gradient stroke)
  8. Specular highlight (.screen blend)
  9. Rim (subtle edge light)
}
```

### Dynamic Properties Per Skin
Each skin provides 5 spatial properties for rain/water adaptation:
- `topOpeningFraction` — Cloud width matches bucket opening
- `bottomWidthFraction` — Rain covers full bucket width
- `waterMaskScale` — Water clips to skin shape
- `maxFillHeight` — Water level matches interior height
- `bottomInsetFraction` — Rain lands at bucket floor

## Implementation Plan

### Patterns
- **Protocol-based skins** over monolithic switch statements
- **Gradient materials** over Canvas-drawn textures (Apple design principle: light defines material)
- **TimelineView** over @State repeatForever (reliable across view lifecycle)
- **Spring animations** over linear (Apple never uses linear for UI)

### Libraries
- SwiftUI (primary UI framework)
- AVAudioPlayer (background sounds, bundle m4a files)
- Firebase Auth + Firestore (disabled by default, `socialEnabled = false`)

### Key Decisions

| Decision | Choice | Rationale | Date |
|----------|--------|-----------|------|
| Skin rendering | BucketShapeProvider protocol | Single Responsibility, each skin ~150 lines | 2026-04-10 |
| Material feel | Gradient + blendMode | Apple design: "light defines material, not drawn textures" | 2026-04-11 |
| Edge treatment | 1pt white→transparent gradient | Apple subpixel edge technique (not thick outlines) | 2026-04-11 |
| Wave animation | TimelineView(.animation) | @State repeatForever freezes on tab switch/background | 2026-04-11 |
| Handle | Removed | Cleaner design, less visual noise | 2026-04-11 |
| Noise sounds | Removed (White/Pink/Brown) | Too harsh texture, replaced with Apple ComfortSounds HQ | 2026-04-11 |
| Vessel system | Rolled back | Attempted T1-T6 abstract vessels, user preferred buckets | 2026-04-11 |
| Cross-platform sync | iOS → macOS port | iOS is source of truth, macOS mirrors | 2026-04-11 |
| Dev mode access | Code toggle (0530), no #if DEBUG | Accessible in Release builds for testing | 2026-04-11 |

## TODO

- [ ] macOS pause state background sound bug (isSessionActive vs isRunning)
- [ ] iOS app icon (Assets.xcassets)
- [ ] iOS TestFlight deployment (needs Apple Developer Program)
- [ ] Additional background themes (currently only deep ocean)
- [ ] Consider shared BucketRendering SPM package for cross-platform code reuse

## Open Questions

- Should `MainActor.assumeIsolated` in Shape.path() be replaced with a safer pattern? (Codex flagged as HIGH risk)
- Future skin progression: keep buckets or revisit vessel concept?
- Windows port feasibility (user mentioned as future consideration)

## Changelog

### 2026-04-11
- Created DESIGN.md
- Recorded: BucketShapeProvider protocol architecture
- Recorded: Apple design philosophy decisions (gradients over textures, thin edges)
- Recorded: TimelineView wave animation decision
- Recorded: Vessel system attempt and rollback
- Recorded: Sound quality upgrade decisions
- Recorded: Cross-platform sync strategy (iOS → macOS)
