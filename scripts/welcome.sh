#!/usr/bin/env bash
set -euo pipefail

CONFIG="$(dirname "$0")/../workshop.config.json"

SUBMIT="(see README)"
if [[ -f "$CONFIG" ]] && command -v jq >/dev/null 2>&1; then
  SUBMIT=$(jq -r '.submitUrl' "$CONFIG")
fi

URL="(your live URL will appear after \`npm start\`)"
if [[ -n "${CODESPACE_NAME:-}" ]]; then
  URL="https://${CODESPACE_NAME}-3000.app.github.dev"
fi

cat <<EOF

╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║          🎉  Welcome to the AI Coding Workshop  🎉             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

  Open the README on the left for step-by-step instructions.

  When you're ready to share your app, run:
      npm run share

  Your live app will be at:
      $URL

  Workshop submission doc:
      $SUBMIT

  Tip: click the robot icon in the left sidebar to open Cline,
       paste the key you were handed, and start chatting.

EOF
