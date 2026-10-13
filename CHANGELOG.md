# Changelog

## 1.1.1 — 2026-10-14

### Canonicalization patch

- v1.1.0 delivered the functional v1.1 implementation. This patch canonicalizes
  source/runtime identity as `web-stack`; it does not redo that implementation.
- Rename the existing GitHub repository from `Tariq-Anjum/ai-web-agent-stack`
  to `Tariq-Anjum/web-stack`, retaining repository ID, history, branches, tags,
  default branch and permissions.
- Establish `/mnt/MD/AI-tools/web-stack` as the single canonical Git/runtime tree;
  preserve active secrets, browser key/state, unique local assets and prior work
  in verified private migration snapshots before removing duplicate trees.
- Canonicalize URLs, default install paths, Compose identity, backup naming,
  documentation and active workspace/integration references. Bootstrap defaults
  to the current checkout rather than accidentally creating a second clone.
- Reconcile both services into canonical Compose. Preserve existing SearXNG local
  settings/cache and shared-network ownership via explicit optional overrides.
  Disable the pinned SearXNG entrypoint's recursive host-file ownership changes;
  protect configuration backups because local overrides can contain credentials.
- Retain the exact functional pins from v1.1.0 and rerun deterministic/local,
  real-service, browser, global-command and existing MCP integration checks.
- No new service/dependency and no measured idle-RAM or performance claim.
- The published `v1.1.0` ref was **not rewritten**: annotated object
  `aaa881d257ac56b135de71f7e7cd0f3811ce3c31` still targets
  `0904d0afa9d3399d72a5f913961b4d11e5acad97`.

See `docs/CANONICALIZATION.md` and `docs/VERIFICATION-v1.1.1.md`.

## 1.1.0 — 2026-10-14

### Verified changes

- Upgrade Crawl4AI 0.9.3 to the official 0.9.4 security release, retaining an
  immutable image digest, authentication, loopback ports and bounded concurrency.
- Pin agent-browser 0.39.0 after isolated package/browser compatibility testing.
  SearXNG remains `2026.9.8-3fdc6d753`.
- Add `web-read`: deterministic pruned fit Markdown by default, query-focused
  BM25 with `--query`/`-q`, stderr diagnostics and non-zero failure exits.
- Add one shared content acceptance helper, local fixtures and CLI contract tests.
- Verify real authenticated Crawl4AI extraction in both modes, rejected
  unauthenticated access, useful search results, running pins and browser snapshots,
  title, URL, screenshot and clean close.
- Fix global-command symlink resolution and stale runtime image pins during updates;
  preserve secrets/settings, avoid persistent npm configuration changes.
- Install/uninstall `web-read` consistently; ignore all generated browser/session
  JSON/text and backup archives. Add isolated test deployment naming options.
- Guidance: interaction prefers `snapshot -i -c`; reading/inspection retains
  task-appropriate normal/full snapshots.

### Design expectation and deferred work

- No new always-running service or production dependency; the wrappers use existing
  Node/curl/jq. No idle-RAM savings or performance improvement is claimed/measured.
- Browserless curl_cffi/Trafilatura/selectolax, optional Lightpanda, and specialist
  Steel/Camoufox/Patchright pilots remain deferred. No extra cache, database,
  MCP server, hosted service or site interceptor was added.

See `docs/VERIFICATION-v1.1.0.md` for release evidence and limitations.

## 1.0.0 — 2026-09-10

Initial recovery-oriented repository baseline.

Includes:

- fresh-machine bootstrap for Arch/CachyOS and Debian/Ubuntu

- SearXNG local deployment
- Crawl4AI authenticated deployment
- agent-browser installation
- Chrome for Testing installation
- version pinning
- health and end-to-end verification
- backup/restore helpers
- browser-state recovery helper
- documentation for installation, security and integration
