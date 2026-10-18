# Web Stack Anti-Bot Fallback Design

Date: 2026-10-18  
Status: OWNER-APPROVED DESIGN; implementation authorized through bounded gates  
Project: web-stack  
Branch: `feat/resilient-fetch-search`

## Goal

Add a high-quality anti-bot fallback path to `web-read` / agent-facing fetches without weakening the existing Crawl4AI-first fast path, content validator, security boundaries, or resource governance.

The fallback is OFF by default. It starts only for a deterministically classified anti-bot failure and is destroyed after its request/session lease ends.

## Existing baseline

Current web-stack behavior:

- `web-read` sends one authenticated request to Crawl4AI `POST /md`.
- Normal reads use fit pruning; query reads use BM25.
- `scripts/read-content.cjs` rejects unsuccessful envelopes, empty/trivial content, challenge/interstitial/access-denied pages and malformed responses.
- `agent-browser` + Chrome for Testing is installed and verified separately for interactive browser work.
- Browser automation and extraction are intentionally decoupled.
- The current Crawl4AI production pin is 0.9.4 by immutable image digest.
- Production activation of new behavior remains a separate owner gate.

The triggering incident was a protected target returning HTTP 429, surfaced through Crawl4AI as an anti-bot failure rather than usable Markdown.

## Governing requirements

1. Normal Crawl4AI remains L0 and must stay the cheapest/default path.
2. Resource cost is evaluated through the Operational Value Budget; a useful capability is not rejected merely for being heavier.
3. The fallback worker must have explicit activation, bounded concurrency, observable resource use and deterministic teardown.
4. Existing content acceptance rules remain authoritative for final output. No challenge page may become successful Markdown.
5. Only anti-bot classifications may auto-escalate. DNS, invalid URL, true 404, ordinary service-health failures, unrelated upstream 5xx, TLS and generic network errors do not automatically launch the anti-bot worker.
6. No retry-until-green. Each escalation tier has a fixed attempt budget.
7. Credentials, cookies and browser state must remain private and session-bounded unless an explicit persistent authenticated profile is selected by a future approved design.
8. All new services bind only where needed and must not expose a public listener by default.
9. Numerical CPU/RAM/storage/network limits are frozen from measured verification evidence, not guessed before measurement.
10. Production activation requires a separate verified owner gate.

## Prerequisite version gate

Before implementing the trusted fallback worker, evaluate current Crawl4AI upstream against 0.9.4, including the 0.9.5 line released after the current pin.

The compatibility/security gate must verify:

- current `/md` contract or the replacement contract used by web-stack;
- fit and BM25 behavior;
- authentication and loopback binding;
- content-validator compatibility;
- browser/stealth/undetected features required by this design;
- Docker image provenance and immutable digest;
- no regression in current tests;
- resource baseline and startup/shutdown behavior;
- security notes relevant to the worker.

Adoption is allowed only on deterministic compatibility PASS and an immutable pin.

## Architecture

```text
web-read / fetch_markdown
        |
        v
L0 normal Crawl4AI /md
        |
        | classified anti-bot failure only
        v
fallback lease manager
        |
        +--> L1 stealth-capable Crawl4AI/browser mode
        |        |
        |        +-- blocked -->
        |
        +--> L2 stronger undetected browser adapter
        |        |
        |        +-- blocked -->
        |
        +--> L3 optional alternate egress/proxy
        |        |
        |        +-- blocked -->
        |
        +--> final bounded failure
        |
        v
shared deterministic content validator
        |
        +--> accepted Markdown
        +--> reject with bounded evidence
```

Exact tier capabilities must be confirmed against the accepted Crawl4AI version. The implementation must not invent unsupported flags from documentation for another release.

## Component boundaries

### 1. Failure classifier

One small deterministic classifier converts a failed normal read into a typed reason.

Minimum reason classes:

- `ANTI_BOT_429`
- `ANTI_BOT_403`
- `ANTI_BOT_CAPTCHA`
- `ANTI_BOT_INTERSTITIAL`
- `NETWORK`
- `TLS`
- `DNS`
- `NOT_FOUND`
- `SERVICE_UNHEALTHY`
- `UPSTREAM_OTHER`
- `CONTENT_REJECTED`
- `UNKNOWN`

Only the explicit anti-bot classes are eligible for automatic fallback.

Evidence should include the bounded status/reason needed for diagnosis, never secrets or full protected page bodies.

### 2. Lease manager

The lease manager owns fallback lifecycle.

Lease modes:

- request lease: one protected URL;
- session lease: multiple related URLs that should reuse browser/session state.

Required states:

`OFF -> STARTING -> ACTIVE -> DRAINING -> OFF`

Required teardown triggers:

- request completion;
- explicit session close;
- idle timeout;
- hard session TTL;
- worker crash;
- caller cancellation;
- verification cleanup.

The worker must not remain alive after all leases end.

### 3. Anti-bot worker

Preferred deployment is an isolated Compose profile or equivalent one-shot container/service that is absent from normal `web-stack up`.

Initial concurrency: 1 active browser session.

The worker may reuse session cookies/state only inside the active lease. Temporary state must live under ignored private state and be removed on successful teardown unless a future explicitly approved authenticated-profile design says otherwise.

### 4. Interactive recovery lane

`agent-browser` remains separate.

Use it when the legitimate workflow requires login, consent, human interaction or user-visible troubleshooting. It is not silently substituted for every failed fetch.

### 5. Shared validator

Every successful fallback result must pass the same final deterministic acceptance boundary used by normal `web-read`.

The fallback may produce HTML or Markdown internally, but consumer stdout remains accepted Markdown only.

## Escalation policy

Default budget:

1. L0 normal fetch: one normal request.
2. On an eligible anti-bot reason, start/reuse a fallback lease.
3. L1: one stealth-capable attempt.
4. L2: one stronger undetected attempt.
5. L3: optional alternate-egress attempt only when configured and authorized.
6. Stop and return a typed failure with evidence.

A tier may be skipped when the accepted upstream version does not support it or when configuration explicitly disables it.

Retries within a tier require a deterministic reason that a retry can change the outcome; generic repetition is forbidden.

## Resource policy

The design follows the owner-approved Operational Value Budget.

Measurement campaign must record at minimum:

- cold-start time;
- active wall time;
- peak RSS / cgroup memory;
- CPU time and peak CPU;
- network bytes where practical;
- temporary storage growth;
- browser process count;
- teardown latency;
- residual processes/containers/state after shutdown.

Admission criteria are based on measured value and system impact, not a blanket low-resource rule.

Idle resource target for this subsystem after teardown: no running fallback process/container and no external network activity.

## Security

- Keep API tokens out of process arguments and logs.
- Do not persist cookies from arbitrary sites across unrelated sessions by default.
- Fallback state directory is private and ignored.
- No privileged/root host integration is introduced.
- Do not weaken TLS verification merely to improve bypass success.
- Do not automatically solve or outsource challenges when doing so would violate site terms, authentication boundaries or owner policy.
- Extracted content remains untrusted input.
- Alternate egress/provider credentials, if later added, are separate secrets and disabled by default.

## Failure evidence and regression detection

Tests must cover:

- anti-bot 429 escalates;
- anti-bot 403/challenge escalates;
- malformed URL does not escalate;
- 404 does not escalate;
- generic 500 does not escalate;
- DNS/TLS/network failure does not escalate;
- challenge content from a fallback tier is still rejected;
- worker starts once for a session and is reused;
- worker stops on session close;
- worker stops on idle timeout;
- worker stops on hard TTL;
- worker cleanup runs after caller failure;
- secrets do not appear in diagnostics;
- no fallback process/container remains after test cleanup.

The original current `web-read` mock/late-transfer tests remain mandatory.

## Interfaces

The existing `web-read URL` and `web-read --query TEXT URL` contracts should remain compatible.

Potential additions, subject to implementation-plan review:

- `--no-fallback` for deterministic L0-only diagnosis;
- `--session ID` for explicit multi-URL reuse;
- machine-readable diagnostic mode on stderr or a separate status command.

Do not change normal stdout: successful output remains Markdown only.

## Non-goals for the first implementation

- no permanent browser farm;
- no automatic commercial unblocker;
- no universal claim that every anti-bot system can be bypassed;
- no multi-user tenancy;
- no cloud control plane;
- no global cookie jar shared across unrelated targets;
- no replacement of `agent-browser`;
- no weakening of content validation.

## Naming

This subsystem is new, so the ZHOOR naming policy applies. Until the owner selects a product-facing name, repository interfaces use the descriptive technical slug `antibot-fallback`.

Non-canonical Tolkien-inspired/original fantasy naming proposals for later owner selection:

- **ZHOOR Veilrunner** — an on-demand path used only when the ordinary road is obscured.
- **ZHOOR Gatecloak** — a bounded protected-entry worker that appears for difficult gates, then disappears.
- **ZHOOR Pathwarden** — emphasizes controlled escalation and lifecycle authority rather than brute-force bypass.

No proposal is canonical without explicit owner selection.

## Cost and operational impact

Short term:

- additional engineering and deterministic integration tests;
- transient browser CPU/RAM/network during protected fetches;
- extra stored image/runtime dependency if the accepted fallback requires one.

Long term:

- higher research/fetch success on protected sites;
- lower manual recovery and repeated failed-request cost;
- no new intended idle CPU/RAM/network after fallback teardown;
- moderate maintenance limited by reusing upstream Crawl4AI/browser capabilities rather than building a custom anti-detect stack.

## Acceptance gate

Implementation candidate is not production-ready until:

1. Crawl4AI version gate passes.
2. Unit/mock lifecycle and classification tests pass.
3. Real normal reads remain unchanged.
4. At least one legitimate reproducible anti-bot fixture/target demonstrates successful bounded escalation, or the worker's mechanics are verified with controlled fixtures when no stable public target exists.
5. Challenge content remains rejected.
6. Resource measurements and teardown evidence pass.
7. No secrets leak.
8. Whole-stack verification passes.
9. Independent review passes.
10. Owner explicitly authorizes production activation.
