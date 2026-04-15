#!/usr/bin/env bash
set -euo pipefail
FILE=README.md
grep -q "^## Install" "$FILE" || { echo "FAIL: missing Install section"; exit 1; }
grep -q "docs/INSTALL.md" "$FILE" || { echo "FAIL: no link to INSTALL.md"; exit 1; }
grep -q "^## Updates" "$FILE" || { echo "FAIL: missing Updates section"; exit 1; }
grep -q "releases" "$FILE" || { echo "FAIL: no link to GitHub Releases"; exit 1; }
echo "OK: README.md has Install + Updates sections"
