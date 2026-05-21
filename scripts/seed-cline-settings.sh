#!/usr/bin/env bash
# Runs once on codespace creation. Reads workshop.config.json and writes
# .vscode/settings.json so Cline opens already pointed at the workshop's
# LiteLLM proxy with the right model. Participants only need to paste the key.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$ROOT/workshop.config.json"
SETTINGS_DIR="$ROOT/.vscode"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

if [[ ! -f "$CONFIG" ]]; then
  echo "No workshop.config.json found — skipping Cline seeding."
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not available — skipping Cline seeding. Install jq in the devcontainer features."
  exit 0
fi

BASE_URL=$(jq -r '.litellmBaseUrl' "$CONFIG")
MODEL=$(jq -r '.model' "$CONFIG")

if [[ "$BASE_URL" == "TBD" || -z "$BASE_URL" || "$BASE_URL" == "null" ]]; then
  echo "litellmBaseUrl in workshop.config.json is not configured — leaving Cline settings untouched."
  echo "Participants will need to fill in the base URL manually."
  exit 0
fi

mkdir -p "$SETTINGS_DIR"

# Merge with any existing settings rather than clobbering them. If the file is
# empty or missing, start from {}.
EXISTING="{}"
if [[ -s "$SETTINGS_FILE" ]]; then
  EXISTING=$(cat "$SETTINGS_FILE")
fi

UPDATED=$(jq -n \
  --argjson existing "$EXISTING" \
  --arg baseUrl "$BASE_URL" \
  --arg model "$MODEL" \
  '$existing + {
    "files.autoSave": "onFocusChange",
    "workbench.startupEditor": "readme",
    "chat.disableAIFeatures": true,
    "chat.commandCenter.enabled": false,
    "github.copilot.enable": { "*": false },
    "cline.apiProvider": "anthropic",
    "cline.anthropicBaseUrl": $baseUrl,
    "cline.modelId": $model,
    "cline.alwaysAllowReadOnly": true,
    "cline.alwaysAllowWrite": true,
    "cline.alwaysAllowExecute": true,
    "cline.alwaysAllowBrowser": true,
    "cline.alwaysAllowMcp": true
  }')

echo "$UPDATED" > "$SETTINGS_FILE"
echo "Wrote $SETTINGS_FILE — Cline pre-pointed at $BASE_URL ($MODEL)."
