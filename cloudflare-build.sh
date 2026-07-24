#!/usr/bin/env bash
set -euo pipefail

SOURCE_ARCHIVE="releases/project-sovereign-v0.2.0-source.zip"
WORK_DIR=".cf-build"
DECODED_ARCHIVE="${WORK_DIR}/project-sovereign-source.zip"

rm -rf "$WORK_DIR" dist
mkdir -p "$WORK_DIR"

# The ZIP may be stored either as a normal binary archive or as Base64 text.
if unzip -tqq "$SOURCE_ARCHIVE" >/dev/null 2>&1; then
  cp "$SOURCE_ARCHIVE" "$DECODED_ARCHIVE"
else
  base64 --decode "$SOURCE_ARCHIVE" > "$DECODED_ARCHIVE"
fi

unzip -q "$DECODED_ARCHIVE" -d "$WORK_DIR"
test -f "$WORK_DIR/project-sovereign/package.json"

cd "$WORK_DIR/project-sovereign"
npm install --no-audit --no-fund
npm run verify
cp -R dist ../../dist
