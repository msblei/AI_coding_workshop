#!/usr/bin/env bash
# Per-container startup. Points the workshop config at the LiteLLM proxy (from
# env), reuses the repo's existing seed/title scripts, then hands off to
# code-server's normal entrypoint opening the project folder.
set -euo pipefail

PROJECT=/home/coder/project
cd "$PROJECT"

# 1. Rewrite workshop.config.json from env so seed-cline-settings.sh picks up
#    THIS deployment's proxy URL + model (instead of the repo's "TBD").
if [[ -n "${LITELLM_BASE_URL:-}" ]]; then
  tmp=$(mktemp)
  jq --arg url "$LITELLM_BASE_URL" --arg model "${MODEL:-claude-opus-4-7}" \
     '.litellmBaseUrl = $url | .model = $model' workshop.config.json > "$tmp" \
     && mv "$tmp" workshop.config.json
fi

# 2. Seed Cline's base URL + model, and the per-tab title. Non-fatal if they
#    no-op. (The API KEY is handled separately — see deploy/README.md "Cline
#    auth"; settings.json cannot hold the secret.)
export WORKSHOP_PARTICIPANT_NAME="${PARTICIPANT_NAME:-Workshop App}"
bash scripts/seed-cline-settings.sh || true
bash scripts/set-title.sh || true

# Fill the participant's real app URL + OpenRouter key into their workspace README
# (shown in preview on launch). Placeholders come from deploy/README-workspace.md.
# OPENROUTER_API_KEY is assigned round-robin per container by gen.sh.
if [[ -f README.md ]]; then
  sed -i "s|{{APP_URL}}|${APP_URL:-}|g" README.md 2>/dev/null || true
  or_key="${OPENROUTER_API_KEY:-}"
  [[ -z "$or_key" ]] && or_key="(ask the facilitator for your OpenRouter key)"
  sed -i "s|{{OPENROUTER_KEY}}|${or_key}|g" README.md 2>/dev/null || true
fi

# 3. Auto-start the React dev server in the background so the participant's
#    public app URL (uN-app) is live immediately — no need to run `npm start`.
#    A restart loop keeps it up if it ever exits. Logs to dev-server.log.
( cd "$PROJECT" && while true; do
    bash scripts/start.sh || true
    echo "[dev server exited — restarting in 3s]"
    sleep 3
  done ) > /home/coder/dev-server.log 2>&1 &

# 4. Keep the React page <title> in sync with the participant's claimed name.
#    Poll the claim service for THIS slot's name; when it appears/changes, set
#    the title via the repo's set-title.sh. SLOT_ID is injected by gen.sh.
if [[ -n "${SLOT_ID:-}" ]]; then
  ( last=""
    while true; do
      name=$(curl -fsS -m 4 "${CLAIM_URL:-http://claim:8090}/api/state" 2>/dev/null \
        | jq -r --argjson id "${SLOT_ID}" '.slots[] | select(.id==$id) | .name // ""' 2>/dev/null || true)
      if [[ -n "$name" && "$name" != "$last" ]]; then
        WORKSHOP_PARTICIPANT_NAME="$name" bash scripts/set-title.sh >/dev/null 2>&1 || true
        last="$name"
      fi
      sleep 5
    done ) > /home/coder/title-poller.log 2>&1 &
fi

# 5. Launch code-server (its own entrypoint reads $PASSWORD), opening the app.
#    --app-name brands the login/password page ("Welcome to AI Coding Workshop").
exec /usr/bin/entrypoint.sh --bind-addr 0.0.0.0:8080 --app-name "AI Coding Workshop" "$PROJECT"
