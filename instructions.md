# Folder Instructions

This repository contains an Objective-C search UI sample and the Issue #1317
reproduction for `UISearchController` with `CYLTableViewPlaceHolder` refresh.
Read this file and `AGENTS.md` before changing project files.

## Instruction format

- Every rule has a tag. Each tag has a visible heading with its summary; full
  text lives in `docs/instructions/<tag>.md`, linked under the heading. Open
  the tag file when a task touches the tag (a keyword appears in the task).
- Instruction files (`AGENTS.md`, `instructions.md`, `docs/instructions.md`,
  `CLAUDE.md`) stay under 200 lines; overflow goes into
  `docs/instructions/<tag>.md`.

## Rules

### Skills [`skills`](docs/instructions/skills.md)

Use the skill table in the tag file to pick the right `.agents/skills` skill.
Every new integration rule updates `AGENTS.md`, `instructions.md`, and the
affected skills in the same change.

### Project rules [`project-rules`](docs/instructions/project-rules.md)

New project-owned types use the `CYL` prefix; new UIKit categories use `+CYL`
and `cyl_` methods/properties. Do not rename unrelated APIs or vendor symbols,
keep third-party attribution, expose `CYLTableViewPlaceHolder` only through its
umbrella header, keep samples configurable, and keep instruction/skill files in
English.

### Comments on public API [`public-api-comments`](docs/instructions/public-api-comments.md)

Public API comments follow the official documentation rules of their language.
Use one documentation block per declaration (three lines even for single-line
comments where block form is allowed), keep one comment format per public file,
and never add trailing declaration comments.

### Xcode project [`xcode-project`](docs/instructions/xcode-project.md)

Preserve Xcode format 46/Xcode 3.2 compatibility, explicit file lists, and the
shared scheme. Keep Podfile/Xcode deployment targets at iOS 15.0, require the
Pods `post_install` deployment-target hook, verify AppIcon/launch assets, and
never commit `Pods/`, generated workspace state, or `._*` files.

### Search bar placement [`search-bar-placement`](docs/instructions/search-bar-placement.md)

A search bar must never cover any view in any state or Dynamic Type size.
Layout search bars against the safe area beside content, keep search screens
from extending under the top bar, and cover every search bar in
`testSearchBarsCoverNoView`.

### Issue #1317 [`issue-1317`](docs/instructions/issue-1317.md)

The reproduction combines `navigationItem.searchController` with
`CYLRefreshNormalHeader`. Keep `hidesSearchBarWhenScrolling = NO` as the safe
default, avoid strong refresh-block captures, and always stop refresh controls.

### CYLTabBarController [`cyl-tabbar`](docs/instructions/cyl-tabbar.md)

Integrate CYLTabBarController by default in the example through a local bundle
configuration file, registered page providers, and a plus button/plus child
controller. Depend on the latest CYLTabBarController commit via CocoaPods,
import only its umbrella header, keep search pages inside tab navigation
controllers, and build with clean derived data after dependency changes.

### Verification [`verification`](docs/instructions/verification.md)

Run `pod install`, validate the project, build/analyze the shared scheme, and
run tests when available. Do not claim visual reproduction/fix without
launching on a simulator. Keep CI scripts shellcheck-clean and workflows
actionlint-clean; follow `docs/CI-CD.md`.

### Task log before every task [`task-log`](docs/instructions/task-log.md)

Before any work starts, record the task as `TODO` in the most suitable `docs/`
file with context, requirements, verbatim prompt plus English translation, and
status. Commit/push the entry before starting; mark it `DONE` with evidence
when finished.

### Commit readiness [`commit-readiness`](docs/instructions/commit-readiness.md)

Before `git cz`, create `.git/hooks/NO_AUTO_SYNC`. On non-main/master branches
commit and push when work is written and open a PR immediately; on main/master
ask first. Use English Commitizen-compatible subjects, include the required
author line, inspect/replace commit-msg hook as needed, track unfinished work
in `docs/` TODOs, and follow the project Commitizen defaults.
