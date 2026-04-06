import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header

            Form {
                Section("집중 목표") {
                    HStack {
                        Text("양동이 채움 목표 시간")
                        Spacer()
                        TextField("", value: $viewModel.settings.sessionGoalMinutes, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
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
                    Text("1 ~ 120분")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
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

                if let error = viewModel.latestError {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .formStyle(.grouped)
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
