#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
archive="${1:-}"

if [[ -z "$archive" || ! -f "$archive" ]]; then
  echo "Usage: $0 BROWSER-STATE.tar.gz" >&2
  exit 2
fi

key_file="$ROOT/state/agent-browser-encryption-key.env"
test -f "$key_file" || {
  echo "Missing $key_file" >&2
  echo "Restore the matching encryption key before restoring browser state." >&2
  exit 1
}

mkdir -p "$HOME"
tar -xzf "$archive" -C "$HOME"

chmod 700 "$HOME/.agent-browser" 2>/dev/null || true

source "$key_file"

echo "Browser state restored to:"
echo "  $HOME/.agent-browser"
echo "The restored state must be used with the matching encryption key."
