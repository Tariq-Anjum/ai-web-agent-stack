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
                                      Crawl4AI API
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

Authenticated extraction/crawling service.

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

Host-exposed ports are loopback-only by default.

## Persistence

SearXNG configuration is source-controlled.

Mutable cache/data is kept in `data/`.

Secrets remain in `.env`.

Browser authentication state remains outside the repository under `$HOME/.agent-browser`.
