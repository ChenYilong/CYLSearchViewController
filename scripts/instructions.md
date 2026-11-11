# Folder Instructions

- Inherit the repository's `instructions.md` and `AGENTS.md`.
- Keep release and validation scripts non-interactive unless a publishing
  command is explicitly selected. Never publish as part of validation.
- `latest-cyl-commit.sh` prints the newest CYLTabBarController commit on any
  branch; run it before every build that depends on CYLTabBarController.
- `ci-checkout-dependencies.sh`, `ci-build-example.sh`, `unit-tests.sh` and
  `check-public-api-comments.sh` are what `.github/workflows/ios.yml` runs;
  keep them usable locally and clean under `shellcheck` (`docs/CI-CD.md`).

## Task log before every task

Before any task, log it as `TODO` in the most suitable document in `docs/`
(else `docs/task-log.md`): context, the user's requirements, the user's prompt
(verbatim plus English translation) and a status line. Commit and push it,
then start; mark it `DONE (YYYY-MM-DD)` with the result when the task ends.
Full rule: `AGENTS.md`, "Task log before every task".
