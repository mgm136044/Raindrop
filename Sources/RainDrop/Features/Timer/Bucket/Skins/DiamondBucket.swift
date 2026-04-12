import SwiftUI

struct DiamondBucket: BucketShapeProvider {

    // MARK: - Body Path (Dramatic octagon — large facets, immediately geometric)

    func bodyPath(in rect: CGRect, mode: BucketRenderMode) -> Path {
        let sideInset = rect.width * 0.10    // Slightly narrower sides for more presence
        let facetInset = rect.width * 0.06   // Larger facets — more dramatic chamfer
        let topY = rect.height * 0.08
        let bottomY = rect.height * 0.92

        let leftX = rect.minX + sideInset
        let rightX = rect.maxX - sideInset
        let topLeftX = leftX + facetInset
        let topRightX = rightX - facetInset
        let topFacetY = topY + facetInset
        let bottomFacetY = bottomY - facetInset

        var path = Path()
        path.move(to: CGPoint(x: topLeftX, y: topY))
        // Top edge
        path.addLine(to: CGPoint(x: topRightX, y: topY))
        // Top-right chamfer
        path.addLine(to: CGPoint(x: rightX, y: topFacetY))
        // Right wall
        path.addLine(to: CGPoint(x: rightX, y: bottomFacetY))
        // Bottom-right chamfer
        path.addLine(to: CGPoint(x: topRightX, y: bottomY))
        // Bottom edge
        path.addLine(to: CGPoint(x: topLeftX, y: bottomY))
        // Bottom-left chamfer
        path.addLine(to: CGPoint(x: leftX, y: bottomFacetY))
        // Left wall
        path.addLine(to: CGPoint(x: leftX, y: topFacetY))
        // Top-left chamfer closes back to start
        path.closeSubpath()
        return path
    }

    // MARK: - Rim Path (Octagonal rim matching top geometry)

    func rimPath(in rect: CGRect) -> Path {
        let sideInset = rect.width * 0.10
        let facetInset = rect.width * 0.06
        let rimExtend: CGFloat = 3
        let topY = rect.height * 0.08
        let rimHeight: CGFloat = 6

        let leftX = rect.minX + sideInset - rimExtend
        let rightX = rect.maxX - sideInset + rimExtend
        let topLeftX = leftX + facetInset
        let topRightX = rightX - facetInset
        let topFacetY = topY + facetInset

        var path = Path()
        path.move(to: CGPoint(x: topLeftX, y: topY))
        path.addLine(to: CGPoint(x: topRightX, y: topY))
        path.addLine(to: CGPoint(x: rightX, y: topFacetY))
        path.addLine(to: CGPoint(x: rightX, y: topFacetY + rimHeight))
        path.addLine(to: CGPoint(x: leftX, y: topFacetY + rimHeight))
        path.addLine(to: CGPoint(x: leftX, y: topFacetY))
        path.closeSubpath()
        return path
    }

    // MARK: - Band Paths (None — pure crystal geometry)

    func bandPaths(in rect: CGRect) -> [Path] {
        []
    }

    // MARK: - Overlay (Layered refraction gradients — no FacetOverlay)

    @ViewBuilder
    func overlay(in rect: CGRect, mode: BucketRenderMode) -> some View {
        if mode == .full {
            ZStack {
                // Refraction layer 1 — 45° diagonal
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.0),
                        Color.cyan.opacity(0.08),
                        Color.white.opacity(0.0)
                    ],
                    startPoint: UnitPoint(x: 0, y: 0),
                    endPoint: UnitPoint(x: 1, y: 1)
                )
                .blendMode(.screen)

                // Refraction layer 2 — 135° diagonal
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.0),
                        Color.blue.opacity(0.05),
                        Color.white.opacity(0.0)
                    ],
                    startPoint: UnitPoint(x: 1, y: 0),
                    endPoint: UnitPoint(x: 0, y: 1)
                )
                .blendMode(.screen)

                // Refraction layer 3 — vertical specular
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.12),
                        Color.clear,
                        Color.white.opacity(0.06)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blendMode(.screen)
            }
            .frame(width: rect.width, height: rect.height)
            .allowsHitTesting(false)
        }
    }

    // MARK: - Color Palette (Ice crystal — very transparent)

    var colorPalette: BucketColorPalette {
        BucketColorPalette(
            fill: Color(red: 0.85, green: 0.92, blue: 1.0, opacity: 0.45),
            stroke: Color(red: 0.70, green: 0.82, blue: 0.95),
            band: .clear,
            accent: Color(red: 0.80, green: 0.92, blue: 1.0)
        )
    }

    // MARK: - Water Style (Crystal blue)

    var waterStyle: WaterStyle {
        WaterStyle(
            gradientTop: Color(red: 0.88, green: 0.96, blue: 1.0),
            gradientBottom: Color(red: 0.40, green: 0.65, blue: 0.95),
            dropGradientTop: Color(red: 0.80, green: 0.95, blue: 1.0),
            dropGradientBottom: Color(red: 0.50, green: 0.70, blue: 1.0),
            surfaceReflectionOpacity: 0.30
        )
    }

    // MARK: - Animation Config (Static refraction — 3 gradient layers replace shimmer)

    var animationConfig: BucketAnimationConfig {
        BucketAnimationConfig(idleAnimation: nil, waveIntensityMultiplier: 0.5)
    }

    // MARK: - Dynamic Rain / Water Fill

    var topOpeningFraction: Double { 0.68 }
    var bottomWidthFraction: Double { 0.68 }
    var waterMaskScale: Double { 0.84 }
    var maxFillHeight: Double { 0.72 }
    var bottomInsetFraction: Double { 0.92 }
}
