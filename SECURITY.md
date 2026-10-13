# Security

## Local-only default

The stack binds published ports to loopback:

```text
127.0.0.1:8080
127.0.0.1:11235
```

Do not change these to `0.0.0.0` unless you understand the exposure and add an appropriate access-control layer.

## Secrets

Generated secrets live in:

```text
.env
state/agent-browser-encryption-key.env
```

Both are excluded from Git and should have mode `600`.

Never paste secret values into:

- GitHub issues
- commit messages
- logs
- compatibility reports
- chat messages

## Crawl4AI

Crawl4AI is deployed with:

- `CRAWL4AI_API_TOKEN`
- `SECRET_KEY`
- `REDIS_PASSWORD`
- bounded concurrency

Keep the API behind localhost or a protected internal network.

Crawl4AI 0.9.4 is pinned by immutable digest. This official security release fixes
robots.txt/link-preview SSRF paths and an untrusted-config boundary bypass.
Re-pin deliberately and verify the live authenticated OpenAPI when upgrading.

`web-read` contacts only the configured loopback API, keeps its token out of
curl arguments, and accepts only HTTP(S) target URLs without embedded credentials.
The server's egress policy remains enabled. Content validation is a bounded
heuristic, not an anti-bot bypass or a guarantee that every page is readable.

## Browser authentication

Browser cookies, credentials and session state may be sensitive even when encrypted.

Use the dedicated browser-state backup flow and protect the encryption key backup separately.
