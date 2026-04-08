import SwiftUI

struct OnboardingFillScene: View {
    let onNext: () -> Void

    @State private var isRunning = false
    @State private var progress: Double = 0
    @State private var showCoin = false
    @State private var showText = false
    @State private var wobbleAngle: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Rain + Bucket
            ZStack {
                if isRunning {
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
                    intensity: 0.5,
                    tiltAngle: wobbleAngle
                )
                .frame(width: 160, height: 150)
                .rotationEffect(.degrees(wobbleAngle), anchor: .bottom)
                .animation(.interpolatingSpring(stiffness: 300, damping: 8), value: wobbleAngle)

                // Coin animation
                if showCoin {
                    Text("🪣 +1")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppColors.accent)
                        .offset(y: -100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(height: 220)
            .contentShape(Rectangle())
            .onTapGesture {
                wobbleAngle = 6
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    wobbleAngle = 0
                }
            }

            Spacer()

            // Bottom UI
            if !isRunning && !showText {
                Button("집중 시작") {
                    startFilling()
                }
                .buttonStyle(PrimaryButtonStyle(color: AppColors.accent))
            }

            if showText {
                VStack(spacing: 20) {
                    Text("집중이 쌓이면 양동이가 채워집니다")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
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
