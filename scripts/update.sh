#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -f "$ROOT/.env" ]] || { echo 'Run scripts/install.sh first.' >&2; exit 1; }
# Reuse the idempotent installation path: sync pins, preserve secrets, verify.
exec "$ROOT/scripts/install.sh"
