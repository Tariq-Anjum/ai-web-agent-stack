#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export WEB_STACK_HOME="$ROOT"
export PATH="$ROOT/bin:$HOME/.local/bin:$PATH"

"$ROOT/scripts/doctor.sh"
"$ROOT/bin/web-stack" verify

echo "Smoke test: PASS"
