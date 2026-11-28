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
- Status: #6 passed CI (6/6 jobs, run 43112176663) and was merged into
  `feat/search-bar-view` (merge commit `51a0e39`). #5 CI running.

## TODO (2026-11-28): commit the unfinished `instructions.md` rewrite as work in progress

- Context: on `docs/agents-tag-format` (PR #18), `AGENTS.md` is already in the tag format (`65d3558`, `52c6bed`). The root
  `instructions.md` rewrite was started but not finished, and was left uncommitted.
- Prompt (verbatim): "提交本地未完成的代码，commit push pr中写好为什么没写完就commit了，别人应该从哪里写。"
- Prompt (English): "Commit the unfinished local code and push; in the PR, explain why it was committed unfinished and where
  others should continue."
- Status: committed as work in progress. Remaining work:
  1. Add the `docs-lookup` and `reply-greeting` headings to `instructions.md` (`AGENTS.md` has them).
  2. Use the `AGENTS.md` layout: `## <Heading> (tag: ...)` with bullets, links only in a final tag table.
  3. Check that every rule removed from the old `instructions.md` exists in a `docs/instructions/<tag>.md` file. Check these first:
     the Podfile header and `post_install` snippets, the comment form for each language, the AppIcon and launch screen rule,
     the Issue #1317 inset details, and the CYLTabBarController integration steps. Move anything missing into its tag file
     instead of deleting it.
  4. Keep `instructions.md` under 200 lines (87 now).

## TODO (2026-11-29): finish the WIP `instructions.md` rewrite

- Context: continues the entry of 2026-11-28 above, on `docs/agents-tag-format` (PR #18), from commit `2e3c1fa`.
- Requirements: do the four remaining items of that entry; move missing rules into tag files instead of deleting them.
- Prompt (verbatim): "finish the WIP"
- Prompt (English): "finish the WIP"
- Status: started.
