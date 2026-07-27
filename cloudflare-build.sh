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
V062_XZ="$WORK/project-sovereign-v0.6.2-recovery-guidance.patch.xz"
V062_PATCH="$WORK/project-sovereign-v0.6.2-recovery-guidance.patch"
V062_APPLY_PATCH="$WORK/project-sovereign-v0.6.2-recovery-guidance.apply.patch"
V070_BASE64="$WORK/project-sovereign-v0.7.0.patch.xz.b64"
V070_XZ="$WORK/project-sovereign-v0.7.0.patch.xz"
V070_PATCH="$WORK/project-sovereign-v0.7.0.patch"
V070_APPLY_PATCH="$WORK/project-sovereign-v0.7.0.apply.patch"

printf 'PROJECT SOVEREIGN Cloudflare build v0.7.0\n'
printf 'Repository commit: %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

rm -rf "$WORK" "$OUTPUT"
mkdir -p "$WORK"
unzip -tqq "$BASE"
unzip -q "$BASE" -d "$WORK"
PROJECT="$WORK/project-sovereign"
test -f "$PROJECT/package.json"

shopt -s nullglob

# Reconstruct the verified v0.3 source.
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

# Apply the verified v0.6.2 recovery guidance patch.
cd "$ROOT"
V062_PARTS=("$ROOT"/releases/v0.6.2/chunks/part-*.bin)
if (( ${#V062_PARTS[@]} != 4 )); then
  echo "ERROR: expected 4 v0.6.2 recovery guidance chunks, found ${#V062_PARTS[@]}." >&2
  exit 1
fi
printf 'v0.6.2 recovery guidance chunks: %s\n' "${#V062_PARTS[@]}"
cat "${V062_PARTS[@]}" > "$V062_XZ"
printf 'v0.6.2 compressed patch bytes: %s\n' "$(wc -c < "$V062_XZ" | tr -d ' ')"
xz -t "$V062_XZ"
xz -dc "$V062_XZ" > "$V062_PATCH"
printf 'v0.6.2 text patch bytes: %s\n' "$(wc -c < "$V062_PATCH" | tr -d ' ')"
awk '
/^diff --git / { skip = ($0 == "diff --git a/package-lock.json b/package-lock.json") }
!skip { print }
' "$V062_PATCH" > "$V062_APPLY_PATCH"
cd "$PROJECT"
patch --batch --forward --dry-run -p1 < "$V062_APPLY_PATCH" >/dev/null
patch --batch --forward -p1 < "$V062_APPLY_PATCH"
echo 'v0.6.2 recovery guidance patch applied.'

# Reconstruct and apply the verified v0.7.0 political drama update.
cd "$ROOT"
V070_PARTS=("$ROOT"/releases/v0.7.0/chunks/part-*.b64)
if (( ${#V070_PARTS[@]} != 13 )); then
  echo "ERROR: expected 13 v0.7.0 base64 chunks, found ${#V070_PARTS[@]}." >&2
  exit 1
fi
printf 'v0.7.0 base64 chunks: %s\n' "${#V070_PARTS[@]}"
cat "${V070_PARTS[@]}" | tr -d '\r\n\t ' > "$V070_BASE64"
printf 'v0.7.0 base64 bytes: %s\n' "$(wc -c < "$V070_BASE64" | tr -d ' ')"
printf '%s  %s\n' 'f51d606c4ce01acc5bdf55b3e8a1231e223afefdb22a27aea03929a92047a7f3' "$V070_BASE64" | sha256sum --check --status
base64 --decode "$V070_BASE64" > "$V070_XZ"
printf '%s  %s\n' 'cf0abde792de623f970f84461e54e12a6cb9d3b1619857d21729fb363bdebea3' "$V070_XZ" | sha256sum --check --status
xz -t "$V070_XZ"
xz -dc "$V070_XZ" > "$V070_PATCH"
printf 'v0.7.0 text patch bytes: %s\n' "$(wc -c < "$V070_PATCH" | tr -d ' ')"
printf '%s  %s\n' 'ceac0db60670cfb187180a1419a2ddb7be69ac2bed18378faa3c6ae741a06686' "$V070_PATCH" | sha256sum --check --status
awk '
/^diff --git / { skip = ($0 == "diff --git a/package-lock.json b/package-lock.json") }
!skip { print }
' "$V070_PATCH" > "$V070_APPLY_PATCH"
cd "$PROJECT"
patch --batch --forward --dry-run -p1 < "$V070_APPLY_PATCH" >/dev/null
patch --batch --forward -p1 < "$V070_APPLY_PATCH"
echo 'v0.7.0 political drama update applied.'

node -e "const p=require('./package.json'); if(p.version!=='0.7.0') { console.error('Unexpected package version:', p.version); process.exit(1); }"
if [[ -f public/_redirects ]]; then
  echo 'ERROR: public/_redirects remains after applying v0.7.0.' >&2
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
test -f "$OUTPUT/src/ui/command-center-view.js"
test -f "$OUTPUT/src/ui/secretary-portraits.js"
test -f "$OUTPUT/src/narrative/secretaries.js"
test -f "$OUTPUT/src/narrative/survival.js"
test -f "$OUTPUT/src/narrative/war-outcomes.js"
test -f "$OUTPUT/src/narrative/endings.js"
test -f "$OUTPUT/src/ui/money.js"

for marker in \
  '政権を編成' \
  '国家目標' \
  '秘書官' \
  'カウント停止中' \
  '財政破綻' \
  '開戦目的' \
  '想定月額戦費' \
  '戦後権益' \
  '九条 澪' \
  '天城 ひなた' \
  '黒崎 蓮' \
  '億円' \
  '兆円'; do
  if ! grep -R -q -- "$marker" "$OUTPUT"; then
    echo "ERROR: v0.7.0 deployment marker is missing: $marker" >&2
    exit 1
  fi
done

if find "$OUTPUT" -type f -name '_redirects' -print -quit | grep -q .; then
  echo 'ERROR: _redirects still exists in deployment output.' >&2
  exit 1
fi

printf 'Deployment output verified: %s files; v0.7.0 tests and build passed.\n' "$(find "$OUTPUT" -type f | wc -l | tr -d ' ')"
