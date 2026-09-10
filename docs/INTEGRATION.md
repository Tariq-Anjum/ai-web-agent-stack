# Integration

## Search

Preferred agent-facing interface:

```bash
web-search "your query"
```

Machine-readable:

```bash
web-search --compact "your query"
```

URL-only:

```bash
web-search --urls "your query"
```

## Crawl4AI

The local API is:

```text
http://127.0.0.1:11235
```

Authentication:

```text
Authorization: Bearer $CRAWL4AI_API_TOKEN
```

The OpenAPI document is available at:

```text
http://127.0.0.1:11235/openapi.json
```

## Browser

The browser automation CLI is:

```bash
agent-browser
```

Typical flow:

```bash
agent-browser open https://example.com
agent-browser snapshot
agent-browser close
```

Use domain allowlisting/content boundaries where the consuming agent needs additional containment.
