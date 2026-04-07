import SwiftUI

struct TimerControlsView: View {
    let canStart: Bool
    let canPause: Bool
    let canResume: Bool
    let canStop: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void
    var isCompact: Bool = false

    var body: some View {
        HStack(spacing: isCompact ? 16 : 12) {
            if canStart {
                if isCompact {
                    compactButton(icon: "play.fill", color: AppColors.startButton, action: onStart)
                } else {
                    Button("집중 시작", action: onStart)
                        .buttonStyle(PrimaryButtonStyle(color: AppColors.startButton))
                }
            }

            if canPause {
                if isCompact {
                    compactButton(icon: "pause.fill", color: AppColors.pauseButton, action: onPause)
                } else {
                    Button("일시정지", action: onPause)
                        .buttonStyle(PrimaryButtonStyle(color: AppColors.pauseButton))
                }
            }

            if canResume {
                if isCompact {
                    compactButton(icon: "play.fill", color: AppColors.startButton, action: onResume)
                } else {
                    Button("재개", action: onResume)
                        .buttonStyle(PrimaryButtonStyle(color: AppColors.startButton))
                }
            }

            if canStop {
                if isCompact {
                    compactButton(icon: "stop.fill", color: AppColors.stopButton, action: onStop)
                } else {
                    Button("집중 종료", action: onStop)
                        .buttonStyle(PrimaryButtonStyle(color: AppColors.stopButton))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: canStart)
        .animation(.easeInOut(duration: 0.25), value: canStop)
    }

    private func compactButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(color)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .transition(.scale.combined(with: .opacity))
    }
}
