import SwiftUI

// MARK: - Fast Sine Lookup Table

let sineLookup: [Double] = (0..<256).map { sin(Double($0) / 256.0 * 2.0 * .pi) }

func fastSin(_ x: Double) -> Double {
    let normalized = x.truncatingRemainder(dividingBy: 2.0 * .pi)
    let positive = normalized < 0 ? normalized + 2.0 * .pi : normalized
    let index = Int(positive / (2.0 * .pi) * 256) & 255
    return sineLookup[index]
}

// MARK: - Multi-wave Water Surface

enum WaterLayer {
    case front, back
}

struct WaterSurfaceShape: Shape {
    var progress: Double
    var waveOffset: Double
    var intensity: Double
    var layer: WaterLayer
    var tiltAngle: Double = 0
    var maxFillHeight: Double = 0.80

    // animatableData에는 waveOffset만 — repeat-forever 애니메이션의 유일한 소유자
    // progress와 tiltAngle은 부모 뷰가 보간하여 전달 (withAnimation/animation modifier)
    var animatableData: Double {
        get { waveOffset }
        set { waveOffset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let clampedProgress = min(max(progress, 0), 1.0)
        let waterTop = rect.maxY - (rect.height * maxFillHeight * clampedProgress)
        let hasWave = clampedProgress >= 0.05

        var path = Path()
        path.move(to: CGPoint(x: 0, y: waterTop))

        let intensityClamped = min(max(intensity, 0), 1)

        // Primary wave
        let primaryAmp = hasWave ? (4.0 + intensityClamped * 4.0) : 0
        let primaryWL = rect.width / 1.5
        // Secondary wave
        let secondaryAmp = hasWave ? (1.5 + intensityClamped * 2.0) : 0
        let secondaryWL = rect.width / 3.0
        // Tertiary wave
        let tertiaryAmp = hasWave ? (0.5 + intensityClamped * 1.0) : 0
        let tertiaryWL = rect.width / 8.0

        let phaseShift: Double = layer == .back ? 0.3 : 0

        // Tilt: water sloshes opposite to bucket tilt (inertia)
        // tiltAngle in degrees → convert to slope across bucket width
        let slopeFactor = max(-1, min(1, -tiltAngle / 8.0))  // clamp: 8° tilt = full slope
        let maxSlosh = rect.height * 0.06 * min(clampedProgress + 0.2, 1.0)

        for x in stride(from: 0, through: rect.width, by: 3) {
            let primary = fastSin(((x / primaryWL) + waveOffset + phaseShift) * 2 * .pi) * primaryAmp
            let secondary = fastSin(((x / secondaryWL) + waveOffset * 1.3 + phaseShift) * 2 * .pi) * secondaryAmp
            let tertiary = fastSin(((x / tertiaryWL) + waveOffset * 2.1) * 2 * .pi) * tertiaryAmp

            // Linear slope: left side goes up when tilting right (positive angle)
            let normalizedX = (x / rect.width) - 0.5  // -0.5 to +0.5
            let slosh = normalizedX * slopeFactor * maxSlosh * 2

            let y = waterTop + primary + secondary + tertiary + slosh
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Surface Highlight (light reflection line)

struct WaterSurfaceHighlight: Shape {
    var progress: Double
    var waveOffset: Double
    var intensity: Double
    var tiltAngle: Double = 0
    var maxFillHeight: Double = 0.80

    var animatableData: Double {
        get { waveOffset }
        set { waveOffset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let clampedProgress = min(max(progress, 0), 1.0)
        let waterTop = rect.maxY - (rect.height * maxFillHeight * clampedProgress)
        let intensityClamped = min(max(intensity, 0), 1)

        let primaryAmp = (4.0 + intensityClamped * 4.0)
        let primaryWL = rect.width / 1.5
        let secondaryAmp = (1.5 + intensityClamped * 2.0)
        let secondaryWL = rect.width / 3.0

        let slopeFactor = max(-1, min(1, -tiltAngle / 8.0))
        let maxSlosh = rect.height * 0.06 * min(clampedProgress + 0.2, 1.0)

        var path = Path()
        var started = false

        for x in stride(from: 0, through: rect.width, by: 3) {
            let primary = fastSin(((x / primaryWL) + waveOffset) * 2 * .pi) * primaryAmp
            let secondary = fastSin(((x / secondaryWL) + waveOffset * 1.3) * 2 * .pi) * secondaryAmp
            let normalizedX = (x / rect.width) - 0.5
            let slosh = normalizedX * slopeFactor * maxSlosh * 2
            let y = waterTop + primary + secondary + slosh - 1

            if !started {
                path.move(to: CGPoint(x: x, y: y))
                started = true
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}
