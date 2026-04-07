import SwiftUI

struct EnvironmentView: View {
    let stage: EnvironmentStage

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .bottom) {
                // Ground
                groundLayer(width: width, height: height)

                // Stage-specific elements
                if stage.rawValue >= EnvironmentStage.grass.rawValue {
                    grassLayer(width: width, height: height)
                }

                if stage.rawValue >= EnvironmentStage.flowers.rawValue {
                    flowerLayer(width: width, height: height)
                }

                if stage.rawValue >= EnvironmentStage.trees.rawValue {
                    treeLayer(width: width, height: height)
                }

                if stage.rawValue >= EnvironmentStage.forest.rawValue {
                    forestLayer(width: width, height: height)
                }

                if stage == .lake {
                    lakeLayer(width: width, height: height)
                }
            }
        }
        .animation(.easeInOut(duration: 1.0), value: stage)
    }

    private func groundLayer(width: Double, height: Double) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [Color.brown.opacity(0.15), Color.brown.opacity(0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width, height: height * 0.12)
            .offset(y: height * 0.44)
    }

    private func grassLayer(width: Double, height: Double) -> some View {
        Canvas { context, size in
            for i in 0..<20 {
                let x = Double(i) / 20.0 * size.width + 10
                let baseY = size.height * 0.88
                let grassHeight = 6.0 + abs(sin(Double(i) * 1.7)) * 8.0

                var path = Path()
                path.move(to: CGPoint(x: x, y: baseY))
                path.addLine(to: CGPoint(x: x - 1.5, y: baseY - grassHeight))
                path.addLine(to: CGPoint(x: x + 1.5, y: baseY - grassHeight))
                path.closeSubpath()

                context.fill(path, with: .color(.green.opacity(0.4)))
            }
        }
        .frame(width: width, height: height)
        .transition(.opacity)
    }

    private func flowerLayer(width: Double, height: Double) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { i in
                Text(["🌸", "🌼", "🌺", "💐", "🌷", "🌻"][i % 6])
                    .font(.system(size: 12))
                    .offset(
                        x: CGFloat(sin(Double(i) * 2.5) * 10),
                        y: CGFloat(cos(Double(i) * 1.8) * 5)
                    )
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: width)
        .offset(y: height * 0.38)
        .transition(.opacity)
    }

    private func treeLayer(width: Double, height: Double) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { i in
                Text("🌳")
                    .font(.system(size: 22))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: width * 0.8)
        .offset(y: height * 0.30)
        .transition(.opacity)
    }

    private func forestLayer(width: Double, height: Double) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { i in
                Text(["🌲", "🌳", "🌲", "🌳", "🌲"][i])
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: width)
        .offset(y: height * 0.34)
        .transition(.opacity)
    }

    private func lakeLayer(width: Double, height: Double) -> some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.15),
                        Color.cyan.opacity(0.10)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width * 0.6, height: height * 0.08)
            .offset(y: height * 0.42)
            .transition(.opacity)
    }
}
