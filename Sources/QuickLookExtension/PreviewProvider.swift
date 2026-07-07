import Foundation
import Quartz
import UniformTypeIdentifiers
import os

/// Data-based Quick Look preview provider. Instead of hosting our own WKWebView
/// (which stalls badly when run offscreen inside a Quick Look extension), we
/// render the Markdown to HTML and hand it to Quick Look, which renders it. This
/// makes previews appear essentially instantly.
class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    private static let log = Logger(subsystem: "com.apjuszczyk.markdownpreviewer", category: "preview")

    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let start = DispatchTime.now()
        let url = request.fileURL

        let data = try Data(contentsOf: url)
        let markdown = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
        let html = MarkdownHTMLRenderer.render(markdown: markdown, title: url.lastPathComponent)
        let htmlData = Data(html.utf8)

        let ms = Int(Double(DispatchTime.now().uptimeNanoseconds &- start.uptimeNanoseconds) / 1_000_000)
        Self.log.error("provided HTML (\(htmlData.count, privacy: .public) bytes) in \(ms, privacy: .public)ms")

        return QLPreviewReply(dataOfContentType: .html,
                              contentSize: CGSize(width: 800, height: 600)) { reply in
            reply.stringEncoding = .utf8
            reply.title = url.lastPathComponent
            return htmlData
        }
    }
}
