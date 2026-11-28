# Folder Instructions

This repository contains an Objective-C search UI sample and the Issue #1317
reproduction for `UISearchController` with `CYLTableViewPlaceHolder` refresh.
Read this file and `AGENTS.md` before changing project files.

## Instruction format

- Every rule has a tag. Each tag has a visible heading with its summary; the full text is in
  `docs/instructions/<tag>.md`, linked only in the final table. Open it only when a task touches the tag (a keyword of
  the tag appears in the task).
- Instruction files (`AGENTS.md`, `instructions.md`, `docs/instructions.md`, `CLAUDE.md`) stay under 200 lines; what
  does not fit goes into the tag's file in `docs/instructions/`.
- Except for the final table, no other part of this file may contain links.

## Skills (tag: `skills`)

- Use the skill table in the tag file to pick the right `.agents/skills` skill.
- Every new integration rule updates `AGENTS.md`, `instructions.md`, and the affected skills in the same change.

## Project rules (tag: `project-rules`)

- New project-owned types use the `CYL` prefix; new UIKit categories use `+CYL` and `cyl_` methods/properties.
- Do not rename unrelated APIs or vendor symbols, keep third-party attribution, expose `CYLTableViewPlaceHolder` only
  through its umbrella header, keep samples configurable, and keep instruction/skill files in English.

## Comments on public API (tag: `public-api-comments`)

- Public API comments follow the official documentation rules of their language.
- Use one documentation block per declaration (three lines even for single-line comments where block form is allowed),
  keep one comment format per public file, and never add trailing declaration comments.

## Xcode project (tag: `xcode-project`)

- Preserve Xcode format 46/Xcode 3.2 compatibility, explicit file lists, and the shared scheme.
- Keep Podfile/Xcode deployment targets at iOS 15.0, require the Pods `post_install` deployment-target hook, verify
  AppIcon/launch assets, and never commit `Pods/`, generated workspace state, or `._*` files.

## Search bar placement (tag: `search-bar-placement`)

- A search bar must never cover any view in any state or Dynamic Type size.
- Layout search bars against the safe area beside content, keep search screens from extending under the top bar, and
  cover every search bar in `testSearchBarsCoverNoView`.

## Issue #1317 (tag: `issue-1317`)

- The reproduction combines `navigationItem.searchController` with `CYLRefreshNormalHeader`.
- Keep `hidesSearchBarWhenScrolling = NO` as the safe default, avoid strong refresh-block captures, and always stop
  refresh controls.

## CYLTabBarController (tag: `cyl-tabbar`)

- Integrate CYLTabBarController by default in the example through a local bundle configuration file, registered page
  providers, and a plus button/plus child controller.
- Depend on the latest CYLTabBarController commit via CocoaPods, import only its umbrella header, keep search pages
  inside tab navigation controllers, and build with clean derived data after dependency changes.

## Verification (tag: `verification`)

- Run `pod install`, validate the project, build/analyze the shared scheme, and run tests when available.
- Do not claim visual reproduction/fix without launching on a simulator.
- Keep CI scripts shellcheck-clean and workflows actionlint-clean; follow `docs/CI-CD.md`.

## Task log before every task (tag: `task-log`)

- Before any work starts, record the task as `TODO` in the most suitable `docs/` file with context, requirements,
  verbatim prompt plus English translation, and status.
- Commit/push the entry before starting; mark it `DONE` with evidence when finished.

## Commit readiness (tag: `commit-readiness`)

- Before `git cz`, create `.git/hooks/NO_AUTO_SYNC`.
- On non-main/master branches commit and push when work is written and open a PR immediately; on main/master ask
  first.
- Use English Commitizen-compatible subjects, include the required author line, inspect/replace commit-msg hook as
  needed, track unfinished work in `docs/` TODOs, and follow the project Commitizen defaults.

## Finding the document a prompt refers to (tag: `docs-lookup`)

- When a prompt mentions a related document without naming it, find it in memory and the conversation context first: prefer the file mentioned most often and most recently.
- If it is still unclear which document is meant, create a new document instead of searching for one.
- Never scan the contents of every file under `docs/`, and never read a document under `docs/` in full unless the owner explicitly names that document and asks for a full read, or authorizes it.

## Reply greeting (tag: `reply-greeting`)

- Start every reply with `Hi, <OS>/<folder>:`, then answer. `<OS>` is the session's operating system; `<folder>` is the name of the session's working folder.
- Example: a macOS session in `/Volumes/obsidian/chenyilong/chenyilong/CYLTabBarController` starts with `Hi, macOS/CYLTabBarController:`.

## Tag reference

| Tag | Heading | Reference (not required; do not read by default) |
|:---|:---|:---|
| `skills` | Skills | [reference](docs/instructions/skills.md) (not required; do not read by default) |
| `project-rules` | Project rules | [reference](docs/instructions/project-rules.md) (not required; do not read by default) |
| `public-api-comments` | Comments on public API | [reference](docs/instructions/public-api-comments.md) (not required; do not read by default) |
| `xcode-project` | Xcode project | [reference](docs/instructions/xcode-project.md) (not required; do not read by default) |
| `search-bar-placement` | Search bar placement | [reference](docs/instructions/search-bar-placement.md) (not required; do not read by default) |
| `issue-1317` | Issue #1317 | [reference](docs/instructions/issue-1317.md) (not required; do not read by default) |
| `cyl-tabbar` | CYLTabBarController | [reference](docs/instructions/cyl-tabbar.md) (not required; do not read by default) |
| `verification` | Verification | [reference](docs/instructions/verification.md) (not required; do not read by default) |
| `task-log` | Task log before every task | [reference](docs/instructions/task-log.md) (not required; do not read by default) |
| `commit-readiness` | Commit readiness | [reference](docs/instructions/commit-readiness.md) (not required; do not read by default) |
| `docs-lookup` | Finding the document a prompt refers to | [reference](docs/instructions/docs-lookup.md) (not required; do not read by default) |
| `reply-greeting` | Reply greeting | [reference](docs/instructions/reply-greeting.md) (not required; do not read by default) |
