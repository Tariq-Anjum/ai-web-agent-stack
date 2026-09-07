## web-research / web-browse

1. **Search** -> SearXNG (existing) — turn the question into candidate URLs.
2. **Read a URL / research / bulk pages** -> `web_fetch.sh <url>`
   (Crawl4AI, 3-tier escalation: plain -> stealth -> undetected. Tier 3 only fires if tiers 1-2
   look blocked — don't reach for it directly. If Tier 3 also gets blocked, fall through to
   Steel.dev instead of retrying Crawl4AI.)
3. **Interact with a page** (click, fill forms, login flows, multi-step navigation) ->
   `agent-browser` CLI, default engine = Lightpanda. **Always pass `-i` on snapshot calls** —
   this is what delivers the token savings; skipping it can make agent-browser cost *more*
   tokens than Playwright MCP, not fewer.
   - If the page misrenders or needs full JS/Web API support Lightpanda doesn't cover, or the
     site fingerprints headless browsers, retry against the Steel.dev fallback:
     `agent-browser open <url> --engine cdp --cdp-url http://localhost:3000`.
4. **Vision needed** (canvas UI, layout-dependent reasoning, visual CAPTCHA elements) ->
   `agent-browser screenshot --annotate`, then pass the image to the driving model. Only reach
   for this when steps 2-3's text/accessibility-tree output isn't enough — last resort, not default.
5. **Complex multi-step forms** -> still `agent-browser` (step 3) — no separate tool. Its
   `fill`/`click`/`select` primitives already handle this; escalate to the Steel.dev fallback
   only if Lightpanda can't render the form correctly or gets blocked.

### Tool reference

| Task | Tool | Invocation |
|---|---|---|
| Search | SearXNG | `curl "http://localhost:8080/search?q=<query>&format=json"` |
| Read/research a URL | Crawl4AI (via wrapper) | `~/ai-tools/web-stack/web_fetch.sh <url>` |
| Click/fill/navigate (default) | agent-browser + Lightpanda | `agent-browser open/snapshot -i/click/fill <args>` |
| Click/fill/navigate (stealth fallback) | agent-browser + Steel.dev | `agent-browser open <url> --engine cdp --cdp-url http://localhost:3000` |
| Screenshot for vision | agent-browser | `agent-browser screenshot --annotate` |
| MCP-only clients | agent-browser native MCP | `agent-browser mcp --tools all` |
| Steel.dev session viewer (debugging) | Steel.dev UI | `http://localhost:3001` |

### Change log

- Replaced bare Chrome-for-Testing fallback with self-hosted Steel.dev (anti-detection +
  session persistence built in, same Docker footprint) — independently verified, not a
  vendor-only claim.
- Made `-i` flag mandatory on all agent-browser snapshot calls — token savings are conditional
  on this, per independent test reports.
- Evaluated Scrapling, Plasmate, Firecrawl-hosted, Bright Data MCP, browser-use, and other
  entries from awesome-ai-web-scraping / awesome-web-agents lists — none cleared the
  independent-evidence bar for inclusion in the default stack. See README "Sources / evidence"
  section for full reasoning.
