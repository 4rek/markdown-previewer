import Cocoa
import Quartz
import WebKit

/// Principal class for the Quick Look preview extension. macOS instantiates this
/// (see `NSExtensionPrincipalClass` in Info.plist) whenever the user Quick Looks
/// a Markdown file. It renders the file to HTML and shows it in a WKWebView.
class PreviewViewController: NSViewController, QLPreviewingController {
    private var webView: WKWebView!

    override func loadView() {
        let configuration = WKWebViewConfiguration()

        // Previews should never execute embedded scripts — disable JavaScript so
        // a malicious Markdown file can't run code in the preview surface.
        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = false
        configuration.defaultWebpagePreferences = pagePreferences

        webView = WKWebView(frame: .zero, configuration: configuration)
        self.view = webView
    }

    func preparePreviewOfFile(at url: URL) async throws {
        let data = try Data(contentsOf: url)
        let markdown = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
        let html = MarkdownHTMLRenderer.render(markdown: markdown, title: url.lastPathComponent)

        // baseURL is the file's directory so relative image links have a chance
        // of resolving (subject to the sandbox read grant Quick Look provides).
        let baseURL = url.deletingLastPathComponent()

        await MainActor.run {
            webView.loadHTMLString(html, baseURL: baseURL)
        }
    }
}
