import SwiftUI

struct WoodBucket: BucketShapeProvider {

    // MARK: - Body Path (barrel with bulgeFactor 0.05, very visible belly)

    func bodyPath(in rect: CGRect, mode: BucketRenderMode) -> Path {
        var path = Path()

        let topY = rect.minY + rect.height * 0.16
        let bottomY = rect.maxY
        let topInset = rect.width * 0.16
        let bottomInset = rect.width * 0.06
        let cornerRadius = rect.width * 0.06

        let topLeft = CGPoint(x: topInset, y: topY)
        let topRight = CGPoint(x: rect.maxX - topInset, y: topY)
        let bottomRight = CGPoint(x: rect.maxX - bottomInset, y: bottomY)
        let bottomLeft = CGPoint(x: bottomInset, y: bottomY)

        // bulgeFactor = 0.05 — very visible rounded belly
        let bulgeFactor = rect.width * 0.05
        let midY = (topY + bottomY) / 2

        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addCurve(
            to: CGPoint(x: bottomRight.x - cornerRadius, y: bottomY - cornerRadius),
            control1: CGPoint(x: topRight.x + bulgeFactor, y: topY + (bottomY - topY) * 0.33),
            control2: CGPoint(x: bottomRight.x + bulgeFactor * 0.5, y: midY + (bottomY - topY) * 0.2)
        )
        path.addQuadCurve(
            to: CGPoint(x: bottomRight.x - cornerRadius * 1.5, y: bottomY),
            control: bottomRight
        )
        path.addQuadCurve(
            to: CGPoint(x: bottomLeft.x + cornerRadius * 1.5, y: bottomY),
            control: CGPoint(x: rect.midX, y: bottomY + rect.height * 0.025)
        )
        path.addQuadCurve(
            to: CGPoint(x: bottomLeft.x + cornerRadius, y: bottomY - cornerRadius),
            control: bottomLeft
        )
        path.addCurve(
            to: topLeft,
            control1: CGPoint(x: bottomLeft.x - bulgeFactor * 0.5, y: midY + (bottomY - topY) * 0.2),
            control2: CGPoint(x: topLeft.x - bulgeFactor, y: topY + (bottomY - topY) * 0.33)
        )
        path.closeSubpath()
        return path
    }

    // MARK: - Rim Path

    func rimPath(in rect: CGRect) -> Path {
        var path = Path()
        let topY = rect.minY + rect.height * 0.16
        let topInset = rect.width * 0.16
        let rimExtend: CGFloat = 6

        path.move(to: CGPoint(x: topInset - rimExtend, y: topY))
        path.addLine(to: CGPoint(x: rect.maxX - topInset + rimExtend, y: topY))
        return path
    }

    // MARK: - Handle Path

    func handlePath(in rect: CGRect) -> Path {
        var path = Path()
        let handleWidth = rect.width * 0.52
        let handleHeight = rect.height * 0.32
        let handleX = rect.midX - handleWidth / 2
        let handleY = rect.minY + rect.height * 0.16 - handleHeight

        let handleRect = CGRect(x: handleX, y: handleY, width: handleWidth, height: handleHeight)
        path.addArc(
            center: CGPoint(x: handleRect.midX, y: handleRect.maxY),
            radius: handleRect.width / 2,
            startAngle: .degrees(195),
            endAngle: .degrees(-15),
            clockwise: false
        )
        return path
    }

    // MARK: - Band Paths (at 30% and 70%, subtle thin lines)

    func bandPaths(in rect: CGRect) -> [Path] {
        return [0.30, 0.70].map { fraction in
            var path = Path()
            let topY = rect.minY + rect.height * 0.16
            let bottomY = rect.maxY
            let y = topY + (bottomY - topY) * fraction

            let topInset = rect.width * 0.16
            let bottomInset = rect.width * 0.06
            let xInset = topInset + (bottomInset - topInset) * fraction
            let bandInset = rect.width * 0.02

            path.move(to: CGPoint(x: xInset + bandInset, y: y))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - xInset - bandInset, y: y),
                control: CGPoint(x: rect.midX, y: y + 2)
            )
            return path
        }
    }

    // MARK: - Overlay (warm wood feel via gradient — no drawn lines)

    @ViewBuilder
    func overlay(in rect: CGRect, mode: BucketRenderMode) -> some View {
        if mode == .full {
            // Warm wood feel via gradient only — no drawn lines
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.45, green: 0.30, blue: 0.15).opacity(0.15), location: 0.0),
                    .init(color: Color(red: 0.55, green: 0.38, blue: 0.20).opacity(0.08), location: 0.15),
                    .init(color: Color(red: 0.42, green: 0.28, blue: 0.14).opacity(0.12), location: 0.3),
                    .init(color: Color(red: 0.50, green: 0.35, blue: 0.18).opacity(0.06), location: 0.5),
                    .init(color: Color(red: 0.40, green: 0.26, blue: 0.12).opacity(0.14), location: 0.7),
                    .init(color: Color(red: 0.48, green: 0.32, blue: 0.16).opacity(0.08), location: 0.85),
                    .init(color: Color(red: 0.38, green: 0.24, blue: 0.10).opacity(0.10), location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.multiply)
            .frame(width: rect.width, height: rect.height)
            .allowsHitTesting(false)
        } else {
            EmptyView()
        }
    }

    // MARK: - Color Palette (warm browns)

    var colorPalette: BucketColorPalette {
        BucketColorPalette(
            fill: Color(red: 0.24, green: 0.17, blue: 0.10, opacity: 0.85),
            stroke: Color(red: 0.36, green: 0.25, blue: 0.15),
            handle: Color(red: 0.36, green: 0.25, blue: 0.15),
            band: Color(red: 0.30, green: 0.20, blue: 0.10).opacity(0.3),
            accent: Color(red: 0.55, green: 0.40, blue: 0.25)
        )
    }

    // MARK: - Water Style

    var waterStyle: WaterStyle {
        .defaultBlue
    }

    // MARK: - Animation Config (breathe)

    var animationConfig: BucketAnimationConfig {
        BucketAnimationConfig(
            idleAnimation: .breathe(scale: 1.02, duration: 6.0),
            waveIntensityMultiplier: 1.0
        )
    }

    // MARK: - Dynamic Rain / Water Fill

    var topOpeningFraction: Double { 0.68 }
    var bottomWidthFraction: Double { 0.88 }
    var waterMaskScale: Double { 0.84 }
    var maxFillHeight: Double { 0.82 }
    var bottomInsetFraction: Double { 0.94 }
}
