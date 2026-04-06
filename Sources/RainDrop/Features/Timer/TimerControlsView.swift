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
            Button("집중 시작", action: onStart)
                .buttonStyle(PrimaryButtonStyle(color: AppColors.startButton))
                .disabled(!canStart)

            Button(canResume ? "재개" : "일시정지") {
                canResume ? onResume() : onPause()
            }
            .buttonStyle(PrimaryButtonStyle(color: AppColors.pauseButton))
            .disabled(!(canPause || canResume))

            Button("집중 종료", action: onStop)
                .buttonStyle(PrimaryButtonStyle(color: AppColors.stopButton))
                .disabled(!canStop)
        }
    }
}
