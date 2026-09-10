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
export WEB_STACK_HOME="/mnt/MD/AI-tools/web-stack"
```

For maximum portability, keeping the repository itself as `WEB_STACK_HOME` is recommended.

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

For this v1.0.0 baseline, x86_64 Linux is the reference platform.
