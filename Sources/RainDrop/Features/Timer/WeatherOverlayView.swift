import SwiftUI

struct WeatherOverlayView: View {
    let condition: WeatherCondition

    var body: some View {
        ZStack {
            switch condition {
            case .cloudy:
                ambientClouds(opacity: 0.15, count: 3)

            case .drizzle:
                ambientClouds(opacity: 0.20, count: 4)
                ambientRain(count: 12, opacity: 0.15)

            case .rain:
                ambientClouds(opacity: 0.30, count: 5)
                ambientRain(count: 25, opacity: 0.20)

            case .rainbow:
                rainbowArc
                ambientClouds(opacity: 0.10, count: 2)
            }
        }
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 1.5), value: condition)
    }

    private func ambientClouds(opacity: Double, count: Int) -> some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let w = 60.0 + abs(sin(Double(i) * 3.1)) * 60.0
                let h = 15.0 + abs(cos(Double(i) * 2.3)) * 15.0
                Ellipse()
                    .fill(AppColors.cloudColor.opacity(opacity))
                    .frame(width: w, height: h)
                    .offset(
                        x: CGFloat(i * 80 - count * 40),
                        y: CGFloat(i * 12 - 20)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 20)
    }

    private func ambientRain(count: Int, opacity: Double) -> some View {
        Canvas { context, size in
            for i in 0..<count {
                let seed = Double(i)
                let x = (seed / Double(count)) * size.width + sin(seed * 2.7) * 20
                let y = abs(sin(seed * 1.9)) * size.height * 0.6
                let length = 4.0 + abs(cos(seed * 3.2)) * 6.0

                var path = Path()
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x - 1, y: y + length))

                context.stroke(
                    path,
                    with: .color(.white.opacity(opacity)),
                    lineWidth: 1
                )
            }
        }
    }

    private var rainbowArc: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height * 0.3)
            let radius = size.width * 0.35

            let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
            for (i, color) in colors.enumerated() {
                let r = radius - Double(i) * 4
                var path = Path()
                path.addArc(
                    center: center,
                    radius: r,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false
                )
                context.stroke(path, with: .color(color.opacity(0.15)), lineWidth: 3)
            }
        }
    }
}
