import SwiftUI

struct BackgroundSoundScreen: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var backgroundSoundService: BackgroundSoundService
    @Environment(\.dismiss) private var dismiss

    /// 시트에서 미리듣기로 재생 시작했는지 추적 (시트 닫힐 때 정지용)
    @State private var startedPreview = false

    var body: some View {
        VStack(spacing: 0) {
            header

            Form {
                Section {
                    Toggle("배경 사운드", isOn: $viewModel.settings.whiteNoiseEnabled)
                        .onChange(of: viewModel.settings.whiteNoiseEnabled) { _, enabled in
                            viewModel.save()
                            if enabled {
                                backgroundSoundService.play(
                                    sound: viewModel.settings.backgroundSound,
                                    volume: viewModel.settings.whiteNoiseVolume
                                )
                                startedPreview = true
                            } else {
                                backgroundSoundService.teardown()
                                startedPreview = false
                            }
                        }
                }

                if viewModel.settings.whiteNoiseEnabled {
                    Section("소리 선택") {
                        ForEach(BackgroundSound.allCases, id: \.self) { sound in
                            Button {
                                viewModel.settings.backgroundSound = sound
                                viewModel.save()
                                backgroundSoundService.play(
                                    sound: sound,
                                    volume: viewModel.settings.whiteNoiseVolume
                                )
                                startedPreview = true
                            } label: {
                                HStack(spacing: 10) {
                                    Text(sound.emoji)
                                        .font(.system(size: 16))
                                    Text(sound.displayName)
                                        .font(.system(size: 14))
                                        .foregroundStyle(AppColors.primaryText)
                                    Spacer()
                                    if viewModel.settings.backgroundSound == sound {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(AppColors.accent)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Section("볼륨") {
                        Slider(value: $viewModel.settings.whiteNoiseVolume, in: 0...1, step: 0.1)
                            .onChange(of: viewModel.settings.whiteNoiseVolume) { _, _ in
                                viewModel.save()
                                backgroundSoundService.setVolume(viewModel.settings.whiteNoiseVolume)
                            }
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(minWidth: 420, minHeight: 400)
        .onDisappear {
            // 타이머 미실행 상태에서 미리듣기로 재생했으면 시트 닫힐 때 정지
            if startedPreview && !backgroundSoundService.isPlaying { return }
            if startedPreview {
                backgroundSoundService.teardown()
            }
        }
    }

    private var header: some View {
        ZStack {
            Text("배경 사운드")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)

            HStack {
                Spacer()
                Button("완료") { dismiss() }
                    .buttonStyle(.glass)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular)
    }
}
