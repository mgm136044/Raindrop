import SwiftUI

struct OnboardingGrowthScene: View {
    let onComplete: () -> Void

    @State private var currentStage: EnvironmentStage = .barren
    @State private var showText = false
    private let stages: [EnvironmentStage] = [.barren, .grass, .flowers, .trees, .forest, .lake]

    var body: some View {
        ZStack {
            // Environment evolution
            EnvironmentView(stage: currentStage)
                .frame(width: 300, height: 200)

            // Stage indicator
            VStack {
                HStack(spacing: 8) {
                    ForEach(stages, id: \.rawValue) { stage in
                        Text(stage.emoji)
                            .font(.system(size: 20))
                            .opacity(stage.rawValue <= currentStage.rawValue ? 1.0 : 0.3)
                            .scaleEffect(stage == currentStage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentStage)
                    }
                }
                .padding(.top, 20)

                Spacer()
            }

            // Bottom
            VStack {
                Spacer()

                if showText {
                    Text("매일의 집중이 당신만의 세계를 만듭니다")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.titleText)
                        .transition(.opacity)

                    Spacer().frame(height: 20)

                    Button("시작하기") {
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.accentBlue)
                }
            }
            .padding(.bottom, 24)
        }
        .onAppear {
            animateStages()
        }
    }

    private func animateStages() {
        Task {
            for (i, stage) in stages.enumerated() {
                try? await Task.sleep(for: .seconds(i == 0 ? 0.5 : 0.8))
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentStage = stage
                }
            }

            try? await Task.sleep(for: .seconds(1.0))
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
            }
        }
    }
}
