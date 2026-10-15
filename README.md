# Web Stack v1.1.1

Reproducible local web-search and browser automation stack for AI agents.

## Components

- SearXNG — privacy-respecting metasearch
- Crawl4AI — authenticated local web crawling/extraction API
- agent-browser — browser automation CLI
- Chrome for Testing — browser runtime managed by agent-browser
- `web-stack` — lifecycle/status/verification CLI
- `web-search` — compact SearXNG CLI wrapper
- `web-read` — validated fit/BM25 Markdown through the local Crawl4AI API
- shared Docker network for service-to-service communication

The project is designed for two purposes:

1. recover a working web stack after a system rebuild;
2. provide a repeatable deployment that can be shared with another Linux user.

## Current baseline

The functional v1.1 baseline was validated on:

- CachyOS Linux
- x86_64
- Docker 29.x / Compose 5.x
- Crawl4AI 0.9.4 (immutable Docker digest)
- agent-browser 0.39.0 (exact npm version)
- Chrome for Testing 155.0.8059.39 (managed by agent-browser)

Exact image/package pins live in `versions/pins.env`.

## Canonical identity

The canonical project is `web-stack`, backed by
[`Tariq-Anjum/web-stack`](https://github.com/Tariq-Anjum/web-stack). On the owner's
machine its single working/runtime root is `/mnt/MD/AI-tools/web-stack`.
The repository was renamed in place; published history and the functional
`v1.1.0` tag are unchanged. `v1.1.1` is the subsequent canonicalization patch,
not a reimplementation of v1.1. See `docs/CANONICALIZATION.md`.

## Security model

The default deployment binds SearXNG and Crawl4AI to `127.0.0.1` on the host. Crawl4AI API authentication is enabled. Secrets are generated locally and never committed.

Do not commit:

- `.env`
- browser authentication/session state
- encryption keys
- runtime logs
- generated caches
- backup archives containing secrets

## Quick install

For a supported Linux machine, the bootstrap can install Docker and common system dependencies. Node.js >= 24 is required for agent-browser.

Supported primary path:

```bash
git clone https://github.com/Tariq-Anjum/web-stack.git
cd web-stack
./scripts/bootstrap.sh
```

For a machine that already has the prerequisites:

```bash
./scripts/install.sh
```

Then:

```bash
./scripts/verify.sh
```

The installer creates the runtime `.env`, directories, Docker network, containers, and agent-browser browser runtime.

## Common commands

After installation:

```bash
web-stack status
web-stack verify
web-stack logs
web-search "Crawl4AI documentation"
web-read https://example.com
web-read --query "example domain" https://example.com
```

The commands work from the repository itself too:

```bash
./bin/web-stack status
./bin/web-search "Hermes AIOS"
./bin/web-read --help
```

## Reading and interaction

`web-read URL` returns deterministic pruned Markdown; `-q`/`--query` selects
query-focused BM25. No LLM is used. HTTP/crawl failures, empty/trivial content,
and recognized challenge/access-denied pages return non-zero with diagnostics
on stderr. It does not fall back silently to raw content.

For interaction, prefer `agent-browser snapshot -i -c`. For reading, broad
inspection or debugging, use normal/full snapshots as appropriate; `-i` is not
mandatory. See `docs/INTEGRATION.md` and `docs/WEB-READ.md`.

`./scripts/verify.sh` and `./tests/smoke.sh` include fixture/CLI tests, real
Crawl4AI fit/BM25 extraction, authenticated OpenAPI and authentication rejection,
search over host/Docker networking, and a browser/screenshot/close cycle.
External smoke checks require Internet access.

No always-running service or production dependency was added in v1.1.

## Default endpoints

Host-local:

- SearXNG: `http://127.0.0.1:8080`
- Crawl4AI: `http://127.0.0.1:11235`

Docker network:

- SearXNG: `http://searxng:8080`
- Crawl4AI: `http://crawl4ai:11235`

## Repository layout

```text
web-stack/
├── README.md
├── LICENSE
├── SECURITY.md
├── CONTRIBUTING.md
├── CHANGELOG.md
├── .gitignore
├── .env.example
├── compose/
│   └── docker-compose.yml
├── config/
│   └── searxng/
│       └── settings.yml
├── versions/
│   └── pins.env
├── bin/
│   ├── web-stack
│   ├── web-search
│   └── web-read
├── scripts/
│   ├── bootstrap.sh
│   ├── prerequisites.sh
│   ├── install.sh
│   ├── verify.sh
│   ├── doctor.sh
│   ├── update.sh
│   ├── uninstall.sh
│   ├── backup.sh
│   ├── restore.sh
│   ├── restore-browser-state.sh
│   └── migrate-existing.sh
├── browser/
│   └── install-agent-browser.sh
├── tests/
│   ├── smoke.sh
│   ├── content-validator.sh
│   ├── web-read.sh
│   └── fixtures/
└── docs/
    ├── ARCHITECTURE.md
    ├── INSTALLATION.md
    ├── CONFIGURATION.md
    ├── BACKUP-RESTORE.md
    ├── TROUBLESHOOTING.md
    ├── UPGRADING.md
    ├── INTEGRATION.md
    ├── DEVELOPMENT.md
    ├── CANONICALIZATION.md
    └── VERIFICATION-v1.1.1.md
```

## Persistence

The stack intentionally separates source from runtime state.

Source-controlled:

- Compose
- SearXNG settings
- shell scripts
- version pins
- documentation

Runtime/generated:

- `.env`
- `data/`
- `logs/`
- `state/`
- browser state under `$HOME/.agent-browser`

This makes a Git clone sufficient to rebuild the stack while keeping secrets and mutable state outside Git.

## Recovery philosophy

A fresh system should need only:

1. a working Git client;
2. Docker;
3. Node.js/npm >= 24 for agent-browser installation;
4. this repository;
5. your secret backup, if restoring existing authenticated sessions.

The installer generates new secrets automatically. Existing browser authentication is optional.

See:

- `docs/INSTALLATION.md`
- `docs/BACKUP-RESTORE.md`

## License

New original development material is proprietary as of October 16, 2026. Earlier MIT-licensed material retains its permissions and [original notice](LICENSE-MIT-HISTORICAL.txt); third-party components retain their own licenses. See [LICENSE](LICENSE). Private repository access is required for the clone instructions above. The repository notice does not relicense SearXNG, Crawl4AI, browser tools, or other upstream components.
