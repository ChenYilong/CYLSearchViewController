# Behavioral guidelines (tag: `behavior`)

Details of the `behavior` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md).

## Behavioral guidelines to reduce common LLM coding mistakes: read in full first (added 2026-11-22)

- Prompt (verbatim): "找到本项目instructions 相关文件（可能包含根目录的agent Claude文件instructions 文件， 首先确认下面内容的归类。如果agent Claude文件文件超出每个文件200行限制，则优先放入docs 里的instructions文件夹合适文件，）以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入，并且在本次任务中就执行一次下面的指令： 找到本项目docs文件夹或者子文件夹里的如下文件， Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes 使用相对路径的方式放入根目录instructions 相关文件 ，相关文件顶部，并标注必须全文阅读该文件。新建分类，新建tag标题。"
- Prompt (English): "Find this project's instruction files (the root agent / Claude / instructions files; first decide
  where the content below belongs; when an agent or Claude file would pass the 200-line limit, put the text into a fitting
  file in `docs/instructions`) and skill files (add files when missing, make sure the write succeeds), write in English, and
  carry this out once in this task: find the file Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes in `docs` or a
  subfolder, reference it by relative path at the top of the root instruction files, and mark that it must be read in full.
  Create a new category with a new tag heading."
- The file: [Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes.md](Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes.md)
  (the user's, added 2026-11-22; keep it unchanged).
- Rules:
  1. It is the first category of `AGENTS.md` and `instructions.md` (heading "Behavioral guidelines: read in full first",
     tag `behavior`), above every other category, with a relative link and the note that it must be read in full.
  2. Read it in full, every line, at the start of every task and after the rules change mid-session (`workflow`); a
     summary or an excerpt does not count.
  3. `CLAUDE.md` imports it (`@docs/instructions/Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes.md`) before
     `@AGENTS.md`, so Claude Code loads the whole file.
  4. Its rules sit beside the project rules; where they disagree, the user's explicit instructions and this project's tag
     rules decide, and the disagreement is named in the reply.
- Skills: `cyl-task-start` (step 0), `cyl-docs`.
