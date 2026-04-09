import SwiftUI

struct OnboardingGrowthScene: View {
    let onComplete: () -> Void

    @State private var currentStage: EnvironmentStage = .barren
    @State private var showText = false
    @State private var animationTask: Task<Void, Never>?
    private let stages: [EnvironmentStage] = [.barren, .grass, .flowers, .trees, .forest, .lake]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Stage indicator
            HStack(spacing: 8) {
                ForEach(stages, id: \.rawValue) { stage in
                    Text(stage.emoji)
                        .font(.system(size: 20))
                        .opacity(stage.rawValue <= currentStage.rawValue ? 1.0 : 0.3)
                        .scaleEffect(stage == currentStage ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: currentStage)
                }
            }

            // Environment evolution
            EnvironmentView(stage: currentStage)
                .frame(width: 300, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()

            // Bottom text + button
            if showText {
                VStack(spacing: 20) {
                    Text("매일의 집중이 당신만의 세계를 만듭니다")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.primaryText)
                        .transition(.opacity)

                    Button("시작하기") {
                        onComplete()
                    }
                    .buttonStyle(.glassProminent)
                    .tint(AppColors.accent)
                }
            }

            Spacer()
                .frame(height: 24)
        }
        .onAppear { animateStages() }
        .onDisappear { animationTask?.cancel() }
    }

    private func animateStages() {
        animationTask?.cancel()
        animationTask = Task {
            for (i, stage) in stages.enumerated() {
                try? await Task.sleep(for: .seconds(i == 0 ? 0.5 : 0.8))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentStage = stage
                }
            }

            try? await Task.sleep(for: .seconds(1.0))
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
            }
        }
    }
}
