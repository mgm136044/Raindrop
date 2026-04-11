import SwiftUI

struct FacetOverlay: View {
    let rect: CGRect

    @State private var shimmerPhase: Double = 0

    var body: some View {
        Canvas { context, size in
            let facetCount = 8
            let sideInset = rect.width * 0.12
            let usableWidth = rect.width - sideInset * 2
            let spacing = usableWidth / Double(facetCount)
            let topY = rect.height * 0.08
            let bottomY = rect.height * 0.96

            for i in 1..<facetCount {
                let x = sideInset + spacing * Double(i)
                let facetAngle = Double(i) / Double(facetCount)
                // shimmerPhase cycles 0→1, produce a travelling highlight wave
                let phaseDiff = abs(shimmerPhase.truncatingRemainder(dividingBy: 1.0) - facetAngle)
                let wrapped = min(phaseDiff, 1.0 - phaseDiff)
                let shimmerIntensity = max(0, 1.0 - wrapped / 0.18) * 0.18

                var line = Path()
                line.move(to: CGPoint(x: x, y: topY))
                line.addLine(to: CGPoint(x: x, y: bottomY))
                context.stroke(line, with: .color(Color.white.opacity(shimmerIntensity)), lineWidth: 1.0)
            }
        }
        .frame(width: rect.width, height: rect.height)
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.0
            }
        }
    }
}
