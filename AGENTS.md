# Agent rules for this repository (any tool)

This repository is an Objective-C iOS search sample. It uses `CYLTableViewPlaceHolder` to show how a navigation-item search controller interacts with pull to refresh. Read `instructions.md` and the matching skill in `.agents/skills/` before making changes.

## Instruction format

Every rule has a tag. Each tag has a visible heading with its summary; the full text is in `docs/instructions/<tag>.md`, linked in the final table as `reference` (not required; do not read by default): open it only when a task touches the tag (a keyword of the tag appears in the task). Instruction files (this file, `instructions.md`, `docs/instructions.md`, `CLAUDE.md`) stay under 200 lines; what does not fit goes into the tag's file in `docs/instructions/`. Except for the final table, no other part of this file may contain links.

## Skills (tag: `skills`)

- Pick the right `.agents/skills` skill from the skill table in the reference doc.
- Every new integration rule updates `AGENTS.md`, `instructions.md`, and the affected skills in the same change.
- Full rule: at reference of this tag (not required; do not read by default).

## Project rules (tag: `project-rules`)

- New project-owned types use the `CYL` prefix; new UIKit categories use `+CYL` and `cyl_` methods and properties.
- Do not rename unrelated APIs or vendor symbols; keep third-party attribution; expose `CYLTableViewPlaceHolder` only through its umbrella header; keep samples configurable; keep instruction and skill files in English.
- Full rule: at reference of this tag (not required; do not read by default).

## Comments on public API (tag: `public-api-comments`)

- Public API comments follow the official documentation rules of their language.
- One documentation block per declaration (three lines, even for a one-line comment, where the block form is allowed); one comment format per public file; never a trailing comment after a declaration.
- Full rule: at reference of this tag (not required; do not read by default).

## Xcode project (tag: `xcode-project`)

- Keep the Xcode project format (`objectVersion = 46`, Xcode 3.2 compatibility), explicit file lists, and the shared scheme.
- Keep the Podfile and Xcode deployment targets at iOS 15.0, keep the Pods `post_install` deployment-target hook, and verify the AppIcon and launch assets.
- Never commit `Pods/`, generated workspace state, or `._*` files.
- Full rule: at reference of this tag (not required; do not read by default).

## Search bar placement (tag: `search-bar-placement`)

- A search bar never covers any view, in any state or at any Dynamic Type size.
- Lay out search bars against the safe area beside the content; search screens do not extend under the top bar; `testSearchBarsCoverNoView` covers every search bar.
- Full rule: at reference of this tag (not required; do not read by default).

## Issue #1317 (tag: `issue-1317`)

- The reproduction combines `navigationItem.searchController` with `CYLRefreshNormalHeader`.
- Keep `hidesSearchBarWhenScrolling = NO` as the safe default, avoid strong captures in refresh blocks, and always stop the refresh controls.
- Full rule: at reference of this tag (not required; do not read by default).

## CYLTabBarController (tag: `cyl-tabbar`)

- The example integrates CYLTabBarController by default: a local bundle configuration file, registered page providers, and a plus button with its own plus child view controller.
- Depend on the latest CYLTabBarController commit through CocoaPods and import only its umbrella header; search pages stay inside the tabs' navigation controllers; build with clean derived data after a dependency change.
- Full rule: at reference of this tag (not required; do not read by default).

## Verification (tag: `verification`)

- Run `pod install`, validate the project, build and analyze the shared scheme, and run the tests when available.
- Never claim a visual reproduction or fix without launching the app on a simulator.
- CI scripts pass ShellCheck and workflows pass actionlint; follow `docs/CI-CD.md`.
- Full rule: at reference of this tag (not required; do not read by default).

## Task log before every task (tag: `task-log`)

- Before any work starts, record the task as a `TODO` in the most suitable `docs/` file: context, requirements, the prompt verbatim plus an English translation, and the status.
- Commit and push the entry before starting; mark it `DONE`, with evidence, when finished.
- Full rule: at reference of this tag (not required; do not read by default).

## Commit readiness (tag: `commit-readiness`)

- Before `git cz`, create `.git/hooks/NO_AUTO_SYNC`.
- On a branch other than `main` / `master`: commit and push as soon as the work is written, and open a pull request right away; on `main` / `master`, ask first.
- English Commitizen-compatible subjects with the required author line; inspect the commit-msg hook before replacing it; track unfinished work as `TODO`s in `docs/`; follow the project's Commitizen defaults.
- Full rule: at reference of this tag (not required; do not read by default).

## Finding the document a prompt refers to (tag: `docs-lookup`)

- When a prompt mentions a related document without naming it, find it in memory and the conversation context first: prefer the file mentioned most often and most recently.
- If it is still unclear which document is meant, create a new document instead of searching for one.
- Never scan the contents of every file under `docs/`, and never read a document under `docs/` in full unless the owner explicitly names that document and asks for a full read, or authorizes it.
- Full rule: at reference of this tag (not required; do not read by default).

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
