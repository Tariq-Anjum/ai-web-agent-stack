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
- any ignored `config/searxng/settings.local.yml`

It does **not** include `.env` or browser keys/state. A local settings override
may nevertheless contain credentials, so archives are created with mode `600`
and must be stored privately. Do not publish them.

One-time canonicalization snapshots under `state/reconciliation/` also contain
sensitive legacy state. They are ignored, owner-private rollback evidence, not
another active project or part of the normal source distribution.

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
8. Ensure restored `.env` and browser key files have mode `600`.
9. Run `./scripts/update.sh` to synchronize canonical image/package pins without
   replacing restored secrets, reinstall command symlinks and run complete verification.

`web-read` has no persistent state or additional backup requirement. Do not
restore obsolete image pins as the active version merely because they were
present in a secrets backup.
