import SwiftUI

struct TimerScreen: View {
    @ObservedObject var viewModel: TimerViewModel
    @ObservedObject var historyViewModel: HistoryViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var shopViewModel: ShopViewModel
    var authViewModel: AuthViewModel?
    var socialViewModel: SocialViewModel?
    var friendsViewModel: FriendsViewModel?
    @State private var isShowingHistory = false
    @State private var isShowingSettings = false
    @State private var isShowingShop = false
    @State private var isShowingSocial = false
    @State private var isDecorating = false
    @State private var motivationIndex = 0
    @State private var displayProgress: Double = 0

    private static let runningMessages = [
        "물방울이 떨어지는 중",
        "좋아요, 집중하고 있어요!",
        "지금 이 순간에 몰입하세요",
        "양동이가 차오르고 있어요",
        "한 방울 한 방울 쌓이는 중",
        "멋져요, 계속 이대로!",
        "집중의 흐름을 유지하세요",
        "당신의 노력이 물이 됩니다",
    ]

    private static let idleMessages = [
        "숨 고르고 다시 시작",
        "준비되면 집중을 시작하세요",
        "오늘도 양동이를 채워볼까요?",
        "한 방울의 시작이 큰 변화를 만들어요",
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.backgroundGradientTop,
                    AppColors.backgroundGradientBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                header

                HStack(spacing: 24) {
                    leftPanel
                    rightPanel
                }

                if let error = viewModel.latestError {
                    Text(error)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.red)
                }

                if let session = viewModel.lastCompletedSession {
                    completionBanner(session)
                }
            }
            .padding(32)
        }
        .sheet(isPresented: $isShowingHistory) {
            HistoryScreen(viewModel: historyViewModel)
                .onAppear {
                    historyViewModel.load()
                }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsScreen(viewModel: settingsViewModel)
        }
        .sheet(isPresented: $isShowingShop) {
            ShopScreen(viewModel: shopViewModel)
        }
        .sheet(isPresented: $isShowingSocial) {
            if let authVM = authViewModel,
               let socialVM = socialViewModel,
               let friendsVM = friendsViewModel {
                SocialScreen(
                    authViewModel: authVM,
                    socialViewModel: socialVM,
                    friendsViewModel: friendsVM
                )
            }
        }
    }

    private var currentMotivationMessage: String {
        if viewModel.isRunning {
            return Self.runningMessages[motivationIndex % Self.runningMessages.count]
        } else {
            return Self.idleMessages[motivationIndex % Self.idleMessages.count]
        }
    }

    private func pickRandomMessage() {
        let count = viewModel.isRunning
            ? Self.runningMessages.count
            : Self.idleMessages.count
        var next = Int.random(in: 0..<count)
        // 같은 메시지 연속 방지
        if next == motivationIndex % count, count > 1 {
            next = (next + 1) % count
        }
        motivationIndex = next
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("RainDrop")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.titleText)

                Text("집중이 쌓일수록 물방울이 양동이를 채웁니다.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 10) {
                // Balance display
                HStack(spacing: 4) {
                    Text("🪣")
                        .font(.system(size: 14))
                    Text("\(shopViewModel.balance)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.accentBlue)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppColors.panelBackground)
                .clipShape(Capsule())

                if AppConstants.socialEnabled {
                    Button {
                        isShowingSocial = true
                    } label: {
                        Image(systemName: "person.2")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(.bordered)
                }

                Button {
                    isShowingShop = true
                } label: {
                    Image(systemName: "bag")
                        .font(.system(size: 16, weight: .medium))
                }
                .buttonStyle(.bordered)

                Button {
                    isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .medium))
                }
                .buttonStyle(.bordered)

                Button("히스토리 보기") {
                    historyViewModel.load()
                    isShowingHistory = true
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.buttonTint)
            }
        }
    }

    private var leftPanel: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 12) {
                Text("현재 세션")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text(viewModel.timerText)
                    .font(.system(size: 58, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppColors.primaryText)

                Text(viewModel.goalText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                if let cycleText = viewModel.cycleText {
                    Text(cycleText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.accentBlue)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Label("오늘 누적 \(viewModel.todayTotalText)", systemImage: "clock.arrow.circlepath")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.subtitleText)

                ProgressView(value: viewModel.currentProgress)
                    .tint(AppColors.accentBlue)
            }

            TimerControlsView(
                canStart: viewModel.canStart,
                canPause: viewModel.canPause,
                canResume: viewModel.canResume,
                canStop: viewModel.canStop,
                onStart: {
                    viewModel.resetCompletionStateIfNeeded()
                    viewModel.start()
                },
                onPause: viewModel.pause,
                onResume: viewModel.resume,
                onStop: viewModel.stop
            )

            Spacer()
        }
        .padding(28)
        .frame(width: 440, alignment: .topLeading)
        .frame(maxHeight: .infinity)
        .background(AppColors.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: AppColors.panelShadow, radius: 18, y: 10)
    }

    private var rightPanel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.rightPanelGradientTop,
                            AppColors.rightPanelGradientBottom
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 14) {
                HStack {
                    Text(currentMotivationMessage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.rightPanelText)
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.4), value: motivationIndex)
                        .onReceive(Timer.publish(every: 8, on: .main, in: .common).autoconnect()) { _ in
                            pickRandomMessage()
                        }
                        .onChange(of: viewModel.isRunning) { _ in
                            pickRandomMessage()
                        }

                    Spacer()

                    if !shopViewModel.shopState.purchasedItemIDs.isEmpty {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isDecorating.toggle()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: isDecorating ? "checkmark" : "paintbrush")
                                    .font(.system(size: 12, weight: .medium))
                                Text(isDecorating ? "완료" : "꾸미기")
                                    .font(.system(size: 12, weight: .medium))
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(isDecorating ? .green : AppColors.accentBlue)
                    }
                }

                ZStack {
                    WaterDropView(isAnimating: viewModel.isRunning)
                        .frame(width: 300, height: 220)

                    BucketWithStickersView(
                        progress: displayProgress,
                        skin: settingsViewModel.settings.selectedSkin,
                        useCustomWaterColor: settingsViewModel.settings.useCustomWaterColor,
                        placements: shopViewModel.shopState.placements,
                        isDecorating: isDecorating,
                        onAddPlacement: { placement in
                            shopViewModel.addPlacement(placement)
                        },
                        onRemovePlacement: { id in
                            shopViewModel.removePlacement(id: id)
                        },
                        purchasedItems: shopViewModel.shopState.purchasedItemIDs
                    )
                    .frame(width: 300, height: 280)
                    .padding(.top, 48)
                    .onChange(of: viewModel.currentProgress) { newValue in
                        if !viewModel.isDraining && !viewModel.isCycleDraining {
                            displayProgress = newValue
                        }
                    }
                    .onChange(of: viewModel.isDraining) { draining in
                        if draining {
                            withAnimation(.easeIn(duration: 1.2)) {
                                displayProgress = 0
                            }
                            Task {
                                try? await Task.sleep(for: .seconds(1.3))
                                viewModel.finishDraining()
                            }
                        }
                    }
                    .onChange(of: viewModel.isCycleDraining) { draining in
                        if draining {
                            displayProgress = 1.0
                            withAnimation(.easeIn(duration: 1.2)) {
                                displayProgress = 0
                            }
                            Task {
                                try? await Task.sleep(for: .seconds(1.3))
                                viewModel.finishCycleDraining()
                            }
                        }
                    }
                }

                if let cycleText = viewModel.cycleText {
                    Text("\(Int(displayProgress * 100))% 채움 · \(cycleText)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppColors.progressText)
                } else {
                    Text("\(Int(displayProgress * 100))% 채움")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppColors.progressText)
                }

                if isDecorating {
                    stickerPalette
                }
            }
            .padding(24)
        }
        .frame(maxHeight: .infinity)
        .shadow(color: AppColors.rightPanelShadow, radius: 18, y: 10)
    }

    private var stickerPalette: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("스티커를 양동이 위로 드래그하세요")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ShopCatalog.allItems.filter { shopViewModel.isPurchased($0) }) { item in
                        Text(item.emoji)
                            .font(.system(size: 28))
                            .padding(6)
                            .background(AppColors.panelBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .draggable(item.id)
                    }
                }
            }
        }
    }

    private func completionBanner(_ session: FocusSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("세션 저장 완료")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.bannerTitle)

                    if !viewModel.isInfinityMode && session.durationSeconds >= viewModel.sessionGoalSeconds {
                        Text("🪣 +1")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.green)
                    }
                }

                Text("이번 집중 시간 \(TimeFormatter.clockString(from: session.durationSeconds))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("닫기") {
                viewModel.resetCompletionStateIfNeeded()
            }
            .buttonStyle(.bordered)
        }
        .padding(18)
        .background(AppColors.bannerBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
