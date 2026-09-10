# Backup and Restore

There are three separate backup classes.

## 1. Runtime/config backup

Run:

```bash
./scripts/backup.sh
```

This captures:

- SearXNG cache/data
- SearXNG source-controlled configuration

It does **not** include secrets.

## 2. Secrets backup

For a recovery that preserves the existing deployment identity, securely copy these files into an encrypted password manager or encrypted offline backup:

```text
.env
state/agent-browser-encryption-key.env
```

Never commit them.

A fresh install can instead generate completely new secrets.

## 3. Browser authentication state

Browser state can contain cookies, login sessions and credentials.

Create a backup on the old system:

```bash
tar -czf \
  "$HOME/agent-browser-state-$(date +%Y%m%d-%H%M%S).tar.gz" \
  -C "$HOME" \
  .agent-browser
```

Protect this archive.

On the new system:

```bash
./scripts/install.sh
```

Restore the matching encryption key file first, then:

```bash
./scripts/restore-browser-state.sh \
  /path/to/agent-browser-state-YYYYMMDD-HHMMSS.tar.gz
```

The browser state must be paired with the encryption key used to create it.

## Complete disaster recovery

1. Install Docker, Git, curl, jq, openssl, Node.js >= 24.
2. Clone this repository.
3. Run `./scripts/install.sh`.
4. Restore `.env` only when preserving the previous deployment identity.
5. Restore `state/agent-browser-encryption-key.env` if restoring encrypted browser state.
6. Run `./scripts/restore.sh` for runtime/config data.
7. Run `./scripts/restore-browser-state.sh` for browser sessions.
8. Run `./scripts/verify.sh`.
