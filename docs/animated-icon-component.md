# Animated Icon Component (CYLTagButton)

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

## TODO (2026-11-17): CYLAnimatedItem is its own pod and module

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
- **Status**: started.
