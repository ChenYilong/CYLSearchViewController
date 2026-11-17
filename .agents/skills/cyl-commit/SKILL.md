---
name: cyl-commit
description: "Write and check every commit message of this project: git cz (Commitizen) style, the whole message in English with no Chinese characters, the author line, and the steps before committing."
---

# Commits

Full rules: `AGENTS.md`, "Commit readiness"; `instructions.md`, "Commitizen defaults" and "Commitizen commits".

## The rule (2026-11-16)

Every commit is a `git cz` (Commitizen) style commit, and the whole commit message is in English: no Chinese
characters (or any other non-English text) anywhere, in the subject, the body or the trailers.

## Format

```text
<type>(<scope>): <emoji> <subject>        # or <type>: <emoji> <subject>; scope only when it helps

<body: what changed and why, in English; detail over 50 characters goes to a docs/ document linked here>

By  @ChenYilong <luohanchenyilong@163.com>

<trailers>
```

| Type | Emoji | Use |
| :--- | :--- | :--- |
| `feat` | ✨ (🎸 Commitizen default) | A new feature |
| `fix` | 🐛 | A bug fix |
| `docs` | 📝 / ✏️ | Documentation only |
| `refactor` | ♻️ / 💡 | Neither a feature nor a fix |
| `test` | 💍 | Tests |
| `chore` | 🔧 / 🤖 | Build or tooling |
| `style` | 💄 | Formatting only |
| `ci` | 🎡 | CI |
| `perf` | ⚡️ | Performance |
| `release` | 🏹 | An intentional release only |

- The subject is 3 to 64 characters, imperative, and sums up the finished work; remaining work goes in the body and in
  a `TODO` of the related `docs/` document.
- The author line `By  @ChenYilong <luohanchenyilong@163.com>` (two spaces after `By`) comes after the description and
  before the trailers.
- A user prompt in Chinese is never quoted in a commit: it is quoted (with its English translation) in the `docs/`
  task log, and the body links that document.

## Before committing

1. `touch .git/hooks/NO_AUTO_SYNC` (instructions.md, "Commitizen commits").
2. Review the changed scope and record unfinished work as a `TODO` in `docs/` (AGENTS.md, "Commit readiness").
3. Check the message: write it to a file and run `scripts/check-commit-message.sh <file>`; after committing,
   `git log -1 --format=%B | scripts/check-commit-message.sh -`. It fails on a subject that is not git cz style, a subject outside 3 to 64 characters, and on
   any Chinese (CJK) character, and prints the offending lines. Rewrite the message before pushing
   (`git commit --amend` while the commit is not pushed).
4. A commit that adds an image under `docs/assets`: `sh scripts/check-screenshot-labels.sh` prints
   `screenshot labels: ok` (AGENTS.md, "Screenshot labels are enforced").
5. Branches other than `master` / `main`: commit and push without asking; `master` / `main`: ask first.

## Pull requests

- **Every branch with commits has an open pull request (added 2026-11-16).** Never create a branch and keep committing
  to it without a pull request: commits on a branch without a pull request are ignored, they are never reviewed or
  merged.
  - Before every commit, check that the branch has an open pull request (`gh pr list --head <branch> --state open`).
    If it has none, open one.
  - Target (base) of a new pull request: the pull request that was active before this one (its head branch) first;
    `master` only when there is none.
  - When more than two pull requests are already open, stop and ask the user whether to create a new branch with a
    pull request or keep committing on the current branch: more than two open branches make merging hard and leave no
    sensible target branch for each.
  - At the end of every exchange (one question and its answer), when the current branch is not `master` / `main`,
    commit and push without asking: the work is always on a branch, never pushed to `master` / `main`, so pushing is
    safe and carries no risk to worry about.
