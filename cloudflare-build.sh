#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
WORK="$ROOT/.cf-build"
OUTPUT="$ROOT/dist"
BASE="$ROOT/releases/project-sovereign-v0.2.0-source.zip"
TEXT_PATCH="$WORK/guided-gameplay-v0.3.patch"

printf 'PROJECT SOVEREIGN Cloudflare build v0.3.0-text-patch\n'
printf 'Repository commit: %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

rm -rf "$WORK" "$OUTPUT"
mkdir -p "$WORK"

# The v0.2 base archive is the previously verified source that already built
# successfully on Cloudflare. v0.3 itself is applied as ordinary Git-tracked text,
# so there is no Base64 decoding, runtime ZIP reconstruction, CRC or SHA check.
unzip -tqq "$BASE"
unzip -q "$BASE" -d "$WORK"
PROJECT="$WORK/project-sovereign"
test -f "$PROJECT/package.json"

shopt -s nullglob
PATCH_PARTS=("$ROOT"/releases/v0.3/guided-gameplay.patch.part-*)
if (( ${#PATCH_PARTS[@]} == 0 )); then
  echo 'ERROR: guided gameplay text patch files were not found.' >&2
  exit 1
fi
printf 'Guided gameplay text patch parts: %s\n' "${#PATCH_PARTS[@]}"
cat "${PATCH_PARTS[@]}" > "$TEXT_PATCH"

cd "$PROJECT"
patch --batch --forward -p1 < "$TEXT_PATCH"

test -f src/domain/command-planning.ts
test -f src/ui/guidance.ts
test -f src/ui/portraits.ts
test ! -f public/_redirects

npm install --no-audit --no-fund
npm run verify

cd "$ROOT"
cp -a "$PROJECT/dist" "$OUTPUT"
rm -f "$OUTPUT/_redirects"
printf '_redirects\n' > "$OUTPUT/.assetsignore"

test -f "$OUTPUT/index.html"
test -f "$OUTPUT/src/ui/main.js"
grep -q '初心者ミッション' "$OUTPUT/src/ui/main.js"
grep -q '遊び方・用語・詰まったとき' "$OUTPUT/src/ui/main.js"
grep -q '未確定命令' "$OUTPUT/src/ui/main.js"

if find "$OUTPUT" -type f -name '_redirects' -print -quit | grep -q .; then
  echo 'ERROR: _redirects still exists in deployment output.' >&2
  exit 1
fi

printf 'Deployment output verified: %s files, no reconstructed v0.3 archive.\n' "$(find "$OUTPUT" -type f | wc -l | tr -d ' ')"
