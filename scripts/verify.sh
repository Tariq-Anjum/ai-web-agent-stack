#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export WEB_STACK_HOME="$ROOT"
export PATH="$ROOT/bin:$HOME/.local/bin:$PATH"

set -a
source "$ROOT/.env"
set +a

"$ROOT/bin/web-stack" status
"$ROOT/bin/web-stack" verify

echo
echo "===== AGENT-BROWSER ====="
agent-browser --version
agent-browser doctor

echo
echo "===== BROWSER SMOKE ====="
agent-browser open https://example.com
agent-browser snapshot >/tmp/agent-browser-snapshot.txt
agent-browser get title
agent-browser get url
agent-browser screenshot "$ROOT/state/agent-browser-smoke.png"
agent-browser close

test -s "$ROOT/state/agent-browser-smoke.png"

echo
echo "===== IMAGE PIN ====="
grep '^CRAWL4AI_IMAGE=' "$ROOT/.env"

echo
echo "===== SECRETS ====="
test "$(stat -c '%a' "$ROOT/.env")" = "600"
test "$(stat -c '%a' "$ROOT/state/agent-browser-encryption-key.env")" = "600"
echo "PASS: secret file permissions"

echo
echo "===== REDIS HOST SETTING ====="
if sysctl vm.overcommit_memory >/dev/null 2>&1; then
  sysctl vm.overcommit_memory
fi

echo
echo "FINAL VERIFICATION: PASS"
