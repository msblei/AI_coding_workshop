# One participant workspace: browser VS Code (code-server) + Cline + the React
# starter app, pre-built so containers start fast. Built once, run N times.
#
#   docker build -f deploy/Dockerfile -t workshop-workspace ..
#
# Build context is the REPO ROOT (so we can COPY the app in). See .dockerignore.
FROM codercom/code-server:latest

# --- system deps (Node 20 + jq + git) as root ----------------------------
USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates gnupg jq git \
 && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

# Restyle the code-server login page to match the claim landing page. Appended
# to login.css (which loads after global.css) so these rules win the cascade.
COPY deploy/login-overrides.css /tmp/login-overrides.css
RUN cat /tmp/login-overrides.css >> /usr/lib/code-server/src/browser/pages/login.css

# code-server itself reads $HOST/$PORT — bind it to all interfaces on 8080 so
# Caddy can reach it. The React dev server needs PORT=3000 instead, so its env
# lives in scripts/start.sh (NOT here) — a global PORT=3000 would hijack
# code-server onto 3000 and leave nothing on 8080.
ENV HOST=0.0.0.0 \
    PORT=8080 \
    BROWSER=none

# --- Cline, installed into the coder user's extension dir -----------------
USER coder
RUN code-server --install-extension saoudrizwan.claude-dev

# --- the workshop app, deps pre-installed ---------------------------------
COPY --chown=coder:coder . /home/coder/project
WORKDIR /home/coder/project
RUN (npm ci || npm install) \
 && cp /home/coder/project/deploy/README-workspace.md /home/coder/project/README.md \
 && rm -rf /home/coder/project/deploy   # swap in the workspace guide, then hide deploy/

# --- code-server USER settings --------------------------------------------
# Application-scoped settings that must live in the user-data dir (not the
# workspace .vscode/settings.json): disable Workspace Trust so Cline activates
# without a prompt, open the README in preview on launch, and hide the built-in
# Copilot/chat UI. See deploy/code-server-user-settings.json.
RUN mkdir -p /home/coder/.local/share/code-server/User
COPY --chown=coder:coder deploy/code-server-user-settings.json /home/coder/.local/share/code-server/User/settings.json

# --- our startup wrapper (seed Cline config, set title, launch) -----------
COPY --chown=coder:coder deploy/entrypoint-workshop.sh /home/coder/entrypoint-workshop.sh
RUN chmod +x /home/coder/entrypoint-workshop.sh

EXPOSE 8080 3000
ENTRYPOINT ["/home/coder/entrypoint-workshop.sh"]
