# Homebrew Cask template.
#
# Publish this in your own tap repo (e.g. `4rek/homebrew-tap`) so users can:
#   brew install --cask 4rek/tap/markdown-previewer
#
# Bump the version and sha256 (printed by scripts/build.sh) on each release.
cask "markdown-previewer" do
  version "1.0.0"
  sha256 "REPLACE_WITH_DMG_SHA256"

  url "https://github.com/4rek/markdown-previewer/releases/download/v#{version}/MarkdownPreviewer.dmg"
  name "Markdown Previewer"
  desc "Quick Look extension that renders Markdown files with GitHub-style formatting"
  homepage "https://github.com/4rek/markdown-previewer"

  depends_on macos: ">= :ventura"

  app "Markdown Previewer.app"

  postflight do
    # This build is ad-hoc signed (no Apple notarization yet), so macOS marks it
    # as quarantined. Strip that flag so users don't hit the "unidentified
    # developer" wall. Remove this line once the app is notarized.
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Markdown Previewer.app"]

    # Activate the extension immediately: refresh Quick Look's cache so the new
    # (or updated) previewer takes effect without a re-login.
    system_command "/usr/bin/qlmanage", args: ["-r"]
    system_command "/usr/bin/qlmanage", args: ["-r", "cache"]
  end

  uninstall quit: "com.apjuszczyk.markdownpreviewer"

  # Clean up Quick Look's cache after removal too.
  uninstall_postflight do
    system_command "/usr/bin/qlmanage", args: ["-r"]
  end

  zap trash: [
    "~/Library/Preferences/com.apjuszczyk.markdownpreviewer.plist",
  ]
end
