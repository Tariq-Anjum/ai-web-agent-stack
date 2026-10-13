# Upgrading

Do not upgrade everything implicitly.

Update one component deliberately.

## Agent-browser

Change:

```text
versions/pins.env
```

then:

```bash
./scripts/update.sh
```

## Crawl4AI

Update `CRAWL4AI_IMAGE` to the desired image digest.

Validate:

```bash
docker compose --env-file .env -f compose/docker-compose.yml config -q
./scripts/verify.sh
```

## SearXNG

Update:

```text
SEARXNG_VERSION
```

Then:

```bash
./scripts/update.sh
```

## v1.1.0 compatibility

Approved pins are Crawl4AI 0.9.4 and agent-browser 0.39.0. Both were tested before
pin replacement. SearXNG is unchanged. Do not use `latest` or implicitly jump to
later releases. Review the candidate image's authenticated `/openapi.json` and
real extraction behavior, not historical request examples.

The updater now synchronizes image pins in existing `.env` files and reuses the
idempotent installer, including command symlinks and complete verification. It
preserves secrets and the browser encryption key. Node remains a host prerequisite.

For reversible package evaluation, use an isolated HOME/npm prefix rather than
replacing a working global installation. See `VERIFICATION-v1.1.0.md`.

## Release discipline

Node.js is treated as a host prerequisite and is not changed automatically by the stack updater. Keep Node.js >= 24.

After a successful upgrade:

1. run `./scripts/verify.sh`;
2. inspect logs;
3. update `CHANGELOG.md`;
4. commit the pin change;
5. tag a release when the state is known-good.
