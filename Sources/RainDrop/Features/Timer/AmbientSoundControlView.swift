import SwiftUI

struct AmbientSoundControlView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    let whiteNoiseService: WhiteNoiseService

    @State private var isExpanded = false

    private var isEnabled: Bool {
        settingsViewModel.settings.whiteNoiseEnabled
    }

    var body: some View {
        HStack(spacing: 8) {
            Button {
                toggleSound()
            } label: {
                Image(systemName: isEnabled ? "speaker.wave.2.fill" : "speaker.slash")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isEnabled ? AppColors.accentBlue : .secondary)
            }
            .buttonStyle(.plain)

            if isExpanded && isEnabled {
                Slider(
                    value: Binding(
                        get: { settingsViewModel.settings.whiteNoiseVolume },
                        set: { newValue in
                            settingsViewModel.settings.whiteNoiseVolume = newValue
                            settingsViewModel.save()
                            whiteNoiseService.setVolume(newValue)
                        }
                    ),
                    in: 0...1,
                    step: 0.1
                )
                .frame(width: 80)
                .controlSize(.mini)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded = hovering
            }
        }
    }

    private func toggleSound() {
        settingsViewModel.settings.whiteNoiseEnabled.toggle()
        settingsViewModel.save()

        if isEnabled {
            whiteNoiseService.setup()
            whiteNoiseService.setVolume(settingsViewModel.settings.whiteNoiseVolume)
            whiteNoiseService.resumeAudio()
        } else {
            whiteNoiseService.teardown()
        }
    }
}
