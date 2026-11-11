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

- A multi-line comment on a public declaration is one documentation block,
  never stacked `//` or `///` lines: Objective-C public headers `/*! … */`;
  public API in Swift `/** … */` or `///`; Kotlin / Java `/** … */`;
  TypeScript / JavaScript `/** … */`; Dart `///`.
- The same format applies to single-line public API comments. In a file that
  contains public API, keep the comment format uniform. This applies to all
  platforms and all languages. Full rule: `AGENTS.md`, "Comments on public API".
