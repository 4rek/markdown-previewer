# Reference copy of the cask. The live version users install from lives in the
# tap repo: https://github.com/4rek/homebrew-tap (Casks/markdown-previewer.rb).
# On each release, bump `version` + `sha256` (checksum of the release DMG) in
# BOTH places.
cask "markdown-previewer" do
  version "1.0.0"
  sha256 "89c76df8ed8ab2b36a40f5e8ad4d307f61bc9788d399600c488f8bde85547620"

  url "https://github.com/4rek/markdown-previewer/releases/download/v#{version}/MarkdownPreviewer.dmg"
  name "Markdown Previewer"
  desc "Quick Look extension that renders Markdown files with GitHub-style formatting"
  homepage "https://github.com/4rek/markdown-previewer"

  depends_on macos: :ventura

  app "Markdown Previewer.app"

  postflight do
    # Ad-hoc signed (not yet notarized): strip quarantine so users don't hit the
    # "unidentified developer" wall.
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Markdown Previewer.app"]

    # Activate the extension immediately by refreshing Quick Look's cache.
    system_command "/usr/bin/qlmanage", args: ["-r"]
    system_command "/usr/bin/qlmanage", args: ["-r", "cache"]
  end

  uninstall_postflight do
    system_command "/usr/bin/qlmanage", args: ["-r"]
  end

  uninstall quit: "com.apjuszczyk.markdownpreviewer"

  zap trash: "~/Library/Preferences/com.apjuszczyk.markdownpreviewer.plist"
end
