#!/usr/bin/env bash
# One command to bring up the whole web-agent stack.
# Adjust AI_TOOLS_DIR if your compose file lives somewhere other than ~/ai-tools.
set -e

AI_TOOLS_DIR="${AI_TOOLS_DIR:-$HOME/ai-tools}"

echo "Starting SearXNG + Crawl4AI + Steel.dev..."
cd "$AI_TOOLS_DIR" && docker compose up -d searxng crawl4ai steel-browser

echo "Checking agent-browser..."
command -v agent-browser >/dev/null || { echo "agent-browser not installed (npm install -g agent-browser)"; exit 1; }
agent-browser doctor --quick

echo "Checking Lightpanda..."
command -v lightpanda >/dev/null || echo "warning: lightpanda not on PATH (yay -S lightpanda-nightly-bin)"

echo ""
echo "All services up."
echo "  SearXNG:        http://localhost:8080"
echo "  Crawl4AI:       http://localhost:11235 (playground: /playground)"
echo "  Steel.dev API:  http://localhost:3000"
echo "  Steel.dev UI:   http://localhost:3001"
echo "  agent-browser engine: $(cat "$HOME/.config/agent-browser/agent-browser.json" 2>/dev/null || echo default)"
