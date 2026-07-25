#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
WORK="$ROOT/.cf-build"
OUTPUT="$ROOT/dist"
BASE="$ROOT/releases/project-sovereign-v0.2.0-source.zip"
TEXT_PATCH="$WORK/guided-gameplay-v0.3.patch"

printf 'PROJECT SOVEREIGN Cloudflare build v0.3.0-line-safe\n'
printf 'Repository commit: %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

rm -rf "$WORK" "$OUTPUT"
mkdir -p "$WORK"

# Use the v0.2 source that has already built successfully on Cloudflare.
# The v0.3 changes are ordinary UTF-8 text patch files: no SHA check,
# no Base64 decoding and no reconstructed v0.3 ZIP/CRC path.
unzip -tqq "$BASE"
unzip -q "$BASE" -d "$WORK"
PROJECT="$WORK/project-sovereign"
test -f "$PROJECT/package.json"

shopt -s nullglob
PATCH_PARTS=("$ROOT"/releases/v0.3/guided-gameplay-v2.patch.part-*)
if (( ${#PATCH_PARTS[@]} != 6 )); then
  echo "ERROR: expected 6 line-safe text patch files, found ${#PATCH_PARTS[@]}." >&2
  exit 1
fi
printf 'Line-safe guided gameplay patch parts: %s\n' "${#PATCH_PARTS[@]}"
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

printf 'Deployment output verified: %s files; v0.3 uses text only.\n' "$(find "$OUTPUT" -type f | wc -l | tr -d ' ')"
