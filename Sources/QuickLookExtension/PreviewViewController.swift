import Cocoa
import Quartz
import WebKit

/// Principal class for the Quick Look preview extension. macOS instantiates this
/// (see `NSExtensionPrincipalClass` in Info.plist) whenever the user Quick Looks
/// a Markdown file. It renders the file to HTML and shows it in a WKWebView.
class PreviewViewController: NSViewController, QLPreviewingController, WKNavigationDelegate {
    private var webView: WKWebView!

    // Quick Look snapshots the view as soon as `preparePreviewOfFile` returns, so
    // we must not return until the web view has actually finished rendering —
    // otherwise the preview shows up blank. This continuation bridges the async
    // entry point to the `WKNavigationDelegate` completion callbacks.
    private var loadContinuation: CheckedContinuation<Void, Error>?

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
        let data = try Data(contentsOf: url)
        let markdown = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
        let html = MarkdownHTMLRenderer.render(markdown: markdown, title: url.lastPathComponent)

        // baseURL is the file's directory so relative image links have a chance
        // of resolving (subject to the sandbox read grant Quick Look provides).
        let baseURL = url.deletingLastPathComponent()

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.loadContinuation = continuation
            self.webView.loadHTMLString(html, baseURL: baseURL)
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadContinuation?.resume()
        loadContinuation = nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadContinuation?.resume(throwing: error)
        loadContinuation = nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadContinuation?.resume(throwing: error)
        loadContinuation = nil
    }
}
