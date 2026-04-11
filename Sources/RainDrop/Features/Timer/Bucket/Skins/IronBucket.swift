import SwiftUI

struct IronBucket: BucketShapeProvider {

    // MARK: - Body Path (very straight walls, wider, flat-topped industrial)

    func bodyPath(in rect: CGRect, mode: BucketRenderMode) -> Path {
        var path = Path()

        let topY = rect.minY + rect.height * 0.06
        let bottomY = rect.maxY
        let sideInset = rect.width * 0.08
        // Zero corner radius at top, small radius at bottom only
        let bottomCornerRadius = rect.width * 0.03

        let topLeft = CGPoint(x: sideInset, y: topY)
        let topRight = CGPoint(x: rect.maxX - sideInset, y: topY)
        let bottomRight = CGPoint(x: rect.maxX - sideInset, y: bottomY)
        let bottomLeft = CGPoint(x: sideInset, y: bottomY)

        path.move(to: topLeft)
        path.addLine(to: topRight)
        // Right wall: perfectly straight down to bottom corner
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - bottomCornerRadius))
        // Bottom-right corner (small radius only)
        path.addQuadCurve(
            to: CGPoint(x: bottomRight.x - bottomCornerRadius, y: bottomRight.y),
            control: bottomRight
        )
        // Bottom edge straight
        path.addLine(to: CGPoint(x: bottomLeft.x + bottomCornerRadius, y: bottomLeft.y))
        // Bottom-left corner (small radius only)
        path.addQuadCurve(
            to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - bottomCornerRadius),
            control: bottomLeft
        )
        // Left wall: perfectly straight up
        path.addLine(to: topLeft)
        path.closeSubpath()
        return path
    }

    // MARK: - Rim Path (extends 8pt, flat-topped)

    func rimPath(in rect: CGRect) -> Path {
        var path = Path()
        let topY = rect.minY + rect.height * 0.06
        let sideInset = rect.width * 0.08
        let rimExtend: CGFloat = 8

        path.move(to: CGPoint(x: sideInset - rimExtend, y: topY))
        path.addLine(to: CGPoint(x: rect.maxX - sideInset + rimExtend, y: topY))
        return path
    }

    // MARK: - Band Paths (two straight lines at 30% and 70%)

    func bandPaths(in rect: CGRect) -> [Path] {
        let topY = rect.minY + rect.height * 0.06
        let bottomY = rect.maxY
        let sideInset = rect.width * 0.08
        let bandInset = rect.width * 0.02
        let fractions: [Double] = [0.30, 0.70]

        return fractions.map { fraction in
            var path = Path()
            let y = topY + (bottomY - topY) * fraction
            let leftX = sideInset + bandInset
            let rightX = rect.maxX - sideInset - bandInset
            path.move(to: CGPoint(x: leftX, y: y))
            path.addLine(to: CGPoint(x: rightX, y: y))
            return path
        }
    }

    // MARK: - Overlay (brushed metal: diagonal gradient — no rivets)

    @ViewBuilder
    func overlay(in rect: CGRect, mode: BucketRenderMode) -> some View {
        if mode == .full {
            // Brushed metal: diagonal gradient
            LinearGradient(
                stops: [
                    .init(color: Color.white.opacity(0.0), location: 0.0),
                    .init(color: Color.white.opacity(0.06), location: 0.25),
                    .init(color: Color.white.opacity(0.0), location: 0.45),
                    .init(color: Color.white.opacity(0.04), location: 0.7),
                    .init(color: Color.white.opacity(0.0), location: 1.0),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.overlay)
            .frame(width: rect.width, height: rect.height)
            .allowsHitTesting(false)
        } else {
            EmptyView()
        }
    }

    // MARK: - Color Palette (dark industrial steel)

    var colorPalette: BucketColorPalette {
        BucketColorPalette(
            fill: Color(red: 0.18, green: 0.20, blue: 0.22, opacity: 0.88),
            stroke: Color(red: 0.30, green: 0.33, blue: 0.36),
            band: Color(red: 0.40, green: 0.43, blue: 0.46).opacity(0.25),
            accent: Color(red: 0.29, green: 0.33, blue: 0.37)
        )
    }

    // MARK: - Water Style

    var waterStyle: WaterStyle {
        WaterStyle(
            gradientTop: AppColors.waterGradientTopColor,
            gradientBottom: AppColors.waterGradientBottomColor,
            dropGradientTop: AppColors.dropGradientTopColor,
            dropGradientBottom: AppColors.dropGradientBottomColor,
            surfaceReflectionOpacity: 0.12
        )
    }

    // MARK: - Animation Config

    var animationConfig: BucketAnimationConfig {
        .none
    }

    // MARK: - Dynamic Rain / Water Fill

    var topOpeningFraction: Double { 0.84 }
    var bottomWidthFraction: Double { 0.84 }
    var waterMaskScale: Double { 0.88 }
    var maxFillHeight: Double { 0.78 }
    var bottomInsetFraction: Double { 0.92 }
}
