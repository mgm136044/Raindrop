import SwiftUI

struct BucketView: View {
    let progress: Double
    let skin: BucketSkin
    let useCustomWaterColor: Bool
    @State private var waveOffset: Double = 0

    private var waterGradientTop: Color {
        if useCustomWaterColor && skin.hasCustomWaterColor {
            return skin.customWaterGradientTop
        }
        return AppColors.waterGradientTopColor
    }

    private var waterGradientBottom: Color {
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

                // Water with wave animation (two layers for depth)
                WaterWaveShape(progress: progress, waveOffset: waveOffset + 0.3, waveHeight: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                waterGradientTop.opacity(0.5),
                                waterGradientBottom.opacity(0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .mask(BucketShape().scale(0.86))

                WaterWaveShape(progress: progress, waveOffset: waveOffset, waveHeight: 6)
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

                // Metal bands
                BucketBand(verticalFraction: 0.30)
                    .stroke(skin.bandColor, lineWidth: 2.5)
                BucketBand(verticalFraction: 0.70)
                    .stroke(skin.bandColor, lineWidth: 2.5)

                // Bucket outline
                BucketShape()
                    .stroke(skin.bucketStroke, lineWidth: 5)

                // Rim (thick top edge)
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

// MARK: - Bucket Shape (rounded barrel)

private struct BucketShape: Shape {
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

        // Barrel bulge control: sides bow outward slightly
        let bulgeFactor = rect.width * 0.025
        let midY = (topY + bottomY) / 2

        path.move(to: topLeft)
        // Top edge
        path.addLine(to: topRight)
        // Right side with slight barrel curve
        path.addCurve(
            to: CGPoint(x: bottomRight.x - cornerRadius, y: bottomY - cornerRadius),
            control1: CGPoint(x: topRight.x + bulgeFactor, y: topY + (bottomY - topY) * 0.33),
            control2: CGPoint(x: bottomRight.x + bulgeFactor * 0.5, y: midY + (bottomY - topY) * 0.2)
        )
        // Bottom-right corner
        path.addQuadCurve(
            to: CGPoint(x: bottomRight.x - cornerRadius * 1.5, y: bottomY),
            control: bottomRight
        )
        // Bottom edge with subtle round
        path.addQuadCurve(
            to: CGPoint(x: bottomLeft.x + cornerRadius * 1.5, y: bottomY),
            control: CGPoint(x: rect.midX, y: bottomY + rect.height * 0.025)
        )
        // Bottom-left corner
        path.addQuadCurve(
            to: CGPoint(x: bottomLeft.x + cornerRadius, y: bottomY - cornerRadius),
            control: bottomLeft
        )
        // Left side with barrel curve
        path.addCurve(
            to: topLeft,
            control1: CGPoint(x: bottomLeft.x - bulgeFactor * 0.5, y: midY + (bottomY - topY) * 0.2),
            control2: CGPoint(x: topLeft.x - bulgeFactor, y: topY + (bottomY - topY) * 0.33)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Bucket Rim (thick top edge)

private struct BucketRim: Shape {
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

private struct BucketBand: Shape {
    let verticalFraction: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topY = rect.minY + rect.height * 0.06
        let bottomY = rect.maxY
        let y = topY + (bottomY - topY) * verticalFraction

        let topInset = rect.width * 0.14
        let bottomInset = rect.width * 0.08
        let xInset = topInset + (bottomInset - topInset) * verticalFraction
        // Inset bands slightly so they don't stick out past the bucket outline
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

private struct BucketHandleShape: Shape {
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

// MARK: - Water Wave Shape

private struct WaterWaveShape: Shape {
    var progress: Double
    var waveOffset: Double
    var waveHeight: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(progress, waveOffset) }
        set {
            progress = newValue.first
            waveOffset = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let clampedProgress = min(max(progress, 0), 1.0)
        let waterTop = rect.maxY - (rect.height * 0.80 * clampedProgress)
        let effectiveWaveHeight = clampedProgress < 0.05 ? 0 : waveHeight

        var path = Path()
        path.move(to: CGPoint(x: 0, y: waterTop))

        let wavelength = rect.width / 1.5
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin((relativeX + waveOffset) * 2 * .pi)
            let y = waterTop + sine * effectiveWaveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
