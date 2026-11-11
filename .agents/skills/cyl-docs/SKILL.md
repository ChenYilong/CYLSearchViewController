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
