---
name: cyl-commit
description: "Commit conventions of this repository: git cz (Commitizen) style, English-only commit messages."
---

# Commits

- Commit in `git cz` (Commitizen) style: `{type}{scope}: {emoji}{subject}` (see AGENTS.md, "Commit readiness", and
  instructions.md, "Commitizen commits", for the hook to run first and the emoji per type).
- The whole commit message is English: subject, body and trailers. No Chinese (or any other non-English text) anywhere
  in a commit message. A user prompt quoted in Chinese goes in the docs (task log), not in the commit.
- Every commit body ends with the author line `By  @ChenYilong <luohanchenyilong@163.com>` and the session trailer.
