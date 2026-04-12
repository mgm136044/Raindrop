import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel
    var totalBuckets: Int = 0
    var shopViewModel: ShopViewModel?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: SettingsTab = .focus
    @State private var showPatchNotes = false
    @State private var devCode = ""

    enum SettingsTab: String, CaseIterable {
        case focus = "집중"
        case skin = "스킨"
        case garden = "가든"
        case misc = "기타"
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header

                // Tab content — 각 탭이 한 화면에 맞으므로 스크롤 불필요
                Group {
                    switch selectedTab {
                    case .focus:
                        focusTab
                    case .skin:
                        skinTab
                    case .garden:
                        gardenTab
                    case .misc:
                        miscTab
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let error = viewModel.latestError {
                    Text(error)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.danger)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
            }
            .disabled(showPatchNotes)

            if showPatchNotes {
                overlayPatchNotes
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showPatchNotes)
        .frame(minWidth: 420, minHeight: 320)
    }

    // MARK: - Header with Tab Picker

    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                Text("설정")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)

                HStack {
                    Spacer()
                    Button("완료") { dismiss() }
                        .buttonStyle(.glass)
                }
            }

            Picker("", selection: $selectedTab) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Tab 1: 집중

    private var focusTab: some View {
        Form {
            Section("집중 목표") {
                Toggle("무한 모드 (∞)", isOn: $viewModel.settings.infinityModeEnabled)
                    .onChange(of: viewModel.settings.infinityModeEnabled) { _,_ in
                        viewModel.save()
                    }

                HStack {
                    Text("양동이 채움 목표 시간")
                    Spacer()
                    if viewModel.settings.infinityModeEnabled {
                        Text("∞")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .trailing)
                    } else {
                        TextField("", value: $viewModel.settings.sessionGoalMinutes, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                    }
                    Text("분")
                        .foregroundStyle(.secondary)
                }
                .onChange(of: viewModel.settings.sessionGoalMinutes) { _,newValue in
                    let clamped = max(1, min(120, newValue))
                    if clamped != newValue {
                        viewModel.settings.sessionGoalMinutes = clamped
                    }
                    viewModel.save()
                }

                if viewModel.settings.infinityModeEnabled {
                    Text("\(viewModel.settings.sessionGoalMinutes)분마다 양동이가 순환됩니다. 순환마다 양동이 코인 1개가 적립됩니다.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    Text("1 ~ 120분")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Section("집중 감시 알림") {
                Toggle("집중 확인 알림", isOn: $viewModel.settings.focusCheckEnabled)
                    .onChange(of: viewModel.settings.focusCheckEnabled) { _,_ in
                        viewModel.save()
                    }

                if viewModel.settings.focusCheckEnabled {
                    HStack {
                        Text("알림 간격")
                        Spacer()
                        TextField("", value: $viewModel.settings.focusCheckIntervalMinutes, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                        Text("분")
                            .foregroundStyle(.secondary)
                    }
                    .onChange(of: viewModel.settings.focusCheckIntervalMinutes) { _,newValue in
                        let clamped = max(1, min(60, newValue))
                        if clamped != newValue {
                            viewModel.settings.focusCheckIntervalMinutes = clamped
                        }
                        viewModel.save()
                    }
                    Text("1 ~ 60분")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Tab 2: 스킨

    private var skinTab: some View {
        Form {
            Section("환경 선택") {
                ForEach(BucketSkin.allCases, id: \.self) { skin in
                    let unlocked = viewModel.settings.developerMode || skin.isUnlocked(totalBuckets: totalBuckets)
                    let palette = skin.shapeProvider.colorPalette
                    Button {
                        if unlocked {
                            viewModel.settings.selectedSkin = skin
                            viewModel.save()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: viewModel.settings.selectedSkin == skin ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(viewModel.settings.selectedSkin == skin ? AppColors.accent : .secondary)

                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(skin.displayName)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(unlocked ? AppColors.primaryText : .secondary)

                                    if !unlocked {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Text(unlocked ? skin.materialDescription : "🪣 \(skin.requiredBuckets)번 채움 시 해금")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.tertiary)
                            }

                            Spacer()

                            Circle()
                                .fill(palette.fill)
                                .overlay(Circle().stroke(palette.stroke, lineWidth: 2))
                                .frame(width: 24, height: 24)
                                .opacity(unlocked ? 1.0 : 0.4)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(!unlocked)
                }
            }

            Section("물 색상") {
                if viewModel.settings.selectedSkin.hasCustomWaterColor {
                    Toggle("스킨 색 물 사용", isOn: $viewModel.settings.useCustomWaterColor)
                        .onChange(of: viewModel.settings.useCustomWaterColor) { _,_ in
                            viewModel.save()
                        }
                    Text("물과 물방울의 색을 스킨 색상에 맞춥니다.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    Text("🪣 금 양동이부터 물 색상을 선택할 수 있습니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Tab 4: 기타

    private var miscTab: some View {
        Form {
            Section("정보") {
                Button("패치노트") {
                    showPatchNotes = true
                }
            }

            Section("개발자") {
                if viewModel.settings.developerMode {
                    HStack {
                        Image(systemName: "hammer.fill")
                            .foregroundStyle(AppColors.accent)
                        Text("개발자 모드 활성화됨")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.accent)
                    }
                }
                HStack {
                    Text("개발자 코드")
                        .font(.system(size: 13))
                    Spacer()
                    SecureField("코드 입력", text: $devCode)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .onSubmit {
                            if devCode == "0530" {
                                viewModel.settings.developerMode.toggle()
                                shopViewModel?.isDeveloperMode = viewModel.settings.developerMode
                                viewModel.save()
                            }
                            devCode = ""
                        }
                }
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Tab 3: 가든

    private var gardenTab: some View {
        let snapshot = GrowthEngine.snapshot(
            totalMinutes: shopViewModel?.shopState.totalFocusMinutes ?? 0,
            skin: viewModel.settings.selectedSkin
        )
        let minutesToNext = GrowthCurve.cumulativeMinutes(for: snapshot.level + 1) - snapshot.totalMinutes
        let sessionsToNext = max(1, Int(ceil(Double(minutesToNext) / 25.0)))

        return Form {
            Section("현재 상태") {
                HStack(spacing: 16) {
                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 8)
                        Circle()
                            .trim(from: 0, to: snapshot.progressToNext)
                            .stroke(
                                AngularGradient(
                                    colors: [AppColors.accent, AppColors.accent.opacity(0.6)],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 1) {
                            Text("\(snapshot.level)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            Text("LEVEL")
                                .font(.system(size: 8, weight: .heavy))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 70, height: 70)

                    // Info text
                    VStack(alignment: .leading, spacing: 6) {
                        Text(snapshot.phase.displayName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if snapshot.level < GrowthCurve.maxLevel {
                            Text("다음 레벨까지 \(minutesToNext)분")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("약 \(sessionsToNext)회 세션")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        } else {
                            Text("최고 레벨 달성!")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.accent)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("성장 여정") {
                let currentPhaseRaw = snapshot.phase.rawValue
                let allPhases = GrowthSnapshot.GrowthPhase.allCases
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        ForEach(Array(allPhases.enumerated()), id: \.offset) { index, phase in
                            let phaseRaw = phase.rawValue
                            VStack(spacing: 4) {
                                Capsule()
                                    .fill(
                                        phaseRaw < currentPhaseRaw
                                            ? AnyShapeStyle(AppColors.accent)
                                            : phaseRaw == currentPhaseRaw
                                                ? AnyShapeStyle(AppColors.accent.opacity(0.6))
                                                : AnyShapeStyle(Color.gray.opacity(0.15))
                                    )
                                    .frame(height: 6)
                                Text(phase.displayName)
                                    .font(.system(size: 9))
                                    .foregroundStyle(phaseRaw <= currentPhaseRaw ? .primary : .tertiary)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("통계") {
                LabeledContent("총 집중 시간") {
                    Text(formatDuration(snapshot.totalMinutes))
                        .foregroundStyle(.secondary)
                }
                LabeledContent("바이옴") {
                    Text("\(snapshot.biome.emoji) \(snapshot.biome.displayName)")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("최고 레벨까지") {
                    if snapshot.level < GrowthCurve.maxLevel {
                        let remaining = GrowthCurve.totalMinutesToMax - snapshot.totalMinutes
                        Text("\(formatDuration(remaining)) 남음")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("달성 완료")
                            .foregroundStyle(AppColors.accent)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)시간 \(mins)분"
        }
        return "\(mins)분"
    }

    // MARK: - Overlay Patch Notes

    private var overlayPatchNotes: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { showPatchNotes = false }

            VStack(spacing: 0) {
                HStack {
                    Text("패치노트")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.primaryText)
                    Spacer()
                    Button("닫기") { showPatchNotes = false }
                        .buttonStyle(.glass)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)

                PatchNotesEmbeddedView()
            }
            .frame(width: 380, height: 500)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(radius: 20)
        }
    }
}

