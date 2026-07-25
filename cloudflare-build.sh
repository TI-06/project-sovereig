#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
WORK="$ROOT/.cf-build"
OUTPUT="$ROOT/dist"
BASE="$ROOT/releases/project-sovereign-v0.2.0-source.zip"
PATCH="$WORK/project-sovereign-v0.3.0-runtime-patch.zip"
EXPECTED_PATCH_SHA="dc402f5ace0f95e10ac7733537813eb07e46116c4df9ad7ecb6840543a1ea53c"

printf 'PROJECT SOVEREIGN Cloudflare build v0.3.0\n'
printf 'Repository commit: %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

rm -rf "$WORK" "$OUTPUT"
mkdir -p "$WORK"

unzip -tqq "$BASE"
unzip -q "$BASE" -d "$WORK"

cat "$ROOT"/releases/v0.3/runtime-patch.b64.part-* | tr -d '\r\n' | base64 --decode > "$PATCH"
echo "$EXPECTED_PATCH_SHA  $PATCH" | sha256sum -c -
unzip -tqq "$PATCH"
unzip -qo "$PATCH" -d "$WORK"

PROJECT="$WORK/project-sovereign"
test -f "$PROJECT/package.json"
cd "$PROJECT"
npm install --no-audit --no-fund
npm run typecheck
npm run build

cd "$ROOT"
cp -a "$PROJECT/dist" "$OUTPUT"
find "$OUTPUT" -type f -name '_redirects' -print -delete
printf '_redirects\n' > "$OUTPUT/.assetsignore"

if find "$OUTPUT" -type f -name '_redirects' -print -quit | grep -q .; then
  echo 'ERROR: _redirects still exists in deployment output.' >&2
  exit 1
fi

test -f "$OUTPUT/index.html"
grep -q '遊び方' "$OUTPUT/src/ui/main.js"
printf 'Deployment output verified: %s files, no _redirects.\n' "$(find "$OUTPUT" -type f | wc -l | tr -d ' ')"
