import SwiftUI

// MARK: - Fast Sine Lookup Table

private enum WaveMath {
    static let sineLookup: [Double] = (0..<256).map { sin(Double($0) / 256.0 * 2.0 * .pi) }

    static func fastSin(_ x: Double) -> Double {
        let normalized = x.truncatingRemainder(dividingBy: 2.0 * .pi)
        let positive = normalized < 0 ? normalized + 2.0 * .pi : normalized
        let index = Int(positive / (2.0 * .pi) * 256) & 255
        return sineLookup[index]
    }
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
    var maxFillHeight: Double = 0.80

    // animatableData에는 waveOffset만 — repeat-forever 애니메이션의 유일한 소유자
    // progress는 부모 뷰가 보간하여 전달 (withAnimation/animation modifier)
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

        for x in stride(from: 0, through: rect.width, by: 3) {
            let primary = WaveMath.fastSin(((x / primaryWL) + waveOffset + phaseShift) * 2 * .pi) * primaryAmp
            let secondary = WaveMath.fastSin(((x / secondaryWL) + waveOffset * 1.3 + phaseShift) * 2 * .pi) * secondaryAmp
            let tertiary = WaveMath.fastSin(((x / tertiaryWL) + waveOffset * 2.1) * 2 * .pi) * tertiaryAmp

            let y = waterTop + primary + secondary + tertiary
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

        var path = Path()
        var started = false

        for x in stride(from: 0, through: rect.width, by: 3) {
            let primary = WaveMath.fastSin(((x / primaryWL) + waveOffset) * 2 * .pi) * primaryAmp
            let secondary = WaveMath.fastSin(((x / secondaryWL) + waveOffset * 1.3) * 2 * .pi) * secondaryAmp
            let y = waterTop + primary + secondary - 1

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
