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

## TODO (2026-11-12): android/ folder: five Kotlin transcriptions, a merged library and example

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
  - Next: step 3, `android/merged` (Gradle, CYLTabBarController at a pinned commit, one example tab per project).
  - Added by the rule "Open pull requests and issues of projects we translate" (2026-11-12): the translations are
    done, so each upstream's open pull requests are to be translated and merged into its folder, and each upstream's
    open issues listed in a table below (link, description, status `TODO`) and fixed in our code, scored until 100.

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
| [iammert/MultiSearchView#15](https://github.com/iammert/MultiSearchView/pull/15) | Merged (equivalent) | Its code change (no `kotlinx.android.synthetic`) is already on master, which uses data binding; the Gradle and Kotlin versions are set by `android/merged`. |

All 22 open pull requests are handled (19 merged, fully or adapted to keep the existing API; 3 change no code).
Open issues: `docs/android-upstream-issues.md`.
