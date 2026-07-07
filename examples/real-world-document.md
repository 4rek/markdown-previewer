# Markdown Feature Test 2 — Real-World Document

A more realistic, prose-heavy document to see how the previewer handles a typical README / spec.

## Overview

The **Markdown Previewer** is a macOS Quick Look extension. When you select a
`.md` file in Finder and press <kbd>Space</kbd>, it renders the Markdown with
GitHub-style formatting instead of showing raw text. It is *self-contained*,
*fast*, and *open source* under the [MIT license](https://opensource.org/license/mit).

> **Note:** This is the second test file. It intentionally mixes long prose with
> occasional code, tables, and lists — the shape of a real document.

## Feature matrix

| Area            | Status      | Notes                                   |
|:----------------|:-----------:|:----------------------------------------|
| CommonMark      | Complete    | Headings, emphasis, lists, quotes       |
| GFM tables      | Complete    | Column alignment supported              |
| Task lists      | Complete    | Rendered as disabled checkboxes         |
| Syntax colors   | Not yet     | Code blocks are monospaced, not colored |
| Remote images   | Partial     | Loads if network available              |

## A short walkthrough

1. **Install** the app and enable the extension.
2. **Select** any Markdown file.
3. **Press Space** — done.

If a preview ever looks stale, the app self-heals on launch. You can also click
**Refresh Preview Cache** in the app window.

### Configuration example

Here is a representative snippet of the kind of content you might preview:

```json
{
  "name": "markdown-previewer",
  "version": "1.0.0",
  "features": ["tables", "task-lists", "dark-mode"],
  "sandboxed": true
}
```

```bash
# Build and package a signed DMG
./scripts/build.sh

# Reset Quick Look if needed
qlmanage -r && qlmanage -r cache
```

## Quotes and callouts

> "Simplicity is the ultimate sophistication."
>
> — attributed to Leonardo da Vinci

Some inline references while reading: see `PreviewProvider.providePreview(for:)`,
the [swift-markdown docs](https://github.com/apple/swift-markdown), and note that
`5 < 10` and `a && b` render literally inside code.

## Nested structure stress test

- Project
  - Sources
    - App
      - `MarkdownPreviewerApp.swift`
      - `OnboardingView.swift`
    - QuickLookExtension
      - `PreviewProvider.swift`
      - `MarkdownHTMLRenderer.swift`
  - Tests
    - [x] Renderer unit tests
    - [ ] UI tests
  - Scripts
    1. `build.sh`
    2. `uninstall.sh`

## Long paragraph (wrapping check)

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu
fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
culpa qui officia deserunt mollit anim id est laborum.

## Mixed emphasis and punctuation

It's a test of *emphasis*, "smart-ish quotes", em—dashes, ellipses…, and
`code_with_underscores` that should **not** turn into italics.

---

That's everything. If both test files render cleanly, the previewer is in good shape. ✅
