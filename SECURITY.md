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

Crawl4AI 0.9.3 is the baseline because it is a security release. Re-pin deliberately when upgrading.

## Browser authentication

Browser cookies, credentials and session state may be sensitive even when encrypted.

Use the dedicated browser-state backup flow and protect the encryption key backup separately.
