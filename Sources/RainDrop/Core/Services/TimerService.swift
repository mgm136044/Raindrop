import Foundation

@MainActor
final class TimerService {
    private var timer: Timer?

    func start(tick: @escaping @MainActor @Sendable () -> Void) {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                tick()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
