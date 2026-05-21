#!/usr/bin/env bash
set -euo pipefail

CONFIG="$(dirname "$0")/../workshop.config.json"

SUBMIT="(see README)"
if [[ -f "$CONFIG" ]] && command -v jq >/dev/null 2>&1; then
  SUBMIT=$(jq -r '.submitUrl' "$CONFIG")
fi

URL="(your live URL will appear once \`npm start\` is up)"
if [[ -n "${CODESPACE_NAME:-}" ]]; then
  URL="https://${CODESPACE_NAME}-3000.app.github.dev"
fi

NAME="${WORKSHOP_PARTICIPANT_NAME:-$(git config user.name 2>/dev/null || echo "Your Name")}"

cat <<EOF

╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║          🎉  Welcome to the AI Coding Workshop  🎉               ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

  Your live app:
      $URL
      (give it ~30 seconds — the dev server is starting in the
       "Start React dev server" terminal tab to the right)

  When you're ready, paste your name and the URL above into:
      $SUBMIT

  Example line to paste:
      $NAME — $URL

  Tip: click the robot icon in the left sidebar to open Cline,
       paste the key you were handed, and start chatting.

EOF
