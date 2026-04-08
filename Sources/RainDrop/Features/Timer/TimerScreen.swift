import SwiftUI

struct TimerScreen: View {
    @ObservedObject var viewModel: TimerViewModel
    @ObservedObject var historyViewModel: HistoryViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var shopViewModel: ShopViewModel
    var authViewModel: AuthViewModel?
    var socialViewModel: SocialViewModel?
    var friendsViewModel: FriendsViewModel?
    var whiteNoiseService: WhiteNoiseService?
    @State private var isShowingHistory = false
    @State private var isShowingSettings = false
    @State private var isShowingShop = false
    @State private var isShowingSocial = false
    @State private var isShowingWhiteNoise = false
    @State private var isShowingStickerEditor = false
    @State private var motivationIndex = 0

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
            // Layer 0: Dynamic sky background
            SkyBackgroundView(
                progress: viewModel.currentProgress,
                isRunning: viewModel.isRunning,
                isOverflowing: viewModel.isOverflowing
            )

            // Layer 1: Scene (cloud + rain + bucket) — 화면 중앙, 주인공
            TimerSceneView(
                viewModel: viewModel,
                skin: settingsViewModel.settings.selectedSkin,
                useCustomWaterColor: settingsViewModel.settings.useCustomWaterColor,
                dropGradientTop: effectiveDropGradientTop,
                dropGradientBottom: effectiveDropGradientBottom,
                placements: shopViewModel.shopState.placements,
                environmentStage: shopViewModel.currentEnvironmentStage,
                weatherCondition: shopViewModel.currentWeather,
                waterColorOverride: effectiveWaterColorOverride
            )

            // Layer 2: Header overlay — 상단
            VStack {
                headerOverlay
                Spacer()
            }

            // Layer 3: Motivation + progress text — 씬 위쪽
            VStack {
                Spacer()
                    .frame(height: 80)

                Text(currentMotivationMessage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.rightPanelText.opacity(0.8))
                    .id(motivationIndex)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: motivationIndex)
                    .onReceive(Timer.publish(every: 8, on: .main, in: .common).autoconnect()) { _ in
                        pickRandomMessage()
                    }
                    .onChange(of: viewModel.isRunning) { _ in
                        pickRandomMessage()
                    }

                Spacer()
            }

            // Layer 4: Bottom controls + info
            VStack {
                Spacer()

                // Progress & cycle info
                progressInfoPill

                Spacer()
                    .frame(height: 12)

                // Timer text — 보조 역할로 축소
                timerDisplay

                Spacer()
                    .frame(height: 16)

                // Controls — 하단 중앙
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
                    onStop: viewModel.stop,
                    isCompact: viewModel.isRunning
                )
                .opacity(viewModel.isRunning ? 0.7 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isRunning)

                Spacer()
                    .frame(height: 24)
            }

            // Layer 5: Error & completion banner
            VStack {
                Spacer()

                if let error = viewModel.latestError {
                    Text(error)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                }

                if let session = viewModel.lastCompletedSession {
                    completionBanner(session)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $isShowingHistory) {
            HistoryScreen(viewModel: historyViewModel, skin: settingsViewModel.settings.selectedSkin)
                .onAppear {
                    historyViewModel.load()
                }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsScreen(
                viewModel: settingsViewModel,
                totalBuckets: shopViewModel.shopState.totalBucketsEarned,
                shopViewModel: shopViewModel
            )
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
        .sheet(isPresented: $isShowingStickerEditor) {
            StickerEditorScreen(
                shopViewModel: shopViewModel,
                skin: settingsViewModel.settings.selectedSkin,
                useCustomWaterColor: settingsViewModel.settings.useCustomWaterColor
            )
        }
        .sheet(isPresented: $isShowingWhiteNoise) {
            if let service = whiteNoiseService {
                WhiteNoiseScreen(
                    viewModel: settingsViewModel,
                    whiteNoiseService: service
                )
            }
        }
    }

    // MARK: - Header Overlay

    private var headerOverlay: some View {
        HStack(alignment: .center) {
            HStack(spacing: 6) {
                Text("RainDrop")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.titleText)

                Text("v\(AppConstants.appVersion)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary.opacity(0.6))
                    .offset(y: 2)
            }

            Spacer()

            HStack(spacing: 8) {
                // Balance display
                HStack(spacing: 4) {
                    Text("🪣")
                        .font(.system(size: 12))
                    Text("\(shopViewModel.balance)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColors.accentBlue)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())

                if AppConstants.socialEnabled {
                    headerButton(icon: "person.2") { isShowingSocial = true }
                }

                headerButton(icon: "bag") { isShowingShop = true }
                headerButton(icon: "gearshape") { isShowingSettings = true }

                if whiteNoiseService != nil {
                    headerButton(icon: "cloud.rain") { isShowingWhiteNoise = true }
                }

                if !shopViewModel.shopState.purchasedItemIDs.isEmpty {
                    headerButton(icon: "paintbrush") {
                        isShowingStickerEditor = true
                    }
                }

                Button {
                    historyViewModel.load()
                    isShowingHistory = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12, weight: .medium))
                        Text("히스토리")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(AppColors.buttonTint)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Timer Display

    private var timerDisplay: some View {
        HStack(spacing: 12) {
            Text(viewModel.timerText)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AppColors.primaryText)

            if let cycleText = viewModel.cycleText {
                Text(cycleText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.accentBlue)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    // MARK: - Progress Info Pill

    private var progressInfoPill: some View {
        HStack(spacing: 16) {
            Text(viewModel.goalText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)

            Text("·")
                .foregroundStyle(.secondary)

            Label("오늘 \(viewModel.todayTotalText)", systemImage: "clock.arrow.circlepath")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.subtitleText)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    // MARK: - Sticker Palette

    // MARK: - Completion Banner

    private func completionBanner(_ session: FocusSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("세션 저장 완료")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.bannerTitle)

                    if viewModel.isInfinityMode && viewModel.lastCycleCount > 0 {
                        Text("🪣 +\(viewModel.lastCycleCount)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.green)
                    } else if !viewModel.isInfinityMode && session.durationSeconds >= viewModel.sessionGoalSeconds {
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
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Helpers

    private func headerButton(icon: String, tint: Color? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(tint ?? AppColors.primaryText)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
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
        if next == motivationIndex % count, count > 1 {
            next = (next + 1) % count
        }
        motivationIndex = next
    }

    private var effectiveWaterColorOverride: (top: Color, bottom: Color)? {
        guard settingsViewModel.settings.waterColorEvolution else { return nil }
        let colors = WaterColorProgression.colors(for: shopViewModel.shopState.totalFocusMinutes)
        return (colors.top, colors.bottom)
    }

    private var effectiveDropGradientTop: Color {
        let skin = settingsViewModel.settings.selectedSkin
        if settingsViewModel.settings.useCustomWaterColor && skin.hasCustomWaterColor {
            return skin.customDropGradientTop
        }
        return AppColors.dropGradientTopColor
    }

    private var effectiveDropGradientBottom: Color {
        let skin = settingsViewModel.settings.selectedSkin
        if settingsViewModel.settings.useCustomWaterColor && skin.hasCustomWaterColor {
            return skin.customDropGradientBottom
        }
        return AppColors.dropGradientBottomColor
    }
}
