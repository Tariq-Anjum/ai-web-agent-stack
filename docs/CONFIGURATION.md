# Configuration

## Environment file

The runtime environment is:

```text
.env
```

Permissions should be:

```text
600
```

## Important variables

```text
SEARXNG_PORT
SEARXNG_VERSION
CRAWL4AI_PORT
CRAWL4AI_CONCURRENCY
CRAWL4AI_IMAGE
CRAWL4AI_API_TOKEN
SECRET_KEY
REDIS_PASSWORD
SEARXNG_SECRET
```

## Version pinning

Edit:

```text
versions/pins.env
```

Then run:

```bash
./scripts/update.sh
```

Record intentional changes in `CHANGELOG.md`.

## Search output

The SearXNG wrapper requests JSON:

```text
/search?format=json
```

`web-search` limits result count and snippet size for agent-friendly output.
