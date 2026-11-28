# Behavioral guidelines (tag: `behavioral`)

The `behavioral` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). **Read this file in full,
every line, before any task.** The guidelines below are the user's text, unchanged (formerly
`docs/instructions/Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes.md`, whose first line was "# CLAUDE.md");
the rules of the tag follow them.

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## The behavioral tag: rules (added 2026-11-22)


- Prompt (verbatim): "找到本项目instructions 相关文件（可能包含根目录的agent Claude文件instructions 文件， 首先确认下面内容的归类。如果agent Claude文件文件超出每个文件200行限制，则优先放入docs 里的instructions文件夹合适文件，）以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入，并且在本次任务中就执行一次下面的指令： 找到本项目docs文件夹或者子文件夹里的如下文件， Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes 使用相对路径的方式放入根目录instructions 相关文件 ，相关文件顶部，并标注必须全文阅读该文件。新建分类，新建tag标题。"
- Prompt (English): "Find this project's instruction files (the root agent / Claude / instructions files; first decide
  where the content below belongs; when an agent or Claude file would pass the 200-line limit, put the text into a fitting
  file in `docs/instructions`) and skill files (add files when missing, make sure the write succeeds), write in English, and
  carry this out once in this task: find the file Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes in `docs` or a
  subfolder, reference it by relative path at the top of the root instruction files, and mark that it must be read in full.
  Create a new category with a new tag heading."
- The guidelines above are the user's text (added 2026-11-22); keep them unchanged.
- Rules:
  1. It is the first category of `AGENTS.md` and `instructions.md` (heading "Behavioral guidelines: read in full first",
     tag `behavioral`), above every other category, with a relative link and the note that it must be read in full.
  2. Read it in full, every line, at the start of every task and after the rules change mid-session (`workflow`); a
     summary or an excerpt does not count.
  3. `CLAUDE.md` imports it (`@docs/instructions/behavioral.md`) before
     `@AGENTS.md`, so Claude Code loads the whole file.
  4. Its rules sit beside the project rules; where they disagree, the user's explicit instructions and this project's tag
     rules decide, and the disagreement is named in the reply.
- Skills: `cyl-task-start` (step 0), `cyl-docs`.
- Second prompt (verbatim): "按照我们之前约定的tag分类方式处理  Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes  文件， 这个文件可以叫 Behavioral，大小写以及文件命名， 参考  docs/instructions文件夹下面其他文件命名，并调整引用了该文件的相对路径。"
- Second prompt (English): "Handle the Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes file the way we agreed for
  tags. The file can be called Behavioral; follow the case and naming of the other files in `docs/instructions`, and adjust
  the relative paths that reference it." Done 2026-11-22: the guidelines and this tag's rules are one tag file,
  `docs/instructions/behavioral.md` (lowercase, like the other tag files); the tag is `behavioral`; `behavior.md` and the
  long file name are gone, every reference points here.
