# Git, commits and pull requests (tag: `git`)

Details of the `git` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## Read this file in full before any git operation (added 2026-11-22)

- Prompt (verbatim): "找到本项目instructions 相关文件（可能包含根目录的agent Claude文件instructions 文件， 首先确认下面内容的归类。如果agent Claude文件文件超出每个文件200行限制，则优先放入docs 里的instructions文件夹合适文件，）以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入，并且在本次任务中就执行一次下面的指令： 执行git 操作前，必须全文阅读git 对应的tag文件。再进行git操作。"
- Prompt (English): "Find the instruction files (the root agent / Claude / instructions files; first decide where this
  belongs; when an agent or Claude file would pass 200 lines, put the text into a fitting file in `docs/instructions`) and the
  skill files (add files when missing, make sure the write succeeds), write in English, and carry this out once in this
  task: before any git operation, read the git tag file in full; only then run the git operation."
- Rules:
  1. Before any git operation (commit, push, pull, fetch with rebase, rebase, merge, cherry-pick, reset, revert, stash,
     branch, checkout or switch of a branch, tag, worktree, and `gh pr` / `gh api` calls that write), read this file,
     `docs/instructions/git.md`, in full, every line. An excerpt, a summary or memory of an earlier reading does not count.
  2. Once per task is enough while the file is unchanged; read it again when it changed since (`git log -1 --format=%H --
     docs/instructions/git.md` differs from the reading) and after a session restart or a context summary.
  3. Then follow every rule in it for that operation (open pull request, `git cz` message checked by
     `scripts/check-commit-message.sh`, the author line, `NO_AUTO_SYNC`, the `commit-msg` hook, the image label check, …).
  4. Read-only git commands (`status`, `log`, `diff`, `show`, `grep`, `ls-remote`) need no reading first.
- First applied 2026-11-22: this file read in full before the commit that adds this section; the `commit-msg` hook below,
  never installed in this clone before, was installed then. Skill: `cyl-commit`.

## Commit readiness

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

- **Before every commit that adds an image** (added 2026-11-18): `sh scripts/check-screenshot-labels.sh` must print
  `screenshot labels: ok`; fix the image or its label line before committing ("Screenshot labels are enforced").

- **Before every Commitizen-style (`git cz`) commit**, run this first in the repository root, so the vault's auto sync does not commit or push in the middle of it:

  ```sh
  touch .git/hooks/NO_AUTO_SYNC
  ```

- **`git cz` style, English only (added 2026-11-16).** Prompt (verbatim): "写入instructions相关文件以及skills，找到commit规范，如果没找到就新建，寻找关键字 git cz，如果没有就新建，如果有就追加以下规则：全英文写入： git cz 风格提交，全英文commit 不允许出现中午。 continue" ("中午" is a typo for "中文", Chinese). Prompt (English): "Write into the instruction files and the skills: find the commit rules (create them if missing), look for the keyword git cz (create it if missing, append if present) and add, in English: commits in git cz style, commit messages entirely in English, no Chinese allowed. Continue." Rules:
  1. Every commit is a Commitizen (`git cz`) style commit: `<type>(<scope>): <emoji> <subject>` or
     `<type>: <emoji> <subject>`, type one of `test`, `feat`, `fix`, `chore`, `docs`, `refactor`, `style`, `ci`, `perf`,
     `release` (instructions.md, "Commitizen defaults").
  2. The whole message (subject, body, author line and trailers) is in English. No Chinese characters (or any other
     non-English text) are allowed,
     not even a quoted prompt: quote a Chinese prompt in the `docs/` task log and link it from the body instead.
  3. Check before committing: `scripts/check-commit-message.sh <message file>`, or
     `git log -1 --format=%B | scripts/check-commit-message.sh -` for the last commit. It checks the git cz form, the
     subject length (3 to 64 characters) and Chinese characters. A failing message is rewritten
     before pushing. Skill: `cyl-commit`.

- **On any branch other than `master` or `main`, commit and push as soon as the work is written, without asking
  for confirmation.** On `master` or `main`, ask first.

- **Every new branch gets a pull request right away, without asking.** As soon as a branch is created and first
  pushed, open its pull request (`gh pr create`). The base (target) branch is the branch the new one was created from
  (its source branch); use `master` or `main` only when that is the source, or when the source branch no longer exists
  on the remote. Never ask for confirmation first. Name the base in the reply.

- Every commit message carries the author line
  `By  @ChenYilong <luohanchenyilong@163.com>` (exactly as written, two spaces
  after `By`) in its body, after the description and before trailers such as
  `Claude-Session:`. Check it with `git log -1 --format=%B` before pushing.
- Before a Commitizen-style commit, follow the commit-message hook instructions
  in `instructions.md`; inspect an existing hook before replacing it.
- Before every commit, review the changed scope and its related issue,
  comparison, and implementation-status documentation.
- Track each unfinished or unverified item from the commit under a `TODO`
  heading in the most relevant existing `docs/` document. Include remaining
  work, implementation constraints, known defects, verification steps, and API
  design or compatibility risks. Reserved keys, stubs, and compilation alone
  do not prove completion.
- Use an English Conventional Commit subject compatible with Commitizen. Put
  detailed completion and pending-work summaries in the body. If the detailed
  description exceeds 50 characters, create or update a suitable `docs/` note
  and link it from the commit body; reuse existing tracking documents.
- Follow the Commitizen defaults: `{type}{scope}: {emoji}{subject}`, emojis
  enabled, no predefined scopes, and a 3–64 character message. The interactive
  format examples separate the emoji from the subject with a space. The
  type list is `test`, `feat`, `fix`, `chore`, `docs`, `refactor`, `style`,
  `ci`, `perf`; `release` is defined but not listed. Default emojis are
  `chore` 🤖, `ci` 🎡, `docs` ✏️, `feat` 🎸, `fix` 🐛, `perf` ⚡️,
  `refactor` 💡, `style` 💄, `test` 💍, and `release` 🏹. Follow the established
  project emoji where it differs (e.g. CYLTabBarController uses `feat: ✨`,
  `docs: 📝`, `chore: 🔧`, and `refactor: ♻️`). The question sequence is
  `type`, `scope`, `subject`, `body`, `breaking`, `issues`, and `lerna`;
  prompts cover optional scope, imperative subject, longer description,
  breaking changes, issue references, and affected packages.

## Commit readiness (instructions.md wording)

- Before every commit, review the changed scope and related issue, comparison,
  and implementation-status documents. Record every unfinished or unverified
  item from the commit under a `TODO` heading in the most relevant existing
  document under `docs/`.
- A TODO must state the current status or score, remaining work, implementation
  constraints, known defects or optimization opportunities, API design and
  compatibility concerns, and verification required for completion. Reserved
  keys, stubs, and compilation alone are not evidence of completion.
- Every commit message body carries the author line
  `By  @ChenYilong <luohanchenyilong@163.com>` (two spaces after `By`), after
  the description and before trailers.
- Use an English Conventional Commit subject compatible with Commitizen.
  Summarize completed work in the subject and keep details and remaining work
  in the body. If the detailed description exceeds 50 characters, create or
  update a suitable document under `docs/` and link it from the commit body.
  Reuse relevant documents and avoid duplicate trackers.

### Commitizen defaults

- Use `{type}{scope}: {emoji}{subject}` with emojis enabled. Omit an unnecessary
  scope; no scopes are preconfigured. The configured message length is 3–64
  characters. In readable subjects, separate the emoji and subject with a
  space as shown in the project examples below.
- The interactive type choices, in order, are `test`, `feat`, `fix`, `chore`,
  `docs`, `refactor`, `style`, `ci`, and `perf`. `release` has a type definition
  but is not an interactive choice; use it only for an intentional release.
- Default meanings and emojis: `chore` (build or auxiliary-tool changes, 🤖),
  `ci` (CI changes, 🎡), `docs` (documentation only, ✏️), `feat` (new feature,
  🎸), `fix` (bug fix, 🐛), `perf` (performance improvement, ⚡️), `refactor`
  (neither a feature nor a fix, 💡), `style` (markup or formatting only, 💄),
  `test` (adding missing tests, 💍), and `release` (release commit, 🏹).
- The question sequence is `type`, `scope`, `subject`, `body`, `breaking`,
  `issues`, and `lerna`. Prompts request the type, optional scope, short
  imperative subject, longer description, breaking changes, issues closed
  (for example `#123`), and affected packages.
- Respect established repository history when it uses project-specific
  mappings. CYLTabBarController examples include `feat: ✨`, `fix: 🐛`,
  `docs: 📝`, `chore: 🔧`, and `refactor: ♻️`. Commit text must remain English.

### Commit-message hook before Commitizen commits

Before a Commitizen-style commit, run the following from the repository root:

```sh
cat > .git/hooks/commit-msg << 'HOOKEOF'
#!/bin/sh
tmpfile="$1"
if grep -qi "Co-Authored-By:" "$tmpfile" 2>/dev/null; then
  tmp_clean=$(mktemp)
  grep -vi "Co-Authored-By:" "$tmpfile" > "$tmp_clean"
  cat "$tmp_clean" > "$tmpfile"
  rm -f "$tmp_clean"
fi
HOOKEOF
chmod +x .git/hooks/commit-msg
```

This overwrites the existing `commit-msg` hook and removes every line containing
`Co-Authored-By:`, case-insensitively, including other authors' attribution.
Inspect any existing hook before replacing it. The command assumes `.git` is
a directory and Git uses its default hooks path; linked worktrees and custom
`core.hooksPath` require the appropriate hooks path instead.

## Commitizen commits

Before every Commitizen-style (`git cz`) commit, run this first in the repository root:

```sh
touch .git/hooks/NO_AUTO_SYNC
```

Rule (added 2026-11-16): every commit is a `git cz` (Commitizen) style commit, and the whole commit message (subject,
body and trailers) is in English: no Chinese characters (or any other non-English text) are allowed anywhere in it. Check a message with
`scripts/check-commit-message.sh <file>` (or `git log -1 --format=%B | scripts/check-commit-message.sh -`). Skill:
`cyl-commit`. Full rule: `AGENTS.md`, "Commit readiness".

## Committing on branches

On any branch other than `master` or `main`, commit and push as soon as the work is written, without asking for
confirmation. On `master` or `main`, ask first.

## Pull requests for new branches

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

Every time a branch is created, open its pull request automatically as soon as the branch is first pushed
(`gh pr create`), without asking. The base (target) branch is the branch it was created from (its source branch) by
preference; use `master` or `main` only when that is the source, or when the source branch no longer exists on the
remote. Name the base branch in the reply.
