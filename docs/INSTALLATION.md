# Installation

## Prerequisites

- Linux x86_64 or another architecture supported by the selected container images
- Docker Engine
- Docker Compose v2
- Git
- curl
- jq
- openssl
- Node.js >= 24
- npm

## Fresh install

```bash
git clone https://github.com/Tariq-Anjum/ai-web-agent-stack.git
cd ai-web-agent-stack
./scripts/install.sh
```

Verify:

```bash
./scripts/verify.sh
```

## Optional custom location

```bash
export WEB_STACK_HOME="/path/to/ai-web-agent-stack"
```

This override applies to the command wrappers. Installation/update/verification
scripts operate on their own checkout. Global symlinks resolve the checkout
correctly when no override is set. Add `$HOME/.local/bin` to your PATH.
The installer exposes `web-stack`, `web-search` and `web-read` there and uses an
explicit user-local npm prefix without changing persistent npm configuration.

Existing `.env` files keep their secrets, ports and local settings; install/update
synchronizes only the two image pins from `versions/pins.env`.

## What the installer generates

```text
.env
state/agent-browser-encryption-key.env
data/searxng/
logs/
```

Secrets are generated using OpenSSL and are not committed.

## Browser authentication restore

Authentication state is optional. A fresh installation works without it.

See `BACKUP-RESTORE.md`.

## Bootstrap on a fresh Linux system

The bootstrap path installs Docker and common CLI prerequisites when `pacman` (Arch/CachyOS) or `apt-get` (Debian/Ubuntu) is available:

```bash
./scripts/bootstrap.sh
```

A Docker group change may require logging out and back in. The bootstrap intentionally stops rather than running the stack through `sudo docker`.

Node.js must be version 24 or newer. The project does not silently install an alternate Node runtime over an existing one.

For v1.1.0, x86_64 Linux is the verified reference platform.

For a parallel test installation, choose unused ports and unique names **before**
installing (these values are persisted in the generated `.env`):

```bash
SEARXNG_PORT=18080 CRAWL4AI_PORT=21235 \
COMPOSE_PROJECT_NAME=ai-web-test \
SEARXNG_CONTAINER_NAME=ai-web-test-searxng \
CRAWL4AI_CONTAINER_NAME=ai-web-test-crawl4ai \
WEB_STACK_NETWORK=ai-web-test-network ./scripts/install.sh
```

Published ports remain loopback-only. Do not run two installations with the same
container/network names or ports. Uninstall stops only that Compose project and
removes only convenience symlinks owned by that checkout; it retains secrets,
browser installation and data.
