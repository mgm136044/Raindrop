import SwiftUI

struct OnboardingBucketScene: View {
    let onNext: () -> Void

    @State private var phase: Int = 0
    @State private var bucketProgress: Double = 0
    @State private var dropY: Double = -0.3
    @State private var showText = false

    var body: some View {
        ZStack {
            // Bucket
            BucketView(
                progress: bucketProgress,
                skin: .wood,
                useCustomWaterColor: false,
                intensity: 0.3
            )
            .frame(width: 160, height: 150)
            .opacity(phase >= 1 ? 1 : 0)
            .animation(.easeIn(duration: 0.5), value: phase)

            // Single raindrop
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

            // Text
            VStack {
                Spacer()

                if showText {
                    Text("이것이 당신의 하루입니다")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
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
        .onAppear {
            startSequence()
        }
    }

    private func startSequence() {
        // Phase 1: Bucket appears
        Task {
            try? await Task.sleep(for: .seconds(0.3))
            phase = 1

            // Phase 2: Raindrop falls
            try? await Task.sleep(for: .seconds(0.8))
            phase = 2
            withAnimation(.easeIn(duration: 0.8)) {
                dropY = 0.3
            }

            // Phase 3: Water rises
            try? await Task.sleep(for: .seconds(1.0))
            phase = 3
            withAnimation(.easeOut(duration: 1.0)) {
                bucketProgress = 0.35
            }

            // Phase 4: Text appears
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
            }
        }
    }
}
