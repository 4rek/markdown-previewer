# Homebrew Cask template.
#
# Publish this in your own tap repo (e.g. `OWNER/homebrew-tap`) so users can:
#   brew install --cask OWNER/tap/markdown-previewer
#
# Replace OWNER and the sha256 (printed by scripts/build.sh) on each release.
cask "markdown-previewer" do
  version "1.0.0"
  sha256 "REPLACE_WITH_DMG_SHA256"

  url "https://github.com/OWNER/markdown-previewer/releases/download/v#{version}/MarkdownPreviewer.dmg"
  name "Markdown Previewer"
  desc "Quick Look extension that renders Markdown files with GitHub-style formatting"
  homepage "https://github.com/OWNER/markdown-previewer"

  depends_on macos: ">= :ventura"

  app "Markdown Previewer.app"

  # This build is ad-hoc signed (no Apple notarization yet), so macOS marks it
  # as quarantined. Strip that flag on install so users don't hit the
  # "unidentified developer" wall. Remove this block once the app is notarized.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Markdown Previewer.app"]
  end

  zap trash: [
    "~/Library/Preferences/com.apjuszczyk.markdownpreviewer.plist",
  ]
end
