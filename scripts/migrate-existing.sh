#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="${1:-}"

if [[ -z "$SOURCE" ]]; then
  echo "Usage: $0 EXISTING-WEB-STACK-DIRECTORY" >&2
  exit 2
fi

test -d "$SOURCE" || {
  echo "Source directory not found: $SOURCE" >&2
  exit 1
}

mkdir -p "$ROOT/data" "$ROOT/logs" "$ROOT/state"

# Safe source/config migration. Secrets are deliberately excluded.
for f in compose.yml; do
  [[ -f "$SOURCE/$f" ]] && cp -f "$SOURCE/$f" "$ROOT/$f.migrated"
done

if [[ -d "$SOURCE/config" ]]; then
  cp -a "$SOURCE/config/." "$ROOT/config/" 2>/dev/null || true
fi

if [[ -d "$SOURCE/data" ]]; then
  cp -a "$SOURCE/data/." "$ROOT/data/" 2>/dev/null || true
fi

echo "Migration copy completed."
echo "No .env or secret files were copied."
