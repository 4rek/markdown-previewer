# Markdown Previewer

A tiny macOS **Quick Look** extension that renders Markdown files with clean,
GitHub-style formatting. Select any `.md` file in Finder, press <kbd>Space</kbd>,
and see rendered Markdown instead of raw text — headings, tables, task lists,
code blocks, and more. Light- and dark-mode aware.

> Does one thing well: previews Markdown. No settings to fiddle with.

<p align="center">
  <img src="docs/screenshot-light.png" width="46%" alt="Rendered Markdown preview in light mode">
  &nbsp;&nbsp;
  <img src="docs/screenshot-dark.png" width="46%" alt="Rendered Markdown preview in dark mode">
</p>
<p align="center"><sub>The same file previewed in light and dark mode — Quick Look follows your system appearance.</sub></p>

**Requirements:** macOS 13 (Ventura) or later.

---

## Install

There are two ways to install. Building from source works today; the Homebrew
route becomes available once the app is published to a tap (see
[Releasing](#releasing-for-maintainers)).

### Option A — Build from source

You need [Xcode](https://apps.apple.com/app/xcode/id497799835) and
[XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen

git clone https://github.com/4rek/markdown-previewer.git
cd markdown-previewer
./scripts/install.sh
```

`install.sh` builds the app, installs it into **/Applications**, refreshes Quick
Look, and launches it. Then continue to [Enable it](#enable-it).

> Prefer a distributable disk image instead? Run `./scripts/build.sh` to produce
> `dist/MarkdownPreviewer.dmg` and install it by hand.

### Option B — Homebrew *(once published)*

```sh
brew install --cask 4rek/tap/markdown-previewer
```

Homebrew installs the app and clears the download quarantine for you. Then
continue to [Enable it](#enable-it).

### Option C — Direct download *(once published)*

1. Download `MarkdownPreviewer.dmg` from the [latest release](https://github.com/4rek/markdown-previewer/releases/latest).
2. Drag **Markdown Previewer** into **Applications**.

---

## Enable it

macOS ships previews turned off until you enable them. One-time setup:

1. **Launch “Markdown Previewer”** once (this registers the extension). Its
   welcome window has a button that jumps straight to the right settings pane.
2. Open **System Settings → General → Login Items & Extensions → Quick Look**
   and turn on **Markdown Previewer**.
3. That's it.

> **First launch on a from-source / direct-download build:** because these
> builds are ad-hoc signed (not Apple-notarized — see
> [Notarization](#upgrading-to-notarization)), macOS may say *“Markdown
> Previewer can't be opened because Apple cannot check it.”* Open **System
> Settings → Privacy & Security**, scroll down, and click **Open Anyway** — once.
> Homebrew installs skip this.

---

## Use

Select any `.md` (or `.markdown`, `.mdown`, `.mkd`, …) file in Finder and press
<kbd>Space</kbd>. The preview appears instantly, fully rendered. Press
<kbd>Space</kbd> again to dismiss it.

Supported Markdown (GitHub-flavored):

Headings · paragraphs · **bold** / *italic* / ~~strikethrough~~ · `inline code` ·
fenced code blocks · blockquotes · ordered / unordered / nested lists · task
lists · GFM tables (with column alignment) · links · images · horizontal rules ·
raw HTML.

Two ready-made sample files live in [`examples/`](examples/) if you want to see
it in action.

### It maintains itself

You should never need Terminal. Each time the app launches it registers itself,
removes any stale duplicate registrations (e.g. an old copy left in Downloads),
and refreshes Quick Look's cache so the latest version is always what you see.
There's also a **Refresh Preview Cache** button in the app window if a preview
ever looks stale.

---

## Update

### If you installed with Homebrew

```sh
brew upgrade --cask markdown-previewer
```

### If you built from source

```sh
cd markdown-previewer
git pull
./scripts/install.sh
```

That's the whole update: `install.sh` rebuilds, replaces the copy in
**/Applications**, refreshes Quick Look, and relaunches — no dragging, no
re-enabling. The new version takes effect immediately.

> If a preview still looks stale (rare), click **Refresh Preview Cache** in the
> app, or run `qlmanage -r && qlmanage -r cache`.

---

## Uninstall

- **Homebrew:** `brew uninstall --cask markdown-previewer`
- **Manual:** run [`scripts/uninstall.sh`](scripts/uninstall.sh), or drag
  **Markdown Previewer** from Applications to the Trash and run `qlmanage -r`.

---

## How it works

The extension is a **data-based Quick Look provider**
([`QLPreviewProvider`](https://developer.apple.com/documentation/quicklookui/qlpreviewprovider)):
it converts the Markdown to HTML using
[apple/swift-markdown](https://github.com/apple/swift-markdown) and hands that
HTML to Quick Look, which renders it. This is what makes previews appear
instantly — the extension never hosts its own web view.

The preview **extension** runs fully inside the **App Sandbox** (it processes
untrusted file content). The small **container app** runs *outside* the sandbox
so it can maintain Quick Look on your behalf (refresh the cache, prune duplicate
registrations) via `qlmanage`/`lsregister`. If the app were ever submitted to the
Mac App Store it would need to be re-sandboxed, dropping the automatic
maintenance in favor of manual cache refreshes.

---

## Development

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
| `Sources/App/` | Tiny SwiftUI container app + onboarding. Registers and enables the extension. |
| `Sources/App/QuickLookMaintenance.swift` | Self-heal on launch: register, prune duplicates, refresh Quick Look. |
| `Sources/QuickLookExtension/PreviewProvider.swift` | The data-based `QLPreviewProvider` that returns rendered HTML to Quick Look. |
| `Sources/QuickLookExtension/MarkdownHTMLRenderer.swift` | Markdown AST → HTML (a small `MarkupVisitor`). |
| `Sources/QuickLookExtension/HTMLTemplate.swift` | Inline CSS page wrapper (light/dark). |
| `Sources/QuickLookExtension/Info.plist` | Declares the `.md` UTIs and `QLIsDataBasedPreview`. |
| `Tests/` | Renderer unit tests. |
| `scripts/install.sh` | Build and install/update into /Applications, then activate Quick Look. |
| `scripts/build.sh` | Builds the ad-hoc-signed DMG for distribution. |
| `scripts/uninstall.sh` | Manual uninstall: remove app, unregister, refresh Quick Look. |
| `Casks/` | Homebrew Cask template. |
| `examples/` | Sample Markdown files. |

---

## Releasing *(for maintainers)*

1. Bump `MARKETING_VERSION` in `project.yml` and `version` in `Casks/markdown-previewer.rb`.
2. Push a tag: `git tag v1.0.0 && git push --tags`.
3. The [release workflow](.github/workflows/release.yml) builds the DMG and
   attaches it to a GitHub Release.
4. Copy the printed `sha256` into the cask and commit it to your tap repo
   (`4rek/homebrew-tap`).

### Upgrading to notarization

The frictionless install path is Apple notarization (needs the **Apple Developer
Program**, $99/yr). When you're ready:

1. In `project.yml`, set `DEVELOPMENT_TEAM` and change `CODE_SIGN_IDENTITY` to
   `"Developer ID Application"`.
2. Add `notarytool` submission + `stapler` stapling to `scripts/build.sh`.
3. Drop the quarantine-stripping `postflight` block from the cask.

No app code changes are needed — the “unidentified developer” warning disappears.

---

## License

[MIT](LICENSE) — use it however you like.
