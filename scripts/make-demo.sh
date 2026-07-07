#!/usr/bin/env bash
#
# Turn a screen recording into an optimized demo GIF at docs/demo.gif.
#
# 1. Record with macOS: press Cmd+Shift+5, choose "Record Selected Portion",
#    drag a box around your Finder window, and capture the Space-to-preview flow.
#    A .mov lands on your Desktop.
# 2. Run:  ./scripts/make-demo.sh ~/Desktop/Screen\ Recording*.mov
#
# Optional args: ./scripts/make-demo.sh <recording> [width_px] [fps]
#
set -euo pipefail

IN="${1:?usage: make-demo.sh <recording.mov> [width_px] [fps]}"
WIDTH="${2:-960}"
FPS="${3:-15}"
OUT="docs/demo.gif"

command -v ffmpeg >/dev/null || { echo "error: ffmpeg not found — brew install ffmpeg" >&2; exit 1; }
command -v gifski >/dev/null || { echo "error: gifski not found — brew install gifski" >&2; exit 1; }
[ -f "$IN" ] || { echo "error: no such file: $IN" >&2; exit 1; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p docs

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Extracting frames (${FPS} fps, ${WIDTH}px wide)"
ffmpeg -y -i "$IN" -vf "fps=${FPS},scale=${WIDTH}:-1:flags=lanczos" "$TMP/f%05d.png" >/dev/null 2>&1

echo "==> Encoding GIF with gifski"
gifski --fps "$FPS" --quality 90 -o "$OUT" "$TMP"/f*.png

echo "==> Done: $OUT ($(du -h "$OUT" | cut -f1))"
echo "    If it's too large (>10 MB), re-run with a smaller width, e.g.:"
echo "    ./scripts/make-demo.sh \"$IN\" 800 12"
