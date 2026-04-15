#!/usr/bin/env bash
set -euo pipefail
FILE=.copilot/plugin.yaml
[[ -f $FILE ]] || { echo "FAIL: $FILE missing"; exit 1; }
command -v yq > /dev/null || { echo "FAIL: yq not installed"; exit 1; }
yq . "$FILE" > /dev/null || { echo "FAIL: invalid YAML"; exit 1; }
[[ $(yq -r .name "$FILE") == "compose-expert" ]] || { echo "FAIL: name mismatch"; exit 1; }
[[ $(yq -r .version "$FILE") == "2.0.0" ]] || { echo "FAIL: version mismatch"; exit 1; }
echo "OK: plugin.yaml valid"
