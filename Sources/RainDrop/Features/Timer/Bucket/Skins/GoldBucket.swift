import SwiftUI

struct GoldBucket: BucketShapeProvider {

    // MARK: - Body Path (Wide-mouth chalice — dramatically flared top, narrow base)

    func bodyPath(in rect: CGRect, mode: BucketRenderMode) -> Path {
        let topInset = rect.width * 0.06      // Very wide top opening
        let bottomInset = rect.width * 0.16   // Narrow base — dramatic chalice silhouette
        let topY = rect.height * 0.08
        let bottomY = rect.height * 0.92
        let cornerRadius = rect.width * 0.06

        let topLeft = CGPoint(x: rect.minX + topInset, y: topY)
        let topRight = CGPoint(x: rect.maxX - topInset, y: topY)
        let bottomLeft = CGPoint(x: rect.minX + bottomInset, y: bottomY)
        let bottomRight = CGPoint(x: rect.maxX - bottomInset, y: bottomY)

        var path = Path()
        path.move(to: CGPoint(x: topLeft.x + cornerRadius, y: topY))
        // Top edge
        path.addLine(to: CGPoint(x: topRight.x - cornerRadius, y: topY))
        // Top-right corner
        path.addQuadCurve(
            to: CGPoint(x: topRight.x, y: topY + cornerRadius),
            control: topRight
        )
        // Right wall: sweeping inward curve for trophy/chalice shape
        path.addCurve(
            to: CGPoint(x: bottomRight.x, y: bottomY - cornerRadius),
            control1: CGPoint(x: topRight.x, y: topY + (bottomY - topY) * 0.45),
            control2: CGPoint(x: bottomRight.x, y: bottomY - (bottomY - topY) * 0.45)
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
        // Left wall: sweeping inward curve
        path.addCurve(
            to: CGPoint(x: topLeft.x, y: topY + cornerRadius),
            control1: CGPoint(x: bottomLeft.x, y: bottomY - (bottomY - topY) * 0.45),
            control2: CGPoint(x: topLeft.x, y: topY + (bottomY - topY) * 0.45)
        )
        // Top-left corner close
        path.addQuadCurve(
            to: CGPoint(x: topLeft.x + cornerRadius, y: topY),
            control: topLeft
        )
        path.closeSubpath()
        return path
    }

    // MARK: - Rim Path (Wide flared rim matching chalice top)

    func rimPath(in rect: CGRect) -> Path {
        let topInset = rect.width * 0.06
        let rimExtend: CGFloat = 6
        let topY = rect.height * 0.08
        let leftX = rect.minX + topInset - rimExtend
        let rightX = rect.maxX - topInset + rimExtend
        let cornerRadius = rect.width * 0.06

        var path = Path()
        path.move(to: CGPoint(x: leftX + cornerRadius, y: topY))
        path.addLine(to: CGPoint(x: rightX - cornerRadius, y: topY))
        path.addQuadCurve(
            to: CGPoint(x: rightX, y: topY + cornerRadius),
            control: CGPoint(x: rightX, y: topY)
        )
        path.addLine(to: CGPoint(x: rightX, y: topY + cornerRadius + 5))
        path.addLine(to: CGPoint(x: leftX, y: topY + cornerRadius + 5))
        path.addLine(to: CGPoint(x: leftX, y: topY + cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: leftX + cornerRadius, y: topY),
            control: CGPoint(x: leftX, y: topY)
        )
        path.closeSubpath()
        return path
    }

    // MARK: - Band Paths (Single thin band at 0.25 — subtle, chalice waist)

    func bandPaths(in rect: CGRect) -> [Path] {
        let topInset = rect.width * 0.06
        let bottomInset = rect.width * 0.16
        let topY = rect.height * 0.08
        let bottomY = rect.height * 0.92
        let fraction: CGFloat = 0.25

        let bandY = topY + (bottomY - topY) * fraction
        let t = fraction
        let leftX = (rect.minX + topInset) * (1 - t) + (rect.minX + bottomInset) * t
        let rightX = (rect.maxX - topInset) * (1 - t) + (rect.maxX - bottomInset) * t

        var path = Path()
        path.move(to: CGPoint(x: leftX, y: bandY))
        path.addLine(to: CGPoint(x: rightX, y: bandY))
        return [path]
    }

    // MARK: - Overlay (Champagne gold reflection — screen blend, topLeading light source)

    @ViewBuilder
    func overlay(in rect: CGRect, mode: BucketRenderMode) -> some View {
        if mode == .full {
            // Champagne gold reflection
            LinearGradient(
                stops: [
                    .init(color: Color(red: 1.0, green: 0.96, blue: 0.85).opacity(0.0), location: 0.0),
                    .init(color: Color(red: 1.0, green: 0.96, blue: 0.85).opacity(0.20), location: 0.30),
                    .init(color: Color(red: 1.0, green: 0.92, blue: 0.70).opacity(0.10), location: 0.55),
                    .init(color: Color(red: 0.80, green: 0.60, blue: 0.20).opacity(0.08), location: 1.0),
                ],
                startPoint: UnitPoint(x: 0.3, y: 0),
                endPoint: UnitPoint(x: 0.7, y: 1)
            )
            .blendMode(.screen)
            .frame(width: rect.width, height: rect.height)
            .allowsHitTesting(false)
        }
    }

    // MARK: - Color Palette (Rich champagne gold)

    var colorPalette: BucketColorPalette {
        BucketColorPalette(
            fill: Color(red: 0.65, green: 0.49, blue: 0.13, opacity: 0.85),
            stroke: Color(red: 0.75, green: 0.58, blue: 0.15),
            band: Color(red: 0.80, green: 0.65, blue: 0.25).opacity(0.2),
            accent: Color(red: 1.0, green: 0.84, blue: 0.40)
        )
    }

    // MARK: - Water Style (Golden liquid)

    var waterStyle: WaterStyle {
        WaterStyle(
            gradientTop: Color(red: 1.0, green: 0.85, blue: 0.35),
            gradientBottom: Color(red: 0.85, green: 0.60, blue: 0.05),
            dropGradientTop: Color(red: 1.0, green: 0.90, blue: 0.50),
            dropGradientBottom: Color(red: 0.90, green: 0.65, blue: 0.10),
            surfaceReflectionOpacity: 0.20
        )
    }

    // MARK: - Animation Config (Serene — no idle animation)

    var animationConfig: BucketAnimationConfig {
        .none
    }

    // MARK: - Dynamic Rain / Water Fill

    var topOpeningFraction: Double { 0.88 }
    var bottomWidthFraction: Double { 0.68 }
    var waterMaskScale: Double { 0.86 }
    var maxFillHeight: Double { 0.85 }
    var bottomInsetFraction: Double { 0.92 }
}
