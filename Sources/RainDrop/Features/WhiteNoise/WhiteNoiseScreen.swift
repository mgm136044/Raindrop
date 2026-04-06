import SwiftUI

struct WhiteNoiseScreen: View {
    @ObservedObject var viewModel: SettingsViewModel
    let whiteNoiseService: WhiteNoiseService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header

            Form {
                Section {
                    Toggle("빗소리 백색소음", isOn: $viewModel.settings.whiteNoiseEnabled)
                        .onChange(of: viewModel.settings.whiteNoiseEnabled) { enabled in
                            viewModel.save()
                            if !enabled {
                                whiteNoiseService.pauseAudio()
                            }
                        }

                    if viewModel.settings.whiteNoiseEnabled {
                        HStack {
                            Text("볼륨")
                            Slider(value: $viewModel.settings.whiteNoiseVolume, in: 0...1, step: 0.1)
                                .onChange(of: viewModel.settings.whiteNoiseVolume) { _ in
                                    viewModel.save()
                                    whiteNoiseService.setVolume(viewModel.settings.whiteNoiseVolume)
                                }
                        }

                        RainySoundWebView(whiteNoiseService: whiteNoiseService)
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )

                        Text("위 플레이어에서 재생 버튼을 눌러주세요. 인터넷 연결이 필요합니다.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(minWidth: 420, minHeight: 350)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("백색소음")
                    .font(.system(size: 24, weight: .bold))
                Text("빗소리로 집중력을 높여보세요.")
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
