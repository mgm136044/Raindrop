import SwiftUI

struct RainParticle {
    var x: Double
    var y: Double
    var speed: Double
    var size: Double
    var opacity: Double
}

struct RainParticleView: View {
    let isAnimating: Bool
    let dropGradientTop: Color
    let dropGradientBottom: Color
    var intensity: Double = 0.5

    @State private var particles: [RainParticle] = []

    private var desiredCount: Int {
        Int(8 + (80 - 8) * min(max(intensity, 0), 1))
    }

    private var speedRange: ClosedRange<Double> {
        let lo = 0.004 + (0.012 - 0.004) * intensity
        let hi = 0.010 + (0.025 - 0.010) * intensity
        return lo...hi
    }

    private var sizeRange: ClosedRange<Double> {
        let lo = 1.5 + (3.0 - 1.5) * intensity
        let hi = 3.0 + (7.0 - 3.0) * intensity
        return lo...hi
    }

    private var opacityRange: ClosedRange<Double> {
        let lo = 0.15 + (0.4 - 0.15) * intensity
        let hi = 0.4 + (0.9 - 0.4) * intensity
        return lo...hi
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let sharedGradient = Gradient(colors: [
                    dropGradientTop,
                    dropGradientBottom.opacity(0.8)
                ])

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

                    var particleContext = context
                    particleContext.opacity = particle.opacity
                    particleContext.fill(
                        Capsule().path(in: rect),
                        with: .linearGradient(
                            sharedGradient,
                            startPoint: CGPoint(x: rect.midX, y: rect.minY),
                            endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                        )
                    )
                }
            }
            .onChange(of: timeline.date) { _,_ in
                updateParticles()
            }
        }
        .onAppear {
            if isAnimating {
                initializeParticles()
            }
        }
        .onChange(of: isAnimating) { _,animating in
            if animating {
                initializeParticles()
            } else {
                particles.removeAll()
            }
        }
    }

    private func makeParticle(yRange: ClosedRange<Double> = -0.3...1.0) -> RainParticle {
        RainParticle(
            x: Double.random(in: 0.05...0.95),
            y: Double.random(in: yRange),
            speed: Double.random(in: speedRange),
            size: Double.random(in: sizeRange),
            opacity: Double.random(in: opacityRange)
        )
    }

    private func initializeParticles() {
        particles = (0..<desiredCount).map { _ in makeParticle() }
    }

    private func updateParticles() {
        guard isAnimating else { return }

        var updated = particles

        // Adjust particle count gradually
        let target = desiredCount
        if updated.count < target {
            let toAdd = min(target - updated.count, 3)
            for _ in 0..<toAdd {
                updated.append(makeParticle(yRange: -0.3...(-0.05)))
            }
        } else if updated.count > target {
            let toRemove = min(updated.count - target, 2)
            updated.removeLast(toRemove)
        }

        for i in updated.indices {
            updated[i].y += updated[i].speed

            if updated[i].y > 1.1 {
                updated[i] = makeParticle(yRange: -0.2...(-0.05))
            }
        }
        particles = updated
    }
}
