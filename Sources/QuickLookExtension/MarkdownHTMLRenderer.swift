import Foundation
import Markdown

/// Converts Markdown source into a full, self-contained HTML page.
enum MarkdownHTMLRenderer {
    static func render(markdown: String, title: String) -> String {
        // swift-markdown enables the GitHub-flavored extensions (tables,
        // strikethrough, task lists) by default.
        let document = Document(parsing: markdown)
        var formatter = HTMLFormatter()
        let body = formatter.visit(document)
        return HTMLTemplate.page(body: body, title: title)
    }
}

/// Walks the Markdown AST and emits HTML. Kept deliberately small and readable —
/// each node type maps to one obvious bit of markup.
private struct HTMLFormatter: MarkupVisitor {
    typealias Result = String

    // Table rendering state.
    private var columnAlignments: [Table.ColumnAlignment?] = []
    private var inTableHead = false

    // MARK: Traversal helpers

    private mutating func descend(into markup: Markup) -> String {
        var result = ""
        for child in markup.children {
            result += visit(child)
        }
        return result
    }

    mutating func defaultVisit(_ markup: Markup) -> String {
        descend(into: markup)
    }

    // MARK: Block nodes

    mutating func visitParagraph(_ paragraph: Paragraph) -> String {
        "<p>\(descend(into: paragraph))</p>\n"
    }

    mutating func visitHeading(_ heading: Heading) -> String {
        let level = min(max(heading.level, 1), 6)
        return "<h\(level)>\(descend(into: heading))</h\(level)>\n"
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> String {
        "<hr>\n"
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> String {
        "<blockquote>\n\(descend(into: blockQuote))</blockquote>\n"
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> String {
        let language = codeBlock.language ?? ""
        let classAttribute = language.isEmpty ? "" : " class=\"language-\(escapeAttribute(language))\""
        return "<pre><code\(classAttribute)>\(escapeText(codeBlock.code))</code></pre>\n"
    }

    mutating func visitHTMLBlock(_ html: HTMLBlock) -> String {
        // Rendered verbatim, but JavaScript is disabled in the web view so any
        // <script> is inert.
        html.rawHTML
    }

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> String {
        "<ul>\n\(descend(into: unorderedList))</ul>\n"
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) -> String {
        let start = orderedList.startIndex
        let startAttribute = start == 1 ? "" : " start=\"\(start)\""
        return "<ol\(startAttribute)>\n\(descend(into: orderedList))</ol>\n"
    }

    mutating func visitListItem(_ listItem: ListItem) -> String {
        let content = descend(into: listItem)
        if let checkbox = listItem.checkbox {
            let checked = checkbox == .checked ? " checked" : ""
            return "<li class=\"task-list-item\"><input type=\"checkbox\" disabled\(checked)> \(content)</li>\n"
        }
        return "<li>\(content)</li>\n"
    }

    // MARK: Tables

    mutating func visitTable(_ table: Table) -> String {
        columnAlignments = table.columnAlignments
        var html = "<table>\n"
        html += visit(table.head)
        html += visit(table.body)
        html += "</table>\n"
        return html
    }

    mutating func visitTableHead(_ head: Table.Head) -> String {
        inTableHead = true
        var html = "<thead>\n<tr>\n"
        for cell in head.children {
            html += visit(cell)
        }
        html += "</tr>\n</thead>\n"
        inTableHead = false
        return html
    }

    mutating func visitTableBody(_ body: Table.Body) -> String {
        guard !body.isEmpty else { return "" }
        return "<tbody>\n\(descend(into: body))</tbody>\n"
    }

    mutating func visitTableRow(_ row: Table.Row) -> String {
        var html = "<tr>\n"
        for cell in row.children {
            html += visit(cell)
        }
        html += "</tr>\n"
        return html
    }

    mutating func visitTableCell(_ cell: Table.Cell) -> String {
        let tag = inTableHead ? "th" : "td"
        let column = cell.indexInParent
        let alignment = column < columnAlignments.count ? columnAlignments[column] : nil
        let style: String
        switch alignment {
        case .some(.left): style = " style=\"text-align:left\""
        case .some(.center): style = " style=\"text-align:center\""
        case .some(.right): style = " style=\"text-align:right\""
        case .none: style = ""
        }
        return "<\(tag)\(style)>\(descend(into: cell))</\(tag)>\n"
    }

    // MARK: Inline nodes

    mutating func visitText(_ text: Text) -> String {
        escapeText(text.string)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> String {
        "<em>\(descend(into: emphasis))</em>"
    }

    mutating func visitStrong(_ strong: Strong) -> String {
        "<strong>\(descend(into: strong))</strong>"
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> String {
        "<del>\(descend(into: strikethrough))</del>"
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> String {
        "<code>\(escapeText(inlineCode.code))</code>"
    }

    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> String {
        inlineHTML.rawHTML
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> String {
        "<br>\n"
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> String {
        "\n"
    }

    mutating func visitLink(_ link: Link) -> String {
        let destination = link.destination ?? ""
        return "<a href=\"\(escapeAttribute(destination))\">\(descend(into: link))</a>"
    }

    mutating func visitImage(_ image: Image) -> String {
        let source = image.source ?? ""
        let alt = image.plainText
        return "<img src=\"\(escapeAttribute(source))\" alt=\"\(escapeAttribute(alt))\">"
    }
}

// MARK: - HTML escaping

private func escapeText(_ string: String) -> String {
    var output = ""
    output.reserveCapacity(string.count)
    for character in string {
        switch character {
        case "&": output += "&amp;"
        case "<": output += "&lt;"
        case ">": output += "&gt;"
        default: output.append(character)
        }
    }
    return output
}

private func escapeAttribute(_ string: String) -> String {
    escapeText(string)
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&#39;")
}
