#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="${1:-$ROOT/backups/ai-web-agent-stack-$STAMP}"

mkdir -p "$ROOT/backups"

tar -czf "$OUT-runtime.tar.gz" \
  -C "$ROOT" \
  data \
  config/searxng

cat > "$OUT-manifest.txt" <<EOF
AI Web Agent Stack backup
Created: $(date --iso-8601=seconds)

Included:
- data/
- config/searxng/

Not included:
- .env
- agent-browser encryption key
- browser authentication state
EOF

echo "Created:"
echo "  $OUT-runtime.tar.gz"
echo "  $OUT-manifest.txt"

echo
echo "Optional secrets backup (store separately):"
echo "  install a secure password manager or encrypted offline vault"
echo "  copy: $ROOT/.env"
echo "  copy: $ROOT/state/agent-browser-encryption-key.env"
echo "Never commit those files."
