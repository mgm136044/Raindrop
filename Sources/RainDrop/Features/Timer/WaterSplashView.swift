import SwiftUI

struct SplashParticle {
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var life: Double
    var maxLife: Double
    var size: Double
}

struct WaterSplashView: View {
    let waterLevel: Double
    let intensity: Double
    let isActive: Bool
    let splashColor: Color

    @State private var splashes: [SplashParticle] = []
    @State private var frameCount: Int = 0

    private var spawnRate: Int {
        Int(2 + min(max(intensity, 0), 1) * 8)
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let waterY = size.height * (1.0 - waterLevel * 0.80)

                for splash in splashes {
                    let alpha = max(1.0 - splash.life / splash.maxLife, 0)
                    let x = splash.x * size.width
                    let y = waterY + splash.y

                    let rect = CGRect(
                        x: x - splash.size / 2,
                        y: y - splash.size / 2,
                        width: splash.size,
                        height: splash.size
                    )

                    context.fill(
                        Circle().path(in: rect),
                        with: .color(splashColor.opacity(alpha * 0.6))
                    )
                }
            }
            .onChange(of: timeline.date) { _,_ in
                updateSplashes()
            }
        }
    }

    private func updateSplashes() {
        guard isActive, waterLevel > 0.05 else {
            splashes.removeAll()
            return
        }

        frameCount += 1
        var updated = splashes

        // Spawn new splashes
        if frameCount % max(30 / spawnRate, 1) == 0 {
            let newSplash = SplashParticle(
                x: Double.random(in: 0.15...0.85),
                y: 0,
                vx: Double.random(in: -0.3...0.3),
                vy: Double.random(in: -4.0...(-1.5)),
                life: 0,
                maxLife: Double.random(in: 0.3...0.6),
                size: Double.random(in: 1.5...3.5)
            )
            updated.append(newSplash)
        }

        // Update existing
        let dt = 1.0 / 30.0
        updated = updated.compactMap { var s = $0
            s.life += dt
            if s.life >= s.maxLife { return nil }
            s.x += s.vx * dt * 0.02
            s.y += s.vy
            s.vy += 12 * dt  // gravity
            return s
        }

        splashes = updated
    }
}
