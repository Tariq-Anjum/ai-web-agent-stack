#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

docker compose \
  --env-file "$ROOT/.env" \
  -f "$ROOT/compose/docker-compose.yml" \
  down

# Do not remove a command owned by another checkout.
for command_name in web-stack web-search web-read; do
  link="$HOME/.local/bin/$command_name"
  if [[ -L "$link" && "$(readlink -f -- "$link")" == "$ROOT/bin/$command_name" ]]; then
    rm -- "$link"
  fi
done

echo "Containers stopped and convenience symlinks removed."
echo "Repository files and secrets were not deleted."
echo "To remove runtime data too, delete:"
echo "  $ROOT/data"
echo "  $ROOT/logs"
echo "  $ROOT/state"
