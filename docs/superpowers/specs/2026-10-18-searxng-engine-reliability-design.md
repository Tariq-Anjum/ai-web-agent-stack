# Web Stack SearXNG Engine Reliability Design

Date: 2026-10-18  
Status: OWNER-APPROVED DIRECTION; reassessment/remediation implementation authorized through bounded gates  
Project: web-stack  
Branch: `feat/resilient-fetch-search`

## Goal

Make SearXNG reliability explicit and measurable.

The system must stop treating “the SearXNG endpoint returned at least one result” as sufficient proof that search is healthy. Instead, web-stack should verify capability coverage, identify which engines actually contributed useful results, record bounded provider failures, and preserve useful search when individual engines are rate-limited, CAPTCHA-blocked or temporarily broken.

## Existing baseline

Current source-controlled configuration uses:

```yaml
use_default_settings: true
```

and does not explicitly select a general-search engine portfolio.

Current verification calls one aggregate general search and passes when `.results` is a non-empty array. That proves SearXNG can return something, but not:

- which engines were selected;
- which engines produced results;
- which engines timed out, CAPTCHAed or rate-limited;
- whether one surviving provider carried the entire query;
- whether the configured default engine set changed across SearXNG updates;
- whether technical/research search capabilities remain covered.

The production pin is:

```text
SEARXNG_VERSION=2026.9.8-3fdc6d753
```

The pinned upstream commit is from 2026-09-08. Current upstream inspected during this reassessment is commit `1c10abe2d3e4ab7ddcc4e9da1a7d07dc7ca7f8f4`, with 119 intervening commits affecting many engine implementations.

## Current upstream findings

These are evidence for the compatibility gate, not automatic configuration changes.

### General engines

- **Brave** is enabled by default upstream and remains useful, but 2026 reports include HTTP 429/rate-limit failures. It cannot be the sole general-search dependency.
- **DuckDuckGo** is enabled by default upstream and remains useful, but CAPTCHA-related failures are reported. It cannot be the sole general-search dependency.
- **Bing** is disabled by default. The current web-stack pin predates a later upstream Bing correction, so Bing must be reevaluated only after an update compatibility gate.
- **Google** is disabled by default upstream. It may be evaluated but should not become a mandatory health dependency without stable measured behavior.
- **Qwant** is disabled by default upstream. It is an optional diversity candidate subject to live testing.
- **ResultHunter** is disabled by default upstream. It is an optional diversity candidate subject to live testing.
- **Startpage** is marked inactive in current upstream because of Proof-of-Work CAPTCHA behavior.
- **Mojeek** is marked inactive in current upstream because of Proof-of-Work CAPTCHA behavior.
- **Swisscows** remains disabled/inactive upstream.

Startpage and Mojeek therefore must not be treated as required providers merely because they are recognizable search engines.

## Capability model

“Necessary search engines” means enough independent engines to satisfy the capabilities web-stack actually needs. It does not mean forcing every SearXNG engine to pass.

### Required capability classes

#### A. General web

Acceptance target:

- at least **3 independently sourced, currently usable general-web engines** in the accepted portfolio;
- no single provider may be required for aggregate search success;
- aggregate search must still return useful results when one primary engine is deliberately disabled or fails.

Candidate pool for evaluation:

- Brave
- DuckDuckGo
- Bing
- Google
- Qwant
- ResultHunter
- other current upstream general engines found during the gate

Final membership is determined by measured live behavior and maintainability, not brand preference.

#### B. Technical/code discovery

At least:

- healthy general-web coverage;
- GitHub search engine or an equivalent direct technical-search engine when useful;
- Stack Overflow / package-registry / documentation engines may be included only when they provide measurable value and stable behavior.

Because GitHub and other specialized sources can change independently, specialized-engine failure must not make general search unhealthy.

#### C. Research/papers

At least two useful sources among currently supported engines such as:

- arXiv;
- Semantic Scholar;
- Crossref;
- PubMed / Europe PMC where applicable.

This category is for research discovery, not proof of factual correctness.

#### D. News

When the `news` category is requested, require redundant working coverage rather than assuming the general portfolio covers it.

The exact accepted news engines are selected by the live gate.

### Optional capability classes

Images, videos, maps, shopping and other categories are not blockers for the first reliability release unless they are already explicitly depended on by web-stack consumers. They can be measured and documented without becoming release blockers.

## Version compatibility gate

Before changing the production engine portfolio, evaluate the current SearXNG release/image against the current pin.

The gate must verify:

- image provenance and immutable pin;
- current settings schema;
- JSON output compatibility;
- existing `web-search` CLI contract;
- localhost binding and current Compose behavior;
- existing source-controlled and private settings override behavior;
- engine changes relevant to the accepted portfolio;
- dependency/security notes;
- whole-stack resource change;
- no regression in Crawl4AI networking through the shared Docker network.

An update is adopted only on deterministic compatibility PASS.

## Engine probe design

Add a deterministic diagnostic command/script that probes engines individually.

Preferred interface:

```text
web-stack search-doctor
```

or a focused helper invoked by `scripts/doctor.sh` / verification.

Each probe uses a small fixed query suite and selects one engine at a time by the SearXNG-supported engine-selection mechanism for the accepted version.

Each result record should contain:

- engine name;
- capability class;
- request outcome;
- HTTP/API outcome;
- result count;
- whether at least one result has a valid HTTP(S) URL;
- latency;
- bounded provider error/reason where exposed;
- pass/degraded/fail status.

Do not store full response bodies in diagnostic evidence.

## Probe query suite

Use a small deterministic set designed to catch different failure modes without hammering providers.

Example classes:

1. stable navigational query;
2. current technical query;
3. uncommon multi-word query that detects irrelevant-result regressions;
4. category-specific query where needed.

Queries should be versioned fixtures so changes are reviewable.

A provider is not permanently failed because of one transient network observation. Apply the Canonical Bounded Regression Evidence Policy:

- one failure -> preserve evidence;
- bounded reproduction/attribution campaign;
- persistent/material failure -> block provider admission;
- clean bounded campaign after an unexplained observation -> mark unresolved/nonreproducible as appropriate while retaining the detector.

## Engine states

Each engine has one runtime assessment state:

- `HEALTHY` — useful results within the accepted envelope;
- `DEGRADED` — useful results but intermittent/rate-limited/slow;
- `BLOCKED` — deterministic CAPTCHA/PoW/anti-bot behavior;
- `BROKEN` — parser/API/config incompatibility;
- `DISABLED_POLICY` — intentionally not part of the active portfolio;
- `INACTIVE_UPSTREAM` — upstream marks it inactive;
- `UNVERIFIED` — not tested in the current gate.

Only `HEALTHY` engines count toward required redundancy. `DEGRADED` engines may contribute opportunistically but do not satisfy the minimum alone.

## Active portfolio policy

Do not inherit an uncontrolled general-search portfolio solely through `use_default_settings: true`.

Preferred direction after measurement:

- continue merging upstream defaults for non-critical settings when useful;
- explicitly control the accepted engines that define web-stack's required capability coverage;
- explicitly remove or disable engines that are known harmful/unusable for the deployment;
- avoid copying the entire upstream `settings.yml`.

The exact SearXNG supported `use_default_settings.engines.keep_only/remove` or equivalent mechanism must be confirmed against the accepted version before implementation.

## Aggregate search behavior

Normal `web-search` should remain simple.

It must:

- request the configured category;
- return useful aggregate results even if one provider fails;
- fail only when the requested capability has no acceptable result, not merely because one engine is unresponsive;
- preserve bounded provider-failure evidence for diagnostics;
- avoid exposing internal provider error noise in normal stdout.

Machine-readable diagnostic output may expose engine contribution/failure metadata through an explicit diagnostic mode or `search-doctor`, not by breaking existing CLI output.

## Fallback policy

Search fallback differs from page-fetch anti-bot fallback.

For search discovery, preferred fallback is **provider diversity**, not launching a browser to scrape a blocked search engine.

Order:

1. normal accepted engine portfolio;
2. surviving healthy engines automatically carry aggregate results;
3. if capability redundancy drops below the accepted minimum, use configured reserve engines that previously passed admission;
4. if no sufficient local SearXNG provider remains, return a typed/degraded failure rather than silently scraping a search engine with the anti-bot browser worker.

A future direct search API/provider may be evaluated separately if local engine diversity is insufficient, but no paid/cloud search dependency is authorized by this design.

## Provider remediation rules

When an engine fails:

1. classify the root cause;
2. check current upstream engine implementation/issues;
3. update SearXNG if the accepted upstream release contains a relevant fix and the version gate passes;
4. repair local settings only when the root cause is configuration;
5. do not add infinite retries, arbitrary long timeouts or CAPTCHA workarounds merely to make an engine green;
6. if upstream marks an engine inactive for PoW/CAPTCHA, treat that as strong evidence against making it a required provider;
7. retain a detector for materially important failures.

## Test requirements

### Local deterministic tests

- parse representative SearXNG JSON with multiple engine contributions;
- one provider failed but aggregate results are useful -> aggregate PASS;
- all required providers failed -> capability FAIL;
- only degraded providers remain -> DEGRADED;
- malformed response -> FAIL;
- result URLs must be HTTP(S);
- diagnostic output contains no secrets;
- existing `web-search` query/limit/snippet behavior remains compatible.

### Real-service tests

Run individual probes for each candidate primary/reserve engine.

Record:

- engine;
- query fixture;
- result count;
- latency;
- observed failure reason;
- final admission state.

Then run controlled portfolio tests:

- all admitted primaries;
- each primary removed one at a time;
- reserve substitution where applicable.

The release must demonstrate that one provider failure does not destroy general search.

## Resource policy

SearXNG itself remains the existing service; the reliability work should not add a new always-on service.

Potential resource changes come from:

- choosing more/fewer active engines per query;
- longer aggregate latency if slow providers are admitted;
- additional outgoing requests;
- small bounded diagnostic evidence.

Measure:

- median and worst bounded search latency;
- number of outbound engine requests;
- SearXNG CPU/RAM during the probe;
- network effect where practical;
- timeout contribution by engine.

An engine can be rejected for poor value even if technically functional.

## Security and privacy

- Avoid API-key engines unless separately configured/approved.
- No new provider credentials are required for the initial portfolio.
- Search query text is necessarily sent to selected upstream search providers; document the admitted set.
- Do not expose SearXNG publicly.
- Provider responses remain untrusted input.
- Do not allow engine error text to become agent instructions.

## Expected initial disposition

The first gate should specifically investigate:

- **Brave:** likely primary candidate, but verify 429 frequency.
- **DuckDuckGo:** likely primary candidate, but verify CAPTCHA frequency.
- **Bing:** reevaluate after current SearXNG update because the current pin predates later fixes.
- **Google:** reserve candidate only if stable in this deployment.
- **Qwant / ResultHunter:** reserve/diversity candidates if they pass live probes.
- **Startpage / Mojeek:** do not count toward required redundancy while current upstream marks them inactive for PoW/CAPTCHA.
- **GitHub + research engines:** evaluate as specialized capability coverage, separate from general-web quorum.

This is a starting hypothesis, not a final engine allowlist.

## Cost and operational impact

Short term:

- compatibility/update evaluation;
- bounded live provider probing;
- implementation of engine-health diagnostics and fixtures;
- possible small increase in network use during verification.

Long term:

- much clearer failure attribution;
- fewer false “search is healthy” results;
- graceful degradation when a provider rate-limits or CAPTCHA-blocks;
- easier provider replacement;
- no new intended always-on service or idle resource class;
- modest maintenance cost because engine health changes with upstream providers.

## Acceptance gate

SearXNG reliability candidate is ready for owner review only when:

1. SearXNG version compatibility gate passes or there is evidence to retain the current pin.
2. Accepted engine portfolio is explicit.
3. General web has at least three `HEALTHY` independent engines.
4. One-at-a-time primary failure tests preserve useful aggregate search.
5. Required technical/research categories meet their accepted coverage.
6. Known CAPTCHA/PoW providers are not falsely reported healthy.
7. Search diagnostics produce bounded useful evidence.
8. Existing `web-search` CLI remains compatible.
9. Whole-stack verification passes.
10. Resource/network effect is measured.
11. Independent review passes.
12. Owner explicitly authorizes production activation of the new portfolio/configuration.
