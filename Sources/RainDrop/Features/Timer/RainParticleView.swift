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

    @State private var particles: [RainParticle] = []

    private let particleCount = 40

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
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

                    let gradient = Gradient(colors: [
                        dropGradientTop.opacity(particle.opacity),
                        dropGradientBottom.opacity(particle.opacity * 0.8)
                    ])

                    context.fill(
                        Capsule().path(in: rect),
                        with: .linearGradient(
                            gradient,
                            startPoint: CGPoint(x: rect.midX, y: rect.minY),
                            endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                        )
                    )
                }
            }
            .onChange(of: timeline.date) { _ in
                updateParticles()
            }
        }
        .onAppear {
            if isAnimating {
                initializeParticles()
            }
        }
        .onChange(of: isAnimating) { animating in
            if animating {
                initializeParticles()
            } else {
                particles.removeAll()
            }
        }
    }

    private func initializeParticles() {
        particles = (0..<particleCount).map { _ in
            RainParticle(
                x: Double.random(in: 0.05...0.95),
                y: Double.random(in: -0.3...1.0),
                speed: Double.random(in: 0.008...0.018),
                size: Double.random(in: 2...5),
                opacity: Double.random(in: 0.3...0.8)
            )
        }
    }

    private func updateParticles() {
        guard isAnimating else { return }

        var updated = particles
        for i in updated.indices {
            updated[i].y += updated[i].speed

            if updated[i].y > 1.1 {
                updated[i] = RainParticle(
                    x: Double.random(in: 0.05...0.95),
                    y: Double.random(in: -0.2...(-0.05)),
                    speed: Double.random(in: 0.008...0.018),
                    size: Double.random(in: 2...5),
                    opacity: Double.random(in: 0.3...0.8)
                )
            }
        }
        particles = updated
    }
}
