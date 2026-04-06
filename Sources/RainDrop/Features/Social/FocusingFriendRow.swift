import SwiftUI

struct FocusingFriendRow: View {
    let profile: UserProfile
    @State private var elapsedSeconds: Int = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.green)
                .frame(width: 8, height: 8)
                .shadow(color: .green.opacity(0.6), radius: 4)

            Text(profile.nickname)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            Text(TimeFormatter.clockString(from: elapsedSeconds))
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(AppColors.progressText)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .onAppear { updateElapsed() }
        .onReceive(timer) { _ in updateElapsed() }
    }

    private func updateElapsed() {
        guard let start = profile.currentSessionStartTime else {
            elapsedSeconds = 0
            return
        }
        elapsedSeconds = max(0, Int(Date().timeIntervalSince(start)))
    }
}
