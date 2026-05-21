#!/usr/bin/env bash
# Organizer-only. Mints N LiteLLM virtual keys, one per workshop participant.
# Prints a CSV of `name,key` ready to paste into a printable handout or DM.
#
# Usage:
#   LITELLM_URL=https://litellm.example.com \
#   LITELLM_ADMIN_KEY=sk-1234 \
#   ./scripts/mint-keys.sh participants.txt
#
# participants.txt is one name per line, blank lines ignored.
#
# Each key is tagged with the participant's name, capped at 30 RPM / 100k TPM,
# and expires 4 hours from now.
set -euo pipefail

LITELLM_URL="${LITELLM_URL:?Set LITELLM_URL to your LiteLLM proxy base URL}"
LITELLM_ADMIN_KEY="${LITELLM_ADMIN_KEY:?Set LITELLM_ADMIN_KEY to a LiteLLM admin key}"
INPUT="${1:?Usage: $0 participants.txt}"

if [[ ! -f "$INPUT" ]]; then
  echo "Participants file not found: $INPUT" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

echo "name,key"

while IFS= read -r raw_name || [[ -n "$raw_name" ]]; do
  # Trim whitespace; skip blank lines and comments.
  name=$(echo "$raw_name" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  [[ -z "$name" || "${name:0:1}" == "#" ]] && continue

  payload=$(jq -n \
    --arg name "$name" \
    '{
      key_alias: $name,
      duration: "4h",
      rpm_limit: 30,
      tpm_limit: 100000,
      metadata: { workshop: "ai-coding", participant: $name }
    }')

  response=$(curl -fsS -X POST "$LITELLM_URL/key/generate" \
    -H "Authorization: Bearer $LITELLM_ADMIN_KEY" \
    -H "Content-Type: application/json" \
    -d "$payload")

  key=$(echo "$response" | jq -r '.key')
  echo "\"$name\",$key"
done < "$INPUT"
