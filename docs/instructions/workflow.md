# Task workflow (scenario: every task) (tag: `workflow`)

Details of the `workflow` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## Task log before every task

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

### Start, score and finish every task (added 2026-11-18)

User's rule (2026-11-18): every task starts with a visible `TODO`, is scored
against acceptance criteria written before the work, and does not stop before
it passes. Checklist: the `cyl-task-start` skill.

0. **Read the rules that changed since the session began** (added 2026-11-18): other sessions edit `AGENTS.md`,
   `instructions.md` and the skills while this one runs. `git pull`, then
   `git log --since=<session start> -p -- AGENTS.md instructions.md .agents/skills`, and apply what changed.
1. **Check other sessions first.** List the other sessions (for example
   `ListAgents`) and read their tasks, usually marked `TODO` at the top of each
   session. If no session is editing the same branch, go on. If one is, check
   whether its task is the same as yours: when it is, do not duplicate it (ask
   that session or the user how to split the work); when it is not, go on and
   keep out of its files.
2. **Mark the task at the top of the session**: the first lines of the session's
   reply are `TODO` with the task in one line and the current branch
   (`git branch --show-current`), for example
   `TODO (branch feat/harmonyos-parity): pin CYLTabBarController 6a9ede85`.
3. **Write the task into `docs/`** as in the steps above, adding
   **Acceptance**: what full marks (100) are and what a pass (60) is, as
   checkable items (builds, tests, screenshots, documents, commits pushed).
4. **Score until it passes.** Score the work against the acceptance criteria
   after each milestone. Below the pass mark the task must not be interrupted
   or handed back: keep working and scoring until it passes.
5. **Explain the missing points.** When the score is below 100, say why each
   missing point could not be earned (for example no arm64 device, a peer's
   pending change).
6. **End the session with the missing points as `TODO`s**: the last lines of
   the final reply list every missing point as `TODO (n points): <what is
   missing>`.
7. **Update the document written at the start**: the score, the reasons, the
   remaining `TODO`s, and `DONE (YYYY-MM-DD)` once it reaches 100 (or a pass
   with the missing points listed).

## Task log before every task (instructions.md wording)

Before starting any task, find the most suitable document in `docs/` (the
feature's own document, else `docs/task-log.md`) and add the task there as
`TODO`: the detailed context, every requirement the user gave, and the user's
prompt quoted verbatim with an English translation, plus a status line. Commit
and push it, then start. When the task ends, change `TODO` to
`DONE (YYYY-MM-DD)` with the result and the evidence. The purpose: an
interrupted task never loses its context. Full rule: `AGENTS.md`, "Task log
before every task".

Start, score and finish every task (added 2026-11-18; skill `cyl-task-start`):

1. Check other sessions first: read their tasks (usually `TODO` at the top of
   each session). No session on the same branch: go on. One on the same
   branch: check whether the task is a duplicate before going on.
2. Mark `TODO`, the task and the current branch at the top of the session.
3. In the `docs/` entry, write the acceptance criteria: what full marks (100)
   and a pass (60) are.
4. Score after each milestone; below a pass, do not interrupt the task: keep
   working and scoring until it passes.
5. Say why it is not 100; end the session with each missing point as a `TODO`;
   update the `docs/` entry (score, reasons, remaining `TODO`s).

## Sessions by platform: Mac for iOS, Win for the other platforms (added 2026-11-19)

- Before starting a task, check the session names (for example with `ListAgents`; this session's own name is shown
  there too).
- A session whose name starts with `Mac` (case-insensitive) mainly develops and tests the iOS side.
- A session whose name starts with `Win` (case-insensitive) mainly develops the other platforms (Android, HarmonyOS,
  Flutter, React Native, mini program).
- When sessions of both kinds are active, assign the platform parts of a task to the fitting session: send the iOS
  part to a `Mac` session and the other platforms to a `Win` session, rather than doing every platform yourself.
- When no session follows this naming, skip this rule and finish the task on your own.
