#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export WEB_STACK_HOME="$ROOT"
export PATH="$ROOT/bin:$HOME/.local/bin:$PATH"

set -a
source "$ROOT/versions/pins.env"
source "$ROOT/.env"
set +a

npm install --global --allow-scripts=agent-browser \
  "agent-browser@$AGENT_BROWSER_VERSION"

agent-browser install

docker compose \
  --env-file "$ROOT/.env" \
  -f "$ROOT/compose/docker-compose.yml" \
  pull

docker compose \
  --env-file "$ROOT/.env" \
  -f "$ROOT/compose/docker-compose.yml" \
  up -d

"$ROOT/bin/web-stack" verify
