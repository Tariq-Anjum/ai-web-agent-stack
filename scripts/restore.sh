#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

archive="${1:-}"
if [[ -z "$archive" || ! -f "$archive" ]]; then
  echo "Usage: $0 RUNTIME-BACKUP.tar.gz" >&2
  exit 2
fi

mkdir -p "$ROOT/data" "$ROOT/config/searxng"

tar -xzf "$archive" -C "$ROOT"

chmod 755 "$ROOT/data" "$ROOT/config/searxng" || true

echo "Runtime/config restored."
echo "Restore .env separately if preserving the old deployment identity."
