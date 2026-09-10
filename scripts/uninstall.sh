#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

docker compose \
  --env-file "$ROOT/.env" \
  -f "$ROOT/compose/docker-compose.yml" \
  down

rm -f "$HOME/.local/bin/web-stack" "$HOME/.local/bin/web-search"

echo "Containers stopped and convenience symlinks removed."
echo "Repository files and secrets were not deleted."
echo "To remove runtime data too, delete:"
echo "  $ROOT/data"
echo "  $ROOT/logs"
echo "  $ROOT/state"
