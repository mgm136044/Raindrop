import SwiftUI

struct RankingRowView: View {
    let rank: Int
    let profile: UserProfile
    let isMe: Bool
    let showDaily: Bool

    private var seconds: Int {
        showDaily ? profile.todayTotalSeconds : profile.weekTotalSeconds
    }

    private var medal: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            if !medal.isEmpty {
                Text(medal)
                    .font(.system(size: 18))
                    .frame(width: 30)
            } else {
                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 30)
            }

            Text(profile.nickname)
                .font(.system(size: 15, weight: isMe ? .bold : .medium))
                .foregroundStyle(isMe ? AppColors.accentBlue : AppColors.primaryText)

            if isMe {
                Text("나")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColors.accentBlue.opacity(0.2))
                    .clipShape(Capsule())
                    .foregroundStyle(AppColors.accentBlue)
            }

            Spacer()

            Text(TimeFormatter.compactDuration(from: seconds))
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(AppColors.progressText)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isMe ? AppColors.accentBlue.opacity(0.08) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
