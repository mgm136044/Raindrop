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

    var body: some View {
        HStack(spacing: 12) {
            if canStart {
                Button("집중 시작", action: onStart)
                    .buttonStyle(PrimaryButtonStyle(color: AppColors.startButton))
                    .transition(.scale.combined(with: .opacity))
            }

            if canPause {
                Button("일시정지", action: onPause)
                    .buttonStyle(PrimaryButtonStyle(color: AppColors.pauseButton))
                    .transition(.scale.combined(with: .opacity))
            }

            if canResume {
                Button("재개", action: onResume)
                    .buttonStyle(PrimaryButtonStyle(color: AppColors.startButton))
                    .transition(.scale.combined(with: .opacity))
            }

            if canStop {
                Button("집중 종료", action: onStop)
                    .buttonStyle(PrimaryButtonStyle(color: AppColors.stopButton))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: canStart)
        .animation(.easeInOut(duration: 0.25), value: canStop)
    }
}
