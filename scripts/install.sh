#!/usr/bin/env bash
#
# Build Markdown Previewer and install (or update) it into /Applications, then
# activate the Quick Look extension. Run this instead of dragging the app by hand
# — it handles replacing an existing copy, clearing quarantine, pruning the stale
# registration, and refreshing Quick Look.
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP_NAME="Markdown Previewer"
CONFIG="Release"
DERIVED="$ROOT/build"
BUILT_APP="$DERIVED/Build/Products/$CONFIG/$APP_NAME.app"
DEST="/Applications/$APP_NAME.app"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"

command -v xcodegen >/dev/null 2>&1 || { echo "error: xcodegen not found — run: brew install xcodegen" >&2; exit 1; }

echo "==> Generating project"
xcodegen generate >/dev/null

echo "==> Building ($CONFIG)"
mkdir -p "$DERIVED"
BUILD_LOG="$(mktemp)"
if ! xcodebuild -project MarkdownPreviewer.xcodeproj -scheme MarkdownPreviewer \
      -configuration "$CONFIG" -derivedDataPath "$DERIVED" build >"$BUILD_LOG" 2>&1; then
    echo "error: build failed" >&2
    tail -40 "$BUILD_LOG" >&2
    exit 1
fi
[ -d "$BUILT_APP" ] || { echo "error: build product not found at $BUILT_APP" >&2; exit 1; }

echo "==> Installing to /Applications (replacing any existing copy)"
osascript -e "quit app \"$APP_NAME\"" >/dev/null 2>&1 || true
rm -rf "$DEST"
cp -R "$BUILT_APP" "$DEST"
xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true

if [ -x "$LSREGISTER" ]; then
    "$LSREGISTER" -f "$DEST" >/dev/null 2>&1 || true
    # xcodebuild auto-registers the build-folder copy; drop it so it can't create
    # a duplicate Quick Look entry.
    "$LSREGISTER" -u "$BUILT_APP" >/dev/null 2>&1 || true
fi

echo "==> Refreshing Quick Look"
qlmanage -r >/dev/null 2>&1 || true
qlmanage -r cache >/dev/null 2>&1 || true

echo "==> Launching app (registers extension + runs self-maintenance)"
open "$DEST"

cat <<EOF

Installed: $DEST

If this is your FIRST install, enable the extension once:
  System Settings → General → Login Items & Extensions → Quick Look → Markdown Previewer

Then select a .md file in Finder and press Space. Updates need no re-enabling.
EOF
