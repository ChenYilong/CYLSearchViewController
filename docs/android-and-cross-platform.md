# Android and Cross-Platform Support

This document tracks support for Android, HarmonyOS NEXT and the cross-platform frameworks (Flutter, then React
Native) for the CYLSearchViewController components.

## TODO (2026-11-12): Android, HarmonyOS NEXT, Flutter, then React Native

- Context: CYLSearchViewController is iOS only today (Objective-C core in `Sources/CYLSearchViewController/`:
  `CYLSearchResultsViewController`, `CYLSearchController`, `CYLSearchBarView`, `CYLSearchView`,
  `CYLMultiSearchView`, `CYLSearchPlaceholderView`, `CYLSearchResources`). The search API parity task
  (`docs/search-api-comparison.md`, compared with five Android libraries) and the Swift migration of the core
  (`docs/swift-migration.md`) were asked earlier and come first, in the order the tasks were given. The repository
  had no Android document, so this one was created. CYLTabBarController (a sibling folder in the vault) already
  ships Android, React Native and Flutter components (`CrossPlatform/`, `Example-Android`) and can serve as the
  reference layout.
- Requirements:
  1. Support Android for the search components.
  2. Support the cross-platform frameworks: Flutter first; adapt React Native only after the Flutter version
     passes its tests.
  3. Adapt to the Android side of HarmonyOS NEXT (HarmonyOS NEXT compatibility for the Android and cross-platform
     builds).
  4. Written in English.
- Prompt (verbatim): "找到docs android相关文档写一个英文TODO：android 与跨端平台（REactNative flutter，先flutter，flutter测试通过后再适配 REactNative）支持适配 android 鸿蒙 NEXT系统。"
- Prompt (English): "Find the Android-related document in docs and write an English TODO: Android and
  cross-platform (React Native, Flutter; Flutter first, adapt React Native after Flutter passes its tests)
  support, adapted for Android and the HarmonyOS NEXT system."
- Status: logged, not started; waits for the search API parity task and the Swift migration.
- Order of work: Android → HarmonyOS NEXT compatibility → Flutter (tests pass) → React Native.
- Decisions (user, 2026-11-13):
  - Flutter wraps the native core, like CYLTabBarController's `flutter_cyltabbar`: a plugin
    (`CrossPlatform/flutter_cylsearch`) shows the iOS Swift core and the Android `cylsearch` views as platform views,
    so the tag style, the empty results placeholder and every later core feature come with it. Dart is not a second
    implementation.
  - HarmonyOS NEXT waits: DevEco Studio 6.0.1 and its tools (`hvigorw`, `ohpm`, the bundled SDK) are installed, but
    no emulator image exists (it needs DevEco's Device Manager with a Huawei account sign-in). Flutter goes first, as
    the original prompt ordered; HarmonyOS is built and verified after an emulator is set up.
- Progress: Android done (the `android/` task below).
- Progress, Flutter (2026-11-13, [`c6ed2b3`](https://github.com/ChenYilong/CYLSearchViewController/commit/c6ed2b3)):
  the plugin works on both platforms; open items below.
  - `CrossPlatform/flutter_cylsearch` (Dart, Swift, Kotlin): `CYLSearchView` and `CYLSearchBarView` widgets show the
    native views as platform views (`UiKitView`; Android hybrid composition) with the iOS parameter names and events
    (`onTextChanged`, `onSubmitted`, `onSuggestionSelected`, `onClose`, `onCancel`). The native views use the Flutter
    app's theme brightness: on a dark-mode system with a light app the first Android run showed a black page and
    white text, now fixed (AppCompat Light / Dark theme on Android, `overrideUserInterfaceStyle` on iOS).
  - Android: the plugin depends on `com.cyl.search:cylsearch`; the example includes `android/merged` as a composite
    build. A composite build allows one Android Gradle plugin, and Flutter 3.47 needs AGP 8.11.1 and Kotlin 2.2.20,
    so `android/merged` moved from AGP 8.7.3 / Kotlin 2.0.21 to those (it builds and its tests pass).
  - iOS: CocoaPods with the local core pod and the sub-repositories pinned by commit, static frameworks. Swift
    Package Manager is off in the example; Flutter warns that a plugin without SPM support will be an error in a
    future version (`TODO`: a `Package.swift` once the core and its sub-repositories can be Swift packages).
  - Tests: `flutter test` 6/6 (parameters with the iOS names and defaults, brightness, events, the platform view of
    each platform); `flutter analyze` clean. Verified by hand on the iOS 26.3 simulator and the Android 15 emulator:
    typing in the native bar reaches Dart ("Text: Rive"), the list and tag styles filter, "zzz" shows the empty
    results placeholder, Back closes the page and pops the route.
  - Screenshots (originals), top to bottom: iOS bar after typing; iOS list style; iOS tag style; iOS empty results;
    Android bar after typing; Android tag style; Android empty results.

    ![Flutter iOS search bar](assets/flutter-ios-search-bar.png)

    ![Flutter iOS list style](assets/flutter-ios-search-list.png)

    ![Flutter iOS tag style](assets/flutter-ios-search-tags.png)

    ![Flutter iOS empty results](assets/flutter-ios-empty-results.png)

    ![Flutter Android search bar](assets/flutter-android-search-bar.png)

    ![Flutter Android tag style](assets/flutter-android-search-tags.png)

    ![Flutter Android empty results](assets/flutter-android-empty-results.png)

    | Field | Value |
    |:---|:---|
    | Platform | Flutter 3.47.9 (Dart 3.13.7) on iOS and Android |
    | Host | macOS 27.3 (26C5035r), Xcode 27.2 (27B5028f), JDK 17.0.21 |
    | Simulator / emulator | iPhone 17, iOS 26.3; `CYL_API35_arm64`, Android 15 (API 35), system in dark mode |
    | SDK | iOS SDK 27.2 (deployment iOS 15.0); Android compileSdk 36 (Flutter), AGP 8.11.1, Kotlin 2.2.20 |
    | Repository | [`c6ed2b3`](https://github.com/ChenYilong/CYLSearchViewController/commit/c6ed2b3) on `feat/swift-core` |
    | Taken | 2026-11-13 03:12–04:52 NZDT |
  - Still open for Flutter (`TODO`): the example with CYLTabBarController's Flutter tab bar (`flutter_cyltabbar`, the
    default example integration: configuration file, raised plus button, one tab per demo); the Discover page of the
    tag-style demos; Swift Package Manager support. Then React Native, then HarmonyOS NEXT (the emulator image is
    downloaded; a device still has to be created in DevEco's Device Manager).

## DONE (2026-11-12): android/ folder: five Kotlin transcriptions, a merged library and example

- Context: refines the TODO above. Android only; iOS code is not changed. The five reference projects were read in
  `docs/search-api-comparison.md`; three are Java or Kotlin libraries (MiguelCatalan Java, lapism and iammert
  Kotlin), yechaoa/MaterialDesign is a showcase app and android-cjj/MaterialSearchView a sample app.
  CYLTabBarController ships an Android tab bar library (`Example-Android` in the sibling folder).
- Requirements:
  1. Create `android/` with one folder per repository (lapism-search, MiguelCatalan-MaterialSearchView,
     yechaoa-MaterialDesign, android-cjj-MaterialSearchView, iammert-MultiSearchView) and a `merged` folder.
  2. Transcribe each project in its folder, all in Kotlin.
  3. Merge the Kotlin code into one project in `merged`, keeping every API; merge the examples into one example
     app that uses CYLTabBarController's Android tab bar, one tab per example; depend on CYLTabBarController's latest
     commit through Gradle or Maven by commit (for example JitPack), else a local path.
  4. In `docs/`, list every public iOS API with its counterpart in `merged` in a second column.
  5. Add the missing APIs to `merged`; mark every row that is not aligned `TODO`; full alignment = 100; score after
     every API added, until 100.
  6. Translate all iOS examples into `merged` (do not change iOS code), using the Android APIs of the table;
     screenshots in the docs and an Android section in README.
- Prompt (verbatim): "将下面的任务，找一个合适的文档，标注关键词TODO：注意本任务仅仅修改android代码，不要改iOS代码。在本项目中新建文件夹命名为 android ，下面的代码 每一个仓库 创建一个文件夹，并创建第四个文件夹命名为merged     https://github.com/lapism/search https://github.com/MiguelCatalan/MaterialSearchView https://github.com/yechaoa/MaterialDesign https://github.com/android-cjj/MaterialSearchView https://github.com/iammert/MultiSearchView 第二步骤：分别将这几个项目在各自文件夹中做代码转录，全部翻译为kotlin语言。第三步骤：将以上几个文件夹里的kotlin代码合并为一个项目，保留所有api接口，并将example合并为一个。使用CYLTabBarController 的android端tabbar 作为展示的功能划分，采用gradle或者maven指向CYLTabBarController 最新提交，找到gradle或者maven使用commit引用的方式集成，如果不行就采用本地路径引用。一个example一个tabbaritem区分。第四步骤：在docs在合适的文档或创建文档，列出iOS端所有的公开api，第二列 ，列出找到的在该merged文件夹下所有的公开api的对应项。第五步，将缺失merged文件夹缺失的API对齐。在该表格未对齐的地方标注TODO如果iOS端和android能完全对齐所有api就是满分，merged文件夹每次新增一个api就在该文档中打分，一直达到满分。第六步骤：将iOS端的example全部移植到merged文件夹，注意是翻译，不要改iOS代码。使用上面提到的表格中android的api实现。并截图更新文档，readme 在android章节。"
- Prompt (English): "Put the following task in a suitable document marked TODO. Only Android code changes; do not
  change iOS code. Create an android folder in this project, one folder per repository below, and a fourth folder
  named merged (the five links). Step 2: transcribe each project in its folder, all in Kotlin. Step 3: merge the
  Kotlin code of these folders into one project, keeping all APIs, and merge the examples into one; use
  CYLTabBarController's Android tab bar to divide the features, depend on CYLTabBarController's latest commit
  through Gradle or Maven by commit, else a local path; one tab item per example. Step 4: in a suitable doc (or a
  new one) list every public iOS API, and in the second column the counterpart found in merged. Step 5: add the
  APIs merged lacks; mark unaligned rows TODO; full alignment of iOS and Android is full marks; score each time an
  API is added to merged, until full marks. Step 6: port all iOS examples to merged (translate, do not change iOS
  code) with the Android APIs of the table, take screenshots, update the docs and README's Android section."
- Findings (2026-11-12, before any code):
  - Licenses: lapism/search, MiguelCatalan/MaterialSearchView and yechaoa/MaterialDesign ship an Apache 2.0
    `LICENSE`; iammert/MultiSearchView states Apache 2.0 in its README. Their code can be transcribed with the
    license and attribution kept. android-cjj/MaterialSearchView has no license, so its code may not be copied or
    translated; its folder would hold an independent Kotlin implementation of the same behavior (a floating button
    that opens a search card with a circular reveal), credited but not derived from its code. Waiting for the user's
    decision.
  - CYLTabBarController's Android library (`Example-Android/cyltabbar`, namespace `com.cyl.tabbar`) is not on Maven
    Central or JitPack, and Gradle source dependencies cannot pin a commit. Plan: `android/merged/settings.gradle.kts`
    checks out CYLTabBarController at the commit pinned in `gradle.properties` (newest commit on any branch, from
    `scripts/latest-cyl-commit.sh`) and includes its `Example-Android` build; a local path override for development.
  - Toolchain: JDK 17 (`~/develop/jdk/jdk-17.0.21+9`), Android SDK (`~/Library/Android/sdk`), Gradle 9.3.1; build
    outside the exFAT volume.
- Decision (user, 2026-11-12): android-cjj gets an original reimplementation, credited but not derived from its code.
- Progress:
  - Step 1 done: `android/` with `lapism-search`, `MiguelCatalan-MaterialSearchView`, `yechaoa-MaterialDesign`,
    `android-cjj-MaterialSearchView`, `iammert-MultiSearchView` and `merged` (next step); `android/README.md`.
  - Step 2 written: lapism, iammert and yechaoa (search screen) copied (already Kotlin); MiguelCatalan's library and
    sample translated from Java to Kotlin (AndroidX); android-cjj independently reimplemented
    (`CYLRevealSearchActivity`). Each folder has `TRANSCRIPTION.md` (source commit, license). No Java file is left.
    Not compiled yet: the folders hold sources only; compilation is checked when they join the Gradle project in
    `merged` (step 3).
  - Added by the rule "Open pull requests and issues of projects we translate" (2026-11-12): the translations are
    done, so each upstream's open pull requests are to be translated and merged into its folder, and each upstream's
    open issues listed in a table below (link, description, status `TODO`) and fixed in our code, scored until 100.
  - PRs and issues done: 22 open PRs merged or marked (table below); 166 open issues DONE or N/A with the reason,
    score 100 ([android-upstream-issues.md](android-upstream-issues.md)).
  - Step 3, first part done: `android/merged` is a Gradle project (Gradle 9.3.1, AGP 8.7.3, Kotlin 2.0.21,
    compileSdk / targetSdk 35, minSdk 23).
    - Modules: `search-lapism`, `search-materialsearchview`, `search-multisearchview` (the libraries, built from
      the folders next to `merged`, sources not copied); `sample-materialsearchview`, `sample-multisearchview`,
      `sample-yechaoa`, `sample-reveal` (the samples, unchanged); `cylsearch` (the CYL API, step 4); `app`.
    - CYLTabBarController: not on Maven and Gradle cannot pin a git dependency to a commit, so
      `settings.gradle.kts` checks out `cyl.tabbar.commit` (gradle.properties, from
      `CYLTabBarController/scripts/latest-cyl-commit.sh`) into `.cyl-deps/` and builds its `cyltabbar` and
      `tabpages` modules; `-Pcyl.tabbar.dir=<path>` or `CYL_TABBAR_DIR` uses a local checkout.
    - The app: `CYLTabBarController` with five tabs (lapism, Material, Multi, Reveal, yechaoa). The lapism tab
      hosts lapism's README usage; the others open the upstream sample activities.
    - Compile fixes found by the first build: lapism `dispatchDraw(Canvas)` and iammert's animator listener
      (non-null parameters of SDK 35); iammert's unused synthetic import; MiguelCatalan sample layouts moved to
      AndroidX class names (they still named `android.support.*` and crashed); the app enables data binding
      (iammert #10); the unused jcenter-only EasingInterpolator dependency dropped; samples keep their own theme
      and opt out of Android 15's edge-to-edge (their toolbars were under the status bar).
    - Verified on an Android 15 emulator (API 35, arm64): all nine sample activities and the lapism tab open with
      no crash; MaterialSearchView filters, wraps long suggestions and fills the query on a tap.
  - Steps 4 and 5 done: [android-api-alignment.md](android-api-alignment.md) lists all 294 public iOS
    declarations (types, enum cases, properties, methods, initializers, protocol requirements, UIKit overrides) with
    the upstream API the iOS doc comment cites and the Kotlin counterpart in the `cylsearch` module, which ports the
    seven iOS classes under the same names. Score 100 (261 DONE, 33 N/A), written by
    `android/merged/scripts/api-alignment.py`; 9 Robolectric behavior tests pass.
  - Step 6 done ([`ffac758`](https://github.com/ChenYilong/CYLSearchViewController/commit/ffac758)): the app ports
    the iOS example. CYLTabBarController from `assets/CYLTabBarConfiguration.json` (titles localized from
    `CYLSearchTabs.bundle`, as on iOS), a raised plus button (`CYLPlusButtonCenterYMultiplier` 0.3, 56 dp: its top
    is above the tab bar) for the search bar page, pages from `CYLTabBarPageRegistry`. Tabs: Search (the search
    example: results, pull to refresh, empty state, overlay), Examples (menu: search example, placeholder styles,
    search bar, ports of the five libraries' examples, original samples), plus, List style, Tag style
    ([tag-view-suggestions.md](tag-view-suggestions.md)). The iOS "Repro" button (a UIKit navigation-item setting
    of Issue #1317) has no Android counterpart. README has an Android section.
  - Verified on the emulator: all five tabs, every menu page, the five ports (MaterialSearchView's six samples)
    and the nine original samples open with no crash; reveal, yechaoa and MultiSearchView were exercised.
  - Screenshots (originals), top to bottom: search tab, examples menu, search bar page, placeholder styles,
    reveal port open, yechaoa port after a search, MultiSearchView port with two searches.

    ![Search tab](assets/android-example-search.png)

    ![Examples menu](assets/android-example-menu.png)

    ![Search bar page](assets/android-example-search-bar.png)

    ![Placeholder styles](assets/android-example-placeholders.png)

    ![Reveal port](assets/android-port-reveal.png)

    ![yechaoa port](assets/android-port-yechaoa.png)

    ![MultiSearchView port](assets/android-port-multisearch.png)

| Field | Value |
|:---|:---|
| Platform | Android (Kotlin, `android/merged`) |
| Host | macOS 27.3 (26C5035r), JDK 17.0.21, Gradle 9.3.1, AGP 8.7.3, Kotlin 2.0.21 |
| Emulator | `CYL_API35_arm64`, Android 15 (API 35), arm64-v8a, 1080 × 2400 |
| SDK | compileSdk / targetSdk 35, minSdk 23 |
| Repository | [`ffac758`](https://github.com/ChenYilong/CYLSearchViewController/commit/ffac758) on `feat/swift-core`; CYLTabBarController `f410fa7`, CollectionViewClassifyMenu `eb3590e` |
| Taken | 2026-11-12 21:30–21:40 NZDT |

## Open pull requests of the translated projects

Read 2026-11-12 (`AGENTS.md`, "Open pull requests and issues of projects we translate"). lapism/search,
yechaoa/MaterialDesign and android-cjj/MaterialSearchView have no open pull requests. The translations were already
done, so each pull request's changes were translated to Kotlin and merged into the project's folder in `android/`.

| Pull request | Status | What was merged |
|:---|:---|:---|
| [MiguelCatalan/MaterialSearchView#245](https://github.com/MiguelCatalan/MaterialSearchView/pull/245) | Merged (equivalent) | The translation already uses AndroidX. |
| [MiguelCatalan/MaterialSearchView#228](https://github.com/MiguelCatalan/MaterialSearchView/pull/228) | Merged (equivalent) | The translation already uses AndroidX. |
| [MiguelCatalan/MaterialSearchView#220](https://github.com/MiguelCatalan/MaterialSearchView/pull/220) | Merged (adapted) | White suggestion text became `setSuggestionTextColor(color)` / `SearchAdapter.textColor` instead of a hard-coded color. |
| [MiguelCatalan/MaterialSearchView#209](https://github.com/MiguelCatalan/MaterialSearchView/pull/209) | Merged | `useAdapter`: the search layout stays hidden when suggestions are set before the search opens. |
| [MiguelCatalan/MaterialSearchView#200](https://github.com/MiguelCatalan/MaterialSearchView/pull/200) | N/A | README wording only; our `TRANSCRIPTION.md` links the upstream README. |
| [MiguelCatalan/MaterialSearchView#176](https://github.com/MiguelCatalan/MaterialSearchView/pull/176) | Merged | `setSuggestions(suggestions, checkSuggestion)`, `SearchAdapter(…, checkWholeString)`. |
| [MiguelCatalan/MaterialSearchView#159](https://github.com/MiguelCatalan/MaterialSearchView/pull/159) | Merged | `isVoiceAvailable()` returns true when a speech recognizer exists. |
| [MiguelCatalan/MaterialSearchView#153](https://github.com/MiguelCatalan/MaterialSearchView/pull/153) | Merged (adapted) | `SuggestionItem`, `setSuggestions(Array<SuggestionItem>)`, `setSuggestions(suggestions, iconRes)`; `getItem()` still returns the text and `getSuggestionItem()` the item, and `setSuggestionIcon` is kept, so existing callers compile. |
| [MiguelCatalan/MaterialSearchView#146](https://github.com/MiguelCatalan/MaterialSearchView/pull/146) | Merged | Same fix as #159. |
| [MiguelCatalan/MaterialSearchView#130](https://github.com/MiguelCatalan/MaterialSearchView/pull/130) | Merged | `getQuery()`. |
| [MiguelCatalan/MaterialSearchView#127](https://github.com/MiguelCatalan/MaterialSearchView/pull/127) | Merged (via #176) | "Contains" matching is `checkWholeString = true`; the default stays "starts with" so existing behavior does not change. |
| [MiguelCatalan/MaterialSearchView#117](https://github.com/MiguelCatalan/MaterialSearchView/pull/117) | Merged (equivalent) | `setInputType` and the `android:inputType` attribute were already on master and are in the translation. |
| [MiguelCatalan/MaterialSearchView#114](https://github.com/MiguelCatalan/MaterialSearchView/pull/114) | Merged (partly) | `setSuggestionsWithDefault`, `SearchAdapter.setDefaultSuggestions` / `setSearchCovered`. Not merged: its "cover" behavior that makes Back and the tint keep the search open, which would change the existing close behavior. |
| [MiguelCatalan/MaterialSearchView#106](https://github.com/MiguelCatalan/MaterialSearchView/pull/106) | Merged (adapted) | `closeSearch(animate)` and `AnimationUtil.disappear`; `closeSearch()` keeps closing at once, as before. |
| [MiguelCatalan/MaterialSearchView#105](https://github.com/MiguelCatalan/MaterialSearchView/pull/105) | Merged | Same fix as #159. |
| [MiguelCatalan/MaterialSearchView#97](https://github.com/MiguelCatalan/MaterialSearchView/pull/97) | N/A | README wording only. |
| [MiguelCatalan/MaterialSearchView#92](https://github.com/MiguelCatalan/MaterialSearchView/pull/92) | N/A | No changes in the pull request. |
| [MiguelCatalan/MaterialSearchView#81](https://github.com/MiguelCatalan/MaterialSearchView/pull/81) | Merged | `SearchViewListener.onSearchViewAboutToShow()` / `onSearchViewAboutToClose()`, default methods so existing listeners compile. |
| [MiguelCatalan/MaterialSearchView#66](https://github.com/MiguelCatalan/MaterialSearchView/pull/66) | Merged | Same fix as #159. |
| [iammert/MultiSearchView#17](https://github.com/iammert/MultiSearchView/pull/17) | Merged | `selectedTabStyle` (line or dot), the `selectedTabStyle` attribute and `viewIndicator2`. |
| [iammert/MultiSearchView#16](https://github.com/iammert/MultiSearchView/pull/16) | Merged | `setSearchIconDrawable`, `setSearchIconColor`, the `searchIcon` and `searchIconColor` attributes. |
| [iammert/MultiSearchView#15](https://github.com/iammert/MultiSearchView/pull/15) | Merged | `MultiSearchContainerView` uses the binding fields (`it.editTextSearch`) instead of `root.<synthetic id>`, which master still had without the synthetic import; the Gradle and Kotlin versions are set by `android/merged`. |

All 22 open pull requests are handled (19 merged, fully or adapted to keep the existing API; 3 change no code).
Open issues: `docs/android-upstream-issues.md`.
