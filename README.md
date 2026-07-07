# Markdown Previewer

A tiny macOS **Quick Look** extension that renders Markdown files with clean,
GitHub-style formatting. Select any `.md` file in Finder, press <kbd>Space</kbd>,
and see rendered Markdown instead of raw text — tables, task lists, code blocks,
and all. Light and dark mode aware.

> Does one thing well: previews Markdown. No settings to fiddle with.

## Install

### Homebrew (recommended)

```sh
brew install --cask OWNER/tap/markdown-previewer
```

*(Replace `OWNER` once you publish your tap — see [Releasing](#releasing).)*

### Manual

1. Download `MarkdownPreviewer.dmg` from the [latest release](https://github.com/OWNER/markdown-previewer/releases/latest).
2. Drag **Markdown Previewer** to **Applications**.
3. Launch it once (it registers the Quick Look extension).

## First-time setup

Because this build is **ad-hoc signed** (not yet Apple-notarized — see
[Notarization](#upgrading-to-notarization)), macOS needs one nudge the first
time:

- **If you installed via Homebrew:** nothing to do — the cask strips the
  quarantine flag for you.
- **If you installed manually:** the first launch may say *"Markdown Previewer
  can't be opened because Apple cannot check it."* Open **System Settings →
  Privacy & Security**, scroll down, and click **Open Anyway**. One time only.

Then enable the extension:

1. **System Settings → General → Login Items & Extensions → Quick Look**
2. Turn on **Markdown Previewer**.
3. In Finder, select a `.md` file and press <kbd>Space</kbd>.

The app's welcome window has a button that jumps straight to that settings pane.

> If a preview looks stale after updating, reset Quick Look's cache:
> `qlmanage -r && qlmanage -r cache`

## What it renders

Headings · paragraphs · **bold** / *italic* / ~~strikethrough~~ · `inline code` ·
fenced code blocks · blockquotes · ordered/unordered lists · GitHub task lists ·
GFM tables (with column alignment) · links · images · horizontal rules.

Rendering is powered by [apple/swift-markdown](https://github.com/apple/swift-markdown)
(GitHub-flavored). JavaScript is disabled in the preview surface, so a malicious
document can't execute code.

## Development

Requirements: **Xcode** and **[XcodeGen](https://github.com/yonaskolb/XcodeGen)**
(`brew install xcodegen`).

The `.xcodeproj` is **generated** from [`project.yml`](project.yml) and is not
committed. Generate it, then open:

```sh
xcodegen generate
open MarkdownPreviewer.xcodeproj
```

Run the renderer tests:

```sh
xcodebuild -project MarkdownPreviewer.xcodeproj -scheme RendererTests \
  -destination 'platform=macOS' test
```

### Project layout

| Path | What it is |
|------|------------|
| `Sources/App/` | Tiny SwiftUI container app + onboarding. Exists to register and enable the extension. |
| `Sources/QuickLookExtension/` | The Quick Look preview extension. |
| `Sources/QuickLookExtension/MarkdownHTMLRenderer.swift` | Markdown AST → HTML (a small `MarkupVisitor`). |
| `Sources/QuickLookExtension/HTMLTemplate.swift` | Inline CSS page wrapper (light/dark). |
| `Sources/QuickLookExtension/PreviewViewController.swift` | `QLPreviewingController` that loads the HTML in a `WKWebView`. |
| `Tests/` | Renderer unit tests. |
| `scripts/build.sh` | Builds the ad-hoc-signed DMG. |
| `Casks/` | Homebrew Cask template. |

## Releasing

1. Bump `MARKETING_VERSION` in `project.yml` and `version` in `Casks/markdown-previewer.rb`.
2. Push a tag: `git tag v1.0.0 && git push --tags`.
3. The [release workflow](.github/workflows/release.yml) builds the DMG and
   attaches it to a GitHub Release.
4. Copy the printed `sha256` into the cask, commit it to your tap repo.

### Upgrading to notarization

The frictionless path is Apple notarization (needs the **Apple Developer
Program**, $99/yr). When you're ready:

1. In `project.yml`, set `DEVELOPMENT_TEAM` and change `CODE_SIGN_IDENTITY` to
   `"Developer ID Application"`.
2. Add `notarytool` submission + `stapler` to `scripts/build.sh`.
3. Drop the `postflight`/quarantine block from the cask.

No other code changes are needed — the quarantine warning simply disappears.

## License

[MIT](LICENSE) — use it however you like.
