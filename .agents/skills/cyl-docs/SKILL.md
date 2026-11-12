---
name: cyl-docs
description: "Document public integration and reproducible steps for CYLSearchViewController."
---

# Documentation rules

- Keep new instruction and skill files in English.
- Update `README.md` when dependency setup, reproduction steps, or public
  integration changes.
- Document the iOS version, dependency, exact reproduction steps, and known
  workaround without claiming an unverified simulator result.
- Preserve the existing README material and links; append or revise only the
  relevant section.
- Use repository-relative paths and keep third-party attributions intact.

## CYLTabBarController

- Document the CYLTabBarController integration (configuration file, plus
  child view controller, pinned commit) in `README.md` and
  `docs/CYLTabBarController-Integration.md` whenever it changes.
- Link upstream docs at a pinned commit, never `master`, and read their
  `[EN]` parts.
- Before every commit, search `docs/` and `README.md` for `TODO`, `Linux`
  and notes such as "without Xcode" or "no simulator"; verify what can be
  verified and keep the rest under `TODO` with what was checked and when.
- Every commit message body carries
  `By  @ChenYilong <luohanchenyilong@163.com>` (two spaces after `By`),
  before trailers.

## Comments on public API

- Official documentation rules decide every comment format; the project rules
  choose among officially allowed forms and give way where they conflict.
- A public API comment, single-line or multi-line, is one block right above
  the declaration. Where the block form is officially allowed it has three
  lines (`/*!`, ` * Text.`, ` */` in Objective-C). No one-line blocks
  (`/*! Text. */`). No trailing `/**< */`, `/*!< */`, `///<` or `//` after
  declarations or enum values.
- A file with public API uses one comment format for every comment.
- Formats:
  - Objective-C `/*! */`.
  - Swift, Kotlin, Java, TypeScript, JavaScript `/** */`.
  - Python: PEP 257 docstrings.
  - Go `//`.
  - C# `///` with XML tags.
  - Rust `///`.
  - Dart `///`.

  Full rule and sources: `AGENTS.md`, "Comments on public API".

## Branches and pull requests

- Every time a branch is created, open its pull request automatically right
  after the first push, without asking. Target the source branch (the branch
  it was created from) first; use `master` or `main` only when that is the
  source or the source branch no longer exists on the remote.
- Screenshots in `docs/assets/` show search screens with nothing behind the
  search bar (`AGENTS.md`, "Search bar placement").

## Screenshots in docs and README

- Screenshots of local builds and of CI/CD go into the related `docs/` document (images in `docs/assets/`, create
  a document when none fits), as clear originals with platform, environment (host OS, simulator or emulator, SDK
  version), repository version or commit link, and date and time.
- At a key milestone (a `TODO` or `Linux` note can be removed, a PR can be merged, the result works with no known
  bug or open issue) update the screenshot section of `README.md` (create it if missing): cropped key details, not
  full screens unless needed, stitched into one image with `scripts/stitch-screenshots.swift`; layout preference:
  stacked top to bottom, then two columns, then one row of at most three.

## Task log before every task

Before any task, log it as `TODO` in the most suitable document in `docs/`
(else `docs/task-log.md`): context, the user's requirements, the user's prompt
(verbatim plus English translation) and a status line. Commit and push it,
then start; mark it `DONE (YYYY-MM-DD)` with the result when the task ends.
Full rule: `AGENTS.md`, "Task log before every task".

- Pick the document by subject: a feature's document first; `task-log.md`
  only when no document fits. Never start a second tracker for the same task.
- Keep the prompt verbatim even when it is not in English; everything else in
  the entry is English.
- The stale-notes search before a commit skips the open `TODO` of the task in
  progress; every other `TODO` it finds is tested and resolved as before.

## Swift

Swift code follows `docs/swift-coding-standard.md` and the third-party Swift skills in `.agents/skills`
(`swift-api-design-guidelines`, `swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture`,
`uikit`, `uikit-layouting`). The core's translation and its score: `docs/swift-migration.md`.
