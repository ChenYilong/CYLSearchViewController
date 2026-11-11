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

## TODO (2026-11-12): merge PR #6, then PR #5, after CI

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
- Status: #6 CI running (run 43112176663).
