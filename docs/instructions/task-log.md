# Task log before every task [`task-log`]

Sessions can stop in the middle of a task (context limits, restarts, another
session taking over the branch or the simulator). So that the next session can
pick the task up, every task is written down in `docs/` before any work starts:

1. **Find the most suitable document in `docs/`**: the feature's own document
   (for example `docs/search-bar-view.md`, `docs/CI-CD.md`,
   `docs/CYLTabBarController-Integration.md`). When none fits, use
   `docs/task-log.md`.
2. **Add the task there as `TODO`, before the first change**, under a heading
   such as `## TODO (YYYY-MM-DD): <task>`, with:
   - **Context**: the background, the branch, the related PRs, issues,
     commits and files, and what is already known;
   - **Requirements**: every requirement the user gave, as a list;
   - **Prompt**: the user's prompt quoted verbatim in its original language,
     followed by an English translation;
   - **Status**: where the work stands; update it at each milestone (commit,
     push, CI result).
   Commit and push this entry before starting the work.
3. **When the task ends, mark it done**: change `TODO` to `DONE (YYYY-MM-DD)`
   and add the result and the evidence (commits, PRs, test results,
   screenshots). An interrupted task keeps `TODO` with its current status.

An open `TODO` of a task in progress is not a stale note: the "stale notes
before every commit" search skips it, and the session that finishes the task
marks it `DONE`.
