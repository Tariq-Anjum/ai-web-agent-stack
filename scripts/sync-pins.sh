#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -f "$ROOT/.env" ]] || { echo 'Generate .env with install.sh first.' >&2; exit 1; }
# shellcheck source=/dev/null
source "$ROOT/versions/pins.env"
umask 077
tmp="$(mktemp "$ROOT/.env.pins.XXXXXX")"
trap 'rm -f -- "$tmp"' EXIT
# Preserve secrets, ports, concurrency and local settings; only synchronize pins.
awk -v searxng="$SEARXNG_VERSION" -v crawl="$CRAWL4AI_IMAGE" '
  /^SEARXNG_VERSION=/ { if (!s++) print "SEARXNG_VERSION=" searxng; next }
  /^CRAWL4AI_IMAGE=/ { if (!c++) print "CRAWL4AI_IMAGE=" crawl; next }
  { print }
  END {
    if (!s) print "SEARXNG_VERSION=" searxng
    if (!c) print "CRAWL4AI_IMAGE=" crawl
  }
' "$ROOT/.env" > "$tmp"
chmod 600 "$tmp"
mv -- "$tmp" "$ROOT/.env"
