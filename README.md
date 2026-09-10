# AI Web Agent Stack

Reproducible local web-search and browser automation stack for AI agents.

## Components

- SearXNG — privacy-respecting metasearch
- Crawl4AI — authenticated local web crawling/extraction API
- agent-browser — browser automation CLI
- Chrome for Testing — browser runtime managed by agent-browser
- `web-stack` — lifecycle/status/verification CLI
- `web-search` — compact SearXNG CLI wrapper
- shared Docker network for service-to-service communication

The project is designed for two purposes:

1. recover a working web stack after a system rebuild;
2. provide a repeatable deployment that can be shared with another Linux user.

## Current baseline

The initial baseline was validated on:

- CachyOS Linux
- x86_64
- Docker 29.x / Compose 5.x
- Crawl4AI 0.9.3
- agent-browser 0.37.1
- Chrome for Testing 153.x

Exact image/package pins live in `versions/pins.env`.

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
git clone https://github.com/Tariq-Anjum/ai-web-agent-stack.git
cd ai-web-agent-stack
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
```

The commands work from the repository itself too:

```bash
./bin/web-stack status
./bin/web-search "Hermes AIOS"
```

## Default endpoints

Host-local:

- SearXNG: `http://127.0.0.1:8080`
- Crawl4AI: `http://127.0.0.1:11235`

Docker network:

- SearXNG: `http://searxng:8080`
- Crawl4AI: `http://crawl4ai:11235`

## Repository layout

```text
ai-web-agent-stack/
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
│   └── web-search
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
│   └── smoke.sh
└── docs/
    ├── ARCHITECTURE.md
    ├── INSTALLATION.md
    ├── CONFIGURATION.md
    ├── BACKUP-RESTORE.md
    ├── TROUBLESHOOTING.md
    ├── UPGRADING.md
    ├── INTEGRATION.md
    └── DEVELOPMENT.md
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

MIT. See `LICENSE`.
