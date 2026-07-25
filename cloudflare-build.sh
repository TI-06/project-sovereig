#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="2026-07-25.3"
REPO_ROOT="$(pwd)"
SOURCE_ARCHIVE="$REPO_ROOT/releases/project-sovereign-v0.2.0-source.zip"
WORK_DIR="$REPO_ROOT/.cf-build"
DECODED_ARCHIVE="$WORK_DIR/project-sovereign-source.zip"
OUTPUT_DIR="$REPO_ROOT/dist"

printf 'PROJECT SOVEREIGN Cloudflare build %s\n' "$SCRIPT_VERSION"
printf 'Repository commit: %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

rm -rf "$WORK_DIR" "$OUTPUT_DIR"
mkdir -p "$WORK_DIR"

# The archive can be a normal ZIP or Base64 text, depending on how it was uploaded.
if unzip -tqq "$SOURCE_ARCHIVE" >/dev/null 2>&1; then
  cp "$SOURCE_ARCHIVE" "$DECODED_ARCHIVE"
else
  base64 --decode "$SOURCE_ARCHIVE" > "$DECODED_ARCHIVE"
  unzip -tqq "$DECODED_ARCHIVE"
fi

unzip -q "$DECODED_ARCHIVE" -d "$WORK_DIR"
PROJECT_DIR="$WORK_DIR/project-sovereign"
test -f "$PROJECT_DIR/package.json"

cd "$PROJECT_DIR"
npm install --no-audit --no-fund
npm run verify

# Copy the completed static build to the repository-level output directory.
cp -a dist "$OUTPUT_DIR"

# This project is deployed by Workers Static Assets, not Pages. Workers parses every
# _redirects file in the asset tree and rejects the Pages SPA rewrite as an infinite
# redirect. The application uses one HTML document and in-page navigation, so no
# redirect/rewrite file is required.
printf 'Removing incompatible redirect files:\n'
find "$OUTPUT_DIR" -type f -name '_redirects' -print -delete

# Also tell Wrangler not to upload Pages control files even if a future build adds them.
printf '_redirects\n' > "$OUTPUT_DIR/.assetsignore"

if find "$OUTPUT_DIR" -type f -name '_redirects' -print -quit | grep -q .; then
  echo 'ERROR: _redirects still exists in deployment output.' >&2
  exit 1
fi

printf 'Deployment output verified: %s files, no _redirects.\n' "$(find "$OUTPUT_DIR" -type f | wc -l | tr -d ' ')"
