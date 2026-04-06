# 양동이 스킨 시스템 + 비 파티클 리팩토링 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 6종 티어별 양동이 스킨(나무→무지개) 해금 시스템 도입 + 물방울을 작고 많은 비 파티클로 교체 + 구름 애니메이션 추가

**Architecture:** BucketSkin 모델이 각 스킨의 색상/해금 조건/특수 효과를 정의. BucketView가 skin 파라미터를 받아 렌더링 분기. WaterDropView를 RainParticleView로 교체하여 자연스러운 비 효과 구현. 설정에서 스킨 선택 UI 제공.

**Tech Stack:** SwiftUI, macOS 13+, Canvas API (파티클), TimelineView (애니메이션)

---

## 파일 구조

### 새 파일
| 파일 | 역할 |
|------|------|
| `Sources/RainDrop/Core/Models/BucketSkin.swift` | 스킨 enum, 색상 팔레트, 해금 조건 |
| `Sources/RainDrop/Features/Timer/RainParticleView.swift` | 비 파티클 시스템 (Canvas + TimelineView) |
| `Sources/RainDrop/Features/Timer/CloudView.swift` | 반투명 구름 애니메이션 |

### 수정 파일
| 파일 | 변경 |
|------|------|
| `Sources/RainDrop/Core/Models/AppSettings.swift` | `selectedSkin`, `useCustomWaterColor` 추가 |
| `Sources/RainDrop/Core/Models/ShopState.swift` | 스킨 해금 상태는 `totalBucketsEarned`로 계산 (추가 저장 불필요) |
| `Sources/RainDrop/Features/Timer/BucketView.swift` | `skin` 파라미터 추가, 스킨별 색상 렌더링 |
| `Sources/RainDrop/Features/Timer/StickerPlacementView.swift` | `skin` 전달 |
| `Sources/RainDrop/Features/Timer/TimerScreen.swift` | RainParticleView + CloudView 통합, 스킨 전달 |
| `Sources/RainDrop/Features/Settings/SettingsScreen.swift` | 스킨 선택 UI 추가 |
| `Sources/RainDrop/Shared/Theme/AppColors.swift` | 스킨별 색상 추가 불필요 (BucketSkin에서 직접 정의) |

---

## Task 1: BucketSkin 모델 정의

**Files:**
- Create: `Sources/RainDrop/Core/Models/BucketSkin.swift`

- [ ] **Step 1: BucketSkin enum + 색상 팔레트 작성**

```swift
import SwiftUI

enum BucketSkin: String, Codable, CaseIterable, Sendable {
    case wood
    case dentedIron
    case platinum
    case gold
    case diamond
    case rainbow

    // MARK: - 해금 조건

    var requiredBuckets: Int {
        switch self {
        case .wood: return 0
        case .dentedIron: return 50
        case .platinum: return 150
        case .gold: return 250
        case .diamond: return 1700
        case .rainbow: return 5000
        }
    }

    func isUnlocked(totalBuckets: Int) -> Bool {
        totalBuckets >= requiredBuckets
    }

    // MARK: - 표시 이름

    var displayName: String {
        switch self {
        case .wood: return "나무 양동이"
        case .dentedIron: return "찌그러진 철 양동이"
        case .platinum: return "백금 양동이"
        case .gold: return "금 양동이"
        case .diamond: return "다이아 양동이"
        case .rainbow: return "무지개 양동이"
        }
    }

    var materialDescription: String {
        switch self {
        case .wood: return "오래된 참나무로 만든 소박한 양동이"
        case .dentedIron: return "사용감 있는 철로 만든 튼튼한 양동이"
        case .platinum: return "광택 나는 백금으로 제작된 고급 양동이"
        case .gold: return "순금으로 도금된 화려한 양동이"
        case .diamond: return "다이아몬드 결정으로 빛나는 보석 양동이"
        case .rainbow: return "일곱 빛깔 무지개가 흐르는 전설의 양동이"
        }
    }

    // MARK: - 양동이 색상

    var bucketFill: Color {
        switch self {
        case .wood: return Color(red: 0.55, green: 0.35, blue: 0.18, opacity: 0.72)
        case .dentedIron: return Color(red: 0.35, green: 0.38, blue: 0.42, opacity: 0.72)
        case .platinum: return Color(red: 0.85, green: 0.87, blue: 0.90, opacity: 0.72)
        case .gold: return Color(red: 0.85, green: 0.68, blue: 0.20, opacity: 0.72)
        case .diamond: return Color(red: 0.70, green: 0.85, blue: 0.95, opacity: 0.72)
        case .rainbow: return Color(red: 0.90, green: 0.80, blue: 0.95, opacity: 0.72)
        }
    }

    var bucketStroke: Color {
        switch self {
        case .wood: return Color(red: 0.40, green: 0.25, blue: 0.12)
        case .dentedIron: return Color(red: 0.45, green: 0.48, blue: 0.52)
        case .platinum: return Color(red: 0.75, green: 0.78, blue: 0.82)
        case .gold: return Color(red: 0.75, green: 0.58, blue: 0.10)
        case .diamond: return Color(red: 0.55, green: 0.75, blue: 0.90)
        case .rainbow: return Color(red: 0.70, green: 0.50, blue: 0.80)
        }
    }

    var bucketHandle: Color {
        switch self {
        case .wood: return Color(red: 0.35, green: 0.22, blue: 0.10)
        case .dentedIron: return Color(red: 0.50, green: 0.52, blue: 0.55)
        case .platinum: return Color(red: 0.80, green: 0.82, blue: 0.85)
        case .gold: return Color(red: 0.80, green: 0.62, blue: 0.15)
        case .diamond: return Color(red: 0.60, green: 0.78, blue: 0.92)
        case .rainbow: return Color(red: 0.75, green: 0.55, blue: 0.85)
        }
    }

    var bandColor: Color {
        switch self {
        case .wood: return Color(red: 0.30, green: 0.18, blue: 0.08)
        case .dentedIron: return bucketStroke.opacity(0.4)
        case .platinum: return bucketStroke.opacity(0.5)
        case .gold: return Color(red: 0.90, green: 0.75, blue: 0.25)
        case .diamond: return Color(red: 0.65, green: 0.85, blue: 1.0)
        case .rainbow: return Color(red: 0.80, green: 0.60, blue: 0.90)
        }
    }

    // MARK: - 물 색상

    /// 금 양동이 이상 티어에서 스킨 색 물 사용 가능
    var hasCustomWaterColor: Bool {
        switch self {
        case .wood, .dentedIron, .platinum: return false
        case .gold, .diamond, .rainbow: return true
        }
    }

    var customWaterGradientTop: Color {
        switch self {
        case .gold: return Color(red: 1.0, green: 0.85, blue: 0.35)
        case .diamond: return Color(red: 0.70, green: 0.90, blue: 1.0)
        case .rainbow: return Color(red: 1.0, green: 0.60, blue: 0.60)
        default: return AppColors.waterGradientTopColor
        }
    }

    var customWaterGradientBottom: Color {
        switch self {
        case .gold: return Color(red: 0.85, green: 0.60, blue: 0.05)
        case .diamond: return Color(red: 0.40, green: 0.65, blue: 0.95)
        case .rainbow: return Color(red: 0.50, green: 0.30, blue: 0.90)
        default: return AppColors.waterGradientBottomColor
        }
    }

    var customDropGradientTop: Color {
        switch self {
        case .gold: return Color(red: 1.0, green: 0.90, blue: 0.50)
        case .diamond: return Color(red: 0.80, green: 0.95, blue: 1.0)
        case .rainbow: return Color(red: 1.0, green: 0.70, blue: 0.70)
        default: return AppColors.dropGradientTopColor
        }
    }

    var customDropGradientBottom: Color {
        switch self {
        case .gold: return Color(red: 0.90, green: 0.65, blue: 0.10)
        case .diamond: return Color(red: 0.50, green: 0.70, blue: 1.0)
        case .rainbow: return Color(red: 0.60, green: 0.35, blue: 0.95)
        default: return AppColors.dropGradientBottomColor
        }
    }
}
```

- [ ] **Step 2: 빌드 확인**

Run: `cd /Users/mingyeongmin/development/raindrop_app && swift build -c release 2>&1 | grep -E "(error:|Build complete)"`
Expected: Build complete

> **Note:** `AppColors`에서 `waterGradientTopColor` 등 Color 타입 접근자가 필요할 수 있음. 현재 AppColors는 NSColor 기반이므로 Step 3에서 Color 변환 헬퍼를 추가.

- [ ] **Step 3: AppColors에 Color 타입 접근자 추가**

`Sources/RainDrop/Shared/Theme/AppColors.swift` 파일 하단에 추가:

```swift
// MARK: - SwiftUI Color Accessors (for BucketSkin)

extension AppColors {
    static var waterGradientTopColor: Color { Color(waterGradientTop) }
    static var waterGradientBottomColor: Color { Color(waterGradientBottom) }
    static var dropGradientTopColor: Color { Color(dropGradientTop) }
    static var dropGradientBottomColor: Color { Color(dropGradientBottom) }
}
```

- [ ] **Step 4: 빌드 확인 + 커밋**

Run: `swift build -c release`
Expected: Build complete

```bash
git add Sources/RainDrop/Core/Models/BucketSkin.swift Sources/RainDrop/Shared/Theme/AppColors.swift
git commit -m "feat: add BucketSkin model with 6 tiers and color palettes"
```

---

## Task 2: AppSettings에 스킨 설정 추가

**Files:**
- Modify: `Sources/RainDrop/Core/Models/AppSettings.swift`

- [ ] **Step 1: selectedSkin과 useCustomWaterColor 추가**

`AppSettings` struct에 프로퍼티 추가:

```swift
var selectedSkin: BucketSkin = .wood
var useCustomWaterColor: Bool = false
```

`init(from decoder:)`에 추가:

```swift
selectedSkin = try container.decodeIfPresent(BucketSkin.self, forKey: .selectedSkin) ?? .wood
useCustomWaterColor = try container.decodeIfPresent(Bool.self, forKey: .useCustomWaterColor) ?? false
```

memberwise `init`에도 파라미터 추가:

```swift
init(
    sessionGoalMinutes: Int = 25,
    focusCheckEnabled: Bool = false,
    focusCheckIntervalMinutes: Int = 5,
    infinityModeEnabled: Bool = false,
    selectedSkin: BucketSkin = .wood,
    useCustomWaterColor: Bool = false
) {
    self.sessionGoalMinutes = sessionGoalMinutes
    self.focusCheckEnabled = focusCheckEnabled
    self.focusCheckIntervalMinutes = focusCheckIntervalMinutes
    self.infinityModeEnabled = infinityModeEnabled
    self.selectedSkin = selectedSkin
    self.useCustomWaterColor = useCustomWaterColor
}
```

- [ ] **Step 2: 빌드 확인 + 커밋**

```bash
swift build -c release
git add Sources/RainDrop/Core/Models/AppSettings.swift
git commit -m "feat: add selectedSkin and useCustomWaterColor to AppSettings"
```

---

## Task 3: BucketView 스킨 대응

**Files:**
- Modify: `Sources/RainDrop/Features/Timer/BucketView.swift`

- [ ] **Step 1: BucketView에 skin 파라미터 추가**

기존:
```swift
struct BucketView: View {
    let progress: Double
    @State private var waveOffset: Double = 0
```

변경:
```swift
struct BucketView: View {
    let progress: Double
    let skin: BucketSkin
    let useCustomWaterColor: Bool
    @State private var waveOffset: Double = 0
```

- [ ] **Step 2: 양동이 색상을 스킨 기반으로 교체**

`body` 내 색상 참조를 전부 `skin` 프로퍼티로 교체:

```swift
// 양동이 채움 — 기존: AppColors.bucketFill → 변경:
BucketShape().fill(skin.bucketFill)

// 양동이 외곽선 — 기존: AppColors.bucketStroke → 변경:
BucketShape().stroke(skin.bucketStroke, lineWidth: 5)

// 림 — 기존: AppColors.bucketStroke → 변경:
BucketRim().stroke(skin.bucketStroke, style: StrokeStyle(lineWidth: 7, lineCap: .round))

// 밴드 — 기존: AppColors.bucketStroke.opacity(0.4) → 변경:
BucketBand(yRatio: 0.30).stroke(skin.bandColor, lineWidth: 2.5)
BucketBand(yRatio: 0.70).stroke(skin.bandColor, lineWidth: 2.5)

// 핸들 — 기존: AppColors.bucketHandle → 변경:
BucketHandleShape().stroke(skin.bucketHandle, style: StrokeStyle(lineWidth: 7, lineCap: .round))
```

- [ ] **Step 3: 물 색상을 스킨 기반으로 교체**

물 그라데이션 색상:

```swift
// 물 색상 결정
private var waterGradientTop: Color {
    if useCustomWaterColor && skin.hasCustomWaterColor {
        return skin.customWaterGradientTop
    }
    return AppColors.waterGradientTopColor
}

private var waterGradientBottom: Color {
    if useCustomWaterColor && skin.hasCustomWaterColor {
        return skin.customWaterGradientBottom
    }
    return AppColors.waterGradientBottomColor
}
```

기존 물 레이어의 LinearGradient를 이 computed property로 교체:

```swift
// Back wave
LinearGradient(colors: [waterGradientTop.opacity(0.6), waterGradientBottom.opacity(0.4)], ...)

// Front wave
LinearGradient(colors: [waterGradientTop, waterGradientBottom], ...)
```

- [ ] **Step 4: 빌드 확인 (컴파일 에러 예상 — 호출부 수정 필요)**

빌드하면 `BucketView` 호출부에서 `skin`/`useCustomWaterColor` 파라미터 누락 에러 발생. Task 4에서 해결.

---

## Task 4: StickerPlacementView + TimerScreen 스킨 전달

**Files:**
- Modify: `Sources/RainDrop/Features/Timer/StickerPlacementView.swift`
- Modify: `Sources/RainDrop/Features/Timer/TimerScreen.swift`

- [ ] **Step 1: StickerPlacementView에 skin 파라미터 추가**

```swift
struct BucketWithStickersView: View {
    let progress: Double
    let skin: BucketSkin
    let useCustomWaterColor: Bool
    let placements: [StickerPlacement]
    // ... 기존 파라미터 유지
```

내부 BucketView 호출 수정:

```swift
BucketView(progress: progress, skin: skin, useCustomWaterColor: useCustomWaterColor)
```

- [ ] **Step 2: TimerScreen에서 스킨 정보 전달**

TimerScreen에 스킨 상태를 settings에서 가져오기. `rightPanel` 내 `BucketWithStickersView` 호출 수정:

```swift
BucketWithStickersView(
    progress: displayProgress,
    skin: settingsViewModel.settings.selectedSkin,
    useCustomWaterColor: settingsViewModel.settings.useCustomWaterColor,
    placements: shopViewModel.shopState.placements,
    isDecorating: isDecorating,
    onAddPlacement: { placement in
        shopViewModel.addPlacement(placement)
    },
    onRemovePlacement: { id in
        shopViewModel.removePlacement(id: id)
    },
    purchasedItems: shopViewModel.shopState.purchasedItemIDs
)
```

- [ ] **Step 3: 빌드 확인 + 커밋**

```bash
swift build -c release
git add Sources/RainDrop/Features/Timer/BucketView.swift \
    Sources/RainDrop/Features/Timer/StickerPlacementView.swift \
    Sources/RainDrop/Features/Timer/TimerScreen.swift
git commit -m "feat: apply bucket skin colors throughout view hierarchy"
```

---

## Task 5: 설정 화면에 스킨 선택 UI 추가

**Files:**
- Modify: `Sources/RainDrop/Features/Settings/SettingsScreen.swift`

- [ ] **Step 1: 스킨 선택 Section 추가**

기존 "집중 감시 알림" Section 뒤에 추가:

```swift
Section("양동이 스킨") {
    ForEach(BucketSkin.allCases, id: \.self) { skin in
        let unlocked = skin.isUnlocked(totalBuckets: totalBuckets)
        Button {
            if unlocked {
                viewModel.settings.selectedSkin = skin
                viewModel.save()
            }
        } label: {
            HStack(spacing: 12) {
                // 선택 표시
                Image(systemName: viewModel.settings.selectedSkin == skin ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(viewModel.settings.selectedSkin == skin ? .blue : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(skin.displayName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(unlocked ? AppColors.primaryText : .secondary)

                        if !unlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(unlocked ? skin.materialDescription : "🪣 \(skin.requiredBuckets)번 채움 시 해금")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                // 미니 프리뷰 (스킨 색상 원)
                Circle()
                    .fill(skin.bucketFill)
                    .overlay(Circle().stroke(skin.bucketStroke, lineWidth: 2))
                    .frame(width: 24, height: 24)
                    .opacity(unlocked ? 1.0 : 0.4)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
    }

    // 물 색상 커스텀 (금 이상 티어)
    if viewModel.settings.selectedSkin.hasCustomWaterColor {
        Toggle("스킨 색 물 사용", isOn: $viewModel.settings.useCustomWaterColor)
            .onChange(of: viewModel.settings.useCustomWaterColor) { _ in
                viewModel.save()
            }
        Text("물과 물방울의 색을 스킨 색상에 맞춥니다.")
            .font(.caption)
            .foregroundStyle(.tertiary)
    }
}
```

- [ ] **Step 2: totalBuckets 값 전달**

SettingsScreen에서 `totalBuckets`가 필요. ShopViewModel에서 가져와야 함.
SettingsScreen에 파라미터 추가:

```swift
struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel
    var totalBuckets: Int = 0
    @Environment(\.dismiss) private var dismiss
```

TimerScreen에서 SettingsScreen 호출 시:

```swift
.sheet(isPresented: $isShowingSettings) {
    SettingsScreen(
        viewModel: settingsViewModel,
        totalBuckets: shopViewModel.shopState.totalBucketsEarned
    )
}
```

- [ ] **Step 3: 빌드 확인 + 커밋**

```bash
swift build -c release
git add Sources/RainDrop/Features/Settings/SettingsScreen.swift \
    Sources/RainDrop/Features/Timer/TimerScreen.swift
git commit -m "feat: add skin selection UI in settings with unlock conditions"
```

---

## Task 6: RainParticleView 구현 (비 파티클 시스템)

**Files:**
- Create: `Sources/RainDrop/Features/Timer/RainParticleView.swift`

- [ ] **Step 1: 파티클 모델 + Canvas 렌더링**

```swift
import SwiftUI

struct RainParticle: Identifiable {
    let id = UUID()
    var x: Double        // 0~1 상대 위치
    var y: Double        // 0~1 상대 위치 (0=상단, 1=하단)
    var speed: Double    // 낙하 속도 (0.005~0.015)
    var size: Double     // 파티클 크기 (2~5)
    var opacity: Double  // 투명도 (0.3~0.8)
}

struct RainParticleView: View {
    let isAnimating: Bool
    let dropGradientTop: Color
    let dropGradientBottom: Color

    @State private var particles: [RainParticle] = []
    @State private var lastUpdate: Date = .now

    private let particleCount = 40

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let x = particle.x * size.width
                    let y = particle.y * size.height
                    let dropSize = particle.size

                    let rect = CGRect(
                        x: x - dropSize / 2,
                        y: y - dropSize * 1.5,
                        width: dropSize,
                        height: dropSize * 3
                    )

                    let gradient = Gradient(colors: [
                        dropGradientTop.opacity(particle.opacity),
                        dropGradientBottom.opacity(particle.opacity * 0.8)
                    ])

                    context.fill(
                        Capsule().path(in: rect),
                        with: .linearGradient(
                            gradient,
                            startPoint: CGPoint(x: rect.midX, y: rect.minY),
                            endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                        )
                    )
                }
            }
            .onChange(of: timeline.date) { newDate in
                updateParticles(date: newDate)
            }
        }
        .onAppear {
            if isAnimating {
                initializeParticles()
            }
        }
        .onChange(of: isAnimating) { animating in
            if animating {
                initializeParticles()
            } else {
                particles.removeAll()
            }
        }
    }

    private func initializeParticles() {
        particles = (0..<particleCount).map { _ in
            RainParticle(
                x: Double.random(in: 0.05...0.95),
                y: Double.random(in: -0.3...1.0),
                speed: Double.random(in: 0.008...0.018),
                size: Double.random(in: 2...5),
                opacity: Double.random(in: 0.3...0.8)
            )
        }
    }

    private mutating func updateParticles(date: Date) {
        guard isAnimating else { return }

        for i in particles.indices {
            particles[i].y += particles[i].speed

            // 화면 아래로 나가면 상단에서 재생성
            if particles[i].y > 1.1 {
                particles[i].y = Double.random(in: -0.2...(-0.05))
                particles[i].x = Double.random(in: 0.05...0.95)
                particles[i].speed = Double.random(in: 0.008...0.018)
                particles[i].size = Double.random(in: 2...5)
                particles[i].opacity = Double.random(in: 0.3...0.8)
            }
        }

        lastUpdate = date
    }
}
```

> **Note:** `mutating`은 struct 메서드에서만 사용. View의 경우 `@State`를 통해 mutation하므로 `mutating` 키워드 제거 필요. 최종 코드에서는 `particles` 배열을 직접 수정.

- [ ] **Step 2: updateParticles에서 mutating 제거**

View 내부에서는 `@State` 프로퍼티를 직접 수정 가능:

```swift
private func updateParticles(date: Date) {
    guard isAnimating else { return }

    var updated = particles
    for i in updated.indices {
        updated[i].y += updated[i].speed

        if updated[i].y > 1.1 {
            updated[i] = RainParticle(
                x: Double.random(in: 0.05...0.95),
                y: Double.random(in: -0.2...(-0.05)),
                speed: Double.random(in: 0.008...0.018),
                size: Double.random(in: 2...5),
                opacity: Double.random(in: 0.3...0.8)
            )
        }
    }
    particles = updated
    lastUpdate = date
}
```

- [ ] **Step 3: 빌드 확인 + 커밋**

```bash
swift build -c release
git add Sources/RainDrop/Features/Timer/RainParticleView.swift
git commit -m "feat: add RainParticleView with Canvas-based rain particle system"
```

---

## Task 7: CloudView 구현

**Files:**
- Create: `Sources/RainDrop/Features/Timer/CloudView.swift`

- [ ] **Step 1: 반투명 구름 애니메이션 작성**

```swift
import SwiftUI

struct CloudView: View {
    let isVisible: Bool

    @State private var cloudOffset: Double = 0
    @State private var cloudOpacity: Double = 0

    var body: some View {
        ZStack {
            // 메인 구름
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 200, height: 50)
                .offset(x: cloudOffset)

            // 보조 구름 (왼쪽)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 50
                    )
                )
                .frame(width: 120, height: 35)
                .offset(x: -60 + cloudOffset * 0.7, y: 5)

            // 보조 구름 (오른쪽)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.04),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 45
                    )
                )
                .frame(width: 100, height: 30)
                .offset(x: 50 + cloudOffset * 0.5, y: 3)
        }
        .opacity(cloudOpacity)
        .onChange(of: isVisible) { visible in
            if visible {
                withAnimation(.easeIn(duration: 1.5)) {
                    cloudOpacity = 1.0
                }
                withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                    cloudOffset = 10
                }
            } else {
                withAnimation(.easeOut(duration: 1.0)) {
                    cloudOpacity = 0
                }
            }
        }
        .onAppear {
            if isVisible {
                cloudOpacity = 1.0
                withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                    cloudOffset = 10
                }
            }
        }
    }
}
```

- [ ] **Step 2: 빌드 확인 + 커밋**

```bash
swift build -c release
git add Sources/RainDrop/Features/Timer/CloudView.swift
git commit -m "feat: add CloudView with translucent floating cloud animation"
```

---

## Task 8: TimerScreen에 RainParticleView + CloudView 통합

**Files:**
- Modify: `Sources/RainDrop/Features/Timer/TimerScreen.swift`

- [ ] **Step 1: WaterDropView를 RainParticleView + CloudView로 교체**

기존 rightPanel 내:
```swift
WaterDropView(isAnimating: viewModel.isRunning)
    .frame(width: 300, height: 220)
```

변경:
```swift
ZStack(alignment: .top) {
    // 구름 (비 시작점)
    CloudView(isVisible: viewModel.isRunning)
        .frame(width: 300, height: 60)
        .offset(y: -10)

    // 비 파티클
    RainParticleView(
        isAnimating: viewModel.isRunning,
        dropGradientTop: effectiveDropGradientTop,
        dropGradientBottom: effectiveDropGradientBottom
    )
    .frame(width: 300, height: 220)
}
.frame(width: 300, height: 220)
```

- [ ] **Step 2: 스킨 기반 물방울 색상 computed property 추가**

TimerScreen에 추가:

```swift
private var effectiveDropGradientTop: Color {
    let skin = settingsViewModel.settings.selectedSkin
    if settingsViewModel.settings.useCustomWaterColor && skin.hasCustomWaterColor {
        return skin.customDropGradientTop
    }
    return AppColors.dropGradientTopColor
}

private var effectiveDropGradientBottom: Color {
    let skin = settingsViewModel.settings.selectedSkin
    if settingsViewModel.settings.useCustomWaterColor && skin.hasCustomWaterColor {
        return skin.customDropGradientBottom
    }
    return AppColors.dropGradientBottomColor
}
```

- [ ] **Step 3: 빌드 확인 + 배포 + 커밋**

```bash
swift build -c release
./deploy.sh --skip-build
git add Sources/RainDrop/Features/Timer/TimerScreen.swift
git commit -m "feat: integrate rain particles + cloud, replace large water drops"
```

---

## Task 9: 최종 통합 + 엣지 케이스 처리

**Files:**
- Multiple files (cleanup)

- [ ] **Step 1: WaterDropView.swift 보존**

`WaterDropView.swift`는 삭제하지 않고 유지 (fallback 또는 참고용). 현재 TimerScreen에서 참조하지 않으면 dead code이지만 향후 필요할 수 있음.

- [ ] **Step 2: 스킨 변경 시 settingsDidChange notification 확인**

설정에서 스킨을 변경하면 `viewModel.save()` → `.settingsDidChange` notification이 이미 발동됨. TimerScreen의 `settingsViewModel.settings.selectedSkin`이 실시간 반영되므로 추가 작업 불필요.

- [ ] **Step 3: deploy.sh로 전체 배포 + 테스트**

```bash
./deploy.sh
```

테스트 체크리스트:
1. 기본 나무 스킨으로 앱 시작 — 갈색 양동이 표시
2. 설정 → 스킨 목록 표시, 해금 안 된 스킨 잠금 표시
3. 타이머 시작 → 구름 나타남 + 작은 비 파티클 떨어짐
4. 양동이에 물이 차오름 + 스킨 색상 반영
5. (금 이상 스킨 해금 시) "스킨 색 물 사용" 토글 → 물/물방울 색상 변경
6. 무한 모드에서도 정상 순환 동작

- [ ] **Step 4: 최종 커밋 + 푸시**

```bash
git add -A
git commit -m "feat: complete bucket skin system + rain particle refactoring"
git push origin main
```

---

## Task 10: GitHub Release 업데이트

**Files:**
- None (CLI 작업)

- [ ] **Step 1: 새 Release 생성**

```bash
cd /Applications && zip -r ~/Desktop/RainDrop.zip RainDrop.app
gh release create v1.1.0 ~/Desktop/RainDrop.zip \
    --repo mgm136044/Raindrop \
    --title "RainDrop v1.1.0 — 양동이 스킨 + 비 파티클" \
    --notes "6종 양동이 스킨(나무→무지개), 비 파티클 시스템, 구름 애니메이션 추가"
```

- [ ] **Step 2: Homebrew Cask 업데이트**

```bash
# SHA256 계산
shasum -a 256 ~/Desktop/RainDrop.zip

# homebrew-tap/Casks/raindrop.rb 의 version과 sha256 업데이트
# version "1.1.0"
# sha256 "<new_hash>"

cd ~/development/homebrew-tap
git add Casks/raindrop.rb
git commit -m "bump: raindrop v1.1.0"
git push origin main
```

- [ ] **Step 3: 정리**

```bash
rm ~/Desktop/RainDrop.zip
```
