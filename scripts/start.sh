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

  Wait until you see the "Your app is live!" banner below
  (about 30 seconds), then click your app URL.

EOF

# Background watcher: poll the dev server until it responds, then print the
# click-here banner. We can't pipe CRA's stdout through a filter to detect
# "Compiled successfully" — Node block-buffers stdout when piped, freezing
# the terminal until a chunk fills. Polling the server directly avoids that
# whole class of problem and keeps CRA's output unmolested (colors, in-place
# progress updates, etc. still work).
(
  while ! curl -fsS -o /dev/null http://localhost:3000 2>/dev/null; do
    sleep 1
  done
  # Give CRA a beat to finish printing its own intro before we append.
  sleep 2
  cat <<INNER

  ────────────────────────────────────────────────────────────
  👉  Your app is live! Click here to open it:

      $URL

      The page should say: "Everything works!"
  ────────────────────────────────────────────────────────────

INNER
) &
WATCHER_PID=$!

# Make sure the background watcher dies with us (e.g. when the user Ctrl+C's
# before the server comes up).
trap "kill $WATCHER_PID 2>/dev/null || true" EXIT INT TERM

BROWSER=none npx react-scripts start
