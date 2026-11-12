# Documentation Folder Instructions

This folder contains project documentation and commit records. Inherit the
repository and vault instructions.

- Write repository-authored documentation in English.
- Preserve issue and comparison tracker structures when updating them.
- Before commits, record unfinished work with a `TODO` heading in the most
  relevant existing document; do not create duplicate trackers.
- Track CYLTabBarController integration rules and their TODOs in
  `CYLTabBarController-Integration.md`.
- Keep commit records factual and link them from the corresponding commit
  message when the detailed description exceeds 50 characters.
- Before any task, log it in the most suitable document here (else
  `task-log.md`) as `TODO` with its context, the user's requirements and the
  user's prompt (verbatim plus English translation); mark it
  `DONE (YYYY-MM-DD)` with the result when it ends (`AGENTS.md`, "Task log
  before every task").
- Screenshots (local builds and runs, CI/CD) live in `assets/` next to the document that shows them, as clear
  originals, each labeled with platform, environment, repository version or commit, and date and time
  (`AGENTS.md`, "Screenshots of builds and CI/CD").
