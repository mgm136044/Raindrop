import SwiftUI

struct PlatinumBucket: BucketShapeProvider {

    // MARK: - Body Path (slim cylinder with sharp shoulders and distinct ledge)

    func bodyPath(in rect: CGRect, mode: BucketRenderMode) -> Path {
        // Top 8% is slightly wider (shoulder), then steps in — creates visible ledge
        let shoulderInset = rect.width * 0.10
        let bodyInset = rect.width * 0.12
        let cornerRadius = rect.width * 0.02  // Tiny corner radius

        let shoulderHeight = rect.height * 0.08
        let topY = rect.minY
        let shoulderY = rect.minY + shoulderHeight
        let bottomY = rect.maxY

        var path = Path()

        // Top of shoulder (wider)
        path.move(to: CGPoint(x: shoulderInset, y: topY))
        path.addLine(to: CGPoint(x: rect.maxX - shoulderInset, y: topY))

        // Step down to body (sharp shoulder ledge — right side)
        path.addLine(to: CGPoint(x: rect.maxX - shoulderInset, y: shoulderY))
        path.addLine(to: CGPoint(x: rect.maxX - bodyInset, y: shoulderY))

        // Right wall straight down to bottom corner
        path.addLine(to: CGPoint(x: rect.maxX - bodyInset, y: bottomY - cornerRadius))
        // Bottom-right corner
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - bodyInset - cornerRadius, y: bottomY),
            control: CGPoint(x: rect.maxX - bodyInset, y: bottomY)
        )
        // Bottom edge
        path.addLine(to: CGPoint(x: bodyInset + cornerRadius, y: bottomY))
        // Bottom-left corner
        path.addQuadCurve(
            to: CGPoint(x: bodyInset, y: bottomY - cornerRadius),
            control: CGPoint(x: bodyInset, y: bottomY)
        )

        // Left wall straight up to shoulder
        path.addLine(to: CGPoint(x: bodyInset, y: shoulderY))

        // Step out to shoulder (sharp shoulder ledge — left side)
        path.addLine(to: CGPoint(x: shoulderInset, y: shoulderY))
        path.addLine(to: CGPoint(x: shoulderInset, y: topY))

        path.closeSubpath()
        return path
    }

    // MARK: - Rim Path (follows the shoulder top)

    func rimPath(in rect: CGRect) -> Path {
        let shoulderInset = rect.width * 0.10
        let rimExtend: CGFloat = 4
        let topY = rect.minY

        var path = Path()
        path.move(to: CGPoint(x: shoulderInset - rimExtend, y: topY))
        path.addLine(to: CGPoint(x: rect.maxX - shoulderInset + rimExtend, y: topY))
        return path
    }

    // MARK: - Band Paths (empty — clean mirror surface)

    func bandPaths(in rect: CGRect) -> [Path] {
        []
    }

    // MARK: - Overlay (mirror-like sharp specular — no scale markings)

    @ViewBuilder
    func overlay(in rect: CGRect, mode: BucketRenderMode) -> some View {
        if mode == .full {
            // Mirror-like sharp specular
            LinearGradient(
                stops: [
                    .init(color: Color.white.opacity(0.0), location: 0.0),
                    .init(color: Color.white.opacity(0.0), location: 0.35),
                    .init(color: Color.white.opacity(0.18), location: 0.42),
                    .init(color: Color.white.opacity(0.0), location: 0.50),
                    .init(color: Color.white.opacity(0.0), location: 1.0),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.screen)
            .frame(width: rect.width, height: rect.height)
            .allowsHitTesting(false)
        } else {
            EmptyView()
        }
    }

    // MARK: - Color Palette (cool platinum silver)

    var colorPalette: BucketColorPalette {
        BucketColorPalette(
            fill: Color(red: 0.55, green: 0.56, blue: 0.58, opacity: 0.80),
            stroke: Color(red: 0.75, green: 0.76, blue: 0.78),
            band: .clear,
            accent: Color(red: 0.95, green: 0.95, blue: 0.96)
        )
    }

    // MARK: - Water Style

    var waterStyle: WaterStyle {
        WaterStyle(
            gradientTop: AppColors.waterGradientTopColor,
            gradientBottom: AppColors.waterGradientBottomColor,
            dropGradientTop: AppColors.dropGradientTopColor,
            dropGradientBottom: AppColors.dropGradientBottomColor,
            surfaceReflectionOpacity: 0.25
        )
    }

    // MARK: - Animation Config (scan highlight, slow period)

    var animationConfig: BucketAnimationConfig {
        BucketAnimationConfig(
            idleAnimation: .scanHighlight(duration: 10.0),
            waveIntensityMultiplier: 1.0
        )
    }

    // MARK: - Dynamic Rain / Water Fill

    var topOpeningFraction: Double { 0.80 }
    var bottomWidthFraction: Double { 0.76 }
    var waterMaskScale: Double { 0.86 }
    var maxFillHeight: Double { 0.75 }
    var bottomInsetFraction: Double { 0.90 }
}
