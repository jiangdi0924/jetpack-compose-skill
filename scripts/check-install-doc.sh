#!/usr/bin/env bash
set -euo pipefail
FILE=docs/INSTALL.md
[[ -f $FILE ]] || { echo "FAIL: $FILE missing"; exit 1; }
for section in "## Claude Code" "## Copilot CLI" "## Codex CLI"; do
  grep -q "$section" "$FILE" || { echo "FAIL: missing section $section"; exit 1; }
done
grep -q "/plugin marketplace add aldefy/compose-skill" "$FILE" || { echo "FAIL: missing CC install cmd"; exit 1; }
grep -q "copilot plugin install" "$FILE" || { echo "FAIL: missing Copilot cmd"; exit 1; }
grep -q "git clone" "$FILE" || { echo "FAIL: missing Codex clone instruction"; exit 1; }
echo "OK: INSTALL.md valid"
