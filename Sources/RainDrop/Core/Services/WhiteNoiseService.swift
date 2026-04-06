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

    private let playJS = """
    (function() {
        var a = document.querySelector('audio');
        if (!a) a = document.getElementById('player');
        if (!a) a = document.querySelector('[id*="audio"]');
        if (!a) a = document.querySelector('[id*="player"]');
        if (a && a.play) { a.play(); return 'audio'; }
        var btn = document.querySelector('.play-button, .btn-play, [class*="play"], button[aria-label*="play"], #play');
        if (!btn) { var buttons = document.querySelectorAll('button'); for (var b of buttons) { if (b.textContent.toLowerCase().includes('play') || b.querySelector('svg')) { btn = b; break; } } }
        if (btn) { btn.click(); return 'button'; }
        return 'none';
    })()
    """

    private let pauseJS = """
    (function() {
        var a = document.querySelector('audio');
        if (!a) a = document.getElementById('player');
        if (!a) a = document.querySelector('[id*="audio"]');
        if (a && a.pause) { a.pause(); }
    })()
    """

    private let volumeJS = """
    (function(vol) {
        var a = document.querySelector('audio');
        if (!a) a = document.getElementById('player');
        if (!a) a = document.querySelector('[id*="audio"]');
        if (a) { a.volume = vol; }
    })
    """

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
        webView.evaluateJavaScript(playJS) { [weak self] result, error in
            Task { @MainActor in
                if let error {
                    logger.error("play 실패: \(error.localizedDescription, privacy: .public)")
                    self?.isPlaying = false
                } else {
                    let method = result as? String ?? "unknown"
                    logger.notice("백색소음 재생 시도: \(method, privacy: .public)")
                    self?.isPlaying = method != "none"
                }
            }
        }
    }

    func pause() {
        pendingPlay = false
        webView?.evaluateJavaScript(pauseJS) { _, _ in }
        isPlaying = false
    }

    /// WebView는 유지하여 재시작 시 로딩 지연 방지. 오디오만 정지.
    func stop() {
        pause()
    }

    func setVolume(_ volume: Double) {
        let clamped = max(0, min(1, volume))
        webView?.evaluateJavaScript("(\(volumeJS))(\(clamped))") { _, _ in }
    }

    // MARK: - WKNavigationDelegate

    nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor in
            self.isLoaded = true
            logger.notice("rainymood.com 로딩 완료")

            // DOM 구조 디버깅
            webView.evaluateJavaScript("document.querySelector('audio')?.src || 'no-audio-element'") { result, _ in
                logger.notice("DOM audio src: \(result as? String ?? "nil", privacy: .public)")
            }

            if self.pendingPlay {
                self.pendingPlay = false
                // DOM 완전 렌더링 대기 후 재생
                try? await Task.sleep(for: .seconds(1.0))
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
