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
                    compactButton(icon: "play.fill", color: AppColors.accent, action: onStart)
                } else {
                    Button("집중 시작", action: onStart)
                        .buttonStyle(PrimaryButtonStyle(color: AppColors.accent))
                }
            }

            if canPause {
                if isCompact {
                    compactButton(icon: "pause.fill", color: AppColors.accent, action: onPause)
                } else {
                    Button("일시정지", action: onPause)
                        .buttonStyle(PrimaryButtonStyle(color: AppColors.accent))
                }
            }

            if canResume {
                if isCompact {
                    compactButton(icon: "play.fill", color: AppColors.accent, action: onResume)
                } else {
                    Button("재개", action: onResume)
                        .buttonStyle(PrimaryButtonStyle(color: AppColors.accent))
                }
            }

            if canStop {
                if isCompact {
                    compactButton(icon: "stop.fill", color: AppColors.danger, action: onStop)
                } else {
                    Button("집중 종료", action: onStop)
                        .buttonStyle(PrimaryButtonStyle(color: AppColors.danger))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: canStart)
        .animation(.easeInOut(duration: 0.25), value: canStop)
    }

    private func compactButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .contentShape(Circle())
                .glassEffect(Glass.regular.tint(color), in: Circle())
        }
        .buttonStyle(.plain)
        .transition(.scale.combined(with: .opacity))
    }
}
