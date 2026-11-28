> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Written by a subagent: its claims and contradictions were NOT re-checked (only items marked S in 02-findings.md were). What the source documents report as done or passing is their claim.

<!-- F-rules-skills-readmes: part 2 of 2 -->
_Part 2 of 2. Previous: [part 1](F-rules-skills-readmes.md)._

### 10.6 Third-party Android upstream READMEs and transcriptions
| Folder | Upstream commit (read 2026-11-12) | License | What is in it |
|---|---|---|---|
| lapism-search | lapism/search `2d55614` | Apache 2.0 `LICENSE` | Already Kotlin; copied unchanged (`src/main`) |
| MiguelCatalan-MaterialSearchView | `53e163c` | Apache 2.0 `LICENSE` | Java library + sample translated, AndroidX, resources unchanged; **upstream quirk kept: `isVoiceAvailable()` true only when no recognizer exists** |
| android-cjj-MaterialSearchView | `298db81` | **no license** | not a transcription: independent `CYLRevealSearchActivity` reimplements behaviour (circular reveal), credited |
| yechaoa-MaterialDesign | `2d6ac57` | Apache 2.0 `LICENSE.md` | only search screen (`SearchViewActivity`, `ToolbarActivity`, layout, menu) |
| iammert-MultiSearchView | `b37f248` | Apache 2.0 per upstream README (2019 Mert Şimşek), `NOTICE` | library + sample copied unchanged |
`android/merged` holds the buildable merged version (all TRANSCRIPTION.md). Upstream issue tracking: `docs/android-and-cross-platform.md` per android/README.md:16-18.
Upstream API notes (history of the replica APIs, not this project's API):
- lapism: README says DEPRECATED in favour of Material `SearchBar/SearchView`; minSdk 21, targetSdk 33, `io.github.lapism:search:2.0.1`; `MaterialSearchBar` (toolbar; `getToolbar(), navigationIconCompat, setHint`) + `MaterialSearchView` (`addView, requestFocus/clearFocus, OnQueryTextListener, OnFocusChangeListener`), Material theme required, CoordinatorLayout + `material_search_bar_scrolling_view_behavior`, XML attrs `search_*`; upstream TODO: Google-like animation.
- MiguelCatalan: `compile 'com.miguelcatalan:materialsearchview:1.4.0'`, API 14+; place last in layout; `setMenuItem, setOnQueryTextListener, setOnSearchViewListener, setVoiceSearch, REQUEST_VOICE + setQuery(word,false), setSuggestions(array), style MaterialSearchViewStyle (searchBackground, searchVoiceIcon, searchCloseIcon, searchBackIcon, searchSuggestionIcon, searchSuggestionBackground, text colours, hint), setCursorDrawable, isSearchOpen/closeSearch on back`; AppBarLayout recipe; Apache 2.0 (2015 Miguel Catalan Bañuls).
- iammert: `com.github.iammert:MultiSearchView:0.3` (JitPack); listener `onItemSelected, onTextChanged, onSearchComplete, onSearchItemRemoved`; style via `app:searchTextStyle`; design credit Cuberto.
- Root README opening (Chinese): imitates the iPhone Messages search box that slides into the navigation bar; shows GIF `CYLSearchViewController/it_is_effect_show__SearchBar.gif`.

## 11. Dated milestone claims in the root README (unverified)
| Milestone | Environment | Commit / branch | When |
|---|---|---|---|
| iOS key details | macOS 27.3, Xcode 27.2, iPhone 17 iOS 26.1 | `9735f79` `feat/swift-core` (image caption says commit 1416a3e) | 2026-11-12 NZDT |
| "Swift migration 100/100, raised plus" | Xcode 27.2, iPhone 18 Pro iOS 27.2 | `726a2da`, `a5158b8` on `fix/ios-swift-todos` | 2026-11-21 +13:00 |
| Mini program | Win 11, DevTools 2.02.2609250, base lib 3.6.6 | `d19e0bb` `feat/swift-core-next` (caption 30f9eda) | 2026-11-15 |
| Android | JDK 17.0.21, Gradle 9.3.1, AGP 8.7.3, Kotlin 2.0.21, API 35 emulator, compile/target 35, min 23 | `ffac758` `feat/swift-core` (caption 79cf4b6); TabBar `f410fa7`, ClassifyMenu `eb3590e` | 2026-11-12 |
More screenshots: `docs/search-api-comparison.md`, `docs/CYLTabBarController-Integration.md`.

## 12. Contradictions and stale statements

### 12.1 Checked against the working tree by me (2026-11-29, read-only `ls/grep/sed/git log`)
1. **"Three files, four public classes" is stale.** Claimed in Sources/CYLSearchBar/instructions.md:4-5 ("nothing else"), di/core.md:95-97 and :133-135, cyl-fix-in-core:22-24, cyl-api-map:10-11, cyl-verify:17-18, README:120-127. `ls Sources/CYLSearchBar` shows **13 Swift files** (Appearance, BarView 3007 lines, Controller 696, HeaderSnapper, NavigationBar, PresentationState, Resources, ResultsComponent, SuggestionArea, TableViewController, TagListHeader, TagListStyle, View 1175). A declaration grep also finds public `CYLSearchBarAppearance, CYLSearchNavigationBar, CYLSearchTagListHeader, CYLSearchTagListStyle, CYLSearchController, CYLSearchTableViewController`. di/core.md:152 itself cites `CYLSearchNavigationBar.swift`, and the mini README:132-141 documents the QMUI classes (mini `src/core` also has more than three modules).
2. **CYLTableViewPlaceHolder pin.** Docs say `62e40c0` on every platform (di/dependencies.md:120, :134; cyl-sub-repositories:44). Root Podfile, Android `gradle.properties`, mini `package.json`, HarmonyOS `oh-package.json5` and the Flutter/RN example lockfiles show `f4cf978567e43288b44f6ddc266510fa837a0e72`.
3. **CYLTabBarController "same commit" differs by platform**: root Podfile / mini / Flutter example `08343e9f…`; Android `gradle.properties` `af56db22…`; HarmonyOS `d19e138e…`; RN example uses a vendored `:path` checkout (its commit not checked). ClassifyMenu is `c0b183de…` in root Podfile, Android, mini, HarmonyOS. CYLDeallocBlockExecutor `eab21d10…` in root, Flutter and RN Podfiles (other platforms not checked, though core.md:173-174 requires one commit).
4. **Core dependencies.** README:129-131 and Sources/CYLSearchBar/instructions.md:15-17 list ClassifyMenu, CYLTableViewPlaceHolder (README also CYLAnimatedItem). The podspec declares `CollectionViewClassifyMenu`, `CYLAnimatedItem`, `CYLTableViewPlaceHolder/Core`, **`CYLDeallocBlockExecutor ~> 1.4`**, plus `sqlite3` (di/core.md:173 does mention the executor).
5. **Issue #1317 / UISearchController text is stale.** README:103-113 and :217-221, `instructions.md`:3-5 (intro still says "Issue #1317 reproduction for `UISearchController`"), di/macos.md:34-43 and :95-103, cyl-verify:101-106, cyl-tabbar-integration:122-123 and di/dependencies.md:45-48 name a navigation-item `UISearchController`, and README also a "Repro: OFF/ON" toggle; the system bar is banned since 2026-11-26. Checked: the "Search and refresh" page **still exists** (`CYLSearchDemoMenuViewController.swift`:361 key `demo.reproduction`, row 0 opens `CYLSearchExampleViewController`) and still has **Overlay** and core pull-to-refresh, but its field is `CYLSearchBarView` (`applyPreset(.pill)`, `embedInNavigationBar(of:)`); the lines I read (45-200 of `CYLSearchExampleViewController.swift`, to the start of `showOverlay`) show no Repro toggle or `UISearchController`, and a grep of example + tests finds **no reference to `repro.on` / `repro.off`** (strings remain in `en.lproj`). Greps of `CYLSearchExample`/`Sources` found no non-comment `UISearch` use; `CYLSearchControllerLifecycleTests.swift`:8,:21 say it is gone. `CYLSearchNavigationItemDemoViewController.swift` uses the project's `CYLSearchController.install(in:)` with `hidesSearchBarWhenScrolling = false` (its header comment says `install` assigns a system controller inside; core not opened to confirm). Tests still use `UISearchBar` as a control. Side note: a comment in `CYLSearchExampleViewController` says "focusesOnAppear needs a back button", older wording than core.md:167-170 (not first controller of the nav stack).
6. **Toolchain versions.** Flutter README:61-64 says AGP 8.11.1 / Kotlin 2.2.20. Now: `android/merged/gradle/libs.versions.toml` AGP 9.2.1, Kotlin 2.2.20; Flutter example settings AGP 9.2.1, Kotlin **2.4.0**. README:86 AGP 8.7.3 / Kotlin 2.0.21 is a historical screenshot environment (2026-11-12).
7. **Mini sub-dependencies.** README:25-29 says placeholder is required and "peer dependency"; `package.json` lists both peers with `peerDependenciesMeta optional: true` (at least the placeholder entry). README:13 "two sub-dependencies" (and test/package.test.js:1,:10 agrees) vs README:185 "the only sub-dependency".
8. **Mini README property tables lag code**: `src/core/CYLSearchBarView.js` has `showsSearchButton`, `searchButtonStyle` (:789-792) and `navigationFieldStyle` (:191); a grep of the README text I read shows no such rows in :86-104.
9. **cyl-tabbar-integration sample config** (:51-70; Search + Menu + "Publish") differs from the real `CYLTabBarConfiguration.json`: four tabs (search, examples, tagStyle, discover), localized titles via `CYLSearchTabs.bundle`, plus button `tab.searchBar`, image `CYLPlusButton`, `CYLPlusButtonAlignsTitle false`, size `{64, 84}`, centerY multiplier 0.3. README:259-260 mentions only Search, Examples and plus. `CYLTabBarConfiguration_svga.json` and `..._swiftui.json` also exist.
10. **Pod naming for animation.** README:141 uses `CYLTabBarController` subspecs `CYLAnimatedItem`/`CYLAnimatedItemSVGA`; the root Podfile and podspec use pod `CYLAnimatedItem` with subspecs (`Core, SVGA, LottieSwift`), and TabBarController subspecs `Core, SVGA, CYLFlatDesignTabBar`.
11. **Local-path rule.** di/macos.md:14-15 and cyl-new-project:10-11 say use `pod 'CYLTableViewPlaceHolder', :path => '../CYLTableViewPlaceHolder'`; di/dependencies.md:103-105 and README:208 say by commit; the actual Podfile uses `:git` + `:commit`.
12. **Line counts**: AGENTS.md/instructions.md 171, CLAUDE.md 4 (under 200); `git.md` is 205 lines now although :203 records "all 201 lines" (a historical note; git.md may exceed 200 as it is a tag file).

### 12.2 Between documents
1. **PR base branch**: previously active PR's head, else master (di/git.md:31-32, :189-190; AG:69-70; cyl-commit:69-70) vs the **source branch** (di/git.md:64-67, :198-201; cyl-verify:114-117; cyl-docs:65-68). Both in git.md.
2. **Commit/push on branches**: "as soon as the work is written" (git.md:61, :179) vs "at the end of every exchange" (:36). The two differ only in timing.
3. **Co-Authored-By**: the documented hook (git.md:144-160) strips all such lines, which conflicts with any tool or harness instruction to add that trailer.
4. **Emoji**: Commitizen defaults (feat 🎸, docs ✏️, chore 🤖, refactor 💡) vs project history set (✨ 📝 🔧 ♻️) (git.md:90-94, cyl-commit:30-39). RN CONTRIBUTING uses plain Conventional Commits with only six types.
5. **Touch targets**: 44 vp/pt/dp minimum (di/accessibility-i18n.md:13, cyl-accessibility-i18n:21-22) vs 36 pt/dp for trailing icon items (di/core.md:179, cyl-search-field:25).
6. **System search bar ban vs older docs/rules**: core.md:146 bans `UISearchController`'s bar, while search-placement and Issue #1317 rules still name a navigation-item `UISearchController` (12.1.5).
7. **Default search button vs mini README sample**: README:74 adds a `{style:'text', title:'Search'}` item although the core now has a built-in button not in `items` (core.md:158-164) and examples must not add a duplicate (example-demos.md:43-45).
8. **Tag suggestions on iOS**: "Android done, iOS TODO" (di/dependencies.md:112-113, cyl-sub-repositories:43) vs README:129 and the podspec comment (iOS depends on ClassifyMenu for tags) and Sources instructions:15.
9. **Animated item component**: README:159-160 says HarmonyOS and mini program have none (TODO) vs mini README:32-40, cyl-sub-repositories:25-28, di/harmonyos.md:45-52, windows.md:82-87 which use vendored `cyl-animated-item` / `cylanimateditem` (newer).
10. **CLAUDE.md**: di/meta.md:17 says it "only imports AGENTS.md"; CLAUDE.md:2-4 and behavioral.md:88-89 show it also imports behavioral.md.
11. **Screenshot layout**: superseded 2026-11-12 order is still the only text in cyl-tabbar-integration:167-170, cyl-plus-button:112-115, cyl-api-map:92-95, cyl-new-project:93-96, cyl-xcode-compat:69-72; cyl-verify, cyl-docs and di/docs carry the 2026-11-18 replacement. Mini README:49 screenshot is two columns (2026-11-15).
12. **HarmonyOS install paths**: cyl-harmonyos-setup:100 and :105-113 install `entry-default-unsigned.hap` on the emulator (windows.md:28-29 also says emulator runs use the unsigned HAPs, without naming the file); the same skill :115-132 (newer, 2026-11-22) says default HAPs cannot install on x86_64, use `entry-emulator-unsigned.hap`. Likewise :34 `assembleHap ... entry@default`. cyl-accessibility-i18n:77 omits `-s timeout 40000`.
13. **cyl-new-project** describes an "Objective-C example" (:3) and the tabbar skill gives ObjC code; README:18, :27 says the example and tests are Swift (since 2026-11-21).
14. **Flutter/RN class name**: core.md:145 says "Flutter and React Native `CYLSearchBar` over the native one"; Flutter/RN READMEs document widgets named `CYLSearchBarView` (not verified in code); neither README mentions the 2026-11-26 default button or `navigationFieldStyle`.
### 12.3 Defects seen
- `CrossPlatform/react-native-cylsearch/README.md:48` contains a **literal carriage return** inside the path: characters `C` `:` CR `s` (verified char codes 67 58 13 115). The intended text is probably `C:\rs`.
- CODE_OF_CONDUCT.md:64 still has the `[INSERT CONTACT METHOD]` placeholder.
- MiguelCatalan upstream README has headings without a space (`#Native version`) and typographic `<!—` comments in XML samples (copying them breaks XML).

## 13. Open TODOs and unfinished work named in these files (document status; not re-verified)
- Issue #1317: original iOS 12.3 inset-loop report never reproduced (README:115-116, :219-221).
- CocoaPods: podspec 0.1.0 unpublished (README:200-202); CYLAnimatedItem pod/subspecs in no release/trunk; CYLDeallocBlockExecutor 1.4 not on trunk (podspec comments).
- HarmonyOS and mini program shared animated-item component: TODO in CYLTabBarController per README:159-160 (may be stale).
- ClassifyMenu tag suggestions on iOS: marked TODO in two docs (likely stale).
- Rive/PAG on x86_64 emulator: plan 1 in `cylanimateditem` requested 2026-11-22; local `emulator` build profile is a stopgap (confirmed present in `harmonyos/entry/build-profile.json5`); debug-guard removal needs user approval; Rive/PAG playback verifiable only on arm64.
- Android Maven publishing config (and POM MIT block) does not exist yet (cyl-license:21-22).
- No animation example page in this repo yet (di/animation.md:25).
- Long-press bubble and title wrapping per platform, no-system-search-bar per platform status: tracked in `docs/task-log.md` (not in my set).
- Swift naming: deprecated forwards to be accepted by owner in SonarCloud (cyl-naming:25-29).
- lapism upstream TODO: Google-like animation.
- cyl-tabbar-integration:117-118: record anything not run on a simulator under TODO in `docs/CYLTabBarController-Integration.md`.
- Documents to refresh (from section 12): core file/class list, pins, Issue #1317 text, tabbar sample config, mini README property tables and sample, Flutter AGP text, old screenshot order in five skills, HAP install paths.

## Coverage

Method: Read tool with offset 1, limit 2000 (returned line count equalled the file total for every dumped file), printed with line numbers in chunks under the output cap. Files longest line was 871 characters. One early two-file dump was cut in the middle; the cut span (mini README from line 177 and docs.md lines 1-60) was re-read. The Read tool counts show one more line than assigned for most files (trailing empty line). `instructions.md` was not printed separately: a script compared it line by line with `AGENTS.md` (read in full); only lines 1 and 3-5 differ, and those I read; all other lines are identical. Nothing else skipped. Out-of-set files were only probed by `ls/grep/sed/wc` for section 12 (podspec, Podfiles, manifests, build files, skills.json, tab config, parts of three Swift example files and a sync script header).

| File | Lines | Read | Skipped |
|---|---|---|---|
| `docs/instructions/core.md` | 180 | 1-180 (all) | none |
| `CrossPlatform/wechat-miniprogram-cylsearch/README.md` | 194 | all, two passes (1-177, 177-end) | none |
| `docs/instructions/docs.md` | 176 | all, two passes (61-end, 1-60) | none |
| `README.md` | 270 | 1-270 (all) | none |
| `AGENTS.md` | 171 | 1-171 (all) | none |
| `instructions.md` | 171 | diff vs AGENTS.md: differing lines 1, 3-5 read; rest verified identical | none |
| `docs/instructions/git.md` | 205 | 1-205 (all) | none |
| `.agents/skills/cyl-verify/SKILL.md` | 200 | 1-200 (all) | none |
| `.agents/skills/cyl-harmonyos-setup/SKILL.md` | 181 | 1-181 (all) | none |
| `docs/instructions/dependencies.md` | 136 | 1-136 (all) | none |
| `docs/instructions/example-demos.md` | 52 | 1-52 (all) | none |
| `.agents/skills/cyl-tabbar-integration/SKILL.md` | 174 | 1-174 (all) | none |
| `docs/instructions/windows.md` | 93 | 1-93 (all) | none |
| `android/MiguelCatalan-MaterialSearchView/README.md` | 260 | 1-260 (all) | none |
| `.agents/skills/cyl-docs/SKILL.md` | 132 | 1-132 (all) | none |
| `.agents/skills/cyl-plus-button/SKILL.md` | 119 | 1-119 (all) | none |
| `.agents/skills/cyl-api-map/SKILL.md` | 99 | 1-99 (all) | none |
| `docs/instructions/code-style.md` | 117 | 1-117 (all) | none |
| `docs/instructions/harmonyos.md` | 63 | 1-63 (all) | none |
| `docs/instructions/accessibility-i18n.md` | 76 | 1-76 (all) | none |
| `android/lapism-search/README.md` | 197 | 1-197 (all) | none |
| `docs/instructions/workflow.md` | 101 | 1-101 (all) | none |
| `.agents/skills/cyl-new-project/SKILL.md` | 100 | 1-100 (all) | none |
| `docs/instructions/behavioral.md` | 98 | 1-98 (all) | none |
| `docs/instructions/macos.md` | 105 | 1-105 (all) | none |
| `CrossPlatform/react-native-cylsearch/CODE_OF_CONDUCT.md` | 133 | 1-133 (all) | none |
| `.agents/skills/cyl-fix-in-core/SKILL.md` | 73 | 1-73 (all) | none |
| `CrossPlatform/react-native-cylsearch/CONTRIBUTING.md` | 132 | 1-132 (all) | none |
| `.agents/skills/cyl-xcode-compat/SKILL.md` | 76 | 1-76 (all) | none |
| `.agents/skills/cyl-naming/SKILL.md` | 45 | 1-45 (all) | none |
| `.agents/skills/cyl-accessibility-i18n/SKILL.md` | 77 | 1-77 (all) | none |
| `docs/instructions/testing.md` | 71 | 1-71 (all) | none |
| `CrossPlatform/flutter_cylsearch/README.md` | 69 | 1-69 (all) | none |
| `.agents/skills/cyl-commit/SKILL.md` | 76 | 1-76 (all) | none |
| `.agents/skills/cyl-task-start/SKILL.md` | 61 | 1-61 (all) | none |
| `docs/instructions/skills.md` | 40 | 1-40 (all) | none |
| `CrossPlatform/react-native-cylsearch/example/README.md` | 97 | 1-97 (all) | none |
| `docs/instructions/meta.md` | 31 | 1-31 (all) | none |
| `.agents/skills/cyl-sub-repositories/SKILL.md` | 44 | 1-44 (all) | none |
| `.agents/skills/cyl-license/SKILL.md` | 45 | 1-45 (all) | none |
| `android/iammert-MultiSearchView/README.md` | 102 | 1-102 (all) | none |
| `CrossPlatform/react-native-cylsearch/README.md` | 69 | 1-69 (all) | none |
| `Sources/CYLSearchBar/instructions.md` | 40 | 1-40 (all) | none |
| `docs/instructions/licenses.md` | 23 | 1-23 (all) | none |
| `docs/instructions/animation.md` | 26 | 1-26 (all) | none |
| `CrossPlatform/flutter_cylsearch/CHANGELOG.md` | 26 | 1-26 (all) | none |
| `CYLSearchExample/instructions.md` | 39 | 1-39 (all) | none |
| `.agents/skills/cyl-search-field/SKILL.md` | 25 | 1-25 (all) | none |
| `.agents/skills/cyl-example-taglist/SKILL.md` | 22 | 1-22 (all) | none |
| `.agents/skills/cyl-simulator-run/SKILL.md` | 32 | 1-32 (all) | none |
| `CYLSearchExampleTests/instructions.md` | 33 | 1-33 (all) | none |
| `docs/instructions/miniprogram.md` | 21 | 1-21 (all) | none |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-navigation-bar/README.md` | 41 | 1-41 (all) | none |
| `.agents/skills/cyl-api-parity/SKILL.md` | 34 | 1-34 (all) | none |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-refresh-button/README.md` | 32 | 1-32 (all) | none |
| `android/README.md` | 18 | 1-18 (all) | none |
| `scripts/instructions.md` | 18 | 1-18 (all) | none |
| `CYLSearchViewController/instructions.md` | 11 | 1-11 (all) | none |
| `android/android-cjj-MaterialSearchView/TRANSCRIPTION.md` | 6 | 1-6 (all) | none |
| `android/MiguelCatalan-MaterialSearchView/TRANSCRIPTION.md` | 6 | 1-6 (all) | none |
| `CrossPlatform/flutter_cylsearch/example/README.md` | 8 | 1-8 (all) | none |
| `android/yechaoa-MaterialDesign/TRANSCRIPTION.md` | 6 | 1-6 (all) | none |
| `android/iammert-MultiSearchView/TRANSCRIPTION.md` | 6 | 1-6 (all) | none |
| `android/lapism-search/TRANSCRIPTION.md` | 6 | 1-6 (all) | none |
| `CrossPlatform/flutter_cylsearch/example/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md` | 5 | 1-5 (all) | none |
| `Resources/instructions.md` | 5 | 1-5 (all) | none |
| `CLAUDE.md` | 4 | 1-4 (all) | none |
