import SwiftUI

struct RainbowBucket: BucketShapeProvider {

    // MARK: - Body Path (Slim cylinder with gently undulating rim — 4 waves, 2pt amplitude)

    func bodyPath(in rect: CGRect, mode: BucketRenderMode) -> Path {
        let sideInset = rect.width * 0.11
        let bottomInset = rect.width * 0.09
        let topY = rect.height * 0.08
        let bottomY = rect.height * 0.92
        let cornerRadius = rect.width * 0.06

        let topLeft = CGPoint(x: rect.minX + sideInset, y: topY)
        let topRight = CGPoint(x: rect.maxX - sideInset, y: topY)
        let bottomLeft = CGPoint(x: rect.minX + bottomInset, y: bottomY)
        let bottomRight = CGPoint(x: rect.maxX - bottomInset, y: bottomY)

        // Undulating rim: 4 waves with 2pt amplitude — subtle but noticeable
        let waveAmplitude: CGFloat = 2.0
        let topEdgeWidth = topRight.x - topLeft.x - cornerRadius * 2
        let waveCount = 4
        let waveSegmentWidth = topEdgeWidth / CGFloat(waveCount)

        var path = Path()
        path.move(to: CGPoint(x: topLeft.x + cornerRadius, y: topY))

        // Draw 4 undulating waves along the top rim
        for i in 0..<waveCount {
            let segStartX = topLeft.x + cornerRadius + CGFloat(i) * waveSegmentWidth
            let segEndX = segStartX + waveSegmentWidth
            let controlX = segStartX + waveSegmentWidth * 0.5
            let controlY = (i % 2 == 0) ? topY - waveAmplitude : topY + waveAmplitude
            path.addQuadCurve(
                to: CGPoint(x: segEndX, y: topY),
                control: CGPoint(x: controlX, y: controlY)
            )
        }

        // Top-right corner
        path.addQuadCurve(
            to: CGPoint(x: topRight.x, y: topY + cornerRadius),
            control: topRight
        )

        // Right wall: straight cylinder (sideInset ≈ bottomInset for slim parallel form)
        path.addCurve(
            to: CGPoint(x: bottomRight.x, y: bottomY - cornerRadius),
            control1: CGPoint(x: topRight.x, y: topY + (bottomY - topY) * 0.40),
            control2: CGPoint(x: bottomRight.x, y: bottomY - (bottomY - topY) * 0.40)
        )

        // Bottom-right corner
        path.addQuadCurve(
            to: CGPoint(x: bottomRight.x - cornerRadius, y: bottomY),
            control: bottomRight
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: bottomLeft.x + cornerRadius, y: bottomY))

        // Bottom-left corner
        path.addQuadCurve(
            to: CGPoint(x: bottomLeft.x, y: bottomY - cornerRadius),
            control: bottomLeft
        )

        // Left wall
        path.addCurve(
            to: CGPoint(x: topLeft.x, y: topY + cornerRadius),
            control1: CGPoint(x: bottomLeft.x, y: bottomY - (bottomY - topY) * 0.40),
            control2: CGPoint(x: topLeft.x, y: topY + (bottomY - topY) * 0.40)
        )

        // Top-left corner close
        path.addQuadCurve(
            to: CGPoint(x: topLeft.x + cornerRadius, y: topY),
            control: topLeft
        )

        path.closeSubpath()
        return path
    }

    // MARK: - Rim Path (Empty — undulating edge IS the rim)

    func rimPath(in rect: CGRect) -> Path {
        Path()
    }

    // MARK: - Band Paths (None)

    func bandPaths(in rect: CGRect) -> [Path] {
        []
    }

    // MARK: - Overlay (Pastel holographic angular gradient — no AuraGlowOverlay)

    @ViewBuilder
    func overlay(in rect: CGRect, mode: BucketRenderMode) -> some View {
        if mode == .full {
            // Pastel holographic — desaturated, not garish
            AngularGradient(
                colors: [
                    Color(red: 0.95, green: 0.80, blue: 0.80).opacity(0.12),
                    Color(red: 0.80, green: 0.95, blue: 0.85).opacity(0.10),
                    Color(red: 0.80, green: 0.85, blue: 0.98).opacity(0.12),
                    Color(red: 0.92, green: 0.80, blue: 0.95).opacity(0.10),
                    Color(red: 0.95, green: 0.80, blue: 0.80).opacity(0.12),
                ],
                center: .center
            )
            .blendMode(.screen)
            .frame(width: rect.width, height: rect.height)
            .allowsHitTesting(false)
        }
    }

    // MARK: - Color Palette (Platinum base — holographic shifts on top)

    var colorPalette: BucketColorPalette {
        BucketColorPalette(
            fill: Color(red: 0.58, green: 0.58, blue: 0.60, opacity: 0.75),
            stroke: Color(red: 0.72, green: 0.72, blue: 0.76),
            band: .clear,
            accent: Color(red: 0.85, green: 0.80, blue: 0.95)
        )
    }

    // MARK: - Water Style (Rainbow gradient — red top to purple bottom)

    var waterStyle: WaterStyle {
        WaterStyle(
            gradientTop: Color(red: 1.0, green: 0.42, blue: 0.42),
            gradientBottom: Color(red: 0.36, green: 0.17, blue: 0.56),
            dropGradientTop: Color(red: 1.0, green: 0.70, blue: 0.70),
            dropGradientBottom: Color(red: 0.60, green: 0.35, blue: 0.95),
            surfaceReflectionOpacity: 0.20
        )
    }

    // MARK: - Animation Config (Slow hue rotation — 20s cycle, subtle shift)

    var animationConfig: BucketAnimationConfig {
        BucketAnimationConfig(
            idleAnimation: .hueRotation(duration: 20.0),
            waveIntensityMultiplier: 1.0
        )
    }

    // MARK: - Dynamic Rain / Water Fill

    var topOpeningFraction: Double { 0.78 }
    var bottomWidthFraction: Double { 0.82 }
    var waterMaskScale: Double { 0.86 }
    var maxFillHeight: Double { 0.78 }
    var bottomInsetFraction: Double { 0.92 }
}
