# Troubleshooting

## Check everything

```bash
./scripts/doctor.sh
./scripts/verify.sh
```

## Crawl4AI is unhealthy

```bash
web-stack status
web-stack logs
```

Check that `.env` contains:

```text
CRAWL4AI_API_TOKEN
SECRET_KEY
REDIS_PASSWORD
CRAWL4AI_IMAGE
```

Do not print their values publicly.

## SearXNG works in browser but JSON is empty

Check:

```bash
curl -fsS \
  --get \
  --data-urlencode 'q=test' \
  --data-urlencode 'format=json' \
  http://127.0.0.1:8080/search |
  jq '{query, result_count: (.results | length)}'
```

## Browser fails to launch

```bash
agent-browser doctor
```

If system libraries are missing, install them using the Linux package manager, then rerun:

```bash
agent-browser install --with-deps
```

On Arch/CachyOS, the project does not use apt/dnf/yum, so install missing Chromium libraries with pacman rather than using `--with-deps`.

## web-read rejected a page

Read the concise stderr reason and check the exit status. HTTP/API/crawl failure,
empty filtered output, insufficient visible substance, or a recognized leading
challenge/access-denied instruction is a failure even on HTTP 200. BM25 may
return no relevant content for a query; try a better query or an ordinary read.
Do not silently substitute rejected content. Use agent-browser inspection only
when appropriate and authorized; no anti-bot bypass is provided.

## Docker network issue

```bash
docker network inspect web-stack
```

Expected members:

```text
crawl4ai
searxng
```

For a fresh Compose-managed network, start the canonical stack:

```bash
web-stack up
```

If `.env` intentionally selects `WEB_STACK_NETWORK_EXTERNAL=true`, inspect and
preserve existing members before making network changes. Do not delete a shared
network merely to remove an ownership warning. See `CANONICALIZATION.md`.
