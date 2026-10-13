# Architecture

```text
                    AI agent / Hermes
                           |
                    web-search CLI
                           |
                           v
                      SearXNG
                           |
                     search engines
                           |
                           +------------------+
                                              |
                                              v
                                web-read → Crawl4AI API
                                              |
                                      browser/extraction
                                              |
                                              v
                                          Chromium
                                              ^
                                              |
                                     agent-browser CLI
```

## Service boundaries

### SearXNG

Search discovery and aggregation.

Host endpoint:

```text
127.0.0.1:8080
```

Docker endpoint:

```text
searxng:8080
```

### Crawl4AI

Authenticated extraction/crawling service. `web-read` calls its `/md` endpoint
and passes the response through one small Node-based content validator. Ordinary
reads use `PruningContentFilterLXML` fit Markdown; query reads use BM25. These are
on-demand commands using existing Node/curl/jq dependencies, not new services.

Host endpoint:

```text
127.0.0.1:11235
```

Docker endpoint:

```text
crawl4ai:11235
```

### agent-browser

Interactive browser control from the host.

It is intentionally separate from Crawl4AI. This avoids coupling:

- search
- extraction
- interactive browser automation

into one process.

## Networking

Both containers share the `web-stack` Docker network.

Host-exposed ports are loopback-only. Optional project/container/network name
and port settings allow isolated test deployments without changing the defaults.
Compose creates/manages the shared network for fresh installs. An explicitly
external pre-existing network can be reused without changing its ownership.
SearXNG and Crawl4AI belong to the same canonical `web-stack` Compose project.

## Intentional deferrals

No new idle daemon, database, cache, MCP server, or cloud dependency is added.
A browserless `curl_cffi + Trafilatura/selectolax` pilot is deferred until measured
Crawl4AI bottlenecks justify it. Lightpanda is a potential optional future engine,
not the default. Steel/Camoufox/Patchright remain specialist future pilots only
after measured legitimate site failures. Valkey, extra Redis, SQLite caching,
FastMCP, Docling, PyMuPDF4LLM and site-specific interceptors are not v1.1 scope.

## Persistence

SearXNG configuration is source-controlled.

Mutable cache/data is kept in `data/`.

Secrets remain in `.env`.

Browser authentication state remains outside the repository under `$HOME/.agent-browser`.
