# Markdown Previewer — Sample

A quick smoke test. Select this file in Finder and press **Space**.

## Text formatting

You can write **bold**, *italic*, ~~strikethrough~~, and `inline code`.
Here's a [link to Apple's swift-markdown](https://github.com/apple/swift-markdown).

> Blockquotes look like this.
> They can span multiple lines.

## Lists

- Unordered item
- Nested:
  - child one
  - child two

1. First
2. Second
3. Third

### Task list

- [x] Build the extension
- [x] Render Markdown
- [ ] Ship it

## Code block

```swift
func greet(_ name: String) -> String {
    return "Hello, \(name)!"  // 1 < 2 stays escaped
}
```

## Table

| Feature      | Status | Notes            |
|:-------------|:------:|-----------------:|
| Tables       |   ✅   |     with align   |
| Task lists   |   ✅   |          GFM     |
| Dark mode    |   ✅   |    auto-adapts   |

---

That's it. If this looks nicely formatted, everything works.
