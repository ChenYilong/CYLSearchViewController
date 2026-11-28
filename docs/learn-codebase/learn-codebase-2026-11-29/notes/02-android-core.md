> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# Android core: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

12/12 chunks read (android/merged/cylsearch Kotlin). BarView 3915 lines (bar+item+TagButton-based item view+trailing group hit slop, focusesOnAppear via lifecycle observer+fragment back stack, outside-touch via Window.Callback wrapper, embedInToolbar+backButtonProgress+predictive back), SearchView (ConcatAdapter-free RecyclerViews, CYLRefresh container, history signal), SearchListView (replaces CYLSearchController/TableVC role), HeaderSnapper, NavigationBar+presets, Resources+store, ResultsComponent, TagList style/header. Findings (code-read only, not run): SearchButtonStyle.Text KDoc says default but Icon is; two stacked KDoc blocks before keyboardOverlapHandler orphan the pinToKeyboard doc; default contentInsets (12,6,12,6) vs iOS (6,16,6,16); default search button with whitespace-only text calls delegate (isNullOrBlank) whereas iOS calls submit() which returns false and tells nobody; CYLSearchTagListStyle.isNight uses uiMode only while CYLSearchBarView.isNight uses theme background luminance (could mismatch on fixed-light theme in system dark); noResultsText rebuilds placeholder (and calls willShowEmptyView) on every refilter; next=03-harmony-core

## Files read (13)

- `android/merged/cylsearch/build.gradle.kts` (109)
- `android/merged/cylsearch/src/main/AndroidManifest.xml` (4)
- `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLOutsideTouchWindowCallback.kt` (22)
- `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchBarAppearance.kt` (179)
- `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchBarView.kt` (3915)
- `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchHeaderSnapper.kt` (114)
- `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchListView.kt` (338)
- `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchNavigationBar.kt` (84)
- `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchResources.kt` (296)
- `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchResultsComponent.kt` (122)
- `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchTagListHeader.kt` (50)
- `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchTagListStyle.kt` (201)
- `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchView.kt` (1991)

Declarations with line numbers: [../reference/02-android-core.md](../reference/02-android-core.md)
