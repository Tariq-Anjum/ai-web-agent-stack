#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export WEB_STACK_HOME="$ROOT"
export PATH="$ROOT/bin:$HOME/.local/bin:$PATH"

pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1" >&2; exit 1; }

for cmd in docker curl jq git openssl node npm agent-browser readlink; do
  command -v "$cmd" >/dev/null 2>&1 && pass "$cmd" || fail "$cmd missing"
done
docker compose version >/dev/null 2>&1 && pass "docker compose" || fail "docker compose missing"
for file in compose/docker-compose.yml config/searxng/settings.yml versions/pins.env scripts/read-content.cjs; do
  [[ -f "$ROOT/$file" ]] && pass "$file" || fail "$file missing"
done
for command_name in web-stack web-search web-read; do
  [[ -x "$ROOT/bin/$command_name" ]] && pass "$command_name" || fail "$command_name missing/not executable"
done
node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 24 ? 0 : 1)' &&
  pass "Node >= 24" || fail "Node < 24"
docker info >/dev/null 2>&1 && pass "Docker daemon" || fail "Docker daemon unavailable"

# shellcheck source=/dev/null
source "$ROOT/versions/pins.env"
[[ "$CRAWL4AI_IMAGE" =~ ^unclecode/crawl4ai@sha256:[a-f0-9]{64}$ ]] ||
  fail "Crawl4AI must be digest pinned"
[[ "$SEARXNG_VERSION" =~ ^[0-9]{4}\.[0-9]+\.[0-9]+-[a-f0-9]+$ ]] ||
  fail "SearXNG must be release/commit pinned"
[[ "$AGENT_BROWSER_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] ||
  fail "agent-browser must be version pinned"
expected_searxng="$SEARXNG_VERSION"
expected_crawl="$CRAWL4AI_IMAGE"
expected_browser="$AGENT_BROWSER_VERSION"
pass "immutable infrastructure/package pins"

if [[ -f "$ROOT/.env" ]]; then
  [[ "$(stat -c '%a' "$ROOT/.env")" == 600 ]] || fail ".env permissions"
  pass ".env mode 600"
  set -a
  # shellcheck source=/dev/null
  source "$ROOT/.env"
  set +a
  [[ "$CRAWL4AI_IMAGE" == "$expected_crawl" && "$SEARXNG_VERSION" == "$expected_searxng" ]] ||
    fail "runtime pins differ from versions/pins.env; run scripts/update.sh"
  for name in CRAWL4AI_API_TOKEN SECRET_KEY REDIS_PASSWORD SEARXNG_SECRET; do
    [[ -n "${!name:-}" ]] || fail "$name missing"
  done
  [[ "${CRAWL4AI_CONCURRENCY:-2}" =~ ^[1-9][0-9]?$ ]] || fail "invalid crawl concurrency"
  [[ "$(stat -c '%a' "$ROOT/state/agent-browser-encryption-key.env" 2>/dev/null)" == 600 ]] ||
    fail "browser encryption key missing or not mode 600"
  # shellcheck source=/dev/null
  source "$ROOT/state/agent-browser-encryption-key.env"
  [[ "${AGENT_BROWSER_ENCRYPTION_KEY:-}" =~ ^[a-f0-9]{64}$ ]] || fail "invalid browser encryption key"
  settings_file="${SEARXNG_SETTINGS_FILE:-settings.yml}"
  [[ "$settings_file" =~ ^[A-Za-z0-9._-]+\.yml$ && -r "$ROOT/config/searxng/$settings_file" ]] ||
    fail "invalid or missing local SearXNG settings file"
  [[ "${WEB_STACK_NETWORK_EXTERNAL:-false}" == false || "${WEB_STACK_NETWORK_EXTERNAL:-false}" == true ]] ||
    fail "invalid external network setting"
  pass "runtime pins, secrets, browser key, bounded concurrency and selected settings"

  dc() { docker compose --env-file "$ROOT/.env" -f "$ROOT/compose/docker-compose.yml" "$@"; }
  dc config -q
  dc config --format json | jq -e '
    [.services[].ports[] | .host_ip] | length == 2 and all(. == "127.0.0.1")
  ' >/dev/null || fail "published ports must be loopback-only"
  pass "Compose configuration and localhost-only exposure"
else
  printf 'INFO  .env not generated yet\n'
fi
[[ "$(agent-browser --version)" == "agent-browser $expected_browser" ]] ||
  fail "installed agent-browser does not match pin"
pass "agent-browser $expected_browser"
echo "Doctor complete."
