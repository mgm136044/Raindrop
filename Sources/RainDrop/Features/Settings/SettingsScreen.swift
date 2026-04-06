import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel
    var totalBuckets: Int = 0
    @Environment(\.dismiss) private var dismiss
    @State private var showOnboarding = false
    @State private var showPatchNotes = false

    var body: some View {
        VStack(spacing: 0) {
            header

            Form {
                Section("집중 목표") {
                    Toggle("무한 모드 (∞)", isOn: $viewModel.settings.infinityModeEnabled)
                        .onChange(of: viewModel.settings.infinityModeEnabled) { _ in
                            viewModel.save()
                        }

                    HStack {
                        Text("양동이 채움 목표 시간")
                        Spacer()
                        if viewModel.settings.infinityModeEnabled {
                            Text("∞")
                                .font(.system(size: 20, weight: .bold))
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
                    .onChange(of: viewModel.settings.sessionGoalMinutes) { newValue in
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
                        .onChange(of: viewModel.settings.focusCheckEnabled) { _ in
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
                        .onChange(of: viewModel.settings.focusCheckIntervalMinutes) { newValue in
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

                Section("양동이 스킨") {
                    ForEach(BucketSkin.allCases, id: \.self) { skin in
                        let unlocked = skin.isUnlocked(totalBuckets: totalBuckets)
                        Button {
                            if unlocked {
                                viewModel.settings.selectedSkin = skin
                                viewModel.save()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: viewModel.settings.selectedSkin == skin ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(viewModel.settings.selectedSkin == skin ? .blue : .secondary)

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
                                    .fill(skin.bucketFill)
                                    .overlay(Circle().stroke(skin.bucketStroke, lineWidth: 2))
                                    .frame(width: 24, height: 24)
                                    .opacity(unlocked ? 1.0 : 0.4)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .disabled(!unlocked)
                    }

                    if viewModel.settings.selectedSkin.hasCustomWaterColor {
                        Toggle("스킨 색 물 사용", isOn: $viewModel.settings.useCustomWaterColor)
                            .onChange(of: viewModel.settings.useCustomWaterColor) { _ in
                                viewModel.save()
                            }
                        Text("물과 물방울의 색을 스킨 색상에 맞춥니다.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Section("기타") {
                    Button("패치노트") {
                        showPatchNotes = true
                    }
                    Button("온보딩 다시 보기") {
                        showOnboarding = true
                    }
                }

                if let error = viewModel.latestError {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .formStyle(.grouped)
            .sheet(isPresented: $showOnboarding) {
                OnboardingView {
                    showOnboarding = false
                }
            }
            .sheet(isPresented: $showPatchNotes) {
                PatchNotesView()
            }
        }
        .frame(minWidth: 420, minHeight: 320)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("설정")
                    .font(.system(size: 24, weight: .bold))
                Text("집중 목표와 알림을 설정합니다.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("닫기") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 12)
        .background(AppColors.historyHeaderBackground)
    }
}
