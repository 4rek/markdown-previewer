import Foundation
import Quartz
import UniformTypeIdentifiers

/// Data-based Quick Look preview provider. We render the Markdown to HTML and
/// hand it to Quick Look, which draws it — so previews appear instantly without
/// the extension hosting its own web view.
///
/// Requires `QLIsDataBasedPreview = true` in the extension's Info.plist;
/// otherwise Quick Look treats the principal class as a view controller.
class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let url = request.fileURL

        let data = try Data(contentsOf: url)
        let markdown = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
        let html = MarkdownHTMLRenderer.render(markdown: markdown, title: url.lastPathComponent)
        let htmlData = Data(html.utf8)

        return QLPreviewReply(dataOfContentType: .html,
                              contentSize: CGSize(width: 800, height: 600)) { reply in
            reply.stringEncoding = .utf8
            reply.title = url.lastPathComponent
            return htmlData
        }
    }
}
