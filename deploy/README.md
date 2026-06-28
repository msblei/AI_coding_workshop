# Self-hosted workshop — operator runbook

Runs the workshop as a fleet of browser IDEs (code-server + Cline + a live React app) on a single
VM, served over HTTPS from your own domain. Participants open a landing page, **claim a spot**, and
get a workspace URL + password — no GitHub accounts, no per-person setup. This is the alternative to
the Codespaces path (see the repo [`README.md`](../README.md)) for networks where Codespaces is
blocked or per-participant GitHub isn't available.

## Architecture

```
                 Caddy (:443, automatic HTTPS)
participant ──►  ai-coding-workshop.<domain>      → claim landing page (pick a spot)
                 www.ai-coding-workshop.<domain>  → 301 → apex
                 uN.ai-coding-workshop.<domain>   → code-server-N:8080   (the IDE)
                 uN-app.ai-coding-workshop.<domain> → code-server-N:3000 (their live React app)
```

Each workspace container: code-server + Cline (Open VSX) + the React app pre-built; the dev server
**auto-starts** (so `uN-app` is live immediately); a poller sets the browser tab title to the
participant's claimed name; the login page is restyled + branded ("AI Coding Workshop").

The **claim service** (zero-dep Node) holds the slot→password map and assigns spots atomically.

## The two modes — when to use which

| | Codespaces | Self-hosted (this) |
|--|------------|--------------------|
| Setup for you | none | one VM, DNS, ~1–2 h |
| Setup for participants | GitHub account + create codespace | open a URL, click a spot |
| Works behind locked-down proxies | often **no** (tunnel transport filtered) | **yes** (plain 443 to your domain) |
| Cost | per-codespace compute | one VM for the session |

## Requirements

- **VM:** 8 vCPU / 32 GB RAM, Ubuntu 24.04. Azure **Standard_D8s_v5** or Hetzner **CCX33**.
  Use a **Static** public IP so Stop/Start keeps the same address.
- **Docker** + compose plugin — installed automatically by `fleet.sh` on first run (no manual step).
- **Inbound ports:** 22 (SSH), 80 + 443 (Caddy/TLS). On Azure, open 80/443 in the NSG.
- **DNS** at your registrar, pointing at the VM IP:
  - `*.ai-coding-workshop.<domain>` (A) — covers `uN`, `uN-app`, `www`.
  - `ai-coding-workshop.<domain>` (A) — the **apex**; the wildcard does *not* cover the bare name.
- **OpenRouter API key(s)** (or similar) for participants (put in `deploy/openrouter-keys.txt`).

## Resource & memory expectations

Measured with 15 workspaces on a 32 GB / 8-vCPU VM:

| State | RAM per container | 15 containers |
|-------|-------------------|---------------|
| Idle (IDE only) | ~80–120 MB | ~2 GB total |
| Running React dev server | ~450 MB | ~8 GB total |

- **RAM:** comfortable — ~8–12 GB of 32 GB with everyone active. 15 is fine; ~20–25 would still fit.
- **CPU:** idle ~0.3%/container. The one spike is the **thundering herd** when all containers (re)start
  and compile at once — 1-min load average briefly hits ~14 on 8 cores, then settles within a minute.
  Normal editing doesn't reproduce it. If you expect everyone compiling in lockstep, a 16-vCPU VM is
  smoother (not required).
- `mem_limit: 3g` per container is set as a safety cap in the generated compose.

## Quickstart — from a brand-new VM (in order)

1. **Create the VM** — 8 vCPU / 32 GB, Ubuntu 24.04, **Static** public IP. Open inbound **22, 80, 443**.
2. **DNS** — two A records at your registrar, both pointing to the VM's IP:
   - `*.ai-coding-workshop.<domain>` — wildcard (`uN`, `uN-app`, `www`)
   - `ai-coding-workshop.<domain>` — apex (the landing page; the wildcard does *not* cover it)
3. **SSH in, clone, configure, launch:**

   ```bash
   ssh -i ~/.ssh/<key>.pem azureuser@<VM-IP>

   git clone https://github.com/msblei/AI_coding_workshop ~/ai_coding_workshop
   cd ~/ai_coding_workshop

   cp deploy/.env.example deploy/.env                                # set DOMAIN + ACME_EMAIL
   cp deploy/openrouter-keys.txt.example deploy/openrouter-keys.txt  # add your OpenRouter key(s)

   sudo bash deploy/fleet.sh 15      # installs Docker if missing, builds, starts 15 workspaces
   ```

4. **Hand out** — send participants to `https://ai-coding-workshop.<domain>`; per-spot URLs + passwords
   are in `cat deploy/users.txt`.

First run takes ~5–10 min (Docker install + image build + dev servers compiling). Only **DOMAIN** and
**ACME_EMAIL** in `.env` are required for the fleet. Re-running `fleet.sh` later rebuilds to a clean
fleet (and resets the claim board); see "Running a workshop" below.

## Running a workshop

**Fresh workshop** (clean slate — wipes previous work + claims):
```bash
ssh -i ~/.ssh/<key>.pem azureuser@<VM-IP>
cd ~/ai_coding_workshop && sudo bash deploy/fleet.sh 15
```
**Resume the same session** (e.g. after deallocating overnight): **just Start the VM** — containers
auto-resume with work + claims intact. Do **not** run `fleet.sh` (it rebuilds and wipes).

> `fleet.sh` is destructive: it rebuilds the image, recreates all containers (deleting in-progress
> participant work — the app lives in the image, not a volume), and clears the claim board. Run it
> **once** before the workshop. Passwords are preserved across runs (kept in `users.txt`).

## Command reference

Run on the VM (Docker needs `sudo`). Compose file: `deploy/docker-compose.gen.yml`.

| Task | Command |
|------|---------|
| SSH in | `ssh -i ~/.ssh/<key>.pem azureuser@<VM-IP>` |
| Build/resize/restart fleet | `sudo bash deploy/fleet.sh <N>` |
| Regenerate config only | `sudo bash deploy/gen.sh <N>` (compose + Caddyfile + users.txt + slots.json) |
| Handout (URLs+passwords) | `cat deploy/users.txt` |
| Fleet status | `sudo docker compose -f deploy/docker-compose.gen.yml ps` |
| Live resource usage | `sudo docker stats` |
| RAM / load | `free -h` · `uptime` |
| A workspace's code-server log | `sudo docker logs deploy-code-server-<N>-1` |
| A workspace's dev-server log | `sudo docker exec deploy-code-server-<N>-1 cat /home/coder/dev-server.log` |
| Title-poller log | `sudo docker exec deploy-code-server-<N>-1 cat /home/coder/title-poller.log` |
| Reset claim board | `sudo docker exec deploy-claim-1 rm -f /data/claims.json && sudo docker restart deploy-claim-1` |
| Reset one workspace | `sudo docker compose -f deploy/docker-compose.gen.yml up -d --force-recreate code-server-<N>` |
| Stop VM (≈$0 compute) | Azure portal **Stop**, or `az vm deallocate -g <rg> -n <vm>` |
| Start VM | Azure portal **Start**, or `az vm start -g <rg> -n <vm>` |

## Monitoring — what healthy looks like

```bash
sudo docker stats --no-stream      # idle ~100 MB/container; ~450 MB when its dev server runs
free -h                            # used ~8–12 GB of 31 GB with everyone active
uptime                             # load < #cores at rest; a brief boot spike is expected
```

## Claim landing page

- Served at the apex `https://ai-coding-workshop.<domain>` by the `claim` service.
- **Claim:** participant enters a name → atomically assigned the next free spot (or clicks a tile) →
  shown their workspace URL + password (Copy button). A cookie makes it refresh-safe.
- **Un-claim:** "Not your spot? Release it" on the card frees the spot (does **not** touch the
  container). For accidental claims.
- **Reset all claims:** the command in the table, or set `CLAIM_ADMIN_TOKEN` in `deploy/.env` and
  `POST /api/reset?token=<token>`. `fleet.sh` also clears claims on every run.
- Slots (id/url/password) live in `deploy/slots.json` (generated); claims persist in the `claim_data`
  volume across restarts.

## Files in `deploy/`

| File | Role |
|------|------|
| `Dockerfile` | Workspace image: code-server + Cline + pre-built app + UX/login restyle; bakes the workspace README. |
| `entrypoint-workshop.sh` | Per-container start: seed title, fill `{{APP_URL}}` in README, auto-start dev server, title poller, launch code-server with `--app-name`. |
| `code-server-user-settings.json` | Baked user settings: trust off, README preview on launch, Copilot/chat hidden. |
| `login-overrides.css` | Appended to code-server's `login.css` to restyle/brand the login page. |
| `gen.sh` / `fleet.sh` | Generate fleet config / orchestrate build+run. |
| `claim/` | Zero-dep claim landing-page service (`server.mjs`) + its Dockerfile. |
| `README-workspace.md` | Participant guide baked into the image as the project `README.md`. |
| `.env.example` / `openrouter-keys.txt.example` | Copy to real files (git-ignored) and fill in. |

## Lifecycle & cost

- **Sleep:** Azure **Stop** = *deallocate* → no compute charge (disk + static IP cost pennies). A guest
  `poweroff` does **not** deallocate. Status must read "Stopped (deallocated)".
- **Resume:** Start → containers auto-resume (`restart: unless-stopped`); Caddy certs persist in the
  `caddy_data` volume. Budget **~5–10 min** to warm up (containers + dev servers compile).
- The VM is disposable — delete it after the workshop if you won't reuse it.

## Troubleshooting

- **Landing page won't load right after adding DNS:** propagation/negative-cache. Public resolvers
  (`1.1.1.1`/`8.8.8.8`) pick it up first; your ISP resolver may lag 15–60 min. Test via cellular or
  flush DNS.
- **`This site can't provide a secure connection`:** usually `www` (now redirected) or Caddy still in
  ACME **retry-backoff** from when DNS didn't resolve yet — `sudo docker restart deploy-caddy-1` to
  retry immediately.
- **Login page changes not visible:** browsers cache `login.css` (served without a hash) — hard-refresh
  (Cmd/Ctrl+Shift+R).
- **`fleet.sh: ... Permission denied`:** generated files are root-owned — run `gen.sh`/`fleet.sh` with
  `sudo`.
- **Ran `fleet.sh` on your Mac:** it must run **on the VM** (needs Docker + `deploy/.env`).
- **IP changed after Stop/Start:** the public IP wasn't Static — update the DNS records to the new IP.

`deploy/.env`, `users.txt`, `slots.json`, `openrouter-keys.txt`, and `*.gen.*` are git-ignored —
never commit real keys/passwords.
