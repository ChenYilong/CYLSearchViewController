> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# Earlier learn-codebase pass (2026-11-27): saved notes, verbatim

From work list `learn-codebase`. **Older record**, against an earlier tree. Some items were corrected later: see [../02-findings.md](../02-findings.md).

## ios-core Sources/CYLSearchBar (done)

CYLSearchBarView (single/multiple mode, items as CYLTagButton, default icon search button, iconified, presets/applyNavigationFieldStyle, focusesOnAppear+dismissesKeyboardOnOutsideTouch via CYLDeallocBlockExecutor), CYLSearchView (page: suggestions tags/list, cache SQLite/defaults/file, results DS, placeholders, refresh API), CYLSearchController (QMUI-shaped, own page over host, no UISearchController), CYLSearchTableViewController, HeaderSnapper, NavigationBar, TagListStyle.

## harmonyos core harmonyos/cylsearch (done)

ArkUI V2 models (@ObservedV2) + components mirror iOS names. Pure-logic blocks tested by harmonyos/scripts/host-logic-test.mjs. Diffs: CYLSearchController wraps CYLSearchView; pageDepth 1=first level (iOS 0); nav bar 56vp; uncommitted diff adds dismissesKeyboardOnOutsideTouch (uiObserver willClick/scrollEvent), performFirstLevelTap, automaticCornerRadius.

## remaining: instructions.md files; android/merged; miniprogram; flutter; RN; harmonyos/entry; CYLSearchExample; tests; scripts+workflows; android upstream ports (done)

stale entry; covered by the 2026-11-27 completion. 2026-11-29: read delta 79db668/ad32984 in full; remote at 79db668

## android core android/merged/cylsearch main (done)

Kotlin Views: CYLSearchBarView (FrameLayout; outside-touch via Window.Callback wrapper; embedInToolbar + back button progress/predictive back; pageDepth null=fragment backstack; isNight via theme luminance), CYLSearchView (page over host, RecyclerView suggestions/results, CYLRefreshLayout, launchView, system-bar options merged from CYLSearchController), CYLSearchListView (=iOS SearchTableViewController), HistorySignal by policy|name. Nit: CYLSearchBarSearchButtonStyle.Text doc says 'The default' but default is Icon.

## android core tests cylsearch/src/test (done)

Robolectric sdk34 tests mirror iOS test names: default colors, editing bar, embedInToolbar, first-level back button, focusesOnAppear, items, multiple-mode back, nav field preset, QMUI ports, search button, trailing group hit slop, behavior, controller alignment, fold control, list view, merge phase 5/5b, suggestion cache, tag style, empty search button. Next: android/merged app (4241 lines).

## android/merged app + build (done)

settings.gradle.kts clones pinned commits (gradle.properties cyl.tabbar/classifymenu/placeholder.commit) into .cyl-deps. App: MainActivity CYLTabBarController from assets json; tabs search/examples/plus/listStyle/tagStyle/discover; CYLExamplePage = toolbar + first-level bar (cylTabSearchBar styles discover/search/examples/list/tag) pushing CYLSearchDiscoverFragment; gradient backdrop plate sibling for Liquid Glass; contacttags demo (store/server/pages). Finding: CYLContactTagServer.kt has a UTF-8 BOM and mojibake ellipses in KDoc ('Uploading鈥?').

## miniprogram src/core (done)

Plain-JS models ported from HarmonyOS models ($r shim, animateTo shim). Parity diffs: CYLSearchBarView.submit() rejects only empty, not blank text (iOS trims); completeSearch trims; addSearch reports didComplete; removeSearch selection picks previous not next; default store slice(0,max(0,maximumCount)) vs max(1). History store 'database' = wx storage key. Next: src/cyl-* components, tests, example.

## miniprogram src/cyl-* components (done)

cyl-search-bar (Component over CYLSearchBarView model, tag buttons from cyl-tag-list-miniprogram, generics for animation engines), cyl-search (overlay/inline/list-screen modes, page-container for back, content scroller holds scroll during reorder/smear events), cyl-search-navigation-bar (menu-button aware, first-level push), cyl-search-refresh-button. Next: miniprogram test/, example/, scripts/.

## learn-codebase (done)

stale entry; covered by the 2026-11-27 completion. 2026-11-29: read delta 79db668/ad32984 in full; remote at 79db668

## remaining (done)

(no note)

## 2026-11-29 follow-up: instruction files + delta (done)

Corrects the note on the two stale entries: the 2026-11-27 record does not list instruction files. Read on 2026-11-29: CLAUDE.md, AGENTS.md, instructions.md (differs from AGENTS.md only in title/intro, via diff), all 18 docs/instructions/*.md, all 19 cyl-*/SKILL.md, diffs of 79db668 and ad32984. Not read: third-party swift-* and uikit* skills. Source coverage rests on the 2026-11-27 record, not re-read. Open: Flutter iOS reads searchButtonImage but Dart never sends it; doc comment of cylFoldControl now sits above cylFlutterAssetImage.
