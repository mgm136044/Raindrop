import SwiftUI

struct CloudView: View {
    let isVisible: Bool

    @State private var cloudOffset: Double = 0
    @State private var cloudOpacity: Double = 0

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 200, height: 50)
                .offset(x: cloudOffset)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 50
                    )
                )
                .frame(width: 120, height: 35)
                .offset(x: -60 + cloudOffset * 0.7, y: 5)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.04),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 45
                    )
                )
                .frame(width: 100, height: 30)
                .offset(x: 50 + cloudOffset * 0.5, y: 3)
        }
        .opacity(cloudOpacity)
        .onChange(of: isVisible) { visible in
            if visible {
                withAnimation(.easeIn(duration: 1.5)) {
                    cloudOpacity = 1.0
                }
                withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                    cloudOffset = 10
                }
            } else {
                withAnimation(.easeOut(duration: 1.0)) {
                    cloudOpacity = 0
                    cloudOffset = 0
                }
            }
        }
        .onAppear {
            if isVisible {
                cloudOpacity = 1.0
                withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                    cloudOffset = 10
                }
            }
        }
    }
}
