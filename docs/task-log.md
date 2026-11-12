# Task Log

Tasks that have no better home in `docs/` are logged here (`AGENTS.md`,
"Task log before every task"). A task that belongs to a feature is logged in
that feature's document instead. Each entry starts as `TODO` before the work
begins and becomes `DONE` when it ends.

## DONE (2026-11-12): log every task in docs/ before starting it

- Context: the user runs several Claude sessions on this repository at once,
  and a session can stop mid-task (context limits, restarts, another session
  taking over a branch or the simulator). The next session needs to find
  what was asked and how far it got.
- Requirements:
  - Write the rule into the instruction files (`AGENTS.md`,
    `instructions.md`, folder `instructions.md` files) and the skills, in
    English.
  - Before any task: find the most suitable document in `docs/`, add the
    task there marked `TODO`, with the detailed context, the user's
    requirements and the user's prompt; then start the task.
  - When the task ends, mark it done.
  - Purpose: no context is lost when a task is interrupted.
- Prompt (verbatim): "写入instructions相关文件，skills相关文件，开始任何任务前总是找到docs里的合适文档，现将任务标记为TODO ，给出任务详细上下文以及我的要求，我的提示词，再开始任务，目的是防止任务中断后，丢失上下文，无法找到上下文。任务结束后再标记TODO为已完成。"
- Prompt (English): "Write into the instruction files and the skill files:
  before starting any task, always find a suitable document in docs/, first
  mark the task as TODO with the task's detailed context, my requirements
  and my prompt, then start the task. The purpose is to avoid losing the
  context when a task is interrupted. When the task ends, mark the TODO as
  done."
- Result: the rule is in `AGENTS.md` ("Task log before every task"),
  `instructions.md`, `docs/instructions.md`, the folder `instructions.md`
  files (`CYLSearchExample/`, `CYLSearchExampleTests/`,
  `Sources/CYLSearchViewController/`, `scripts/`) and all seven `cyl-*`
  skills; `cyl-docs` adds how to pick the document. This entry was logged
  first (commit `eb0ce70`), as the rule requires. Branch
  `feat/search-bar-view`.

## DONE (2026-11-12): merge PR #6, then PR #5, after CI

- Context: PR #6 (`docs/todo-sweep` → `feat/search-bar-view`) holds one
  commit, `29fdf24`: the scene life cycle (the example did not launch when
  built with the iOS 27 SDK), page titles that renamed their tabs, and
  `scripts/public-api-doc-coverage.sh`. PR #5 (`feat/search-bar-view` →
  `master`) holds CYLSearchBarView, the CYLTabBarController example and the
  search bar placement rule. The duplicate tab bar integration that was on
  `docs/todo-sweep` was dropped (local tag `backup/todo-sweep-935da41`).
- Requirements: wait until CI has finished, merge #6 into
  `feat/search-bar-view`, then wait for #5's CI and merge #5 into `master`.
- Prompt (verbatim): "CI结束后，合并分支，以下分支 #5 feat/search-bar-view → master … #6 docs/todo-sweep → feat/search-bar-view (its source)"
- Prompt (English): "After CI finishes, merge these branches: #5
  feat/search-bar-view → master, and #6 docs/todo-sweep →
  feat/search-bar-view."
- Result: #6 passed CI (6/6 jobs, run 43112176663) and was merged into
  `feat/search-bar-view` (merge commit `51a0e39`). #5 passed CI on
  `ac03541` (6/6 jobs) and was merged into `master` (merge commit
  `55022ba`).

## TODO (2026-11-12): retarget every open PR to the current branch, merge, keep only it

- Context: current branch `feat/swift-core` (PR #8 → `feat/search-api-parity`). Open PRs: #7
  (`feat/search-api-parity` → `master`), #8, and #2 from a fork (`master` → `master`, "Fix broken headings in
  Markdown files"). Remote branches `claude/youthful-mendel-pn01ru`, `docs/todo-sweep`, `feat/search-api-parity`
  and `feat/search-bar-view` have no commit that `feat/swift-core` lacks.
- Requirements: point every open PR at `feat/swift-core`; merge them all into it, resolving conflicts; keep only
  the current branch (delete the others; `master` stays as the default branch); then continue the unfinished tasks.
- Prompt (verbatim): "将所有处于open状态的分支的target branch指向本分支，当前分支，全部合并仅仅保留当前分支，处理冲突后合并，继续以上未完成的任务。"
- Prompt (English): "Point the target branch of every open branch at this branch, the current branch; merge them
  all and keep only the current branch; merge after resolving conflicts; continue the unfinished tasks above."
- Status: logged.

## TODO (2026-11-12): pull request for the clean sibling checkout

- Context: while building, the sibling `CYLTableViewPlaceHolder` had another session's uncommitted, half-finished
  `CYLRefresh/Custom/Drawn/` folder, so this session built against a clean detached checkout of its last commit
  (`18971fe`) in its own scratch folder. That checkout has no changes of this session.
- Requirement: "then create a PR that merges into the current branch".
- Prompt (verbatim): "found an uncommitted, half-finished Drawn/ folder in the sibling's working tree, so I'm building from a clean checkout of their last commit in my own folder instead. then create pr merge to current branch"
- Status: logged; to check what can be put in a PR (this session changed nothing in the sibling).
