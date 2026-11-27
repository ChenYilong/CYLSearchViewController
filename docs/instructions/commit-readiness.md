# Commit readiness [`commit-readiness`]

- **Before every Commitizen-style (`git cz`) commit**, run this first in the repository root, so the vault's auto sync does not commit or push in the middle of it:

  ```sh
  touch .git/hooks/NO_AUTO_SYNC
  ```

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
- Before a Commitizen-style commit, inspect an existing hook before replacing
  it. The command below assumes `.git` is a directory and Git uses its default
  hooks path; linked worktrees and custom `core.hooksPath` require the
  appropriate hooks path instead. Run from the repository root:

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

  This overwrites the existing `commit-msg` hook and removes every line
  containing `Co-Authored-By:`, case-insensitively, including other authors'
  attribution.
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
