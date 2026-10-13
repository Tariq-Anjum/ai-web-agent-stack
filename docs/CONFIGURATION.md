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
COMPOSE_PROJECT_NAME
SEARXNG_CONTAINER_NAME
CRAWL4AI_CONTAINER_NAME
WEB_STACK_NETWORK
WEB_STACK_NETWORK_EXTERNAL
SEARXNG_SETTINGS_FILE
```

`COMPOSE_PROJECT_NAME` defaults to `web-stack`. Both services are managed by
canonical Compose. Fresh installs let Compose manage `web-stack` networking.
For a pre-existing shared network, `WEB_STACK_NETWORK_EXTERNAL=true` preserves
external ownership and prevents teardown from removing it.

`SEARXNG_SETTINGS_FILE` defaults to source-controlled `settings.yml`. An ignored
`settings.local.yml` can preserve existing local SearXNG behavior during migration.
Keep sensitive overrides private and back them up separately from published source.
The pinned SearXNG image runs as root. `FORCE_OWNERSHIP=false` prevents its
entrypoint from recursively changing ownership of host source/config/cache files;
this keeps owner-private local configuration readable to the host backup tooling.
Startup ownership warnings are expected with user-owned bind mounts and do not
indicate a failed crawl/search; the functional gate verifies actual operation.

## Version pinning

Edit:

```text
versions/pins.env
```

Then run:

```bash
./scripts/update.sh
```

Install/update copies the image pins into `.env` atomically without replacing
secrets, ports or concurrency. Doctor fails if runtime pins differ from the
canonical pins or if the installed agent-browser version differs.

Record intentional changes in `CHANGELOG.md`.

## Search output

The SearXNG wrapper requests JSON:

```text
/search?format=json
```

`web-search` limits result count and snippet size for agent-friendly output.
It reads `SEARXNG_PORT` from the selected checkout's `.env`; `SEARXNG_URL` can
explicitly override the endpoint.

`web-read` uses `CRAWL4AI_PORT` and the API token from that same `.env`. Its
request timeout is controlled by `WEB_READ_TIMEOUT` (default 90, range 1..300
seconds). See `WEB-READ.md`.
