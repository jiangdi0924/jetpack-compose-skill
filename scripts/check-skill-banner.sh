#!/usr/bin/env bash
set -euo pipefail
SKILL=jetpack-compose-expert-skill/SKILL.md
grep -q "^version: 2.0.0$" "$SKILL" || { echo "FAIL: missing version frontmatter"; exit 1; }
grep -q "Installation notice.*distributed as a plugin" "$SKILL" || { echo "FAIL: missing deprecation banner"; exit 1; }
grep -q "/plugin marketplace add aldefy/compose-skill" "$SKILL" || { echo "FAIL: missing marketplace command"; exit 1; }
echo "OK: SKILL.md has version + banner"
