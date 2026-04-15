#!/usr/bin/env bash
set -euo pipefail
FILE=.claude-plugin/plugin.json
[[ -f $FILE ]] || { echo "FAIL: $FILE missing"; exit 1; }
jq . "$FILE" > /dev/null || { echo "FAIL: invalid JSON"; exit 1; }
for field in name version description author repository license skills keywords; do
  jq -e ".${field}" "$FILE" > /dev/null || { echo "FAIL: missing field $field"; exit 1; }
done
[[ $(jq -r .name "$FILE") == "compose-expert" ]] || { echo "FAIL: name mismatch"; exit 1; }
[[ $(jq -r .version "$FILE") == "2.1.0" ]] || { echo "FAIL: version mismatch"; exit 1; }
[[ $(jq -r '.skills[0]' "$FILE") == "../jetpack-compose-expert-skill" ]] || { echo "FAIL: skills path wrong"; exit 1; }
echo "OK: plugin.json valid"
