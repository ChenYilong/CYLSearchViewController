> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Written by a subagent: its claims and contradictions were NOT re-checked (only items marked S in 02-findings.md were). What the source documents report as done or passing is their claim.

# D. Animated icon, tab bar integration, dependency and TODO documents

Digest written 2026-11-29. Short names used in citations:
- **AIC** = docs/animated-icon-component.md
- **TBI** = docs/CYLTabBarController-Integration.md
- **HO** = docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md
- **SUB** = docs/sub-repositories.md

Unless section 1 says "checked", everything below is what a document **claims**. Builds, tests, device runs and screenshots were not verified. Commit hashes are as written.

## 0. What each document is

- AIC: progress ledger for CYLTabBarController's guide `docs/Animated-Item.md` (upstream repo). It holds a Done table, a table titled "TODO" (most rows are really DONE; rows are not in numeric order, AIC:45-65), the owner's cross-platform UI contracts of 2026-11-24 (AIC:67-256), then older DONE/TODO task entries (AIC:265-666).
- TBI: default tab bar integration, public API comment rule, SVGA/Rive tab icons, Swift adaptation, the contact tags example, mini program drag/scroll fixes, tab switch contract, tag drag scroll hold.
- HO: handover written 2026-11-26 by the Windows coordination session; sections 10-17 added by the Mac iOS session; 18-21 are 2026-11-27 follow-ups. Newest statements in this document set. Folder rule: `docs/todo/<year><month><week>`, week = ceil(day/7); one file per folder, later notes appended (HO:4-5, 389).
- SUB: sibling dependency ledger; newest entry is 2026-11-20 (SUB:283-304), so its pins are stale.
- docs/svga-tab-icons.md: redirect stub only (2026-11-16) to TBI "SVGA animations ..." section (svga-tab-icons.md:3-6).
- Six SVGA NOTICE files: see section 12.

## 1. Checked by me (targeted read-only checks, working tree, 2026-11-29)

- **Pins still split**, matching HO:68-75: Android tab bar `af56db22` (android/merged/gradle.properties:8); HarmonyOS `d19e138e` (harmonyos/oh-package.json5:5); mini program `08343e9f` (CrossPlatform/wechat-miniprogram-cylsearch/package.json:34); Flutter pubspec `08343e9f` (flutter_cylsearch/example/pubspec.yaml:23); root and Flutter iOS Podfiles `08343e9f` (Podfile:20,24; Flutter Podfile:37,39). ClassifyMenu `c0b183de` (gradle.properties:11, oh-package.json5:7, package.json:36, three Podfiles). Placeholder `f4cf9785`. Dealloc `eab21d10` in the three Podfiles. RN's git-ignored vendor copy commit was not checked.
- CYLSearchViewController.podspec: version `0.1.0` (:3); depends on CollectionViewClassifyMenu, CYLAnimatedItem, CYLTableViewPlaceHolder/Core, `CYLDeallocBlockExecutor ~> 1.4` (:20,27,36,40). Consistent with release gaps M2/M4 (HO:241,243).
- .github/workflows/ios.yml:21-23 has a concurrency group with `cancel-in-progress: false`.
- Sources/CYLSearchBar/CYLSearchController.swift has `pageView.removeFromSuperview()` at :487 and a `deinit` doing the same at :493-494: consistent with the I1 fix claim (HO:410). Behaviour not tested.
- CYLSearchExample/CYLSearchDiscover.bundle/search_camera.json header says w 36, h 36 (so HO:323 is right; HO:157 and HO:185 are superseded; AIC:75 says the iOS canonical file is 44 x 44, stale).
- Sources/CYLSearchBar/CYLSearchTagListStyle.swift:25: `tagCornerRadius` defaults to the library constant `CYLAnimatedItemCornerRadiusCapsule` (supersedes AIC:101's repo-local `capsuleCornerRadius` on iOS; Android not checked).
- Sources/CYLSearchBar now has 13 Swift files plus instructions.md (TBI:62-63 says the Swift core is three files).
- The six SVGA NOTICE files are byte-identical.
- All four large files were re-read chunk by chunk with the Read tool and compared line by line to an in-memory copy: no differences, nothing truncated.

## 2. Standing rules and contracts

### 2.1 Pinning and dependencies
- CYLTabBarController is integrated by default: root built with `+tabBarControllerWithConfigurationFile:error:`; plus button declared under `CYLTabBarControllerPlusButton`, its `CYLTabBarItemPageIdentifier` resolving to the plus child VC; pages via `CYLTabBarPageRegistry` providers; newest commit via `scripts/latest-cyl-commit.sh --podfile`; recipe `.agents/skills/cyl-tabbar-integration/SKILL.md` (TBI:16-26). `Sources/` does not import CYLTabBarController (TBI:94). CI warns when the pin is not newest; on upstream change also compare upstream AGENTS.md and cyl-* skills and update recorded commits (TBI:164-167).
- Pin the newest commit of the newest branch; **a merged pull request branch does not count** (AIC:34, 589-592; owner chose merge commit 9a54e26 over a newer commit on the merged branch).
- Unpublished components come in **by commit** (:git + :commit); no local `:path` in a commit (AIC:21, 618-620; SUB:30). Owner: "don't let anything block progress" (SUB:147-149).
- **Move the tab bar pin only together with a ClassifyMenu commit that bundles the same tab bar commit**; the mini program and HarmonyOS use ClassifyMenu's vendored copies (AIC:56-57, 633-651; mismatch broke ArkTS compile and mini program test). HarmonyOS must keep exactly one `cylanimateditem` (AIC:394-395). `test/package.test.js` requires the synced `cyl-animated-item/COMMIT` to equal `cylTabBarControllerCommit` (AIC:210).
- Missing interfaces are added in the sub-repository first, pushed, then pinned; core exposes the feature by enum/parameter; example passes only data, style, taps (SUB:28-32).
- 2026-11-26 rule: every platform pins the same pair; the Mac session announces it; Windows repins once (HO:15, 77). A CI check that RN `example/vendor/CYLTabBarController` equals the pin is missing; the mismatch is silent (HO:77-78).
- Pin files historically touched together: Podfiles (root, Flutter, RN), android/merged/gradle.properties, harmonyos/oh-package.json5 (+ vendor sync), mini program package.json, Flutter pubspec.yaml/lock (TBI:1040-1041). Android `settings.gradle.kts` git steps have a 10-minute limit, one retry, `core.longpaths=true` (SUB:158-161). `cyl.tabbar.ios.commit` is an optional iOS-only override read first by RN iOS `fetch-cyltabbar.sh`; deleted 2026-11-20 (SUB:285-298).
- Core depends on `CYLAnimatedItem` (Core subspec: static images, no engine); only examples add engines `CYLAnimatedItem/<Type>` (LottieObjectiveC, Lottie, LottieSwift, PAG, PAGEnterprise, Rive, SVGA, GIF, Engine) (AIC:19-20, 514-530).
- Android: package `com.cyl.animateditem`; `settings.gradle.kts` includes `:cylanimateditem` and substitutes `io.github.chenyilong:cyltabbarcontroller-animateditem`; cylsearch links no engine, app adds libs.lottie and SVGAPlayer (AIC:24-25, 478-483).
- HarmonyOS: `harmonyos/scripts/sync-sub-repositories.py` (.sh) vendors classifymenu, cylanimateditem*, cyltabbar, cylplaceholder, cyldeallocblockexecutor into git-ignored `harmonyos/vendor`; engines registered by the app in EntryAbility.onCreate; ohpm `overrides` picks one lottie (2.0.38), libpag (4.5.102), rive (1.0.4) (AIC:348-351, 633-644, 225).
- Mini program: `node scripts/sync-example.js` installs sub-packages; engines pass through abstract nodes cyl-lottie-view / -pag- / -rive- / -svga- (default cyl-animation-placeholder), forwarded by cyl-search and cyl-search-bar (AIC:645-652). The script must copy every placeholder component (AIC:52).

### 2.2 One animated icon+title component
- Everything with icon+title or animated icon uses ClassifyMenu's `CYLTagButton` (a `CYLAnimatedItemView`), so a new animation type is added once (AIC:276-288). CYLTableViewPlaceHolder instead builds `CYLPlaceholderView` directly on CYLAnimatedItem; accepted as meeting the goal (AIC:384-396).
- Search bar items: iOS `CYLSearchBarItemButton: CYLTagButton`; `animationURL` forwarded and played on tap; 36 pt touch area (44 vp HarmonyOS; mini program 36 px) (AIC:318-364). HarmonyOS/mini program: while loading or with no engine, static image shows; a system symbol cannot be drawn there so a placeholder shows (AIC:655-657).
- Display priority: animation if playable; else static image; placeholder only for an animated item with no image; text item never (AIC:485-487).
- Since 2026-11-18: mini program `cyl-tag-button` autoplay default false: an animated icon rests until played (owner rule, as iOS) (AIC:53).
- CYLAnimatedItemView is Swift since upstream `4c7dc79d` (same ObjC API; Objective-C cannot subclass it; SwiftPM `import CYLAnimatedItemViews`) (TBI:397-400). Its `style` property was renamed `itemStyle` upstream (TBI:1034-1042).
- Item API on every platform: `animationLoops`, `animationSpeed`, `restartAnimation()` (playAnimation() on HarmonyOS/mini program); Flutter `restartItemAnimation`, RN ref command `restartItemAnimation(index)`; iOS `item(dictionary:)` / Android `fromMap` read the keys (AIC:64). Advisor verdict 2026-11-23: call upstream directly, **no JS/Dart wrapper** (second platform view would break layout, touch area, accessibility, reload file, add packaging deps). Fix: `setItems(dictionaries:)`/`setItems(maps)` keep unchanged items and update loops/speed in place instead of rebuilding (AIC:65). Optional open: forward animationSpeed only when set.
- Rive (row 40): no core has Rive code; HarmonyOS example uses `CYLRiveAnimationBuilder` via ClassifyMenu `86d085c7` `registerItemBuilder`; HarmonyOS pin `325c7a31`; not compiled (AIC:63).

### 2.3 Animation demo rule (owner 2026-11-24, AIC:67-75)
Animate an item the bar already has (camera button becomes Lottie `search_camera.json`, static camera as fallback); never add a demo item. Bar keeps field, camera, divider, Search. Loop/speed/Play-again controls go at the end of the scrolling content or pinned above the tab bar; ids `CYLSearchDiscoverAnimationLoops/Speed/Play`. Changing loops/speed never reloads. Canonical asset in CYLSearchDiscover.bundle (30 fps, 60 frames, first=last frame). Table status: iOS (a746489), Flutter and RN iOS halves done; their Android halves, native Android, HarmonyOS, mini program TODO (AIC:77-84).

### 2.4 Default layout contract (owner 2026-11-24, AIC:86-102)
- Cause of Flutter/RN looking different: page shells, not components; alignment belongs in the core.
- One 16 pt/dp inset: bar capsule `contentInsets` (6,16,6,16; was 12), section header, tags. Examples add no padding for these components. Test `testBarCapsuleLinesUpWithTheTagListInset`.
- Tag list owns its header: `sectionTitle`, `showsClearButton`, `showsRefreshButton` (arrow.clockwise, string `tagList.refresh` en/ja/zh-Hans/zh-Hant; refresh wins over trash).
- Default tag look `CYLSearchTagListStyle` (capsule, 1 pt separator border, 17 pt, 36 pt high, 12 spacing, 16 inset, bold 20 header), only via ClassifyMenu public API; customize with `tagCornerRadius`, `styleCustomizer`.
- Every text from localization files in four languages; Flutter/RN copy iOS data; RN picks iOS preferred language because Hermes Intl follows app localizations. RN tab titles localized; other RN demo pages and Flutter tab titles still English (AIC:102).
- Discover topics grid is NOT in core but must be built from ClassifyMenu tag list (iOS `gridStyle(itemsPerRow: 2)`, `menuImageForItem`; bridges `columns`, `tagImages`, `foldedRowCount: 0`, helper `applyGrid(columns:to:)`) (AIC:98). Open owner question: bold header as core default (AIC:94).

### 2.5 Corner radius, final rule 8b (AIC:100-101)
Plain points clamped to half height; **0 = square**; capsule = ONE named constant (value 1000) which callers use, never the literal; no other special values; `CYLTagCornerRadiusSquare` deleted. Supersedes rule 8 (AIC:100), ClassifyMenu PR #36's restored constant, Android "0 = capsule", and the temporary private 0.001 "square" value. Deliberately kept: search field `-1` sentinel (`textFieldCornerRadius`/`fieldCornerRadius`) (AIC:194).

### 2.6 Refresh / data / navigation bar contract (2026-11-24, AIC:104-144)
- A: refresh **icon** built into each library (iOS `CYLSearchTagListHeader.applyRefreshIcon(to:)`, re-apply after assigning `style`; Android `cyl_search_ic_refresh` Apache-2.0 Material with notice; HarmonyOS `sys.symbol.arrow_clockwise` verified in SDK; mini program SVG in the component package). Never guess symbol names.
- B: single source `CYLSearchExample/CYLSearchDiscover.bundle/<lang>.lproj/search-discover.json`; copies via `python3 scripts/sync-discover-data.py` (`--check`; add copies to `COPIES`). 4 pages x 6 = 24 records `{title, icon:"hot"}`; one hot per page, source slots 0,3,5,1 (records 0,9,17,19), different from the neighbour page incl. wrap; refresh = next page cyclically, no random. Position comes from data order. Open interpretation: if "database" meant SQLite, only the loader changes.
- C: search bar always in a navigation bar, one core entry per platform: iOS `embedInNavigationBar(of:)` (titleView, else core-made `CYLSearchNavigationBar`, top safe area +44; bridges use `CYLSearchNavigationBar.holding(_:showsBackButton:)` + `backHandler` which does not pop); bridges prop `embedsInNavigationBar`; Android `embedInToolbar`; HarmonyOS `CYLSearchNavigationPage` (NavDestination title builder, else Navigation; `layoutWeight(1)`); mini program `cyl-search-navigation-bar` (`cylNavigationBarWidthsFrom`, clears menu capsule).
- Field is 36 pt embedded (was 46). **Width is the core's job**: embedded iOS bar answers `sizeThatFits`/`intrinsicContentSize` with `layoutFittingExpandedSize.width` because the nav bar first asks with width 0; test `testEmbeddedBarAsksForTheWholeWidthAndAPlainBarKeepsItsOwn`. Beside a back button only the trailing 16 inset aligns (expected). Title view is not laid out in a headless window, so width is checked on a simulator (AIC:139-143).
- Discover is **always a second-level page with a back button**, never a tab root (entry VC/page pushes it). This supersedes the `-CYLDemoPushDiscover` argument (AIC:141-142). AIC:142 verbatim: "A pushed Flutter route covers the page but keeps the native tab bar visible after the back tap (it is hidden while the route is open)."
- Flutter bug: `Scaffold.appBar` adds status-bar height itself, so PreferredSize must be 44 (it was counted twice).

### 2.7 Test hand-over standard (AIC:146-170)
Write code first; test each platform once in one batch; do not wait for CI or other sessions. Five conditions: (1) code complete with file:line per spec item; (2) static checks green (`sync-discover-data.py --check`, check-public-api-comments.sh, check-screenshot-labels.sh, check-licenses.sh, yarn typecheck, flutter analyze, Kotlin compile if possible); (3) no open owner TODO for the platform in docs/task-log.md; (4) record real `git rev-parse HEAD` of pinned checkouts in screenshot footers; (5) own device free (Windows heavy lock). Screenshots en + zh-Hans + back tap. CI last: every push replaces the pending run, so push once and wait. Assignments: Mac = iOS core, iOS examples, Dart/TS + iOS halves, sync script; Windows sessions = Android / Flutter+RN Android halves, and HarmonyOS + mini program; own clone/worktree (stash is shared across worktrees), `git pull --rebase` before push (AIC:242-247). HO:83-84 later says never rebase published history (merge origin).

### 2.8 Tab switch contract (TBI:928-930)
After every switch exactly one item is selected; all others show unselected image/tint/title/resting frame and play nothing; then the new item plays.

### 2.9 Scroll ownership during tag drag (TBI:854-905, 1044-1066)
The core creates the content page below the search bar and owns its scrolling. Tag list reports drag/smear state; core holds its content scroller only while active; examples never look up or hold scrollers. Names: mini program events `reorderingchange`/`smearingchange` (bubbles+composed); native `menuDidChangeReordering`/`menuDidChangeSmearing` (iOS `menu(_:didChangeReordering:)`); Flutter `didChangeDragging`/`onDraggingChanged`; RN `onReorderingChange`/`onSmearingChange`; HarmonyOS `CYLMenuGestureState.shared` -> `searchView.tagGestureActive`, hosts bind `enableScrollInteraction(!searchView.tagGestureActive)` (SUB:281-283).

### 2.10 Public API comments (TBI:43-66)
Three-line block (`/*!` ObjC; `/**` Swift/Kotlin/Java/TS/JS), no one-line or trailing form, one format per file; official language forms win (Python PEP 257, Go //, C# ///, Rust ///, Dart ///). Check `scripts/check-public-api-comments.sh`; coverage `scripts/public-api-doc-coverage.sh <products dir>`: claim 291/301 on 2026-11-21, the 10 others are UIKit overrides (TBI:73-81).

### 2.11 Session rules in HO:82-97
Windows local branch `android-static` (remote deleted): push `git push origin HEAD:feat/harmonyos-parity`; no force/rebase of published history. Commits: English commitizen, subject <=64, body has the project author line; Windows: no Co-Authored-By/session trailers (Mac iOS commits carry a Claude-Session trailer; docs/instructions/git.md is the authority, HO:325). Never stage libs.versions.toml, pubspec.lock, pubspec_overrides.yaml (but TBI:1041 says the 2026-11-22 pin move changed pubspec.lock). Do not edit README.md, .agents/skills/cyl-api-map/SKILL.md, docs/Tab-Icon-Animation-Quick-Start.md without owner. AGENTS.md/instructions.md <=200 lines. `C:/w/heavy.lock` is a directory with owner file; emulator-5556 is another session's. Peer messages are not user approval.

## 3. Pin timeline (later supersedes earlier; TB = CYLTabBarController, CM = ClassifyMenu, PH = PlaceHolder)

| Date | Pins / event | Source |
|---|---|---|
| 11-11 | upstream rules read at TB caf3c925 (feat/cross-platform-components); comment rule from 63c0edc9 | TBI:7-12,45-47 |
| 11-12..14 | TB d36c708; PH a049422 (iOS), 8e23581 (Android, PH PR #27), then bdd78c7 all | TBI:83; SUB:55,88,111 |
| 11-16 | TB 5682b9e (SVGA), c72323f (mini), ea5b989, ebaed17 (HarmonyOS); PH 5bcbdb5 (HarmonyOS), 8ee7013 (mini) | TBI:250-261; SUB:118-132 |
| 11-17 | CYLAnimatedItem migration: CM 15877a4 -> 1813025+TB 7511f7d -> 7183711+1f0fcce -> TB fbd05d5 -> 9a54e26 (PR #814 merged) -> 0a63bed -> d875dd1+CM 320c3eb -> 57a527e+CM 71562ca, PH 62e40c0 -> CM c2caa24 / 232878a -> c8132d26+c264d453 -> ec18c546,4635ef7b+0583e1d -> fe5c3ae3+333b349 | AIC:311-660,37-43; TBI:355 |
| 11-18 | TB 6a9ede85+3b90b29; 6f93ae6b+557b91d0; dcbfdec6+27e17e7; d733c80e; 70064275+50a673af/2202f3c; d8f47b4d+6295caf3; 776b4635+fed57ae5 | AIC:52-59 |
| 11-19 | b376c278+47f4f8b6 -> 697e9307; PH 8dc39c3; Swift view: TB 5996fa96+CM d6a94ce9+PH f7e0c4d; contact tags: CM 3fc2c23b+PH d19120f; CM 43ec09ce+TB 5744917d; CM 3af1b7cd+PH e984868; PH b18b617; CM 357478ba+f88d67a8; c966c527+9a4ad95e; 272f569a; 542a0094/c43eebcd+74f0b4cd; a32ab9e7; cf5d9f7e; 2ec3d90e | AIC:60-61; TBI:410-760; SUB:150-244 |
| 11-20 | CM 3bfa201a; PH f1a9052; dc5910f5+TB 8ece77dd (iOS 15 min, Swift CYLTabBarController); 8c141d8c; ab84db37+8b7dea18+PH c84fce90; 954edf8c+41660d24; 53608bb5; cf478388 | SUB:245-304 |
| 11-22 | TB ace1af0e (PR #822)+CM 1f8c1001 on every platform; RN smear tested at CM pin 9dc1f76 | TBI:1039-1041,1129 |
| 11-23 | all 7 pin files c4a1f8fd (HarmonyOS f51057a7) -> f66e85d5 (static only); HarmonyOS 325c7a31 | AIC:62-63 |
| 11-24 | f45a8f1d (+CM 04b39e26, PH f4cf9785); CM cd95371c; CM 4be6cda+c6b3e976; CM 551072a+b4299707; candidate 4bc1ec1+dea0951e "not final"; Dealloc 4276a6d (Object.assign) merged | AIC:167-236 |
| 11-26 | split: see section 1. Newest TB engine branch head ff2ada53 (contains HarmonyOS tint fix 53372bce) | HO:16, 66-75 |
| 11-27 | Flutter/RN Android build broken by the split; tab bar session proposes 2b99043f or newer; waiting for owner (HO section 8 item 9) | HO:418, 432 |

Notes: row 41 (AIC:64) says pins at f66e85d5 do not build the RN iOS example; PR #824 commit needed. SUB:151-157: PH 8dc39c3 needed TB >= 4f73209c. SUB:203-205: three pin changes went out inside commit 9e0ff66 because commit type `build` is not allowed.

## 4. Tab bar integration facts

- iOS example config `CYLSearchExample/CYLTabBarConfiguration.json`; plus page ID `plus` = search bar demo; every page in a UINavigationController (keeps Issue #1317 setup); unreadable config -> log + examples menu (TBI:85-94). Titles are keys localized in CYLSearchTabs.bundle; Info.plist needs `CFBundleLocalizations` or titles stay English (TBI:95-99).
- Static-framework pod bundles need "[CP] Copy Pods Resources" phase, else raw keys like `CYLRefreshHeaderIdleText` (TBI:102-105).
- Search bar never covers a view: results screen excludes top edge extension; stacked placement; iOS 26 `searchBarPlacementAllowsToolbarIntegration = NO`; tests `testSearchBarsCoverNoView`, `testSearchBarNeverCoversTheViewControllersView`; iOS 26 shows searchTextField without UISearchBar (TBI:113-132). Parts describe the pre-rebuild system search bar; HO:275 says UISearchBar subclass was deleted 2026-11-26.
- iOS 27 SDK apps need UIScene life cycle (`CYLSearchExampleSceneDelegate`); use `navigationItem.title` so pages do not rename tabs (TBI:133-139).
- **Raised plus button**: prefer it in demos (top above the bar). `CYLPlusButtonCenterYMultiplier` alone does nothing when the plus button has a title (`cyl_showsTitleInTabBarItem`: it sits inside the item). Working iOS recipe (a5158b8, 2026-11-21): `CYLPlusButtonAlignsTitle` false + `CYLPlusButtonSize {64,84}` + multiplier 0.3 + 52 pt image asset `CYLPlusButton` (`CYLPlusButtonImageSize` would redraw the SF Symbol black); in all three configs; test `testPlusButtonIsRaisedAboveTheTabBar`. Minor open: title is core default gray; `CYLTabBarItemTitleColor` takes only hex (TBI:169-214). On Android/RN (11-17) the core now lays out the plus button, so size/multiplier/offset keys were removed from RN, native Android multiplier and Flutter offset/size; Flutter not rebuilt then; mini program keeps its multiplier (TBI:356-361).
- **SVGA** (done 11-19, score 100): iOS `-CYLDemoTabIconSource` 0 symbols (default) / 1 keys (`CYLTabBarSVGAURL`,`CYLTabBarSVGASize`) / 2 file (`CYLTabBarConfiguration_svga.json`, `CYLTabBarSVGAFilePath`); dark keys `CYLTabBarSVGADarkURL/FilePath`; `-CYLDemoTabBarStyle flatDesign`; in-page header `CYLSVGADemoTagButton.swift` with tab_activity.svga; SwiftUI host `CYLSVGASwiftUIDemo.swift` (`-CYLDemoTab 1 -CYLDemoRow 4`). Android `--es CYLDemoTabIconSource 2`, SVGAPlayer-Android 2.6.1 (JitPack), needs `tools:replace="android:allowBackup,android:label"`. Flutter `--dart-define=CYL_DEMO_TAB_ICON_SOURCE=2`. HarmonyOS `--pi CYLDemoTabIconSource n`, files in rawfile/svga; no SwiftUI host. Mini program `*.svga.bin` 30x30, test svga-tab-icons.test.js (TBI:216-311). RN iOS: Podfile adds TB/SVGA + SVGAPlayerLite 1.0.8 with module maps; copy phase (TBI:252). `axe` lists every element twice there, so tap by coordinates (TBI:283-284). Flutter plugin platform views needed `@MainActor` (TBI:307-308). Known upstream bug: switching dark->light at runtime keeps dark SVGA files (TBI:245). RN Android c795d08: tab icons empty due to `system:` names, TODO then (TBI:910-915, an orphaned fragment placed after the drag section).
- **Rive** (done 11-19): `icons.riv` fetched at build time, not committed (no own license, owner decision 11-16); artboards CHAT, SEARCH, BELL, USER; state machine `<ARTBOARD>_Interactivity`, input `active`; 28 pt; Rive is default for Flutter/RN (`CYL_DEMO_TAB_ICON_SOURCE` 3; 2 SVGA; 0 PNG). Android `app.rive:rive-android` 10.3.0, Gradle task `fetchCylRiveIcons` (TBI:363-390). Tint: icons.riv draws light strokes, so set `tint: 'title'` in CYLTabBarAnimationOptions (TBI:345-355; iOS honoured from d733c80e, AIC:56). HarmonyOS @ohos/rive is arm64-only; x86_64 shows static fallback (AIC:54). RN needed removal of stale `react-native-cyltabbar/android/build` (AIC:54).
- Simulated-tap quirk: axe taps on RN/Flutter iOS CYLTabBarController tabs only highlighted (11-18/19, TBI:691-693, 712-714; AIC:55 B-b); AIC:56 says B-b/B-c fixed (3ee06877 EagerGestureRecognizer; 51d58545), rechecked 11-19. TBI 691/712 observations at 9a4ad95e/5744917d are before the tap fix 3ddb2868 pinned via 74f0b4cd (SUB:222-224).

## 5. Contact tags example (TBI:419-760)

- iOS: Examples row 6 (`-CYLDemoRow 5`) "Edit Remarks" -> "Edit Tags" sheet; search field is CYLSearchBarView; CYLContactTags.bundle (47 tags, en/ja/zh-Hans/zh-Hant; `contact-tags.json` v2 `{id,title}`, ids t01-t47, new u-*, other device o-*; 24 contacts bound by id). Placeholder `.noResults`/`.empty` above keyboard; `reportsContentSize`. Bug fixed: search bar stretched/collapsed because tag list intrinsic height outranked it (TBI:463-464).
- ClassifyMenu APIs added for it: `setEditing(_:animated:)`, `CYLTagListStore`/`CYLTagListCachePolicy`, `editingFinishHandler`, `CYLTagListRemoteSource`, `CYLTagListLoadPolicy` (cacheThenNetwork default, cacheFirst, networkFirst), rename + `menuIdentifierForItem`, built-in header clear button (images in folder bundle CYLClassifyMenuImages.bundle), `editingIndicatorSpacing` 8, insets left 4 right 2. This repo's core: `CYLSearchBarView.editingBar(placeholder:actionTitle:)` + `pinToKeyboard(in:)`.
- Simulated sync: cache A local, cache B "server" sandbox file, 5 s latency + CYLPlaceholderHUD; leaving Manage uploads; opening downloads B into A (follow-up requirement); sync button = other device (random tag + swap first two). Args: `-CYLContactTagsResetCache YES`, `-CYLContactTagsEmpty YES`, `-CYLContactTagsEditor YES`, `-CYLContactTagsServerLatency`, `-CYLContactTagsLoadPolicy`. Android intent extras and HarmonyOS `--pi` same names; mini program query reset/empty/editor/latency.
- Ports done 11-19 on all platforms (score 100). Differences: Android Edit Tags is pushed page; load policy arg not ported to Android; RN/Flutter caches in memory, HUD drawn by example, RN English only. CYLContactTags added to `check-ios-parity.mjs` (549/549).
- Bridge API: tagIds, selectedIds, sectionTitle, showsClearButton, editing, supportsRenaming; events delete/move/renameRequest/clear; editingBar + actionTitle + editingSubmit; placeholder view (TBI:662-701).

## 6. Past bugs: root causes and fixes

| Symptom | Root cause | Fix | Source |
|---|---|---|---|
| Mini program drag still scrolls (phone) | `min-height:100vh` made the PAGE the scroller, so scroll-view `scroll-y` held nothing; iOS ignores body overflow hidden | fixed height + overflow hidden, `.list{min-height:0}`, `disableScroll:true` | TBI:821-832 |
| `catchtouchmove` lock did not stop scrolling | in WAWebview `catch*` only stops propagation; only built-ins preventDefault | only lock is the real scroller's `scroll-y` | TBI:825-829 |
| 2ec3d90e lock too late | WeChat decides scrollability at first touchstart | superseded twice (3bfa201a, then page layout, then core cyl-search `.cyl-content` scroll-view holding itself) | TBI:793-795, 854-875 |
| Delete/pencil ignore real tap (mini) | `catchtouchstart="noop"` suppresses tap on base lib 3.6.6 (works 3.18.0) | `mut-bind:touchstart` (CM a32ab9e7). Earlier `trigger('tap')` handler check gave false pass; use `element.tap()` | TBI:743-756 |
| Two tabs selected (mini SVGA) | previous animation not stopped | container stops/rests others first (TB 41660d24) | TBI:949-950 |
| Android "More" leaves previous SVGA | `cyl_moreButtonTapped` bypasses selectedIndex setter; SVGA animator has no deselect step | `cyl_stopAnimationsOfAllTabBarItemsExcept` (c1abdffe); recording-animator test `CYLTabBarMoreAnimationTest` | TBI:991-1008 |
| classifymenu compile fail after repin | upstream added `style` to CYLAnimatedItemView, clashing with CYLTagButton.style (iOS too) | renamed `itemStyle`, PR #822 = ace1af0e; verified 8/8 | TBI:1009-1042 |
| Flutter: tag drag scrolls list / never starts | platform view without recognizer loses gesture arena to Dart scroll view | LongPressGestureRecognizer on platform view (7f61043); iOS first failed, later worked at 1f8c1001/ace1af0e (not bisected) | TBI:1081-1121 |
| Flutter iOS loses selection leaving Manage | selectedIds applied before setEditing(false); no further update | apply after editing change + didChangeEditing (3c75b17) | TBI:708-711 |
| Flutter Discover empty glass box | 4 platform-view widgets dropped changes made before creation callback | `_created` sends update; test cyl_created_update_test.dart; **no device run** | HO:398 |
| Platform-view title+Manage one a11y node | merged semantics | separate containers | TBI:657-658 |
| RN smear never fired | no prop to enable | `allowsSmearSelection` default false | TBI:1126-1133 |
| DevTools "registry.js is not defined" | DevTools 2.02.0 drops sibling modules when `module.exports={...require()}` object spread | use `Object.assign` (upstream CYLDeallocBlockExecutor; vendored at b4299707) | AIC:221, 225 |
| Mini example blank, cyl_placeholder_hud not defined | sync-example.js copied only 2 of 4 PH components | copy all | AIC:52 |
| 8 null-prop warnings | cyl-tag-button initial `data.view={}` | `view:{iconKind:"none"}` | AIC:52-53 |
| Mini SVGA never plays | cyl-svga/pag/rive reloaded needlessly | TB ec18c546 | AIC:43 |
| Mini svga.bin no icon | own extension list without svga | `cylAnimatedItemType()` | AIC:42 |
| Android SVGA "never plays" | NOT a bug: clickable tag consumed taps; screenshots too slow | isClickable=false | AIC:39-40 |
| Android white status bar icons | example theme | `windowLightStatusBar` true (example only) | AIC:38 |
| HarmonyOS standalone tag title cut, took tap | measured without UI context | CM 232878a | AIC:36 |
| HarmonyOS 6 test errors | test HAP built without `-p buildMode=emulatorTest` had arm64 libs; install failed so OLD entry_test ran | rebuild with flag; 56/56 | AIC:217, 223 |
| HarmonyOS resource conflict cyl_navigationBar_back | key declared twice in 4 files | d18bf67 | AIC:216 |
| HarmonyOS "passes" were stale (several pins) | Git Bash turned robocopy `/MIR` into a path; silent failure | copy from PowerShell, check exit code; rechecked 29/29 | SUB:207-213 |
| HarmonyOS sync failing | %LOCALAPPDATA% Temp git caches emptied but folders left | rebuild; script now rebuilds hollow cache; checks claimed in between ran stale/no code | SUB:241-244; AIC:59 |
| Android git checkout hung 28 min | likely partial clone + a cloud-synced folder (guess) | timeouts, retry, longpaths | SUB:158-161 |
| Gradle META-INF/cylanimateditem/LICENSE duplicate | RN bridge compiled cylanimateditem and app also linked module | upstream B9 (4635ef7b) depends on included build | TBI:336-343 |
| RN Android 40 undefined libc++ symbols | SDK path with space -> CMake uses 8.3 name CLANG_~1.EXE -> clang runs as C driver | space-free sdk.dir junction (local.properties) | TBI:321-325 |
| RN Android other machine issues | corrupt Gradle transforms lock; release path >260 chars; Metro fails on subst | delete lock; `react-native bundle` into debug assets; build from short path e.g. C:/w/rn (HO:93) | TBI:328-331 |
| Flutter Android "Unable to locate Dart VM" | dart-vm exe vanished from shared SDK caches; cause unknown | re-downloaded with user consent | AIC:59 |
| RN iOS build failures | ObjC++ ignores `@import` in Swift headers; stray duplicate methods; Swift-only style props; later needs SVGAPlayerLite types before CYLAnimatedItem Swift header; noexcept fixed upstream PR #824 | import headers first in CYLRNSearchSupport.h; applyConfiguration: | AIC:55, 64 |
| Flutter iOS Svga.pbobjc.h not found | both SVGAPlayer and SVGAPlayerLite pods | use SVGAPlayerLite; `pod update Protobuf` (3.21.12->3.27.2); Int for defaultVisibleRows | AIC:55 |
| CI static-lib "overridable members could not be loaded" | CYLAnimatedItemView expected in CYLAnimatedItem but found in CYLTabBarController (diagnosed with `-disable-deserialization-recovery`) | TB 83a8ff8 headers @import CYLAnimatedItem | AIC:50 |
| CI example/tests fail | SVGA animator header moved pods | import `<CYLAnimatedItem/CYLSVGATabBarItemAnimator.h>`; other fixes b2ac3b2, bdf2587 (@objcMembers), e258afd, f21a314 | AIC:49, 609-611 |
| Two early CYLAnimatedItem bugs | missing DEFINES_MODULE; Lottie animator accepted non-Lottie | PR #814 | AIC:30, 601-603 |
| Skill files overwritten | commits 1416a3e, 2db1bd6 replaced all seven cyl-* skills with appended section | restored from db9991a, 1416a3e | SUB:48-50 |
| Pushed page swipe-back lost | hiding system back button disables UIKit swipe back (iOS 27.2); delegate workaround passed unit test but failed on simulator | keep system back button | HO:288 |
| iOS I1/I2/I3 | overlay never removed; results VC no appearance callbacks; no relayout on resize | fixed in core 11-27 (I2 forwards appearance calls, still no containment); suite 153 -> 154 -> 156 | HO:410-414 |
| CI never finishes (I8) | latest finding: stale queued run 45745662592 held the concurrency group | cancelled; macOS runner waits remain | HO:411 |

## 7. Verification recipes

- iOS (HO:306-318): `pod install`; `xcodebuild test -workspace CYLSearchExample.xcworkspace -scheme CYLSearchExample -destination 'platform=iOS Simulator,id=<own UDID>' -derivedDataPath /tmp/cyl-dd`; `bash scripts/check-public-api-comments.sh && bash scripts/check-licenses.sh && bash scripts/check-example-fold.sh`; `shellcheck scripts/*.sh`; `scripts/pod-lint.sh lib`; `sh scripts/check-screenshot-labels.sh <base> <head>` (PR base: `$(git merge-base origin/master HEAD) HEAD`, HO:400). Own simulator only; never `simctl shutdown all`; args -CYLDemoTab, -CYLDemoRow; real input with `axe`.
- Node/mini program: `npm test`; run `node scripts/sync-example.js` first (DevTools beforeCompile does not refresh components, HO:94); private AppID temporarily in project.config.json, revert (HO:95). DevTools: `cli.bat auto --project ... --auto-port 9420 --trust-project` (AIC:218). A project restart once fixed a blank simulator (AIC:53). Use wechatide-skill per repo rules.
- Real drag in DevTools: Windows mouse input on the simulator window (verify window by screenshot match before every press), read state via miniprogram-automator on the same connection (a new connect restarts the simulator); automator synthetic events cannot scroll; always include a control with protection off (TBI:817-820). Expected: swipe on tag scrolls list; long press >=380 ms then drag: scroll 0 and tag moves; move at 300 ms: scrolls (TBI:837-844, 879-884). A control that also passes proves nothing (SUB:274-276).
- Page-level switch table: page-meta first node of page works; page-meta inside component and undocumented wx.setPageStyle do not (TBI:886-899).
- HarmonyOS: build in ASCII mirror C:\cylbuild\harmonyos; `aa test` needs `-s timeout 40000` (15000 cascades) (HO:92,176); emulator test HAP: `hvigorw --mode module -p module=entry@ohosTest -p isOhosTest=true -p buildMode=emulatorTest -p product=default assembleHap` (AIC:223); `node harmonyos/scripts/host-logic-test.mjs`, check-ios-parity.mjs, check-accessibility-i18n.mjs. Hold check launch: `--ps CYLDebugQuery i --pi CYLDebugNoFocus 1 --pi CYLDebugTagGestureActive 1|0` (TBI:1139-1143). `uitest` cannot long-press-drag; `dumpLayout` exposes no text for symbol nodes. One emulator per session: a shared emulator gave untrustworthy results.
- Android: `:cylsearch:testDebugUnitTest :app:assembleDebug`; `android/merged/gradle.properties` pins. Emulators via `pwsh -File scripts/release-ram/restart-emulators.ps1`; AVD CYL_Second_API_37 port 5558 windowed -no-metrics; HarmonyOS "Mate 70 Pro" needs -path and -imageRoot; force-stop app and stop only your emulator (HO:88-91).
- Quick tab switch: tap A, tap B after 0.1/0.25/0.5/0.9 s, 8 switches, wait 3.8 s, compare accessibility `selected` with icon colours. iOS More: temporary uncommitted 6th page in the _svga config, `-CYLDemoTabIconSource 2` (TBI:979-982, 951-956).
- Tag drag: Android, long press on tag padding in Manage, drag 450 px up/300 down, compare header y; plain swipe as control (TBI:1056-1058; script `dragtest.sh` on the Windows machine). Flutter iOS: `axe drag --hold` 0.6/1.2/2.0 s.
- Rive tap proof: bell-region pixel change per frame in 30 fps video (TBI:389-390); Android SVGA play proof: pixel diff vs rest 3338,305,0 of 6400 (AIC:51).
- Screenshots: named `<platform>-<device>-<date>-<what>-at-<sha>.png`, header+footer, dated linking line; originals docs/assets/raw/ (HO:208, 397).
- Heuristic from history: handler-level, unit or stale-mirror checks repeatedly gave false confidence (HO:288, TBI:747, SUB:207).

## 8. Status snapshot (latest claims)

- Advisor judgments (not measurements): HO section 2: features 86, release 76 (HO:29). **HO section 11 supersedes for release decision: progress 84, release readiness 52** (HO:231-247). Release-point gaps M1..M8: no green CI -10; unreleasable dependency chain -15 (Dealloc eab21d10 on unmerged PR #29 stacked on #30; 1.4 not on trunk); split pins -4; breaking iOS API at 0.1.0 without changelog -5; verification gaps -6 (60 UIKit-only tests removed/merged); open defects -5; stale docs -2; PR #11 ~2100 files, #16 conflicts -1.
- Branches (HO:45-64, 11-26): feat/harmonyos-parity = integration (PR #11 -> master, 1117 ahead); nothing reached master since 11-12 (PR #5). fix/qmui-score-100 PR #16 (conflicted, one task-log commit, HO:253). ci-screenshots is artifact only. Merged delete candidates: fix/i2-i5-offset, fix/ios-swift-todos, feat/swift-core, feat/swift-core-next (carries npm publish TODO), feat/harmonyos. Dependency branches: TB feat/harmony-animated-item-engines (ff2ada53), TB feat/glass-backdrop-source (08343e9f), CM feat/glass-backdrop (c0b183de, next SHA pending), Dealloc feat/did-become-active-on-screen (PR #30, merge first) and feat/screen-focus-events (PR #29, eab21d10).
- iOS changes 11-26 (HO:273-291): `applyNavigationFieldStyle()`; no system search bar (CYLSearchBar UISearchBar subclass deleted; CYLSearchController rebuilt over CYLSearchBarView with overlay; removed searchController, hidesNavigationBarDuringPresentation, forwardsAppearanceFromContentsViewController, two status bar providers, UISearchResultsUpdating/UISearchControllerDelegate, window-snapshot swipe); focusesOnAppear (second level+), dismissesKeyboardOnOutsideTouch (default on, not editing bars); built-in default search button (icon style); trailing group; first-level bar pushesOnTap/onFirstLevelTap, five CYLSearchBarPreset. Bar in a nav bar calls cylRefreshScreenState() after layout when focusesOnAppear. CYLSearchBarView.swift >3000 lines (split recommended). Suite 150/0 at 5d0b0f5 (was 201); later 156 on iOS 26.1 (HO:414).
- 11-27: I7 images fixed incl. 21 more (7ce7c73); label check against PR base: 14 failures, 4 Android fixed (40b020b), 10 iOS later DONE (HO:412); I1, I2, I3 fixed; RN `goBack()` on CYLSearchBarHandle (3289796; jest 22/22; Android library compiles; no device run, iOS build by Mac); mini cyl-search-bar draws clearIconImage/cancelTitle (npm 174/174, not seen in DevTools); mini beforeCompile unchanged.
- **P1 (HO:416-418): Flutter Android build fails** because flutter_cyltabbar (pub, 08343e9f) and `:cylanimateditem` (android/merged, af56db22) are mixed (`CYLGlassHighlight` missing); moving Flutter to af56db22 fails with unresolved CYLTabBarItem/CYLTabBarItemIconViewProvider. RN expected same (not built). Fix = one TB commit whose cyltabbar and cylanimateditem compile together on Android, Flutter, RN. Candidate 2b99043f (their local run 307+156 tests). **Do not repin before the owner decides** (HO:432).

## 9. Open TODOs and unfinished work

### Release / cross-cutting
1. Unify pins (fixes P1); add Dealloc dependency to Android/HarmonyOS/mini/Flutter/RN at unified pin and move focusesOnAppear moments to `appDidBecomeActiveOnScreen`; implement dismissesKeyboardOnOutsideTouch there (HO:154, 186).
2. One finished green `iOS` CI run on release head (runner availability).
3. Merge Dealloc PR #30 then #29 (retarget to master), release, repin to master commit (HO:225). Merge PR #11, resolve #16; version bump, changelog, migration guide; publish npm/pub/ohpm/pods (cyl-search-miniprogram needs npm login).
4. README and Sources/CYLSearchBar/instructions.md, CYLSearchExample/instructions.md, ios-api-alignment.md stale (still describe UISearchController repro); README edit needs owner (HO:326).
5. API scorecards stale: regenerated at 9c9ae2d Android 98 (8 TODO), HarmonyOS 99 (4), mini 97 (10); check rows by hand (HO:324).
6. docs/no-system-searchbar.md:43-48 work list and qmui-search-controller.md E1-E22 need re-marking. Many headings say TODO though closed lower; inline TODOs not reviewed by handover (HO:380-382).
7. Entries without final status: Discover layout/header into core, "fix every open TODO", placeholder pin past Swift rename (HO:378). Tags as default suggestion style 94/100 (HO:374). iOS animated item check 85 then 90 (HO:376). Release-RAM macOS section stub (HO:189). 10 CYLSearchViewQMUIPortTest SQLite "Illegal connection pointer" failures, order dependent, never baselined (HO:175); AIC:195 links one to the 16 dp default insets, which also blocks that default in Android core.

### Tab bar / dependency items
- Tab switch contract: heading TODO; 95/100, only mini retest on user phone (TBI:968-969). HarmonyOS GIF gap when selectedIndex changed externally, by reading, unreproduced (TBI:941-943). iOS More item draws first moved tab's SVGA icon (upstream) (TBI:960-962).
- Tag drag hold: HarmonyOS real drag signal + device run (latest TBI score 85; search core claims listener via CYLMenuGestureState at cf478388, device run open, SUB:281-283).
- Mini program drag: phone check; if still scrolls, 200 ms pre-lock in cyl-tag-cloud or movable-view; README/comment should say host scroller must be a scroll-view it can hold (TBI:847-852, 902-905). TBI:904 says iOS/Android/HarmonyOS/RN/Flutter hold no such lock yet (superseded by the later audit TBI:1044+).
- Contact tag delete: real phone check (TBI:760).
- HarmonyOS ClassifyMenu tags never animate without app registering `CYLTagAnimationBuilder`; the example must not add players back; open at 551072a (AIC:235). Compare AIC:63, which says the example registers CYLRiveAnimationBuilder at the earlier 325c7a31.
- AIC:236-239 open glass pin pair, tint, selected glass look, labelled screenshots.

### AIC rows
- 23 HarmonyOS gaps (square icon only; no PixelMap/symbol static image; type by extension; fixed 4 vp padding/44 vp min height) wait on TB owner (AIC:53). 31 Rive playback on arm64 device (AIC:54). 39-42 still marked TODO 2026-11-23: owner manual test, ArkTS build, bridges (codegen rerun), HO:375 says re-verify. Row 41 notes iOS/Flutter/RN iOS verified; pins moving was left.
- 2026-11-24 contracts: animation demo Android halves/native Android/HarmonyOS/mini (AIC:80-84); Android A/B/C/bridges "written statically, NOT run" (AIC:185-193; later HO shows Android work continuing but AIC not updated); not in Android core: contentInsets 16 dp, default tag look (AIC:195); two-column grid + HOT not in core (AIC:94, but rule 7 says deliberately example-layer).
- HarmonyOS: Discover by hand, hot label screen reader, wrapped Navigation branch unused, other locales fall back to English; ClassifyMenu should expose per-image accessibility label `menuAccessibilityLabelForImageForItem` (AIC:207, 261). Mini: cloud draws icon before title, no per-tag hint, cyl-tag-cloud ignores backgroundStyle at 551072a (AIC:204, 227), dark theme unverified, README for 2 new components. Liquid Glass batch checks written not run (AIC:229). corner-radius CM PR #35/#36 merge dependency (AIC:194).
- PH side: CM's CYLTagButton step 3 superseded (done differently).

### Per platform from HO:99-163
- Android: trailing group device check; "Search bar (plus)" tab not first-level pushing bar; duplicate magnifier on List/Tag style tabs; Search tab not full width (OVERLAY); predictive back/pop animation undriven; dark tab bar; icon contrast evidence ambiguous; SVGA not re-measured at af56db22; ios-api-alignment 8 rows. Tint done at af56db22 (HO:19).
- HarmonyOS: tint (repin to include 53372bce, one SVG per tab replacing tab_*_selected/normal, `CYLTabBarControllerIconRenderingMode:"template"`, measure light/dark; HO:16-19, 172); edge swipe-back (`uitest swipe` from x=2 opens dock); Rive/PAG arm64; Lottie/PAG/Rive tabs, plus tab, real device, system theme; examples-menu in-page bars; Placeholder Discover/gallery not tag lists; glass core gaps; dark flat bar mid-grey; "written, not run" items.
- Mini: dark mode, real tap beside camera (36 px ::after), edge swipe-back, pill outline; empty placeholder under keyboard needs owner phone (core-todo.md:229,236); no backdrop-filter, subtitles, tail control position; CYLSearchTagListStyle.js header keys; CYLSearchController export decision; README; registry.js re-check; touristappid.
- RN: gaps 10.3 vs 7.0 dp (cause unknown); goBack device run + README; dark tab bar light, "Search bar" label invisible; contact pages white in dark; CI vendor pin check and Android build job; not verified: Discover spacing, Tag style, Search controller demo, release, arm64; jest/tsc after e8b4927 (later 22/22 with tsc clean, HO:422); no tag iconColor/template param; glass needs CM "list-owned plate"; English demo pages.
- Flutter: device run of empty glass box fix; back gesture not wired (secondaryAnimation -> setBackButtonProgress; measure cost); route watcher no Dart test; dark labels unreadable, bar #FAFAFA; glass plate; English tab titles; plus button unresponsive once.
- iOS (HO:292-304, 334-348): I1-I3 fixed (HO:410-414); open I4 (hard-coded English second-level), I5 (Search tab filtering lost, depends D4), I6 (searchButtonImage in Flutter/RN); real-device keyboard checks (didTouchOutside misses pointer scroll); visual check of CYLSearchController active state, styles screen, collection demo; iOS 17.5/26.5 rerun, 15/16/18-25 unverified; split CYLSearchBarView.swift; record push/swipe back. X1 Flutter iOS plus button; X2 dark pages; X3 missed tap; X4 tag drag; X5 Liquid Glass partial; X6 GitHub issue #3 status bar overlap.

## 10. Owner decisions not made

HO:192-204: (1) default tint of static tab icons (opt-in vs one-colour detection); (2) how/when tab bar background follows dark mode (decided it must, "not today"; read upstream docs/Dark-Mode-Adaptation.md first); (3) List/Tag style magnifier (rule 9); (4) release-ram `-Apply` complaint; Chinese file name for Dark-Mode-Adaptation; (5) remove x86_64 Rive/PAG debug guard (needs owner's approval); (6) glass board behind Discover grid on all platforms; (7) PH Android Maven coordinates; (8) mini CYLSearchController export; fold control when all tags fit; (9) pin pair; (10) focusesOnAppear "second level or deeper" supersedes back-button filter?; (11) external monitor dimming and outside-touch keyboard dismissal (deferred).
HO:355-363: D1 system back vs own arrow (system now, departs from rule 10); D2 real stack view for field+trailing (gaps 8 pt); D3 pushesOnTap default and camera/search push (off); D4 Search tab second-level page; D5 should native/Flutter/RN looks match; D6 convert menus/styles/samples to tag lists; D7 version/release/publish order; D8 how to review ~2100-file PR; D9 keep Search button on Edit Remarks name field (kept).
**Decided, do not reopen** (HO:365-366): no system search bar anywhere; auto-focus only on second-level+ pages; icon-style default search button; fold control is the tail tag, icon only.

## 11. Contradictions and stale statements

1. Release readiness 76 (HO:29) vs 52 (HO:233); section 11 says use it for release.
2. Scorecards 100/100 (HO:211) vs 98/99/97 (HO:324).
3. search_camera.json "still 44x44" (HO:157, 185; AIC:75 canonical 44x44) vs closed (HO:323). Checked: 36x36.
4. I8 cause: "later pushes cancelled" (HO:222), concurrency/pause pushes (HO:343) vs flag already false and runner shortage (HO:401) vs stale queued run held group (HO:411, latest).
5. 4 Android label images: "remain (Windows session)" (HO:412) vs already done by 40b020b (HO:425, which says so).
6. Tag drag score 55/100 in section heading line (TBI:1046) and HO:347, 373 vs 85/100 (TBI:1137). 
7. Tab switch: heading TODO (TBI:920), Status 80 (TBI:963) with appended updates to 95 (TBI:968); sibling Android entry DONE 100 (TBI:1039) but still has "Status: TODO 80" at TBI:1027.
8. SUB:8-9 says CM 71562ca / PH 62e40c0 "on every platform"; AIC:396 says PH pin "is c84fce9 today"; AIC:565 TB "today 41660d24". All superseded; actual c0b183de / f4cf9785 (checked).
9. SUB:113-114 "HarmonyOS does not use PH (no HarmonyOS version)" vs SUB:116-119 uses cylplaceholder.
10. SUB:18-20 local `:path` Podfile is historical; fixed (SUB:54-56).
11. AIC:7 "29 of 32 rows, 4 open" vs later rows to 42 and TODO-table rows marked DONE.
12. AIC:42 (row 29) fixed; AIC:52 (row 22) "Left: no search bar item has animation in mini example" (row text says closed by 29, 30).
13. AIC:55 B-a/B-b "TODO" vs AIC:56 fixed.
14. AIC:144 "HarmonyOS/mini nothing started" vs AIC:197-256 written/run later same day. AIC:263 "grid still hand-built; back button only with -CYLDemoPushDiscover" vs AIC:98/203-204 grid from ClassifyMenu and AIC:141-142 argument gone.
15. AIC:183 HarmonyOS/mini corner radius "todo" vs AIC:194 done. AIC:210/262 failing mini pin test (102 of 103) vs fixed (AIC:210) and later 116/116 (AIC:194), 120/120 (AIC:228).
16. AIC:217 six ohosTest errors "not trusted" -> explained and 56/56 at AIC:223. AIC:218 DevTools failure -> cause found AIC:221, upstream fix vendored AIC:225; HO:134 still says re-check.
17. TBI:234-236 "Flutter/RN/mini have no SVGA code, rows wait" vs table TBI:251-253 done (TBI:251 calls the note wrong).
18. TBI:253 "mini defaults to SVGA while iOS defaults to SF Symbols; no in-page SVGA" is still flagged TODO for 1:1 inside a section scored 100 (TBI:256).
19. TBI:326/345 RN Android open bugs vs fixed TBI:351-355 and rows TBI:379-381.
20. TBI:381 old libc++ link failure "environment issue, fails without rive" vs TBI:321-325 root cause found (SDK path space).
21. TBI:129-132 and TBI:117-121 describe UISearchBar-based behaviour; removed 11-26 (HO:275).
22. TBI:23-24, 164-166 "newest commit" default vs HO:77 same-pair announced by Mac and AIC:168 (owner said not to pin PR #36/new hash, 11-24).
23. HO:125 cites animated-icon-component.md:40 for corner radius/ohosTest "written, not run", but AIC:40 is row 28 (Android SVGA not a bug). The relevant text is around AIC:209-212.
24. AIC:101 mentions repo-local constants as current; checked iOS uses library constant now.
25. Mini SVGA NOTICE lists six .svga files but the folder holds only tab_activity/tab_list/tab_search `.svga.bin` (checked by Glob); text is a verbatim copy.
26. File corruption: AIC:59 and AIC:216 contain raw control characters where Windows backslash sequences were evidently interpreted (my reading: C:\cylbuild\flutter, C:\dev\flutter, dart-sdk\bin\dartvm.exe; ...main\resources\base\element...). TBI:323,325 (and AIC/SUB paths such as C:cylbuildharmonyos at SUB:209) have backslashes missing.
27. SUB:170 notes commit messages de35153 and 82a24ba wrongly say "Rive tab icons ..." while content is a pin/closure: do not trust those messages.
28. AIC:56 says the Flutter/RN iOS simulated-tap and launch-tint bugs were fixed and rechecked 2026-11-19, but TBI:691-693 and TBI:712-714 (same date) report RN and Flutter taps only highlighting at 9a4ad95e (RN also 5744917d). My inference: the later observations predate the fix, since SUB:222-224 later pins 74f0b4cd, which "brings the iOS tab-tap fix 3ddb2868". I saw no later iOS tab-tap recheck in these documents (TBI:722-725 at 74f0b4cd checks the delete button, not tab taps).
29. TBI:62-63 says the iOS Swift core is "the three files" of Sources/CYLSearchBar; checked: 13 Swift files plus instructions.md. Stale.
30. Tension, not a hard conflict: HO:86 says never stage pubspec.lock, while TBI:1040-1041 records that the earlier 2026-11-22 pin move changed it.

## 12. SVGA asset notice

Same text in six places: CYLSearchExample/SVGA/NOTICE.md; flutter_cylsearch/example/ios/Runner/SVGA/NOTICE.md; react-native-cylsearch/example/ios/CylsearchExample/SVGA/NOTICE.md; android/merged/app/src/main/assets/SVGA-NOTICE.md; harmonyos/entry/src/main/resources/rawfile/svga/NOTICE.md; wechat-miniprogram-cylsearch/example/miniprogram/assets/tab/svga/NOTICE.md.
- Mapping from kongpf8848/Animation `app/src/main/assets/svga`, Apache 2.0: tab_home<-tab_home_select, tab_search<-tab_search_select, tab_profile<-tab_my_select, tab_activity<-tab_life_select, tab_chat<-tab_lvju_select, tab_list<-tab_find_house_list_select (NOTICE:3-10).
- Unchanged renamed copies, as used by CYLTabBarController's examples (its docs/SVGA-Animation.md); 96x96, play once 1-2 s, keep last frame. Provenance caveat: icons look taken from a shipping app, original author unnamed; **replace if origin is disputed** (NOTICE:12-15). TBI:260-261 names the immediate source as TB's Example-SwiftUI-Rive/AnimatedApp/SVGAAssets.
- Checked folders: iOS, HarmonyOS: 6 svga + NOTICE; Flutter and RN iOS: 6 svga + NOTICE + search_camera.json; Android assets: 6 svga + SVGA-NOTICE + search_camera.json among other files; mini: 3 .svga.bin + NOTICE.

## Coverage

Line counts: "task" = count given in the assignment; "Read" = lines reported by the Read tool (one higher, the trailing empty line). All read through the Read tool with offset/limit.

| File | task / Read | Ranges read | Skipped |
|---|---|---|---|
| docs/animated-icon-component.md | 666 / 667 | 1-57, 58-100, 101-193, 194-257, 258-493, 494-667 | none |
| docs/CYLTabBarController-Integration.md | 1146 / 1147 | 1-266, 267-495, 496-693, 694-931, 932-1126, 1127-1147 | none |
| docs/todo/20261104/Next-Unify-...-MiniProgram.md | 434 / 435 | 1-188, 189-396, 397-435 | none |
| docs/sub-repositories.md | 304 / 305 | 1-243, 244-305 | none |
| docs/svga-tab-icons.md | 6 / 7 | 1-7 | none |
| CYLSearchExample/SVGA/NOTICE.md | 15 / 16 | 1-16 | none |
| CrossPlatform/flutter_cylsearch/example/ios/Runner/SVGA/NOTICE.md | 15 / 16 | 1-16 | none |
| CrossPlatform/react-native-cylsearch/example/ios/CylsearchExample/SVGA/NOTICE.md | 15 / 16 | 1-16 | none |
| android/merged/app/src/main/assets/SVGA-NOTICE.md | 15 / 16 | 1-16 | none |
| harmonyos/entry/src/main/resources/rawfile/svga/NOTICE.md | 15 / 16 | 1-16 | none |
| CrossPlatform/wechat-miniprogram-cylsearch/example/miniprogram/assets/tab/svga/NOTICE.md | 15 / 16 | 1-16 | none |

Line-by-line comparison of the Read output with an in-memory copy showed no differences (the in-memory copy was also used to count lines, search for control characters and compare the NOTICE files). Not opened: linked screenshots, docs/task-log.md and other referenced documents, upstream repositories. Section 1 checks used narrow searches only.
