import SwiftUI

struct OnboardingFillScene: View {
    let onNext: () -> Void

    @State private var isRunning = false
    @State private var progress: Double = 0
    @State private var showCoin = false
    @State private var showText = false

    var body: some View {
        ZStack {
            // Rain + Cloud + Bucket
            ZStack {
                if isRunning {
                    CloudView(isVisible: true, intensity: 0.5)
                        .frame(width: 140, height: 40)
                        .offset(y: -80)

                    RainParticleView(
                        isAnimating: true,
                        dropGradientTop: AppColors.dropGradientTopColor,
                        dropGradientBottom: AppColors.dropGradientBottomColor,
                        intensity: 0.6
                    )
                    .frame(width: 140, height: 200)
                    .offset(y: -20)
                }

                BucketView(
                    progress: progress,
                    skin: .wood,
                    useCustomWaterColor: false,
                    intensity: 0.5
                )
                .frame(width: 160, height: 150)
            }

            // Coin animation
            if showCoin {
                Text("🪣 +1")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.green)
                    .offset(y: -100)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Bottom UI
            VStack {
                Spacer()

                if !isRunning && !showText {
                    Button("집중 시작") {
                        startFilling()
                    }
                    .buttonStyle(PrimaryButtonStyle(color: AppColors.startButton))
                }

                if showText {
                    Text("집중이 쌓이면 양동이가 채워집니다")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.titleText)
                        .transition(.opacity)

                    Spacer().frame(height: 20)

                    Button("다음") {
                        onNext()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.accentBlue)
                }
            }
            .padding(.bottom, 24)
        }
    }

    private func startFilling() {
        isRunning = true

        withAnimation(.easeInOut(duration: 3.0)) {
            progress = 1.0
        }

        Task {
            try? await Task.sleep(for: .seconds(3.2))
            isRunning = false

            withAnimation(.spring(response: 0.5)) {
                showCoin = true
            }

            try? await Task.sleep(for: .seconds(1.0))
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
            }
        }
    }
}
