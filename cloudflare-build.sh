#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
WORK="$ROOT/.cf-build"
OUTPUT="$ROOT/dist"
BASE="$ROOT/releases/project-sovereign-v0.2.0-source.zip"
PATCH="$WORK/project-sovereign-v0.3.0-runtime-patch.zip"

printf 'PROJECT SOVEREIGN Cloudflare build v0.3.0\n'
printf 'Repository commit: %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

rm -rf "$WORK" "$OUTPUT"
mkdir -p "$WORK"

# Validate and extract the known-good v0.2 base archive.
unzip -tqq "$BASE"
unzip -q "$BASE" -d "$WORK"

# Reconstruct the v0.3 patch from Git-tracked Base64 text chunks.
# A ZIP byte checksum is intentionally not fixed here: ZIP metadata such as file
# timestamps can change the archive SHA even when all extracted files are identical.
shopt -s nullglob
PATCH_PARTS=("$ROOT"/releases/v0.3/runtime-patch.b64.part-*)
if (( ${#PATCH_PARTS[@]} == 0 )); then
  echo 'ERROR: v0.3 runtime patch chunks were not found.' >&2
  exit 1
fi

printf 'Runtime patch chunks: %s\n' "${#PATCH_PARTS[@]}"
cat "${PATCH_PARTS[@]}" | tr -d '\r\n\t ' | base64 --decode > "$PATCH"
printf 'Runtime patch SHA-256: %s\n' "$(sha256sum "$PATCH" | awk '{print $1}')"

# Verify the reconstructed archive itself and the files required by this release.
unzip -tqq "$PATCH"
PATCH_ENTRIES="$(unzip -Z1 "$PATCH")"
for required in \
  'project-sovereign/package.json' \
  'project-sovereign/src/ui/main.ts' \
  'project-sovereign/src/ui/portraits.ts'; do
  if ! grep -Fxq "$required" <<< "$PATCH_ENTRIES"; then
    echo "ERROR: runtime patch is missing $required" >&2
    exit 1
  fi
done

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
test -f "$OUTPUT/src/ui/main.js"
grep -q '遊び方' "$OUTPUT/src/ui/main.js"
printf 'Deployment output verified: %s files, no _redirects.\n' "$(find "$OUTPUT" -type f | wc -l | tr -d ' ')"
