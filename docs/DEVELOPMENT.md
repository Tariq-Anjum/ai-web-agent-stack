# Development

Run:

```bash
./tests/content-validator.sh  # local, no service/LLM required
./tests/web-read.sh           # local temporary mock HTTP server, always closed
./tests/pin-sync.sh           # atomic/idempotent pin and settings preservation
./scripts/doctor.sh
./scripts/verify.sh           # real services + browser
./tests/smoke.sh
```

Shell scripts should pass:

```bash
bash -n path/to/script.sh
```

Run `shellcheck` on modified shell scripts when available; it is not a production
dependency. Node helpers/tests use only built-in modules.

Keep generated state out of Git. All `state/` content except `.gitkeep`, including
JSON/session files and screenshots, is ignored.

The live gate requires useful search results, authenticated OpenAPI, rejected
unauthenticated access, substantive real fit/BM25 content, matching running image
pins and an agent-browser open/full-and-interactive-snapshot/title/URL/PNG/close
cycle. Browser smoke uses a dedicated session and an EXIT cleanup trap.

When changing infrastructure:

```bash
git status
git diff --check
```

Prefer a single coherent commit for deployment changes, followed by a Git tag for a known-good release.
