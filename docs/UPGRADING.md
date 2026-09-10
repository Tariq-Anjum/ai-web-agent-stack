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
docker compose config -q
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

## Release discipline

Node.js is treated as a host prerequisite and is not changed automatically by the stack updater. Keep Node.js >= 24.

After a successful upgrade:

1. run `./scripts/verify.sh`;
2. inspect logs;
3. update `CHANGELOG.md`;
4. commit the pin change;
5. tag a release when the state is known-good.
