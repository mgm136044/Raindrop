import SwiftUI

struct BucketView: View {
    private static let waveCycleDuration: TimeInterval = 2.5

    let progress: Double
    let skin: BucketSkin
    let useCustomWaterColor: Bool
    var intensity: Double = 0.5
    var waterColorOverride: (top: Color, bottom: Color)?
    var tiltAngle: Double = 0
    var mode: BucketRenderMode = .full

    @State private var idlePhase: Double = 0
    @State private var provider: AnyBucketSkin

    init(
        progress: Double,
        skin: BucketSkin,
        useCustomWaterColor: Bool,
        intensity: Double = 0.5,
        waterColorOverride: (top: Color, bottom: Color)? = nil,
        tiltAngle: Double = 0,
        mode: BucketRenderMode = .full
    ) {
        self.progress = progress
        self.skin = skin
        self.useCustomWaterColor = useCustomWaterColor
        self.intensity = intensity
        self.waterColorOverride = waterColorOverride
        self.tiltAngle = tiltAngle
        self.mode = mode
        self._provider = State(initialValue: skin.shapeProvider)
    }

    private var waterGradientTop: Color {
        if let override = waterColorOverride { return override.top }
        if useCustomWaterColor && skin.hasCustomWaterColor {
            return provider.waterStyle.gradientTop
        }
        return AppColors.waterGradientTopColor
    }

    private var waterGradientBottom: Color {
        if let override = waterColorOverride { return override.bottom }
        if useCustomWaterColor && skin.hasCustomWaterColor {
            return provider.waterStyle.gradientBottom
        }
        return AppColors.waterGradientBottomColor
    }

    private var surfaceReflectionOpacity: Double {
        provider.waterStyle.surfaceReflectionOpacity
    }

    private var effectiveIntensity: Double {
        intensity * provider.animationConfig.waveIntensityMultiplier
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let rect = CGRect(origin: .zero, size: geometry.size)
            let palette = provider.colorPalette

            if mode == .full {
                TimelineView(.animation) { context in
                    let waveOffset = (context.date.timeIntervalSinceReferenceDate / Self.waveCycleDuration)
                        .truncatingRemainder(dividingBy: 1.0)

                    bucketContent(rect: rect, palette: palette, waveOffset: waveOffset)
                }
            } else {
                bucketContent(rect: rect, palette: palette, waveOffset: 0)
            }
        }
        .drawingGroup()
        .onAppear {
            restartIdleAnimation()
        }
        .onChange(of: skin) { _, newSkin in
            provider = newSkin.shapeProvider
            restartIdleAnimation()
        }
    }

    // MARK: - Bucket Content

    @ViewBuilder
    private func bucketContent(rect: CGRect, palette: BucketColorPalette, waveOffset: Double) -> some View {
        ZStack(alignment: .bottom) {
            // 1. Body fill
            BucketBodyShape(provider: provider, mode: mode)
                .fill(palette.fill)

            // 2a. Water layer (back, softer) — full mode only
            if mode == .full {
                WaterSurfaceShape(
                    progress: progress,
                    waveOffset: waveOffset + 0.3,
                    intensity: effectiveIntensity,
                    layer: .back,
                    tiltAngle: tiltAngle,
                    maxFillHeight: provider.maxFillHeight
                )
                .fill(
                    LinearGradient(
                        colors: [
                            waterGradientTop.opacity(0.45),
                            waterGradientBottom.opacity(0.45)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .mask(BucketBodyShape(provider: provider, mode: mode).scale(provider.waterMaskScale))
            }

            // 2b. Water layer (front, primary)
            WaterSurfaceShape(
                progress: progress,
                waveOffset: waveOffset,
                intensity: mode == .mini ? 0 : effectiveIntensity,
                layer: .front,
                tiltAngle: tiltAngle,
                maxFillHeight: provider.maxFillHeight
            )
            .fill(
                LinearGradient(
                    colors: [
                        waterGradientTop.opacity(mode == .mini ? 0.7 : 1.0),
                        waterGradientBottom.opacity(mode == .mini ? 0.9 : 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .mask(BucketBodyShape(provider: provider, mode: mode).scale(provider.waterMaskScale))

            // 3. Surface highlight
            if progress > 0.05 && mode == .full {
                WaterSurfaceHighlight(
                    progress: progress,
                    waveOffset: waveOffset,
                    intensity: effectiveIntensity,
                    tiltAngle: tiltAngle,
                    maxFillHeight: provider.maxFillHeight
                )
                .stroke(Color.white.opacity(surfaceReflectionOpacity), lineWidth: 1.5)
                .mask(BucketBodyShape(provider: provider, mode: mode).scale(provider.waterMaskScale))
            }

            // 4. Overlay (skin-specific decorations) — full mode only
            if mode == .full {
                provider.overlay(in: rect, mode: mode)
                    .mask(BucketBodyShape(provider: provider, mode: mode))
            }

            // 5. Bands (subtle, thin)
            let bandPaths = provider.bandPaths(in: rect)
            ForEach(Array(bandPaths.enumerated()), id: \.offset) { _, bandPath in
                bandPath
                    .stroke(palette.band, lineWidth: mode == .mini ? 0.5 : 1.0)
            }

            // 6. Edge rim light (1pt white->transparent instead of thick outline)
            BucketBodyShape(provider: provider, mode: mode)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(mode == .mini ? 0.15 : 0.30),
                            palette.stroke.opacity(mode == .mini ? 0.3 : 0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: mode == .mini ? 1.0 : 1.5
                )

            // 7. Specular highlight layer (.screen blend)
            if mode == .full {
                BucketBodyShape(provider: provider, mode: mode)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.clear,
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
            }

            // 8. Rim — subtle edge light
            if mode == .full {
                BucketRimShape(provider: provider)
                    .stroke(
                        Color.white.opacity(0.35),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
            }
        }
        .applyIdleAnimation(config: provider.animationConfig, phase: idlePhase)
    }

    // MARK: - Idle Animation

    private func restartIdleAnimation() {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            idlePhase = 0
        }

        startIdleAnimation()
    }

    private func startIdleAnimation() {
        guard let animation = provider.animationConfig.idleAnimation else { return }

        switch animation {
        case .breathe(_, let duration):
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                idlePhase = 1.0
            }
        case .scanHighlight(let duration):
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                idlePhase = 1.0
            }
        case .hueRotation(let duration):
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                idlePhase = 1.0
            }
        case .facetShimmer:
            break // Driven by tiltAngle from parent
        }
    }
}

// MARK: - Idle Animation View Modifier

private extension View {
    @ViewBuilder
    func applyIdleAnimation(config: BucketAnimationConfig, phase: Double) -> some View {
        if let animation = config.idleAnimation {
            switch animation {
            case .breathe(let scale, _):
                let currentScale = 1.0 + (scale - 1.0) * phase
                self.scaleEffect(currentScale)
            case .scanHighlight:
                self // Scan highlight handled by overlay
            case .hueRotation:
                self.hueRotation(.degrees(phase * 360))
            case .facetShimmer:
                self
            }
        } else {
            self
        }
    }
}

// MARK: - Shape Wrappers

/// Wraps provider.bodyPath as a SwiftUI Shape for use with .fill/.stroke/.mask/.scale
@MainActor
private struct BucketBodyShape: Shape {
    let provider: AnyBucketSkin
    let mode: BucketRenderMode

    nonisolated func path(in rect: CGRect) -> Path {
        MainActor.assumeIsolated {
            provider.bodyPath(in: rect, mode: mode)
        }
    }
}

/// Wraps provider.rimPath as a SwiftUI Shape
@MainActor
private struct BucketRimShape: Shape {
    let provider: AnyBucketSkin

    nonisolated func path(in rect: CGRect) -> Path {
        MainActor.assumeIsolated {
            provider.rimPath(in: rect)
        }
    }
}
