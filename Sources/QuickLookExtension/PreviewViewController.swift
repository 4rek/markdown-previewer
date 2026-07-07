import Cocoa
import Quartz
import WebKit
import os

/// Principal class for the Quick Look preview extension. macOS instantiates this
/// (see `NSExtensionPrincipalClass` in Info.plist) whenever the user Quick Looks
/// a Markdown file. It renders the file to HTML and shows it in a WKWebView.
class PreviewViewController: NSViewController, QLPreviewingController, WKNavigationDelegate {
    private static let log = Logger(subsystem: "com.apjuszczyk.markdownpreviewer", category: "preview")

    private var webView: WKWebView!

    // Quick Look shows its "preparing" spinner until `preparePreviewOfFile`
    // returns, so we must return the moment the content is on screen — but *not*
    // wait for every subresource to finish. We resume as soon as the document is
    // committed and rendering, and guard with a hard timeout so it can't hang.
    private var loadContinuation: CheckedContinuation<Void, Error>?
    private var startTime: DispatchTime = .now()
    private static let maxWait: TimeInterval = 1.5

    override func loadView() {
        let configuration = WKWebViewConfiguration()

        // Previews should never execute embedded scripts — disable JavaScript so
        // a malicious Markdown file can't run code in the preview surface.
        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = false
        configuration.defaultWebpagePreferences = pagePreferences

        webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 800, height: 600), configuration: configuration)
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        self.view = webView
    }

    func preparePreviewOfFile(at url: URL) async throws {
        startTime = .now()
        let data = try Data(contentsOf: url)
        let markdown = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
        let html = MarkdownHTMLRenderer.render(markdown: markdown, title: url.lastPathComponent)
        Self.log.log("prepared HTML (\(html.count) bytes) at +\(self.elapsedMs())ms")

        // NOTE: baseURL is the *file's own URL*, which Quick Look's sandbox grants
        // read access to. Using the parent directory (which the sandbox does NOT
        // grant) makes WebKit stall for seconds establishing the document origin.
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.loadContinuation = continuation
            self.webView.loadHTMLString(html, baseURL: url)

            DispatchQueue.main.asyncAfter(deadline: .now() + Self.maxWait) { [weak self] in
                guard let self, self.loadContinuation != nil else { return }
                Self.log.log("resume via TIMEOUT at +\(self.elapsedMs())ms")
                self.finishLoading()
            }
        }
    }

    private func elapsedMs() -> Int {
        Int(Double(DispatchTime.now().uptimeNanoseconds &- startTime.uptimeNanoseconds) / 1_000_000)
    }

    /// Resume the pending continuation exactly once.
    private func finishLoading(throwing error: Error? = nil) {
        guard let continuation = loadContinuation else { return }
        loadContinuation = nil
        if let error {
            continuation.resume(throwing: error)
        } else {
            continuation.resume()
        }
    }

    // MARK: - WKNavigationDelegate

    // Content is committed and rendering — hand control back to Quick Look now.
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Self.log.log("resume via didCommit at +\(self.elapsedMs())ms")
        finishLoading()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Self.log.log("didFinish at +\(self.elapsedMs())ms")
        finishLoading()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Self.log.error("didFail at +\(self.elapsedMs())ms: \(error.localizedDescription)")
        finishLoading(throwing: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Self.log.error("didFailProvisional at +\(self.elapsedMs())ms: \(error.localizedDescription)")
        finishLoading(throwing: error)
    }
}
