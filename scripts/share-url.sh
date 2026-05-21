#!/usr/bin/env bash
set -euo pipefail

CONFIG="$(dirname "$0")/../workshop.config.json"

if [[ -z "${CODESPACE_NAME:-}" ]]; then
  echo "⚠️  This script is meant to run inside a GitHub Codespace."
  echo "    \$CODESPACE_NAME is not set, so we can't build your live URL."
  exit 1
fi

URL="https://${CODESPACE_NAME}-3000.app.github.dev"

if [[ -f "$CONFIG" ]] && command -v jq >/dev/null 2>&1; then
  SUBMIT=$(jq -r '.submitUrl' "$CONFIG")
else
  SUBMIT="(see the README for the submission link)"
fi

cat <<EOF

✨ Your live app is here:
   $URL

📋 Paste it (with your name) into the workshop doc:
   $SUBMIT

   Example line to paste:
   $(git config user.name 2>/dev/null || echo "Your Name") — $URL

EOF
