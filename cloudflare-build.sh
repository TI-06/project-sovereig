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

cd "$ROOT"
V04_PARTS=("$ROOT"/releases/v0.4/v04.patch.xz.b64.part-*)
if (( ${#V04_PARTS[@]} != 7 )); then
  echo "ERROR: expected 7 v0.4 patch files, found ${#V04_PARTS[@]}." >&2
  exit 1
fi
printf 'v0.4 patch parts: %s\n' "${#V04_PARTS[@]}"
cat "${V04_PARTS[@]}" | tr -d '\r\n\t ' > "$V04_BASE64"
printf 'v0.4 Base64 bytes: %s\n' "$(wc -c < "$V04_BASE64" | tr -d ' ')"

if ! base64 --decode "$V04_BASE64" > "$V04_XZ"; then
  echo 'ERROR: v0.4 patch Base64 decoding failed.' >&2
  exit 1
fi
printf 'v0.4 compressed patch bytes: %s\n' "$(wc -c < "$V04_XZ" | tr -d ' ')"

if ! xz -t "$V04_XZ"; then
  echo 'ERROR: v0.4 compressed patch integrity check failed.' >&2
  exit 1
fi
if ! xz -dc "$V04_XZ" > "$V04_PATCH"; then
  echo 'ERROR: v0.4 patch decompression failed.' >&2
  exit 1
fi
printf 'v0.4 text patch bytes: %s\n' "$(wc -c < "$V04_PATCH" | tr -d ' ')"

cd "$PROJECT"
if ! git apply --check "$V04_PATCH"; then
  echo 'ERROR: v0.4 patch does not apply to reconstructed v0.3 source.' >&2
  exit 1
fi
git apply "$V04_PATCH"
echo 'v0.4 patch applied.'

for required in \
  src/gameplay/policy-guidance.ts \
  src/gameplay/crisis-director.ts \
  src/gameplay/turn-debrief.ts \
  src/gameplay/choice-events.ts \
  src/ui/main.ts \
  src/ui/visual-language.ts; do
  if [[ ! -f "$required" ]]; then
    echo "ERROR: required v0.4 source file is missing: $required" >&2
    exit 1
  fi
done
if [[ -f public/_redirects ]]; then
  echo 'ERROR: public/_redirects remains after applying v0.4.' >&2
  exit 1
fi
echo 'v0.4 source structure verified.'

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
