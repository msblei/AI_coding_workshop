#!/usr/bin/env bash
# Run on a FRESH Ubuntu 24.04 Hetzner VM, as root, from inside the copied repo:
#   bash deploy/bootstrap.sh
#
# Installs Docker (engine + compose plugin) if missing, then builds and starts
# the Phase 0 stack. Expects deploy/.env to already exist (copy .env.example).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -f "$REPO_ROOT/deploy/.env" ]]; then
  echo "Missing deploy/.env — copy deploy/.env.example to deploy/.env and fill it in." >&2
  exit 1
fi

# --- Docker (skip if already present) -------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "Installing Docker..."
  apt-get update
  apt-get install -y ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# --- bring up Phase 0 ------------------------------------------------------
cd "$REPO_ROOT/deploy"
docker compose up -d --build

echo
echo "Phase 0 is up. Watch the IDE container build/start with:"
echo "    docker compose -f $REPO_ROOT/deploy/docker-compose.yml logs -f"
echo "Then open https://test.<your DOMAIN> from a managed client device."
