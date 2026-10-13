# Changelog

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
