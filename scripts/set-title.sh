#!/usr/bin/env bash
# Sets the <title> in public/index.html to the participant's name so each
# showcased browser tab is labeled. Falls back through:
#   1. $WORKSHOP_PARTICIPANT_NAME (organizer override)
#   2. `git config user.name` (Codespaces sets this from the GitHub identity)
#   3. $GITHUB_USER
#   4. $CODESPACE_NAME
#   5. "Workshop App"
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INDEX="$ROOT/public/index.html"

if [[ ! -f "$INDEX" ]]; then
  echo "No public/index.html found — skipping title set."
  exit 0
fi

NAME="${WORKSHOP_PARTICIPANT_NAME:-}"
[[ -z "$NAME" ]] && NAME="$(git config user.name 2>/dev/null || true)"
[[ -z "$NAME" ]] && NAME="${GITHUB_USER:-}"
[[ -z "$NAME" ]] && NAME="${CODESPACE_NAME:-}"
[[ -z "$NAME" ]] && NAME="Workshop App"

# Escape characters that would break sed's replacement.
ESCAPED=$(printf '%s' "$NAME" | sed -e 's/[&/\]/\\&/g')

# Replace whatever is currently between <title>...</title>.
sed -i "s|<title>[^<]*</title>|<title>${ESCAPED}</title>|" "$INDEX"

echo "Set browser tab title to: $NAME"
