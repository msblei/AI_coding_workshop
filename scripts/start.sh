#!/usr/bin/env bash
set -euo pipefail

URL="(your URL will appear once you're in the codespace)"
if [[ -n "${CODESPACE_NAME:-}" ]]; then
  URL="https://${CODESPACE_NAME}-3000.app.github.dev"
fi

cat <<EOF

╔══════════════════════════════════════════════════════════════════╗
║          🚀  Starting your app...                                ║
╚══════════════════════════════════════════════════════════════════╝

  Wait until you see "Compiled successfully!" below (about 30 seconds),
  then open this URL in a new browser tab:

  👉  $URL

  When the page loads, you should see: "Everything works!"

EOF

exec npx react-scripts start
