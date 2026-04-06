import SwiftUI

struct MenuBarContent: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Text(statusLabel)
        Text("현재 세션: \(viewModel.timerText)")
        Text("오늘 총 집중: \(viewModel.todayTotalText)")

        Divider()

        if viewModel.canStart {
            Button("시작") { viewModel.start() }
        }
        if viewModel.canPause {
            Button("일시정지") { viewModel.pause() }
        }
        if viewModel.canResume {
            Button("재개") { viewModel.resume() }
        }
        if viewModel.canStop {
            Button("중지") { viewModel.stop() }
        }

        Divider()

        Button("RainDrop 열기") {
            openWindow(id: "main")
            NSApplication.shared.activate(ignoringOtherApps: true)
        }

        Divider()

        Button("종료") {
            NSApplication.shared.terminate(nil)
        }
    }

    private var statusLabel: String {
        switch viewModel.timerState {
        case .idle: return "대기 중"
        case .running: return "집중 중"
        case .paused: return "일시정지"
        case .completed: return "완료"
        }
    }
}
