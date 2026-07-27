#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
WORK="$ROOT/.cf-build"
OUTPUT="$ROOT/dist"
PROJECT="$WORK/project-sovereign"
V073_BASE64="$WORK/project-sovereign-v0.7.3.patch.xz.b64"
V073_XZ="$WORK/project-sovereign-v0.7.3.patch.xz"
V073_PATCH="$WORK/project-sovereign-v0.7.3.patch"
V073_APPLY_PATCH="$WORK/project-sovereign-v0.7.3.apply.patch"

printf 'PROJECT SOVEREIGN Cloudflare build v0.7.3\n'
printf 'Repository commit: %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

# Preserve and run the exact verified v0.7.0 reconstruction first.
bash "$ROOT/scripts/cloudflare-build-v070.sh"

test -d "$PROJECT"
test -f "$PROJECT/package.json"

# Reconstruct and apply the verified v0.7.3 command room, map, and war room update.
cd "$ROOT"
shopt -s nullglob
V073_PARTS=("$ROOT"/releases/v0.7.3/chunks/part-*.b64)
if (( ${#V073_PARTS[@]} != 6 )); then
  echo "ERROR: expected 6 v0.7.3 base64 chunks, found ${#V073_PARTS[@]}." >&2
  exit 1
fi
printf 'v0.7.3 base64 chunks: %s\n' "${#V073_PARTS[@]}"
cat "${V073_PARTS[@]}" | tr -d '\r\n\t ' > "$V073_BASE64"
printf 'v0.7.3 base64 bytes: %s\n' "$(wc -c < "$V073_BASE64" | tr -d ' ')"
printf '%s  %s\n' '6269791294708031ffdc57d56650d624692ab98e31359af8d52d3031f819f9d3' "$V073_BASE64" | sha256sum --check --status
base64 --decode "$V073_BASE64" > "$V073_XZ"
printf '%s  %s\n' 'dd637fc19844654fc046cfa6c3d3c485a6aeb6edcc7db2b6c31747111ee190b8' "$V073_XZ" | sha256sum --check --status
xz -t "$V073_XZ"
xz -dc "$V073_XZ" > "$V073_PATCH"
printf 'v0.7.3 text patch bytes: %s\n' "$(wc -c < "$V073_PATCH" | tr -d ' ')"
printf '%s  %s\n' '7fde03adec6c98d3e14af9de0cd928e59c0903f67ced1c2fd7904e4c4c56d0ae' "$V073_PATCH" | sha256sum --check --status
awk '
/^diff --git / { skip = ($0 == "diff --git a/package-lock.json b/package-lock.json") }
!skip { print }
' "$V073_PATCH" > "$V073_APPLY_PATCH"
cd "$PROJECT"
patch --batch --forward --dry-run -p1 < "$V073_APPLY_PATCH" >/dev/null
patch --batch --forward -p1 < "$V073_APPLY_PATCH"
echo 'v0.7.3 command room, national map, and war room update applied.'

node -e "const p=require('./package.json'); if(p.version!=='0.7.3') { console.error('Unexpected package version:', p.version); process.exit(1); }"
if [[ -f public/_redirects ]]; then
  echo 'ERROR: public/_redirects remains after applying v0.7.3.' >&2
  exit 1
fi

npm run verify

cd "$ROOT"
rm -rf "$OUTPUT"
cp -a "$PROJECT/dist" "$OUTPUT"
rm -f "$OUTPUT/_redirects"
printf '_redirects\n' > "$OUTPUT/.assetsignore"

test -f "$OUTPUT/index.html"
test -f "$OUTPUT/src/ui/main.js"
test -f "$OUTPUT/src/ui/command-center-view.js"
test -f "$OUTPUT/src/gameplay/monthly-priorities.js"
test -f "$OUTPUT/src/gameplay/secretary-proposals.js"
test -f "$OUTPUT/src/gameplay/regional-status.js"
test -f "$OUTPUT/src/gameplay/war-operations.js"
test -f "$OUTPUT/src/ui/national-map-view.js"
test -f "$OUTPUT/src/ui/region-inspector.js"
test -f "$OUTPUT/src/ui/confirm-overlay.js"
test -f "$OUTPUT/src/ui/war-room-view.js"

for marker in \
  '国内状況マップ' \
  '今月の最重要案件' \
  '今月の提案' \
  '先月比' \
  '戦力温存' \
  '均衡作戦' \
  '突破作戦' \
  'PHASE 2・交戦中' \
  '地域被害' \
  '戦後権益' \
  '秘書官の提案と推奨命令'; do
  if ! grep -R -q -- "$marker" "$OUTPUT"; then
    echo "ERROR: v0.7.3 deployment marker is missing: $marker" >&2
    exit 1
  fi
done

if find "$OUTPUT" -type f -name '_redirects' -print -quit | grep -q .; then
  echo 'ERROR: _redirects still exists in deployment output.' >&2
  exit 1
fi

printf 'Deployment output verified: %s files; v0.7.3 tests and build passed.\n' "$(find "$OUTPUT" -type f | wc -l | tr -d ' ')"
