import SwiftUI

struct CloudView: View {
    let isVisible: Bool
    var intensity: Double = 0.5

    @State private var cloudOffset: Double = 0
    @State private var cloudOpacity: Double = 0

    private var baseOpacity: Double {
        0.3 + min(max(intensity, 0), 1) * 0.5
    }

    var body: some View {
        ZStack {
            // Main cloud
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColors.cloudColor.opacity(0.40),
                            AppColors.cloudColor.opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 200, height: 50)
                .offset(x: cloudOffset)

            // Left cloud
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColors.cloudColor.opacity(0.30),
                            AppColors.cloudColor.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 50
                    )
                )
                .frame(width: 120, height: 35)
                .offset(x: -60 + cloudOffset * 0.7, y: 5)

            // Right cloud
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColors.cloudColor.opacity(0.25),
                            AppColors.cloudColor.opacity(0.06),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 45
                    )
                )
                .frame(width: 100, height: 30)
                .offset(x: 50 + cloudOffset * 0.5, y: 3)

            // Extra clouds at high intensity
            if intensity > 0.5 {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppColors.cloudColor.opacity(0.20),
                                AppColors.cloudColor.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 40
                        )
                    )
                    .frame(width: 90, height: 28)
                    .offset(x: -100 + cloudOffset * 0.4, y: -8)
                    .opacity(min((intensity - 0.5) * 2, 1))

                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppColors.cloudColor.opacity(0.18),
                                AppColors.cloudColor.opacity(0.04),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 35
                        )
                    )
                    .frame(width: 80, height: 25)
                    .offset(x: 100 + cloudOffset * 0.3, y: -5)
                    .opacity(min((intensity - 0.5) * 2, 1))
            }
        }
        .opacity(cloudOpacity * baseOpacity)
        .onChange(of: isVisible) { _,visible in
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
