#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
set -a
source "$ROOT/versions/pins.env"
set +a

command -v node >/dev/null 2>&1 || {
  echo "Node.js >= 24 is required." >&2
  exit 1
}

node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 24 ? 0 : 1)' || {
  echo "Node.js >= 24 is required." >&2
  exit 1
}

npm config set prefix "$HOME/.local"
npm install --global --allow-scripts=agent-browser \
  "agent-browser@$AGENT_BROWSER_VERSION"

agent-browser install

echo "agent-browser $(agent-browser --version | awk '{print $2}') installed."
