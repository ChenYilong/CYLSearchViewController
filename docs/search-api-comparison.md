# Search API Comparison

This document compares the public API of CYLSearchViewController with five
open-source search components (Android), one table per project, and tracks
the work to reach full parity (100/100 for each project).

## TODO (2026-11-12): match and exceed five search libraries, then port their examples

- Context: CYLSearchViewController (Objective-C, UIKit) ships
  `CYLSearchResultsViewController`, `CYLSearchController` (overlay),
  `CYLSearchBarView`, `CYLSearchPlaceholderView` and `CYLSearchResources`
  (`Sources/CYLSearchViewController/`). `master` is at `55022ba` (PR #5
  merged: CYLSearchBarView, the CYLTabBarController example, search bar
  placement rule). Work happens on `feat/search-api-parity`, created from
  `master`. The five reference projects are Android libraries:
  - https://github.com/lapism/search
  - https://github.com/MiguelCatalan/MaterialSearchView
  - https://github.com/yechaoa/MaterialDesign
  - https://github.com/android-cjj/MaterialSearchView
  - https://github.com/iammert/MultiSearchView
- Requirements:
  1. The task is mainly about the core code (`Sources/`).
  2. Read each project's code and README; add every feature we lack.
  3. Align the API: study each project's initialization style and add
     matching API next to our existing API (keep what we have).
  4. Our features must be a superset of each project's: never fewer.
  5. In `docs/`, one table per project: first column the project's public
     API, second column our API; list the match where one exists, then list
     what we are missing.
  6. A project scores 100 when every one of its APIs has a counterpart; keep
     adding API until every project is at 100.
  7. After 100: port each project's example completely to Swift and add it
     to our example.
  8. Core first: the example only passes data and style parameters in and
     implements tap handling.
- Prompt (verbatim): "注意本任务主要针对core代码修改 ：阅读该项目代码 以及readme  https://github.com/lapism/search https://github.com/MiguelCatalan/MaterialSearchView https://github.com/yechaoa/MaterialDesign https://github.com/android-cjj/MaterialSearchView https://github.com/iammert/MultiSearchView 加入我们缺失的功能。第二步对齐api ，分别学习该项目的初始化方式，新增我们原有api。保证我们得功能要比这个项目更多，绝对不能少。docs中写个表格，对上面每一个链接分别写表格，第一列为的公开api，第二列为我们的api。如果能找到对应的，就列出，最后查看我们少了什么API。如果链接中的项目 API 完全存在对应版本，那么就满分，持续更新我们的API，一直到100分 。满分后的，将每一个链接里的项目里面的example完全复刻为swift版本 加入我们的example 。优先更新core层面代码，example仅仅负责数据传入以及样式参数输入，点击事件实现。"
- Prompt (English): "Note that this task is mainly about changing the core
  code: read these projects' code and READMEs (the five links above) and add
  the features we are missing. Second step, align the API: study each
  project's initialization style and add it alongside our existing API.
  Make sure we have more features than each project, never fewer. In docs,
  write a table for each link: first column its public API, second column
  ours. List the counterpart where one exists, then see which APIs we lack.
  If every API of a linked project has a counterpart, it scores full marks;
  keep updating our API until 100. After full marks, port each project's
  example completely to Swift and add it to our example. Update the core
  first; the example only passes data and style parameters and implements
  tap handling."
- Order: this task runs before the Swift migration (`docs/swift-migration.md`), which was asked later; the
  user's rule is to work through tasks in the order they were given.
- Status: the five projects are read. Done in the core: `CYLSearchBarView` (navigation icon and button, voice,
  submit and custom clear buttons, keyboard options, maximum length, clear on cancel / end editing,
  `setText:submit:`, `submit`, show and hide keyboard, iconified state with fade or circular reveal, state
  restoration) and the new `CYLSearchView` (open/close page with suggestions, content view, divider, scrim,
  bar button item). Build clean. Next: `CYLMultiSearchView`, tests, the comparison tables, then the Swift
  example ports.
