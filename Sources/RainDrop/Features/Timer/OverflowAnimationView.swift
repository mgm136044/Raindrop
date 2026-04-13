import SwiftUI

struct SparkleParticle {
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var life: Double
    var maxLife: Double
    var size: Double
}

struct OverflowAnimationView: View {
    let isActive: Bool

    @State private var sparkles: [SparkleParticle] = []
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            if sparkles.isEmpty {
                Color.clear
            } else {
                // Golden sparkle burst
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    Canvas { context, size in
                        for sparkle in sparkles {
                            let alpha = max(1.0 - sparkle.life / sparkle.maxLife, 0)
                            let x = sparkle.x * size.width
                            let y = sparkle.y * size.height

                            let rect = CGRect(
                                x: x - sparkle.size / 2,
                                y: y - sparkle.size / 2,
                                width: sparkle.size,
                                height: sparkle.size
                            )

                            context.fill(
                                Circle().path(in: rect),
                                with: .color(Color.yellow.opacity(alpha * 0.8))
                            )

                            // Glow
                            let glowRect = rect.insetBy(dx: -sparkle.size * 0.5, dy: -sparkle.size * 0.5)
                            context.fill(
                                Circle().path(in: glowRect),
                                with: .color(Color.orange.opacity(alpha * 0.2))
                            )
                        }
                    }
                    .onChange(of: timeline.date) { _,_ in
                        updateSparkles()
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(opacity)
        .onChange(of: isActive) { _,active in
            if active {
                spawnBurst()
                // Delay fade-in by one cycle to let TimelineView insert first
                DispatchQueue.main.async {
                    withAnimation(.easeIn(duration: 0.3)) {
                        opacity = 1.0
                    }
                }
                Task {
                    try? await Task.sleep(for: .seconds(2.5))
                    withAnimation(.easeOut(duration: 0.5)) {
                        opacity = 0
                    }
                }
            } else {
                sparkles.removeAll()
                opacity = 0
            }
        }
    }

    private func spawnBurst() {
        sparkles = (0..<25).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 0.003...0.012)
            return SparkleParticle(
                x: 0.5,
                y: 0.45,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed,
                life: 0,
                maxLife: Double.random(in: 1.0...2.5),
                size: Double.random(in: 3...7)
            )
        }
    }

    private func updateSparkles() {
        guard !sparkles.isEmpty else { return }
        let dt = 1.0 / 30.0
        sparkles = sparkles.compactMap { var s = $0
            s.life += dt
            if s.life >= s.maxLife { return nil }
            s.x += s.vx
            s.y += s.vy
            s.vy += 0.0002  // light gravity
            s.size *= 0.995
            return s
        }
    }
}
