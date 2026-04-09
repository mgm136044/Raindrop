import SwiftUI

struct SocialScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var socialViewModel: SocialViewModel
    @ObservedObject var friendsViewModel: FriendsViewModel
    @State private var isShowingFriendSearch = false
    @State private var isShowingFriendRequests = false
    @State private var rankingTab: RankingTab = .daily
    @Environment(\.dismiss) private var dismiss

    enum RankingTab: String, CaseIterable {
        case daily = "오늘"
        case weekly = "이번 주"
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView

            switch authViewModel.authState {
            case .signedOut:
                SignInScreen(authViewModel: authViewModel)
            case .needsProfile:
                ProfileSetupScreen(authViewModel: authViewModel)
            case .signedIn:
                signedInContent
            }
        }
        .frame(width: 500, height: 600)
        .background(
            LinearGradient(
                colors: [AppColors.backgroundGradientTop, AppColors.backgroundGradientBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlayModal(isPresented: $isShowingFriendSearch) {
            FriendSearchScreen(viewModel: friendsViewModel)
        }
        .overlayModal(isPresented: $isShowingFriendRequests) {
            FriendRequestsScreen(viewModel: friendsViewModel)
        }
        .onAppear {
            if authViewModel.isSignedIn {
                socialViewModel.loadAndListen()
                friendsViewModel.loadFriends()
                friendsViewModel.listenToRequests()
            }
        }
        .onDisappear {
            socialViewModel.stopListening()
            friendsViewModel.stopListening()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("소셜")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppColors.titleText)

            Spacer()

            if authViewModel.isSignedIn {
                HStack(spacing: 8) {
                    if let user = authViewModel.currentUser {
                        Text("코드: \(user.inviteCode)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.panelBackground)
                            .clipShape(Capsule())
                    }

                    badgedButton(
                        icon: "envelope",
                        count: friendsViewModel.incomingRequests.count
                    ) {
                        isShowingFriendRequests = true
                    }

                    Button {
                        isShowingFriendSearch = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .buttonStyle(.glass)

                    Button {
                        authViewModel.signOut()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .buttonStyle(.glass)
                }
            }

            Button("닫기") { dismiss() }
                .buttonStyle(.glass)
        }
        .padding(16)
    }

    // MARK: - Signed In Content

    private var signedInContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Focusing friends section
                focusingFriendsSection

                // Ranking section
                rankingSection
            }
            .padding(16)
        }
    }

    // MARK: - Focusing Friends

    private var focusingFriendsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(AppColors.accent)
                Text("지금 집중 중인 친구")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.titleText)
            }

            if socialViewModel.focusingFriends.isEmpty {
                Text("현재 집중 중인 친구가 없습니다")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 4) {
                    ForEach(socialViewModel.focusingFriends) { friend in
                        FocusingFriendRow(profile: friend)
                    }
                }
            }
        }
        .padding(16)
        .background(AppColors.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Ranking

    private var rankingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(AppColors.accent)
                Text("랭킹")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.titleText)

                Spacer()

                Picker("", selection: $rankingTab) {
                    ForEach(RankingTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }

            let ranking = rankingTab == .daily
                ? socialViewModel.dailyRanking
                : socialViewModel.weeklyRanking

            if ranking.isEmpty {
                Text("친구를 추가하면 랭킹을 볼 수 있습니다")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 2) {
                    ForEach(Array(ranking.enumerated()), id: \.element.id) { index, profile in
                        RankingRowView(
                            rank: index + 1,
                            profile: profile,
                            isMe: profile.id == socialViewModel.myUID,
                            showDaily: rankingTab == .daily
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(AppColors.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Helper

    private func badgedButton(icon: String, count: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))

                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(Circle().fill(.red))
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.glass)
    }
}
