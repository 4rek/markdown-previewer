#!/usr/bin/env bash
#
# Build an ad-hoc-signed "Markdown Previewer.app" and package it into a
# drag-to-install DMG under ./dist. No Apple Developer account required.
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP_NAME="Markdown Previewer"
CONFIG="Release"
DERIVED="$ROOT/build"
DIST="$ROOT/dist"
STAGING="$DIST/staging"

command -v xcodegen >/dev/null 2>&1 || { echo "error: xcodegen not found — run: brew install xcodegen" >&2; exit 1; }

echo "==> Generating Xcode project"
xcodegen generate

echo "==> Building ($CONFIG)"
rm -rf "$DERIVED" "$DIST"
xcodebuild \
  -project MarkdownPreviewer.xcodeproj \
  -scheme MarkdownPreviewer \
  -configuration "$CONFIG" \
  -derivedDataPath "$DERIVED" \
  clean build

APP="$DERIVED/Build/Products/$CONFIG/$APP_NAME.app"
[ -d "$APP" ] || { echo "error: build product not found at $APP" >&2; exit 1; }

echo "==> Packaging DMG"
mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$STAGING" \
  -ov -format UDZO \
  "$DIST/MarkdownPreviewer.dmg" >/dev/null
rm -rf "$STAGING"

# xcodebuild auto-registers the freshly built .app with LaunchServices, which
# makes a *second* Quick Look extension appear alongside any copy installed in
# /Applications. Un-register the build-folder copy so it doesn't pollute the
# system extensions list — the DMG is the only artifact we care about here.
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"
[ -x "$LSREGISTER" ] && "$LSREGISTER" -u "$APP" >/dev/null 2>&1 || true

echo "==> Done: $DIST/MarkdownPreviewer.dmg"
echo -n "    sha256: "
shasum -a 256 "$DIST/MarkdownPreviewer.dmg" | awk '{print $1}'
