# Folder Instructions

- Inherit the repository's `instructions.md` and `AGENTS.md`.
- Keep release and validation scripts non-interactive unless a publishing
  command is explicitly selected. Never publish as part of validation.
- `latest-cyl-commit.sh` prints the newest CYLTabBarController commit on any
  branch; run it before every build that depends on CYLTabBarController.
- `ci-checkout-dependencies.sh`, `ci-build-example.sh`, `unit-tests.sh` and
  `check-public-api-comments.sh` are what `.github/workflows/ios.yml` runs;
  keep them usable locally and clean under `shellcheck` (`docs/CI-CD.md`).
