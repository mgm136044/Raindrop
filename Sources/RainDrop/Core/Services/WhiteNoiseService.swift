import Foundation
import WebKit
import os

private let logger = Logger(subsystem: "com.mingyeongmin.RainDrop", category: "WhiteNoise")

@MainActor
final class WhiteNoiseService: NSObject, ObservableObject, WKNavigationDelegate {
    @Published private(set) var isPlaying = false
    @Published private(set) var isLoaded = false

    private var webView: WKWebView?
    private var pendingPlay = false

    func setup() {
        guard webView == nil else { return }
        let config = WKWebViewConfiguration()
        config.mediaTypesRequiringUserActionForPlayback = []
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = self
        wv.load(URLRequest(url: URL(string: "https://www.rainymood.com")!))
        webView = wv
        logger.notice("WKWebView 생성, rainymood.com 로딩 시작")
    }

    func play() {
        guard let webView else {
            setup()
            pendingPlay = true
            return
        }
        if !isLoaded {
            pendingPlay = true
            return
        }
        webView.evaluateJavaScript("var a = document.querySelector('audio'); if(a) { a.play(); true; } else { false; }") { [weak self] result, error in
            Task { @MainActor in
                if let error {
                    logger.error("play 실패: \(error.localizedDescription, privacy: .public)")
                    self?.isPlaying = false
                } else {
                    self?.isPlaying = true
                    logger.notice("백색소음 재생 시작")
                }
            }
        }
    }

    func pause() {
        pendingPlay = false
        webView?.evaluateJavaScript("var a = document.querySelector('audio'); if(a) { a.pause(); }") { _, _ in }
        isPlaying = false
    }

    /// WebView는 유지하여 재시작 시 로딩 지연 방지. 오디오만 정지.
    func stop() {
        pause()
    }

    func setVolume(_ volume: Double) {
        let clamped = max(0, min(1, volume))
        webView?.evaluateJavaScript("var a = document.querySelector('audio'); if(a) { a.volume = \(clamped); }") { _, _ in }
    }

    // MARK: - WKNavigationDelegate

    nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor in
            self.isLoaded = true
            logger.notice("rainymood.com 로딩 완료")
            if self.pendingPlay {
                self.pendingPlay = false
                self.play()
            }
        }
    }

    nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Task { @MainActor in
            logger.error("rainymood.com 로딩 실패: \(error.localizedDescription, privacy: .public)")
        }
    }
}
