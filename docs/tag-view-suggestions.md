# Tag View Suggestions (CollectionViewClassifyMenu)

Suggestions under the search bar shown as a list (table view) or as tags (collection view, from
CollectionViewClassifyMenu).

## TODO (2026-11-12): CollectionViewClassifyMenu as a dependency and a tag-view suggestion style

- Context: CollectionViewClassifyMenu is a sibling project in the same vault folder
  (`../CollectionViewClassifyMenu`) with a podspec at its root. `CYLSearchView` lists suggestions in
  `suggestionsTableView` today.
- Requirements:
  1. iOS: make CollectionViewClassifyMenu a sub-dependency of this pod through its root podspec; depend on its
     newest commit (which may not be on its main branch), or on the local path while developing, but commit only the
     commit-based dependency.
  2. Add support in the core with an enum or a parameter that chooses how suggestions appear under the search bar:
     a table view or a collection view (tags). Change the core first; add an interface to CollectionViewClassifyMenu
     only when needed, commit it there, then update this repository's commit dependency.
  3. Show the styles in the example: an empty tab item named "tagview style" shows the existing examples' suggestions
     with different parameters in the new style.
- Prompt (verbatim): "在iOS端 将CollectionViewClassifyMenu 也就是本项目在本地 本机环境的同一个文件夹目录下的项目，文件夹就叫CollectionViewClassifyMenu 通过根目录的.spec 文件制作成本仓库的子依赖库。你可以通过查找CollectionViewClassifyMen的最新commit地址进行依赖，最新commit可能不在main分支。也可以通过本地路径依赖，选择一个方便你开发的方式集成，但commit前要移除本地依赖形式，采用commit依赖。为iOS端加入CollectionViewClassifyMen 支持，采用枚举形式，或者参数形式，指定 效果，效果类似搜索框下端具体是tableview还是collectionview。优先采用修改core核心代码的方式实现，如有必要也可以前往CollectionViewClassifyMen新增接口，帮CollectionViewClassifyMen提交后更新本仓库commit依赖继续开发。在本项目example中展示以上提到的不同样式。将现在已有的example展示，寻找一个空的tabbaritem项，命名为tagview样式，展示现有样式的不同参数设置后的新搜索备选项展示形式。"
- Prompt (English): "On iOS, make CollectionViewClassifyMenu (the project in the same local folder, named
  CollectionViewClassifyMenu) a sub-dependency of this repository through its root .spec file. Depend on its newest
  commit (maybe not on main) or on the local path, whichever is convenient while developing, but remove the local
  form before committing and use the commit form. Add CollectionViewClassifyMenu support on iOS with an enum or a
  parameter that chooses the effect, i.e. whether the area under the search bar is a table view or a collection
  view. Prefer changing the core; if needed, add interfaces to CollectionViewClassifyMenu, commit there, then update
  this repository's commit dependency and continue. Show the styles in the example: find an empty tab item, name it
  tagview style, and show the existing examples' new suggestion presentation with different parameters."
- Status: logged; order: after the Android task and the plus button rule.

## DONE (2026-11-12): Android: the suggestion demo in two tabs, list style and tag style

- Context: `android/merged` (see [android-and-cross-platform.md](android-and-cross-platform.md)) runs the
  MaterialSearchView sample from its "Material" tab. Its suggestions are a list under the search bar (screenshot).
  CollectionViewClassifyMenu has an Android port (`../CollectionViewClassifyMenu/android/merged`, modules `library`
  and `example`) whose tag views give the tag style. This is the Android side of the iOS TODO above.
- Requirements:
  1. Copy the suggestion demo. Show it in two of CYLTabBarController's tab items in `android/merged/app`.
  2. Tab "list style": the current list of suggestions (MaterialSearchView, unchanged).
  3. Tab "tag style": the same suggestions shown as tags with CollectionViewClassifyMenu's Android library. Depend on
     it by its newest commit, like CYLTabBarController (local path only while developing).
  4. Prefer a style option in the library (`cylsearch` / MaterialSearchView) over code in the example; the example
     passes only data, style parameters and click handling.
  5. Screenshots of both tabs in this document, labeled per AGENTS.md, then mark this TODO DONE.
- Screenshot of the current list style (the demo to copy). Android 15 emulator `CYL_API35_arm64` (API 35, arm64),
  host macOS 27.3 (26C5035r), compileSdk 35, CYLSearchViewController commit `d459b91`, 2026-11-12 18:19 NZDT.
  Left: typing "a" lists the suggestions; right: tapping "Android" fills the query.

  ![MaterialSearchView suggestions in android/merged](assets/android-merged-materialsearchview-suggestions.png)

  Full-size original of the left state: [android-merged-suggestions-list-original.png](assets/android-merged-suggestions-list-original.png).
- Prompt (verbatim): "该演示，复制一份，使用cyltabbarcontroller不同items管理，演示搜索备选项内容，一个item使用现在的样式，一个item 使用使用新的新的collectionview 也就是tagview 也就是 CollectionViewClassifyMenu提供的样式展示。写入文档中 标注todo附带截图。continue"
- Prompt (English): "Copy this demo and manage it with different CYLTabBarController items to show the search
  suggestions: one item uses the current style, the other the new collection view, i.e. the tag view, the style
  CollectionViewClassifyMenu provides. Write it into the docs marked TODO with screenshots. Continue."
- Status: DONE (2026-11-12, [`ffac758`](https://github.com/ChenYilong/CYLSearchViewController/commit/ffac758)).
  - Library, not example: `CYLSearchView.suggestionStyle` (`CYLSearchSuggestionStyle.List` / `Tags`) in
    `cylsearch`; `Tags` shows the filtered suggestions in `suggestionsTagView`, CollectionViewClassifyMenu's
    `CYLTagListView`, and a tapped tag works like a tapped row (fills the query, `searchViewDidSelectSuggestion`,
    submits when `submitsOnSuggestionSelection`).
  - Dependency: CollectionViewClassifyMenu's Android library at its newest commit `eb3590e` (branch
    `feat/android-kotlin`), checked out by `android/merged/settings.gradle.kts` (`cyl.classifymenu.commit`), like
    CYLTabBarController; `-Pcyl.classifymenu.dir` only for local development.
  - Example: the "List style" and "Tag style" tabs of the app (`CYLSuggestionStyleFragment`) pass only the
    suggestions and the style; the toolbar's search action opens the search.
  - Verified on the emulator: typing "a" lists 14 suggestions in both styles; tapping the "Android" tag sets the
    query to "Android"; no crash.
  - Screenshots (originals), from top to bottom: list style, tag style, tag style after tapping "Android".

    ![List style](assets/android-suggestions-list-style.png)

    ![Tag style](assets/android-suggestions-tag-style.png)

    ![Tag tapped](assets/android-suggestions-tag-picked.png)

| Field | Value |
|:---|:---|
| Platform | Android (Kotlin, `android/merged`) |
| Host | macOS 27.3 (26C5035r), JDK 17.0.21, Gradle 9.3.1, AGP 8.7.3, Kotlin 2.0.21 |
| Emulator | `CYL_API35_arm64`, Android 15 (API 35), arm64-v8a, 1080 × 2400 |
| SDK | compileSdk / targetSdk 35, minSdk 23 |
| Repository | [`ffac758`](https://github.com/ChenYilong/CYLSearchViewController/commit/ffac758) on `feat/swift-core`; CYLTabBarController `f410fa7`, CollectionViewClassifyMenu `eb3590e` |
| Taken | 2026-11-12 21:30–21:40 NZDT |
  - The iOS side is the TODO above (still open, in order).
