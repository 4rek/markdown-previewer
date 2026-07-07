# Markdown Feature Test 1

This file exercises **every feature** the previewer supports. Press <kbd>Space</kbd> in Finder to render it.

## Headings

# H1 Heading
## H2 Heading
### H3 Heading
#### H4 Heading
##### H5 Heading
###### H6 Heading

## Inline text formatting

Regular text with **bold**, *italic*, ***bold italic***, ~~strikethrough~~, and `inline code`.

You can combine them: **bold with `code` inside**, *italic with [a link](https://example.com)*.

Here is a hard line break at the end of this line —  
and this text is on the next line.

A soft break just
continues on the same rendered line.

## Links

- Inline link: [Apple swift-markdown](https://github.com/apple/swift-markdown)
- Autolink-style: https://www.example.com
- Link with title text: [hover me](https://example.com "A title")

## Blockquotes

> This is a blockquote.
>
> It can span multiple paragraphs and contain **formatting**, `code`, and [links](https://example.com).
>
> > Nested blockquotes are also supported.

## Lists

### Unordered

- First item
- Second item
  - Nested item A
  - Nested item B
    - Deeply nested
- Third item

### Ordered

1. Step one
2. Step two
   1. Sub-step 2a
   2. Sub-step 2b
3. Step three

### Ordered starting at a custom number

5. Fifth
6. Sixth
7. Seventh

### Task list

- [x] Completed task
- [x] Another done item
- [ ] Pending task
- [ ] Another to-do

## Code

Inline: use `MarkdownHTMLRenderer.render(markdown:title:)` to render.

Fenced block with a language (note `<` is escaped correctly):

```swift
func greet(_ name: String) -> String {
    let ok = 1 < 2 && 3 > 2
    return "Hello, \(name)! (\(ok))"
}
```

Fenced block without a language:

```
plain text code block
  preserves    spacing
no syntax highlighting
```

## Tables (GitHub-flavored, with alignment)

| Feature       | Supported | Alignment demo |
|:--------------|:---------:|---------------:|
| Headings      |    ✅     |     right-aligned |
| Tables        |    ✅     |            $100 |
| Task lists    |    ✅     |             $9 |
| Long content  |    ✅     | wraps as needed |

## Horizontal rule

Above the line.

---

Below the line.

## Raw HTML passthrough

<div align="center">
  <strong>This paragraph is centered via raw HTML.</strong>
</div>

Text with <mark>inline HTML mark</mark> and <sub>subscript</sub> / <sup>superscript</sup>.

## Emoji & Unicode

Emoji: 🚀 ✨ 📝 ✅ — Unicode: café, naïve, Ω, → , ①②③

---

*End of feature test 1.*
