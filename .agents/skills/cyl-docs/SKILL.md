---
name: cyl-docs
description: "Document public integration and reproducible steps for CYLSearchViewController."
---

## Instruction files: categories, tags, 200 lines (rule, 2026-11-22)

`AGENTS.md` and `instructions.md` (and `CLAUDE.md`, which imports `AGENTS.md`) stay within 200 lines each. Their content is
grouped under one always-visible heading per category, `## <Category> (tag: `tag`)` (behavioral first, then skills, meta, workflow, git, core,
dependencies, animation, testing, docs, macos, windows, harmonyos, miniprogram, accessibility-i18n, licenses,
code-style). Each heading holds the must-know rules and a relative link to `docs/instructions/<tag>.md`, the full text;
read that file when a task touches the tag. A new rule: full text in its tag file, one line under the heading when every
agent must know it; a new category: a new tag in both files and a new tag file; never drop a rule to save lines. Check:
`wc -l AGENTS.md instructions.md` (200 at most) and that every relative link resolves. Full rule:
[docs/instructions/meta.md](../../../docs/instructions/meta.md).

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
- Correction (user, 2026-11-12): the original wording, "prefer the horizontal arrangement" and "worst is horizontal stitching", contradicted itself; the rule is to prefer the vertical arrangement, one image per row stacked top to bottom.
- Enforced (added 2026-11-18): every image committed to `docs/assets` (not only stitched ones) is made with
  `swift scripts/stitch-screenshots.swift` (macOS) or `scripts/stitch-screenshots.ps1` (Windows) with a header and a
  footer; the document line that links it carries the label (platform, device and OS, SDK / IDE, host OS, commits,
  date with time zone). `sh scripts/check-screenshot-labels.sh` must pass before every commit that adds an image; CI
  runs it too. Re-read rules changed since the session began at each task start. Full rule: `AGENTS.md`, "Screenshot
  labels are enforced".

- Stitched screenshots (added 2026-11-18, replaces the order above): one column over several rows; two columns over
  several rows when one column would be taller than one phone screen (one full screenshot of the device). A header
  above and a footer below, in bands of their own that never cover a screenshot, bold, English: header (red) with the
  platform, simulator or emulator and its OS version, IDE or SDK version, host OS when it matters, library and
  repository commits, branch, date, and the purpose; a red caption above each panel (state, timing, measured result);
  footer (dark gray) with the result and what is needed to reproduce. Example: "iOS 27.2, iPhone 17 Pro sim, Xcode
  27.2, CYLTabBarController dcbfdec6 (ef1d0313), feat/harmony, 2026-11-18. Rive tags at rest (no play)". Tool:
  `swift scripts/stitch-screenshots.swift --header ... --footer ... --out OUT.png IN.png=caption ...`. Full rule:
  `AGENTS.md`, "Stitched screenshots: layout, header and footer".

## Task log before every task

Before any task, log it as `TODO` in the most suitable document in `docs/`
(else `docs/task-log.md`): context, the user's requirements, the user's prompt
(verbatim plus English translation) and a status line. Commit and push it,
then start; mark it `DONE (YYYY-MM-DD)` with the result when the task ends.
Full rule: `AGENTS.md`, "Task log before every task".
Also before any task: check other sessions, mark `TODO` and the branch at the top of the session, write
acceptance criteria (full marks, pass), score until it passes, end with the missing points as `TODO`s
(`cyl-task-start`).

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

## Open pull requests and issues of projects we translate

When we translate or port another GitHub project's code (for example `android/`), merge its open pull requests
(before translating, or translate and merge them afterwards), list its open issues in a `docs/` table (issue link,
description, fix status `TODO`), fix them in our code and score after every fix until 100; a translation that has not
started begins at 60. Full rule: `AGENTS.md`, same section.

## Swift core: examples adapt to the core (added 2026-11-13)

When an Objective-C to Swift change of the core breaks an example's build, fix the example: example code has the lowest weight of all code here. Change any example code as needed; never keep a core API, overload, shim or deprecated alias only because an example uses it, and never lower the Swift core's quality (naming, types, optionality, access control) to fit an example. Compatibility matters only for callers outside the examples (published API users). The Swift coding standard (docs/swift-coding-standard.md) decides. Rule and context: [docs/swift-migration.md](../../../docs/swift-migration.md).
