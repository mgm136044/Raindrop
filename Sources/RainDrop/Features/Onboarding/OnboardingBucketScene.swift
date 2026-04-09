import SwiftUI

struct OnboardingBucketScene: View {
    let onNext: () -> Void

    @State private var phase: Int = 0
    @State private var bucketProgress: Double = 0
    @State private var dropY: Double = -0.3
    @State private var showText = false
    @State private var wobbleAngle: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Bucket + raindrop
            ZStack {
                BucketView(
                    progress: bucketProgress,
                    skin: .wood,
                    useCustomWaterColor: false,
                    intensity: 0.3,
                    tiltAngle: wobbleAngle
                )
                .frame(width: 160, height: 150)
                .rotationEffect(.degrees(wobbleAngle), anchor: .bottom)
                .animation(.interpolatingSpring(stiffness: 300, damping: 8), value: wobbleAngle)
                .opacity(phase >= 1 ? 1 : 0)
                .animation(.easeIn(duration: 0.5), value: phase)

                if phase == 2 {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.dropGradientTopColor, AppColors.dropGradientBottomColor],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 8, height: 12)
                        .offset(y: dropY * 200)
                }
            }
            .frame(height: 200)
            .contentShape(Rectangle())
            .onTapGesture {
                wobbleAngle = wobbleAngle <= 0 ? 6 : -6
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    wobbleAngle = 0
                }
            }

            Spacer()

            // Bottom text + button
            if showText {
                VStack(spacing: 20) {
                    Text("이것이 당신의 하루입니다")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.primaryText)
                        .transition(.opacity)

                    Button("다음") {
                        onNext()
                    }
                    .buttonStyle(.glassProminent)
                    .tint(AppColors.accent)
                }
            }

            Spacer()
                .frame(height: 24)
        }
        .onAppear {
            startSequence()
        }
    }

    private func startSequence() {
        Task {
            try? await Task.sleep(for: .seconds(0.3))
            phase = 1

            try? await Task.sleep(for: .seconds(0.8))
            phase = 2
            withAnimation(.easeIn(duration: 0.8)) {
                dropY = 0.3
            }

            try? await Task.sleep(for: .seconds(1.0))
            phase = 3
            withAnimation(.easeOut(duration: 1.0)) {
                bucketProgress = 0.35
            }

            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
            }
        }
    }
}
