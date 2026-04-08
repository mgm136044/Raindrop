import SwiftUI

struct BucketView: View {
    let progress: Double
    let skin: BucketSkin
    let useCustomWaterColor: Bool
    var intensity: Double = 0.5
    var waterColorOverride: (top: Color, bottom: Color)?
    var tiltAngle: Double = 0
    @State private var waveOffset: Double = 0

    private var waterGradientTop: Color {
        if let override = waterColorOverride { return override.top }
        if useCustomWaterColor && skin.hasCustomWaterColor {
            return skin.customWaterGradientTop
        }
        return AppColors.waterGradientTopColor
    }

    private var waterGradientBottom: Color {
        if let override = waterColorOverride { return override.bottom }
        if useCustomWaterColor && skin.hasCustomWaterColor {
            return skin.customWaterGradientBottom
        }
        return AppColors.waterGradientBottomColor
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .bottom) {
                // Bucket background fill
                BucketShape()
                    .fill(skin.bucketFill)

                // Water layer 1 (back, softer)
                WaterSurfaceShape(progress: progress, waveOffset: waveOffset + 0.3, intensity: intensity, layer: .back, tiltAngle: tiltAngle)
                    .fill(
                        LinearGradient(
                            colors: [
                                waterGradientTop.opacity(0.45),
                                waterGradientBottom.opacity(0.45)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .mask(BucketShape().scale(0.86))

                // Water layer 2 (front, primary)
                WaterSurfaceShape(progress: progress, waveOffset: waveOffset, intensity: intensity, layer: .front, tiltAngle: tiltAngle)
                    .fill(
                        LinearGradient(
                            colors: [
                                waterGradientTop,
                                waterGradientBottom
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .mask(BucketShape().scale(0.86))

                // Surface highlight (light reflection)
                if progress > 0.05 {
                    WaterSurfaceHighlight(progress: progress, waveOffset: waveOffset, intensity: intensity, tiltAngle: tiltAngle)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                        .mask(BucketShape().scale(0.86))
                }

                // Metal bands
                BucketBand(verticalFraction: 0.30)
                    .stroke(skin.bandColor, lineWidth: 2.5)
                BucketBand(verticalFraction: 0.70)
                    .stroke(skin.bandColor, lineWidth: 2.5)

                // Bucket outline
                BucketShape()
                    .stroke(skin.bucketStroke, lineWidth: 5)

                // Rim
                BucketRim()
                    .stroke(skin.bucketStroke, style: StrokeStyle(lineWidth: 7, lineCap: .round))

                // Handle
                BucketHandleShape()
                    .stroke(skin.bucketHandle, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .frame(width: width * 0.52, height: height * 0.32)
                    .offset(y: -height * 0.30)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                waveOffset = 1.0
            }
        }
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
    var tiltAngle: Double = 0

    // animatableData에는 waveOffset만 — repeat-forever 애니메이션의 유일한 소유자
    // progress와 tiltAngle은 부모 뷰가 보간하여 전달 (withAnimation/animation modifier)
    var animatableData: Double {
        get { waveOffset }
        set { waveOffset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let clampedProgress = min(max(progress, 0), 1.0)
        let waterTop = rect.maxY - (rect.height * 0.80 * clampedProgress)
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

        for x in stride(from: 0, through: rect.width, by: 2) {
            let primary = sin(((x / primaryWL) + waveOffset + phaseShift) * 2 * .pi) * primaryAmp
            let secondary = sin(((x / secondaryWL) + waveOffset * 1.3 + phaseShift) * 2 * .pi) * secondaryAmp
            let tertiary = sin(((x / tertiaryWL) + waveOffset * 2.1) * 2 * .pi) * tertiaryAmp

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

private struct WaterSurfaceHighlight: Shape {
    var progress: Double
    var waveOffset: Double
    var intensity: Double
    var tiltAngle: Double = 0

    var animatableData: Double {
        get { waveOffset }
        set { waveOffset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let clampedProgress = min(max(progress, 0), 1.0)
        let waterTop = rect.maxY - (rect.height * 0.80 * clampedProgress)
        let intensityClamped = min(max(intensity, 0), 1)

        let primaryAmp = (4.0 + intensityClamped * 4.0)
        let primaryWL = rect.width / 1.5
        let secondaryAmp = (1.5 + intensityClamped * 2.0)
        let secondaryWL = rect.width / 3.0

        let slopeFactor = max(-1, min(1, -tiltAngle / 8.0))
        let maxSlosh = rect.height * 0.06 * min(clampedProgress + 0.2, 1.0)

        var path = Path()
        var started = false

        for x in stride(from: 0, through: rect.width, by: 2) {
            let primary = sin(((x / primaryWL) + waveOffset) * 2 * .pi) * primaryAmp
            let secondary = sin(((x / secondaryWL) + waveOffset * 1.3) * 2 * .pi) * secondaryAmp
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

// MARK: - Bucket Shape (rounded barrel)

struct BucketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let topY = rect.minY + rect.height * 0.06
        let bottomY = rect.maxY
        let topInset = rect.width * 0.14
        let bottomInset = rect.width * 0.08
        let cornerRadius = rect.width * 0.06

        let topLeft = CGPoint(x: topInset, y: topY)
        let topRight = CGPoint(x: rect.maxX - topInset, y: topY)
        let bottomRight = CGPoint(x: rect.maxX - bottomInset, y: bottomY)
        let bottomLeft = CGPoint(x: bottomInset, y: bottomY)

        let bulgeFactor = rect.width * 0.025
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
}

// MARK: - Bucket Rim

struct BucketRim: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topY = rect.minY + rect.height * 0.06
        let topInset = rect.width * 0.14
        let rimExtend: CGFloat = 6

        path.move(to: CGPoint(x: topInset - rimExtend, y: topY))
        path.addLine(to: CGPoint(x: rect.maxX - topInset + rimExtend, y: topY))
        return path
    }
}

// MARK: - Metal Bands

struct BucketBand: Shape {
    let verticalFraction: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topY = rect.minY + rect.height * 0.06
        let bottomY = rect.maxY
        let y = topY + (bottomY - topY) * verticalFraction

        let topInset = rect.width * 0.14
        let bottomInset = rect.width * 0.08
        let xInset = topInset + (bottomInset - topInset) * verticalFraction
        let bandInset = rect.width * 0.02

        path.move(to: CGPoint(x: xInset + bandInset, y: y))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - xInset - bandInset, y: y),
            control: CGPoint(x: rect.midX, y: y + 2)
        )
        return path
    }
}

// MARK: - Handle

struct BucketHandleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY),
            radius: rect.width / 2,
            startAngle: .degrees(195),
            endAngle: .degrees(-15),
            clockwise: false
        )
        return path
    }
}
