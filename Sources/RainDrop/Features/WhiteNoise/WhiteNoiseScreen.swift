import SwiftUI

struct WhiteNoiseScreen: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var whiteNoiseService: WhiteNoiseService
    @Environment(\.overlayDismiss) private var overlayDismiss

    var body: some View {
        VStack(spacing: 0) {
            header

            Form {
                Section {
                    Toggle("빗소리 백색소음", isOn: $viewModel.settings.whiteNoiseEnabled)
                        .onChange(of: viewModel.settings.whiteNoiseEnabled) { _,enabled in
                            viewModel.save()
                            if !enabled {
                                whiteNoiseService.teardown()
                            } else {
                                whiteNoiseService.setup()
                            }
                        }

                    if viewModel.settings.whiteNoiseEnabled {
                        HStack {
                            Text("볼륨")
                            Slider(value: $viewModel.settings.whiteNoiseVolume, in: 0...1, step: 0.1)
                                .onChange(of: viewModel.settings.whiteNoiseVolume) { _,_ in
                                    viewModel.save()
                                    whiteNoiseService.setVolume(viewModel.settings.whiteNoiseVolume)
                                }
                        }

                        if whiteNoiseService.webView != nil {
                            RainySoundWebView(
                                whiteNoiseService: whiteNoiseService,
                                webViewID: whiteNoiseService.webViewID
                            )
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .id(whiteNoiseService.webViewID)
                        } else {
                            ProgressView("로딩 중...")
                                .frame(height: 120)
                        }

                        Text("위 플레이어에서 재생 버튼을 눌러주세요. 인터넷 연결이 필요합니다.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(minWidth: 420, minHeight: 350)
        .onAppear {
            if viewModel.settings.whiteNoiseEnabled && whiteNoiseService.webView == nil {
                whiteNoiseService.setup()
            }
        }
    }

    private var header: some View {
        ZStack {
            Text("백색소음")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)

            HStack {
                Spacer()
                Button("완료") { overlayDismiss?() }
                    .buttonStyle(.glass)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular)
    }
}
