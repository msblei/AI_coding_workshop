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
  then click your app URL — it will appear right after the compile.

EOF

# Pipe CRA's output through awk so we can inject our codespace URL right
# after each successful compile. The localhost / network URLs CRA prints
# by default are useless in Codespaces — participants need this URL instead.
#
# `script -qefc … /dev/null` allocates a pseudo-TTY for react-scripts. Without
# the PTY, Node detects stdout is a pipe and block-buffers its output, so awk
# would only see CRA's lines in big chunks (terminal looks frozen). The PTY
# makes Node flush line-by-line.
script -qefc "BROWSER=none npx react-scripts start" /dev/null | awk -v url="$URL" '
{
  print $0
  fflush()
  if (/webpack compiled successfully/) {
    print ""
    print "  ────────────────────────────────────────────────────────────"
    print "  👉  Your app is live! Click here to open it:"
    print ""
    print "      " url
    print ""
    print "      The page should say: \"Everything works!\""
    print "  ────────────────────────────────────────────────────────────"
    print ""
    fflush()
  }
}'
