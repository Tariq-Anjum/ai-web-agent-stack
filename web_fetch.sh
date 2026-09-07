#!/usr/bin/env bash
# Usage: web_fetch.sh <url>
# Tries a plain fetch first, escalates to stealth, then to the undetected
# (nodriver-derived) browser adapter only if earlier tiers look blocked.
# If Tier 3 also gets blocked, route the job through the Steel.dev fallback instead
# (see README.md Step 3 / web-tools-index.md) rather than retrying this script.
# Requires: Crawl4AI running at localhost:11235 (see docker-compose.crawl4ai.yml)
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <url>" >&2
  exit 1
fi

URL="$1"
ENDPOINT="http://localhost:11235/crawl"

is_blocked() {
  local body="$1"
  if [[ -z "$body" ]] || grep -qiE "access denied|are you a human|attention required|cf-error|captcha" <<<"$body"; then
    return 0
  fi
  return 1
}

fetch() {
  local browser_json="$1"
  curl -s -X POST "$ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "{\"urls\": [\"$URL\"], \"browser_config\": $browser_json}"
}

# Tier 1 — plain, fastest, cheapest
RESULT=$(fetch '{"headless": true}')
if ! is_blocked "$RESULT"; then echo "$RESULT"; exit 0; fi

# Tier 2 — stealth mode (JS fingerprint patches)
echo "tier1 blocked, retrying with stealth..." >&2
RESULT=$(fetch '{"headless": true, "enable_stealth": true}')
if ! is_blocked "$RESULT"; then echo "$RESULT"; exit 0; fi

# Tier 3 — undetected adapter (deep CDP patches, nodriver-derived), second attempt only
echo "tier2 blocked, retrying with undetected adapter..." >&2
RESULT=$(fetch '{"headless": false, "enable_stealth": true, "undetected": true}')
if ! is_blocked "$RESULT"; then echo "$RESULT"; exit 0; fi

echo "tier3 (Crawl4AI undetected adapter) also blocked. Route this URL through the Steel.dev fallback instead:" >&2
echo "  agent-browser open \"$URL\" --engine cdp --cdp-url http://localhost:3000" >&2
echo "$RESULT"
