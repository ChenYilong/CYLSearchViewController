# QMUISearchBar and QMUISearchController in CYLSearchBar (Swift)

Design and task record for bringing QMUI_iOS's `QMUISearchBar` and `QMUISearchController` (and the
`UISearchBar+QMUI` / `UISearchController+QMUI` categories they rely on) into this repository's Swift core
(`Sources/CYLSearchBar`), with CYL names, and their example into `CYLSearchExample`.

## TODO (2026-11-21, `feat/harmonyos-parity`, PR #11): port QMUISearchBar / QMUISearchController to Swift

- **Context**: source: `Vibe-Coding-Projects/QMUI_iOS-fixed` (fork of Tencent/QMUI_iOS, imported in `792c9dda`),
  files `QMUIKit/QMUIComponents/QMUISearchBar.{h,m}`, `QMUISearchController.{h,m}` and their dependencies
  `QMUIKit/UIKitExtensions/UISearchBar+QMUI.{h,m}`, `UISearchController+QMUI.{h,m}`. Our current search code:
  `Sources/CYLSearchBar/CYLSearchBarView.swift` (a custom `UIView` bar), `CYLSearchView.swift` (a custom overlay
  with suggestions and results), `CYLSearchResources.swift` (history), plus the legacy Objective-C app files
  `CYLSearchViewController/Class/CYLSearchBar` (a `UISearchBar` subclass) and
  `Class/Controller/CYLSearchController` (a hand-made search page). The owner chose to commit on PR #11's branch
  (asked 2026-11-21: three open PRs otherwise). Design by this session (with the advisor); code by Sonnet agents,
  one per phase, reviewed and tested here between phases. Clone: `/tmp/xpr/csvc-qmui`.
- **Requirements**:
  1. Design document in `docs/` (this file), then the code written by the default Sonnet model.
  2. Rename to this project's naming rules first (`CYL` prefix, `cyl_` for category members), then Swift.
  3. Merge into the project: into a fitting existing class, else as a new class; and merge our fitting code into the
     new class, so that QMUI's design and interfaces are available here.
  4. Replicate QMUI's search bar example in `CYLSearchExample`.
  5. Read QMUI's comments closely: keep its design reasoning and every edge case it handles (the QMUI classes are
     proven in production; our current code is a draft and less robust).
- **Prompt (verbatim)**: "advisor 请参考 下面几个searchbar实现， 进行设计， 设计文档放docs中， 并交给默认sonnet模型进行代码实现。 该实现与我们 的searchbar高度相似， 先改为 合适的类命名规范， 再转为Swift， 再merge到我们的项目中， 找到合适的类合并。 如果没有合适的类就单独放项目中，并将我们项目中合适的代码也按照这个新加入的类进行合并， 保证可以将下面的类的设计， 以及接口引入我们的项目。 并将下面项目中对应的searchbar 的exmaple 也复刻进我的的Example中， 并详细阅读下面代码中注释， 注意他说明的设计思路， 以及边界场景处理，下面几个类是经过实际项目的验证的， 我们现有代码仅仅是草稿， 总体没有下面的代码更健壮。 /Volumes/obsidian/chenyilong/chenyilong/Vibe-Coding-Projects/QMUI_iOS-fixed/QMUIKit/QMUIComponents/QMUISearchBar.h /Volumes/obsidian/chenyilong/chenyilong/Vibe-Coding-Projects/QMUI_iOS-fixed/QMUIKit/QMUIComponents/QMUISearchBar.m /Volumes/obsidian/chenyilong/chenyilong/Vibe-Coding-Projects/QMUI_iOS-fixed/QMUIKit/QMUIComponents/QMUISearchController.h /Volumes/obsidian/chenyilong/chenyilong/Vibe-Coding-Projects/QMUI_iOS-fixed/QMUIKit/QMUIComponents/QMUISearchController.m"
- **Prompt (English)**: "Advisor, use the search bar implementations below as the reference for a design; put the design
  document in docs and hand the implementation to the default Sonnet model. It is very similar to our search bar: first
  rename to suitable class naming rules, then convert to Swift, then merge into our project, finding the fitting classes
  to merge with. If no class fits, add it to the project on its own, and merge the fitting code of our project into the
  new class, so that the design and interfaces of the classes below come into our project. Also replicate the
  corresponding search bar example of that project into our Example. Read the comments in the code below in detail:
  note the design reasoning they explain and the handling of edge cases; these classes are proven in real projects,
  our existing code is only a draft and overall less robust than theirs." (followed by the four file paths above)
- **Status**: started; design in progress.
