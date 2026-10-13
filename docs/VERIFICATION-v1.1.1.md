# v1.1.1 canonicalization verification

Date: **2026-10-14** (local). Functional base:
`0904d0afa9d3399d72a5f913961b4d11e5acad97` / published **v1.1.0**.

This patch preserves the already-verified v1.1 implementation. It does not
repeat the release as a new v1.1 feature commit or change its pins.

## Identity/preservation gate

- Existing repository renamed in place to **Tariq-Anjum/web-stack** with ID
  **1360489518** unchanged; permissions, visibility/default main and complete
  remote refs/HEAD compared equal across rename.
- Origin explicitly set to `https://github.com/Tariq-Anjum/web-stack.git`;
  fetch succeeded from the canonical URL.
- Single registered Git working tree: **/mnt/MD/AI-tools/web-stack**.
  Former recovery/feature working paths are absent.
- Full private filesystem archives passed tar comparisons before mutation.
  Non-Git content/mode/link manifests, all original refs, bundle verification,
  clean feature/nested clone and full Git fsck passed before removal.
- Active API credentials/ports/concurrency and browser key were checked equal
  to their pre-migration values; SearXNG settings/secret/cache were preserved.
- API .env, browser key and ignored local settings remain mode 600.
  Archives/evidence are private and not staged.
- Active reference scan found no old-name launcher/install/configuration paths.
  Old names remain only in explicit rename provenance and historical records.
- 28 pre-existing dirty/untracked ZHOOR files hash-checked unchanged. Its sole
  task edit is a canonical reference label, with no unrelated behavior changed.

## Complete canonical runtime gate

Run from the actual canonical root, against its real localhost services:

| Command/check | Result / material evidence |
|---|---|
| `git diff --check` | PASS |
| `bash -n` over all shell scripts/bin commands | PASS |
| `node --check` over Node helpers/tests | PASS |
| `docker compose --env-file .env -f compose/docker-compose.yml config -q` | PASS; localhost-only published ports independently asserted |
| `./tests/content-validator.sh` | PASS, 18 deterministic fixture cases |
| `./tests/web-read.sh` | PASS, real CLI request encoding/failure behavior against a temporary local mock, including a late transfer failure |
| `./tests/pin-sync.sh` | PASS, canonical pins, preserved fixture settings/secrets, mode 600 and idempotence |
| `./tests/bootstrap.sh` | PASS, default target is the current checkout; mocked package/Docker boundaries avoid sudo or an accidental duplicate clone |
| `./scripts/doctor.sh` | PASS, runtime pins equal source pins, package 0.39.0, protected secrets, readable selected settings, bounded concurrency and Compose |
| `./scripts/verify.sh` | PASS, useful host/network search, health 0.9.4, authenticated OpenAPI, unauthenticated OpenAPI/extraction rejection, real fit/BM25 reads and exact running image refs |
| `./tests/smoke.sh` | PASS, complete gate including browser |
| `web-search "Crawl4AI documentation"` | PASS, substantive results including official documentation |
| `web-read https://example.com` | PASS, pruned Markdown containing documentation examples |
| `web-read --query "example domain" https://example.com` | PASS, query-focused substantive Markdown |
| agent-browser lifecycle | PASS, doctor 12 pass/0 warn/0 fail; open, full snapshot, interactive compact snapshot, Example Domain title, canonical URL, valid PNG and clean close |
| Existing shared MCP | PASS, status/search plus actual fit and BM25 reads; preserved token works without changing bindings |
| `./scripts/backup.sh` | PASS, local settings included, .env/browser key/state excluded, archive/manifest mode 600; reused 644 outputs repaired to 600 before rewriting |
| Fresh deployment | PASS, isolated Git clone with exported candidate source, no runtime secrets/state/override copied; default settings and Compose-managed network; functional installer and private backup; host ownership retained |
| Test cleanup | PASS, transient fresh-test services/network/tree removed; only canonical searxng/crawl4ai services remain |

Fresh deployment reused the installed approved agent-browser and Chrome runtime
through an isolated HOME, without replacing the owner's global package/browser.
The original v1.1 compatibility gate already evaluated a fresh isolated npm
installation. Existing production .env/settings/key were never replaced by
fresh-install fixtures.

Shellcheck was not installed, and was not introduced as a production dependency.
Syntax, fixture/CLI and actual runtime checks were run instead.

## Final pins and runtime

```text
SEARXNG_VERSION=2026.9.8-3fdc6d753
CRAWL4AI_IMAGE=unclecode/crawl4ai@sha256:9021b3cb5c6f12570bbcd5395638495e0a06969b3148e377b953d174af2ebc9b
AGENT_BROWSER_VERSION=0.39.0
```

Both containers report canonical Compose project **web-stack** and canonical
Compose file. The browser tested was Chrome for Testing **155.0.8059.39**.
Actual Crawl4AI version/contract remains 0.9.4, with fit and bm25 available.

## Known limitations and resource evidence

Crawl4AI still emits upstream Pydantic/FastAPI/duplicate-operation warnings.
SearXNG emits expected user-owned bind-mount ownership warnings with forced
chown disabled, unavailable-engine/limiter-header warnings and provider
CAPTCHA/rate-limit suspensions. Useful multi-engine search and real reads pass;
the report does not claim clean logs or universal site/search availability.

Content acceptance remains a conservative bounded heuristic, not universal
anti-bot detection or factual verification. Internet-dependent smoke targets
and browser downloads can change.

No new always-running service or production dependency was introduced. Idle
service RAM is expected to be unchanged by the patch's on-demand/configuration
work; no RAM or throughput comparison was measured. Private one-time
preservation evidence used about **2.2 GiB** during verification, including
the stopped legacy Crawl4AI filesystem and complete source/test snapshots.
Chrome installation downloaded about **189 MB**; temporary fresh-test browser
reuse avoided another browser copy. These are storage/network observations,
not RAM measurements.

Final commit/main/tag identities are recorded in authoritative Git refs and
the release closeout. The existing v1.1.0 annotated object and target are
explicitly checked again before publication of v1.1.1.
