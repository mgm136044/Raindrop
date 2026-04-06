import Foundation

@MainActor
final class TimerService {
    private var timer: Timer?

    func start(tick: @escaping @MainActor @Sendable () -> Void) {
        stop()
        let t = Timer(timeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                tick()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
