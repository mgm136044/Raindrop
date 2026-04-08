# Design System of RainDrop

## 1. Visual Theme & Atmosphere

RainDrop is a macOS focus timer app built around the metaphor of **filling** -- raindrops accumulate in a bucket as the user concentrates, and over time, each day gains weight and density. The design philosophy is "Record life's density through filling" (채움으로 삶의 밀도를 기록한다).

The interface is deliberately quiet. The bucket and water are the hero elements -- they occupy the center of the screen, and everything else (timer, controls, navigation) exists as transparent overlays that recede during active sessions. This creates an environment the user wants to keep open, not just use and close.

The visual language is rooted in nature: rain, water, clouds, sky. Progress is never shown as a percentage bar or number alone -- it is felt through rising water levels, intensifying rain, darkening skies, and the golden clearing when a session completes. The app breathes through subtle, continuous animation: wave ripples, drifting clouds, falling rain.

**Key Characteristics:**
- macOS native (SwiftUI) with full dark/light mode support -- dark mode is the primary experience
- Bucket-as-hero layout: ZStack overlay structure with the bucket scene centered, UI floating above
- Nature-driven feedback: rain intensity, sky color, water level all respond to focus progress (0.0-1.0)
- `.glassEffect(.regular)` overlays for all floating UI -- header, timer pill, controls, info pill
- Continuous ambient animation even at idle (gentle wave ripples in bucket)
- Celebration moments: golden sparkle burst when bucket overflows, sky clears to warm tones
- 6-tier bucket skin system (Wood -> Iron -> Platinum -> Gold -> Diamond -> Rainbow) as progression milestones
- Environment evolution: cumulative focus grows the landscape (barren -> grass -> flowers -> trees -> forest -> lake)
- Weather system: consecutive focus days change ambient weather (cloudy -> drizzle -> rain -> rainbow)

## 2. Color Palette & Roles

All colors are dynamic, responding to system appearance (dark/light mode). Dark mode uses deep blue-black tones; light mode uses soft blue-whites.

### Background Gradients (diagonal, topLeading -> bottomTrailing)
- **Background Top**: Dark `rgb(0.10, 0.12, 0.18)` / Light `rgb(0.96, 0.98, 0.99)`
- **Background Bottom**: Dark `rgb(0.08, 0.10, 0.16)` / Light `rgb(0.88, 0.94, 0.98)`

### Sky Gradients (progress-driven, replace background during sessions)
- **Dawn** (0-20%): Dark `rgb(0.18, 0.14, 0.25)` to `rgb(0.22, 0.16, 0.12)` / Light warm peach tones
- **Gathering** (20-50%): Dark `rgb(0.12, 0.14, 0.22)` to `rgb(0.10, 0.12, 0.20)` / Light gray-blue
- **Storm** (50-100%): Dark `rgb(0.08, 0.10, 0.18)` to `rgb(0.06, 0.08, 0.15)` / Light muted blue-gray
- **Clearing** (overflow): Dark `rgb(0.20, 0.18, 0.10)` to `rgb(0.15, 0.12, 0.08)` / Light golden warmth

### Panel & Surface
- **Panel Background**: Dark `rgba(0.14, 0.16, 0.22, 0.85)` / Light `rgba(1.0, 1.0, 1.0, 0.82)`
- **Right Panel Top**: Dark `rgba(0.12, 0.15, 0.22, 0.95)` / Light `rgba(1.0, 1.0, 1.0, 0.95)`
- **Right Panel Bottom**: Dark `rgb(0.10, 0.16, 0.26)` / Light `rgb(0.83, 0.93, 0.99)`
- **Floating UI**: `.glassEffect(.regular)` (system vibrancy)

### Text
- **Primary**: Dark `rgb(0.92, 0.94, 0.97)` / Light `rgb(0.08, 0.18, 0.31)`
- **Title**: Dark `rgb(0.85, 0.90, 0.98)` / Light `rgb(0.10, 0.20, 0.33)`
- **Subtitle**: Dark `rgb(0.55, 0.62, 0.72)` / Light `rgb(0.16, 0.34, 0.55)`
- **Scene Text**: Dark `rgb(0.70, 0.80, 0.92)` / Light `rgb(0.13, 0.28, 0.46)`
- **Progress**: Dark `rgb(0.50, 0.75, 0.95)` / Light `rgb(0.10, 0.43, 0.68)`

### Interactive / Accent
- **Accent Blue**: Dark `rgb(0.25, 0.60, 0.95)` / Light `rgb(0.12, 0.55, 0.88)` -- primary accent, buttons, highlights
- **Button Tint**: Dark `rgb(0.22, 0.55, 0.88)` / Light `rgb(0.14, 0.45, 0.75)` -- borderedProminent tint
- **Start Button**: Dark `rgb(0.20, 0.58, 0.92)` / Light `rgb(0.12, 0.55, 0.88)` -- focus start action
- **Pause Button**: Dark `rgb(0.35, 0.55, 0.78)` / Light `rgb(0.28, 0.50, 0.72)` -- muted blue
- **Stop Button**: Dark `rgb(0.90, 0.45, 0.32)` / Light `rgb(0.86, 0.42, 0.28)` -- red-orange danger

### Water & Rain
- **Water Top**: Dark `rgb(0.30, 0.65, 0.90)` / Light `rgb(0.39, 0.79, 0.97)`
- **Water Bottom**: Dark `rgb(0.10, 0.35, 0.75)` / Light `rgb(0.14, 0.48, 0.91)`
- **Drop Top**: Dark `rgb(0.50, 0.78, 1.0)` / Light `rgb(0.65, 0.89, 1.0)`
- **Drop Bottom**: Dark `rgb(0.12, 0.45, 0.85)` / Light `rgb(0.18, 0.58, 0.95)`
- **Cloud**: Dark `white` / Light `rgb(0.55, 0.62, 0.72)`

### Water Color Progression (by cumulative focus minutes)
- **0-300min**: `rgb(0.45, 0.75, 0.95)` to `rgb(0.20, 0.50, 0.85)` -- light blue
- **300-1500min**: `rgb(0.30, 0.65, 0.90)` to `rgb(0.10, 0.40, 0.80)` -- blue
- **1500-5000min**: `rgb(0.20, 0.60, 0.85)` to `rgb(0.05, 0.35, 0.75)` -- deep blue
- **5000-15000min**: `rgb(0.15, 0.55, 0.75)` to `rgb(0.05, 0.30, 0.65)` -- teal
- **15000+min**: `rgb(0.10, 0.40, 0.70)` to `rgb(0.03, 0.20, 0.55)` -- sapphire

## 3. Typography Rules

### Font Family
- **System**: SF Pro (macOS system font) via `.system()` modifier
- **Design variant**: `.rounded` for display/title text, default for body

### Hierarchy

| Role | Size | Weight | Design | Spacing | Usage |
|------|------|--------|--------|---------|-------|
| App Title | 22pt | Bold | Rounded | default | "RainDrop" in header overlay |
| Version | 11pt | Medium | default | default | "v2.0.4" next to title |
| Timer Display | 36pt | Bold | Rounded | monospacedDigit | HH:MM:SS timer text |
| Motivation | 18pt | Semibold | default | default | Rotating encouragement messages |
| Cycle Text | 16pt | Semibold | default | default | "N번째 순환 중" |
| Info Pill | 14pt | Medium | default | default | Goal text, today total |
| Section Header | 20-24pt | Bold | default | default | Modal screen titles |
| Body | 13-14pt | Medium | default | default | Descriptions, labels |
| Caption | 11-12pt | Medium | default | default | Hints, secondary info |
| Emoji Sticker | 26pt | -- | -- | -- | Sticker overlays on bucket |
| Balance Badge | 13pt | Bold | default | default | Coin count in header |

### Key Rules
- Timer text always uses `.monospacedDigit()` to prevent layout jitter
- Title uses `.rounded` design for warmth; body stays default for readability
- Korean text (`ko_KR` locale) throughout -- all UI strings in Korean
- Motivation messages cycle every 8 seconds with `.opacity` transition

## 4. Component Stylings

### Buttons

**PrimaryButtonStyle** (custom):
- Font: 14pt bold, white foreground
- Padding: 18h, 12v
- Background: RoundedRectangle(14, continuous) filled with color param
- Pressed: color.opacity(0.82), scale 0.98

**Compact Timer Buttons** (during active session):
- Circle shape, 56x56pt
- Icon: SF Symbol, 22pt bold, white
- Background: solid color (start=blue, pause=muted, stop=red)
- Plain button style

**Header Buttons**:
- `.glass` style, `.controlSize(.small)`
- SF Symbol icon, 14pt medium
- Bordered prominent for "히스토리" with accent tint

### Floating Pills (Timer, Info, Balance)
- Background: `.glassEffect(.regular)`
- Shape: `Capsule()`
- Padding: 20-24h, 8-10v
- Text centered

### Modal Headers (History, Settings, Shop, Sticker Editor)
- Background: `historyHeaderBackground` color
- Layout: Title + subtitle left, close button right (`.glassProminent`)
- Padding: 20h, 18 top, 12 bottom

### Completion Banner
- Background: `.glassEffect(.regular)`
- Shape: RoundedRectangle(18, continuous)
- Content: Session info left, close button right
- Padding: 18 all

### Bucket View
- Barrel shape with curved sides (BucketShape)
- 2 metal bands at 30% and 70% vertical
- Handle arc above
- Rim line at top
- 2-layer water fill with 3-wave composite surface (WaterSurfaceShape)
- Surface highlight line (white, 0.15 opacity)
- Wave animation: linear 2.5s repeat forever
- Tap: wobble spring (stiffness 300, damping 8), 6-degree rotation from bottom anchor

### Rain Particles (Canvas, 30fps)
- Count: 8 (idle) to 80 (full intensity), scales with progress
- Shape: Capsule, width=size, height=size*3
- Speed: 0.004-0.025 per frame
- Size: 1.5-7pt
- Opacity: 0.15-0.9
- Gradient: dropGradientTop to dropGradientBottom

### Cloud View
- 3-5 ellipses with RadialGradient (cloud color, fading to clear)
- Drift: 8s easeInOut repeat, 10px horizontal
- Fade in: 1.5s easeIn; fade out: 1.0s easeOut
- Opacity scales with intensity: 0.3 + intensity * 0.5

## 5. Layout Principles

### Window
- Fixed: 1040x700 (main window)
- `.windowResizability(.contentSize)`

### Main Screen (ZStack layers, bottom to top)
1. SkyBackgroundView (full bleed, ignoresSafeArea)
2. TimerSceneView (centered, contains environment + weather + cloud + rain + bucket + splash + overflow)
3. Header overlay (top, .glassEffect(.regular), 24h padding)
4. Motivation text (below header)
5. Bottom stack: progress pill, timer pill, controls
6. Error/completion banner (bottom)

### Modal Screens
- Presented as `.sheet()` from TimerScreen
- Each has min size constraints (420x320 to 620x580)
- Form-based for settings; grid-based for shop; split-view for sticker editor

### Spacing Scale
- 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 28, 32pt
- Primary padding: 24 (header), 20 (modal content), 16 (cards)
- Component gaps: 8-12 (within groups), 16-24 (between sections)

### Corner Radius
- Large containers: 28pt continuous
- Medium cards: 12-14pt continuous
- Small elements: 8pt
- Pills/badges: Capsule()

## 6. Depth & Elevation

### Material Layers
- `.glassEffect(.regular)`: All floating UI overlays (header, pills, banners, sticker palette)
- Solid colors: Only for modal backgrounds and bucket rendering

### Animation Layers (TimerSceneView depth order)
1. EnvironmentView (grass/flowers/trees -- behind bucket)
2. WeatherOverlayView (ambient clouds/rain -- behind bucket)
3. CloudView + RainParticleView (session-active rain -- above environment)
4. BucketWithStickersView (center hero)
5. OverflowAnimationView (celebration sparkles)
6. WaterSplashView (surface splash particles)

### Shadow System
- No explicit drop shadows in v2.0 (removed from panels)
- Depth conveyed through material layers and opacity gradients

## 7. Do's and Don'ts

### Do
- Let the bucket scene breathe -- controls should recede during active sessions
- Use water level as the primary progress indicator, not numbers
- Keep animations subtle and continuous -- the screen should feel alive, not busy
- Maintain nature metaphor consistency: rain, water, sky, weather, environment
- Use Korean for all user-facing strings
- Use `.glassEffect(.regular)` for any floating UI over the scene
- Use `Capsule()` for inline info displays
- Keep dark mode as the primary design target

### Don't
- Don't add UI elements that compete with the bucket for visual attention
- Don't use percentage bars or numeric progress as primary indicators
- Don't use random values in SwiftUI view bodies (causes render flickering) -- use deterministic pseudo-random like `sin(index * seed)`
- Don't use `.contentTransition(.opacity)` on macOS 13 (requires macOS 14+) -- use `.id() + .transition(.opacity)` instead
- Don't create DateFormatter instances inside computed properties or view bodies -- use `static let`
- Don't use `.position()` in ForEach for interactive elements (causes full-parent hit area overlap) -- use fixed-frame containers
- Don't use drag-and-drop gestures in the main timer ZStack (gesture conflicts) -- use separate modal screens for complex interactions

## 8. Responsive Behavior

### macOS Only
- No iOS/iPadOS targets
- Fixed window size (1040x700) -- not resizable
- Menu bar extra (MenuBarContent) for quick access
- Keyboard: no custom shortcuts (standard macOS behavior)

### Modal Sizing
| Screen | Min Size | Notes |
|--------|----------|-------|
| History | 620x580 | 3-tab: monthly, weekly, sessions |
| Settings | 420x320 | Form-based, grouped style |
| Shop | 500x480 | 4-column grid |
| White Noise | 420x350 | Toggle + volume + WebView |
| Social | 500x600 | Auth states, ranking |
| Sticker Editor | 600x480 | Split: preview + palette/list |
| Onboarding | 520x450 | 3-scene experiential |
| Patch Notes | 480x500 | Scrollable version list |

## 9. Agent Prompt Guide

### Quick Reference Colors (Dark Mode)
```
Background:     rgb(26, 31, 46) to rgb(20, 26, 41)
Accent Blue:    rgb(64, 153, 242)
Start:          rgb(51, 148, 235)
Stop:           rgb(230, 115, 82)
Text Primary:   rgb(235, 240, 247)
Text Secondary: rgb(140, 158, 184)
Water:          rgb(77, 166, 230) to rgb(26, 89, 191)
```

### Component Generation Prompts

**To generate a new modal screen:**
> Create a SwiftUI sheet view with historyHeaderBackground header (title + subtitle left, "닫기" borderedProminent button right), padding 20h/18top/12bottom. Content below in ScrollView. Min frame 480x400. All text in Korean.

**To generate a new floating pill:**
> Create an HStack with .glassEffect(.regular) background, Capsule() clip shape, padding 16-20h and 6-8v. Text 12-14pt medium, secondary color. Place in bottom area of main ZStack.

**To generate a new particle system:**
> Use Canvas + TimelineView(.animation(minimumInterval: 1.0/30.0)). Store particles in @State array. Update on timeline change. Use deterministic randomness for initial positions (sin/cos with index seed). Support intensity: Double parameter (0-1) to scale count/speed/size.

**To add a new bucket skin:**
> Add a case to BucketSkin enum with requiredBuckets threshold, displayName (Korean), materialDescription (Korean), and color properties: bucketFill, bucketStroke, bucketHandle, bandColor. Optionally add hasCustomWaterColor with customWaterGradientTop/Bottom and customDropGradientTop/Bottom.
