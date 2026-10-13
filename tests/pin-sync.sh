#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
temp="$(mktemp -d)"
trap 'rm -rf -- "$temp"' EXIT
mkdir -p "$temp/scripts" "$temp/versions"
cp "$ROOT/scripts/sync-pins.sh" "$temp/scripts/"
cp "$ROOT/versions/pins.env" "$temp/versions/"
printf '%s\n' \
  'CRAWL4AI_API_TOKEN=fixture-token' \
  'SEARXNG_PORT=18080' \
  'CRAWL4AI_CONCURRENCY=2' \
  'LOCAL_SETTING=preserved' \
  'SEARXNG_VERSION=obsolete' \
  'SEARXNG_VERSION=duplicate' \
  'CRAWL4AI_IMAGE=obsolete' > "$temp/.env"
"$temp/scripts/sync-pins.sh"
[[ "$(stat -c '%a' "$temp/.env")" == 600 ]]
grep -Fxq 'CRAWL4AI_API_TOKEN=fixture-token' "$temp/.env"
grep -Fxq 'SEARXNG_PORT=18080' "$temp/.env"
grep -Fxq 'CRAWL4AI_CONCURRENCY=2' "$temp/.env"
grep -Fxq 'LOCAL_SETTING=preserved' "$temp/.env"
[[ "$(grep -c '^SEARXNG_VERSION=' "$temp/.env")" == 1 ]]
for name in SEARXNG_VERSION CRAWL4AI_IMAGE; do
  grep -Fxq "$(grep "^$name=" "$ROOT/versions/pins.env")" "$temp/.env"
done
cp "$temp/.env" "$temp/before"
"$temp/scripts/sync-pins.sh"
cmp -s "$temp/.env" "$temp/before"
echo 'PASS pin sync: canonical pins, preserved secrets/settings, mode 600, idempotent'
