# v1.1.0 verification evidence

Date: **2026-10-14** (local); verified platform: Linux x86_64, Docker **29.9.0**,
Compose **5.6.0**, Node **26.11.1**, npm **12.2.0**.

## Base and isolation

Fetched all remotes/tags with pruning before implementation. Authoritative
`origin/main` was exactly `e02d4fef1a4995d7c44b37ed01bb5e8a90d393fb`, with no
intervening changes and a clean checkout. Implemented in
`feat/ai-web-agent-stack-v1.1` in a separate worktree, not directly on main.
The superseded Steel/Lightpanda architecture was not restored.

Existing active services and global agent-browser were left untouched.
Test deployment used unique Compose/container/network names, loopback ports
18080/21235, generated test secrets, and an isolated HOME/npm/browser prefix.
All runtime logs, screenshots, test secrets and browser files remain ignored.

## Primary version evidence

- [Crawl4AI official v0.9.4 release](https://github.com/unclecode/crawl4ai/releases/tag/v0.9.4)
  published 2026-09-23.
- [Crawl4AI v0.9.4 changelog](https://github.com/unclecode/crawl4ai/blob/v0.9.4/CHANGELOG.md)
  identifies it as a security release fixing SSRF and an untrusted-config bypass.
  No upstream speedup claim is used as a local benchmark.
- [agent-browser official v0.39.0 release](https://github.com/vercel-labs/agent-browser/releases/tag/v0.39.0)
  published 2026-10-09; npm metadata confirms version 0.39.0 and Node >=24.

Pulled `unclecode/crawl4ai:0.9.4`, resolved its digest, launched/tested the exact
digest, and checked package/health version **0.9.4**. Final production pin:

```text
unclecode/crawl4ai@sha256:9021b3cb5c6f12570bbcd5395638495e0a06969b3148e377b953d174af2ebc9b
```

SearXNG stays `2026.9.8-3fdc6d753`. agent-browser becomes `0.39.0`.
The tested browser installed by agent-browser was Chrome for Testing
**155.0.8059.39**. Chrome remains managed by agent-browser; its installer can
resolve a different Chrome release in future (no independent Chrome pin added).

## Completed candidate gate

Commands were run from the candidate checkout. Install/update/doctor/verify/smoke
used the isolated test HOME; the manual command checks used installed symlinks
with no `WEB_STACK_HOME` override, proving resolved-command root discovery.

| Command/check | Result and semantic evidence |
|---|---|
| `git diff --check` | PASS |
| `bash -n` over every shell script and bin command | PASS |
| `node --check` on helpers/tests | PASS |
| `docker compose --env-file .env -f compose/docker-compose.yml config -q` | PASS; published addresses separately asserted as 127.0.0.1 |
| `./tests/content-validator.sh` | PASS: 18 fixtures, including substantive/compact/prose-mention passes and empty/tiny/link-only/challenge/human/denied/CAPTCHA/unsuccessful/malformed failures |
| `./tests/web-read.sh` | PASS: fit/BM25 request fields, literal metacharacter/newline query encoding, Markdown-only output, help/invalid input, HTTP/crawl/challenge/late-transfer failures with empty stdout |
| `./tests/pin-sync.sh` | PASS: canonical pins, duplicate replacement, preserved fixture secrets/local settings, mode 600 and idempotence |
| `./scripts/doctor.sh` | PASS: dependencies, Node, exact pins/package, runtime pin equality, bounded concurrency, secrets and browser-key permissions, Compose/local exposure |
| `./scripts/verify.sh` | PASS: useful host and Docker-network search; health version 0.9.4; authenticated OpenAPI fields; unauthenticated OpenAPI and extraction rejection; real fit/BM25 extraction through web-read/shared validator; exact running image references |
| `./tests/smoke.sh` | PASS: delegates to the complete live gate, including browser |
| `web-search "Crawl4AI documentation"` | PASS: five results, including official docs and upstream repository |
| `web-read https://example.com` | PASS: substantive pruned Markdown containing documentation examples |
| `web-read --query "example domain" https://example.com`, `-q` and `--help` | PASS: focused Markdown and correct CLI behavior |
| agent-browser version/install/doctor/open/snapshot/title/URL/screenshot/close | PASS: 0.39.0, installed Chrome, doctor 0 failures; both full and interactive compact snapshots; Example Domain title, canonical URL and valid nonempty PNG; dedicated sessions closed |
| Fresh install, update and reinstall | PASS: generated mode-600 secrets, correct pins, symlinks and real functional verification |
| Uninstall | PASS: removed owned command links and test containers/network; retained secrets/data and a deliberately foreign symlink |

The candidate `/openapi.json` was fetched with authentication **before**
implementing the request. Image source confirmed the `/md` handler checks crawl
failure and returns fit Markdown. No historical schema assumptions, Python
runtime addition, LLM filtering, cloud service or raw-content fallback is used.

Shellcheck was **not installed**, so it was not run or installed as a release
dependency. Bash syntax and deterministic/live tests were run instead.

## Self-review and known limitations

Reviewed the complete product diff for secrets, shell quoting/injection,
localhost exposure, floating pins, API parsing, validator reuse, cleanup,
fresh-install/update behavior and accidental architecture/dependency restoration.

Fixed discovered defects: symlink root resolution, stale .env image pins,
persistent npm-prefix mutation, generated JSON/text state visibility in Git,
and content emission on a late curl transfer failure.

Crawl4AI logs contained upstream Pydantic field-shadowing, FastAPI deprecation
and duplicate-operation-ID warnings; no functional extraction failure was seen.
SearXNG reported unavailable ahmia/torch engines, limiter/header warnings and
provider CAPTCHA/rate-limit suspensions. Successful multi-engine search still
returned substantive results; these upstream/provider limitations were not
silently represented as clean logs or universal search availability.

The content validator is bounded and conservative, not universal challenge
detection or factual verification. Very short legitimate pages can fail. BM25
queries with no useful matches fail instead of returning unrelated raw content.
External smoke checks need Internet and can fail if upstream services change.

## Resource and deployment scope

No new always-running service or production package dependency. New functionality
is on-demand shell/curl/jq/Node work. Incremental idle daemon RAM is expected to
be effectively zero by design; no idle-RAM or throughput benchmark was performed.

The pulled Crawl4AI image reports **6,110,795,282 bytes** in Docker's image
metadata (total unpacked image, not incremental disk use). The isolated test
HOME used about **564 MiB** including browser/npm state. These are test/storage
observations, not memory measurements. Existing shared Docker layers may reduce
additional disk use. Network transfers included Docker images, npm package and
Chrome download. There are no new routine background network activities.

Browserless curl_cffi/Trafilatura/selectolax, Lightpanda, Steel/Camoufox/Patchright,
Valkey, extra Redis, SQLite caching, FastMCP wrapper, Docling, PyMuPDF4LLM and
site-specific interceptors remain deferred and were not added.

GitHub integration/tag identities and post-integration verification are reported
in the release closeout and authoritative Git refs, rather than embedding a
self-referential commit SHA in this document.
