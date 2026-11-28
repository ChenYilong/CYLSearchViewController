> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# HarmonyOS core: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

11/11 chunks read (harmonyos/cylsearch; CYLSearchBarView.ets read as modified working copy). Pure-logic blocks are Node-tested by host-logic-test.mjs. Model classes (@ObservedV2) + @ComponentV2 drawers; QMUI-shaped fronts CYLSearchBar/Controller/TableViewController/NavigationBar; database history mirrored in memory with serialized queue. Findings (code read + git grep, not run): alwaysShowsSearchResultsController is only stored in CYLSearchController.ets and never affects CYLSearchView.showsResults (iOS/Android use it); searchButtonHandler runs AFTER submit/delegate, iOS+Android (and the alignment doc row) call it INSTEAD; applyBackgroundStyle sets only style flags, no clear glass fills/list background unlike iOS+Android; next=04-mp-src

## Files read (13)

- `harmonyos/cylsearch/build-profile.json5` (13)
- `harmonyos/cylsearch/hvigorfile.ts` (6)
- `harmonyos/cylsearch/Index.ets` (57)
- `harmonyos/cylsearch/oh-package.json5` (12)
- `harmonyos/cylsearch/src/main/ets/CYLSearchBar.ets` (241)
- `harmonyos/cylsearch/src/main/ets/CYLSearchBarView.ets` (3485)
- `harmonyos/cylsearch/src/main/ets/CYLSearchController.ets` (655)
- `harmonyos/cylsearch/src/main/ets/CYLSearchNavigationBar.ets` (126)
- `harmonyos/cylsearch/src/main/ets/CYLSearchResources.ets` (513)
- `harmonyos/cylsearch/src/main/ets/CYLSearchTableViewController.ets` (177)
- `harmonyos/cylsearch/src/main/ets/CYLSearchTagListStyle.ets` (242)
- `harmonyos/cylsearch/src/main/ets/CYLSearchView.ets` (2236)
- `harmonyos/cylsearch/src/main/module.json5` (7)

Declarations with line numbers: [../reference/03-harmony-core.md](../reference/03-harmony-core.md)
