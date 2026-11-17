# HarmonyOS (cross-platform)

The search core on every platform is CYLSearchBar ([search-core-merge.md](search-core-merge.md); HarmonyOS exports in `harmonyos/cylsearch/Index.ets`): four public
classes, `CYLSearchBarView` (with `mode` single or multiple), `CYLSearchBarItem`, `CYLSearchView` (suggestions,
results, empty placeholders, the only refresh API) and `CYLSearchResources`. iOS `Sources/CYLSearchBar`; Android
`android/merged/cylsearch` (`CYLSearchBarView.kt`, `CYLSearchView.kt`, `CYLSearchResources.kt`, refresh from
CYLTableViewPlaceHolder's `:placeholder-refresh`); HarmonyOS `harmonyos/cylsearch` (`.ets`, the same three files);
mini program components `cyl-search-bar` and `cyl-search`; React Native components `CYLSearchBarView` and `CYLSearchView`
on the native cores. Flutter is moving to the merged core (in progress). Dated task entries below record the work in their own time and name the classes of that time.

The HarmonyOS port of CYLSearchViewController: the ArkTS library `harmonyos/cylsearch` and the example app
`harmonyos/entry`. Other platforms: [android-and-cross-platform.md](android-and-cross-platform.md).

## HarmonyOS version

| Item | Version |
| :--- | :--- |
| System | HarmonyOS NEXT, target HarmonyOS 6.0.1 (API 21), compatible from HarmonyOS 6.0.1 (API 21; the minimum of CYLTableViewPlaceHolder's cylplaceholder) (`harmonyos/build-profile.json5`) |
| Language and UI | ArkTS, ArkUI state management V2 (`@ComponentV2`) |
| IDE and SDK | DevEco Studio 6.0.1 with its bundled SDK (API 21), hvigor, ohpm |
| Run | Huawei emulator (Mate 70 Pro, HarmonyOS 6.0.1, API 21); unsigned HAP installed with `hdc install` |

## DONE in code (2026-11-16; TODO 2026-11-16): Scorecard 3, issues seen in the emulator screenshots (screenshot checks pending)

- Prompt (verbatim): "我已经更新了鸿蒙代码在模拟器上的截图 并更新了鸿蒙相关文档，请查看当前代码的运行截图，识别出截图中存在的问题 。给出issues猎鸟，每发现一个问题就新增一行，第二列写修复工作状态默认填TODO，给出打分机制，这个表格没有TODO 为满分，在没有模拟器的前提下修复issues，我会在你全部修复好后统一运行截图。每次修复一个issue就更新TODO为 TODO need 模拟器截图验证，更新所有TODO后视为满分。一直修复到满分为止。记录所有异常 不限于本仓库的异常，其他仓库的异常也一并列出。比如 tabbar 的badge为文字的时候，文字显示异常，NEW字样 无法一行显示，被换行了。疑似是badge大小未根据字体大小 字体做大小适配拉伸，怀疑是写死了badge的大小。需要根据label文字适配badge大小，参考android与I iOS端实现。 icon 与title y轴放点中心线未对齐。类似的issue也都要列出。"
- Prompt (English): "I updated the screenshots of the HarmonyOS code on the emulator and the HarmonyOS documents. Look at the
  screenshots of the current code and find the problems in them. Give an issue list: one row per problem, the second
  column the fix status, `TODO` by default; give a scoring rule: no `TODO` in the table is a full score. Fix the issues
  without an emulator; I will take all the screenshots once everything is fixed. Each time an issue is fixed, change its
  `TODO` to `TODO need 模拟器截图验证` (needs an emulator screenshot to verify); with every `TODO` updated the score is
  full. Keep fixing until the score is full. Record every problem, not only in this repository: list other
  repositories' problems too. For example, when a tab bar badge is text, the text is wrong: `NEW` does not fit on one
  line and wraps, probably because the badge size does not follow the font and the text (a fixed badge size); the badge
  must size itself to its label, as on Android and iOS. The icon and the title are not aligned on the vertical center
  line. List every similar issue."
- Screenshots read (2026-11-16): `docs/assets/harmonyos-examples-emulator-unsigned.jpeg` (Examples tab, emulator time
  07:36, today); `harmonyos-discover-emulator-unsigned.jpeg` and `harmonyos-search-empty-cache-emulator-unsigned.jpeg`
  (2026-11-15, before the example was rebuilt 1:1 with iOS in `940db01`); CYLTabBarController
  `docs/assets/harmonyos-tab-bar-svga-launch.png` and `harmonyos-tab-bar-svga-messages-tap.png` (branch
  `feat/harmonyos-svga`); and the text badge described by the user (no screenshot in the repositories).
- Scoring: Score = rows whose status is not `TODO` / all rows × 100. `TODO need 模拟器截图验证` (fixed in code, waiting
  for the user's emulator screenshot) counts as not `TODO`; `DONE` once the screenshot confirms it.

| # | Status | Repository | Seen in | Issue | Cause found in the code | Fix |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | DONE (verified on the emulator in CYLTabBarController's demo: its `scripts/harmonyos-issues.json` #1 is DONE at `b2ec2f3`, the commit pinned here, with `harmonyos-verify-home-eba8c44.jpeg`; Mate 70 Pro emulator, HarmonyOS 6.0.1 (API 21), 2026-11-16) | CYLTabBarController (`harmonyos-cyltabbar`) | user report | A text badge (`NEW`) wraps to two lines: the badge does not size itself to its text | `CYLBadgeView`: the `Text` has no `maxLines(1)` and no width from its text; positioned inside the narrow icon box, it takes the box's width limit and wraps (iOS and Android measure the label and grow the badge) | Upstream CYLTabBarController `127b8ae8` / `16a19bbf` (in `9fb874c`, pinned): one line, the measured badge width (`cylTextBadgeWidth()`). My duplicate PR #801 was closed. Second review: CYLTabBarController `harmonyos-home-mate70pro-api21.jpeg` still shows `NE` / `W`, but it was taken at 13:54, before `127b8ae8` (13:56) and `16a19bbf` (14:01): re-check on a new screenshot; see row 12 |
| 2 | DONE (verified in CYLTabBarController `docs/assets/harmonyos-port-svga-demo-taps.png`, emulator: every SVGA icon centred over its title, measured −2 to +1.5 px) | CYLTabBarController (`harmonyos-cyltabbar`) | `harmonyos-tab-bar-svga-launch.png` | The icon is not centered over its title (on the vertical center line): every animated icon sits about 6 vp right of its title | `cylTab`: the icon `Stack` is `imageSize` wide with `alignContent(TopStart)`; an SVGA / Lottie icon of `svgaSize` / `lottieSize` larger than `imageSize` overflows to the right | Upstream `127b8ae8` / `16a19bbf` (in `9fb874c`, pinned): the icon box follows the drawn icon (`cylIconHeight`); measured −2 to +1.5 px on the Mate 70 Pro emulator by the CYLTabBarController session (its `docs/SVGA-Animation.md`). The screenshots read here came from its deleted `HarmonyOS/` demo |
| 3 | DONE (verified in `docs/assets/harmonyos-search-tab-cyltabbar-emulator-unsigned.jpeg`: `搜索栏` on the same line as the tab titles) | CYLTabBarController (`harmonyos-cyltabbar`) | both tab bar screenshots, `harmonyos-examples-emulator-unsigned.jpeg` | The plus button's title sits lower than the other tab titles (`发布`, `搜索栏`) | `cylPlus`: the title is at a fixed `y = tabBarHeight - 17`, while the other titles are centered with their icon in the column (`(tabBarHeight - imageSize - 3 - 13) / 2 + imageSize + 3`) | Upstream `127b8ae8` / `16a19bbf` (in `9fb874c`, pinned): tab titles and the plus title share one top (`tabBarHeight - 17`) |
| 4 | DONE (verified on the emulator in CYLTabBarController's demo: its `scripts/harmonyos-issues.json` #25 is DONE at `b2ec2f3`, the commit pinned here, with `harmonyos-verify-home-eba8c44.jpeg`; Mate 70 Pro emulator, HarmonyOS 6.0.1 (API 21), 2026-11-16) | CYLTabBarController (`harmonyos-cyltabbar`) | `harmonyos-tab-bar-svga-messages-tap.png` | The badge sits on the icon's right edge for a number but the red dot is far to the right of the icon: the badge position does not follow the icon's real size | `CYLBadgeView` is anchored at `anchorWidth = imageSize`, not at the drawn icon size (row 2) | Upstream `16a19bbf` (in `9fb874c`, pinned): the badge anchors to the drawn icon (`anchorWidth: cylIconHeight(index)`) |
| 5 | DONE (verified in `harmonyos-search-tab-cyltabbar-emulator-unsigned.jpeg`: the raised blue plus button) | CYLSearchViewController (`harmonyos/entry`) | `harmonyos-examples-emulator-unsigned.jpeg` | The plus button is a small grey circle inside the bar; on iOS (and its mini program copy) it is a raised blue button (AGENTS.md: examples prefer the raised plus button) | `pages/Index.ets` gives the plus button `imageSize: 30`; `tab_plus_circle_fill_normal.svg` is grey | `imageSize: 56` in `pages/Index.ets` (with an aligned title the image sits right above the title, so its top rises above the bar); `tab_plus_circle_fill_normal.svg` and `_selected.svg` blue, the circle filling the 24 x 24 box as in the mini program copy |
| 6 | DONE (`assets/harmonyos-mate70pro-api21-20261117-examples-card.jpeg`: the card ends after its four rows; Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), cyltabbar `b2ec2f3`, 2026-11-17 06:14 emulator time (UTC+8)) | CYLSearchViewController (`harmonyos/entry`) | `harmonyos-examples-emulator-unsigned.jpeg` | The Examples card (white, rounded) runs down to the tab bar instead of ending after its four rows, as the iOS inset grouped list does | `ExamplesMenu.ets`: the `List` has `layoutWeight(1)` | `List` `.height('auto').flexShrink(1)` instead of `layoutWeight(1)`: the card ends after its last row and scrolls only when the rows do not fit |
| 7 | DONE (`assets/harmonyos-mate70pro-api21-20261117-placeholder-above-keyboard.jpeg`: with the keyboard up, the empty placeholder is centered in the space above it, from the core fix in `CYLSearchComponent`; Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), cyltabbar `b2ec2f3`, 2026-11-17 06:10 emulator time (UTC+8)) | CYLSearchViewController (`harmonyos/entry`) | `harmonyos-search-empty-cache-emulator-unsigned.jpeg` | The empty placeholder is centered in the whole page, so the keyboard covers its lower part ("暂无数据" touches the keyboard) | The window does not resize for the keyboard (`KeyboardAvoidMode.OFFSET` by default), so the page keeps its full height under the keyboard | Moved to the core on 2026-11-17: `CYLSearchComponent` (`harmonyos/cylsearch`) pads the area under the search bar by the part of the keyboard that covers it (`keyboardHeightChange`), so placeholders center above the keyboard in any app; the example's `KeyboardAvoidMode.RESIZE` is removed |
| 8 | DONE (verified in `harmonyos-search-tab-cyltabbar-emulator-unsigned.jpeg`: tag and sparkle magnifying glass icons) | CYLSearchViewController (`harmonyos/entry`) | `harmonyos-examples-emulator-unsigned.jpeg` | The Tag style and Discover tab icons are a bookmark and a star, not iOS's `tag` and `sparkle.magnifyingglass` | The current `tab_tag_*.svg` draw a tag and `tab_sparkle_magnifyingglass_*.svg` a magnifying glass: the screenshot came from an older build. The magnifying glass has a plus inside, not iOS's sparkle | `tab_sparkle_magnifyingglass_normal.svg` / `_selected.svg`: a four-point sparkle in the lens instead of a plus, as `sparkle.magnifyingglass`; the tag icons were already right |
| 9 | DONE (`assets/harmonyos-mate70pro-api21-20261117-discover.jpeg`: the tab bar shows, recent searches in Chinese, a placeholder in the search field; Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), cyltabbar `b2ec2f3`, 2026-11-17 06:14 emulator time (UTC+8)) | CYLSearchViewController (`harmonyos/entry`) | `harmonyos-discover-emulator-unsigned.jpeg` (2026-11-15) | Discover: no tab bar; recent searches in English in a Chinese UI; empty search field; no discover topics; "打开搜索" where iOS has the trash button | Not in the current code: Discover is a tab page of `CYLTabBarController` since `940db01`, reads `rawfile/discover/zh_CN.json`, takes the first topic as the placeholder, shows the topics and the trash header button | No change needed: the current code already behaves as iOS (see the cause); a new screenshot verifies it |
| 10 | DONE (`assets/harmonyos-mate70pro-api21-20261117-search-list-end.jpeg`: the last row, 示例结果 40, scrolls fully clear of the raised plus button; Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), CYLSearchViewController after `709f481`, cyltabbar `b2ec2f3`, 2026-11-17 05:5x emulator time (UTC+8)) | CYLSearchViewController (`harmonyos/entry`) | `harmonyos-search-tab-cyltabbar-emulator-unsigned.jpeg` (09:24) | The raised plus button covers page content: the last visible row (`示例结果 14`) runs behind the plus button (AGENTS.md: the raised plus button never covers the page content above the bar) | The tab pages end at the top of the bar, but the plus button rises 24 vp above it (`imageSize` 56 over a 32 vp image area); nothing reserves that space | `pages/Index.ets`: each tab page gets `padding({ bottom: plusOverhang() })`, the 24 vp the plus button rises above the bar (`imageSize` 56 - (49 - 17)), so it ends above the plus button |
| 11 | DONE (verified on the emulator in CYLTabBarController's demo: its `scripts/harmonyos-issues.json` #15 is DONE at `b2ec2f3`, the commit pinned here, with `harmonyos-verify-home-end-eba8c44.jpeg`; Mate 70 Pro emulator, HarmonyOS 6.0.1 (API 21), 2026-11-16) | CYLTabBarController (`harmonyos-cyltabbar`) | `harmonyos-home-mate70pro-api21.jpeg` | The same in the CYLTabBarController demo: the plus button, its badge and the `99+` badge cover the last row (`设置 CYLFlatDesignTa…m 背景`) | The page area does not reserve the space of what rises above the bar | Fixed upstream in code: CYLTabBarController `scripts/harmonyos-issues.json` #15 ("The demo list has no bottom inset", status `TODO need 模拟器截图验证`) |
| 12 | DONE (verified on the emulator in CYLTabBarController's demo: its `scripts/harmonyos-issues.json` #19 is DONE at `b2ec2f3`, the commit pinned here, with `harmonyos-verify-home-end-eba8c44.jpeg`; Mate 70 Pro emulator, HarmonyOS 6.0.1 (API 21), 2026-11-16) | CYLTabBarController (`harmonyos-cyltabbar`) | code review of `CYLBadge.ets` (`9fb874c`) | A text badge with a border clips its text: the measured width is text + margin, but the border is drawn inside the width | `cylTextBadgeWidth()` leaves out `borderWidth` (the demo has a "Border" badge option) | CYLTabBarController PR #805 merged, in `3ddb96c` (pinned): `cylTextBadgeWidth()` adds `borderWidth` on both sides (checked in the code) |
| 13 | DONE (verified on the emulator in CYLTabBarController's demo: its `scripts/harmonyos-issues.json` #20 is DONE at `b2ec2f3`, the commit pinned here, with `harmonyos-verify-l10n-mate70pro-api21.png`; Mate 70 Pro emulator, HarmonyOS 6.0.1 (API 21), 2026-11-16) | CYLTabBarController (`harmonyos-cyltabbar`) | `harmonyos-home-mate70pro-api21.jpeg`; `cyltabbar/src/main/resources/*/element/string.json` (`9fb874c`) | Demo texts in English in a non-English UI: 27 to 29 sentences per language are copies of the English text (de, fr, es, ar, ko, ja, and the others; zh_TW 7), for example "A tab bar controller of another context, with a square plus button" | The 30 language files were filled with the English text where no translation existed | CYLTabBarController `3ddb96c` (pinned): all 46 HarmonyOS-only keys translated in 33 languages (its issue #20, `harmonyos-l10n.py --check` passes). Checked here: de, fr, es keep only the two "Liquid Glass" entries (a name) in English; ar, ko, ja, zh_TW none |
| 14 | DONE (verified on the emulator in CYLTabBarController's demo: its `scripts/harmonyos-issues.json` #3 is DONE at `b2ec2f3`, the commit pinned here, with `harmonyos-verify-home-eba8c44.jpeg`; Mate 70 Pro emulator, HarmonyOS 6.0.1 (API 21), 2026-11-16) | CYLTabBarController (demo `entry`) | `harmonyos-home-mate70pro-api21.jpeg` (13:54) | The navigation bar buttons (`扁平样式 ●`, `液态玻璃`, `换肤`) sit above the centre line of the title `首页` | Fixed upstream after the screenshot ("nav bar centre line", `16a19bbf`, 14:01) | Upstream `16a19bbf` (in the pinned `9fb874c`); re-check on a new screenshot |
| 15 | DONE (verified on the emulator in CYLTabBarController's demo: its `scripts/harmonyos-issues.json` #5 is DONE at `b2ec2f3`, the commit pinned here, with `harmonyos-verify-home-eba8c44.jpeg`; Mate 70 Pro emulator, HarmonyOS 6.0.1 (API 21), 2026-11-16) | CYLTabBarController (demo `entry`) | `harmonyos-home-mate70pro-api21.jpeg` (13:54) | English subtitles in the Chinese UI ("tabBarHidden = false; hidden, it comes back after 2 s", "cyl_tabBarMinimizeBehavior = Never; tap to choose, then scroll this list") | zh_CN had no translation when the screenshot was taken | Upstream `16a19bbf` translated them (zh_CN: "tabBarHidden = %@；隐藏后 2 秒自动恢复"; no English sentence left in zh_CN); other languages: row 13 |
| 16 | DONE (`aa start … --pi CYLDemoTab 3` opens the Tag style tab: `assets/harmonyos-mate70pro-api21-20261117-cyldemotab3-tag-style.jpeg`; Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), CYLSearchViewController after `709f481`, cyltabbar `b2ec2f3`, 2026-11-17 05:5x emulator time (UTC+8)) | CYLSearchViewController (`harmonyos/entry`) | BUG TODO in `docs/android-and-cross-platform.md` (`4ae57b6`) | The launch parameter `--pi CYLDemoTab <n>` does not select a tab | Nothing copied `want.parameters` into AppStorage: `pages/Index.ets` read `AppStorage.get('CYLDemoTab')`, which no code ever set (since `dcaf837`) | `EntryAbility` stores it in `onCreate` and `onNewWant`; `Index` watches it (`@StorageLink` + `@Watch`). Emulator check: it worked, but 3 opened Discover; it now counts like iOS `viewControllers`, the plus page in its slot (0 Search, 1 Examples, 2 plus page, 3 Tag style, 4 Discover) |
| 17 | DONE (verified on the emulator 127.0.0.1:5557 by the CYLTabBarController session, build `962681e` with cyltabbar `3ddb96c`: tabs, rows and "Overlay" respond; dumpLayout shows the tab itself on top) | CYLSearchViewController (`harmonyos/entry`) with CYLTabBarController `9fb874c` | BUG TODO in `docs/android-and-cross-platform.md` (`4ae57b6`) | The example ignores every touch (tab bar, "Overlay", result rows; `uitest uiInput click`, `uinput`), while touch works elsewhere on the emulator | Not found in the code. Ruled out by reading: no dialog, sub-window, `setWindowTouchable`, `HitTestMode.Block` or `enabled(false)` in the app, `cylsearch` or `cyltabbar`; hidden tab pages are `Visibility.Hidden` and the bar is outside the page stack, so no page covers the bar. Candidates to check on the emulator: (1) `9fb874c` tabs used an exclusive long-press + tap group (CYLTabBarController issue #14), replaced by `onClick` + a parallel long press in the now pinned `3ddb96c`; (2) `KeyboardAvoidMode.RESIZE` (row 7) came in the same hour; (3) `hdc shell uitest dumpLayout` shows which node is on top | Cause: the tab gesture of cyltabbar `9fb874c` (CYLTabBarController issue #14), fixed by `onClick` + a parallel long press from `3ddb96c`; nothing to change in the app |
| 18 | DONE (`assets/harmonyos-mate70pro-api21-20261117-discover.jpeg`: the curve spans the full width; Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), CYLSearchViewController after `709f481`, cyltabbar `b2ec2f3`, 2026-11-17 05:5x emulator time (UTC+8)) | CYLSearchViewController (`harmonyos/entry`) | emulator check by the CYLTabBarController session (Discover tab) | A stray open rounded shape at the left edge of Discover, level with "按住提问，有问必答" (about [0,1270][210,1370] of 1316 px) | The light curved area under the mic button is a `Path` whose commands assume a 360 wide box; Path commands are in px and are not scaled, so on a 1316 px screen only the left 360 px got the curve | `Discover.ets`: the commands are built from the measured width in px (`curveCommands()`, `onAreaChange`), the bump in the middle across the whole page |
| 19 | DONE (no change: matches iOS) | CYLSearchViewController (`harmonyos/entry`) | emulator check by the CYLTabBarController session (Search tab) | Tapping a result row ("示例结果 N") does nothing | The rows have no tap action; neither has iOS (`CYLSearchExampleViewController` has no `didSelectRowAt`), so this is the 1:1 behavior | None |
| 20 | DONE (`assets/harmonyos-mate70pro-api21-20261117-search-list-end.jpeg`: the list runs to the tab bar with no band above it; Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), CYLSearchViewController after `709f481`, cyltabbar `b2ec2f3`, 2026-11-17 05:5x emulator time (UTC+8)) | CYLSearchViewController (`harmonyos/entry`) | `d771c1f` screenshots (base `5a30019`): Examples, Placeholder styles, Other libraries, Tag style | A white band above the tab bar on grey pages; the Placeholder styles list is cut off by it | Row 10's fix padded every page by 24 vp; the padding shows the white page behind | Padding removed; scrolling lists get `contentEndOffset(CYL_PLUS_OVERHANG)` (24 vp), Discover keeps a 24 vp bottom padding on its white background |
| 21 | DONE (`assets/harmonyos-mate70pro-api21-20261117-placeholder-styles.jpeg`: the Empty, NoResults and Error icons are secondary grey; Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), cyltabbar `b2ec2f3`, 2026-11-17 06:14 emulator time (UTC+8)) | CYLSearchViewController (`harmonyos/entry`) | Placeholder styles screenshot | The NoResults and Error icons are black; iOS tints them secondary grey | `fillColor` tints SVG only; these are PNGs | `CYLDemoCell`: a `ColorFilter` matrix to #8E8E93, alpha kept |
| 22 | DONE (`assets/harmonyos-mate70pro-api21-20261117-discover.jpeg`: no outline around the curve; Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), CYLSearchViewController after `709f481`, cyltabbar `b2ec2f3`, 2026-11-17 05:5x emulator time (UTC+8)) | CYLSearchViewController (`harmonyos/entry`) | Discover screenshot | The curve under the mic button has a black outline (and is the old 360 px shape: the build predates row 18's fix `d9376af`) | `Path` draws a default black stroke | `.stroke(Color.Transparent).strokeWidth(0)`; row 18's width fix waits for a new build |
| 23 | DONE (emulator 127.0.0.1:5555, HarmonyOS 6.0.1.112 API 21, 2026-11-16: the SVGA animation, its label and "Tab icons: SF Symbols" above the Examples card) | CYLSearchViewController (`harmonyos/entry`) | Examples screenshot | No SVGA header or "Tab icons: …" button above the Examples list | The build (base `5a30019`) predates `6eb2d6a` | Nothing to change; check on a new build |
| 24 | DONE (`assets/harmonyos-mate70pro-api21-20261117-examples-card.jpeg`: the card ends right after its last row; Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), CYLSearchViewController after `709f481`, cyltabbar `b2ec2f3`, 2026-11-17 05:5x emulator time (UTC+8)) | CYLSearchViewController (`harmonyos/entry`) | emulator 127.0.0.1:5555 (2026-11-16) | The Examples card has a white strip under its last row | Row 20's `contentEndOffset` also went onto the short card lists, whose card background includes the offset | Removed from the three card menus (Examples, Other libraries, MaterialSearchView samples); kept on the long full-height lists |
| 25 | TODO | CYLTabBarController (`harmonyos-cyltabbar`) and CYLTableViewPlaceHolder (`cylplaceholder`) | install on emulator 127.0.0.1:5555 (x86_64) | The app does not install on an x86_64 emulator: "install parse native so failed … Abi type" | Both libraries depend on `@ohos/rive` 1.0.4 and `@tencent/libpag` 4.5.102, whose packages ship arm64-v8a .so files only | Open in the two sub-repositories (an x86_64 build of the native packages, or Rive / PAG as optional dependencies). For emulator runs, the build mirror excludes `**/arm64-v8a/*.so` (`buildOption.nativeLib.filter`), not committed; Rive and PAG animations are then unavailable |
| 26 | DONE (`assets/harmonyos-mate70pro-api21-20261117-discover.jpeg`, after the fix; Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), CYLSearchViewController after `709f481`, cyltabbar `b2ec2f3`, 2026-11-17 05:5x emulator time (UTC+8)) | CYLSearchViewController (`harmonyos/entry`) | emulator, 2026-11-17 | Discover: a white strip about 24 vp tall between the grey curved area and the tab bar | The page's bottom padding (`CYL_PLUS_OVERHANG`, which keeps the mic button clear of the plus button) lay outside the grey area, on the white page background | Example-only (the core has no such code): the space is now a grey row under the curve, so the area reaches the tab bar and the mic button stays above the plus button |

- Third review (2026-11-16, 15:10): no new screenshot in either repository since the second review. CYLTabBarController
  double-checked at `ea5b989` (now pinned; it contains `3ddb96c`): its issues #15 to #24 are fixed in code, among them
  our rows 11, 12 and 13 (its #15, #19, #20); none covers the touch bug of row 17. The local emulator is not set up (no
  instance in Device Manager, `hdc list targets` empty), so the code could not be run here; the CYLTabBarController
  session, which has the emulator `127.0.0.1:5557`, was asked to run the row 17 checks.

- Next screenshot run (prepared 2026-11-16 16:22): build from `feat/harmonyos-parity` at the commit that adds this note
  or later; cyltabbar `ebaed17` (badges centred on the icon corner, its #25, double-checked in `CYLBadge.ets`: one line,
  width with the border, `markAnchor` 50 %). Sync `harmonyos/vendor` first (`python3 harmonyos/scripts/sync-sub-repositories.py`),
  then `hvigorw clean` and `hvigorw assembleHap --mode module -p module=entry@default -p product=default`; install the
  unsigned HAP (no signing). The screenshots of `d771c1f` came from base `5a30019`, older than rows 16 to 23.
  What each screen should show:
  - Search tab (row 10, 20): the last result rows scroll above the plus button; no white band above the bar.
  - Examples tab (rows 6, 20, 23): the SVGA animation and "Tab icons: SF Symbols" above the card; the card ends after
    its four rows; no band. Tap "Tab icons" twice: SVGA icons in the tab bar (keys, then file).
  - Placeholder styles (rows 20, 21): grey icons in every section; the list runs down to the bar without a band.
  - Discover (rows 18, 22): the light curve spans the whole width, with no outline; the mic button above the plus button.
  - `aa start -b com.cyl.search.harmonyos -a EntryAbility --pi CYLDemoTab 3` (row 16): opens Tag style.
  - CYLTabBarController demo (rows 1, 12, 14, 15): `NEW` on one line, centred on the icon corner.

- Core or example layer (rule of 2026-11-17, `AGENTS.md`, "Fix issues in the core first"; the core is the code
  published to a package registry):

  | Rows | Layer of the fix | Why |
  | :--- | :--- | :--- |
  | 1 to 4, 12 to 15 | Core: CYLTabBarController's `cyltabbar` (its commits, pinned here) | Bugs of the tab bar library itself |
  | 7 | Core: `harmonyos/cylsearch` (`CYLSearchComponent` follows the window's keyboard height and ends its placeholders and suggestions above the keyboard), 2026-11-17 | Every app with a search view would meet it. The earlier example-layer fix (`KeyboardAvoidMode.RESIZE` in `EntryAbility`) was removed |
  | 10, 20 | Core: CYLTabBarController's `cyltabbar` (`cyl_plusButtonOverhang`, PR #811, commit `b2ec2f3`, pinned here 2026-11-17); the example only applies the value | The tab bar is laid out over the pages, so the library cannot move page content itself; it now tells apps how far its raised plus button rises above the bar (the same layout as its plus slot, Liquid Glass included), instead of each app hard-coding it. The example applies it to its long lists (`contentEndOffset(CYL_PLUS_OVERHANG)`, now computed by the library). Decided by the user on 2026-11-17 ("Fix in CYLTabBarController") |
  | 5, 16 | Example layer | Example-only: the example's own tab configuration (the plus button's size) and launch parameter; the core has no such code |
  | 6, 24 | Example layer | Example-only: the Examples page's own card list |
  | 8, 18, 22 | Example layer | Example-only: the example's tab icons and the Discover page's drawing |
  | 21 | Example layer | Example-only: `CYLDemoCell`, the example's row view |
  | 25 | Core of the sub-repositories (open) | `@ohos/rive` and `@tencent/libpag` are dependencies of CYLTabBarController's and CYLTableViewPlaceHolder's libraries |

<!-- harmonyos-score3:begin -->
Score: 96/100 (25 of 26 rows not `TODO`).
<!-- harmonyos-score3:end -->

- Prompt (verbatim): "全英文写入instructions相关文件以及 skills相关文件： 鸿蒙系统 ide 准备工作，模拟器安装的必要条件， region should be set to china (NZ) in country.region.xml to china make sure The region file now says China: <countryregion name="CN"/>"
- Prompt (English): "Write, in English only, into the instruction files and the skill files: the HarmonyOS IDE
  preparation and the prerequisites for installing the emulator. The region must be set to China in
  `country.region.xml` (the developer is in New Zealand); make sure the region file says China:
  `<countryregion name="CN"/>`."
- Requirements: English only; update `AGENTS.md`, `instructions.md` and a skill in `.agents/skills`; DevEco Studio
  preparation; emulator prerequisites; region set to China (`CN`) in `country.region.xml`, checked on this machine.
- Status: DONE (2026-11-16). New skill `.agents/skills/cyl-harmonyos-setup`; new sections in `AGENTS.md` and
  `instructions.md` ("HarmonyOS: IDE preparation and emulator prerequisites"); a pointer in `cyl-verify`.
- Evidence (Windows 11 Pro 10.0.22631, DevEco Studio build `DS-243.24978.46.36.601251`):
  `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml` contains `<countryregion name="CN"/>` (the original
  `NZ` file is kept as `country.region.xml.bak-NZ`); `HypervisorPresent = True`; 64 GB RAM; the HarmonyOS 6.0.1
  `phone_all_x86` system image was downloading in `%LOCALAPPDATA%\Huawei\Sdk`.
- TODO: N/A on HarmonyOS: no emulator instance on this machine (the image is downloaded; Device Manager only);
  development continues without one. See Scorecard 2, row 7.

## DONE (2026-11-16; TODO 2026-11-16): the HarmonyOS scorecard, scored to 100

- Prompt (verbatim): "合并pr 新建pr 开始鸿蒙端开发，在新建跨端文档，标注鸿蒙系统版本，新建表格，列出iOS版本存在的API， 在新建表格列出iOS端example 层所有演示，每个表格的第二列为鸿蒙对应实现，默认填TODO 鸿蒙系统软件开发过程中需要实时打分，两个表格一起打分。移除所有todo为满分。每每完成一个功能移除一个todo，一直到满分为止。"
- Prompt (English): "Merge the PRs, open a new PR and start the HarmonyOS development. Make a new cross-platform document
  stating the HarmonyOS version; make a table listing the APIs of the iOS version, and a table listing every demo
  of the iOS example layer; the second column of each table is the HarmonyOS implementation, `TODO` by default.
  Score live during the HarmonyOS development, both tables together. No TODO left is a full score. Each time a
  feature is done, remove one TODO, until the score is full."
- Rules:
  1. Table 1 lists every iOS public API; its second column comes from the third column of
     [harmonyos-api-alignment.md](harmonyos-api-alignment.md) (kept in step with the Swift sources by
     `python3 scripts/harmonyos-api-alignment.py`).
  2. Table 2 lists every demo of the iOS example (`CYLSearchExample`); its second column is the HarmonyOS page or
     component, `TODO` until the demo works on HarmonyOS as on iOS (1:1: same texts, data, layout and behaviour).
  3. Principles (2026-11-16, `AGENTS.md` "HarmonyOS: API and example 1:1 with iOS"): the API matches iOS, the
     example is a 1:1 copy of the iOS example, and the internals are migrated from the Android Kotlin sources.
  4. After each feature: replace its `TODO`, run `python3 scripts/harmonyos-scorecard.py` (rewrites both tables and
     the score), add a line to the score log, commit.
- Build on Windows: hvigor rejects a path with spaces or non-ASCII characters, so mirror `harmonyos/` to an ASCII
  path (for example `C:\cylbuild\harmonyos`) and run `hvigorw assembleHap --mode module -p module=entry@default
  -p product=default` there, with `DEVECO_SDK_HOME` set to DevEco Studio's `sdk` and its `jbr\bin` on `PATH`.

## Kotlin parity of the internals (2026-11-16)

The ArkTS core was compared with `android/merged/cylsearch` file by file; these behaviours now follow the Kotlin code
(tests in `harmonyos/entry/src/ohosTest/ets/test/CYLSearchCore.test.ets`, "Kotlin parity"):

- `CYLSearchView`: the query is trimmed before "empty or not" and matched with accents folded (`fold`); the
  placeholders use the trimmed query; any refilter shows the suggestions again and a handled submit dismisses them;
  `setQuery` and a tapped suggestion set the text silently, report the change once and submit through the bar
  (`searchBarViewShouldSubmitText`, blank refused, untrimmed text to the delegate); `searchViewDidShow` /
  `searchViewDidClose` fire when the animation ends; `showSearch` on an open view focuses the field again; changing
  `emptyResultsScenario` / `emptySuggestionsScenario` replaces the placeholder.
- `CYLSearchBarView`: `setText` is silent, `submit` refuses whitespace, and with `iconifiedByDefault` an empty field
  folds back to the search button when editing ends.
- The default suggestion store (`CYLSearchResources.suggestionCache(...)`): keeps at least one query, an empty name
  is `CYLSearchView`, the file name is made safe, `none` keeps nothing.
- `CYLSearchBarView` in `multiple` mode: nothing is selected while typing, the typed text is not trimmed, `addSearch`
  completes the search being typed and reports nothing, and removing a search selects the next one as Kotlin does.
- The four items left open here are done (2026-11-16); see "Scorecard 2" below.

## DONE (2026-11-16; TODO 2026-11-16): Scorecard 2, the remaining HarmonyOS work, scored to 100

- Prompt (verbatim): "鸿蒙模拟器正在安装，大概一小时后安装成功，请现在立即开始鸿蒙端的开发工作。阅读本地的鸿蒙功能相关文档，搜索鸿蒙相关关键词，找到TODO以及打分表。制作满分标准。如果没有就新建打分表。一直完成到满分为止。"
- Prompt (English): "The HarmonyOS emulator is installing and should be ready in about an hour; start the HarmonyOS
  development now. Read the local HarmonyOS documents, search the HarmonyOS keywords, find the TODOs and the
  scorecards. Write a full-score standard; make a new scorecard if there is none. Keep going until the score is full."
- Found: Table 1 and Table 2 below already score 100/100, but only "by implementation": nothing has run on a device.
  The open items were the four Kotlin-parity gaps above, the emulator TODO in "IDE preparation and emulator
  prerequisites", and "HarmonyOS not run" in [sub-repositories.md](sub-repositories.md). This scorecard collects them.
- Full-score standard: every row is `DONE` with its evidence (a commit, a test name, a build log line or a committed
  screenshot). Code that compiles counts only for rows about compiling; every behavior row needs a run on the
  emulator or a device. Score = `DONE` rows / all rows × 100, rounded down.
- N/A rule (user, 2026-11-16: "marking the rest 'TODO: N/A on HarmonyOS' with a reason"): a row that cannot be done
  without an emulator is marked `TODO: N/A on HarmonyOS` with its reason and counts like `N/A` in Table 1 (not a
  `TODO`). It stays unverified: when an emulator or device is available, run it and replace the mark with `DONE`.

| # | Item | Status | Evidence |
| :--- | :--- | :--- | :--- |
| 1 | Inline fold control placed as the last tag of the flow, not laid over the last row (CollectionViewClassifyMenu `CYLMenuFoldControlPositionInline`) | DONE | `CYLSearchComponent.visibleTagCount()`, `cylFoldedTagCount` in the core; test `foldedTagCountLeavesRoomForAnInlineControl` |
| 2 | `CYLMenuFoldControlPosition.none`: every tag, no control (iOS `CYLMenuFoldControlPositionNone`) | DONE | Enum value `none = 2`; test `foldControlPositionNone` |
| 3 | Screen-reader announcement "Recent searches cleared" after `clearSuggestionCache` (iOS `UIAccessibility.post(.announcement)`, Android `announceForAccessibility`) | DONE | `accessibility.sendAccessibilityEvent` with `announceForAccessibility`; test `clearSuggestionCacheWithoutContextDoesNotThrow` |
| 4 | Focus delay of an iconified bar: opening it focuses the field once the text input is drawn (Android posts to the field) | DONE | `CYLSearchBarView.showKeyboardWhenDrawn` retries each frame, up to 30 |
| 5 | One fold measurement: the Discover page uses the core `cylFoldedTagCount` instead of its own copy | DONE | `entry/src/main/ets/demos/Discover.ets` imports it from `cylsearch` |
| 6 | App HAP and test HAP compile, with no new warning in the changed files | DONE | hvigor `BUILD SUCCESSFUL` for `entry@default` and `entry@ohosTest` (2026-11-16, DevEco Studio `DS-243.24978.46.36.601251`); the older `animateTo` warnings were removed in row 11 |
| 7 | Mate 70 Pro emulator (HarmonyOS 6.0.1, API 21) created and listed by `hdc list targets` | DONE | `hdc list targets` lists 127.0.0.1:5555 (model "emulator", OpenHarmony-6.0.1.112, API 21, x86_64), 2026-11-16 |
| 8 | Hypium tests (`CYLSearchCore`, `CYLSearchUI`) run on the emulator, all pass | DONE | 2026-11-17, emulator 127.0.0.1:5555 used by this session alone, cyltabbar `b2ec2f3`: Tests run 22, Pass 21, Error 1. Fixed on the way: (1) four icon-only example controls (nav bar Back and open-search, Discover mic and fold) gained `accessibilityGroup(true)`, now enforced by `check-accessibility-i18n.mjs`; (2) uitest on API 21 does not report `accessibilityText`, so `findByLabel` takes the control's id as a fallback for icon-only controls, after the label. Then: the emulator's keyboard first-run privacy screen was accepted once (the user agreed, 2026-11-17), and `searchFlowByLabels` now checks that submitting closes the search page, as MaterialSearchView does, before one Back (it pressed Back twice and left the app). Result: Tests run 22, Pass 22, Error 0 (Mate 70 Pro emulator 127.0.0.1:5555, HarmonyOS 6.0.1 (API 21), cyltabbar `b2ec2f3`, 2026-11-17 06:10 emulator time (UTC+8)) |
| 9 | Each of the 25 demos launched on the emulator and checked 1:1 with iOS; screenshots committed in `docs/assets/` with labels, rows 1 to 4 checked on screen (VoiceOver-equivalent ScreenReader for row 3) | TODO: N/A on HarmonyOS | Reason: launching demos and taking screenshots needs an emulator or a device (row 7). Every demo compiles in the app HAP; the on-screen 1:1 check with iOS is not done |
| 10 | The `database` cache policy is a real SQLite database (`relationalStore`, table `queries` with `cache`, `query`, `time`, as Android `SQLiteOpenHelper`), not a preferences store; the queries kept by the older preferences store move into it once (`docs/core-todo.md` rule 5: a database first) | DONE | `CYLSearchSuggestionStore` (`cyl_search_suggestions.db`); reads mirrored in memory, writes queued in order, `whenStored()`, `onLoad` refreshes the list; test `databasePolicyKeepsQueriesInSQLite` |
| 11 | No compiler warning in `cylsearch`: the deprecated global `animateTo` replaced by `UIContext.animateTo` (`cylAnimate`, the context set by each drawing component), every throwing call handled | DONE | hvigor `BUILD SUCCESSFUL` for `entry@default` and `entry@ohosTest` with no `cylsearch` warning (2026-11-16; before: 6 `animateTo` and 1 throw warning) |
| 12 | The pure logic (accent folding, matching, filtering with the cached queries first, the cache order and limit, the tag folding) lives in `CYLSearchLogic.ets` with no kit import and is tested on the host, without an emulator | DONE | `node harmonyos/scripts/host-logic-test.mjs`: tests 14, pass 14, fail 0 (Node 22.23.5, 2026-11-16); the core calls these functions, HAPs build with no `cylsearch` warning |
| 13 | The multi-search and search bar rules in `CYLSearchLogic.ets`, used by the core and tested on the host: text limit, when a typed search completes (not trimmed), the selection after a removal (Android `remove`), blank text refused on submit | DONE | `CYLMultiSearchView` and `CYLSearchBarView` call `cylSearchTextLimited`, `cylSearchTextCompletes`, `cylSelectionAfterRemoval`, `cylSearchTextSubmittable`; `node harmonyos/scripts/host-logic-test.mjs`: tests 23, pass 23, fail 0; HAPs build with no `cylsearch` warning |
| 14 | The resources are a 1:1 copy of iOS, checked without an emulator: every string of the library and of the example (tabs, Discover) in en, ja, zh-Hans and zh-Hant with the same text (iOS `%@` / `%ld` / `%lu` as HarmonyOS `%s` / `%d`), and every placeholder image | DONE | `node harmonyos/scripts/check-ios-parity.mjs`: checked 357, 357 match, 0 problems (2026-11-16) |
| 15 | Screen readers (ScreenReader, the VoiceOver of HarmonyOS): every tappable element of the library has a label in the language the app shows; icons have 44 vp touch areas (the voice and submit buttons, the multi-search remove button, the fold control); a custom suggestion cell is read as one element; multi-search items read their position ("Search 2 of 3", iOS `multisearch.item`) and their selected state; the cache cleared is announced (row 3) | DONE | `node harmonyos/scripts/check-accessibility-i18n.mjs`: 15 tappable elements, 0 problems; HAPs build with no `cylsearch` warning. Not heard on a device: see row 9 |
| 16 | Localization: no English text written in the library's UI (Cancel, Back, Voice search, Search, More / Less, Show more / Show less now come from string resources in en, ja, zh-Hans, zh-Hant); 29 more languages copied from CYLTabBarController's string table, filtered to the texts this project uses (OK, Default, No data, Cancel) | DONE | `node harmonyos/scripts/import-cyltabbar-localizations.mjs` (58 `string.json` files in 29 language folders); `check-accessibility-i18n.mjs`: 25 string resources used, all present in the four curated languages; hvigor accepts every language folder |
| 17 | UI automation by label: the hypium UI tests find every control by its accessibility label or localized text (`findByLabel`, `tapLabel`), ids only for the text field; a new flow test types, clears, types again and submits through labelled controls; the example's list rows are labelled groups (Examples menu, placeholder styles, MaterialSearchView samples, other libraries) so tests and screen readers find them | DONE (code) | `CYLSearchUI.test.ets` compiles into `entry-ohosTest-unsigned.hap`; `check-accessibility-i18n.mjs` now covers the library and the example: 31 tappable elements, 0 problems. Running the tests: row 8 |

<!-- harmonyos-score2:begin -->
Score: 100/100 (17 of 17 rows not `TODO`: 16 DONE, row 9 `TODO: N/A on HarmonyOS`).
<!-- harmonyos-score2:end -->

| Date | Change | Score |
| :--- | :--- | ---: |
| 2026-11-16 | Scorecard made; rows 1 to 6 done and compiled | 66 |
| 2026-11-16 | Rows 10 and 11 added and done: SQLite suggestion cache, no `cylsearch` warnings | 72 |
| 2026-11-16 | Row 12 added and done: pure logic in `CYLSearchLogic.ets`, 14 host tests pass with Node | 75 |
| 2026-11-16 | Rows 7 to 9 marked `TODO: N/A on HarmonyOS` with reasons (development without an emulator) | 100 |
| 2026-11-16 | Row 13 added and done: multi-search and search bar rules tested on the host (23 of 23) | 100 |
| 2026-11-16 | Row 14 added and done: iOS resource parity checked on the host (357 of 357) | 100 |
| 2026-11-16 | Rows 15 and 16 added and done: screen-reader labels and touch areas, localization with CYLTabBarController's translations | 100 |
| 2026-11-16 | Row 17 added and done: UI tests find controls by label, example rows labelled | 100 |


## Score

Status: 100 by implementation; every demo compiles, none has run yet (no emulator on the Windows machine; create one in
DevEco Studio > Device Manager, then `hdc install` the HAP and run the hypium tests). The tab bar and the refresh header come from the
sub-repositories' HarmonyOS libraries: run `python3 harmonyos/scripts/sync-sub-repositories.py` before building.

<!-- harmonyos-score:begin -->
Score: 100/100 (308 of 308 rows; API 283/283, demos 25/25; TODO left 0).
<!-- harmonyos-score:end -->

| Date | Change | Score |
| :--- | :--- | ---: |
| 2026-11-16 | Tables listed; the API from harmonyos-api-alignment.md, every demo TODO | 94 |
| 2026-11-16 | The example rebuilt 1:1 with iOS (25 demos), the iOS placeholder images and texts in the core; compiled with hvigor (app and test HAPs), not run: this Windows machine has no HarmonyOS emulator | 100 |
| 2026-11-16 | Back to TODO, not 1:1 yet: the tab bar and the refresh header are drawn in the example (CYLTabBarController and CYLTableViewPlaceHolder have no HarmonyOS library), the Voice sample has no speech recognizer | 99 |
| 2026-11-16 | Voice sample: CoreSpeechKit speech recognition | 99 |
| 2026-11-16 | The tab bar on CYLTabBarController's `cyltabbar` and the refresh header on CYLTableViewPlaceHolder's `cylplaceholder` (harmonyos/scripts/sync-sub-repositories.py, pinned commits); minimum raised to API 21, the libraries' minimum | 100 |

## Table 1: iOS public API

<!-- harmonyos-api:begin -->
| iOS public API | HarmonyOS implementation |
| :--- | :--- |
| **enum `CYLSearchBarMode`** | `CYLSearchBarMode` |
| `CYLSearchBarMode.single` | `CYLSearchBarMode.single` |
| `CYLSearchBarMode.multiple` | `CYLSearchBarMode.multiple` |
| **enum `CYLSearchBarNavigationIcon`** | `CYLSearchBarNavigationIcon` |
| `CYLSearchBarNavigationIcon.none` | `CYLSearchBarNavigationIcon.none` |
| `CYLSearchBarNavigationIcon.arrow` | `CYLSearchBarNavigationIcon.arrow` |
| `CYLSearchBarNavigationIcon.search` | `CYLSearchBarNavigationIcon.search` |
| **enum `CYLSearchBarIconPosition`** | `CYLSearchBarIconPosition` |
| `CYLSearchBarIconPosition.trailing` | `CYLSearchBarIconPosition.trailing` |
| `CYLSearchBarIconPosition.center` | `CYLSearchBarIconPosition.center` |
| `CYLSearchBarIconPosition.leading` | `CYLSearchBarIconPosition.leading` |
| **enum `CYLSearchBarExpansionAnimation`** | `CYLSearchBarExpansionAnimation` |
| `CYLSearchBarExpansionAnimation.fade` | `CYLSearchBarExpansionAnimation.fade` |
| `CYLSearchBarExpansionAnimation.circularReveal` | `CYLSearchBarExpansionAnimation.circularReveal` |
| **enum `CYLSearchBarItemStyle`** | `CYLSearchBarItemStyle` |
| `CYLSearchBarItemStyle.icon` | `CYLSearchBarItemStyle.icon` |
| `CYLSearchBarItemStyle.divider` | `CYLSearchBarItemStyle.divider` |
| `CYLSearchBarItemStyle.text` | `CYLSearchBarItemStyle.text` |
| **enum `CYLSearchBarStyle`** | `CYLSearchBarStyle` |
| `CYLSearchBarStyle.plain` | `CYLSearchBarStyle.plain` |
| `CYLSearchBarStyle.bordered` | `CYLSearchBarStyle.bordered` |
| **protocol `CYLSearchBarViewDelegate`** | `CYLSearchBarViewDelegate` |
| `CYLSearchBarViewDelegate.-searchBarViewShouldBeginEditing:` | `CYLSearchBarViewDelegate.searchBarViewShouldBeginEditing` |
| `CYLSearchBarViewDelegate.-searchBarViewDidTapWhileNotEditable:` | `CYLSearchBarViewDelegate.searchBarViewDidTapWhileNotEditable` |
| `CYLSearchBarViewDelegate.-searchBarViewDidBeginEditing:` | `CYLSearchBarViewDelegate.searchBarViewDidBeginEditing` |
| `CYLSearchBarViewDelegate.-searchBarViewDidEndEditing:` | `CYLSearchBarViewDelegate.searchBarViewDidEndEditing` |
| `CYLSearchBarViewDelegate.-searchBarView:textDidChange:` | `CYLSearchBarViewDelegate.searchBarViewTextDidChange` |
| `CYLSearchBarViewDelegate.-searchBarViewSearchButtonClicked:` | `CYLSearchBarViewDelegate.searchBarViewSearchButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarViewCancelButtonClicked:` | `CYLSearchBarViewDelegate.searchBarViewCancelButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarViewNavigationButtonClicked:` | `CYLSearchBarViewDelegate.searchBarViewNavigationButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarViewVoiceButtonClicked:` | `CYLSearchBarViewDelegate.searchBarViewVoiceButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarView:shouldSubmitText:` | `CYLSearchBarViewDelegate.searchBarViewShouldSubmitText` |
| `CYLSearchBarViewDelegate.-searchBarView:didChangeIconified:` | `CYLSearchBarViewDelegate.searchBarViewDidChangeIconified` |
| `CYLSearchBarViewDelegate.-searchBarView:didSelectItem:` | `CYLSearchBarViewDelegate.searchBarViewDidSelectItem` |
| `CYLSearchBarViewDelegate.-searchBarView:textDidChange:atIndex:` | `CYLSearchBarViewDelegate.searchBarViewTextDidChange` |
| `CYLSearchBarViewDelegate.-searchBarView:didCompleteSearch:atIndex:` | `CYLSearchBarViewDelegate.searchBarViewDidCompleteSearch` |
| `CYLSearchBarViewDelegate.-searchBarView:didRemoveSearchAtIndex:` | `CYLSearchBarViewDelegate.searchBarViewDidRemoveSearchAtIndex` |
| `CYLSearchBarViewDelegate.-searchBarView:didSelectSearch:atIndex:` | `CYLSearchBarViewDelegate.searchBarViewDidSelectSearch` |
| **class `CYLSearchBarView`** | `CYLSearchBarView` |
| `CYLSearchBarView.delegate` | `CYLSearchBarView.delegate` |
| `CYLSearchBarView.textField` | `CYLSearchBarView.textField` |
| `CYLSearchBarView.fieldView` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.searchIconView` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.cancelButton` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.placeholderLabel` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.navigationButton` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.voiceButton` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.submitButton` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.iconButton` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.text` | `CYLSearchBarView.text` |
| `CYLSearchBarView.placeholder` | `CYLSearchBarView.placeholder` |
| `CYLSearchBarView.font` | `CYLSearchBarView.font` |
| `CYLSearchBarView.textColor` | `CYLSearchBarView.textColor` |
| `CYLSearchBarView.placeholderColor` | `CYLSearchBarView.placeholderColor` |
| `CYLSearchBarView.cursorColor` | `CYLSearchBarView.cursorColor` |
| `CYLSearchBarView.fieldHeight` | `CYLSearchBarView.fieldHeight` |
| `CYLSearchBarView.contentInsets` | `CYLSearchBarView.contentInsets` |
| `CYLSearchBarView.fieldBackgroundColor` | `CYLSearchBarView.fieldBackgroundColor` |
| `CYLSearchBarView.fieldCornerRadius` | `CYLSearchBarView.fieldCornerRadius` |
| `CYLSearchBarView.fieldBorderColor` | `CYLSearchBarView.fieldBorderColor` |
| `CYLSearchBarView.fieldBorderWidth` | `CYLSearchBarView.fieldBorderWidth` |
| `CYLSearchBarView.fieldShadowOpacity` | `CYLSearchBarView.fieldShadowOpacity` |
| `CYLSearchBarView.searchIcon` | `CYLSearchBarView.searchIcon` |
| `CYLSearchBarView.searchIconTintColor` | `CYLSearchBarView.searchIconTintColor` |
| `CYLSearchBarView.trailingAccessoryViews` | `CYLSearchBarComponent.trailingAccessoryViews` (a `@BuilderParam`) |
| `CYLSearchBarView.items` | `CYLSearchBarView.items` |
| `CYLSearchBarView.itemViews` | `CYLSearchBarView.itemViews` |
| `CYLSearchBarView.itemTintColor` | `CYLSearchBarView.itemTintColor` |
| `CYLSearchBarView.searchBarStyle` | `CYLSearchBarView.searchBarStyle` |
| `CYLSearchBarView.fieldBackgroundImage` | `CYLSearchBarView.fieldBackgroundImage` |
| `CYLSearchBarView.selectedItem` | `CYLSearchBarView.selectedItem` |
| `CYLSearchBarView.selectedIndex` | `CYLSearchBarView.selectedIndex` |
| `CYLSearchBarView.addItem(_:)` | `CYLSearchBarView.addItem` |
| `CYLSearchBarView.insertItem(_:at:)` | `CYLSearchBarView.insertItem` |
| `CYLSearchBarView.addItem(style:title:image:index:handler:)` | `CYLSearchBarView.addItem` |
| `CYLSearchBarView.removeItem(_:)` | `CYLSearchBarView.removeItem` |
| `CYLSearchBarView.removeAllItems()` | `CYLSearchBarView.removeAllItems` |
| `CYLSearchBarView.hasItem(of:)` | `CYLSearchBarView.hasItem` |
| `CYLSearchBarView.leadingView` | `CYLSearchBarComponent.leadingView` (a `@BuilderParam`) |
| `CYLSearchBarView.showsCancelButton` | `CYLSearchBarView.showsCancelButton` |
| `CYLSearchBarView.cancelButtonTitle` | `CYLSearchBarView.cancelButtonTitle` |
| `CYLSearchBarView.cancelButtonEndsEditing` | `CYLSearchBarView.cancelButtonEndsEditing` |
| `CYLSearchBarView.clearsTextOnCancel` | `CYLSearchBarView.clearsTextOnCancel` |
| `CYLSearchBarView.clearsTextOnEndEditing` | `CYLSearchBarView.clearsTextOnEndEditing` |
| `CYLSearchBarView.navigationIcon` | `CYLSearchBarView.navigationIcon` |
| `CYLSearchBarView.navigationImage` | `CYLSearchBarView.navigationImage` |
| `CYLSearchBarView.navigationAccessibilityLabel` | `CYLSearchBarView.navigationAccessibilityLabel` |
| `CYLSearchBarView.navigationBackgroundColor` | `CYLSearchBarView.navigationBackgroundColor` |
| `CYLSearchBarView.navigationShadowOpacity` | `CYLSearchBarView.navigationShadowOpacity` |
| `CYLSearchBarView.navigationHandler` | `CYLSearchBarView.navigationHandler` |
| `CYLSearchBarView.showsVoiceButton` | `CYLSearchBarView.showsVoiceButton` |
| `CYLSearchBarView.voiceImage` | `CYLSearchBarView.voiceImage` |
| `CYLSearchBarView.showsSubmitButton` | `CYLSearchBarView.showsSubmitButton` |
| `CYLSearchBarView.submitImage` | `CYLSearchBarView.submitImage` |
| `CYLSearchBarView.clearImage` | `CYLSearchBarView.clearImage` |
| `CYLSearchBarView.keyboardType` | `CYLSearchBarView.keyboardType` |
| `CYLSearchBarView.returnKeyType` | `CYLSearchBarView.returnKeyType` |
| `CYLSearchBarView.autocapitalizationType` | TODO: N/A on HarmonyOS: ArkUI `TextInput` has no capitalization trait |
| `CYLSearchBarView.autocorrectionType` | TODO: N/A on HarmonyOS: ArkUI `TextInput` has no autocorrection trait |
| `CYLSearchBarView.isSecureTextEntry` | `CYLSearchBarView.isSecureTextEntry` |
| `CYLSearchBarView.maximumTextLength` | `CYLSearchBarView.maximumTextLength` |
| `CYLSearchBarView.isIconified` | `CYLSearchBarView.isIconified` |
| `CYLSearchBarView.iconifiedByDefault` | `CYLSearchBarView.iconifiedByDefault` |
| `CYLSearchBarView.expansionAnimation` | `CYLSearchBarView.expansionAnimation` |
| `CYLSearchBarView.iconPosition` | `CYLSearchBarView.iconPosition` |
| `CYLSearchBarView.animationDuration` | `CYLSearchBarView.animationDuration` |
| `CYLSearchBarView.mode` | `CYLSearchBarView.mode` |
| `CYLSearchBarView.searches` | `CYLSearchBarView.searches` |
| `CYLSearchBarView.selectedSearchIndex` | `CYLSearchBarView.selectedSearchIndex` |
| `CYLSearchBarView.isEditingNewSearch` | `CYLSearchBarView.isEditingNewSearch` |
| `CYLSearchBarView.newSearchButton` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` draws it in `CYLSearchBarModeMultiple` (`newSearchImage`) |
| `CYLSearchBarView.minimumTextLength` | `CYLSearchBarView.minimumTextLength` |
| `CYLSearchBarView.searchIndicatorColor` | `CYLSearchBarView.searchIndicatorColor` |
| `CYLSearchBarView.unselectedSearchAlpha` | `CYLSearchBarView.unselectedSearchAlpha` |
| `CYLSearchBarView.searchFieldWidth` | `CYLSearchBarView.searchFieldWidth` |
| `CYLSearchBarView.newSearchImage` | `CYLSearchBarView.newSearchImage` |
| `CYLSearchBarView.removeSearchImage` | `CYLSearchBarView.removeSearchImage` |
| `CYLSearchBarView.beginNewSearch()` | `CYLSearchBarView.beginNewSearch` |
| `CYLSearchBarView.completeSearch()` | `CYLSearchBarView.completeSearch` |
| `CYLSearchBarView.addSearch(_:)` | `CYLSearchBarView.addSearch` |
| `CYLSearchBarView.selectSearch(at:)` | `CYLSearchBarView.selectSearch` |
| `CYLSearchBarView.removeSearch(at:)` | `CYLSearchBarView.removeSearch` |
| `CYLSearchBarView.init(frame:)` | `new CYLSearchBarView(…)` |
| `CYLSearchBarView.init(coder:)` | TODO: N/A on HarmonyOS: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchBarView.setText(_:submit:)` | `CYLSearchBarView.setText` |
| `CYLSearchBarView.submit()` | `CYLSearchBarView.submit` |
| `CYLSearchBarView.showKeyboard()` | `CYLSearchBarView.showKeyboard` |
| `CYLSearchBarView.hideKeyboard()` | `CYLSearchBarView.hideKeyboard` |
| `CYLSearchBarView.setIconified(_:animated:)` | `CYLSearchBarView.setIconified` |
| `CYLSearchBarView.encodeRestorableState(with:)` | `CYLSearchBarView.encodeRestorableState` |
| `CYLSearchBarView.decodeRestorableState(with:)` | `CYLSearchBarView.decodeRestorableState` |
| `CYLSearchBarView.traitCollectionDidChange(_:)` | TODO: N/A on HarmonyOS: system colors (`sys.color.*`) follow the color mode by themselves |
| `CYLSearchBarView.tintColorDidChange()` | TODO: N/A on HarmonyOS: system colors follow the theme by themselves (`searchIndicatorColor` overrides) |
| `CYLSearchBarView.intrinsicContentSize` | `CYLSearchBarView.intrinsicContentSize` |
| `CYLSearchBarView.sizeThatFits(_:)` | TODO: N/A on HarmonyOS: ArkUI measures a component from its declaration (`intrinsicContentSize` gives the height) |
| `CYLSearchBarView.layoutSubviews()` | TODO: N/A on HarmonyOS: ArkUI lays a component out from its declaration |
| `CYLSearchBarView.textFieldShouldBeginEditing(_:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldShouldReturn(_:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textField(_:shouldChangeCharactersIn:replacementString:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldDidBeginEditing(_:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldDidEndEditing(_:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.becomeFirstResponder()` | `CYLSearchBarView.becomeFirstResponder` |
| `CYLSearchBarView.resignFirstResponder()` | `CYLSearchBarView.resignFirstResponder` |
| **class `CYLSearchBarItem`** | `CYLSearchBarItem` |
| `CYLSearchBarItem.style` | `CYLSearchBarItem.style` |
| `CYLSearchBarItem.title` | `CYLSearchBarItem.title` |
| `CYLSearchBarItem.image` | `CYLSearchBarItem.image` |
| `CYLSearchBarItem.selectedImage` | `CYLSearchBarItem.selectedImage` |
| `CYLSearchBarItem.animatedImage` | `CYLSearchBarItem.animatedImage` |
| `CYLSearchBarItem.imageSize` | `CYLSearchBarItem.imageSize` |
| `CYLSearchBarItem.itemAccessibilityLabel` | `CYLSearchBarItem.itemAccessibilityLabel` |
| `CYLSearchBarItem.itemAccessibilityIdentifier` | `CYLSearchBarItem.itemAccessibilityIdentifier` |
| `CYLSearchBarItem.isEnabled` | `CYLSearchBarItem.isEnabled` |
| `CYLSearchBarItem.isSelectable` | `CYLSearchBarItem.isSelectable` |
| `CYLSearchBarItem.isSelected` | `CYLSearchBarItem.isSelected` |
| `CYLSearchBarItem.tintColor` | `CYLSearchBarItem.tintColor` |
| `CYLSearchBarItem.backgroundColor` | `CYLSearchBarItem.backgroundColor` |
| `CYLSearchBarItem.selectedBackgroundColor` | `CYLSearchBarItem.selectedBackgroundColor` |
| `CYLSearchBarItem.contentInsets` | `CYLSearchBarItem.contentInsets` |
| `CYLSearchBarItem.imagePositionAdjustment` | `CYLSearchBarItem.imagePositionAdjustment` |
| `CYLSearchBarItem.titlePositionAdjustment` | `CYLSearchBarItem.titlePositionAdjustment` |
| `CYLSearchBarItem.badgeValue` | `CYLSearchBarItem.badgeValue` |
| `CYLSearchBarItem.badgeColor` | `CYLSearchBarItem.badgeColor` |
| `CYLSearchBarItem.badgeSize` | `CYLSearchBarItem.badgeSize` |
| `CYLSearchBarItem.badgeContentInsets` | `CYLSearchBarItem.badgeContentInsets` |
| `CYLSearchBarItem.badgePositionAdjustment` | `CYLSearchBarItem.badgePositionAdjustment` |
| `CYLSearchBarItem.handler` | `CYLSearchBarItem.handler` |
| `CYLSearchBarItem.index` | `CYLSearchBarItem.index` |
| `CYLSearchBarItem.itemView` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarItem.init(style:title:image:)` | `new CYLSearchBarItem(…)` |
| `CYLSearchBarItem.init(title:image:)` | `new CYLSearchBarItem(…)` |
| `CYLSearchBarItem.init(title:image:selectedImage:)` | `new CYLSearchBarItem(…)` |
| `CYLSearchBarItem.iconItem(image:title:handler:)` | `CYLSearchBarItem.iconItem` |
| `CYLSearchBarItem.textItem(title:handler:)` | `CYLSearchBarItem.textItem` |
| `CYLSearchBarItem.divider()` | `CYLSearchBarItem.divider` |
| `CYLSearchBarItem.item(dictionary:)` | `CYLSearchBarItem.item` |
| `CYLSearchBarItem.setTitleTextAttributes(_:for:)` | `CYLSearchBarItem.setTitleTextAttributes` |
| `CYLSearchBarItem.titleTextAttributes(for:)` | `CYLSearchBarItem.titleTextAttributes` |
| `CYLSearchBarItem.setBadgeTextAttributes(_:for:)` | `CYLSearchBarItem.setBadgeTextAttributes` |
| `CYLSearchBarItem.badgeTextAttributes(for:)` | `CYLSearchBarItem.badgeTextAttributes` |
| `CYLSearchBarItem.actualBadgeSuperView()` | TODO: N/A on HarmonyOS: ArkUI has no view objects; the badge is drawn by `CYLSearchBarItemView` |
| **class `CYLSearchResources`** | `CYLSearchResources` |
| `CYLSearchResources.resourceBundle` | `CYLSearchResources.resourceBundle` |
| `CYLSearchResources.image(named:)` | `CYLSearchResources.imageNamed` |
| `CYLSearchResources.localizedString(forKey:)` | `CYLSearchResources.localizedString` |
| `CYLSearchResources.localizedString(forKey:language:)` | `CYLSearchResources.localizedString` |
| **enum `CYLSearchSuggestionStyle`** | `CYLSearchSuggestionStyle` |
| `CYLSearchSuggestionStyle.list` | `CYLSearchSuggestionStyle.list` |
| `CYLSearchSuggestionStyle.tags` | `CYLSearchSuggestionStyle.tags` |
| **protocol `CYLSearchViewDelegate`** | `CYLSearchViewDelegate` |
| `CYLSearchViewDelegate.-searchViewDidShow:` | `CYLSearchViewDelegate.searchViewDidShow` |
| `CYLSearchViewDelegate.-searchViewDidClose:` | `CYLSearchViewDelegate.searchViewDidClose` |
| `CYLSearchViewDelegate.-searchView:textDidChange:` | `CYLSearchViewDelegate.searchViewTextDidChange` |
| `CYLSearchViewDelegate.-searchView:didSubmitText:` | `CYLSearchViewDelegate.searchViewDidSubmitText` |
| `CYLSearchViewDelegate.-searchView:didChangeFocus:` | `CYLSearchViewDelegate.searchViewDidChangeFocus` |
| `CYLSearchViewDelegate.-searchView:didSelectSuggestion:atIndex:` | `CYLSearchViewDelegate.searchViewDidSelectSuggestion` |
| `CYLSearchViewDelegate.-searchViewVoiceButtonClicked:` | `CYLSearchViewDelegate.searchViewVoiceButtonClicked` |
| `CYLSearchViewDelegate.-searchViewNavigationButtonClicked:` | `CYLSearchViewDelegate.searchViewNavigationButtonClicked` |
| `CYLSearchViewDelegate.-searchView:didSelectResult:` | `CYLSearchViewDelegate.searchViewDidSelectResult` |
| **protocol `CYLSearchViewDataSource`** | `CYLSearchViewDataSource` |
| `CYLSearchViewDataSource.-searchView:resultsForQuery:` | `CYLSearchViewDataSource.searchViewResultsForQuery` |
| `CYLSearchViewDataSource.-searchView:configureResultCell:withResult:` | `CYLSearchViewDataSource.searchViewConfigureResultCell` |
| **class `CYLSearchView`** | `CYLSearchView` |
| `CYLSearchView.delegate` | `CYLSearchView.delegate` |
| `CYLSearchView.searchBarView` | `CYLSearchView.searchBarView` |
| `CYLSearchView.dividerView` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchComponent` draws the divider (`dividerColor`) |
| `CYLSearchView.suggestionsTableView` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchComponent` draws the list (`suggestionCellConfiguration`) |
| `CYLSearchView.suggestionsTagView` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchComponent` draws the tags (`suggestionsFoldControl`) |
| `CYLSearchView.suggestionsFoldControl` | `CYLSearchView.suggestionsFoldControl` |
| `CYLSearchView.suggestionsFoldedRowCount` | `CYLSearchView.suggestionsFoldedRowCount` |
| `CYLSearchView.suggestionStyle` | `CYLSearchView.suggestionStyle` |
| `CYLSearchView.showsEmptyResultsPlaceholder` | `CYLSearchView.showsEmptyResultsPlaceholder` |
| `CYLSearchView.emptyResultsScenario` | `CYLSearchView.emptyResultsScenario` |
| `CYLSearchView.emptyResultsView` | `CYLSearchView.emptyResultsView` |
| `CYLSearchView.resultsDataSource` | `CYLSearchView.resultsDataSource` |
| `CYLSearchView.resultsTableView` | `CYLSearchView.resultsTableView` |
| `CYLSearchView.searchResults` | `CYLSearchView.searchResults` |
| `CYLSearchView.refreshHandler` | `CYLSearchView.refreshHandler` |
| `CYLSearchView.isRefreshing` | `CYLSearchView.isRefreshing` |
| `CYLSearchView.beginRefreshing()` | `CYLSearchView.beginRefreshing` |
| `CYLSearchView.endRefreshing()` | `CYLSearchView.endRefreshing` |
| `CYLSearchView.setRefreshHandler(_:)` | `CYLSearchView.setRefreshHandler` |
| `CYLSearchView.beginRefreshing(in:)` | `CYLSearchView.beginRefreshing` |
| `CYLSearchView.endRefreshing(in:)` | `CYLSearchView.endRefreshing` |
| `CYLSearchView.isRefreshing(in:)` | `CYLSearchView.isRefreshing` |
| `CYLSearchView.dividerColor` | `CYLSearchView.dividerColor` |
| `CYLSearchView.contentView` | `CYLSearchView.contentView` |
| `CYLSearchView.scrimColor` | `CYLSearchView.scrimColor` |
| `CYLSearchView.suggestions` | `CYLSearchView.suggestions` |
| `CYLSearchView.suggestionFilter` | `CYLSearchView.suggestionFilter` |
| `CYLSearchView.showsSuggestionsForEmptyQuery` | `CYLSearchView.showsSuggestionsForEmptyQuery` |
| `CYLSearchView.filteredSuggestions` | `CYLSearchView.filteredSuggestions` |
| `CYLSearchView.suggestionImage` | `CYLSearchView.suggestionImage` |
| `CYLSearchView.suggestionImageTintColor` | `CYLSearchView.suggestionImageTintColor` |
| `CYLSearchView.suggestionBackgroundColor` | `CYLSearchView.suggestionBackgroundColor` |
| `CYLSearchView.suggestionTextColor` | `CYLSearchView.suggestionTextColor` |
| `CYLSearchView.suggestionLineBreakMode` | `CYLSearchView.suggestionLineBreakMode` |
| `CYLSearchView.submitsOnSuggestionSelection` | `CYLSearchView.submitsOnSuggestionSelection` |
| `CYLSearchView.suggestionCellConfiguration` | `CYLSearchView.suggestionCellConfiguration` |
| `CYLSearchView.suggestionCachePolicy` | `CYLSearchView.suggestionCachePolicy` |
| `CYLSearchView.suggestionCacheName` | `CYLSearchView.suggestionCacheName` |
| `CYLSearchView.suggestionCache` | `CYLSearchView.suggestionCache` |
| `CYLSearchView.suggestionCacheHeaderView` | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchComponent.cacheHeader` draws it |
| `CYLSearchView.suggestionCacheTitleLabel` | `CYLSearchView.suggestionCacheTitle` |
| `CYLSearchView.clearSuggestionCacheButton` | `CYLSearchView.clearSuggestionCache()` (the header button calls it) |
| `CYLSearchView.showsEmptySuggestionsPlaceholder` | `CYLSearchView.showsEmptySuggestionsPlaceholder` |
| `CYLSearchView.emptySuggestionsScenario` | `CYLSearchView.emptySuggestionsScenario` |
| `CYLSearchView.emptySuggestionsView` | `CYLSearchView.emptySuggestionsView` |
| `CYLSearchView.focusesSearchFieldOnShow` | `CYLSearchView.focusesSearchFieldOnShow` |
| `CYLSearchView.searchOpen` | `CYLSearchView.isSearchOpen` |
| `CYLSearchView.animationDuration` | `CYLSearchView.animationDuration` |
| `CYLSearchView.closesOnSubmit` | `CYLSearchView.closesOnSubmit` |
| `CYLSearchView.query` | `CYLSearchView.query` |
| `CYLSearchView.backgroundColor` | `CYLSearchView.backgroundColor` |
| `CYLSearchView.init(frame:)` | `new CYLSearchView(…)` |
| `CYLSearchView.init(coder:)` | TODO: N/A on HarmonyOS: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchView.layoutSubviews()` | TODO: N/A on HarmonyOS: ArkUI lays a component out from its declaration |
| `CYLSearchView.safeAreaInsetsDidChange()` | TODO: N/A on HarmonyOS: ArkUI keeps the page inside the safe area by itself |
| `CYLSearchView.install(in:)` | `CYLSearchView.installInView` |
| `CYLSearchView.showSearch()` | `CYLSearchView.showSearch` |
| `CYLSearchView.showSearch(animated:)` | `CYLSearchView.showSearch` |
| `CYLSearchView.closeSearch()` | `CYLSearchView.closeSearch` |
| `CYLSearchView.closeSearch(animated:)` | `CYLSearchView.closeSearch` |
| `CYLSearchView.closeSearch(animated:completion:)` | `CYLSearchView.closeSearch` |
| `CYLSearchView.encodeRestorableState(with:)` | `CYLSearchView.encodeRestorableState` |
| `CYLSearchView.decodeRestorableState(with:)` | `CYLSearchView.decodeRestorableState` |
| `CYLSearchView.accessibilityPerformEscape()` | `CYLSearchView.accessibilityPerformEscape` |
| `CYLSearchView.attach(to:)` | `CYLSearchView.attachToMenuItem` |
| `CYLSearchView.setQuery(_:submit:)` | `CYLSearchView.setQuery` |
| `CYLSearchView.showSuggestions()` | `CYLSearchView.showSuggestions` |
| `CYLSearchView.reloadResults()` | `CYLSearchView.reloadResults` |
| `CYLSearchView.dismissSuggestions()` | `CYLSearchView.dismissSuggestions` |
| `CYLSearchView.clearSuggestionCache()` | `CYLSearchView.clearSuggestionCache` |
| `CYLSearchView.searchBarView(_:textDidChange:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewSearchButtonClicked(_:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewNavigationButtonClicked(_:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewVoiceButtonClicked(_:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewCancelButtonClicked(_:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewDidBeginEditing(_:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewDidEndEditing(_:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:numberOfRowsInSection:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:cellForRowAt:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:didSelectRowAt:)` | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
<!-- harmonyos-api:end -->

## Table 2: iOS example demos

<!-- harmonyos-demos:begin -->
| iOS example demo | HarmonyOS implementation |
| :--- | :--- |
| Tab bar: CYLTabBarController with Search, Examples, Tag style, Discover and the plus button (CYLTabBarConfiguration.json) (`CYLSearchExampleAppDelegate.m`) | `pages/Index.ets` on CYLTabBarController's HarmonyOS library `cyltabbar` (commit 94eb7b1), configured by the iOS CYLTabBarConfiguration.json |
| Search tab: Issue #1317 reproduction, the search bar in the navigation bar over a list (UISearchController, the CYLSearchView refresh API; Overlay: a CYLSearchView with resultsDataSource) (`CYLSearchExampleViewController.swift`) | `demos/SearchExample.ets` `SearchExampleView`: the list inside `CYLSearchRefreshComponent` with `CYLSearchView.setRefreshHandler` / `endRefreshingIn` (Repro); Overlay: a `CYLSearchView` with `resultsDataSource` and its own `refreshHandler` |
| Search tab: pull to refresh with CYLTableViewPlaceHolder's CYLRefreshNormalHeader (`CYLSearchExampleViewController.swift`) | `SearchExampleView` with CYLTableViewPlaceHolder's HarmonyOS library `cylplaceholder` (commit 5bcbdb5): `CYLRefreshContainer` + `CYLRefreshNormalHeaderModel` |
| Search tab: the empty state, the CYLPlaceholderView of CYLTableViewPlaceHolder, "No matching results" (`CYLSearchExampleViewController.swift`) | `SearchExampleView` with cylplaceholder's `CYLPlaceholderView` (`CYLPlaceholderViewModel.initWithStyleMessage`, no results) |
| Examples tab: the menu (Search and refresh, Placeholder styles, Search bar, Ports) (`CYLSearchDemoMenuViewController.m`) | `demos/ExamplesMenu.ets` `ExamplesMenuView` |
| Placeholder styles: the 41 styles x 4 messages and the Custom section (text only, image only, both) (`CYLSearchDemoMenuViewController.m`) | `PlaceholderGalleryPage` (the iOS images, `imageForStyle`) |
| Placeholder styles: the detail page with one CYLPlaceholderView (CYLTableViewPlaceHolder) (`CYLSearchDemoMenuViewController.m`) | `PlaceholderDetailPage` with cylplaceholder's `CYLPlaceholderView` |
| Search bar page (plus button and Examples): CYLSearchBarView styles and appended items (`CYLSearchBarDemoViewController.m`) | `demos/SearchBarDemo.ets` `SearchBarDemoView` |
| Ports: the menu of five search libraries (`CYLSearchPortsViewController.swift`) | `PortsMenuPage` |
| Port: lapism/search (MaterialSearchBar + MaterialSearchView) (`CYLLapismSearchViewController.swift`) | `demos/Ports.ets` `LapismPage` |
| Port: MiguelCatalan/MaterialSearchView, the menu of six samples (`CYLMaterialSearchMenuViewController.swift`) | `demos/MaterialSearch.ets` `MaterialMenuView` |
| MaterialSearchView sample: Default (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 0 |
| MaterialSearchView sample: Themed (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 1 |
| MaterialSearchView sample: Voice (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 2, `common/SpeechRecognizer.ets` (CoreSpeechKit, microphone permission; zh-CN, the engine's only language) |
| MaterialSearchView sample: Sticky (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 3 |
| MaterialSearchView sample: Tabs (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 4 |
| MaterialSearchView sample: Input type (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 5 |
| Port: yechaoa/MaterialDesign SearchViewActivity (`CYLYechaoaSearchViewController.swift`) | `YechaoaPage` |
| Port: android-cjj/MaterialSearchView circular reveal (`CYLRevealSearchViewController.swift`) | `RevealPage` (core `iconButtonBackgroundColor`, `iconButtonTintColor`) |
| Port: iammert/MultiSearchView (`CYLMultiSearchDemoViewController.swift`) | `MultiSearchDemoPage` |
| Tag style tab: the six MaterialSearchView samples with tag suggestions, keyboard down on show (`CYLSuggestionDemoPages.swift`) | `MaterialMenuView({ tags: true })` |
| Discover tab: recent searches and discover topics copied from CollectionViewClassifyMenu (`CYLSearchDiscoverViewController.swift`) | `demos/Discover.ets` `DiscoverView` (rawfile `discover/<language>.json`) |
| Snackbar: a short message at the bottom (CYLSnackbar) (`CYLSearchPortsViewController.swift`) | `common/DemoCommon.ets` `CYLSnackbar` |
| Texts in English, Japanese, Simplified and Traditional Chinese (`CYLSearchViewController.bundle`) | resources base, ja_JP, zh_CN, zh_TW (`harmonyos/scripts/import-ios-resources.py`) |
| Dark mode follows the system (`CYLSearchExample`) | `sys.color.*` and `resources/dark` colors |
<!-- harmonyos-demos:end -->
