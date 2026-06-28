#!/usr/bin/env bash
# Bring up (or update) the N-participant fleet. Run as root on the VM:
#   sudo bash deploy/fleet.sh [N]      (default N=10)
#
# Steps: generate config -> (re)build the shared image -> stop the Phase 0
# single-instance stack (frees 80/443) -> start the fleet.
set -euo pipefail

N="${1:-10}"
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

bash "$HERE/gen.sh" "$N"

echo "--- building shared workspace image ---"
docker build -t workshop-workspace:latest -f "$HERE/Dockerfile" "$ROOT"

echo "--- stopping Phase 0 stack if running (frees 80/443) ---"
docker compose -f "$HERE/docker-compose.yml" down 2>/dev/null || true

echo "--- starting the fleet (builds the claim landing-page service too) ---"
# --remove-orphans cleans up containers from a previous, larger participant count.
docker compose -f "$HERE/docker-compose.gen.yml" up -d --build --remove-orphans

echo "--- clearing previous claims for a fresh start ---"
for _ in 1 2 3 4 5; do
  docker compose -f "$HERE/docker-compose.gen.yml" exec -T claim sh -c 'rm -f /data/claims.json' 2>/dev/null && break
  sleep 1
done
# Restart so the claim service drops its in-memory claims too (not just the file).
docker compose -f "$HERE/docker-compose.gen.yml" restart claim >/dev/null 2>&1 || true

echo
echo "--- fleet status ---"
docker compose -f "$HERE/docker-compose.gen.yml" ps
echo
echo "Participant URLs + passwords are in deploy/users.txt"
