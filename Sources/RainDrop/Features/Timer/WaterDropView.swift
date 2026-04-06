import SwiftUI

struct WaterDropView: View {
    let isAnimating: Bool

    var body: some View {
        ZStack {
            droplet(delay: 0.0, xOffset: -36, scale: 0.8)
            droplet(delay: 0.5, xOffset: 0, scale: 1.0)
            droplet(delay: 1.0, xOffset: 36, scale: 0.75)
        }
    }

    private func droplet(delay: Double, xOffset: CGFloat, scale: CGFloat) -> some View {
        FallingDrop(delay: delay, isAnimating: isAnimating)
            .scaleEffect(scale)
            .offset(x: xOffset)
    }
}

private struct FallingDrop: View {
    let delay: Double
    let isAnimating: Bool
    @State private var isFalling = false

    var body: some View {
        DropShape()
            .fill(
                LinearGradient(
                    colors: [
                        AppColors.dropGradientTop,
                        AppColors.dropGradientBottom
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 30, height: 44)
            .opacity(isAnimating ? 0.96 : 0)
            .offset(y: isAnimating && isFalling ? 134 : -48)
            .animation(
                isAnimating
                    ? .easeIn(duration: 1.15).repeatForever(autoreverses: false).delay(delay)
                    : .default,
                value: isFalling
            )
            .onAppear {
                if isAnimating {
                    isFalling = true
                }
            }
            .onChange(of: isAnimating) { newValue in
                if newValue {
                    isFalling = false
                    DispatchQueue.main.async {
                        isFalling = true
                    }
                } else {
                    isFalling = false
                }
            }
    }
}

private struct DropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.16)
        )
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.16)
        )
        return path
    }
}
