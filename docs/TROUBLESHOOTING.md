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

## Docker network issue

```bash
docker network inspect web-stack
```

Expected members:

```text
crawl4ai
searxng
```

Recreate if necessary:

```bash
docker network rm web-stack 2>/dev/null || true
docker network create web-stack
docker compose \
  --env-file .env \
  -f compose/docker-compose.yml \
  up -d
```
