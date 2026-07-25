#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
WORK="$ROOT/.cf-build"
OUTPUT="$ROOT/dist"
BASE="$ROOT/releases/project-sovereign-v0.2.0-source.zip"
V03_PATCH="$WORK/guided-gameplay-v0.3.patch"
V04_BASE64="$WORK/project-sovereign-v0.4.0.patch.xz.b64"
V04_XZ="$WORK/project-sovereign-v0.4.0.patch.xz"
V04_PATCH="$WORK/project-sovereign-v0.4.0.patch"

printf 'PROJECT SOVEREIGN Cloudflare build v0.4.0\n'
printf 'Repository commit: %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

rm -rf "$WORK" "$OUTPUT"
mkdir -p "$WORK"

# Rebuild the verified v0.3 source from the v0.2 base and line-safe text patch.
unzip -tqq "$BASE"
unzip -q "$BASE" -d "$WORK"
PROJECT="$WORK/project-sovereign"
test -f "$PROJECT/package.json"

shopt -s nullglob
V03_PARTS=("$ROOT"/releases/v0.3/guided-gameplay-v2.patch.part-*)
if (( ${#V03_PARTS[@]} != 6 )); then
  echo "ERROR: expected 6 v0.3 patch files, found ${#V03_PARTS[@]}." >&2
  exit 1
fi
cat "${V03_PARTS[@]}" > "$V03_PATCH"

cd "$PROJECT"
patch --batch --forward -p1 < "$V03_PATCH"

# Apply the verified v0.4 text patch. No fixed SHA value is used.
cd "$ROOT"
V04_PARTS=("$ROOT"/releases/v0.4/v04.patch.xz.b64.part-*)
if (( ${#V04_PARTS[@]} != 7 )); then
  echo "ERROR: expected 7 v0.4 patch files, found ${#V04_PARTS[@]}." >&2
  exit 1
fi
printf 'v0.4 patch parts: %s\n' "${#V04_PARTS[@]}"
cat "${V04_PARTS[@]}" > "$V04_BASE64"
base64 --decode "$V04_BASE64" > "$V04_XZ"
xz -t "$V04_XZ"
xz -dc "$V04_XZ" > "$V04_PATCH"

cd "$PROJECT"
git apply --check "$V04_PATCH"
git apply "$V04_PATCH"

test -f src/gameplay/policy-guidance.ts
test -f src/gameplay/crisis-director.ts
test -f src/gameplay/turn-debrief.ts
test -f src/gameplay/choice-events.ts
test -f src/ui/gameplay-views.ts
test ! -f public/_redirects

npm install --no-audit --no-fund
npm run verify

cd "$ROOT"
cp -a "$PROJECT/dist" "$OUTPUT"
rm -f "$OUTPUT/_redirects"
printf '_redirects\n' > "$OUTPUT/.assetsignore"

test -f "$OUTPUT/index.html"
test -f "$OUTPUT/src/ui/main.js"
grep -q '国家危機センター' "$OUTPUT/src/ui/main.js"
grep -q '政策パッケージ' "$OUTPUT/src/ui/main.js"
grep -q '国家選択イベント' "$OUTPUT/src/ui/main.js"
grep -q '遊び方・用語・詰まったとき' "$OUTPUT/src/ui/main.js"

if find "$OUTPUT" -type f -name '_redirects' -print -quit | grep -q .; then
  echo 'ERROR: _redirects still exists in deployment output.' >&2
  exit 1
fi

printf 'Deployment output verified: %s files; v0.4 tests and build passed.\n' "$(find "$OUTPUT" -type f | wc -l | tr -d ' ')"
