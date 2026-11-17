# Animated Icon Component (CYLTagButton)

## Progress against the guide (CYLTabBarController `docs/Animated-Item.md`)

Guide: <https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md>,
read at `e3ebc24` (2026-11-17, docs only after `57a527e`). Updated 2026-11-17 07:30 UTC. Score: 19 of 25 rows done (76);
the 6 open rows wait on CI, a device or upstream. Every row with "unverified" is written but has not been compiled or run
(no Xcode, Android SDK, DevEco or WeChat DevTools in the container that wrote it).

Prompt (verbatim): "告诉我 你遵循文档改造的进度，并在本仓库合适地方标注进度以及todo。这个文档是与动效组件相关的。告诉我 你遵循文档改造的进度https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md"
(English: "Tell me your progress in following the document, and mark the progress and the TODOs in a suitable place in
this repository. The document is about the animated component.")

### Done

| # | Guide requirement | Platform | Where in this repository | Status |
|:--|:---|:---|:---|:---|
| 1 | Search bar items are the one icon + title component (`CYLTagButton`, a `CYLAnimatedItemView`) | iOS | `CYLSearchBarItemButton: CYLTagButton` in `Sources/CYLSearchBar/CYLSearchBarView.swift` | DONE |
| 2 | The core depends on `CYLAnimatedItem` (Core, static images), never on an engine or CYLTabBarController | iOS | podspec `s.dependency 'CYLAnimatedItem'`; `import CYLAnimatedItem` | DONE, `pod lib lint` passes (run 265) |
| 3 | Only the example adds engines (`CYLAnimatedItem/<Type>`) | iOS | Podfile: `CYLAnimatedItem` `Core`, `SVGA`, `LottieSwift`; Flutter example `SVGA`, `Rive`; React Native example from the vendored checkout | DONE |
| 4 | Pods not on the trunk are named by `:git` + `:commit` | iOS | Podfiles pin CYLTabBarController and `CYLAnimatedItem` at `57a527e` | DONE |
| 5 | Example imports engine headers from the `CYLAnimatedItem` pod | iOS | `CYLSearchExampleAppDelegate.m` imports `<CYLAnimatedItem/CYLSVGATabBarItemAnimator.h>` (`7ee53de`) | DONE, CI pending |
| 6 | Engine-only API guarded or read without the engine | iOS | the core uses only `animationURL`, `playAnimation` and the hooks; tests read `animationPlayer` by key | DONE |
| 7 | Android: depend on `cyltabbarcontroller-animateditem`, package `com.cyl.animateditem` | Android | `android/merged/settings.gradle.kts` includes `:cylanimateditem` and substitutes the Maven coordinate | DONE, unverified |
| 8 | Android: the core links no engine; the app adds the libraries | Android | `cylsearch` has none; `app` adds `libs.lottie` and SVGAPlayer (`:placeholder-lottie` removed with CYLTableViewPlaceHolder `62e40c0`) | DONE, unverified |
| 9 | HarmonyOS: the component by commit (`cylanimateditem` module) | HarmonyOS | `harmonyos/scripts/sync-sub-repositories.py` vendors it next to `vendor/classifymenu`; `build-profile.json5` registers it (`68b5a52`) | DONE, unverified |
| 10 | HarmonyOS: the core links no engine; the app registers engines and the animation builder | HarmonyOS | `cylsearch` depends on no animation library; `entry` registers Lottie, PAG, Rive, SVGA, GIF in `EntryAbility.onCreate` | DONE, unverified |
| 11 | Mini program: `cyl-animated-item` by commit, engines through abstract nodes | Mini program | `cyl-search-bar` / `cyl-search` forward `cyl-lottie-view`, `-pag-`, `-rive-`, `-svga-` to `cyl-tag-button`; the example passes `cyl-lottie` and `cyl-svga` (`68b5a52`) | DONE, `npm test` 51/51, not run in DevTools |
| 12 | Sub-repositories on the component, pinned by commit | all | CollectionViewClassifyMenu `71562ca` (every platform on the component), CYLTableViewPlaceHolder `62e40c0` (placeholders on it) | DONE |
| 13 | The two CYLAnimatedItem bugs found by our CI fixed in the core (module, Lottie only for Lottie files) | all | CYLTabBarController PR #814, merged into #788 (`9a54e26`), pinned since | DONE |
| 14 | A license in every published package (the guide's "license notice in every published package") | all | MIT `LICENSE` in every package bundle; `scripts/check-licenses.sh` in CI (`docs/licenses.md`) | DONE |
| 15 | Parity tables follow the merged API | all | Android, HarmonyOS and mini program tables regenerated, all 100 | DONE |
| 16 | Docs describe the component and the pins | all | this document, `docs/sub-repositories.md`, `README.md` License section | DONE |
| 17 | Pin the newest commit of the newest branch (a merged pull request branch does not count) | all | `AGENTS.md`, `instructions.md`, `cyl-tabbar-integration` skill | DONE |
| 18 | Every iOS failure of the migration fixed in the core first | iOS | ClassifyMenu re-export of `CYLAnimatedItem` (`b15b822`); this repository's only example-layer fix is row 5, recorded as example-only | DONE |
| 21 | HarmonyOS build and run | HarmonyOS | Mate 70 Pro emulator (HarmonyOS 6.0.1, API 21), Windows with DevEco, 2026-11-17: the HAP builds (two example-only compile fixes, `9f9c3d7`); ohosTest 29 of 29 pass at CollectionViewClassifyMenu `232878a` (`b210a1e` for three test fixes). On screen: the SVGA header plays when shown and again on each tap, with its full title (`assets/harmonyos-mate70pro-api21-20261117-svga-tagbutton-title.jpeg`, `…-svga-tagbutton-playing.jpeg`; before: `…-title-cut-before.jpeg`); the search bar's items keep the tint (`…-searchbar-item-tint.jpeg`). The two core bugs found here (a standalone tag measured its title without the UI context; it always took the tap) were fixed in CollectionViewClassifyMenu `232878a` and pinned on every platform. PAG and Rive stay arm64-only on the x86_64 emulator (Scorecard 3 row 25) | DONE |

### TODO

| # | Item | Platform | Why it is open | Next step |
|:--|:---|:---|:---|:---|
| 19 | A complete iOS CI run of the current tip | iOS | every run since 06:02 UTC was cancelled by the next push. Run 271 (`bb261ce`): `pod lib lint`, shellcheck, comments and licenses pass; unit tests failed to compile `CYLSearchDemoMenuViewController.m` ("use of undeclared identifier 'CYLSVGADemoTagButton'"): the example's Swift class returns a `CYLTagButton`, whose base class is in the `CYLAnimatedItem` module, which the example never imported, so the generated `CYLSearchExample-Swift.h` left the class out. The imports alone (`ff54219`) did not help (same error on `9f9c3d7`); the menu now creates the button through the runtime (`NSClassFromString(@"CYLSVGADemoTagButton")` + `performSelector:`), as it already does for `CYLSVGASwiftUIDemo`. Example-layer fix, reason: the core side is done (CollectionViewClassifyMenu re-exports `CYLAnimatedItem`, `b15b822`); the missing import is in example code, the same case as ClassifyMenu's demo app (`880d9b1`) | the next complete run |
| 20 | Animated icons seen playing in the example | iOS, Android | no screenshot of an animated search bar item yet | screenshots from CI (iOS) and an emulator (Android) |
| 22 | Mini program run | Mini program | no WeChat DevTools here; `generic:` resolution through `app.json` and the npm default path untested | run in DevTools, screenshots |
| 23 | Upstream gaps of the component | HarmonyOS, mini program | mini program: GIF without stills, speed or loop and always-on autoplay (fixed by CYLTabBarController PR #815, not merged); HarmonyOS: square icon only, no PixelMap or symbol as the static image (a symbol item shows the placeholder while loading), type by extension only, fixed 4 vp padding and 44 vp minimum height (asked, waiting on the owner) | after #815 is merged: pin its merge and pass `gif-first-frame` / `gif-last-frame` / `gif-duration`, `embedded`, `autoplay` in `cyl-search-bar` |
| 25 | Android build at the CollectionViewClassifyMenu pin | Android | 2026-11-17, Windows: `:classifymenu:compileDebugKotlin` fails at `232878a` and at the previous pin `71562ca`: its `CYLTagButton.kt:297` names `com.cyl.tabbar.CYLSize`, but CYLTabBarController's `:cylanimateditem` has it in `com.cyl.animateditem` (at `57a527e` and at its newest `357c314`). A core bug of CollectionViewClassifyMenu, sent to its session | pin its fix, then `./gradlew :app:assembleDebug :cylsearch:testDebugUnitTest` and the animated search bar item on the Android emulator (row 20) |
| 24 | Pin the guide's newest commit `e3ebc24` | all | docs only after `57a527e`; held during the CI push freeze | move the pins with the next code change |

## TODO (2026-11-17): one icon + title / animated icon component everywhere

- **Context**: branch `feat/harmonyos-parity` (PR #11). The packaged icon + title component that also plays animated
  icons is CollectionViewClassifyMenu's `CYLTagButton`
  (`CollectionViewClassifyMenu/Class/TagList/CYLTagButton.swift`, branch `feat/harmony`): an icon (`imageView`), a
  title (`titleLabel`), a delete indicator, and `animationURL` / `playAnimation()`, which hand every file format to
  CYLTabBarController's animation engine (`CYLTabBarItemAnimationFactory`, found at runtime) with no per-format code.
  Found in this project: `CYLSearchBarView`'s item control (`CYLSearchBarItemControl`, icon + title + badge, its own
  view), the empty-result placeholders (CYLTableViewPlaceHolder's `CYLPlaceholderView`, whose animated icons use that
  library's own engine, `CYLPlaceholderItemAnimationEngine`, without SVGA), and the example's SVGA demo header
  (`SVGAPlayer` directly). `CYLTagButton` lacks a badge and an icon-above-title layout.
- **Requirements**:
  1. Every component of the project that shows an icon with a title, or plays an animated icon, uses the same
     component, `CYLTagButton`; where it does not, change its implementation so that it does.
  2. A new animation type is then added in that one component only; every component that shows animations supports
     it with no second change.
  3. All platforms: iOS, Android, HarmonyOS and the mini program (CollectionViewClassifyMenu has a `CYLTagButton`
     counterpart on each); React Native and Flutter follow through the native cores.
- **Decisions (user, 2026-11-17)**: everything goes through `CYLTagButton`. CYLTableViewPlaceHolder: layered — its own
  session (task "Every icon + title and animation display goes through CYLPlaceholderView", branch
  `feat/android-refresh-port-followup`, PR #31) first makes everything there go through `CYLPlaceholderView`; then
  `CYLPlaceholderView` draws its animated icon with `CYLTagButton` (CYLTableViewPlaceHolder gains a dependency on
  CollectionViewClassifyMenu and drops its own engine). That step waits for that session, to avoid editing
  `CYLPlaceholderView` in parallel.
- **Plan**:
  1. CollectionViewClassifyMenu (every platform): `CYLTagButton` gains what the other uses need: a badge, an icon
     above the title (a `CYLTagImagePlacement` case), icon-only use; pushed to `feat/harmony` and pinned here.
  2. This repository (every platform): `CYLSearchBarView`'s items are drawn by `CYLTagButton`; the example's SVGA demo
     is a `CYLTagButton` with an `.svga` `animationURL`.
  3. CYLTableViewPlaceHolder: `CYLPlaceholderView`'s animated icon becomes a `CYLTagButton` (after its session).
- **Prompt (verbatim)**: "请确保本项目中所有具有如下特征的组件使用的是同一个组件，如果不是相关代码修改内部实现，以保证使用的是同一个组件，方便我重构该组件就可以把修改应用到所有组件上。我的需求是以后新增动效类型，仅需需要修改这个组件，所有需要使用动效展示的组件都可以支持新增动效，无须在第二个地方修改代码。" (followed by the link to `CYLTagButton.swift` on `feat/harmony`, line 94, and its description)
- **Prompt (English)**: "Make sure every component of this project with the following traits uses the same component;
  where one does not, change its internal implementation so that it does, so that refactoring that component applies
  the change to all of them. My requirement: in the future, adding a new animation type only needs a change to this
  component, and every component that shows animations supports the new type with no change in a second place."
- **Status (2026-11-17)**: step 1 DONE, step 2 DONE on every platform (iOS, Android, HarmonyOS, the mini program; React
  Native and Flutter through the native cores), step 3 TODO. Nothing is compiled or run here (no Xcode, no Android SDK,
  no DevEco Studio, no WeChat DevTools): see "Unverified".

### Step 1: DONE (2026-11-17), CollectionViewClassifyMenu `1e43253` + `a0c8232`

- `CYLTagButton` gained a badge (`badgeValue`, `badgeColor`, `badgeLabel`), the icon above or below the title
  (`CYLTagImagePlacement.top` / `.bottom`), `height(forTitle:iconSize:style:traitCollection:)` and the standalone
  initializers `init(title:image:)` / `init(title:image:animationURL:)`, on iOS, Android, HarmonyOS and the mini program
  (`cyl-tag-button`), branch `feat/harmony`.
- Pinned here at `15877a483cbaa16bcbc26755f678f166463b5af4` (branch `feat/harmony`; it adds the HarmonyOS and mini
  program parts of step 2 below to `a0c8232`) on every platform: `Podfile`, the React Native and Flutter example
  Podfiles, `android/merged/gradle.properties` (`cyl.classifymenu.commit`), `harmonyos/oh-package.json5`
  (`collectionViewClassifyMenuCommit`) and the mini program's `package.json` (`collectionViewClassifyMenuCommit`).

### Step 2: DONE (2026-11-17) on every platform

- iOS (`Sources/CYLSearchBar/CYLSearchBarView.swift`): every `CYLSearchBarItem` is drawn by a `CYLTagButton`
  (a private subclass that adds only the link to its item, the divider line, the 36 pt touch area and the item's badge
  metrics), styled from the item for each state; `itemView` / `itemViews` are typed `CYLTagButton`;
  `CYLSearchBarItem.animationURL` is forwarded to the button and played on each tap.
- Android (`CYLSearchBarView.kt`): the same with `com.cyl.classifymenu.CYLTagButton` (`CYLSearchBarItemButton`);
  `itemView` / `itemView(context)` / `itemViews` are typed `CYLTagButton`; `CYLSearchBarItem.animationURL: Uri?`.
- Example (iOS): the SVGA demo above the Examples list is a `CYLTagButton` with `tab_activity.svga` as its
  `animationURL` (`CYLSearchExample/CYLSVGADemoTagButton.swift`, used by `CYLSVGADemoHeaderView`); the example no
  longer uses `SVGAPlayer` itself (the SVGA tab icons go through CYLTabBarController). Searched every example for
  other direct animation players or hand-made icon + title views (LottieAnimationView, PAGView, RiveView,
  SVGAPlayer, SVGAImageView, badge views): none left on iOS, Android, React Native and Flutter; the Android and mini
  program examples have no SVGA demo header (only SVGA tab icons through CYLTabBarController).
- Tests: iOS `testSearchBarItemsAreAppendedLikeFlatDesignTabBarItems` and Android `CYLSearchBarItemTest` check that
  an item's view is a `CYLTagButton` showing the item's title, image and badge, and forwarding `animationURL`.
- HarmonyOS (`harmonyos/cylsearch`): `cylsearch` depends on CollectionViewClassifyMenu's HarmonyOS library
  `@cyl/classifymenu` (`harmonyos/scripts/sync-sub-repositories.py` installs `harmony/classifymenu` at
  `collectionViewClassifyMenuCommit` into the git-ignored `harmonyos/vendor/classifymenu`, a module of
  `build-profile.json5`). `CYLSearchBarItem.itemView` is a `CYLTagButton`, created on first use and styled from the
  item by `reloadItemView(barTint)`: no border, the item's background (transparent by default) and 10 vp corners when
  it has one, its tint (else the bar's `itemTintColor`, else `sys.color.font_primary`) for the title and the icon,
  the title attributes of its current state, its icon size, insets, position adjustments and badge (color, text
  attributes, smallest size, insets, offset), at least 36 x 36 vp; a text item shows its title (and its icon), an
  icon item only its icon (its title is the screen reader label); system symbols are drawn with `SymbolGlyph`.
  `CYLSearchBarItemView` draws it through `CYLTagButtonHost` (the V1 bridge inside the V2 bar), grows the touch
  region to 44 vp, dims a disabled item and reads its label and badge; a divider keeps its line.
  `CYLSearchBarItem.animationURL` (`asset:<rawfile>`) is forwarded and played on each tap; `CYLSearchBarView.itemViews`
  returns the `CYLTagButton`s.
- HarmonyOS example: the SVGA demo above the Examples list is a `CYLTagButton` with `asset:svga/tab_activity.svga` as
  its `animationURL` (`ExamplesMenu.ets`, `cylSVGADemoTagButton`, as iOS `CYLSVGADemoTagButton`), played once when
  shown and on each tap; the example no longer uses cyltabbar's `CYLSVGAView` for it.
- One app, both libraries: classifymenu pins `@ohos/lottie` 2.0.38 and `@tencent/libpag` 4.4.31 (its minimum is
  API 12; libpag 4.5.102 needs API 15), cylplaceholder 2.0.28 and 4.5.102; `harmonyos/oh-package.json5` picks one
  version of each with ohpm `overrides` (the newer: `@ohos/lottie` 2.0.38, `@tencent/libpag` 4.5.102, `@ohos/rive`
  1.0.4), so the HAP carries one libpag.
- Mini program (`src/cyl-search-bar`): every item is CollectionViewClassifyMenu's `<cyl-tag-button>`
  (`cyl-tag-list-miniprogram`, an optional peer dependency installed by `scripts/sync-example.js` at
  `collectionViewClassifyMenuCommit`) with the properties of `CYLSearchBarItem.tagButtonProperties(tint)`: a
  transparent box (`allowsTransparentBackground`), no border, the tint of the color mode, the title attributes, the
  icon size, the badge and its color, the item's label for the screen reader; the 36 px box around it takes the taps
  and plays the item's `animationURL` (a key of the app's animation registry) on each tap.
- Tests: HarmonyOS `CYLSearchCore.test.ets` `searchBarItemsAreDrawnByTagButtons` (an item's view is a `CYLTagButton`
  with the item's symbol, badge, tint and `animationURL`; a text item shows its title) and the host logic tests
  `cylSearchBarItemButtonContent`, `cylSearchBarItemInsets`, `cylSearchTouchRegion`; mini program
  `components.test.js` "cyl-search-bar draws each item with cyl-tag-button" (title, image, badge, `animationURL`,
  transparent style, a tap plays the animation) and `package.test.js` (the two sub-dependencies, pinned by commit).
- Tables: `docs/harmonyos-api-alignment.md` 284 / 284 = 100 (`CYLSearchBarItem.animationURL`, `itemView`),
  `docs/miniprogram-api-alignment.md` 284 / 284 = 100.

### DONE (2026-11-17): step 2 on HarmonyOS and the mini program (logged as TODO in `00b8fde`)

- **Context**: CollectionViewClassifyMenu `27777c6b6a35951b9fd639849296dcbfaaae5876` (branch `feat/harmony`) removed
  the four HarmonyOS blockers above (`SymbolGlyph` for `sys.symbol` icons, `ResourceColor` colors, `CYLTagButtonHost`
  for V2 parents, animation versions noted: lottie 2.0.38, libpag 4.4.31 there vs 4.5.102 in cylplaceholder) and the
  mini program one (`allowsTransparentBackground`).
- **Requirements**: HarmonyOS `cylsearch` depends on classifymenu pinned to that commit like cylplaceholder / cyltabbar
  (`oh-package.json5` key, `sync-sub-repositories.py` entry, git-ignored vendor copy); `CYLSearchBarView.ets` draws
  every item with `CYLTagButton` (no border, the item's background, tint, title attributes, icon size; text item =
  title (+ icon), icon item = icon only, divider keeps its line, badge from the item, 44 vp touch area,
  accessibility); `CYLSearchBarItem.animationURL` forwarded; the example's SVGA header becomes a `CYLTagButton`.
  Mini program: `cyl-search-bar` items drawn with classifymenu's `cyl-tag-button` (transparent, iOS look), pinned to
  the same commit; `animationURL` on items. Tests, the parity generators at 100, docs.
- **Prompt**: relayed by the parent session for the task above (same prompt).
- **Result**: step 2 above. CollectionViewClassifyMenu commits on `feat/harmony`: `27777c6` (symbols, `ResourceColor`,
  `minimumSize`, badge metrics, `CYLTagButtonHost`, `allowsTransparentBackground`), `a7d3474` (`playAnimation()`
  before the icon is loaded plays it once loaded), `15877a4` (`cyl-tag-button` `accessibilityLabel`).

### Step 3: TODO

- CYLTableViewPlaceHolder: `CYLPlaceholderView`'s animated icon becomes a `CYLTagButton` (CYLTableViewPlaceHolder
  depends on CollectionViewClassifyMenu and drops `CYLPlaceholderItemAnimationEngine`); waits for that repository's
  own session (PR #31).

### Unverified

- Nothing was compiled here: the Swift core and example (`CYLSearchBarView.swift`, `CYLSVGADemoTagButton.swift`,
  `CYLSearchDemoMenuViewController.m`, the project file entry), the Objective-C test, the Kotlin core and its
  Robolectric test. To check: `pod install`, build and test the shared scheme; `./gradlew :cylsearch:testDebugUnitTest`.
- Not seen on a simulator: the items' look (no border, the field's background behind them, the 36 pt / dp touch
  area, the badge on the icon's corner), an animated bar item, and the SVGA demo header playing `tab_activity.svga`
  through the engine (whether `playAnimation()` before the SVGA file is parsed plays it once it is loaded).
- HarmonyOS, not compiled or run (no DevEco Studio here): `CYLSearchBarView.ets`, `ExamplesMenu.ets`, the ohosTest,
  the ohpm `overrides`; to check: `python3 harmonyos/scripts/sync-sub-repositories.py`, `ohpm install`, build, the
  ohosTest on the emulator, and on screen: the items' look (symbols tinted, theme colors in dark mode, the badge),
  the 44 vp touch region, the V1 tag inside the V2 bar redrawing when an item changes, the SVGA demo playing once.
  Whether `@cyl/classifymenu`'s PAG code runs on libpag 4.5.102 (built against 4.4.31) is not checked.
- Mini program, not opened in WeChat DevTools: the items drawn by `cyl-tag-button` (the camelCase attributes, the
  transparent box, the tap reaching the outer box, the badge position).
- Checks run here: the parity generators (Android 100, iOS 100, HarmonyOS 100, mini program 100),
  `harmonyos-scorecard.py` 100, `check-public-api-comments.sh`, the HarmonyOS host logic tests (30 pass), iOS parity
  (397 match) and accessibility checks (0 problems), the mini program `npm test` (48 pass, with the example synced).

## DONE (2026-11-17): depend on CYLTabBarController's CYLAnimatedItem; no animation engine in the core

- **Context**: CYLTabBarController (`feat/cross-platform-components`, guide
  [docs/Animated-Item.md](https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md),
  read at its newest commit `7511f7d`, 2026-11-17 03:36 UTC) ships the shared animated icon + title component `CYLAnimatedItem`: the component's core
  (`CYLTabBarController/CYLAnimatedItem`, CYLUtils only, static images, `CYL_ANIMATION_ENGINE_AVAILABLE` = 0 without an
  engine; Android module `:cylanimateditem`, Maven `io.github.chenyilong:cyltabbarcontroller-animateditem`) and one
  Core-free engine subspec per type (`CYLAnimatedItemLottieSwift`, `…LottieObjectiveC`, `…PAG`, `…PAGEnterprise`,
  `…Rive`, `…SVGA`, `…GIF`). Its migration row for `CYLTagButton`: subclass `CYLAnimatedItemView`, delete
  `CYLTagAnimationEngine` (the run-time lookup) and the own icon / title / animation properties, the delete indicator
  becomes `accessoryView`, the per-state look goes to `itemStateDidChange` / `onItemStateChanged`, the indicator's side to
  `accessoryPlacement`, static measuring stays. HarmonyOS and the mini program have no `CYLAnimatedItem` yet (TODO in
  CYLTabBarController). CYLTableViewPlaceHolder's own session migrates `CYLPlaceholderView` (its task `eb03683`).
- **Requirements**:
  1. Change the CocoaPods, Gradle / Maven and npm configuration as the guide says; the core code depends on the new
     component.
  2. Rework the core so that it shows the same animations through it.
  3. The core does not depend on an animation engine; animated icons show only when the example layer adds an engine.
  4. The components concerned: the packaged animated icon + title core components (CollectionViewClassifyMenu's
     `CYLTagButton` and this repository's search bar items built on it).
- **Plan**: (1) CollectionViewClassifyMenu: `CYLTagButton` subclasses `CYLAnimatedItemView` on iOS and Android; podspec
  `s.dependency 'CYLTabBarController/CYLAnimatedItem'`, Gradle dependency on the animated item module; examples add the
  engine subspecs / animation libraries. (2) This repository: pin CYLTabBarController `35aa757` and the new
  CollectionViewClassifyMenu commit; the core depends on `CYLTabBarController/CYLAnimatedItem` (no engine); the
  example's Podfile adds the engines it plays (SVGA and the others it uses); Android includes `:cylanimateditem`.
  (3) HarmonyOS and the mini program: blocked until CYLTabBarController ships the component there.
- **Prompt (verbatim)**: "https://github.com/ChenYilong/CYLTabBarController/blob/13e717c9/docs/Animated-Item.md 根据文档链接，根据该文档，修改cocoapods gradle maven npm等配置，要求更新core核心代码 ，依赖该新组件。改造core核心代码，要求实现同等动效效果。core核心代码不依赖于动效引擎，仅仅在example层引入动效引擎时才展示动效icon。涉及的组件为本仓库中已经封装好的动效icon加title的核心组件代码。"
- **Prompt (English)**: "Following the linked document, change the CocoaPods, Gradle, Maven, npm and similar
  configuration; update the core code to depend on the new component. Rework the core code to achieve the same
  animation effects. The core code does not depend on the animation engine; animated icons show only when the example
  layer adds the animation engine. The components concerned are this repository's packaged animated icon + title
  core components."
- **Guide link (user, 2026-11-17)**: "更新该文档地址 最新地址https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md"
  ("Update the document's address to the newest one: …"). The guide is linked on its branch, so it always shows the
  newest version: <https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md>.
- **Status**: done; the verification items below stay TODO. The guide's "Downstream migration status" row for this
  repository says it follows CollectionViewClassifyMenu (its search bar items subclass `CYLTagButton`); the commits are
  CollectionViewClassifyMenu `45101fb` (task log) and `1813025` (the migration), and this repository's checkpoint
  `31d8b8a` plus the commit after it.
- **Result**:
  - Pins: CollectionViewClassifyMenu `181302515f4c7dffa80fac349096d6593764a593` (`feat/harmony`: `CYLTagButton` subclasses
    `CYLAnimatedItemView`) in the `Podfile`, both CrossPlatform example Podfiles, `android/merged/gradle.properties`,
    `harmonyos/oh-package.json5` and the mini program `package.json`; CYLTabBarController
    `7511f7db2c9ada0da015e4b4e0f4c1bb94df8f93` (its branch tip; no code change since `35aa757`) in the `Podfile`, the
    Flutter example's Podfile and `pubspec.yaml` (`flutter_cyltabbar`, which compiles `cylanimateditem` since `09e782a`),
    `gradle.properties` (`cyl.tabbar.commit`, also the React Native checkout), HarmonyOS and the mini program.
    `harmonyos/scripts/sync-sub-repositories.py` and the mini program's `scripts/sync-example.js` ran at the new pins.
  - iOS core: the podspec depends on `CYLTabBarController/CYLAnimatedItem` (no engine) and on
    `CYLTableViewPlaceHolder/Core` instead of `CYLTableViewPlaceHolder/Lottie`, so the core carries no animation engine
    at all (it brought `lottie-ios` before). The example Podfiles add the engines they play: the root `Podfile`
    `CYLAnimatedItem`, `CYLAnimatedItemSVGA` (the SVGA demo tag) and `CYLAnimatedItemLottieSwift` next to the tab bar's
    subspecs, and `CYLTableViewPlaceHolder` `:subspecs => ['Core', 'Lottie']` (the animated placeholders); the Flutter
    example `CYLAnimatedItemSVGA` / `…Rive` and the placeholder's Lottie; the React Native example the placeholder's
    Lottie (its tab bar comes from the vendored CYLTabBarController with `Rive`). `scripts/pod-lint.sh lib` also checks
    out CYLTabBarController at the pinned commit for `--include-podspecs` (the subspec is in no trunk release). The bar
    item button (`CYLSearchBarItemButton`, a `CYLTagButton`) needed no code change: it sets `title`, `image`,
    `selectedImage`, `animationURL`, the badge and its accessibility, which are now the base class's or
    `CYLTagButton`'s overrides; `CYLTagButton`'s `updateItemAccessibility()` keeps the item's label and traits.
  - Android: `settings.gradle.kts` includes `:cylanimateditem` from the pinned CYLTabBarController checkout (`:cyltabbar`
    depends on it), and `build.gradle.kts` substitutes `io.github.chenyilong:cyltabbarcontroller-animateditem` (the
    coordinate CollectionViewClassifyMenu's library asks for) with it; the React Native and Flutter examples substitute
    it in their `includeBuild` of `android/merged` too. `cylsearch` no longer depends on `:placeholder-lottie`: the app
    adds it (and keeps SVGAPlayer), so the core has no animation library. `CYLSearchBarItemButton` passes
    `animationURL?.toString()` (the base class's `String?`) and keeps the item's TalkBack text through
    `accessibilityText()`.
  - Display priority (the component's, inherited): the animation when it can play; otherwise the static image; the
    component's placeholder, sized like the item's icon, only for an item with an animation file and no image; a text
    item never shows one. Documented in `README.md` ("Local CocoaPods component") and on `CYLSearchBarItem.animationURL`.
  - Tests: iOS `testSearchBarItemsFollowTheAnimatedItemDisplayPriority`, Android
    `CYLSearchBarItemTest.itemsFollowTheAnimatedItemDisplayPriority` (static image over placeholder, placeholder without
    an image, none for a text item); the existing item tests read `animationURL` as the base class's type on Android.
  - Checks run here: `scripts/check-public-api-comments.sh` OK; `android/merged/scripts/api-alignment.py` 100,
    `ios-alignment.mjs` (with `.cyl-deps/CollectionViewClassifyMenu` at `1813025`) 842 / 842 = 100,
    `harmonyos-api-alignment.py` 100, `harmonyos-scorecard.py` 100 (309 / 309), `miniprogram-api-alignment.py` 100;
    HarmonyOS host tests (`host-logic-test.mjs` 30 pass, `check-accessibility-i18n.mjs` 0 problems,
    `check-ios-parity.mjs` 397 / 397); mini program `npm test` 48 pass.
- **TODO (blocked upstream)**: HarmonyOS and the mini program. CYLTabBarController has no `CYLAnimatedItem` component
  there yet (the guide's TODO 3 and 4), so `harmonyos/cylsearch` and the mini program's `cyl-search-bar` keep the
  animated icon code of CollectionViewClassifyMenu's `CYLTagButton` ports; move them onto the component when it ships.
- **TODO (verification)**: no Xcode, Android SDK or DevEco here, so nothing was compiled or run: (1) `pod install`, the
  example build and analyzer, the unit tests and `scripts/pod-lint.sh lib` in iOS CI; (2) the Android build and tests
  (`./gradlew :cylsearch:testDebugUnitTest :app:assembleDebug`), including the `:cylanimateditem` substitution; (3)
  the React Native and Flutter Android builds: `react-native-cyltabbar` / `flutter_cyltabbar` compile
  `cylanimateditem`'s sources themselves, and `cylsearch` now brings the `:cylanimateditem` project through
  CollectionViewClassifyMenu, so check for duplicate `com.cyl.animateditem` / `com.cyl.tabbar` classes (if so, exclude
  `io.github.chenyilong:cyltabbarcontroller-animateditem` from the app's runtime classpath there); (4) screenshots of
  the SVGA demo tag and the animated placeholders against the previous ones.

## DONE (2026-11-17, pending CI): CYLAnimatedItem is its own pod and module

- **Context**: branch `feat/harmonyos-parity` (PR #11). The guide
  ([docs/Animated-Item.md](https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md))
  changed at `1f0fcce` (`c53d2899`): the component is the pod and module `CYLAnimatedItem`, with no dependency on
  CYLTabBarController (subspecs `Core`, `Engine`, `LottieObjectiveC`, `Lottie`, `LottieSwift`, `PAG`, `PAGEnterprise`,
  `Rive`, `SVGA`, `GIF`); Swift `import CYLAnimatedItem`, Objective-C `@import CYLAnimatedItem;` or
  `#import <CYLAnimatedItem/CYLAnimatedItemView.h>`; Android engine classes in `com.cyl.animateditem`. Until it is on
  the trunk, Podfiles name `pod 'CYLAnimatedItem'` by `:git` + `:commit`. CollectionViewClassifyMenu followed in
  `7183711`.
- **Requirements**: re-read the guide and adjust: the podspec depends on `CYLAnimatedItem` (no engine); the example
  takes its engines from `CYLAnimatedItem/<Type>`; pins CYLTabBarController `1f0fcce`, CollectionViewClassifyMenu
  `7183711`; lint includes the `CYLAnimatedItem` podspec.
- **Prompt (verbatim)**: "更新了该文档地址 最新地址https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md 文档更新了一些描述 请重新阅读 调整"
- **Prompt (English)**: "The document was updated, latest address …/docs/Animated-Item.md; some descriptions changed. Please
  read it again and adjust."
- **Status**: adjusted, pending CI (nothing compiles here: no Xcode, Android SDK or DevEco).
  - Podspec: `s.dependency 'CYLAnimatedItem'` (its default subspec `Core`: static images, no engine) instead of
    `CYLTabBarController/CYLAnimatedItem`.
  - `CYLSearchBarView.swift` imports `CYLAnimatedItem` where the module exists (CocoaPods); Swift Package Manager still
    compiles the component into CYLTabBarController and reaches it through CollectionViewClassifyMenu.
  - Example Podfile: `pod 'CYLAnimatedItem', :subspecs => ['Core', 'SVGA', 'LottieSwift']` by `:git` + `:commit`;
    CYLTabBarController keeps only its own subspecs (`Core`, `SVGA`, `CYLFlatDesignTabBar`). Flutter example: the
    `CYLAnimatedItem` pod with `SVGA` and `Rive`; React Native example: `pod 'CYLAnimatedItem'` from the same vendored
    checkout as CYLTabBarController.
  - Tests: `#import <CYLAnimatedItem/CYLAnimatedItemView.h>`.
  - `scripts/pod-lint.sh lib` checks out `CYLAnimatedItem` (CYLTabBarController's repository at the pinned commit)
    instead of CYLTabBarController: neither this podspec nor CollectionViewClassifyMenu's depends on the tab bar any
    more.
  - Pins: CYLTabBarController `1f0fcce` (Podfiles, Gradle, ohpm, npm, pub), CollectionViewClassifyMenu `7183711`.
  - Android: CollectionViewClassifyMenu's `CYLTagButton` imports from `com.cyl.animateditem`; `cylsearch` imports
    nothing from `com.cyl.tabbar`, so it needed no change.
  - Parity tables regenerated (descriptions only, all at 100); HarmonyOS scorecard 309/309.
  - Still TODO, as before: HarmonyOS and the mini program wait for the component upstream (guide TODO 5); the
    CYLTableViewPlaceHolder pin `f488e2f` predates its own migration.
- **Pins moved again** (2026-11-17): CYLTabBarController `fbd05d5` (PR #814: `CYLAnimatedItem.podspec` defines its
  module; the Lottie animator takes no file Lottie cannot play) and CollectionViewClassifyMenu `98182e8` (static-library
  Podfiles, test wait, the same pin). Pending CI.

## DONE (2026-11-17): the guide re-read at `caf0a38` / `ee106e8`

- **Prompt (verbatim)**: "我已更新了该文档地址 最新地址https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md 文档更新了一些描述 请重新阅读 调整"
- **Prompt (English)**: "I updated the document, latest address …/docs/Animated-Item.md; some descriptions changed. Please read
  it again and adjust."
- **What changed in the guide** since `1f0fcce`: the text now describes the `CYLAnimatedItem` pod throughout
  (`b53011f`); per-type animation guards in `CYLAnimatedItem/Core` (`d1c2418`); type keys compile without their
  engine and fall back to the static image (`caf0a38`); subclasses guard engine-only API (`animationPlayer`,
  `animationSource`) with `CYL_ANIMATION_ENGINE_AVAILABLE`; downstream rows: `pod 'CYLAnimatedItem'` plus
  `CYLAnimatedItem/<Type>`, `import CYLAnimatedItem`, Android `com.cyl.animateditem`.
- **Result**: already followed, no code change. The core uses only API declared without an engine
  (`animationURL`, `playAnimation`, the hooks) and checks the engine at run time; tests read `animationPlayer` by key.
- **Pin kept at `fbd05d5`, not the branch tip `ee106e8`** (05:18 UTC, "license notice in every published package"):
  the tip does not contain PR #814 (`CYLAnimatedItem.podspec` `DEFINES_MODULE`, no Lottie view for an unplayable
  file), so pinning it would bring back two CI failures. TODO: move the pin to the branch once PR #814 is merged into
  it.

## DONE (2026-11-17): the guide re-read at `ec12a9d`

- **Prompt (verbatim)**: "我已经更新了该文档地址 最新地址https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md 文档更新了一些描述 请重新阅读 调整"
- **Prompt (English)**: "I updated the document, latest address …/docs/Animated-Item.md; some descriptions changed. Please read
  it again and adjust."
- **What changed** (`ec12a9d`, after `ee106e8`): the resources paragraph names each platform's license location
  (iOS `CYLAnimatedItem.bundle/LICENSE`, Android `META-INF/cylanimateditem/LICENSE` in the AAR); the commit list adds
  the per-type guards (`CYL_LOTTIE_AVAILABLE`, `CYL_GIF_AVAILABLE`, `CYL_PAG_AVAILABLE`, `CYL_RIVE_AVAILABLE`,
  `CYL_SVGA_AVAILABLE`), the engine-free type keys and "a license notice in every published package"; the iOS CI
  status (run 839 on `caf0a38`: Carthage, the root Podfile with `pod 'CYLAnimatedItem'` and Example-Swift-03 passed).
- **Adjusted**: the license layout follows the same rule as CYLTabBarController: the Android library's license and
  icon notices moved from `assets/CYLSearchViewController.bundle/` to `src/main/resources/META-INF/cylsearch/` (inside
  the AAR), and the mini program's component folder gets `src/LICENSE` (`docs/licenses.md`). The animated item code
  needed no change: it uses no type key or engine-only API.
- **Pin**: still `fbd05d5`; the branch tip `ec12a9d` does not contain PR #814 yet.
- **Pin update** (2026-11-17): CollectionViewClassifyMenu `98182e8` → `4622434` (its newest commit: MIT license in
  every package, `d0c82cb` / `f752b6c`; CYLTabBarController pins back at `fbd05d5` until PR #814 is merged, recorded in
  its AGENTS.md). CYLTabBarController stays `fbd05d5` here too.
- **PR #814 merged** (2026-11-17): the owner merged it into `feat/cross-platform-components` (PR #788, `9a54e26`), so
  CYLTabBarController moves from `fbd05d5` to `9a54e26`, the branch tip, and CollectionViewClassifyMenu to `6ee254c`
  (the same pin). `47aec88` (engine report, on the merged PR's branch, not in #788) waits until it is merged.
- **Pin settled** (2026-11-17): the owner chose `9a54e26` (the #788 merge) over `47aec88` (a newer commit on the
  merged PR #814 branch). CollectionViewClassifyMenu `3ccf775` pins it again; this repository pins CollectionViewClassifyMenu
  `3ccf775`. The rule (a merged pull request branch does not count) is in AGENTS.md, instructions.md and the
  `cyl-tabbar-integration` skill.
- **Pin `0a63bed`** (2026-11-17): CYLTabBarController moves to the #788 tip `0a63bed` (engine report, license notices,
  both #814 fixes kept); CollectionViewClassifyMenu to `edba997` (the same pin).

## DONE (2026-11-17): the guide re-read at `0a63bed`

- **Prompt (verbatim)**: "我已经更新了该文档地址 最新地址https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md 文档更新了一些描述 请重新阅读 调整"
- **Prompt (English)**: "I updated the document, latest address …/docs/Animated-Item.md; some descriptions changed. Please read
  it again and adjust."
- **What changed**: the guide records the two CYLAnimatedItem bugs found by CollectionViewClassifyMenu's CI as fixed in
  CYLTabBarController's core (`DEFINES_MODULE` in `CYLAnimatedItem.podspec`; the Lottie animator takes only a Lottie
  document) and updates failure case (4) to match; the branch tip is still `0a63bed`, already pinned.
- **Adjusted**: nothing in this repository needed the module workaround (its Podfiles build frameworks).
  CollectionViewClassifyMenu dropped its `:modular_headers` workaround (`4171135`), pinned here. Pending CI.
- **Pin** (2026-11-17): CollectionViewClassifyMenu `b4d0e51` (its example's engine report; no core change).
- **Pins** (2026-11-17): CYLTabBarController `d875dd1` (#788 tip: remote GIF/PAG downloads, late-failure fallback); CollectionViewClassifyMenu `320c3eb` (re-export of `CYLAnimatedItem`, the Android menu buttons and filter header on `CYLTagButton`, the same pin).
- **CI on `15a6144`** (run 44027141867): `pod lib lint` passes. The example build and the unit tests failed on one line:
  `CYLSearchExampleAppDelegate.m` imported `<CYLTabBarController/CYLSVGATabBarItemAnimator.h>`, a header that moved to
  the `CYLAnimatedItem` pod (`CYLAnimatedItem/SVGA`). Example-only: the core has no such import; the example now
  imports `<CYLAnimatedItem/CYLSVGATabBarItemAnimator.h>`. Pending CI.

## TODO (2026-11-17): the guide re-read at `57a527e`: CYLAnimatedItem on HarmonyOS and the mini program

- **Context**: CYLTabBarController `842aef8` adds the component on HarmonyOS (ohpm module
  `CrossPlatform/harmonyos-cyltabbar/cylanimateditem`, `CYLAnimatedItemView`, engines registered by the app with
  `CYLAnimatedItemEngines.register(...)` and an `animationBuilder`, no animation library in the module) and on the WeChat
  mini program (`src/cyl-animated-item` in cyl-tabbar-miniprogram, engines as abstract nodes `cyl-lottie-view` and its
  siblings, GIF through `<image>`). Unpublished: taken by commit (HarmonyOS `file:` or a copy of the folder at the pinned
  commit; mini program `github:ChenYilong/CYLTabBarController#<sha>` or a copy of `src/cyl-animated-item`). `57a527e`
  fixes the iOS umbrella header (animator headers) and an accessory test. Pins move to `57a527e`.
- **Requirements**: re-read the guide and adjust; import unreleased components by commit; do not block progress; the core
  depends on no animation engine, only the examples add engines; every platform.
- **Prompt (verbatim)**: "我已经更新了该文档地址 最新地址https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md 文档更新了一些描述 请重新阅读 调整"
- **Prompt (English)**: "I updated the document, latest address …/docs/Animated-Item.md; some descriptions changed. Please read it
  again and adjust."
- **Status**: started. Pins `57a527e`; HarmonyOS and mini program migrations next (not buildable here: no DevEco, no WeChat
  DevTools).
- **Pin** (2026-11-17): CollectionViewClassifyMenu `71562ca` (HarmonyOS `CYLTagButton` on `cylanimateditem`, mini program tags on `cyl-animated-item`, both by commit `57a527e`). The HarmonyOS vendor copy and the mini program search bar follow next.
- **Status** (2026-11-17, HarmonyOS and mini program on the pinned CollectionViewClassifyMenu `71562ca`): done in code, not
  compiled or run (no DevEco Studio, no WeChat DevTools here), so the heading stays `TODO`.
  - **How the component arrives, by commit.** Both platforms take CYLTabBarController's component through
    CollectionViewClassifyMenu's vendored copy at `57a527e` (checked here: the same files as CYLTabBarController
    `57a527e`, plus ClassifyMenu's `README.md` / `COMMIT` / `LICENSE`).
    - HarmonyOS: `harmonyos/scripts/sync-sub-repositories.py` now also copies ClassifyMenu `harmony/cylanimateditem`
      (at `collectionViewClassifyMenuCommit`) into `harmonyos/vendor/cylanimateditem`, next to `vendor/classifymenu`,
      so the vendored `"cylanimateditem": "file:../cylanimateditem"` resolves; `harmonyos/build-profile.json5`
      registers the module. `cylsearch` still depends only on `cylplaceholder` and `@cyl/classifymenu`: no animation
      library. The example `harmonyos/entry` registers the engines (`cylRegisterExampleAnimationEngines()` in
      `EntryAbility.onCreate`: `CYLAnimatedItemEngines.register('Lottie' | 'PAG' | 'Rive' | 'SVGA' | 'GIF')` and
      `CYLTagAnimationBuilder.register(...)`) with the players and views ported unchanged from ClassifyMenu's example
      (`entry/src/main/ets/animation/`, SVGA decoder included), and adds `@ohos/lottie`, `@tencent/libpag` (4.5.102,
      the root override) and `@ohos/rive` to its own `oh-package.json5`.
    - Mini program: `scripts/sync-example.js` copies ClassifyMenu's `cyl-tag-list-miniprogram/miniprogram_dist`, which
      now holds `cyl-animated-item` (with its `COMMIT` = `57a527e` and `LICENSE`) and `cyl-animation-placeholder`; the
      script fails when either is missing. `src/cyl-search-bar` declares the abstract nodes `cyl-lottie-view`,
      `cyl-pag-view`, `cyl-rive-view`, `cyl-svga-view` (default: ClassifyMenu's `cyl-animation-placeholder`) and
      forwards them to `cyl-tag-button`; `src/cyl-search` declares and forwards them to its `cyl-search-bar`s. The
      package links no engine. Every search bar of the example passes `generic:cyl-lottie-view="cyl-lottie"` and
      `generic:cyl-svga-view="cyl-svga"` (CYLTabBarController's players, already installed for the tab bar) and the
      placeholder for PAG and Rive (the example installs no PAG or Rive player).
  - **API.** HarmonyOS `CYLSearchBarView` / `CYLSearchBarItem` unchanged: the fields it sets on `CYLTagButton`
    (`image`, `selectedImage`, `animationURL`, `style.animationSize`, badge, `playAnimation()`) are unchanged at `71562ca`.
    One behavior change from ClassifyMenu: while the animation loads (or with no engine registered), the static image
    under it is the item's `image` when it is a resource or a path; a system symbol cannot be drawn there, so the
    component's placeholder shows. Mini program: added the four abstract nodes on `cyl-search-bar` and `cyl-search`.
  - **Checks.** Mini program `npm test`: 51 of 51 (3 new tests: the slots are declared and forwarded, the synced
    `cyl-animated-item` is at the pinned commit, every example search bar passes its engines);
    `node harmonyos/scripts/host-logic-test.mjs` 30 of 30; `check-ios-parity.mjs` 397 match;
    `check-accessibility-i18n.mjs` 0 problems; `harmonyos-scorecard.py` 100/100; `miniprogram-api-alignment.py`
    100/100 (no change); `check-licenses.sh` OK; `check-public-api-comments.sh` OK.
  - **TODO.** Build the HAP with DevEco Studio (ohpm install of the `file:` modules and the three animation libraries;
    `PAGFile.LoadFromAssets` and the Rive view against `@tencent/libpag` 4.5.102 and `@ohos/rive` 1.0.4) and run the
    ohosTest suite on the emulator; run the mini program in WeChat DevTools and check an animated search bar item
    (SVGA / Lottie) plays on tap and falls back to its image; screenshots for both (AGENTS.md, "Screenshots").
