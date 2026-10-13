# Canonical project and repository identity

## Final identity

- Project: **web-stack**
- GitHub: **https://github.com/Tariq-Anjum/web-stack**
- Owner deployment's single Git/source/runtime root: **/mnt/MD/AI-tools/web-stack**
- Default Compose project: **web-stack**, managing SearXNG and Crawl4AI together.
- Global commands: `web-stack`, `web-search`, `web-read`.

Other users can install this repository at their own chosen path. No machine-
specific home directory is hardcoded into the install/recovery tooling.

## Release continuity

The existing repository was renamed from `Tariq-Anjum/ai-web-agent-stack`,
not replaced with a new repository. GitHub repository ID **1360489518** and
node ID **R_kgDOURdsLg**, default branch, visibility, permissions, all branches,
tags and remote HEAD were verified unchanged by the rename.

The functional v1.1 implementation is already published:

```text
v1.1.0 tag object: aaa881d257ac56b135de71f7e7cd0f3811ce3c31
v1.1.0 target:     0904d0afa9d3399d72a5f913961b4d11e5acad97
```

Those refs are preserved exactly. **v1.1.1** is the subsequent identity/
runtime-reconciliation patch, built forward from that commit. No history was
reset, squashed or force-pushed, and v1.1.0 was not deleted/recreated.

## Lossless local reconciliation

Before migration:

- `web-stack` was a non-Git active runtime with unique secrets, browser key/state,
  wrappers, Compose file, diagnostics and a historical ignored Steel checkout.
- `ai-web-agent-stack` was the clean recovery Git repository at v1.1.0.
- Its feature worktree and nested clean-clone test deployment were clean at the
  same commit, with ignored test secrets, browser assets and verification logs.

Full private archives were compared against all three original trees. Private
SHA-256/mode/link manifests and a verified `git bundle --all` recorded filesystem
and Git state. The existing primary `.git` was moved into the active root;
worktree metadata was repaired before consolidation. Published source was
installed around the preserved active runtime.

Active Crawl4AI API credentials, `SECRET_KEY`, `REDIS_PASSWORD`, port/concurrency
settings and browser encryption key were retained. Conflicting old wrappers/
Compose, recovery secrets/state, diagnostic files and historical vendor assets
were preserved privately instead of silently discarded or made defaults.

Immediately before deleting redundant working copies, deterministic checks
confirmed **52 recovery files**, **470 feature files**, **4 links**, all original
Git refs, the verified bundle, clean feature/nested clone and `git fsck --full`.
Archives had already passed complete tar comparisons. Both former project
paths and the feature worktree were then removed. Some Docker-owned inert
settings/cache assets were retained inside ignored private state rather than
weakening permissions or using sudo; no additional Git working copy remains.

Preservation evidence is under:

```text
state/reconciliation/
```

Its archives contain secrets. The evidence directory is mode **700**, archives/
manifests are mode **600**, and the entire area is ignored. It is rollback data,
not another active project or part of a fresh clone. Do not publish it or
extract historical trees over a running deployment. These snapshots are
intentionally retained pending owner-controlled backup retention.

## Runtime ownership and configuration

Legacy SearXNG belonged to a separate Compose project and used its own settings
bind mount plus an anonymous cache volume. Its settings/cache and the stopped
Crawl4AI filesystem were captured before transfer; the old cache volume and
legacy settings remain available for rollback. No volume was deleted.

Both current services use `compose/docker-compose.yml` in canonical web-stack.
The active SearXNG settings were preserved byte-for-byte as ignored private
`config/searxng/settings.local.yml`, selected with `SEARXNG_SETTINGS_FILE`.
Fresh clones select source-controlled `settings.yml` instead. The SearXNG secret
was retained; credentials are not added to source.

The existing shared network is reused with `WEB_STACK_NETWORK_EXTERNAL=true`.
Fresh clones default to `false` and let Compose create/manage their network.
External mode preserves existing network ownership and prevents teardown from
deleting a shared network.

The pinned SearXNG entrypoint supports `FORCE_OWNERSHIP=false`. Canonical
Compose uses that setting to prevent recursively chowning host source/cache/
private settings. Host ownership and private file modes were verified after
startup, and backup/reused-backup permissions were tested. The image's existing
root process behavior is unchanged; no agent is run as root.

Published ports remain 127.0.0.1, API authentication remains enabled, crawl
concurrency remains bounded and the browser key remains mode 600.

## Cross-project references

Updated active workspace index/service-management guidance, the existing
shared MCP README and one ZHOOR architecture diagram label to web-stack.
The ZHOOR change is a reference-only local edit, not a behavior/architecture
change or a push of that repository. Its 28 pre-existing dirty/untracked files
were hash-checked and left unchanged.

AGENTS/CLAUDE instruction symlinks, curated skills, MCP bindings and home-side
global command paths already used web-stack and were verified rather than
rewritten unnecessarily. The existing shared MCP provider remains at
`/mnt/MD/AI-tools/mcp/web-stack/server.py`; no second MCP server was introduced.

Intentionally retained old-name references are historical: the exact v1.1.0
verification record, rename/changelog provenance, published branch/tag history,
integration audit snapshots, index backup, memory/audit archives and generated
desktop/browser session records. They are not active install/launcher paths.
Canonical memory was not rewritten as an implementation side effect.

## Resource boundary

There are still only the two stack services. No new daemon, database, permanent
runtime/dependency or cloud service was added. The new patch controls identity,
settings selection, ownership and backup behavior, not a new extraction engine.
No idle-RAM or performance savings were measured. All explicitly deferred
browser/anti-bot/cache/interceptor pilots remain absent from the active stack.
