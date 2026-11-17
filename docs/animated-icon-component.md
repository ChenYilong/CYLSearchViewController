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
- **Status (2026-11-17)**: step 1 DONE, step 2 DONE on iOS and Android (TODO on HarmonyOS and the mini program, waiting
  for CollectionViewClassifyMenu, below), step 3 TODO. Nothing is compiled or run here (no Xcode, no Android SDK, no
  DevEco Studio): see "Unverified".

### Step 1: DONE (2026-11-17), CollectionViewClassifyMenu `1e43253` + `a0c8232`

- `CYLTagButton` gained a badge (`badgeValue`, `badgeColor`, `badgeLabel`), the icon above or below the title
  (`CYLTagImagePlacement.top` / `.bottom`), `height(forTitle:iconSize:style:traitCollection:)` and the standalone
  initializers `init(title:image:)` / `init(title:image:animationURL:)`, on iOS, Android, HarmonyOS and the mini program
  (`cyl-tag-button`), branch `feat/harmony`.
- Pinned here at `a0c82323c60eebc4d870a10293cf2a5dcba84d2b`: `Podfile`, the React Native and Flutter example
  Podfiles, `android/merged/gradle.properties` (`cyl.classifymenu.commit`; `.cyl-deps` checked out at it). HarmonyOS
  and the mini program do not depend on CollectionViewClassifyMenu yet (no pin to change).

### Step 2: DONE on iOS and Android (2026-11-17); TODO on HarmonyOS and the mini program

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
- TODO, HarmonyOS (`harmonyos/cylsearch`, and the example's SVGA header, `CYLSVGAView` of cyltabbar): waits for
  CollectionViewClassifyMenu's ArkTS `CYLTagButton`, which cannot draw a bar item yet:
  1. it draws its icon with `Image`, which does not draw the items' system symbols (`$r('sys.symbol.camera')`,
     drawn with `SymbolGlyph` today);
  2. its colors are strings, while the items use theme colors (`ResourceColor`, `$r('sys.color.font_primary')`)
     that follow the color mode;
  3. `CYLTagButtonComponent` is a V1 `@Component` with an `@ObjectLink`; the bar is a V2 `@ComponentV2`, and passing
     the model across needs a check in DevEco Studio;
  4. adding it as a sub-repository here (`harmonyos/scripts/sync-sub-repositories.py`, `oh-package.json5`) pulls
     `@ohos/lottie 2.0.38` and `@tencent/libpag 4.4.31` next to cylplaceholder's `2.0.28` / `4.5.102`.
  Until then `CYLSearchBarItem.animationURL` is TODO in `docs/harmonyos-api-alignment.md` (score 99).
- TODO, mini program (`src/cyl-search-bar`): waits for CollectionViewClassifyMenu's `cyl-tag-button`, whose tag box
  cannot be transparent (`opaqueBackground` turns `transparent` and alpha 0 into `#F2F2F7`), so the items would sit
  on gray boxes inside the field. Then: add `cyl-tag-list-miniprogram` as an optional peer dependency (as
  `cyl-placeholder-miniprogram`), install it in `scripts/sync-example.js` at the pinned commit, and draw each item
  with `<cyl-tag-button>`. Until then `CYLSearchBarItem.animationURL` is TODO in `docs/miniprogram-api-alignment.md`
  (score 99).

### TODO (2026-11-17): step 2 on HarmonyOS and the mini program

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
- **Status**: started.

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
- Checks run here: the parity generators (Android 100, iOS 100, HarmonyOS 99, mini program 99: the `animationURL`
  rows above), `check-public-api-comments.sh`, the HarmonyOS host logic, iOS parity and accessibility checks, the mini
  program `npm test`.
