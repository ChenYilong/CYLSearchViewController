---
name: cyl-task-start
description: "Starting, scoring and finishing any task in CYLSearchViewController: check other sessions first (split platform work: Mac sessions iOS, Win sessions the others), mark TODO and the branch at the top of the session, log the task in docs/ with acceptance criteria (full marks and pass), score until it passes, end with the missing points as TODOs; restart a hung emulator after telling the other sessions."
---

> **Before step 0, read in full** [docs/instructions/behavioral.md](../../../docs/instructions/behavioral.md)
> (tag `behavioral` in `AGENTS.md`): every line, at the start of every task.

# Start, score and finish every task

Full rules: `AGENTS.md`, "Task log before every task" (with "Start, score and finish every task") and "Emulators
and simulators: restart when hung" (user's rules, 2026-11-18).

## Before the first change

0. **Read the rules that changed since the session began** (other sessions edit them):
   `git pull`, then `git log --since=<session start> -p -- AGENTS.md instructions.md .agents/skills`; apply them.
1. **Check other sessions.** List them (for example `ListAgents`) and read their tasks, usually marked `TODO` at the
   top of each session.
   - No session is editing the same branch: go on.
   - One is: check whether its task is the same. Same task: do not duplicate it; ask that session or the user how to
     split the work. Different task: go on and keep out of its files.
   - **Split by platform (added 2026-11-19)**: a session named `Mac...` (case-insensitive) mainly develops and tests
     iOS; a session named `Win...` mainly develops the other platforms. When sessions of both kinds are active, send
     each platform part of the task to the fitting session (iOS to `Mac`, the others to `Win`). When no session
     follows this naming, skip this step and do the task on your own. Rule: `AGENTS.md`, "Sessions by platform".
2. **Mark the task at the top of the session**: the first lines of the reply are
   `TODO (branch <git branch --show-current>): <the task in one line>`.
3. **Log the task in `docs/`** (the feature's document, else `docs/task-log.md`) under
   `## TODO (YYYY-MM-DD): <task>`: Branch, Context, Requirements, the user's Prompt (verbatim plus English), Status,
   and **Acceptance**:
   - **Full marks (100)**: every requirement done and verified (builds, tests, screenshots, documents, pushed).
   - **Pass (60)**: the minimum that makes the task usable, as checkable items.
   Commit and push the entry before starting.

## While working

4. **Score after each milestone** against the acceptance criteria. A screenshot without its header, footer and label
   line (`sh scripts/check-screenshot-labels.sh` fails) keeps the task below a pass. Below 60 the task must not be interrupted or
   handed back: keep working and scoring until it passes.

## At the end

5. **Explain every missing point**: why it could not be earned (for example no arm64 device, a peer's change
   pending, the user's decision needed).
6. **End the session's final reply with the missing points as `TODO`s**, one per line:
   `TODO (n points): <what is missing>`.
7. **Update the `docs/` entry**: score, reasons, remaining `TODO`s; `DONE (YYYY-MM-DD)` at 100 (or at a pass with
   the missing points listed).

## Hung emulators and simulators

- **Stays hung until restarted** (`adb shell echo` answers but `pm`, `am` and installs time out; `hdc` hangs): tell
  the other sessions that use it first (what hangs, that you restart it now), then restart it.
- **Does not open or does not finish booting**: restart it first, before any other diagnosis.
- **Restart from the command line, without asking the user**:
  - Android: `adb -s emulator-5556 reboot`; if `adb` cannot reach it, `adb -s emulator-5556 emu kill`, then
    `emulator -avd <name> -no-snapshot-load`.
  - HarmonyOS: `hdc -t 127.0.0.1:5555 shell reboot`.
  - iOS simulator: `xcrun simctl shutdown <udid> && xcrun simctl boot <udid>`.
  Tell the other sessions again when it is back.
