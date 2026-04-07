import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var scene: OnboardingScene = .bucket

    private enum OnboardingScene {
        case bucket, fill, growth
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.backgroundGradientTop, AppColors.backgroundGradientBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Scene indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(sceneIndex >= index ? AppColors.accentBlue : AppColors.subtitleText.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)

                // Scene content
                switch scene {
                case .bucket:
                    OnboardingBucketScene {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            scene = .fill
                        }
                    }

                case .fill:
                    OnboardingFillScene {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            scene = .growth
                        }
                    }

                case .growth:
                    OnboardingGrowthScene {
                        onComplete()
                    }
                }
            }
        }
        .frame(width: 520, height: 450)
    }

    private var sceneIndex: Int {
        switch scene {
        case .bucket: return 0
        case .fill: return 1
        case .growth: return 2
        }
    }
}
