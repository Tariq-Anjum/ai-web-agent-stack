# Open-Source Web Agent Stack — Research Review + Implementation

Goal: one local, 100% open-source, low-resource stack that gives any AI agent/harness on your
machine (Claude Code, pi coding agent, Hermes Agent, Claude Desktop/Cowork, etc.) the ability to
search, browse, fill forms, extract clean research content, use vision only when needed, and
push through bot-detection only as a last resort — all with minimal tokens per tool call.

---

## Part 1 — Research Review

### The chosen stack (5 moving parts, 2 of which you already have running)

| Layer | Tool | License | Why |
|---|---|---|---|
| Search | **SearXNG** (already running) | AGPL-3.0 | Your existing meta-search — no change needed |
| Interactive browsing / forms / login flows (default engine) | **agent-browser** (Vercel Labs) + **Lightpanda** engine | Apache-2.0 (agent-browser) / AGPL-3.0 (Lightpanda) | Purpose-built for AI agents: accessibility-tree snapshots instead of raw HTML, ~88-95% fewer tokens than Playwright MCP when run in interactive (`-i`) mode, native CLI + native MCP server |
| Interactive browsing fallback (stealth-capable) | **agent-browser** pointed at self-hosted **Steel.dev** browser | Apache-2.0 (agent-browser) / AGPL-3.0 (Steel) | Replaces bare Chrome-for-Testing. Same Docker footprint, but ships anti-detection plugins + session/cookie persistence + debugging UI out of the box |
| Research / bulk fetch / clean markdown / progressive anti-bot | **Crawl4AI** (docker) | Apache-2.0 | LLM-ready markdown output, built-in 3-tier bot-detection escalation, self-hosted for free |
| Vision (only when needed) | Screenshot from either browsing tool above | — | Not a new service — a capability you already have |

### Why not the obvious defaults

- **Not `browser-use`** — drives a full Chromium session per task, LLM decides every step. ~112k stars but heavy. Independent r/devops reports confirm it underperforms for many users. Fallback only, not daily driver on 16GB RAM.
- **Not full self-hosted Firecrawl** — needs Redis, RabbitMQ, Postgres, a Playwright microservice, recommends 8-12GB RAM. Crawl4AI does the same job in one container, ~300MB-1GB idle. A Reddit n8n user independently confirmed Crawl4AI beat self-hosted Firecrawl on flaky doc sites.
- **Not Camoufox/nodriver/Patchright as a default service** — Crawl4AI's built-in UndetectedAdapter covers second-attempt escalation. Independent comparisons rate Crawl4AI's native stealth low (star) vs Camoufox (5 stars) — which is why Camoufox stays a documented escape hatch, not an always-on fourth service.
- **Not bare Chrome-for-Testing as fallback anymore** — zero anti-detection. Independent reviews (dev.to, third-party vendor-review sites) confirm Steel.dev self-hosted gives anti-detection plugins, session persistence, and a debug UI for the same Docker cost as raw Chrome.

### How the pieces divide the work

- **agent-browser + Lightpanda (default)** = hands for the common case. Token-efficient ONLY when invoked with `-i` (interactive-elements-only) flag — independent testing shows savings evaporate, sometimes regress worse than Playwright MCP, without it.
- **agent-browser + Steel.dev (fallback)** = hands for the hard case — same CLI, pointed at a stealth-capable browser session.
- **Crawl4AI** = the reader — URL to clean markdown, with automatic escalation.
- **SearXNG** = the index — question to ranked URL list.

### Honest resource budget (16GB RAM, Ryzen 7840U)

| Component | Idle | Active |
|---|---|---|
| SearXNG | ~150-300MB | same |
| Crawl4AI container (shm_size 2g) | ~300MB-1GB | ~500MB-1.5GB per concurrent crawl |
| agent-browser + Lightpanda session | near 0 | ~60-150MB per session |
| agent-browser + Steel.dev fallback | ~300-500MB idle | ~250-800MB per session |

Leave Steel.dev as fallback, not default — Lightpanda's 9-16x lower memory footprint is still the point. Avoid running a big local Ollama model concurrently with a Chrome-engine (Steel) session — that's where 16GB gets tight.

---

## Part 2 — Step-by-Step Implementation

### Step 0 — Directory layout

```bash
mkdir -p ~/ai-tools/web-stack
cd ~/ai-tools/web-stack
```

### Step 1 — Add Crawl4AI and Steel.dev to your existing docker-compose

```yaml
  crawl4ai:
    image: unclecode/crawl4ai:latest
    container_name: crawl4ai
    restart: unless-stopped
    shm_size: 2g
    ports:
      - "11235:11235"
    environment:
      - MAX_CONCURRENT_TASKS=4
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11235/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  steel-browser:
    image: ghcr.io/steel-dev/steel-browser:latest
    container_name: steel-browser
    restart: unless-stopped
    shm_size: 2g
    ports:
      - "3000:3000"
      - "3001:3001"
    environment:
      - HOST=0.0.0.0
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

```bash
cd ~/ai-tools
docker compose up -d crawl4ai steel-browser
docker compose ps
curl http://localhost:11235/health
curl http://localhost:3000/health
```

### Step 2 — Install Lightpanda

```bash
yay -S lightpanda-nightly-bin
# or: curl -fsSL https://pkg.lightpanda.io/install.sh | bash
lightpanda --help
```

### Step 3 — Install agent-browser

```bash
npm install -g agent-browser
agent-browser install
agent-browser doctor
mkdir -p ~/.config/agent-browser
cat > ~/.config/agent-browser/agent-browser.json << 'EOF'
{
  "engine": "lightpanda"
}
EOF
```

Always use `-i`:

```bash
agent-browser open https://example.com
agent-browser snapshot -i
agent-browser close
```

Steel.dev fallback:

```bash
agent-browser open https://example.com --engine cdp --cdp-url http://localhost:3000
```

(Confirm the exact CDP flag against `agent-browser --help` for your installed version.)

### Step 4 — 3-tier fetch/escalate wrapper for Crawl4AI

See `web_fetch.sh` in this repo. Tier1 plain -> Tier2 stealth -> Tier3 undetected adapter. If Tier3 also blocked, route through Steel.dev fallback instead of retrying Crawl4AI.

### Step 5 — One-command launcher

See `start-web-stack.sh` in this repo.

### Step 6 — Make it globally available

Shell-access agents: use `agent-browser`, `web_fetch.sh`, and SearXNG's HTTP API directly (cheapest, no MCP schema overhead).

MCP-only clients: register agent-browser's native MCP server:

```json
{
  "mcpServers": {
    "agent-browser": {
      "command": "agent-browser",
      "args": ["mcp", "--tools", "all"]
    }
  }
}
```

### Step 7 — Routing logic (see web-tools-index.md for the canonical version)

1. Search -> SearXNG
2. Read/research -> web_fetch.sh (Crawl4AI 3-tier escalation; fall through to Steel.dev if Tier3 fails)
3. Interact -> agent-browser + Lightpanda (`-i` mandatory); fallback to Steel.dev via `--engine cdp`
4. Vision -> agent-browser screenshot --annotate (last resort)
5. Complex forms -> agent-browser (step 3), no separate tool

---

## Verification checklist

```bash
curl -s "http://localhost:8080/search?q=test&format=json" | head -c 200
curl -s http://localhost:11235/health
curl -s http://localhost:3000/health
agent-browser open https://example.com && agent-browser snapshot -i && agent-browser close
agent-browser open https://example.com --engine cdp --cdp-url http://localhost:3000
~/ai-tools/web-stack/web_fetch.sh "https://example.com" | head -c 200
agent-browser mcp --tools all &
```

---

## If you ever need more (escape hatches, not defaults)

- Site beats Crawl4AI's undetected adapter AND Steel.dev: install Camoufox (Firefox-engine patches, independently rated strongest, but heaviest).
- Need raw CDP control: `pip install nodriver` (same lineage as Crawl4AI's adapter).
- Need deterministic, code-owned automation: Playwright directly, or Playwright + Stagehand.

None of these are part of the default stack — add only if a real site defeats what's above.

---

## Sources / evidence used for this revision

- Lightpanda memory/speed claims and beta-stage limitations: independent GitHub issue tracker review and Dispatch AI repo audit.
- agent-browser token-efficiency figures (88-95% reduction) and the mandatory `-i` flag caveat: independent Reddit testing (crowdtamers.com data) plus a countervailing report of token regression without `-i`.
- Crawl4AI vs Scrapling vs Camoufox stealth ratings: independent third-party tool-comparison matrices, not vendor-published benchmarks.
- Steel.dev self-hosted viability vs bare Chrome-for-Testing and vs Browserbase: independent dev.to comparison article and third-party vendor-review site, plus unprompted Reddit (r/LocalLLaMA, r/devops) usage reports.
- browser-use heaviness: independent r/devops usage report.
- Self-published/marketing-only numbers (Scrapling's "774x faster" claim, Plasmate's "17.5x token compression," Firecrawl/Bright Data/ZenRows vendor benchmarks) were explicitly excluded per project policy: no self-published benchmark numbers accepted without independent corroboration.
