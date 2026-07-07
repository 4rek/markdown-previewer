#!/usr/bin/env bash
#
# Cleanly remove a manually-installed Markdown Previewer: delete the app,
# unregister its Quick Look extension, and refresh Quick Look's cache.
# (Homebrew users should just run `brew uninstall --cask markdown-previewer`.)
#
set -euo pipefail

APP="/Applications/Markdown Previewer.app"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"

# Quit the app if it's running.
osascript -e 'quit app "Markdown Previewer"' >/dev/null 2>&1 || true

if [ -d "$APP" ]; then
  [ -x "$LSREGISTER" ] && "$LSREGISTER" -u "$APP" >/dev/null 2>&1 || true
  rm -rf "$APP"
  echo "Removed $APP"
else
  echo "Not found at $APP (nothing to remove)"
fi

# Refresh Quick Look so the previewer disappears cleanly.
qlmanage -r >/dev/null 2>&1 || true
qlmanage -r cache >/dev/null 2>&1 || true

echo "Done. Quick Look cache refreshed."
