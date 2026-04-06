import Foundation
import SwiftUI
import WebKit
import os

private let logger = Logger(subsystem: "com.mingyeongmin.RainDrop", category: "WhiteNoise")

/// rainymood.com을 WKWebView로 로드하여 빗소리 백색소음을 재생.
/// 사용자가 직접 재생 버튼을 클릭하는 방식으로 autoplay 정책을 우회.
@MainActor
final class WhiteNoiseService: NSObject, ObservableObject, WKNavigationDelegate {
    @Published private(set) var isLoaded = false

    private(set) var webView: WKWebView?

    /// CSS 주입: 불필요한 요소 숨기고 플레이어만 표시
    private let hideCSS = """
    (function() {
        var style = document.createElement('style');
        style.textContent = `
            body > *:not(#app):not(#player-container):not(.player):not(audio) { display: none !important; }
            header, footer, nav, .social, .links, .logo, .title, .subtitle, .credits,
            [class*="social"], [class*="header"], [class*="footer"], [class*="nav"],
            [class*="banner"], [class*="ad"], [class*="promo"], [class*="subscribe"],
            [class*="download"], [class*="share"], iframe { display: none !important; }
            body { background: transparent !important; overflow: hidden !important; display: flex !important;
                   justify-content: center !important; align-items: center !important;
                   min-height: 100vh !important; }
        `;
        document.head.appendChild(style);
        return 'css-injected';
    })()
    """

    func setup() {
        guard webView == nil else { return }
        let config = WKWebViewConfiguration()
        config.mediaTypesRequiringUserActionForPlayback = []
        let wv = WKWebView(frame: CGRect(x: 0, y: 0, width: 300, height: 200), configuration: config)
        wv.navigationDelegate = self
        wv.isHidden = false
        wv.setValue(false, forKey: "drawsBackground")
        wv.load(URLRequest(url: URL(string: "https://www.rainymood.com")!))
        webView = wv
        logger.notice("WKWebView 생성, rainymood.com 로딩 시작")
    }

    func setVolume(_ volume: Double) {
        let clamped = max(0, min(1, volume))
        let js = """
        (function() {
            var a = document.querySelector('audio');
            if (!a) a = document.getElementById('player');
            if (!a) a = document.querySelector('[id*="audio"]');
            if (!a) a = document.querySelector('[id*="player"]');
            if (a) { a.volume = \(clamped); }
        })()
        """
        webView?.evaluateJavaScript(js) { _, _ in }
    }

    func pauseAudio() {
        let js = """
        (function() {
            var a = document.querySelector('audio');
            if (!a) a = document.getElementById('player');
            if (!a) a = document.querySelector('[id*="audio"]');
            if (!a) a = document.querySelector('[id*="player"]');
            if (a && a.pause) { a.pause(); }
        })()
        """
        webView?.evaluateJavaScript(js) { _, _ in }
    }

    func resumeAudio() {
        let js = """
        (function() {
            var a = document.querySelector('audio');
            if (!a) a = document.getElementById('player');
            if (!a) a = document.querySelector('[id*="audio"]');
            if (!a) a = document.querySelector('[id*="player"]');
            if (a && a.play) { a.play(); }
        })()
        """
        webView?.evaluateJavaScript(js) { _, _ in }
    }

    // MARK: - WKNavigationDelegate

    nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor in
            self.isLoaded = true
            logger.notice("rainymood.com 로딩 완료")

            // CSS 주입으로 플레이어만 표시
            webView.evaluateJavaScript(self.hideCSS) { result, _ in
                logger.notice("CSS injection: \(result as? String ?? "nil", privacy: .public)")
            }
        }
    }

    nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Task { @MainActor in
            logger.error("rainymood.com 네비게이션 실패: \(error.localizedDescription, privacy: .public)")
        }
    }

    nonisolated func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Task { @MainActor in
            logger.error("rainymood.com 초기 로딩 실패 (네트워크 오류): \(error.localizedDescription, privacy: .public)")
        }
    }
}

// MARK: - SwiftUI WebView Wrapper

struct RainySoundWebView: NSViewRepresentable {
    let whiteNoiseService: WhiteNoiseService

    func makeNSView(context: Context) -> WKWebView {
        if whiteNoiseService.webView == nil {
            whiteNoiseService.setup()
        }
        return whiteNoiseService.webView ?? WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
