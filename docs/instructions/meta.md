# How the instruction files are organized (tag: `meta`)

Details of the `meta` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md).

## Instruction files: categories, tags, 200 lines (added 2026-11-22)

- Prompt (verbatim): "找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入，并且在本次任务中就执行一次下面的指令：将项目的instructions相关文件，可能包含agent Claude文件， 首先将文件进行归类， 以及使用关键词管理，关键词可以称之为称作 tag， 使用标题形式将所有内容归类， 比如测试场景， windows场景， macos专属场景， 文档场景， 等等等等， 将现有的所有文件按照分类，并打上tag， 以标题形式展示。  每个分类标题不能隐藏， 将文件限制在200行以内，如果tag内的内容过多导致超出， 那么就将 超出的部分， 在docs文件夹中新建文件夹， 为instructions文件夹， 按照tag新建文件，将每个分类超出的部分放进去。以相对路径链接形式进行引用， 保证触发关键词，触发tag的时候才去看更详细的描述。"
- Prompt (English): "Find this project's instruction files and skill files (add files when missing, make sure the write
  succeeds), write in English, and carry out the following once in this task: sort the project's instruction files
  (including the agent and Claude files) into categories managed by keywords, called tags; group all content under
  headings, for example the testing scenario, the Windows scenario, the macOS-only scenario, the documentation scenario,
  and so on; tag every existing file by category and show the categories as headings. No category heading may be
  hidden. Keep each file within 200 lines; when a tag's content makes a file longer, create a folder `instructions` in
  `docs`, one file per tag, and move the overflow of each category there. Reference it with relative links, so the
  detailed text is read only when its keyword, its tag, is triggered."
- Rules:
  1. The instruction files are `AGENTS.md`, `instructions.md` and `CLAUDE.md` (which only imports `AGENTS.md`). Each stays
     within 200 lines (`wc -l`).
  2. Their content is grouped under one heading per category, the heading naming the category and its tag:
     `## <Category> (tag: `tag`)`. Every category heading is always present and visible (no folding, no `<details>`),
     even when its summary is one line.
  3. Under each heading: the few rules an agent must always know, then a relative link to the tag's file,
     `docs/instructions/<tag>.md`, which holds the full text (prompts, reasons, procedures). Read the tag file when the
     task touches that tag (its keyword: testing, Windows, macOS, HarmonyOS, commits, screenshots, …).
  4. A new rule goes into its tag's file in full and, when every agent must know it, as one line under the tag's
     heading. A new category gets a new tag, a heading in both instruction files and a new tag file. When a file
     would pass 200 lines, move text from it into the tag files; never drop a rule.
  5. The first category is always `behavioral` (`docs/instructions/behavioral.md`: the behavioral guidelines, read in full first; added 2026-11-22).
  6. `AGENTS.md` and `instructions.md` keep the same tags and headings. Skills (`.agents/skills`) stay as they are and
     are listed in the `skills` category; a skill that repeats a rule links the tag file.
- First reorganization: 2026-11-22 (`docs/task-log.md`, "sort the instruction files by tag"). Skill: `cyl-docs`.
