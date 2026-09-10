# Contributing

Keep the project reproducible.

Before changing deployment behavior:

```bash
./scripts/doctor.sh
./scripts/verify.sh
./tests/smoke.sh
```

Do not commit:

- `.env`
- `state/*.env`
- runtime logs
- caches
- browser profiles
- backup archives
- generated screenshots

When updating versions, change `versions/pins.env` and document the reason in `CHANGELOG.md`.

Prefer small, reviewable commits.
