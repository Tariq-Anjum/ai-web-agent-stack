#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

export WEB_STACK_HOME="${WEB_STACK_HOME:-$ROOT}"
export PATH="$WEB_STACK_HOME/bin:$HOME/.local/bin:$PATH"

mkdir -p \
  "$WEB_STACK_HOME/data/searxng" \
  "$WEB_STACK_HOME/logs" \
  "$WEB_STACK_HOME/state" \
  "$HOME/.local/bin"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  }
}

for cmd in docker curl jq git openssl; do
  require_cmd "$cmd"
done

docker compose version >/dev/null 2>&1 || {
  echo "Docker Compose v2 is required." >&2
  exit 1
}

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "Node.js and npm are required for agent-browser installation." >&2
  echo "Install Node.js >= 24, then rerun this installer." >&2
  exit 1
fi

node_major="$(node -p 'process.versions.node.split(".")[0]')"
(( node_major >= 24 )) || {
  echo "Node.js >= 24 required; found $(node --version)." >&2
  exit 1
}

set -a
source "$ROOT/versions/pins.env"
set +a

if [[ ! -f "$ROOT/.env" ]]; then
  umask 077

  CRAWL4AI_API_TOKEN="$(openssl rand -hex 32)"
  SECRET_KEY="$(openssl rand -hex 32)"
  REDIS_PASSWORD="$(openssl rand -hex 32)"
  SEARXNG_SECRET="$(openssl rand -hex 32)"

  cat > "$ROOT/.env" <<EOF
SEARXNG_PORT=8080
SEARXNG_HOST=127.0.0.1
SEARXNG_VERSION=$SEARXNG_VERSION
CRAWL4AI_PORT=11235
CRAWL4AI_CONCURRENCY=2
CRAWL4AI_API_TOKEN=$CRAWL4AI_API_TOKEN
SECRET_KEY=$SECRET_KEY
REDIS_PASSWORD=$REDIS_PASSWORD
SEARXNG_SECRET=$SEARXNG_SECRET
CRAWL4AI_IMAGE=$CRAWL4AI_IMAGE
EOF

  chmod 600 "$ROOT/.env"
else
  chmod 600 "$ROOT/.env"
  set -a
  source "$ROOT/.env"
  set +a
fi

# Keep package-installed agent-browser user-local.
npm config set prefix "$HOME/.local"

installed_version="$(agent-browser --version 2>/dev/null | awk '{print $2}' || true)"
if [[ "$installed_version" != "$AGENT_BROWSER_VERSION" ]]; then
  npm install --global --allow-scripts=agent-browser \
    "agent-browser@$AGENT_BROWSER_VERSION"
fi

agent-browser install

# Persist an explicit browser encryption key for authenticated browser state.
KEY_FILE="$ROOT/state/agent-browser-encryption-key.env"
if [[ ! -f "$KEY_FILE" ]]; then
  umask 077
  printf 'export AGENT_BROWSER_ENCRYPTION_KEY=%s\n' \
    "$(openssl rand -hex 32)" > "$KEY_FILE"
fi
chmod 600 "$KEY_FILE"

# Install convenience symlinks.
ln -sfn "$ROOT/bin/web-stack" "$HOME/.local/bin/web-stack"
ln -sfn "$ROOT/bin/web-search" "$HOME/.local/bin/web-search"

# Ensure the key is exported for this process and descendants.
source "$KEY_FILE"

docker network inspect web-stack >/dev/null 2>&1 ||
  docker network create web-stack >/dev/null

docker compose \
  --env-file "$ROOT/.env" \
  -f "$ROOT/compose/docker-compose.yml" \
  pull

docker compose \
  --env-file "$ROOT/.env" \
  -f "$ROOT/compose/docker-compose.yml" \
  up -d

"$ROOT/bin/web-stack" verify

cat <<EOF

Installation complete.

Stack root:
  $ROOT

Commands:
  web-stack status
  web-stack verify
  web-search "Crawl4AI documentation"

SearXNG:
  http://127.0.0.1:${SEARXNG_PORT:-8080}

Crawl4AI:
  http://127.0.0.1:${CRAWL4AI_PORT:-11235}

Secrets:
  $ROOT/.env
  $KEY_FILE

Do not commit either secret file.
EOF
