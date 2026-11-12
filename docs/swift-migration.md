# Swift Migration of the Core

This document tracks the translation of the core (`Sources/CYLSearchViewController/`) from Objective-C to Swift,
with a score after every commit.

## TODO (2026-11-12): translate the core to Swift, with a Swift coding standard

- Context: the core of CYLSearchViewController is Objective-C (`Sources/CYLSearchViewController/*.h` and `*.m`:
  `CYLSearchBarView`, `CYLSearchController`, `CYLSearchPlaceholderView`, `CYLSearchResources`,
  `CYLSearchResultsViewController`, and the new `CYLSearchView` / `CYLMultiSearchView` from the search API parity
  task in `docs/search-api-comparison.md`). The pod is built with `use_frameworks!`, and the example
  (`CYLSearchExample/`) is Objective-C. Logged on branch `feat/search-api-parity` while the search API parity
  task was in progress.
- Requirements:
  1. iOS only. The focus is the core code of this project; third-party libraries are out of scope.
  2. First create a Swift coding standard document, then update the instruction files (`AGENTS.md`,
     `instructions.md`, folder `instructions.md`) and the skills to refer to it. All in English.
  3. If ready-made Swift skills exist online, copy and install them into this project (`.agents/skills`).
  4. Following the Swift coding standard and the Swift skills, translate all core code to Swift.
  5. Do not change the example layer unless it is necessary.
  6. Record the translation progress in this document.
  7. Scoring: the measure is that no Objective-C code is left in the core. Code that cannot be written in Swift
     counts as translated when it is kept compatible with Swift through macros or keywords (for example
     `NS_SWIFT_NAME`, `NS_REFINED_FOR_SWIFT`). No Objective-C code left = 100/100.
  8. Score after every commit and check whether it is 100; continue until it is.
- Prompt (verbatim): "将下面的任务找一个合适的文档，标注 TODO：全英文写入：注意本操作仅仅设计iOS端，重点修改 本项目的Core核心层面代码。 不涉及第三方库，首先创建swift编码规范文档，更新instructions和skills相关文档。如果网络有现成的swift skills请直接复制安装到本项目中，按照swift编码规范以及swift相关skilla，将Core 核心层面代码全部转录为Swift代码，如果无必要不要修改example层代码。在该文档中记录swift翻译进度。以项目中不存在objc代码为准，如果无法翻译为swift以宏定义 关键字形式 进行兼容swift的也可以算作翻译成功。不存在objc代码为满分，每提交一次就打一次分。每提交一次检查是否满分。一直到满分为止。"
- Prompt (English): "Put the following task in a suitable document and mark it TODO, written fully in English: note
  that this work concerns iOS only and focuses on changing this project's core code. Third-party libraries are not
  involved. First create a Swift coding standard document and update the instruction and skill documents. If
  ready-made Swift skills exist online, copy and install them into this project. Following the Swift coding
  standard and the Swift skills, translate all core code into Swift; do not change the example layer unless
  necessary. Record the Swift translation progress in this document. The measure is that no Objective-C code
  exists in the project; code that cannot be translated to Swift but is made Swift-compatible through macros or
  keywords also counts as translated. No Objective-C code = full marks. Score after every commit, check after
  every commit whether it is full marks, and continue until it is."
- Status: logged, not started. Score: 0/100 (all 5 core types and their new parity types are Objective-C).

## Progress

| Commit | Objective-C files left in `Sources/` | Score |
|:---|:---|:---|
| (not started) | all | 0/100 |
