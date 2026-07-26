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
V04_APPLY_PATCH="$WORK/project-sovereign-v0.4.0.apply.patch"
V05_XZ="$WORK/project-sovereign-v0.5.0.patch.xz"
V05_PATCH="$WORK/project-sovereign-v0.5.0.patch"
V05_APPLY_PATCH="$WORK/project-sovereign-v0.5.0.apply.patch"
V06_XZ="$WORK/project-sovereign-v0.6.0.patch.xz"
V06_PATCH="$WORK/project-sovereign-v0.6.0.patch"
V06_APPLY_PATCH="$WORK/project-sovereign-v0.6.0.apply.patch"
V061_XZ="$WORK/project-sovereign-v0.6.1-hotfix.patch.xz"
V061_PATCH="$WORK/project-sovereign-v0.6.1-hotfix.patch"

printf 'PROJECT SOVEREIGN Cloudflare build v0.6.1\n'
printf 'Repository commit: %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

rm -rf "$WORK" "$OUTPUT"
mkdir -p "$WORK"
unzip -tqq "$BASE"
unzip -q "$BASE" -d "$WORK"
PROJECT="$WORK/project-sovereign"
test -f "$PROJECT/package.json"

# Reconstruct the verified v0.3 source.
shopt -s nullglob
V03_PARTS=("$ROOT"/releases/v0.3/guided-gameplay-v2.patch.part-*)
if (( ${#V03_PARTS[@]} != 6 )); then
  echo "ERROR: expected 6 v0.3 patch files, found ${#V03_PARTS[@]}." >&2
  exit 1
fi
cat "${V03_PARTS[@]}" > "$V03_PATCH"
cd "$PROJECT"
patch --batch --forward -p1 < "$V03_PATCH"

# Reconstruct and apply the verified v0.4 patch.
cd "$ROOT"
V04_PARTS=("$ROOT"/releases/v0.4/v04.patch.xz.b64.part-*)
if (( ${#V04_PARTS[@]} != 7 )); then
  echo "ERROR: expected 7 v0.4 patch files, found ${#V04_PARTS[@]}." >&2
  exit 1
fi
printf 'v0.4 patch parts: %s\n' "${#V04_PARTS[@]}"
cat "${V04_PARTS[@]}" | tr -d '\r\n\t ' > "$V04_BASE64"
base64 --decode "$V04_BASE64" > "$V04_XZ"
xz -t "$V04_XZ"
xz -dc "$V04_XZ" > "$V04_PATCH"
awk '
/^diff --git / { skip = ($0 == "diff --git a/package-lock.json b/package-lock.json") }
!skip { print }
' "$V04_PATCH" > "$V04_APPLY_PATCH"
cd "$PROJECT"
patch --batch --forward --dry-run -p1 < "$V04_APPLY_PATCH" >/dev/null
patch --batch --forward -p1 < "$V04_APPLY_PATCH"
echo 'v0.4 patch applied.'

# Reconstruct and apply the verified v0.5 patch.
cd "$ROOT"
V05_PARTS=("$ROOT"/releases/v0.5/chunks/part-*.bin)
if (( ${#V05_PARTS[@]} != 8 )); then
  echo "ERROR: expected 8 v0.5 binary chunks, found ${#V05_PARTS[@]}." >&2
  exit 1
fi
printf 'v0.5 binary chunks: %s\n' "${#V05_PARTS[@]}"
cat "${V05_PARTS[@]}" > "$V05_XZ"
xz -t "$V05_XZ"
xz -dc "$V05_XZ" > "$V05_PATCH"
awk '
/^diff --git / { skip = ($0 == "diff --git a/package-lock.json b/package-lock.json") }
!skip { print }
' "$V05_PATCH" > "$V05_APPLY_PATCH"
cd "$PROJECT"
patch --batch --forward --dry-run -p1 < "$V05_APPLY_PATCH" >/dev/null
patch --batch --forward -p1 < "$V05_APPLY_PATCH"
echo 'v0.5 patch applied.'

# Reconstruct and apply the verified v0.6 playability and UX patch.
cd "$ROOT"
V06_PARTS=("$ROOT"/releases/v0.6/chunks/part-*.bin)
if (( ${#V06_PARTS[@]} != 12 )); then
  echo "ERROR: expected 12 v0.6 binary chunks, found ${#V06_PARTS[@]}." >&2
  exit 1
fi
printf 'v0.6 binary chunks: %s\n' "${#V06_PARTS[@]}"
cat "${V06_PARTS[@]}" > "$V06_XZ"
printf 'v0.6 compressed patch bytes: %s\n' "$(wc -c < "$V06_XZ" | tr -d ' ')"
xz -t "$V06_XZ"
xz -dc "$V06_XZ" > "$V06_PATCH"
printf 'v0.6 text patch bytes: %s\n' "$(wc -c < "$V06_PATCH" | tr -d ' ')"
awk '
/^diff --git / { skip = ($0 == "diff --git a/package-lock.json b/package-lock.json") }
!skip { print }
' "$V06_PATCH" > "$V06_APPLY_PATCH"
cd "$PROJECT"
patch --batch --forward --dry-run -p1 < "$V06_APPLY_PATCH" >/dev/null
patch --batch --forward -p1 < "$V06_APPLY_PATCH"
echo 'v0.6 patch applied.'

# Apply the verified v0.6.1 opportunity event hotfix.
cd "$ROOT"
V061_PARTS=("$ROOT"/releases/v0.6.1/chunks/part-*.bin)
if (( ${#V061_PARTS[@]} != 2 )); then
  echo "ERROR: expected 2 v0.6.1 hotfix chunks, found ${#V061_PARTS[@]}." >&2
  exit 1
fi
printf 'v0.6.1 hotfix chunks: %s\n' "${#V061_PARTS[@]}"
cat "${V061_PARTS[@]}" > "$V061_XZ"
printf 'v0.6.1 compressed patch bytes: %s\n' "$(wc -c < "$V061_XZ" | tr -d ' ')"
xz -t "$V061_XZ"
xz -dc "$V061_XZ" > "$V061_PATCH"
printf 'v0.6.1 text patch bytes: %s\n' "$(wc -c < "$V061_PATCH" | tr -d ' ')"
cd "$PROJECT"
patch --batch --forward --dry-run -p1 < "$V061_PATCH" >/dev/null
patch --batch --forward -p1 < "$V061_PATCH"
echo 'v0.6.1 hotfix applied.'

node -e "const p=require('./package.json'); if(p.version!=='0.6.1') { console.error('Unexpected package version:', p.version); process.exit(1); }"
if [[ -f public/_redirects ]]; then
  echo 'ERROR: public/_redirects remains after applying v0.6.1.' >&2
  exit 1
fi

npm install --no-audit --no-fund
npm run verify

cd "$ROOT"
cp -a "$PROJECT/dist" "$OUTPUT"
rm -f "$OUTPUT/_redirects"
printf '_redirects\n' > "$OUTPUT/.assetsignore"

test -f "$OUTPUT/index.html"
test -f "$OUTPUT/src/ui/main.js"
for marker in \
  '指令室' \
  '国家方針' \
  '危機・イベント' \
  '国家プロジェクト' \
  '国家分析' \
  '国家年表' \
  '今月あなたが決めたこと' \
  '次にやること' \
  '選択済み・次ターンで実行' \
  '別のイベントも同時に選択できます'; do
  if ! grep -R -q -- "$marker" "$OUTPUT"; then
    echo "ERROR: v0.6.1 deployment marker is missing: $marker" >&2
    exit 1
  fi
done

if find "$OUTPUT" -type f -name '_redirects' -print -quit | grep -q .; then
  echo 'ERROR: _redirects still exists in deployment output.' >&2
  exit 1
fi

printf 'Deployment output verified: %s files; v0.6.1 tests and build passed.\n' "$(find "$OUTPUT" -type f | wc -l | tr -d ' ')"
