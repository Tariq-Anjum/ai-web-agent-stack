#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1" >&2; exit 1; }

for cmd in docker curl jq git openssl node npm agent-browser; do
  command -v "$cmd" >/dev/null 2>&1 && pass "$cmd" || fail "$cmd missing"
done

docker compose version >/dev/null 2>&1 && pass "docker compose" || fail "docker compose missing"

test -f "$ROOT/compose/docker-compose.yml" && pass "compose file" || fail "compose file missing"
test -f "$ROOT/config/searxng/settings.yml" && pass "SearXNG settings" || fail "SearXNG settings missing"
test -f "$ROOT/versions/pins.env" && pass "version pins" || fail "version pins missing"

if [[ -f "$ROOT/.env" ]]; then
  [[ "$(stat -c '%a' "$ROOT/.env")" == "600" ]] && pass ".env mode 600" || fail ".env permissions"
else
  printf 'INFO  .env not generated yet\n'
fi

node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 24 ? 0 : 1)' &&
  pass "Node >= 24" || fail "Node < 24"

docker info >/dev/null 2>&1 && pass "Docker daemon" || fail "Docker daemon unavailable"

echo
echo "Doctor complete."
