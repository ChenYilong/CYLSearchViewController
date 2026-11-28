> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Written by a subagent: its claims and contradictions were NOT re-checked (only items marked S in 02-findings.md were). What the source documents report as done or passing is their claim.

# E: Other documents in docs/ (digest of 12 files)

Written 2026-11-29. Citations are `file:line`, relative to `docs/` unless a path is given.
Labels: statements are what the documents CLAIM (tests passed, builds, device checks were not re-run). **[checked]** marks what was confirmed by a targeted read/search of the working tree during this export. Where a later dated entry replaces an earlier one, the later one is the current claim.

## 0. Shared architecture facts (as the documents state them)

- Search core on every platform is `CYLSearchBar` (android-and-cross-platform.md:6-12): `CYLSearchBarView` (`mode` single/multiple), `CYLSearchBarItem`, `CYLSearchView` (suggestions, results, empty placeholders, the only refresh API), `CYLSearchResources`. See contradiction C2 on the "four classes" count.
  - iOS `Sources/CYLSearchBar`; Android `android/merged/cylsearch` (`CYLSearchBarView.kt`, `CYLSearchView.kt`, `CYLSearchResources.kt`; refresh from CYLTableViewPlaceHolder `:placeholder-refresh`); HarmonyOS `harmonyos/cylsearch` (.ets); mini program components `cyl-search-bar`, `cyl-search`; React Native and Flutter wrap the native cores.
- Dated entries use the class names of their time (CYLMultiSearchView, CYLSearchController, CYLSearchResultsViewController, `Sources/CYLSearchViewController/`). **[checked]** `Sources/` now holds only `CYLSearchBar/` with 13 .swift files plus instructions.md.
- Order of platform work: Android, HarmonyOS compatibility, Flutter, React Native (android-and-cross-platform.md:129); HarmonyOS was deferred until an emulator existed (:135-137).
- Decision (user, 2026-11-13): Flutter wraps the native core through platform views; Dart is not a second implementation (:130-134). React Native does the same (:274-292).
- Rule: fix in the core, not the example; examples only pass parameters (core-todo.md:3-5; tag-view-suggestions.md:216-217, user: "fix it in the core").
- Missing capability in a sub-repository is fixed there first, pushed, then the pin is updated (tag-view-suggestions.md:199-200).

## 1. Android (android-and-cross-platform.md; android/ folder)

### 1.1 Layout and build
- `android/`: `lapism-search`, `MiguelCatalan-MaterialSearchView` (Java to Kotlin, AndroidX), `yechaoa-MaterialDesign` (search screen only), `android-cjj-MaterialSearchView`, `iammert-MultiSearchView`, `merged`; each has `TRANSCRIPTION.md` (source commit, license) (:578-583).
- Licenses (2026-11-12): lapism, MiguelCatalan, yechaoa have Apache 2.0 LICENSE; iammert states Apache 2.0 in README; **android-cjj has no license, so its code must not be copied or translated**. User decision: original reimplementation (`CYLRevealSearchActivity`), credited, not derived (:565-577, :581-582).
- `merged` modules: `search-lapism`, `search-materialsearchview`, `search-multisearchview` (sources taken from sibling folders, not copied), `sample-materialsearchview`, `sample-multisearchview`, `sample-yechaoa`, `sample-reveal`, `cylsearch`, `app` (:593-595).
- CYLTabBarController is not on Maven/JitPack and Gradle source dependencies cannot pin a commit: `settings.gradle.kts` checks out `cyl.tabbar.commit` (gradle.properties, from `CYLTabBarController/scripts/latest-cyl-commit.sh`) into `.cyl-deps/` and builds `cyltabbar` + `tabpages`; local override `-Pcyl.tabbar.dir=<path>` or `CYL_TABBAR_DIR` (:571-574, :596-599). Same pattern for ClassifyMenu: `cyl.classifymenu.commit`, `-Pcyl.classifymenu.dir` for local dev only (tag-view-suggestions.md:62-64).
- Toolchain history: Gradle 9.3.1 / AGP 8.7.3 / Kotlin 2.0.21 (SDK 35, minSdk 23; :591-592); then AGP 8.11.1 / Kotlin 2.2.20 for Flutter 3.47 composite build (a composite build allows one AGP) (:146-148); then AGP 9.1.0 with `android.builtInKotlin=false`, Kotlin 2.2.20 (Flutter app uses Kotlin 2.4.0; sub-repos still use `kotlinOptions`, an error in 2.4) (:195-198); then AGP 9.2.1 + Gradle 9.4.1 for React Native 0.88 (:289-291, `06865a5`). **[checked]** current: AGP 9.2.1, Kotlin 2.2.20, Gradle 9.4.1.
- Original Mac toolchain paths: JDK 17 `~/develop/jdk/jdk-17.0.21+9`, SDK `~/Library/Android/sdk`; build outside the exFAT volume (:575-576).
- Compile fixes at first build (:602-606): lapism `dispatchDraw(Canvas)`, iammert animator listener non-null params (SDK 35), unused synthetic import, MiguelCatalan sample layouts moved off `android.support.*`, data binding enabled in app (iammert #10), jcenter-only EasingInterpolator dropped, samples opt out of Android 15 edge-to-edge.
- App: CYLTabBarController from `assets/CYLTabBarConfiguration.json`, titles from `CYLSearchTabs.bundle`, raised plus button (`CYLPlusButtonCenterYMultiplier` 0.3, 56 dp) for the search-bar page, `CYLTabBarPageRegistry`; tabs Search, Examples, plus, List style, Tag style (:614-620). The iOS "Repro" button (Issue #1317) has no Android counterpart.
- API alignment: 294 iOS declarations, 261 DONE + 33 N/A, script `android/merged/scripts/api-alignment.py` (:609-613). Later counts: see C6.
- Backlog table "Android, RN, Flutter TODO table" closed 5/5 (2026-11-16, :60-74): system Back ends search in CYLMultiSearchView (`OnBackPressedCallback`, 17/17); Android animated placeholder via CYLTableViewPlaceHolder PR #28 (`7bc27a1`, pin `6d8b264`); RN iOS raised plus button: `alignsTitle: false` keeps title on the button so `centerYMultiplier` applies; 52 pt green PNG `src/assets/plus-button*.png` (`imageSize` redrew the SF Symbol black), `size` 64x84, multiplier 0.3.

### 1.2 Upstream PRs (android-and-cross-platform.md:650-682; read 2026-11-12)
22 open PRs: 19 merged (fully or adapted so existing API stays), 3 N/A (**[checked]** 22 rows; N/A = MiguelCatalan #200, #97, #92). lapism, yechaoa, android-cjj had none.
- Notable adaptations: #220 -> `setSuggestionTextColor`/`SearchAdapter.textColor`; #176/#127 -> `checkWholeString` (default stays "starts with"); #153 -> `SuggestionItem`, `setSuggestions(Array<SuggestionItem>)`, `setSuggestions(suggestions, iconRes)`, `getItem()` still returns text, `getSuggestionItem()`, `setSuggestionIcon` kept; #114 partly (`setSuggestionsWithDefault`, `setDefaultSuggestions`/`setSearchCovered`; "cover" behaviour NOT merged because it would change close behaviour); #106 -> `closeSearch(animate)`, `closeSearch()` still immediate; #81 -> default methods `onSearchViewAboutToShow/Close`; #209 `useAdapter` fix; #159/#146/#105/#66 `isVoiceAvailable()`; #130 `getQuery()`.
- iammert: #17 `selectedTabStyle` (line/dot, `viewIndicator2`); #16 `setSearchIconDrawable`/`setSearchIconColor` + attrs; #15 binding fields instead of `root.<synthetic id>`.

### 1.3 Upstream open issues (android-upstream-issues.md)
- Score = (DONE + N/A) / all x 100 (:7). Log 2026-11-12: 0/166 -> 164 (101 DONE, 63 N/A, 98) -> 166 (103 DONE, 63 N/A, 100) (:11-15). Rule: Status `TODO` until handled.
- **[checked by counting rows]** 166 rows, 103 DONE, 63 N/A, 0 TODO. By project: MiguelCatalan 146 (91/55, :18-167), iammert 8 (8/0, :169-180), yechaoa 8 (0/8, :182-193), android-cjj 4 (4/0, :195-202). lapism has none.
- N/A categories: upstream Maven artifact/jcenter (#257 #256 #255); app usage/layout questions (many); upstream docs/README (#223, #183, #152, #151); bugs in the reporter's app or device (#253, #249, #207, #202 antivirus, #167 OOM, #131 truncated trace, #180); design choices (#232 attrs, #203 not a menu action view, #162/#142 returning true from `onQueryTextSubmit` keeps search open, #140 height follows `actionBarSize`, #132, #111 PNG icons, #109 iconified, #42 resource prefix would break overrides, #235 `setAdapter` takes any ListAdapter, #37 use `setSuggestionsWithDefault`); yechaoa: outside the copied search screen or asks for Java.
- Fix API reference by issue (Kotlin MaterialSearchView):
  - Text/appearance: `setTextGravity`, `setTypeface` (#252 #210, RTL start/end layout #252 #119 #98), `setTextSize` (#236 #149 #62), `setMaxLength` (#244), `setEllipsize(true)` (#32), `setDividerColor` (#34 #14), `searchCursorDrawable` (#41), `setSuggestionMinHeight` (#187), `setDimBackground(true)` (#217 #186), `setAnimationDuration` applies to reveal (#26).
  - Filtering/suggestions: `setIgnoreAccents(true)` (#250), `setSuggestionFilter` (#242 #165; show all with `{ _, _ -> true }` #196 #94), `setFilterDelay` (#198), `setSuggestionsWithDefault` (#158), `setSuggestionIcon`/`SuggestionItem` (#133 #77 #70), item click listener preserved and called after query filled (#50 #226 #181 #171 #89), `setOnItemLongClickListener` (#166), null suggestions skipped (#233 #74), empty result clears list (#75), custom adapter shows tint (#80).
  - Root cause shared by #194 #192 #154 #141 #90 #84 #47: suggestion list now has fixed height instead of `wrap_content`; rows have own background (`search_view.xml`, `suggest_item.xml`).
  - Behaviour: `showSearch()` from code / without menu item (#234 #221 #219), `setShowKeyboardOnOpen(false)` (#123), open shows keyboard and focuses (#104 #100 #96), clear keeps focus (#122), focus restored after rotation (#214), `getQuery()` (#205 #164), `setQuery`/`selectAll()` (#125), `setClearQueryOnClose(false)` (#118 #102), `setAllowEmptyQuery(true)` (#145 #20), `setInputType` (#113), `setSearchEnabled` (#56), `setOnBackIconClickListener` (#185), `SearchViewListener.onSearchViewCanceled` (#71), `setOnVoiceClickListener` (#40), `setVoiceSearch(false)`/`showVoice(false)` (#208), `closeSearch(true)` (#138 #95).
  - Crash/state: lookups only in inflated layout (#248), open state set before callbacks (#237), INVISIBLE on close (#206), `setBackground` during inflation (#204 #110 #76), reveal only when attached and laid out (#170), reveal starts from menu item (#57 #212), dismissed suggestions GONE (#168), open/visibility consistent (#33), `isVoiceAvailable()` (#213 #189 #179 #137 #78 #63; #39 uses view context), AndroidX (#227 #224), TabActivity sample runs (#157).
  - iammert: `showSoftInput` for Android 12+ (#19), `getEditText()` (#18), `addSearch(text)` (#14), `setSearchIconColor` (#13), app must enable data binding else NoClassDefFoundError (#10), removed tab clears focus first (#7), `setSearchText` (#6), `android:textCursorDrawable` applied (#4).
  - android-cjj: readable colours + reveal laid-out card (#4 #2), `.idea` ignored (#3), no-license note in TRANSCRIPTION.md (#1).

## 2. Flutter (android-and-cross-platform.md)

- Plugin `CrossPlatform/flutter_cylsearch`: widgets `CYLSearchView`, `CYLSearchBarView`, later `CYLTagListView`; `UiKitView` / Android hybrid composition; iOS parameter names and events `onTextChanged, onSubmitted, onSuggestionSelected, onClose, onCancel`; native views follow Flutter theme brightness (fixed black page/white text on dark system with light app) (:139-145; `c6ed2b3`).
- Android: depends on `com.cyl.search:cylsearch`; example includes `android/merged` as composite build (:146). iOS: CocoaPods, static frameworks, SPM off in example (`enable-swift-package-manager: false`) (:149-150, :265-270).
- CYLTabBarController tab bar (`626763e`; :184-201): `flutter_cyltabbar` configured from `assets/cyl_tabbar_configuration.json` loaded in Dart and passed as `configuration` (`bundle:` routes do not reach Flutter assets on iOS); plus button page via `CYLTabBarItemPageIdentifier`; icons from SF Symbols as 1x/2x/3x variants (`tool/render_tab_icons.swift`; a single 3x rendered 3x too big on iOS). Android needs `MainActivity extends FlutterFragmentActivity` (:199). ViewPager2 was undeclared at TabBar `50d9018`: fixed upstream PR #791 (`74aa25e`).
- iOS shows max five tab items (sixth becomes "More"), so No results / No content share one "Empty results" tab (:237-238).
- Discover page: data from CYLSearchDiscover.bundle copied to `assets/discover/<language>/`; `CYLTagListView` height from `heightThatFitsWidth` (:230-236).
- **Bug fixed (2026-11-13): plus button title disappears on its own page** (:369-430). The suspected `cyl_updateLiquidGlassMask` was NOT the cause (`CYL_PLUS_BUTTON_LENS_MASK_ENABLED` already 0 at `74aa25e`; stays 0). Cause: with `CYLPlusButtonAlignsTitle` on, the title is drawn by its tab item inside the selected Liquid Glass lens, and TabBar hid the lens on the plus page (`CYLPlusButtonShowsSelection` off, button not layout-centered). Fix in TabBar PR #793 (`8ae53a7`), pinned `bc73220`. TabBar unit tests claimed 135, 0 failures, 2 skipped. Related TabBar commit `d90802e` (Home icon after More editing): UIKit never calls `-[UITabBar endCustomizingAnimated:]`, fix polls `isCustomizing`. TabBar standing rule: on any plus button bug set the mask switch to 0 and retest.
- Test counts over time: 6/6 (:155), 7/7 plugin + 3/3 example (:239), clean clone 13/13 with 3 analyze infos (:51), 18 of 18 on 2026-11-21/22.
- **Environment failure "Unable to locate the Dart VM executable"** (:14-28, 2026-11-18). The file's Windows paths have lost some backslashes; verbatim they read `C:cylbuild\flutter`, `C:dev\flutter`, `bincachedart-sdk\bindartvm.exe`. Inferred real paths: `C:\cylbuild\flutter`, `C:\dev\flutter`, `bin\cache\dart-sdk\bin\dartvm.exe`.
  - Fix (ask the user first, SDKs are shared): delete `bin\cache\dart-sdk` and `bin\cache\engine-dart-sdk.stamp` (verbatim `bincachedart-sdk`, `bincacheengine-dart-sdk.stamp`); with the stamp left, flutter.bat skips download and fails "The system cannot find the path specified"; run `flutter --version`; check dartvm.exe is back. Suspect a system cleaner (not Defender).
  - 2026-11-19: delete auditing enabled on both dartvm.exe files and their bin folders: `auditpol /set /subcategory:"{0CCE921D-69AE-11D9-BED3-505054503030}" /success:enable` plus an `Everyone`/`Delete` audit rule. Find the deleter (elevated PowerShell): `Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4660,4663} | Where-Object { $_.Message -match 'dartvm' }`. Undo: same auditpol command with `/success:disable`.

## 3. React Native (android-and-cross-platform.md)

- Package `CrossPlatform/react-native-cylsearch` (create-react-native-library; Fabric; Kotlin + Objective-C++; RN 0.88 CLI example), layout like `react-native-cyltabbar` (:280-282). Components `CylsearchView` (events `onTextChange, onSubmit, onSuggestionSelect, onClose`), `CylsearchBarView`, `CylsearchTagListView` (sized by `onHeightChange`); JS wrappers CYLSearchView, CYLSearchBarView, CYLTagListView pass color scheme (:282-286).
- iOS: podspec depends on CYLSearchViewController (static); .mm views import CYLTableViewPlaceHolder header before generated Swift header (uses `CYLPlaceholderScenario`). Android: `com.cyl.search:cylsearch:0.1.0` substituted with `android/merged`; `CYLSearchBarView` is final so it is wrapped in a FrameLayout (:287-292).
- CYLTableViewPlaceHolder privacy manifest clashed ("Multiple commands produce .../PrivacyInfo.xcprivacy"); moved into a resource bundle, PR #29 `a96e9d2` (:293-297).
- Tab bar setup: run `example/scripts/fetch-cyltabbar.sh` **once before `yarn`** (checks out `cyl.tabbar.commit` into git-ignored `example/vendor/`); package.json `portal:` dependency; Metro reads TS sources (`metro.config.js`, condition `react-native-cyltabbar-source`); Podfile uses checkout as pod; `settings.gradle` `cylAndroidRoot` -> its `Example-Android`. Not a yarn workspace, so a git dependency was impossible (:336-344). Usage `<CYLTabBar items plusButton tapAnimation="scale" onTabSelect>`. TabBar fixes PR #793: 15 C functions declared twice, rejected by ObjC++ (`2bd846a`); missing `androidx.viewpager2` (`2a12582`). (Note #793 is also cited as the plus-title fix at :406.)
- iOS automation: launch argument `-initialTab discover|bar|tags|empty|list` read via RN `Settings`; `simctl launch cylsearch.example -initialTab <tab>` (:327-329). `tablist` container hid tabs from iOS accessibility; each tab now its own element (`fc55a2f`). Touch by label with `/opt/homebrew/Cellar/xcodebuildmcp/2.7.0/libexec/bundled/axe` (:357-358). Done 2026-11-15 (:366).
- Verification under host load about 970: release build used; debug crashed once in RN dev-tools `CxxInspectorPackagerConnection` (not the library) (:301-306).
- Windows (:38-58, 2026-11-18): `react-native doctor` 0 errors, yarn 1.22.22 via corepack, **JDK 17 from Gradle's toolchain folder as JAVA_HOME** (21 above supported range); Flutter 3.50.0 doctor ok except Visual Studio (desktop only). **Deep clone paths break RN CMake (260 chars)** (RN README "Building the example on Windows"). Example-only bug fixed: white status-bar icons on white page (`src/App.tsx` StatusBar). jest 5/5, tsc 0 errors, flutter test 13/13; HarmonyOS ohosTest 29/29. Flutter debug native tab bar appeared about a minute after launch (:50). Pins then: TabBar fe5c3ae3, ClassifyMenu 333b349.

## 4. WeChat mini program (android-and-cross-platform.md:98-125)

- `CrossPlatform/wechat-miniprogram-cylsearch`, npm `cyl-search-miniprogram` version 0.1.0 (**[checked]** package.json version 0.1.0). Logic: `CYLSearchSuggestionStore` (4 policies on wx storage), `CYLSearchBarItem(s)`, `CYLSearchViewModel`; tests `node --test` (8 then; later npm test 58, 61, 86).
- 2026-11-15: runs in DevTools (base lib 3.6.6), `example/`, `scripts/sync-example.js`, `scripts/devtools-screenshots.js`. Fixed `cyl-search` infinite recursion (`sync()` wrote its own observed `suggestions`). Then open: search icon image, Lottie placeholders, API table (:109-110; API tables exist later, core-todo.md:250).
- Packaging verified: `npm pack`, tarball in a new mini program, DevTools Build npm, `require('cyl-search-miniprogram')` resolves; details in miniprogram-api-alignment.md (:115-120).
- Publish procedure (open): user runs `! npm login`, then `npm publish` from the package dir. Pre-checks: name free (`npm view` gave 404 on 2026-11-15, also for cyl-placeholder-miniprogram and cyl-tabbar-miniprogram), version, `npm pack --dry-run` lists only `src/, README.md, LICENSE`.
- Editing-bar refocus bug (core-todo.md:287-307, fixed 2026-11-19): WeChat focuses an `<input>` only on `focus` false->true. Fix: `requestInputFocus()` clears `inputFocus` and re-sets next frame; editing bar calls it for every new non-empty `value`. DevTools 2.02.2609250, miniprogram-automator; npm test 58/58. Phone check by user still open.
- DevTools draws no keyboard, so keyboard-overlap cases need a real phone (core-todo.md:229-230).

## 5. HarmonyOS NEXT (android-and-cross-platform.md:432-533, 684-711)

- Task rules (:437-448): study Applib-HarmonyOS/FlexibleSearchBar and record what is taken; full match of iOS public API; table harmonyos-api-alignment.md (iOS API | doc comment | counterpart, default TODO); score by `python3 scripts/harmonyos-api-alignment.py` until 100. TabBar/Liquid Glass API belongs to CYLTabBarController.
- FlexibleSearchBar is a HarmonyOS 2 Java UI component, no code reused; borrowed the open/closed model with one animated fraction -> `isIconified`/`setIconified(_, animated)`, `expansionFraction`, `CYLSearchBarExpansionAnimation.circularReveal`; no custom canvas (:459-465).
- Project: HarmonyOS 6.0.1 API 21 (compatible 5.0.0 API 12), HAR `cylsearch`, ArkTS state management V2, each iOS class = `@ObservedV2` model (`@Trace`) + component (:466-469).
- Build (Mac): `DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk hvigorw assembleHar --mode module -p module=cylsearch@default -p product=default` (tools from `DevEco-Studio.app/Contents/tools`) (:470-471). Example HAP: `hvigorw assembleHap --mode module -p module=entry@default -p product=default`, unsigned (:491-495).
- Setup before building after TabBar switch: `python3 harmonyos/scripts/sync-sub-repositories.py` then `ohpm install --all` (:509). Strings import: `harmonyos/scripts/import-android-strings.py`.
- Progression: 49/100 (397 rows, 196 done) -> 397/397 (compile-only claim, :484-490) -> ran on Mate 70 Pro emulator 2026-11-16 unsigned (:502-528), 30 locales.
- Testing gotchas: **`uitest dumpLayout` returned a stale tree; confirm with screenshots (`snapshot_display`)** (:515-517). Tab buttons lost `CYLTab<n>` ids so UI test locators needed change (:509-511), yet later fix says tests go back until tab bar (`CYLTab0`) shows (:532-533). Shared emulator: another session's apps came to front; first tap after launch only dismisses keyboard. 13 run, 10-11 pass; re-run needed with exclusive emulator (superseded by later "hypium 29 of 29" core-todo.md:244; the CYLSearchUI suite later hung, tag-view-suggestions.md:298).
- Rive crash (2026-11-16, :684-711): `@ohos/rive` 1.0.4 crashes with GPU renderer on emulator (`eglDestroySurface` on EGL worker thread) and with rapid view dispose/recreate; fixes: Canvas renderer on emulator (placeholder `1902852` `cylRiveRendererType()`; ClassifyMenu `3417e7e`) and one view per item. Core has no Rive code; pins in `harmonyos/oh-package.json5` moved placeholder 5bcbdb5->76762c6, TabBar ea5b989->c795d08. Other platforms need no change.

## 6. Core behaviour and features (core-todo.md)

### Behaviour rule 1 (2026-11-13, :12, :14-43)
**Focus alone changes nothing below the search bar** (cache list, header, suggestions, placeholder, frame). Only text changes (type, delete, paste, clear, selected suggestion) or data changes (submitted query, cache cleared) update it. Finding: neither core refreshed on focus; the report was the verification script's own edits. Tests `testFocusAloneChangesNothingBelowTheSearchBar` / `focusAloneChangesNothingBelowTheSearchBar`. Each core behaviour rule must have a test.

### Suggestion cache (DONE 2026-11-14, :45-168)
- Survey: only persistent store was legacy ObjC `CYLSearchController` history (NSUserDefaults key `kSearchHistory`); no database anywhere (:47-56).
- API: `CYLSearchSuggestionCachePolicy` = none, database (default; system libsqlite3 / SQLiteOpenHelper), userDefaults/SharedPreferences, sandboxFile (JSON on Android); protocol `CYLSearchSuggestionCache` (load/add/remove/clear); `CYLSearchSuggestionStore` (`maximumCount` 20, `name` separates caches). `CYLSearchView`: `suggestionCachePolicy, suggestionCacheName, suggestionCache, suggestionCacheHeaderView, suggestionCacheTitleLabel` ("Recent searches"), `clearSuggestionCacheButton`, `clearSuggestionCache()`, `showsEmptySuggestionsPlaceholder, emptySuggestionsScenario, emptySuggestionsView`. Submitted queries cached newest-first without duplicates; empty query lists cache; typing puts cached matches before `suggestions`; clear announces for accessibility (:61-85). **[checked]** `maximumCount = 20` is now at `Sources/CYLSearchBar/CYLSearchResources.swift:161` (the file named at :77 is gone).
- `focusesSearchFieldOnShow` (default true; false = list/placeholder with keyboard down, focus only on tap) (:170-191). **[checked]** default true, CYLSearchView.swift:568. Test `testFocusesSearchFieldOnShowDecidesWhenTheKeyboardAppears`.
- `showsSuggestionCacheHeader` (DONE 2026-11-21, `efb3b78`, :232-250): default true (**[checked]** CYLSearchView.swift:511); false hides header+trash, cache stays. On Android, HarmonyOS, mini program, Flutter, RN. Claimed: :cylsearch 26/26, hypium 29/29, npm 61/61, flutter 18/18; **iOS sides of Flutter and RN not compiled (no Xcode)**.
- Animated placeholder: iOS needs a CYLTableViewPlaceHolder animation engine subspec (Lottie, lottie-ios >= 4.5.1), still image fallback (:103-114). **CocoaPods gotcha: stale cache installed only CYLRefresh; fix `pod cache clean CYLTableViewPlaceHolder --all`** (:109-111). Android done 2026-11-15 via placeholder PR #30 (`af23ea0`), module `android/placeholder-lottie` (lottie-android 6.6.2), assets `CYLPlaceholderAnimations`; `cylsearch` depends on `:placeholder-lottie`; this supersedes "Still open" at :126-128 and :149-156. Tests claimed 36/36, 3/3, 16/16.

### Placeholder under the keyboard (TODO 2026-11-19, :193-230) score 90/100
- Acceptance 100: placeholder fully above keyboard on iOS, Android, RN, Flutter, HarmonyOS, mini program with screenshots; 60: iOS+Android.
- Android: `CYLSearchView.kt` pads both placeholders by keyboard inset. iOS: `CYLSearchView.swift` frames `emptyResultsView`/`emptySuggestionsView` above the keyboard; test `testEmptyResultsPlaceholderStaysAboveTheKeyboard` (before: ended 874 pt, keyboard from 538 pt; 29 tests pass).
- Native Search tab (Issue #1317 page, plain UISearchController + `cyl_reloadData`) is CYLTableViewPlaceHolder's job: fixed in its `d19120f` (f7e0c4d was not enough), pinned everywhere.
- HarmonyOS passes without code change (system keyboard avoidance). Mini program needs a real phone (still open 2026-11-21).

### Editing bar (DONE 2026-11-19, :252-285)
- iOS `CYLSearchBarView.editingBar(placeholder:actionTitle:)` (ObjC `+editingBarWithPlaceholder:actionTitle:`): no magnifier; trailing `cancelButton` is the action, submits via `editingSubmitHandler` like return, after delegate `-searchBarView:shouldSubmitText:`; words capitalized, no autocorrect, opaque; `pinToKeyboard(in:)` uses `keyboardLayoutGuide` (undocked too); `isEditingBar`. Test `testEditingBarSubmitsAndRidesOnTheKeyboard`.
- Android (`2fee101`): `editingBar(context, placeholder, actionTitle)`, trimmed text, `pinToKeyboard(container)`, `keyboardOverlapHandler`; test `CYLSearchBarEditingBarTest`.
- HarmonyOS: `editingBar(placeholder, actionTitle)`, `enterKeyTapped()`, `pinToKeyboard(uiContext)` (`KeyboardAvoidMode.RESIZE`); no capitalization setting.
- Mini program: `submitEditing()`; component props `editingBar` (event `editingsubmit` {text}) and `pinsToKeyboard` (`wx.onKeyboardHeightChange`).
- Flutter `CYLSearchView(editingBar: true)` (`8989d69`), RN `<CylsearchBarView editingBar>` (`274ba00`). Used by the contact-tags examples ("Manage"). The "for the Windows session" note at :265-266 is superseded by :267-285.

### iOS position on content-below-bar ownership (2026-11-20, :309-321)
Rule: the core creates the content page, listens to tag-list drag, holds own scrolling only while dragging; examples never create/find/switch a scroller. Mini program implements it in `cyl-search` content slot (`7757f9c`, ClassifyMenu `8c141d8c`). iOS wires no lock: `CYLTagListView` drag is UICollectionView interactive movement on the same scroll view. A host scroll view inside `CYLSearchView.contentView` would need a core-owned lock. Physical-iPhone drag unchecked.

## 7. Tag-view suggestions (tag-view-suggestions.md)

Note: **lines 301-516 duplicate lines 69-284** (see C-dup).

- iOS (`e1a771a`): `CYLSearchView.suggestionStyle` (`.list`/`.tags`), `suggestionsTagView` = ClassifyMenu `CYLTagListView`; tapped tag acts like a row (:117-120). Podspec depends on ClassifyMenu; Podfile pins by `:git`+`:commit`; static frameworks (`use_frameworks! :linkage => :static`); `scripts/pod-lint.sh` checks pinned commit into `build/lint-specs/`, lints with `--include-podspecs --use-static-frameworks` (ClassifyMenu not on trunk) (:121-125). Requirement: local path only during development, never committed (:12-14).
- Example tabs "Tag style" and "Discover" (`CYLSearchDiscoverViewController`, `CYLSearchDiscover.bundle`, copied from ClassifyMenu's CYLMenuExample at e550a01). Tests 19/19. Known: a sparkle emoji shows as box on fresh simulator.
- Android (`ffac758`, `0c8e306`): `CYLSearchSuggestionStyle.List/Tags`, `suggestionsTagView`, `searchViewDidSelectSuggestion`, `submitsOnSuggestionSelection`; `CYLSuggestionStyleFragment`, `CYLSearchDiscoverFragment`; library fix: `CYLSearchBarView` keeps accessory view's own size.
- Android tag ellipsis bug (DONE `74b75a6`, :189-224): cause in ClassifyMenu `CYLTagButton`: children measured UNSPECIFIED so ellipsize never applied; `place()` now measures at frame; ClassifyMenu PR #17 `f972416`, `CYLTagTitleEllipsisTest`. User explicitly rejected calling it a library "difference".
- Fold control lost on later platforms (BUG DONE 2026-11-13, :226-281): core params `suggestionsFoldControl` (default inline icon chevron as last tag) and `suggestionsFoldedRowCount` (default 2; 0 = all). iOS relayout via private `CYLMenuDelegate` object (no new public conformance). Flutter `suggestionsFoldControlPosition/Content, suggestionsFoldedRowCount`; `CYLTagListView(foldControlPosition:, foldControlContent:, foldedRowCount:)`. Flutter-Android fix: report max of `heightThatFitsWidth` and `contentHeight` (`menuDidChangeContentHeight`). Tests iOS 25/25 (`testTagSuggestionsEndWithTheFoldButtonByDefault`), Android 15/15.
- **Current default (2026-11-22, branch feat/harmonyos-parity, PR #11, :284-300): tags**, folded, fold control last, on iOS, Android, HarmonyOS, mini program, RN (`cylSearchViewSuggestionStyle`), Flutter. **[checked]** CYLSearchView.swift:187 `.tags`; Android CYLSearchView.kt:347 `Tags`. Tests exercising lists and list replicas (iOS `CYLOriginalSearchDemoViewController`, Android MaterialSearchView sample) set list explicitly. Fold control hides itself when all tags fit (`canFoldSection` false); a different behaviour belongs in ClassifyMenu. This supersedes the 2026-11-12 era default of list.
- Two entries for that date; **:284-298 + :299-300 are the more complete/newer account** (inference from content: "rerun after the iOS fix"): iOS 17.5 144/144; iOS 27.2 144 with 1 flaky (`testI4ShortListHeaderSettlesFullyShownOrHidden`, passes alone); iOS 26.5 1 failure `CYLSearchBarStyleTests.testB7CancelDoesNotJitterWhenLeavingSearch` (bar-only, fails alone, handled by another session); Android unit tests green; npm 86/86; Flutter 18/18; **RN jest 10/10, tsc clean**; HarmonyOS CYLSearchCore 22/22, CYLSearchQMUIPort 12/12, **CYLSearchUI hung**. The second (:516-537) has the older numbers (140 of 143; RN test not run), but it carries the screenshot lines (:535-536, core 4cc5638/8df22f8, ClassifyMenu 9dc1f761) and the TODO line (:537).
- iOS first-row blur fixed (`4cc5638`, :299): iOS 26 scroll edge effect; hide `topEdgeEffect`; test `testTagSuggestionsStartBelowTheSearchBarWithoutAnEdgeBlur`. **[checked]** the code is now in CYLSearchSuggestionArea.swift:201.
- Android first/last tag rows cut ~5 px: **NOT fixed** (:300), located in ClassifyMenu Android `CYLTagListView`; margin/padding change in CYLSearchView had no effect (reverted); next: compare `heightThatFitsWidth` with `computeFrames` `totalHeight` for folded inline control.

## 8. Swift migration (swift-migration.md) and coding standard (swift-coding-standard.md)

- Core migration 2026-11-12, 100/100 (:7-63). Score = ObjC lines removed from Sources/ / 2838 x 100 floored: 14 files/2838 -> 0, 3, 10, 21, 39, 63, 100. Every type kept ObjC name through `@objc(...)`. Claimed on Xcode 27.2: 19/19, 0 warnings, pod lib lint, comment check; PR #8, `feat/swift-core`. `CYLSearchExampleViewController` moved to Swift (ObjC cannot subclass Swift). Bug found: lapism port's `searchBarViewDidTapWhileNotEditable:` mismatched protocol.
- **Rule (2026-11-13, :85-87; standard :95-97): example build errors are fixed in examples; never keep a core API/overload/shim/deprecated alias just for an example; never lower core quality. Compatibility matters only for published API users.**
- Second wave (DONE 2026-11-21, :102-183): 4,139 ObjC lines -> 59. Steps 0/12/50/51/100. Legacy Objective-C demo `CYLSearchViewController/` (in no Xcode target since 2015) rebuilt as `CYLOriginalSearchDemoViewController` + `CYLKenBurnsView` + `CYLOriginalDemo.bundle`, removed in `726a2da` (folder keeps Images.xcassets, CYLLaunchScreen.storyboard, the GIF `it_is_effect_show__SearchBar.gif`). Target effect described :139-143. Matching fixes (:161-164): `secondarySystemGroupedBackground` field, `showsCancelButton` + `navigationIcon = .none`, white rows via `suggestionCellConfiguration`. iOS 26 glass back button shows no "返回" title (accepted difference).
- Tests (:173-181): 37 Swift + 3 ObjC smoke = 40/40; base `CYLSearchExampleTestCase`; `@testable import CYLSearchExample`; 12 KVC/selector calls remain on private members with comments. Constraints: `objectVersion = 46`, explicit file references, keep ObjC smoke test `CYLSearchCoreObjectiveCSmokeTests.m`. RN `.mm` bridges intentionally ObjC++. **[checked]** the only .m among the four iOS example/test folders searched is that smoke test (tests now include many more Swift files than six).
- Cells keep `textLabel/imageView` (content configurations broke `testSearchBarDemoRow`) (:129-131).

### Coding standard essentials (swift-coding-standard.md)
- Precedence: this doc over skills; official Swift rules over this doc (:6-9). Skills pinned in `.agents/skills.json`.
- Swift 5 mode (`SWIFT_VERSION = 5.0`, Podfile `ENV['SWIFT_VERSION']='5'`), iOS 15+, UIKit only; main thread; `@MainActor` only if ObjC interface unchanged (:13-18).
- Naming (:22-29): public types start `CYL`; no new global functions; lowerCamelCase without underscores (SonarCloud swift:S100, S115; re-evaluated 2026-11-22, skill `cyl-naming`); one primary type per file; Booleans read as assertions; private helpers unprefixed; public extension members on system types `cyl_` in ObjC names / `cyl` in Swift.
- ObjC compatibility (:36-48): `@objc(CYLName)`, keep selectors and getter names, `@objc public protocol ...: NSObjectProtocol` with `@objc optional`, enums `Int` in original order, Swift-only types internal or wrapped, `NS_SWIFT_NAME/NS_REFINED_FOR_SWIFT/NS_SWIFT_UNAVAILABLE` count as translated; explicit nullability, `null_resettable` = `T!`.
- Structure (:52-65): public/open only as needed, final by default; ObjC callers `@import CYLSearchViewController;`; `// MARK: -` sections; no `!`/`try!` outside tests; weak delegates and weak self in stored closures.
- Docs comments: three-line `/**` block above every public declaration; no `///` in core; mention matched Android API (:69-73). Format: 4 spaces, 120 columns, trailing commas in multiline literals, system imports first (:77-79).
- UI: frames where original used frames, else Auto Layout; search bar never covers a view; strings via `CYLSearchResources.localizedString(forKey:)` (4 languages); accessibility labels, Dynamic Type (:83-86).
- Before commit (:92-93): clean build, `scripts/unit-tests.sh`, analyze 0 warnings in Sources/, `scripts/check-public-api-comments.sh`, score in swift-migration.md.

## 9. CI/CD (CI-CD.md)

- `.github/workflows/ios.yml`, modeled on CYLTabBarController's at `d574501c1af217fb91347845085b46f047644ad9` (feat/cross-platform-components, 2026-11-11 17:40:12 +1300); when upstream changes, compare and update the recorded commit (:3-10, :81-82).
- Triggers: PRs, pushes to `master` and `claude/**`, `workflow_dispatch` (**[checked]** matches).
- Jobs (:19-26): Changes (docs/assets/*.md-only PRs skip macOS steps but pass), shellcheck (`shellcheck scripts/*.sh`), Public API comments, pod lib lint (`scripts/pod-lint.sh lib --verbose`), Example build and analyze (warns on stale TabBar pin, fails on warnings in Sources/), Unit tests (`scripts/unit-tests.sh`). No Carthage, no demo matrix. **[checked]** ios.yml also has an "Example screenshots" job and runs `scripts/check-licenses.sh` in the comments job.
- Runner `macos-26`; override with repo variable `MACOS_RUNNER` (e.g. xcode-27) (:31-32).
- Run locally (verbatim, :44-52):

```sh
scripts/ci-checkout-dependencies.sh
scripts/check-public-api-comments.sh
scripts/pod-lint.sh lib --verbose
rm -rf build && scripts/ci-build-example.sh build
scripts/ci-build-example.sh analyze
scripts/unit-tests.sh "iPhone 17"
scripts/local-run-environment.sh
```

- `local-run-environment.sh` writes the first line of ios.yml (`# local-run-environment: macOS 27.3 (26C5035r), Xcode 27.2 (27B52)`); run before a local build.
- History: master green 2026-11-11 (run 43007916007); 2026-11-12 run 43100220331 failed only the warnings gate (`resignFirstResponder` not calling super, `osx.cocoa.MissingSuperCall`), fixed. Gate covers Sources/ only (pods have their own issues).
- Decisions: placeholder sibling follows default branch, set `CYL_PLACEHOLDER_REF` if it breaks (see C4); TabBar pin staleness only warns (refresh with `scripts/latest-cyl-commit.sh`; the workflow message mentions `--podfile`, **[checked]**).
- **Concurrency (2026-11-17): `cancel-in-progress: false`** (**[checked]**) because frequent multi-session pushes left no run finishing for >2 h; one pending run is replaced by the newest (:139-144). This supersedes the "newer run on same ref cancels the older" statement at :15.
- Example screenshots job (done 100/100, 2026-11-19, :146-175): launch args `-CYLDemoTab <index>`, `-CYLDemoRow <index>`; `scripts/example-screenshots.sh`, `scripts/publish-screenshots.sh`; 10 screens published to branch `ci-screenshots/<branch>/<sha7>/` (artifact storage blocked from cloud sessions). Tab order search, examples, search bar (plus), tag style, discover; files `tab2-search-bar, tab3-tag-style, tab4-discover` since `0d524e7`. **Gotcha:** under `set -o pipefail`, `launchctl list | grep -q` fails when grep exits early (SIGPIPE), so running app looked stopped; read list into a variable first. Run 44388884124 (37c96d3) green.
- Screenshot rules (:84-137): every screenshot (CI and local) in docs/ with related document and committed; update README with latest when result is as expected; label platform, OS, simulator, SDK, repo version/commit, time; original resolution; take at milestones; README shows cropped key details, stitched. **Stitch order: vertical (one per row) first, then two columns, last a row of max three.** The user's original "horizontal first" wording was self-contradictory and corrected by the user to vertical-first (:137, supersedes the "to be confirmed" at :135-136). Tool `scripts/stitch-screenshots.swift` (**[checked]** a .ps1 variant also exists).

## 10. Licenses (licenses.md)

- Rule: every package published to a registry ships its license inside, in the resource bundle (create one if missing). Owner chose **MIT everywhere, Copyright (c) 2015 ChenYilong** (:12, 2026-11-17). Skill `cyl-license`. Root LICENSE copied byte for byte.

| Registry | Package | License location (:31-38) |
|---|---|---|
| CocoaPods | CYLSearchViewController.podspec (`s.license = { :type => 'MIT', :file => 'LICENSE' }`) | LICENSE, Resources/CYLSearchViewController.bundle/LICENSE |
| Maven/Gradle | android/merged/cylsearch | src/main/resources/META-INF/cylsearch/ |
| ohpm | harmonyos/cylsearch | LICENSE, src/main/resources/rawfile/CYLSearchViewController.bundle/ |
| npm | CrossPlatform/react-native-cylsearch | LICENSE |
| npm | CrossPlatform/wechat-miniprogram-cylsearch | LICENSE and src/LICENSE |
| pub.dev | CrossPlatform/flutter_cylsearch | LICENSE |

- Android/HarmonyOS bundles also carry `NOTICE, LICENSE.material-design-icons, LICENSE.placeholder-third-party, ICON-SOURCES`.
- Check: `bash scripts/check-licenses.sh` (in CI; "8 files", later "OK (9 files)").
- Maven (2026-11-21): publishes `com.cyl:cylsearch:0.1.0` (release AAR + sources), POM MIT + Apache-2.0 for Material icons; check with `./gradlew :cylsearch:publishReleasePublicationToBuildRepository` (JDK 17). Placeholder coordinates: `io.github.chenyilong:cyltableviewplaceholder:0.1.0`, `...-refresh:0.1.0`; also `io.github.chenyilong:cyltabbarcontroller-animateditem` must be on Maven Central before a release. The temporary `pom.withXml` mapping was removed 2026-11-22 (pin a169386) (:44-67; supersedes the unspecified-coordinate and pin-c84fce9 notes). **[checked]** no withXml in build.gradle.kts; current placeholder pin is f4cf978.
- QMUI_iOS port (2026-11-22, :69-94): Tencent MIT. Ported files with Tencent header + "Ported to Swift for CYLSearchViewController, 2026.": `CYLSearchBar.swift` (QMUISearchBar, UISearchBar+QMUI), `CYLSearchBarAppearance.swift`, `CYLSearchController.swift`, `CYLSearchTableViewController.swift`; `CYLSearchHeaderSnapper.swift` is original (no header). iOS notice: `Resources/CYLSearchViewController.bundle/LICENSE.QMUI` + NOTICE. Android also (commit `feded48`): `CYLSearchBarAppearance.kt, CYLSearchListView.kt`, QMUI-derived parts of bar/view; `android/merged/cylsearch/LICENSE.QMUI`, NOTICE, copied to META-INF/cylsearch. **This supersedes "iOS pod only" (:83).** Script fails if LICENSE.QMUI missing, NOTICE omits it, or a ported file loses the header. **[checked]** the file list names CYLSearchBar.swift, but no such file is in Sources/CYLSearchBar now (listing: Appearance, BarView, Controller, HeaderSnapper, NavigationBar, PresentationState, Resources, ResultsComponent, SuggestionArea, TableViewController, TagListHeader, TagListStyle, View).

## 11. Release-RAM manual (Release-RAM.md, owner task 2026-11-26)

- Order (:12-20): first make sure no session is using an emulator; close WeChat devtools, HarmonyOS emulator, watchman, Gradle, Obsidian, Android Studio, Android emulator, Chrome, Finder windows; sleep/shut inactive emulators; close Bionic, opencode, MiniMax Code, TextExpander; dim all displays; then message every Windows and macOS session: "The emulators were restarted; if you were waiting for an emulator to debug, start the emulator debugging again."
- Scripts (PowerShell 7, run from repo root; **[checked]** all exist): `release-ram.ps1` (plain run = dry run); `scripts/release-ram/stop-apps.ps1` (Obsidian, studio64, Chrome, Edge; kill after 8 s, unsaved work lost); `close-explorer-windows.ps1` (`-RestartShell`); `restart-emulators.ps1`; `set-brightness.ps1` (`-Restore`; built-in panel only).
- Steps: check `C:/w/heavy.lock` (shared lock naming holder), `adb devices`, ask sessions.

```powershell
pwsh -File ./release-ram.ps1
pwsh -File ./release-ram.ps1 -Apply -Force -Keep emulator-5556
pwsh -File ./scripts/release-ram/restart-emulators.ps1 -Platform android -Force
pwsh -File ./scripts/release-ram/restart-emulators.ps1 -Platform harmonyos -Force
```

- Switches: `-RestartShell, -SkipEmulators, -StopEmulatorsOnly, -Platform android|harmonyos|both` (default both), `-DimDisplay`. The test table also mentions `-StopOnly` (:102).
- Defaults: AVD `CYL_Second_API_37`, port 5558 (`emulator-5558`), HarmonyOS `Mate 70 Pro`; `-Avd -Port -HvdName -Headless` (use headless if windowed start hangs).
- Stop sequence (:68-76): `adb -s emulator-<port> emu kill`; after 20 s `taskkill /T /F` on the tree; delete `*.lock` in `%USERPROFILE%\.android\avd\<AVD>.avd`. Without `-Force` refuses when busy (held lock, instrumentation/uiautomator, Gradle connected*AndroidTest, `hdc` `aa test`, adb unresponsive). Only the named emulator is touched; `-Keep` never stopped.
- HarmonyOS start needs `Emulator.exe -hvd "<name>" -path <instances folder> -imageRoot <image folder>`; override `CYL_HVD_PATH`, `CYL_HVD_IMAGE_ROOT`; stop `Emulator.exe -stop`; `hdc list targets` shows 127.0.0.1:5555.
- Claimed tests (:91-108): Android start/busy/hung (7 s snapshot, 44 s hung) pass; brightness dry-run only (no WMI panel); closing the four apps for real not exercised. Script does not message sessions. **macOS section not written** (:110-116).

## 12. Docs-folder rules, commit readiness, screenshot index

- instructions.md (docs/): English; keep tracker structures; record unfinished work as `TODO` heading in the most relevant existing doc before commit, no duplicate trackers; TabBar integration TODOs in CYLTabBarController-Integration.md; commit records factual, linked from commit message when detail > 50 chars; log every task first (context, requirements, verbatim + English prompt), mark `DONE (YYYY-MM-DD)`; screenshots in assets/ with labels; translated projects need open-issues table with score; animation pages: Play all (from progress 0), speed slider, loop switch, applied live, all platforms (:6-26).
- commit-readiness-2026-11-09.md: added policy (track unfinished work, English Conventional Commits compatible with Commitizen), `*.base` gitignored (docs/docs.base local), TODOs must give remaining work, known defects, API risks, verification steps; linked docs/ note when detail > 50 chars; Issue #1317 repro/verification status unchanged by that commit (:3-22).
- screenshot-index.md: 14 screenshots with no caption elsewhere (:5-18), dates 2026-11-14 to 2026-11-23, commits 6a9b5d9, cc65415, 27b4d03, 0f20ae0, 012343f, 0aaf47b, aa40cef, 496ac41; topics: Android/Flutter discover items API 35; Android API 37 RN rive tint, status-bar icons, SVGA tab icon/tag button; HarmonyOS searchbar tint and SVGA tag button (including "title cut before"); mini program SVGA tag button "no icon"/"no play", tag style tab; RN iOS search bar. Device/OS/SDK are only what filenames say.
- Process convention seen across docs: task entry = Context, Requirements, Prompt (verbatim) + Prompt (English), Status/Result with evidence, sometimes Acceptance (60/100) and a score; screenshot labels list platform, host, device, SDK, commits, time. Sessions split by platform (Mac: iOS; Windows: others) and sometimes share emulators.

## Contradictions, stale statements and supersessions

- **C1 Maven groupId [checked].** licenses.md:44 and `android/merged/cylsearch/build.gradle.kts:73` publish `com.cyl:cylsearch`. `CrossPlatform/flutter_cylsearch/android/build.gradle.kts:85` and `CrossPlatform/react-native-cylsearch/android/build.gradle:38` depend on `com.cyl.search:cylsearch:0.1.0` (as android-and-cross-platform.md:146, :288). The examples hide this by composite-build substitution; inference: against a real Maven release these coordinates would not resolve.
- **C2 "Four public classes" [checked].** android-and-cross-platform.md:6-8 and swift-coding-standard.md:54-55. Code also has public `CYLSearchBarAppearance, CYLSearchNavigationBar, CYLSearchTagListHeader, CYLSearchTagListStyle` and `open` `CYLSearchController, CYLSearchTableViewController` (plus public enums/protocols).
- **C3 swift-coding-standard.md stale [checked]:** :3-4 lists 3 core files (there are 13 .swift); :14 "No third-party dependencies in the core" (podspec lines 20, 27, 36, 40: CollectionViewClassifyMenu, CYLAnimatedItem, CYLTableViewPlaceHolder/Core, CYLDeallocBlockExecutor; these are by the same owner, but are dependencies); :15 plain `use_frameworks!` (Podfile uses static linkage); :90 tests "Objective-C ... until ported" vs swift-migration.md:173-182 (ported).
- **C4 CI-CD.md:36-40, :71-73 [checked]:** says Podfile uses `:path => '../CYLTableViewPlaceHolder'`; Podfile:15 pins `:git`+`:commit` f4cf978. `scripts/ci-checkout-dependencies.sh:5` still repeats the old statement. Job table :19-26 omits the screenshots job (the doc itself describes it at :146-175) and the license check. :15 vs :139-144 on cancellation.
- **C5 Lottie [checked]:** core-todo.md:105-109 says the core podspec depends on `CYLTableViewPlaceHolder/Lottie`; podspec now depends on `/Core`; Lottie appears in the Podfile subspecs. Inference: "animated by default" may not hold for pod consumers.
- **C6 API row counts:** 294 (android-and-cross-platform.md:609), 299/302/323 (history), 395 (:127), 397 (:485), "289 of 289" for Android, HarmonyOS, mini program (core-todo.md:250, 2026-11-21). **[checked, files outside this assignment]** android-api-alignment.md:54 says 437 rows (409 DONE, 28 N/A); harmonyos-api-alignment.md:31 says 437 (uncommitted working-tree changes exist there).
- **C7 Placeholder pins:** core-todo.md:121 bdd78c7 "everywhere"; :149, :161 say iOS pins at c202b8c (a different branch); later d19120f, 8dc39c3, a169386. **[checked]** current f4cf978 (Podfile, gradle.properties, oh-package.json5).
- **C8 TabBar pins differ now [checked]:** Podfile 08343e9; android gradle.properties af56db22; harmonyos oh-package.json5 d19e138. AGENTS.md: TabBar is pinned to the newest commit on any branch, the same commit CollectionViewClassifyMenu pins for TabBar. Separately, this repository's ClassifyMenu pin is c0b183d in all three places.
- **C9 Stale status lines inside DONE sections of android-and-cross-platform.md:** :97 "logged, not started"; :127-128 "HarmonyOS open 0/323" (heading :76 says it runs); :477-490 "no emulator device exists" (superseded :502-528); :499 "IN PROGRESS" under a DONE heading :432; :153-154 SPM still blocked; :264-272 "Then React Native, then HarmonyOS" (done later).
- **C10 core-todo.md:** :193 headed TODO with Android/iOS fixed, score 90 (open only for phone); :126-128 and :149-156 "Android has no animation" superseded by :157-167.
- **C11 [checked]** android-upstream-issues.md:47 says `setAdapter` is listed in docs/android-and-cross-platform.md; that document (read fully) never mentions setAdapter.
- **C15** android-and-cross-platform.md:509-511 says HarmonyOS tab buttons no longer have `CYLTab<n>` ids (UI tests need new locators); :532-533, later in the same section, says each tab test goes back until the tab bar (`CYLTab0`) shows. The document does not say which is current.
- **C-dup** tag-view-suggestions.md:301-516 repeats :69-284 (**[checked]** line-by-line: only difference is the bullet indent of :301 vs :69); the headings "DONE (2026-11-14) tag-style demos", "Android tag cells cut text", "BUG DONE fold button" and "tags default 2026-11-22" each appear twice. Looks like a merge artifact (inference). The two 11-22 entries differ in test numbers (see section 7). :85 and :317 say "the next entry" for the iOS side.- **C12** tag-view-suggestions.md:158-159 (Android progress note) still says long titles are cut, "see the bug TODO below"; resolved at :208-219.
- **C13** licenses.md:77 lists `Sources/CYLSearchBar/CYLSearchBar.swift`, absent in the current listing [checked]; licenses.md:42 "8 files" vs :89 "9 files" (dated, not a real conflict).
- **C14** CI-CD.md:128-129 and many entries cite AGENTS.md section names (e.g. "Sub-repositories", "Verification -> Screenshots of builds and CI/CD", "Licenses in published packages (added 2026-11-17)"); current AGENTS.md is organised by tags with full text in docs/instructions/<tag>.md.

## Open TODOs and unfinished work (as of the documents; not re-verified)

Cross-platform:
1. Flutter plugin Swift Package Manager (`Package.swift`); blocked until core, ClassifyMenu, TableViewPlaceHolder, TabBar ship Swift packages; owner macOS session (android-and-cross-platform.md:150-154, :265-270). **[checked]** no root Package.swift.
2. Verify VoiceOver double-tap on native tabs inside Flutter (:203-205).
3. iOS Flutter "Searching: ..." snack bar not visible 2 s after tap; check floating tab bar cover (:263-264).
4. Publish `cyl-search-miniprogram` to npm (needs user's `! npm login`) (:121-124); mini program dark appearance never seen (:125-126).
5. Dart SDK deletion culprit unknown; **delete auditing still on** per doc (undo with `/success:disable`) (:23-28).
6. HarmonyOS UI tests: re-run with exclusive emulator (:530-533) and **CYLSearchUI suite hung, rerun** (tag-view-suggestions.md:298, :537). 2026-11-14 note: cross-platform wrappers do not target HarmonyOS (:489-490).

Tag view:
7. Mini program device test for tags default (Windows, WeChat DevTools); rerun HarmonyOS CYLSearchUI; **fix Android ~5 px tag row cut in ClassifyMenu and pin** (tag-view-suggestions.md:300, :537).
8. iOS 26.5 failure `testB7CancelDoesNotJitterWhenLeavingSearch` (another session) and flaky `testI4...` (:298).

Core:
9. Empty-results placeholder under keyboard: mini program on a real phone; score 90/100 (core-todo.md:229-230).
10. User's phone check of the mini program rename refocus (:307).
11. Physical iPhone drag in Manage; if the list scrolls, record and fix in CYLTagListView, core first (:320-321).
12. iOS sides of Flutter/RN `showsSuggestionCacheHeader` not compiled at the time (:249).

Releases:
13. Before Maven release: placeholder, refresh and animateditem artifacts on Maven Central (licenses.md:48-63); also resolve C1.
14. Release-RAM macOS section and scripts (Release-RAM.md:110-116); Windows app closing and brightness not exercised (:105, :108); external monitors cannot be dimmed (:80-81).
15. CI-CD: interpretation items resolved; maintenance duty to track upstream ios.yml (:81-82).
16. commit-readiness: ongoing duty to apply the review to every commit (:20-22).

android-upstream-issues.md and swift-migration.md have no open items (both 100/100).

## Coverage

All reads used the Read tool with offset/limit. Read reports one more line than the assigned count for each file (a trailing empty line); it is included in each range.

| File | Assigned lines | Ranges read | Skipped/unread |
|---|---:|---|---|
| docs/android-and-cross-platform.md | 711 | 1-290, 291-570, 571-711 (+ trailing empty) | none |
| docs/tag-view-suggestions.md | 537 | 1-298, 299-537 (+ trailing); 301-516 read and found to duplicate 69-284 | none |
| docs/core-todo.md | 321 | 1-273, 274-321 (+ trailing) | none |
| docs/android-upstream-issues.md | 202 | 1-161, 162-202 (+ trailing) | none; digest groups the 166 rows by fix/reason, not one line per issue |
| docs/swift-migration.md | 183 | 1-183 (+ trailing) | none |
| docs/CI-CD.md | 175 | 1-175 (+ trailing) | none |
| docs/licenses.md | 94 | 1-94 (+ trailing) | none |
| docs/Release-RAM.md | 116 | 1-116 (+ trailing) | none |
| docs/swift-coding-standard.md | 97 | 1-97 (+ trailing) | none |
| docs/screenshot-index.md | 18 | 1-18 (+ trailing) | none (referenced images not opened) |
| docs/instructions.md | 26 | 1-26 (+ trailing) | none |
| docs/commit-readiness-2026-11-09.md | 22 | 1-22 (+ trailing) | none |

Images linked by these documents were not opened. Targeted checks (searches/short reads, not full reads) covered: Sources/CYLSearchBar declarations and defaults, podspec, Podfile, ios.yml, ci-checkout-dependencies.sh, Gradle files of android/merged and the Flutter/RN plugins, oh-package.json5, the mini program package.json, file listings, and single lines of the two API alignment documents. No tests or builds were run.
