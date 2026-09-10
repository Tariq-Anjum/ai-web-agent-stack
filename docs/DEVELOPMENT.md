# Development

Run:

```bash
./scripts/doctor.sh
./tests/smoke.sh
```

Shell scripts should pass:

```bash
bash -n path/to/script.sh
```

Keep generated state out of Git.

When changing infrastructure:

```bash
git status
git diff --check
```

Prefer a single coherent commit for deployment changes, followed by a Git tag for a known-good release.
