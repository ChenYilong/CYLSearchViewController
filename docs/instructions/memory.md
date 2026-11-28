# Memory: learn-codebase and claude-mem (tag: `memory`)

Details of the `memory` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md).

## Read the learn-codebase guide before learn-codebase (added 2026-11-29)

- Prompt (English): "In docs/learn-codebase create a README document. It records how, later on another computer, to specify
  the output path when using claude-mem's learn-codebase command again, and how to remove private information from the
  output before committing it to git, summarized from this experience. Create a new tag named memory in the agents file:
  this new document must be read before running learn-codebase; give its relative path. Write the documents in English."
  The original wording is in [docs/task-log.md](../task-log.md), "learn-codebase guide and the `memory` tag".
- Rules:
  1. Before running claude-mem's learn-codebase (`/claude-mem:learn-codebase`, or any request to learn, prime or re-read
     the whole codebase), and before exporting or committing its output, read the guide in full:
     [../learn-codebase/README.md](../learn-codebase/README.md). A summary or a memory of an earlier reading does not count.
  2. Name the output path in the prompt: `docs/learn-codebase/learn-codebase-<YYYY-MM-DD>/`. The skill has no path setting.
  3. Draft outside `docs/learn-codebase`; before files move in, remove private information, leave raw claude-mem
     observation dumps out and mark unverified claims in every Markdown file. Keep each file within 65,536 bytes.
  4. Commit as the guide's section 5 and [git.md](git.md) require.
  5. When something in the guide turns out wrong or out of date (for example after a claude-mem upgrade), correct the guide.
