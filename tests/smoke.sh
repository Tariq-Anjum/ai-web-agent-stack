#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# One complete gate, including real services and browser (not merely mocks).
"$ROOT/scripts/verify.sh"
echo "Smoke test: PASS"
