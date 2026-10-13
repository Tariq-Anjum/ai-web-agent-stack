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

## Read a URL

```bash
web-read https://example.com
web-read --query "research focus" https://example.com
web-read -q "research focus" https://example.com
web-read --help
```

Successful stdout is extracted Markdown, not the API envelope. Check exit status;
never treat failed extraction as usable content. Logs/reasons go to stderr.
Ordinary reads use deterministic pruning; query reads use BM25, without an LLM.
See `WEB-READ.md` for acceptance rules and API details.

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

For clicking, filling and navigation, prefer compact interactive accessibility
output:

```bash
agent-browser open https://example.com
agent-browser snapshot -i -c
# click/fill/navigation commands as needed
agent-browser close
```

For page reading, broad inspection or debugging, preserve normal/full snapshots:

```bash
agent-browser snapshot
```

Interactive-only output omits non-interactive page text. `-i` is not mandatory
for all browser use; select the snapshot form appropriate to the task.

Use domain allowlisting/content boundaries where the consuming agent needs additional containment.
