# Agent Instructions

This repository is an Objective-C iOS search sample. It uses
`CYLTableViewPlaceHolder` to demonstrate the interaction between a
navigation-item search controller and pull-to-refresh. Read `instructions.md`
and the applicable skill in `.agents/skills/` before making changes.

## Skills

WeChat DevTools Skills (<https://developers.weixin.qq.com/miniprogram/dev/devtools/Skills.html>): DONE
(2026-11-15). `wechatide-skill` ships with WeChat DevTools and is linked into the user skill folder
(`~/.claude/skills/wechatide-skill`); use it for every mini program build, run, automation and screenshot
(`CrossPlatform/wechat-miniprogram-cylsearch`). Notes for Windows: see `docs/miniprogram-api-alignment.md`.


`.agents/skills` holds the skills; `.claude/skills` only points there.

| Skill | Use it when |
|:---|:---|
| `cyl-tabbar-integration` | Adding or changing a `CYLTabBarController` in the example (configuration file, plus child view controller, latest commit) |
| `cyl-plus-button` | Writing or changing the plus button: configuration keys, title alignment, Liquid Glass limits |
| `cyl-new-project` | Creating or extending an example project |
| `cyl-api-map` | Finding the public API of `CYLTableViewPlaceHolder` and `CYLTabBarController` |
| `cyl-xcode-compat` | Touching the `.xcodeproj`, Podfile or deployment targets |
| `cyl-sub-repositories` | Adding or updating a sibling project as a sub-repository (CollectionViewClassifyMenu, CYLTableViewPlaceHolder): commit pin, core option, example, every platform |
| `cyl-license` | Any package published to a registry (CocoaPods, Maven/Gradle, npm, pub, ohpm): the MIT `LICENSE` inside its resource bundle, the manifest field, the check |
| `cyl-task-start` | Starting, scoring and finishing any task: check other sessions, `TODO` and branch at the top, the `docs/` entry with acceptance criteria, scoring until it passes, missing points as `TODO`s at the end; restarting a hung emulator |
| `cyl-docs` | Editing `README.md` or `docs/` |
| `cyl-verify` | Building, testing, running the simulator; real pointer input for scrolling and drag gestures |
| `cyl-api-parity` | Comparing two platforms' APIs: the parity table (source API, description, target counterpart, `TODO` by default), its score, and the loop to 100 |
| `cyl-fix-in-core` | Fixing any issue or bug: in the core (code published to a package registry) first; example-layer fixes only after asking, with the reason documented; the content below the search bar and its scrolling belong to the core |
| `cyl-commit` | Writing any commit message: `git cz` style, English only, the author line, the checks before committing |
| `cyl-accessibility-i18n` | Screen readers and localization in any code; writing UI tests that find controls by their labels |
| `cyl-harmonyos-setup` | Preparing DevEco Studio and the HarmonyOS emulator: SDK paths, virtualization, Huawei ID, region `CN` in `country.region.xml` |
| `swift-api-design-guidelines`, `swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture` | Writing or translating Swift (third-party, pinned in `.agents/skills.json`) |
| `uikit`, `uikit-layouting` | UIKit views, controllers and layout in Swift (third-party) |

Every new integration rule updates, in the same change, `AGENTS.md`,
`instructions.md` and the affected skills.

## API parity tables (added 2026-11-17)

- A parity table compares two platforms (or two libraries). Column 1: an API or feature of the source; column 2: what
  it does; column 3: the counterpart on the target, `TODO` by default.
- Score: (rows whose column 3 is not `TODO`) / rows × 100. No `TODO` in column 3 is 100; all `TODO` is 0.
- Loop until 100: (1) search the existing code to match each `TODO` row with its counterpart; (2) score; (3) resolve
  the remaining `TODO` rows one by one, each becoming the name of its implementation; (4) score again; repeat.
- Implement in the core first (rule "Fix issues in the core first"), then use the example to show the usage, copying
  the source platform's example. Keep the logic and the API names the same on both platforms.
- When one direction reaches 100, make the reverse table the same way.
- Tables: [docs/ios-api-alignment.md](docs/ios-api-alignment.md) (Android core → iOS),
  [docs/android-api-alignment.md](docs/android-api-alignment.md) (iOS → Android). Skill: `cyl-api-parity`.

## Licenses in published packages (added 2026-11-17)

- Prompt (verbatim): "找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：所有需要发布到外部仓库的代码，包括但不限于 cocoapods graddle npm maven等等 必须包含协议声明，如果已经有内置包文件夹就放进去，如果没有就新建，确保写入成功。以iOS为例，内置包bundle文件应包含协议文件。此操作适用于所有平台。"
- Prompt (English): "Write, in English, into the instruction and skill files (creating them when missing): all code
  published to an external registry, including but not limited to CocoaPods, Gradle, npm and Maven, must contain a
  license declaration; if a built-in package (bundle) folder exists, put it there, otherwise create one. On iOS, the
  built-in bundle contains the license file. This applies to every platform."
- Rules:
  1. Every package published to an external registry (CocoaPods, Maven / Gradle, npm, pub.dev, ohpm and any other)
     ships its license file, not only a manifest field.
  2. The license file goes into the package's built-in resource bundle folder; when the package has none, create
     one. iOS: `Resources/CYLSearchViewController.bundle/LICENSE`; Android: `META-INF/<module>/LICENSE` in the
     library's Java resources (inside the AAR); the mini program: its component folder (`src/`); a JavaScript or Dart
     package: its root, the folder its registry ships. The same layout as CYLTabBarController (`docs/License-Notices.md`).
  3. Every platform, every new package.
  4. The license is MIT, `Copyright (c) 2015 ChenYilong` (owner's choice, 2026-11-17). The root `LICENSE` is the source;
     every copy is identical to it, and each manifest declares MIT.
  5. Third-party files shipped in a package keep their own license and notice files in the same bundle.
- Check: `bash scripts/check-licenses.sh` (CI). Skill: `cyl-license`. Record and file list: `docs/licenses.md`.

## Bugs of the animated components: record, screenshot, fix in CYLTabBarController (added 2026-11-17)

- Prompt (verbatim): "遇到bug，第一步记录， 第二截图， 所有修复，都应在CYLTabBarController仓库内修复动效相关组件完成，避免修改example 完成修复， 如果必须改动example也应，让CYLTabBarController 修改接口供demo使用。"
- Prompt (English): "When you meet a bug: first record it, second take a screenshot. Every fix of the animated components
  is made in the CYLTabBarController repository; do not fix it by changing the example. If the example must change,
  CYLTabBarController changes its API for the demo to use."
- Rules:
  1. Record every bug first (the related document's issue table or TODO entry: what, where, platform, device), then
     take a screenshot of it (`docs/assets`, labelled with platform, device and OS, commit, date) before fixing.
  2. Bugs of the animated components (`CYLAnimatedItem`, `CYLAnimatedItemView`, its engines and players, the tab
     bar animations) are fixed in CYLTabBarController, which owns them (its own branch and pull request, or its
     session), then pinned here. Never work around them in the example.
  3. If the example has to change, CYLTabBarController first adds or changes the API the example needs, and the example
     only calls it.

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

## Project rules

- The search core is `CYLSearchBar`: three files and four public classes on iOS
  (`Sources/CYLSearchBar`: `CYLSearchBarView`, `CYLSearchBarItem`, `CYLSearchView`, `CYLSearchResources`), the same
  on every platform (Android `android/merged/cylsearch`, HarmonyOS `harmonyos/cylsearch`, the mini program's
  `cyl-search-bar` and `cyl-search`). Refresh lives only in `CYLSearchView`. CYLSearch depends on no other search
  kernel (CollectionViewClassifyMenu and CYLTableViewPlaceHolder are not search kernels). A new feature goes into the
  class it belongs to (a parameter or a mode), not into a new public class. Design: `docs/search-core-merge.md`.
- New project-owned types and identifiers use the `CYL` prefix. New UIKit
  category files use `+CYL`; category methods and properties use `cyl_`.
- Do not rename existing APIs or vendor symbols in a task that does not require
  it. Keep original copyright and attribution when adapting third-party code.
- The public integration surface of `CYLTableViewPlaceHolder` is its umbrella
  header. The example must not depend on private headers or implementation
  details.
- Keep the sample configurable through protocols or public properties. Avoid
  dependencies on `AppDelegate`, global state, or concrete model types.
- Keep all instructions and skill files in English.

## Swift

The core is Swift (`Sources/CYLSearchBar`; the translation record and its score: `docs/swift-migration.md`). All Swift code
follows `docs/swift-coding-standard.md` and the Swift skills in `.agents/skills` (`swift-api-design-guidelines`,
`swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture`, `uikit`, `uikit-layouting`; third-party,
pinned in `.agents/skills.json`, never edited by hand). Public Swift API keeps the Objective-C class names and
selectors (`@objc(...)`), so Objective-C callers keep working; documentation comments are three-line `/** */`
blocks.

## Comments on public API

Callers read a public API's comment through the IDE's documentation (Xcode
Quick Help, the generated Swift interface, Android Studio, editor hovers).
Only a documentation comment gets there whole. The multi-line rule is adapted
from CYLTabBarController's `AGENTS.md`, "Comments on public API" (commit
`63c0edc`). The rules below are this project's own and win over upstream.

- **The official rules decide.** Every comment format follows the official
  documentation rules of its language. The rules below choose among the forms
  an official rule allows. Where a rule below contradicts an official rule,
  the official rule wins.
- **Multi-line comments on public API are one documentation block**, never
  stacked single-line comments, right above the declaration with nothing in
  between.
- **Single-line comments use the block format too.** The format requirements
  for multi-line public API comments also apply to single-line public API
  comments. In a language whose block form is officially allowed, a one-line
  comment is still three lines above the declaration:

  ```objc
  /*!
   * Text.
   */
  - (void)example;
  ```

  - Never put the block on one line (`/*! Text. */`).
  - Never add a trailing comment after a declaration or an enum value:
    no `/**< */`, `/*!< */`, `///<` or `//`.
- **One comment format per public file.** In a file that contains public API,
  every documentation comment uses the same format, long or short.
- **All platforms and all languages.** Use the official documentation form of
  each language:

  | Language | Format | Official source |
  |:---|:---|:---|
  | Objective-C, C, C++ headers | `/*!` … ` * ` … ` */` | Xcode Quick Help / HeaderDoc (Apple) |
  | Swift | `/**` … ` * ` … ` */` (Swift does not read `/*!`) | Swift Markup, DocC (allows `///` and `/** */`) |
  | Kotlin | `/**` … ` * ` … ` */` | KDoc (kotlinlang.org) |
  | Java | `/**` … ` * ` … ` */` | Javadoc (Oracle) |
  | TypeScript | `/**` … ` * ` … ` */` | TSDoc |
  | JavaScript | `/**` … ` * ` … ` */` | JSDoc |
  | Python | Triple double-quoted docstring as PEP 257 says: a one-line docstring keeps its quotes on the same line; a multi-line docstring is a summary line, a blank line, then the closing `"""` on its own line | PEP 257 |
  | Go | `//` line comments right above the declaration, no blank line | Effective Go, go.dev/doc/comment |
  | C# | `///` lines with XML tags (`<summary>`, `<param>`, `<returns>`) | Microsoft Learn, XML documentation comments |
  | Rust | `///` (outer) and `//!` (inner) doc comments | Rust Style Guide, rustdoc book |
  | Dart | `///` lines | Effective Dart, "DO use `///` doc comments" |

  A language with no block documentation form, or whose official guide
  requires line doc comments (Go, C#, Rust, Dart above), uses that one form
  throughout the file. A short comment is then a single doc-comment line, and
  a long one is consecutive lines of the same form.

## Xcode project

- Preserve Xcode project format 46, compatibility version Xcode 3.2, explicit
  file lists, and a shared scheme.
- The Podfile top declares `platform :ios, '15.0'`,
  `ENV['SWIFT_VERSION'] = '5'`, and this directory's `.xcodeproj`.
- The Podfile ends with one `post_install` hook that sets every Pods target's
  `IPHONEOS_DEPLOYMENT_TARGET` to `"15.0"`. Append it at the bottom if missing;
  never add duplicate hooks.
- Keep Xcode app and test deployment targets at iOS 15.0 and use the local
  sibling `CYLTableViewPlaceHolder` pod for this reproduction.
- Verify that the AppIcon asset set contains actual icon files and that the
  launch storyboard/image is configured in the app target. If either is
  missing, reuse the icon and custom launch image from
  `CYLTabBarController/Example/Images.xcassets`.
- Never commit `Pods/`, generated workspace state, or AppleDouble `._*` files.

## Search bar placement

- A search bar never covers any view, at any time: not a view controller's
  view (`self.view`), not a sibling, a background view or a bar item; for a
  navigation-item search controller, `CYLSearchBarView` and the overlay; in
  every state and at every Dynamic Type size. Views of search screens do not
  extend under the top bar (`edgesForExtendedLayout` without
  `UIRectEdgeTop`); a `CYLSearchBarView` is laid out against the safe area,
  beside the content, never on top of it, and a colored area behind it ends
  where the bar begins. `testSearchBarsCoverNoView` checks every search bar
  with `CYLViewsCoveredByView`; add each new one there.

## Issue #1317

The reproduction uses `UISearchController` in `navigationItem.searchController`
and pull-to-refresh on its table through the core's refresh API:
`CYLSearchView.setRefreshHandler(_:for:)` adds it and `CYLSearchView.endRefreshing(in:)` stops it
(CYLTableViewPlaceHolder's normal header inside; the example never calls CYLTableViewPlaceHolder's refresh API
directly). Pinning the search bar with
`hidesSearchBarWhenScrolling = NO` is the known workaround for repeated inset
updates on affected iOS versions. Refresh handlers must not retain their
controller strongly and must always end the refresh (`endRefreshing(in:)` on every completion path).

## CYLTabBarController

This project integrates CYLTabBarController by default. Rules adapted from
CYLTabBarController's `AGENTS.md` and `cyl-*` skills at its latest commit
(`caf3c92`, branch `feat/cross-platform-components`, 2026-11-11); see
`docs/CYLTabBarController-Integration.md` for the source and the status.

- **Default integration in the example layer.** Unless a task says otherwise,
  every `CYLTabBarController` in the example (`CYLSearchExample/`) is created
  from a **local configuration file** in the app bundle, and has a **plus
  button with a plus child view controller**. Never write tabs, the plus
  button or a `CYLPlusButton` subclass only in code for the default demo.
  - The file (for example `CYLSearchExample/CYLTabBarConfiguration.json`) holds
    `CYLTabBarControllerTabBarItemsAttributes` (an even number of tabs, each
    with `CYLTabBarItemIdentifier` / `CYLTabBarItemPageIdentifier`) and
    `CYLTabBarControllerPlusButton` with `CYLTabBarItemTitle`,
    `CYLTabBarItemImage` and `CYLTabBarItemPageIdentifier`. The page found for
    the plus button's page ID becomes the plus child view controller.
  - Register a page provider for every page ID in
    `CYLTabBarPageRegistry.sharedRegistry` (or a registry passed as
    `CYLTabBarControllerPageRegistry`), then create the controller with
    `+[CYLTabBarController tabBarControllerWithConfigurationFile:error:]`.
    Handle the error: never leave the window without a root view controller.
  - Plus button taps that need code use `CYLTabBarControllerPlusButtonAction`
    (code only); read the configuration with
    `+configurationWithContentsOfFile:error:` and add the action before
    `-initWithConfiguration:`.
  - Full recipe: the `cyl-tabbar-integration` skill. Plus button limits: the
    `cyl-plus-button` skill.
- **Depend on the latest commit, through CocoaPods.** Before every build, run
  `scripts/latest-cyl-commit.sh --podfile`; it prints the newest commit on any
  branch by commit timestamp. Put that line into the Podfile:
  `pod 'CYLTabBarController', :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '<sha>'`.
  Never a version number, branch or tag. Run `pod install`, then build. Name
  the commit (sha, date, branch) in the report; if it cannot be fetched, say
  so and keep the sha already in the Podfile.
  Exception: A pull request branch that is already merged into the newest branch does not count, even when it gets a newer commit afterwards: pin the newest branch's tip, and move once that newer commit is merged there (owner's decision, 2026-11-17: `9a54e26`, the merge of PR #814 into PR #788, not `47aec88`). CYLSearchViewController and CollectionViewClassifyMenu pin the same commit.
- **Imports.** The example imports only
  `#import <CYLTabBarController/CYLTabBarController.h>`, like the other pods'
  umbrella headers.
- **Search inside tabs.** A tab page that shows search embeds its view
  controller in a `UINavigationController`, so
  `navigationItem.searchController` and the Issue #1317 workaround keep
  working. Do not put the search bar on the tab bar controller itself.
- **Reading CYLTabBarController docs.** Its `docs/` and comments are
  bilingual: read the `[EN]` part and skip the `[CN]` part; in a
  `中文 | English` table read the right column. Code wins over `docs/`, and
  `docs/` over `README.md`.
- **Accessibility.** Tabs, the plus button, badges and every control in the
  example have meaningful accessibility labels; tests find elements by label
  or identifier before coordinates.
- **Clean builds.** Build into an empty derived data folder after a
  dependency change, so the app does not run stale pod code.

- **Raised plus button.** Example layer, raised plus button: when an example demonstrates a plus button, always prefer the raised effect, where the top of the plus button rises above the top edge of the tab bar (for example `CYLPlusButtonCenterYMultiplier` below 0.5 with a button taller than half the bar, or `CYLPlusButtonCenterYOffset`); keep it fully tappable (`touchableRect`) and never let it cover the page content above the bar.

## Sub-repositories (CollectionViewClassifyMenu, CYLTableViewPlaceHolder)

Sibling projects in the same local folder (`../<Name>`) that this library uses are sub-repositories. The rules were
set for CollectionViewClassifyMenu (the tag-view suggestion style, `docs/tag-view-suggestions.md`) and apply to every
sub-repository:

- **Dependency.** iOS: through the sub-repository's root podspec, as a sub-dependency of this pod (podspec
  `s.dependency`, Podfile `:git` + `:commit`). Android and the other platforms: through their package manager by
  commit; when that is not possible, the build checks out that commit and builds the module from source
  (`android/merged/settings.gradle.kts`, `pinnedCheckout`).
- **Newest commit.** Pin the newest commit on any branch (`git fetch` then `git log --remotes -1`); it may not be on
  `main` or `master`. A local path is allowed only while developing: remove it before committing and commit the
  commit-based dependency.
- **Core first.** Add the feature to this library's core with an enum or a parameter that chooses it. When the
  sub-repository lacks an interface, add it there, commit and push it there, then update this repository's pinned
  commit and continue.
- **Example.** The example shows every style the option offers; it passes only data, style parameters and click
  handling.

CollectionViewClassifyMenu shows the suggestions under the search bar as tags instead of a list
(`CYLSearchSuggestionStyle`; Android done, iOS `TODO` in `docs/tag-view-suggestions.md`).

CYLTableViewPlaceHolder is integrated as a sub-repository under all the requirements above. Requirement: when a search
has no results (the content is empty), show CYLTableViewPlaceHolder's empty-content placeholder style. This applies to
every platform: iOS, Android, React Native, Flutter, HarmonyOS and mini programs. CYLTableViewPlaceHolder is the
placeholder sub-dependency: `CYLSearchView` shows its `CYLPlaceholderView` / `CYLPlaceholderStackView` for empty
results and empty suggestions, and wraps its pull-to-refresh header in the refresh API; every platform pins the
same commit, `62e40c0` (its newest commit, on `CYLAnimatedItem`). Status: done on iOS, Android, HarmonyOS, the mini program, React Native and Flutter. Tracked in `docs/sub-repositories.md` and `docs/search-core-merge.md`. Use
the `cyl-sub-repositories` skill.

## Verification

Run `pod install`, validate the project with Xcodeproj/CocoaPods, build and
analyze the shared scheme, and run tests when available. Do not claim a visual
reproduction or fix without launching the sample on a simulator.

- **CI/CD**: `.github/workflows/ios.yml`, modeled on CYLTabBarController's
  `ios.yml`. It runs shellcheck, the public API comment check,
  `pod lib lint`, the example build and analyzer (warnings in `Sources/` fail
  it) and the unit tests. The default macOS runner is `macos-26`; the
  `MACOS_RUNNER` variable changes it. Run the same scripts locally before
  pushing; see `docs/CI-CD.md`.
- A script added under `scripts/` must pass `shellcheck`. A workflow change
  must pass `actionlint`.

### Screenshots of builds and CI/CD

- **Where they go.** Every screenshot, local build and run screenshots and CI/CD screenshots alike (a GitHub Actions
  run, a job log, an artifact), is committed to this repository and shown in the related document in `docs/`, with
  the image in `docs/assets/` and the shortest relative link. When no document fits, create one.
- **Clear originals.** Use the original pixels (`xcrun simctl io <device> screenshot`, an emulator's own capture,
  a full-resolution browser capture); crop to the detail, never scale below the original size.
- **Labels.** Next to every screenshot (its caption or table row) write:
  - the platform: iOS, Android, Flutter, React Native, HarmonyOS or mini program;
  - the environment: the host OS version and build, the simulator or emulator (device and OS version), and the
    platform SDK version (Xcode and iOS SDK; Android SDK and API level; Flutter SDK; React Native; HarmonyOS SDK and
    API version; the mini program base library);
  - this repository's version number or commit link;
  - the date and time it was taken, with the time zone.
- **Key milestones.** Take and publish screenshots at key milestones: when a `TODO` or `Linux` note can be removed,
  when a pull request can be merged, or when the result works as expected with no known bug and no open issue.
- **README.** At such a milestone, when the result is as expected, update the screenshot section of `README.md`
  (create it if missing) with the latest images and the labels above. Show the key details, cropped; capture the
  full screen only when it is needed. Combine several details into one stitched image
  (`scripts/stitch-screenshots.swift`), laid out in this order of preference:
  1. stacked top to bottom, one image per row (easiest to read on a phone);
  2. two columns over several rows;
  3. one horizontal row of at most three images.

  Correction (user, 2026-11-12): the original wording, "prefer the horizontal arrangement" and "worst is horizontal stitching", contradicted itself; the rule is to prefer the vertical arrangement, one image per row stacked top to bottom.

### Stitched screenshots: layout, header and footer (added 2026-11-18)

- Prompt, verbatim: "找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：找到截图相关规范，如果没有就新建保证写入成功，截图除了 优先选用竖版排列风格。优先两列，多行。且给拼接好的图增加header，footer，header，footer不能与截图区域重叠 覆盖，标注关键信息：关键信息也是英文，测试模拟器平台，模拟器系统版本，操作系统版本，ide 版本，以及测试目的等等。以附带的截图为例。提取截图的附带信息以及风格 完善我的描述规则。 更新截图规则，优选一列多行 如果一列拼接后长度超过普通手机的一屏幕 则两列多行"
- Prompt, English: stitched screenshots are vertical; they get a header and a footer that never overlap or cover the
  screenshots, with the key information in English (platform, simulator and its OS version, host OS version, IDE
  version, purpose of the test, and so on), in the style of the example the user attached. Prefer one column over
  several rows; when that column is taller than one screen of an ordinary phone, use two columns over several rows.
- **Layout** (replaces the order of preference above):
  1. one column, several rows, stacked top to bottom;
  2. when that one column would be taller than one phone screen, two columns over several rows (left to right, then
     top to bottom). One phone screen is the height of one full screenshot of the device under test (for example
     2622 px for an iPhone 17 Pro or iPhone 18 Pro simulator, 2400 px for a 1080 x 2400 Android phone); for crops of
     the full screen width, the script uses the cell width x 19.5 / 9;
  3. never one horizontal row of more than three images.
- **Header**: a band of its own above every screenshot, never drawn on a screenshot. Bold, red (#FF3B30) on white,
  English, one or two lines:
  1. the platform and the OS version of the simulator or emulator (iOS 27.2, Android API 37, HarmonyOS API 21, WeChat
     base library 3.6.6) and the device ("iPhone 18 Pro sim", "Medium Phone emulator", "Mate 70 Pro emulator");
  2. the IDE or SDK version (Xcode 27.2 (27B52), Android Studio and Android SDK, Flutter 3.47.9, React Native,
     DevEco Studio, WeChat DevTools);
  3. the host OS version (macOS 27.3, Windows 11) when it matters for the result;
  4. the code under test: the library and its commit (CYLTabBarController dcbfdec6), this repository's commit, the
     branch;
  5. the date (and time with its time zone when several runs are compared);
  6. the purpose: what the image proves, in a few words ("Rive tags at rest (no play)").
  Example, from the user's image: "iOS 27.2, iPhone 17 Pro sim, Xcode 27.2, CYLTabBarController dcbfdec6 (ef1d0313),
  feat/harmony, 2026-11-18. Rive tags at rest (no play)".
  The image: [docs/assets/screenshot-style-example-ios27.2-rive-tags-20261118.png](docs/assets/screenshot-style-example-ios27.2-rive-tags-20261118.png).
- **Captions**: every panel has a short caption in its own band right above it, bold red: the state or the step and
  its timing ("launch, no play"), with a measured result when there is one ("11 s later, 0 changed pixels").
- **Footer**: a band of its own below every screenshot, bold dark gray: the result or verdict (pass / fail, bug
  number), and what is not in the header but needed to reproduce (file names, launch arguments, the test or command).
- **Never overlap**: the header, the captions and the footer never cover any pixel of a screenshot; screenshots keep
  their original pixels (cropped, never enlarged); everything written on the image is English.
- **Tool**: `swift scripts/stitch-screenshots.swift --header "<line 1>\n<line 2>" --footer "<result>" --out
  docs/assets/<name>.png "<shot 1>.png=<caption 1>" "<shot 2>.png=<caption 2>"`. `--columns auto` (the default)
  applies the layout rule; `--screen-height <px>` sets one screen when the images are not full-width crops.

### Screenshot labels are enforced (added 2026-11-18)

User's request (2026-11-18): "检查为什么没有应用新增的截图Label规范，并强化该策略保证以后截图必须遵循该规范，避免再出现该问题。"
(find out why the new screenshot label rule was not applied, and make every future screenshot follow it).

Why it was missed (2026-11-17/18, the Windows session): the header and footer rule landed mid-session from another
session and nothing made the session re-read it; the older "Labels" rule was applied only in part (platform, device,
pins, but no host OS, SDK or IDE version, time zone); the only tool ran on macOS; and nothing checked a screenshot
before it was committed. So, from now on:

- **Every screenshot, not only stitched ones.** Every image committed to `docs/assets` goes through a stitching tool
  with `--header` and `--footer` (one image is a one-panel stitch). The raw capture may be kept in `docs/assets/raw/`
  as the tool's input; documents link the labelled PNG.
- **A tool on every host.** macOS: `swift scripts/stitch-screenshots.swift`; Windows:
  `powershell -ExecutionPolicy Bypass -File scripts/stitch-screenshots.ps1 -Header "..." -Footer "..." -Out
  docs/assets/<name>.png "<shot>.png=<caption>"` (same layout and look). Both require a header and a footer and write
  them into the PNG as its "Description" text (`CYL header: ... | CYL footer: ...`).
- **The check.** `sh scripts/check-screenshot-labels.sh` (staged images) or `... BASE HEAD` fails when an added
  `docs/assets` image is not a PNG, has no header and footer, is shown by no Markdown file, or the line that shows it
  has no date (YYYY-MM-DD) and commit. Run it before every commit that adds an image (commit readiness). CI does not
  run it: the `screenshot-labels.yml` workflow was removed at the user's request (2026-11-18, "Remove label CI
  screenshots from ci").
- **The label line in the document**: on the same line as the image link, the platform, device and OS version,
  SDK / IDE version, host OS, the library commits, the date with time and time zone.
- **Rules change mid-session.** At the start of each task, pull and read what changed in the rules since the session
  began (`git log --since=<session start> -p -- AGENTS.md instructions.md .agents/skills`), and apply it to the task.
- **Scoring.** A task with an unlabelled screenshot cannot pass (`cyl-task-start`).

## Open pull requests and issues of projects we translate

When a document of this project links to another project's GitHub repository (not this project) because its code
is translated, ported or merged into ours (for example the Kotlin transcriptions in `android/`), the work covers
that project's open pull requests and open issues, not only its default branch. The same rule applies on every
platform (iOS, Android, Flutter, React Native, HarmonyOS, mini programs).

1. **Open pull requests.**
   - Translation not started yet: merge the project's open pull requests into the code you translate first.
   - Translation already done: translate each open pull request's changes separately and merge them into our
     translated code.
2. **Open issues table.** In the related `docs/` document (create one when none fits), list every open issue of
   that project in a table: first column the issue link, second column the issue description, third column the fix
   status, `TODO` by default. Record the date the list was read.
3. **Fix them in our code.** For each issue, find its counterpart in our code and try to fix it there; set the
   status to `DONE` with the commit (or `N/A` with the reason when the issue does not apply to our code, for example
   a feature we do not have).
4. **Score.** Score = issues `DONE` or `N/A` / all listed issues × 100. Score again after every fixed issue and
   continue until 100.
5. **Order.** When the translation has not started: merge the open pull requests, then work on the open issues;
   start translating once the issue score reaches 60; after translating, fix the remaining issues until 100. When
   the translation is done: translate and merge the open pull requests, then fix the issues on the translated code
   until 100.

## Task log before every task

Sessions can stop in the middle of a task (context limits, restarts, another
session taking over the branch or the simulator). So that the next session can
pick the task up, every task is written down in `docs/` before any work starts:

1. **Find the most suitable document in `docs/`**: the feature's own document
   (for example `docs/search-bar-view.md`, `docs/CI-CD.md`,
   `docs/CYLTabBarController-Integration.md`). When none fits, use
   `docs/task-log.md`.
2. **Add the task there as `TODO`, before the first change**, under a heading
   such as `## TODO (YYYY-MM-DD): <task>`, with:
   - **Context**: the background, the branch, the related PRs, issues,
     commits and files, and what is already known;
   - **Requirements**: every requirement the user gave, as a list;
   - **Prompt**: the user's prompt quoted verbatim in its original language,
     followed by an English translation;
   - **Status**: where the work stands; update it at each milestone (commit,
     push, CI result).
   Commit and push this entry before starting the work.
3. **When the task ends, mark it done**: change `TODO` to `DONE (YYYY-MM-DD)`
   and add the result and the evidence (commits, PRs, test results,
   screenshots). An interrupted task keeps `TODO` with its current status.

An open `TODO` of a task in progress is not a stale note: the "stale notes
before every commit" search skips it, and the session that finishes the task
marks it `DONE`.

### Start, score and finish every task (added 2026-11-18)

User's rule (2026-11-18): every task starts with a visible `TODO`, is scored
against acceptance criteria written before the work, and does not stop before
it passes. Checklist: the `cyl-task-start` skill.

0. **Read the rules that changed since the session began** (added 2026-11-18): other sessions edit `AGENTS.md`,
   `instructions.md` and the skills while this one runs. `git pull`, then
   `git log --since=<session start> -p -- AGENTS.md instructions.md .agents/skills`, and apply what changed.
1. **Check other sessions first.** List the other sessions (for example
   `ListAgents`) and read their tasks, usually marked `TODO` at the top of each
   session. If no session is editing the same branch, go on. If one is, check
   whether its task is the same as yours: when it is, do not duplicate it (ask
   that session or the user how to split the work); when it is not, go on and
   keep out of its files.
2. **Mark the task at the top of the session**: the first lines of the session's
   reply are `TODO` with the task in one line and the current branch
   (`git branch --show-current`), for example
   `TODO (branch feat/harmonyos-parity): pin CYLTabBarController 6a9ede85`.
3. **Write the task into `docs/`** as in the steps above, adding
   **Acceptance**: what full marks (100) are and what a pass (60) is, as
   checkable items (builds, tests, screenshots, documents, commits pushed).
4. **Score until it passes.** Score the work against the acceptance criteria
   after each milestone. Below the pass mark the task must not be interrupted
   or handed back: keep working and scoring until it passes.
5. **Explain the missing points.** When the score is below 100, say why each
   missing point could not be earned (for example no arm64 device, a peer's
   pending change).
6. **End the session with the missing points as `TODO`s**: the last lines of
   the final reply list every missing point as `TODO (n points): <what is
   missing>`.
7. **Update the document written at the start**: the score, the reasons, the
   remaining `TODO`s, and `DONE (YYYY-MM-DD)` once it reaches 100 (or a pass
   with the missing points listed).

## Emulators and simulators: restart when hung (added 2026-11-18)

User's rule (2026-11-18): restarting is the first remedy, and needs no
question to the user.

- **An emulator that stays hung until it is restarted** (for example `adb`
  answers `shell echo` but `pm`, `am` and installs time out; `hdc` commands
  hang): tell the other sessions first (a message to each session that uses it:
  what hangs, that you restart it now), then restart it.
- **An emulator or simulator that does not open, or does not finish booting**:
  restart it first, before any other diagnosis.
- **Restart from the command line, without asking the user**, for example
  `adb -s emulator-5556 reboot` (or `adb -s emulator-5556 emu kill`, then
  `emulator -avd <name> -no-snapshot-load`), `hdc -t 127.0.0.1:5555 shell reboot`,
  `xcrun simctl shutdown <udid> && xcrun simctl boot <udid>`. Tell the other
  sessions again when it is back.

## Commit readiness

- **Every branch with commits has an open pull request (added 2026-11-16).** Never create a branch and keep committing
  to it without a pull request: commits on a branch without a pull request are ignored, they are never reviewed or
  merged.
  - Before every commit, check that the branch has an open pull request (`gh pr list --head <branch> --state open`).
    If it has none, open one.
  - Target (base) of a new pull request: the pull request that was active before this one (its head branch) first;
    `master` only when there is none.
  - When more than two pull requests are already open, stop and ask the user whether to create a new branch with a
    pull request or keep committing on the current branch: more than two open branches make merging hard and leave no
    sensible target branch for each.
  - At the end of every exchange (one question and its answer), when the current branch is not `master` / `main`,
    commit and push without asking: the work is always on a branch, never pushed to `master` / `main`, so pushing is
    safe and carries no risk to worry about.

- **Before every commit that adds an image** (added 2026-11-18): `sh scripts/check-screenshot-labels.sh` must print
  `screenshot labels: ok`; fix the image or its label line before committing ("Screenshot labels are enforced").

- **Before every Commitizen-style (`git cz`) commit**, run this first in the repository root, so the vault's auto sync does not commit or push in the middle of it:

  ```sh
  touch .git/hooks/NO_AUTO_SYNC
  ```

- **`git cz` style, English only (added 2026-11-16).** Prompt (verbatim): "写入instructions相关文件以及skills，找到commit规范，如果没找到就新建，寻找关键字 git cz，如果没有就新建，如果有就追加以下规则：全英文写入： git cz 风格提交，全英文commit 不允许出现中午。 continue" ("中午" is a typo for "中文", Chinese). Prompt (English): "Write into the instruction files and the skills: find the commit rules (create them if missing), look for the keyword git cz (create it if missing, append if present) and add, in English: commits in git cz style, commit messages entirely in English, no Chinese allowed. Continue." Rules:
  1. Every commit is a Commitizen (`git cz`) style commit: `<type>(<scope>): <emoji> <subject>` or
     `<type>: <emoji> <subject>`, type one of `test`, `feat`, `fix`, `chore`, `docs`, `refactor`, `style`, `ci`, `perf`,
     `release` (instructions.md, "Commitizen defaults").
  2. The whole message (subject, body, author line and trailers) is in English. No Chinese characters (or any other
     non-English text) are allowed,
     not even a quoted prompt: quote a Chinese prompt in the `docs/` task log and link it from the body instead.
  3. Check before committing: `scripts/check-commit-message.sh <message file>`, or
     `git log -1 --format=%B | scripts/check-commit-message.sh -` for the last commit. It checks the git cz form, the
     subject length (3 to 64 characters) and Chinese characters. A failing message is rewritten
     before pushing. Skill: `cyl-commit`.

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
- Before a Commitizen-style commit, follow the commit-message hook instructions
  in `instructions.md`; inspect an existing hook before replacing it.
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

## Animation examples: playback controls (added 2026-11-13)

- Any example page that shows animations, on every platform (iOS, Android, React Native, Flutter, mini programs,
  HarmonyOS), offers "Play all" (each animation restarts from progress 0), a speed slider and a loop switch, combined
  into one playback strategy applied live, with accessibility labels and values; change the core when an example
  needs it. This repository has no animation example yet; the rule and its status live in CollectionViewClassifyMenu
  `docs/example-animation-controls.md` and CYLTabBarController `docs/Tab-Icon-Animation-Quick-Start.md`.

## HarmonyOS: API and example 1:1 with iOS, internals from the Android Kotlin sources (added 2026-11-16)

- Prompt (verbatim): "写入instructions相关文档，鸿蒙系统版本，原则如下：API对标iOS端，example对标iOS端。需要一比一复刻。内部实现对标android 内的Kotlin 源码实现迁移到鸿蒙端。继续 continue 你未完成的任务"
- Prompt (English): "Write into the instructions documents the HarmonyOS version and these principles: the API matches
  iOS, the example matches iOS, a one-to-one copy; the internal implementation is migrated to HarmonyOS from the
  Kotlin sources in android/. Then continue the unfinished tasks."
- HarmonyOS version: HarmonyOS NEXT, target HarmonyOS 6.0.1 (API 21), compatible from HarmonyOS 6.0.1 (API 21; the minimum of CYLTableViewPlaceHolder's cylplaceholder)
  (`harmonyos/build-profile.json5`); ArkTS with ArkUI state management V2 (`@ComponentV2`); DevEco Studio 6.0.1 with
  its bundled SDK, hvigor and ohpm.
- Rules:
  1. API: every public API of the iOS library has a HarmonyOS counterpart with the iOS name
     (`docs/harmonyos-api-alignment.md`).
  2. Example: `harmonyos/entry` replicates `CYLSearchExample` one to one: the same tabs, pages, texts in
     en/ja/zh-Hans/zh-Hant, data, images and interactions (`harmonyos/scripts/import-ios-resources.py` imports the iOS
     resources). A change to the iOS example changes the HarmonyOS example in the same task.
  3. Internals: migrate the behavior from the Android Kotlin sources (`android/`) to ArkTS (the same state handling,
     filtering, caching and event order); write new code only where Android has none, and note it.
  4. Score both tables of `docs/harmonyos-cross-platform.md` after each feature (`python3 scripts/harmonyos-scorecard.py`)
     until no TODO is left.

## HarmonyOS: IDE preparation and emulator prerequisites (added 2026-11-16)

- Prompt (verbatim): "全英文写入instructions相关文件以及 skills相关文件： 鸿蒙系统 ide 准备工作，模拟器安装的必要条件， region should be set to china (NZ) in country.region.xml to china make sure The region file now says China: <countryregion name="CN"/>"
- Prompt (English): "Write, in English only, into the instruction files and the skill files: the HarmonyOS IDE
  preparation and the prerequisites for installing the emulator. The region must be set to China in
  `country.region.xml` (the developer is in New Zealand); make sure the region file says China:
  `<countryregion name="CN"/>`."
- Before the first HarmonyOS build or run on a machine, follow the `cyl-harmonyos-setup` skill. In short:
  1. IDE: DevEco Studio 6.0.1 with its bundled SDK (API 21), signed in with a Huawei ID. Command-line builds set
     `DEVECO_SDK_HOME` to DevEco Studio's `sdk` and put its `jbr\bin` and `sdk\default\openharmony\toolchains`
     (`hdc`) on `PATH`. hvigor rejects paths with spaces or non-ASCII characters: build from an ASCII mirror of
     `harmonyos/` (for example `C:\cylbuild\harmonyos`).
  2. Emulator prerequisites: a 64-bit Windows 10 or 11 host (or a Mac with Apple silicon); CPU virtualization
     enabled in the firmware; the Windows features Hyper-V, Windows Hypervisor Platform and Virtual Machine Platform
     on (`HypervisorPresent` is `True`); 16 GB RAM at least and enough free disk; a Huawei ID sign-in; the Device
     Manager privacy statement accepted; and the region set to China.
  3. Region: the developer is in New Zealand (first-launch region `NZ`), but the local emulator is offered only for
     China. With DevEco Studio closed, `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml` (macOS:
     `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/country.region.xml`) must contain
     `<countryregion name="CN"/>`. Check it before creating an emulator and after restarting the IDE; keep the
     original as `country.region.xml.bak-NZ`.
  4. Emulator: Device Manager > Local Emulator > New Emulator > Mate 70 Pro, HarmonyOS 6.0.1 (API 21); check with
     `hdc list targets`; install with `hdc install`.
  5. Signing (user, 2026-11-16: "模拟器 测试 不需要签名 跳过签名", "emulator tests need no signing; skip signing"):
     emulator runs and tests use the unsigned HAPs; keep `signingConfigs` empty and do not ask for a certificate,
     a profile or automatic signing. Signing is needed only for a real device or a release, when the user asks.

## HarmonyOS: screen readers and localization (added 2026-11-16)

- Prompt (verbatim): "适配视觉辅助 盲人辅助 为鸿蒙代码 。 适配国际化本地化，本地化文件可以从CYLTabBarController中复制一份过来。筛选本项目用到的文字。"
- Prompt (English): "Adapt the HarmonyOS code for visual assistance and for blind users. Adapt it for
  internationalization and localization; the localization files can be copied from CYLTabBarController. Keep only
  the texts this project uses."
- Screen readers: every tappable element of `harmonyos/cylsearch` has a label (`accessibilityText`, or a `Text` child)
  in the language the app shows; decorative icons are `accessibilityLevel('no')`; a touch area is at least 44 vp
  (`responseRegion` when the icon is smaller and the layout must not change); a list item reads its position and
  selected state (`accessibilityDescription`, `accessibilitySelected`); a state change with nothing on screen to
  read is announced (`accessibility.sendAccessibilityEvent`, `announceForAccessibility`).
- Localization: no English text written in the library's UI code; titles and labels default to string resources
  (`ResourceStr`). en, ja, zh-Hans and zh-Hant come from iOS (`check-ios-parity.mjs`); the other languages come from
  CYLTabBarController's string table, filtered to the texts this project uses
  (`node harmonyos/scripts/import-cyltabbar-localizations.mjs`, which never overwrites the four iOS languages).
- Check both with `node harmonyos/scripts/check-accessibility-i18n.mjs`; Scorecard 2 rows 15 and 16 in
  `docs/harmonyos-cross-platform.md`.

## Accessibility, localization and UI automation by label (added 2026-11-16)

- Prompt (verbatim): "并将下面的内容规则写入instructions相关文件并写入skills相关文件，如果相关文件不存在就新建文件确保成功。全英文写入：本项目全部代码已经支持适配视觉辅助 盲人辅助 为鸿蒙代码 。 适配国际化本地化，本地化文件。如果发现不支持请先支持，然后在自动化UI测试过程中，优先使用刚刚提到的功能进行UI控件定位。触发点击事件，或者触发复杂流程，连续操作等。"
- Prompt (English): "Write the following rule, in English, into the instruction files and the skill files, creating
  them when missing: all code of this project supports visual assistance and blind users, the HarmonyOS code
  included, and is internationalized and localized with localization files. When something is not supported,
  support it first; then, in automated UI tests, locate UI controls with these features first, to trigger taps,
  complex flows and continuous operations."
- Rules:
  1. All code of this project (library and examples, every platform, HarmonyOS included) supports screen readers
     and is localized (the two sections above for HarmonyOS; skill `cyl-accessibility-i18n`).
  2. A gap found (a control with no label, a text written in code, a missing language key) is fixed first, before
     the test or the feature that needs it.
  3. UI automation locates controls by their accessibility label or localized visible text first, read from the
     app's string resources in the device language; an id only for a control with no label of its own. Taps,
     typing, submitting, complex flows and continuous operations go through labelled controls. A control a test
     cannot find by label is a screen-reader gap (rule 2).
- HarmonyOS: `harmonyos/entry/src/ohosTest/ets/test/CYLSearchUI.test.ets` (`findByLabel`, `tapLabel`, the flow test
  `searchFlowByLabels`); check `node harmonyos/scripts/check-accessibility-i18n.mjs` (the library and the example).
- Status on the Windows machine (checked 2026-11-16): the region file says `<countryregion name="CN"/>`, a hypervisor
  is present, 64 GB RAM, and the HarmonyOS 6.0.1 `phone_all_x86` image was downloading.

## Mini program example: a 1:1 copy of the iOS example (added 2026-11-15)

- The WeChat Mini Program example (`CrossPlatform/wechat-miniprogram-cylsearch/example`) replicates the iOS example
  (`CYLSearchExample`) one to one: the same tabs (`CYLTabBarConfiguration.json`), pages, texts and languages, data,
  images and interactions. Texts, data and images come from the iOS bundles through
  `scripts/import-ios-resources.js`; never retype them. A page added to or changed in the iOS example is added to or
  changed in the mini program example in the same task.
- What the example needs and the core lacks goes into the core components; the example passes data, style parameters
  and taps only. Differences only where the platform forces them (WeChat's menu button, no built-in speech
  recognition), each listed in `docs/miniprogram-api-alignment.md`.

## Swift core: examples adapt to the core (added 2026-11-13)

- When an Objective-C to Swift change of the core breaks an example's build, fix the example: example code has the lowest weight of all code here. Change any example code as needed; never keep a core API, overload, shim or deprecated alias only because an example uses it, and never lower the Swift core's quality (naming, types, optionality, access control) to fit an example. Compatibility matters only for callers outside the examples (published API users). The Swift coding standard (docs/swift-coding-standard.md) decides.

## Core behavior: focus alone changes nothing below the search bar (added 2026-11-13)

- Focusing the search field (cursor shown, keyboard up) without typing changes nothing below the search bar: the area under it (the cached queries and their header, the suggestions, the empty placeholder) looks exactly as it does while the field is not focused. That area is updated only when the person changes the text (typing, deleting, pasting, the clear button, a selected suggestion) or when its data changes (a submitted query, the cache cleared). Rule list: `docs/core-todo.md`, "Core behavior rules".

## Accessibility and localization on every platform; UI tests locate controls through them (added 2026-11-16)

- All code of this project (the core, every port and every example, HarmonyOS included) supports visual accessibility
  and screen readers for blind users (VoiceOver, TalkBack, HarmonyOS ScreenReader), and internationalization /
  localization through localization files. Every control a user can tap or read has an accessibility label (and a hint
  where the action is not obvious), tappable rows are one accessibility element, and every user-facing text comes from
  a localization file, never a hard-coded string (HarmonyOS: `$r('app.string.…')` in `resources/<locale>/element/string.json`;
  translations shared with CYLTabBarController are copied from its `CYLTabBarController.bundle/*.lproj`).
- If something turns out not to support them, add the support first, then continue the task.
- In automated UI tests, locate controls through these features first: accessibility identifiers / labels (iOS
  `accessibilityIdentifier` / `accessibilityLabel`, Android `contentDescription`, HarmonyOS `.id()` /
  `accessibilityText`, `ON.id` / `ON.accessibilityText`), then localized text. Use them to trigger taps, complex flows and
  series of actions; coordinates are the last resort.

## Running scripts: prefer bash (added 2026-11-16)

- Run scripts with bash first: write them as `#!/usr/bin/env bash` files and run them with `bash script.sh`, or pipe
  a heredoc to `bash` (`bash <<'EOF' … EOF`), instead of typing them straight into the interactive shell.
- Reason: the default shell here is zsh, and zsh does not split an unquoted variable into words. For example, with
  `box="10 20 30 40"`, `sips --cropOffset $box …` passes one argument in zsh but four in bash. The error this rule
  avoids: "zsh doesn't split $box into words either. Running the same measurement as a bash script."
- In zsh, when a script cannot be used, split explicitly (`${=box}`) or use an array; never rely on word splitting.

## Sessions by platform: Mac for iOS, Win for the other platforms (added 2026-11-19)

- Before starting a task, check the session names (for example with `ListAgents`; this session's own name is shown
  there too).
- A session whose name starts with `Mac` (case-insensitive) mainly develops and tests the iOS side.
- A session whose name starts with `Win` (case-insensitive) mainly develops the other platforms (Android, HarmonyOS,
  Flutter, React Native, mini program).
- When sessions of both kinds are active, assign the platform parts of a task to the fitting session: send the iOS
  part to a `Mac` session and the other platforms to a `Win` session, rather than doing every platform yourself.
- When no session follows this naming, skip this rule and finish the task on your own.


## Image resources: folder bundles (added 2026-11-19)

- New image files of a core live in a folder bundle, never in an asset catalog (user's prompt, verbatim:
  "请确保新增的图片资源文件在core代码仓库中均以文件夹形式管理，以iOS为例，图片资源文件均存放在.bundle的文件夹形式中"). On iOS: PNG files
  (@1x, @2x, @3x) in a `<Name>.bundle` folder under the core's resources, copied by the podspec and by `Package.swift`
  (`.copy`), and read through the core's resource lookup (as CYLTabBarController's `CYLAnimatedItem.bundle` and
  CollectionViewClassifyMenu's `CYLClassifyMenuImages.bundle`). Other platforms keep images in a resource folder of the
  same kind. This repository's core has no image files today (its icons are SF Symbols).
