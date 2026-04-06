import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0

    private let pages: [(emoji: String, title: String, subtitle: String, description: String)] = [
        ("🪣", "RainDrop", "빗물을 모아 양동이를 채우세요", "집중할수록 양동이가 차오릅니다"),
        ("⏱", "집중 타이머", "목표 시간만큼 집중하면 양동이 코인 획득", "무한 모드로 끝없이 집중할 수도 있어요"),
        ("✨", "나만의 양동이", "6종 스킨으로 양동이를 꾸미세요", "스티커, 백색소음도 함께"),
        ("🚀", "준비 완료!", "지금 바로 집중을 시작해보세요", "매일 조금씩, 양동이를 채워나가요"),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.backgroundGradientTop, AppColors.backgroundGradientBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                pageContent

                Spacer()

                pageIndicator
                    .padding(.bottom, 20)

                navigationButtons
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 40)
        }
        .frame(width: 480, height: 400)
    }

    private var pageContent: some View {
        let page = pages[currentPage]
        return VStack(spacing: 16) {
            Text(page.emoji)
                .font(.system(size: 64))

            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppColors.primaryText)

            Text(page.subtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.subtitleText)
                .multilineTextAlignment(.center)

            Text(page.description)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .id(currentPage)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? AppColors.accentBlue : AppColors.subtitleText.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentPage > 0 {
                Button("이전") {
                    withAnimation { currentPage -= 1 }
                }
                .buttonStyle(.bordered)
                .transition(.opacity)
            }

            Spacer()

            if currentPage < pages.count - 1 {
                Button("다음") {
                    withAnimation { currentPage += 1 }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.accentBlue)
            } else {
                Button("시작하기") {
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.startButton)
            }
        }
    }
}
