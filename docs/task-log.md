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

## DONE (2026-11-12): retarget every open PR to the current branch, merge, keep only it

- Context: current branch `feat/swift-core` (PR #8 → `feat/search-api-parity`). Open PRs: #7
  (`feat/search-api-parity` → `master`), #8, and #2 from a fork (`master` → `master`, "Fix broken headings in
  Markdown files"). Remote branches `claude/youthful-mendel-pn01ru`, `docs/todo-sweep`, `feat/search-api-parity`
  and `feat/search-bar-view` have no commit that `feat/swift-core` lacks.
- Requirements: point every open PR at `feat/swift-core`; merge them all into it, resolving conflicts; keep only
  the current branch (delete the others; `master` stays as the default branch); then continue the unfinished tasks.
- Prompt (verbatim): "将所有处于open状态的分支的target branch指向本分支，当前分支，全部合并仅仅保留当前分支，处理冲突后合并，继续以上未完成的任务。"
- Prompt (English): "Point the target branch of every open branch at this branch, the current branch; merge them
  all and keep only the current branch; merge after resolving conflicts; continue the unfinished tasks above."
- Result: #2 (fork, README heading fix) retargeted to `feat/swift-core` and merged (`e9ca91e`). #7 could not be
  retargeted (GitHub: no new commits; all of `feat/search-api-parity` is in `feat/swift-core`), so it was closed
  with a note. #8 (`feat/swift-core`) now targets `master`. Remote branches `claude/youthful-mendel-pn01ru`,
  `docs/todo-sweep`, `feat/search-api-parity` and `feat/search-bar-view` (each with 0 commits missing from
  `feat/swift-core`) were deleted; `feat/swift-core` and `master` (the default branch, which cannot be deleted)
  remain. Local branches and worktrees of this session were removed. The shared working folder is still on the
  local `feat/search-bar-view` of another session and was not touched.

## TODO (2026-11-12): pull request for the clean sibling checkout

- Context: while building, the sibling `CYLTableViewPlaceHolder` had another session's uncommitted, half-finished
  `CYLRefresh/Custom/Drawn/` folder, so this session built against a clean detached checkout of its last commit
  (`18971fe`) in its own scratch folder. That checkout has no changes of this session.
- Requirement: "then create a PR that merges into the current branch".
- Prompt (verbatim): "found an uncommitted, half-finished Drawn/ folder in the sibling's working tree, so I'm building from a clean checkout of their last commit in my own folder instead. then create pr merge to current branch"
- Status: logged; to check what can be put in a PR (this session changed nothing in the sibling).

## DONE (2026-11-12): rule for open PRs and issues of projects we translate

- Context: `android/` holds Kotlin transcriptions of five GitHub projects, made from their default branches without
  their open pull requests and issues (`docs/android-and-cross-platform.md`).
- Requirements: write a rule (English) into the instruction files and the skills: when a document of this project
  links to another project's GitHub repository for translation or similar work, merge that project's open PRs
  (before translating; or, when the translation is done, translate the open PRs and merge them in); list its open
  issues in a `docs/` table (issue link, description, fix status, default `TODO`); find each issue's counterpart in
  our code and fix it; score after each fix until 100. Translation may start once the issues reach 60. The same rule
  applies on every platform.
- Prompt (verbatim): "写入一条规则到。instructions相关文件和skills文件中，全英文写入以下规则：如果本项目文档中出现了 非本项目的 GitHub 链接，切该链接是用来 做代码翻译等任务的，那么在翻译过程前，或者翻译过程后，需要 访问该GitHub 的 pr 链接，将处于open状态的pr合并进来。并且为该项目的issues页面，中处于open状态的issues在docs文件夹下相关文档，如果没有就新建文档中制作表格，第一列为issue地址 第二列为issue描述，第三列为修复状态，默认填TODO。你需要找到这些issue在我们项目代码中的对应项，尝试修复。issues修复完为满分，每修复一个issue打一次分，一直到满分为止。 举例说明：比如：本项目的android文件夹内，存在多个其他项目翻译为kotlin的任务，这些任务均默认翻译master分支代码，忽略了pr与issues内容，如果翻译任务还未开启那么就先 merge 该项目处于open状态的pr，再尝试解决open issues，只要issues处理状态达到60分，就可以开始翻译工作，翻译完成后，再开始尝试解决剩余的issues到满分。如果翻译工作已经完成，那么就单独对open pr内容进行翻译后，再merge到我们的项目中。基于翻译过的代码还是要处理issues。一直到满分。其他平台同样规则执行。"
- Prompt (English): "Write a rule into the instruction files and the skill files, all in English: if this project's
  documents contain a GitHub link that is not this project's, and the link is used for code translation or similar
  tasks, then before or after translating, visit that GitHub project's PRs and merge the open ones in. For the open
  issues on its issues page, make a table in a related document in docs (create one if none): first column the issue
  link, second the issue description, third the fix status, TODO by default. Find each issue's counterpart in our
  code and try to fix it. All issues fixed is full marks; score after each fixed issue until full marks. Example: the
  android folder has several projects translated to Kotlin, all from the master branch, ignoring PRs and issues. If a
  translation has not started, first merge the project's open PRs, then try to solve the open issues; once the issue
  status reaches 60 the translation may start, and after it, solve the remaining issues to full marks. If the
  translation is already done, translate the open PRs' content separately and merge it into our project, and still
  handle the issues on the translated code, until full marks. Other platforms follow the same rule."
- Result: the rule is in `AGENTS.md` ("Open pull requests and issues of projects we translate"), `instructions.md`,
  `docs/instructions.md`, `android/README.md` and every `cyl-*` skill. Applying it to the five projects in `android/`
  (their translation is done: translate and merge their open PRs, then the issue tables and fixes) is a follow-up
  recorded in `docs/android-and-cross-platform.md`.

## TODO (2026-11-12): CYLTableViewPlaceHolder as a sub-repository on every platform

- Logged in [sub-repositories.md](sub-repositories.md) (context, requirements, prompt verbatim and in English).
  The rules are written; the integration is open.
