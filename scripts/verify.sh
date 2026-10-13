#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export WEB_STACK_HOME="$ROOT"
export PATH="$ROOT/bin:$HOME/.local/bin:$PATH"

"$ROOT/scripts/doctor.sh"
"$ROOT/tests/content-validator.sh"
"$ROOT/tests/web-read.sh"
"$ROOT/tests/pin-sync.sh"
set -a
# shellcheck source=/dev/null
source "$ROOT/.env"
set +a
# shellcheck source=/dev/null
source "$ROOT/state/agent-browser-encryption-key.env"

"$ROOT/bin/web-stack" status
"$ROOT/bin/web-stack" verify

echo "===== RUNNING IMAGE PINS ====="
dc() { docker compose --env-file "$ROOT/.env" -f "$ROOT/compose/docker-compose.yml" "$@"; }
for service in crawl4ai searxng; do
  id="$(dc ps -q "$service")"
  [[ -n "$id" ]]
  image="$(docker inspect --format '{{.Config.Image}}' "$id")"
  case "$service" in
    crawl4ai) [[ "$image" == "$CRAWL4AI_IMAGE" ]] ;;
    searxng) [[ "$image" == "docker.io/searxng/searxng:$SEARXNG_VERSION" ]] ;;
  esac
  printf '%s: %s\n' "$service" "$image"
done

echo "===== AGENT-BROWSER ====="
agent-browser --version
agent-browser doctor

echo "===== BROWSER SMOKE ====="
# Never interfere with an agent's default browser session. Always clean up,
# including on assertion/command failure; store artifacts only in ignored state.
session="web-stack-verify-$$"
snapshot="$(mktemp "$ROOT/state/snapshot.XXXXXX")"
cleanup() {
  agent-browser --session "$session" close >/dev/null 2>&1 || true
  rm -f -- "$snapshot"
}
trap cleanup EXIT
agent-browser --session "$session" open https://example.com
agent-browser --session "$session" snapshot > "$snapshot"
grep -Fq 'documentation examples' "$snapshot"
agent-browser --session "$session" snapshot -i -c > "$snapshot"
grep -Fq 'Learn more' "$snapshot"
[[ "$(agent-browser --session "$session" get title)" == 'Example Domain' ]]
[[ "$(agent-browser --session "$session" get url)" == 'https://example.com/' ]]
rm -f -- "$ROOT/state/agent-browser-smoke.png"
agent-browser --session "$session" screenshot "$ROOT/state/agent-browser-smoke.png"
test -s "$ROOT/state/agent-browser-smoke.png"
[[ "$(od -An -tx1 -N8 "$ROOT/state/agent-browser-smoke.png" | tr -d ' \n')" == 89504e470d0a1a0a ]]
agent-browser --session "$session" close
trap - EXIT
rm -f -- "$snapshot"

echo "===== REDIS HOST SETTING (informational) ====="
if sysctl vm.overcommit_memory >/dev/null 2>&1; then
  sysctl vm.overcommit_memory
fi
echo "FINAL VERIFICATION: PASS"
