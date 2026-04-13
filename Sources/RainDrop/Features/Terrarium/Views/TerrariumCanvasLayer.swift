import SwiftUI

struct TerrariumCanvasLayer: View {
    let placements: [PlantPlacement]
    let phase: GrowthSnapshot.GrowthPhase
    let biomeTheme: BiomeTheme
    var reduceAnimations: Bool = false

    var body: some View {
        if reduceAnimations {
            // Static render — no TimelineView, zero CPU when idle
            Canvas { ctx, size in
                drawGround(ctx: ctx, size: size, time: 0)
                for placement in placements {
                    drawPlant(ctx: ctx, size: size, placement: placement, time: 0)
                }
                if phase.rawValue >= 3 {
                    drawAmbientParticles(ctx: ctx, size: size, time: 0)
                }
            }
            .allowsHitTesting(false)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate

                Canvas { ctx, size in
                    // Ground layer
                    drawGround(ctx: ctx, size: size, time: time)

                    // Plants (sorted by zIndex — back to front)
                    for placement in placements {
                        drawPlant(ctx: ctx, size: size, placement: placement, time: time)
                    }

                    // Ambient particles (phase 3+)
                    if phase.rawValue >= 3 {
                        drawAmbientParticles(ctx: ctx, size: size, time: time)
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func drawGround(ctx: GraphicsContext, size: CGSize, time: TimeInterval) {
        // Subtle ground gradient at bottom
        let groundHeight = size.height * 0.12
        let groundRect = CGRect(
            x: 0,
            y: size.height - groundHeight,
            width: size.width,
            height: groundHeight
        )
        let gradient = Gradient(colors: biomeTheme.groundGradient.map { $0.opacity(0.3) })
        ctx.fill(
            Path(roundedRect: groundRect, cornerRadius: groundHeight / 2),
            with: .linearGradient(
                gradient,
                startPoint: CGPoint(x: 0, y: groundRect.minY),
                endPoint: CGPoint(x: 0, y: groundRect.maxY)
            )
        )
    }

    private func drawPlant(
        ctx: GraphicsContext,
        size: CGSize,
        placement: PlantPlacement,
        time: TimeInterval
    ) {
        let x = placement.position.x * size.width
        let y = placement.position.y * size.height
        let scale = placement.scale

        // Gentle sway animation
        let swayPhase = time * 0.5 + placement.position.x * 10
        let sway = sin(swayPhase) * 2.0 * scale

        var plantCtx = ctx

        // Glow effect for luminescent plants
        if placement.template.glows {
            let glowPulse = 0.3 + 0.2 * sin(time * 1.5 + placement.position.x * 5)
            plantCtx.addFilter(.blur(radius: 4))
            plantCtx.opacity = glowPulse
            drawPlantShape(
                ctx: plantCtx,
                type: placement.template.type,
                x: x + sway,
                y: y,
                scale: scale * 1.3,
                color: placement.template.color
            )
            plantCtx = ctx // Reset for solid plant
        }

        drawPlantShape(
            ctx: ctx,
            type: placement.template.type,
            x: x + sway,
            y: y,
            scale: scale,
            color: placement.template.color
        )
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func drawPlantShape(
        ctx: GraphicsContext,
        type: PlantType,
        x: Double,
        y: Double,
        scale: CGFloat,
        color: Color
    ) {
        let s = scale * 20 // Base unit size

        switch type {
        case .moss:
            // Horizontal ellipse on ground
            let rect = CGRect(x: x - s * 1.2, y: y - s * 0.3, width: s * 2.4, height: s * 0.6)
            ctx.fill(Path(ellipseIn: rect), with: .color(color))

        case .sprout:
            // Thin stem + small leaf
            var stem = Path()
            stem.move(to: CGPoint(x: x, y: y))
            stem.addLine(to: CGPoint(x: x, y: y - s * 1.5))
            ctx.stroke(stem, with: .color(color), lineWidth: 1.5)
            let leaf = CGRect(x: x - s * 0.3, y: y - s * 1.8, width: s * 0.6, height: s * 0.4)
            ctx.fill(Path(ellipseIn: leaf), with: .color(color))

        case .smallFlower:
            // Stem + circle bloom
            var stem = Path()
            stem.move(to: CGPoint(x: x, y: y))
            stem.addLine(to: CGPoint(x: x, y: y - s * 2))
            ctx.stroke(stem, with: .color(color.opacity(0.6)), lineWidth: 1.2)
            let bloom = CGRect(x: x - s * 0.4, y: y - s * 2.5, width: s * 0.8, height: s * 0.8)
            ctx.fill(Path(ellipseIn: bloom), with: .color(color))

        case .tallFlower:
            // Taller stem + larger bloom
            var stem = Path()
            stem.move(to: CGPoint(x: x, y: y))
            stem.addLine(to: CGPoint(x: x, y: y - s * 3))
            ctx.stroke(stem, with: .color(color.opacity(0.5)), lineWidth: 1.5)
            let bloom = CGRect(x: x - s * 0.5, y: y - s * 3.6, width: s * 1.0, height: s * 1.0)
            ctx.fill(Path(ellipseIn: bloom), with: .color(color))

        case .fern:
            // Fan of 3 curved lines
            for i in -1...1 {
                var frond = Path()
                frond.move(to: CGPoint(x: x, y: y))
                let angle = Double(i) * 0.3
                frond.addQuadCurve(
                    to: CGPoint(x: x + sin(angle) * s * 2, y: y - s * 2.5),
                    control: CGPoint(x: x + sin(angle) * s * 1.5, y: y - s * 1.2)
                )
                ctx.stroke(frond, with: .color(color), lineWidth: 1.5)
            }

        case .mushroom:
            // Stem + dome cap
            let capRect = CGRect(x: x - s * 0.6, y: y - s * 1.5, width: s * 1.2, height: s * 0.8)
            ctx.fill(Path(ellipseIn: capRect), with: .color(color))
            var stem = Path()
            stem.move(to: CGPoint(x: x - s * 0.15, y: y))
            stem.addLine(to: CGPoint(x: x - s * 0.15, y: y - s * 1.1))
            stem.addLine(to: CGPoint(x: x + s * 0.15, y: y - s * 1.1))
            stem.addLine(to: CGPoint(x: x + s * 0.15, y: y))
            ctx.fill(stem, with: .color(color.opacity(0.7)))

        case .bush:
            // Cluster of overlapping circles
            let offsets: [(Double, Double)] = [
                (-0.5, -0.3), (0.3, -0.5), (0.0, -0.8), (-0.3, -0.6), (0.5, -0.4),
            ]
            for (dx, dy) in offsets {
                let r = s * 0.5
                let rect = CGRect(x: x + dx * s - r, y: y + dy * s - r, width: r * 2, height: r * 2)
                ctx.fill(Path(ellipseIn: rect), with: .color(color.opacity(0.8)))
            }

        case .smallTree:
            // Trunk + canopy circle
            var trunk = Path()
            trunk.move(to: CGPoint(x: x - s * 0.12, y: y))
            trunk.addLine(to: CGPoint(x: x - s * 0.12, y: y - s * 2))
            trunk.addLine(to: CGPoint(x: x + s * 0.12, y: y - s * 2))
            trunk.addLine(to: CGPoint(x: x + s * 0.12, y: y))
            ctx.fill(trunk, with: .color(color.opacity(0.6)))
            let canopy = CGRect(x: x - s * 0.8, y: y - s * 3.5, width: s * 1.6, height: s * 1.8)
            ctx.fill(Path(ellipseIn: canopy), with: .color(color))

        case .vine:
            // Wavy line climbing up
            var vine = Path()
            vine.move(to: CGPoint(x: x, y: y))
            vine.addCurve(
                to: CGPoint(x: x + s * 0.5, y: y - s * 3),
                control1: CGPoint(x: x - s * 0.8, y: y - s * 1),
                control2: CGPoint(x: x + s * 1.0, y: y - s * 2)
            )
            ctx.stroke(vine, with: .color(color), lineWidth: 2)

        case .glowPlant:
            // Luminescent orb on thin stem
            var stem = Path()
            stem.move(to: CGPoint(x: x, y: y))
            stem.addLine(to: CGPoint(x: x, y: y - s * 2))
            ctx.stroke(stem, with: .color(color.opacity(0.4)), lineWidth: 1)
            let orb = CGRect(x: x - s * 0.5, y: y - s * 2.8, width: s * 1.0, height: s * 1.0)
            ctx.fill(Path(ellipseIn: orb), with: .color(color))
        }
    }

    private func drawAmbientParticles(ctx: GraphicsContext, size: CGSize, time: TimeInterval) {
        let particleCount = phase == .transcendence ? 15 : 8

        for i in 0..<particleCount {
            let p = time * 0.3 + Double(i) * 1.7
            let x = size.width * (0.1 + 0.8 * ((sin(p * 0.7) + 1) / 2))
            let y = size.height * (0.3 + 0.5 * ((cos(p * 0.5 + Double(i)) + 1) / 2))
            let radius = 2.0 + 1.5 * sin(p * 2)
            let opacity = 0.15 + 0.15 * sin(p * 1.5)

            let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
            ctx.fill(
                Path(ellipseIn: rect),
                with: .color(biomeTheme.particleColor.opacity(opacity))
            )
        }
    }
}
