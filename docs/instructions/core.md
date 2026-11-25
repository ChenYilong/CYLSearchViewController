# Core architecture and fix-in-core (tag: `core`)

Details of the `core` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## Fix issues in the core first (added 2026-11-17)

- Prompt (verbatim): "并找到instructions相关文档，以及skills相关文档，追加编码规范：全英文写入：如果遇到issue bug，你应该主要优先修改 core 层面的代码以规避类似问题，而非example层。core的定义为发布到 相关库管理平台的代码比如 cocoapods maven gradle npm等平台的代码。最差的方式是在example层修复。如果无法从core 层面修复，你要询问我并告知我原因。并在相关文档中解释 ：为什么不能从core层面解决，而是在example层解决。"
- Prompt (English): "Find the instruction documents and the skill documents and append this coding rule, in English: when
  you meet an issue or a bug, fix it first in the core code so that similar problems cannot happen, not in the example
  layer. The core is the code published to a package registry, such as CocoaPods, Maven, Gradle or npm. Fixing it in
  the example layer is the worst way. If it cannot be fixed in the core, ask me and tell me why, and explain in the
  related document why it could not be solved in the core and was solved in the example layer."
- Rules:
  1. The core is every piece of code published to a package registry: the CocoaPods pod (`Sources/`,
     `CYLSearchViewController.podspec`), the Android library (`android/merged/cylsearch`, Maven / Gradle), the React
     Native and mini program packages (npm), the Flutter plugin (pub), the HarmonyOS library (`harmonyos/cylsearch`,
     ohpm), and the libraries of the sub-repositories (CYLTabBarController, CYLTableViewPlaceHolder,
     CollectionViewClassifyMenu). Everything else (`CYLSearchExample`, `harmonyos/entry`, the `example` folders) is
     the example layer.
  2. An issue or a bug is fixed in the core first, in a way that keeps every app of the library from meeting it, not
     only the example. A bug in a sub-repository's library is fixed there (its own branch and pull request, then the
     new commit is pinned here), not worked around in this repository.
  3. The example layer is the last resort. Before fixing an issue only there, ask the user and give the reason the
     core cannot fix it.
  4. Every fix made in the example layer is explained in the related document (the issue's row or its section): why
     the core could not solve it, and why the example layer is the right place. A fix of example-only code (an example
     page's layout, its texts or images) says so: "example-only: the core has no such code".
- Skill: `cyl-fix-in-core`.

## Fix issues in the core first (added 2026-11-17) (instructions.md wording)

- When you meet an issue or a bug, fix it first in the core, so that similar problems cannot happen in any app, not
  in the example layer. The core is the code published to a package registry: CocoaPods, Maven / Gradle, npm, pub,
  ohpm (`Sources/`, `android/merged/cylsearch`, the React Native, Flutter and mini program packages,
  `harmonyos/cylsearch`, and the sub-repositories' libraries). Fixing an issue in the example layer is the worst way.
- If the core cannot fix it, ask the user first and tell them why. Then explain in the related document why the core
  could not solve it and why the example layer did.
- Full rule: `AGENTS.md`, "Fix issues in the core first"; skill `cyl-fix-in-core`.

## The core owns the content below the search bar and its scrolling (added 2026-11-20)

- Prompt (verbatim): "咱们的searchbar组件是由我们自己core核心代码创建的吧？为什么不能监听taglist编辑状态，修改seachbar对应视图的滚动禁用状态？请确认你提到的currentPage 应该在searchbar core核心代码中创建，你不应在example中手动查找。seachbar底部的显示页面也就是你所谓currentPage经由core代码创建后可以自行监听编辑taglist状态并且仅仅在拖拽手势启动状态，来自动关滚动开关"
- Prompt (English): "Our search bar component is created by our own core code, isn't it? Why can it not listen to the tag
  list's editing state and change the scrolling state of the view that belongs to it? Confirm that the currentPage you
  mentioned must be created in the search bar core code and that you must not look it up by hand in the example. The
  page shown below the search bar, which you call currentPage, once the core code has created it, can listen to the
  tag list's editing state by itself and turn its scrolling off automatically, only while a drag gesture is active."
- Rules:
  1. The search bar and the content page shown below it (the page that holds the tag lists, suggestions or results) are
     created and owned by the core: on the mini program `cyl-search-bar` and the content area of `cyl-search`, and the
     same classes on every platform. An example never creates, looks up or holds that scrolling view. No `<scroll-view>`
     of its own around the core's content, no `getCurrentPages()`, `selectComponent` or `currentPage` lookup that finds the content page or its scroller in
     example code (calling a core component's own API, such as `setQuery`, is fine), no example flag such as `reordering` bound to `scroll-y`. (`currentPage()` of miniprogram-automator may be used
     in test scripts only, never in the core or in an example.)
  2. The content page listens by itself to the tag list below it: its editing state and its drag gesture (the tag
     list's `reorderingchange` {reordering}, and `smearingchange` {smearing} for the smear selection). It turns its own
     scrolling off only while a drag gesture is active, from the start of the drag until it ends or is cancelled, and
     keeps scrolling on at every other time, in editing mode too: a swipe scrolls, a long press starts the drag.
  3. The content page is the one view that scrolls (on the mini program a fixed-height column whose `<scroll-view>` is the
     scroller, never a page that grows with its content) and it holds that view's own scroll switch (`scroll-y`; the
     scroll view's `isScrollEnabled` on iOS, the matching switch on Android, HarmonyOS, React Native and Flutter). In
     WeChat `catchtouchmove` only stops propagation and never stops native scrolling; a page-level `overflow: hidden` is
     not honoured by iOS for touch scrolling. `"disableScroll": true` in the page configuration only keeps the page
     itself from scrolling or bouncing. The documented switch for the page's own scrolling is `<page-meta page-style>` (base
     library 2.9.0), which "must be the first node of the page", so a component cannot hold it (checked: inside a component it
     does nothing); `wx.setPageStyle` is not in the documentation and had no effect in DevTools 3.6.6 (no callback either).
     A core component therefore cannot switch the page: its own scroller's switch is the lock, and a host keeps its page from
     scrolling by layout (a fixed-height column with `"disableScroll": true`).
  4. A tag list from another repository (CollectionViewClassifyMenu) sends those states as events the core's content page
     can hear (on the mini program: bubbling and composed, so they cross the slot), fixed in that repository first and then
     pinned here (`cyl-sub-repositories`). The example only places the tag list into the content page.
  5. Test scrolling and dragging with REAL pointer input (mouse drags in WeChat DevTools, not miniprogram-automator's
     synthetic events, which cannot scroll), read the scroll offsets, and run a control with the protection off, so the test
     can tell. Skills: `cyl-fix-in-core`, `cyl-verify`.

## The core owns the content below the search bar and its scrolling (added 2026-11-20) (instructions.md wording)

- The search bar and the content page below it (tag lists, suggestions, results) are created and owned by the core
  (mini program: `cyl-search-bar` and the content area of `cyl-search`). An example never creates, looks up or holds that
  scrolling view: no own `<scroll-view>` around core content, no `getCurrentPages()` / `selectComponent` / `currentPage`
  lookup that finds the content page or its scroller (calling a core component's own API is fine), no example flag such as `reordering` bound to `scroll-y`. (`currentPage()` is for test scripts only.)
- The content page listens by itself to the tag list's editing state and drag gesture (`reorderingchange`,
  `smearingchange`) and turns its own scrolling off only while a drag gesture is active; scrolling stays on otherwise,
  in editing mode too. It is the one scroller (a fixed-height column) and holds its own scroll switch (`scroll-y`);
  `catchtouchmove` and a page-level `overflow: hidden` do not stop native scrolling in WeChat on iOS.
  A component cannot switch the page (`<page-meta>` must be the first node of a page; `wx.setPageStyle` is undocumented and
  did nothing in DevTools 3.6.6): the host keeps its page from scrolling by layout (a fixed-height column, `disableScroll`).
- A tag list from another repository emits those states as bubbling, composed events: fix it there first, then pin it.
- Test scrolling with real pointer input (mouse drags in WeChat DevTools), with a control with the protection off.
- Full rule: `AGENTS.md`, "The core owns the content below the search bar and its scrolling"; skills `cyl-fix-in-core`,
  `cyl-verify`.

## Project rules

- The search core is `CYLSearchBar`: three files and four public classes on iOS
  (`Sources/CYLSearchBar`: `CYLSearchBarView`, `CYLSearchBarItem`, `CYLSearchView`, `CYLSearchResources`), the same
  on every platform (Android `android/merged/cylsearch`, HarmonyOS `harmonyos/cylsearch`, the mini program's
  `cyl-search-bar` and `cyl-search`). Refresh lives only in `CYLSearchView`. CYLSearch depends on no other search
  kernel (CollectionViewClassifyMenu and CYLTableViewPlaceHolder are not search kernels). A new feature goes into the
  class it belongs to (a parameter or a mode), not into a new public class. Design: `docs/search-core-merge.md`.
- New project-owned public types use the `CYL` prefix. Functions, members and constants are lowerCamelCase
  without underscores (SonarCloud S100 / S115 / S116 / S117); `cyl_` survives only in Objective-C selectors of
  extension members on system types (`@objc(cyl_name)`, Swift name `cylName`). Skill `cyl-naming` (re-evaluated
  2026-11-22) has the reasons and the rules for every platform.
- Do not rename existing APIs or vendor symbols in a task that does not require
  it. Keep original copyright and attribution when adapting third-party code.
- The public integration surface of `CYLTableViewPlaceHolder` is its umbrella
  header. The example must not depend on private headers or implementation
  details.
- Keep the sample configurable through protocols or public properties. Avoid
  dependencies on `AppDelegate`, global state, or concrete model types.
- Keep all instructions and skill files in English.

## Swift core: examples adapt to the core (added 2026-11-13)

- When an Objective-C to Swift change of the core breaks an example's build, fix the example: example code has the lowest weight of all code here. Change any example code as needed; never keep a core API, overload, shim or deprecated alias only because an example uses it, and never lower the Swift core's quality (naming, types, optionality, access control) to fit an example. Compatibility matters only for callers outside the examples (published API users). The Swift coding standard (docs/swift-coding-standard.md) decides.

## Core behavior: focus alone changes nothing below the search bar (added 2026-11-13)

- Focusing the search field (cursor shown, keyboard up) without typing changes nothing below the search bar: the area under it (the cached queries and their header, the suggestions, the empty placeholder) looks exactly as it does while the field is not focused. That area is updated only when the person changes the text (typing, deleting, pasting, the clear button, a selected suggestion) or when its data changes (a submitted query, the cache cleared). Rule list: `docs/core-todo.md`, "Core behavior rules".

## Image resources: folder bundles (added 2026-11-19)

- New image files of a core live in a folder bundle, never in an asset catalog (user's prompt, verbatim:
  "请确保新增的图片资源文件在core代码仓库中均以文件夹形式管理，以iOS为例，图片资源文件均存放在.bundle的文件夹形式中"). On iOS: PNG files
  (@1x, @2x, @3x) in a `<Name>.bundle` folder under the core's resources, copied by the podspec and by `Package.swift`
  (`.copy`), and read through the core's resource lookup (as CYLTabBarController's `CYLAnimatedItem.bundle` and
  CollectionViewClassifyMenu's `CYLClassifyMenuImages.bundle`). Other platforms keep images in a resource folder of the
  same kind. This repository's core has no image files today (its icons are SF Symbols).

## Search core

- The search core is `CYLSearchBar`: three files and four public classes on iOS
  (`Sources/CYLSearchBar`: `CYLSearchBarView`, `CYLSearchBarItem`, `CYLSearchView`, `CYLSearchResources`), the same
  on every platform (Android `android/merged/cylsearch`, HarmonyOS `harmonyos/cylsearch`, the mini program's
  `cyl-search-bar` and `cyl-search`). Refresh lives only in `CYLSearchView`. CYLSearch depends on no other search
  kernel (CollectionViewClassifyMenu and CYLTableViewPlaceHolder are not search kernels). A new feature goes into the
  class it belongs to (a parameter or a mode), not into a new public class. Design: `docs/search-core-merge.md`.

## One search field, no system search bar (added 2026-11-26)

- Prompt (English): "No platform may use a system search bar; replace every one with CYLSearchBarView, mainly in the core code. Examples may not use a system search bar either. Expose the same preset (the Discover look) on every platform."
- Rules:
  1. The text field of every search in this project is the core's `CYLSearchBarView` (Android `CYLSearchBarView`, HarmonyOS
     `CYLSearchBarView`, Flutter and React Native `CYLSearchBar` over the native one, the mini program's `cyl-search-bar`). No
     system search bar anywhere, in the core or in an example: iOS `UISearchBar`, `UISearchController`'s bar and
     `UISearchTextField`; Android `SearchView`, `SearchBar`, Material `SearchView`; HarmonyOS `Search()`; Flutter
     `SearchBar`, `SearchAnchor`, `SearchDelegate`, `CupertinoSearchTextField`; React Native `TextInput` used as a search
     box; the mini program's `<input type="search">` or `<search>`.
  2. The one look is the navigation field preset, the Discover look: bordered capsule (corner radius 18), soft shadow
     (opacity 0.06), no magnifier, 16 pt text that scales, an opaque white (light) or black (dark) fill, a divider before the
     trailing items. iOS: `CYLSearchBarView.applyNavigationFieldStyle()` (`Sources/CYLSearchBar/CYLSearchNavigationBar.swift`).
     Every other platform exposes the same preset under the same name in its core, and the Flutter and React Native
     bridges pass it through (a `navigationFieldStyle` parameter), so an example never sets these values itself.
  3. Where a platform's own search UI is part of a ported third-party library (a Ports demo of QMUI, MaterialSearchView and the
     like), the port keeps that library's classes only as a replica of its API, and its demo screen shows the core field.
  4. A screen that needs a plain text input that is not a search (a remark name) uses the same field too (one input look).
  5. Default search button (owner, 2026-11-26): every `CYLSearchBarView` has a built-in, kept search button after the field and the
     owner's items (a divider before it when an item precedes it), a title by default (the localized "Search": en, ja, zh-Hans,
     zh-Hant). The core has a built-in magnifier icon (iOS SF Symbol `magnifyingglass`); the caller chooses `searchButtonStyle`
     (`text` or `icon`), a custom `searchButtonTitle` or `searchButtonImage`, `searchButtonHandler`, or `showsSearchButton = false`.
     An editing bar (`editingBar(...)`) and a bar in multiple mode have none. It is not in `items`. A tap submits the text, and tells
     the delegate `searchBarViewSearchButtonClicked` also for empty text. Every platform exposes the same names.
  6. Keyboard life cycle of the bar itself (owner, 2026-11-26): the bar manages it as the smallest component, so it works in every
     container. The keyboard has the Search key (`returnKeyType = .search`). `focusesOnAppear` (off by default) focuses the field
     every time the bar appears on screen (first entry of a pushed page, push and pop, return from the background), but only while the
     bar is in a navigation bar that currently shows a back button: a root tab page or a plain bar never focuses (owner decision
     2026-11-26, relayed by the Windows session; `CYLSearchBarView.isInNavigationBarWithBackButton`).
     `dismissesKeyboardOnOutsideTouch` (on by default; never for an editing bar) hides the keyboard for a touch anywhere in the
     window outside the bar, which includes the start of every finger scroll in any container. Both come from CYLDeallocBlockExecutor's
     life cycle events (`didEnterScreen`, `appDidBecomeActiveOnScreen` (library PR #30), `didTouchOutside` (library PR #29, on top of #30)); the core's podspec depends on it
     and every platform's pin must name the same commit. Other platforms use their own ports of those events.
- Skill: `cyl-search-field`. Per-platform status: `docs/task-log.md`, entry "no system search bar on any platform".
