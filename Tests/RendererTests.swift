import XCTest

final class RendererTests: XCTestCase {
    private func render(_ markdown: String) -> String {
        MarkdownHTMLRenderer.render(markdown: markdown, title: "test.md")
    }

    func testHeadingAndParagraph() {
        let html = render("# Hello\n\nWorld.")
        XCTAssertTrue(html.contains("<h1>Hello</h1>"), html)
        XCTAssertTrue(html.contains("<p>World.</p>"), html)
    }

    func testInlineFormatting() {
        let html = render("This is **bold**, *italic*, ~~struck~~ and `code`.")
        XCTAssertTrue(html.contains("<strong>bold</strong>"), html)
        XCTAssertTrue(html.contains("<em>italic</em>"), html)
        XCTAssertTrue(html.contains("<del>struck</del>"), html)
        XCTAssertTrue(html.contains("<code>code</code>"), html)
    }

    func testGFMTableWithAlignment() {
        let markdown = """
        | Left | Center | Right |
        |:-----|:------:|------:|
        | a    | b      | c     |
        """
        let html = render(markdown)
        XCTAssertTrue(html.contains("<table>"), html)
        XCTAssertTrue(html.contains("<th style=\"text-align:left\">Left</th>"), html)
        XCTAssertTrue(html.contains("<th style=\"text-align:center\">Center</th>"), html)
        XCTAssertTrue(html.contains("<th style=\"text-align:right\">Right</th>"), html)
        XCTAssertTrue(html.contains("<td style=\"text-align:center\">b</td>"), html)
    }

    func testTaskList() {
        let html = render("- [x] done\n- [ ] todo")
        XCTAssertTrue(html.contains("<input type=\"checkbox\" disabled checked>"), html)
        XCTAssertTrue(html.contains("<input type=\"checkbox\" disabled>"), html)
    }

    func testFencedCodeBlockWithLanguage() {
        let markdown = """
        ```swift
        let x = 1 < 2
        ```
        """
        let html = render(markdown)
        XCTAssertTrue(html.contains("<pre><code class=\"language-swift\">"), html)
        // Angle brackets inside code must be escaped.
        XCTAssertTrue(html.contains("1 &lt; 2"), html)
    }

    func testHTMLEscapingInText() {
        let html = render("5 < 6 & 7 > 4")
        XCTAssertTrue(html.contains("5 &lt; 6 &amp; 7 &gt; 4"), html)
    }

    func testLink() {
        let html = render("[site](https://example.com)")
        XCTAssertTrue(html.contains("<a href=\"https://example.com\">site</a>"), html)
    }

    func testDocumentIsWrapped() {
        let html = render("hi")
        XCTAssertTrue(html.hasPrefix("<!DOCTYPE html>"), html)
        XCTAssertTrue(html.contains("<article class=\"markdown-body\">"), html)
        XCTAssertTrue(html.contains("prefers-color-scheme: dark"), html)
    }
}
