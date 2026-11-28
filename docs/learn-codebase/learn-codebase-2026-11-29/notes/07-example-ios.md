> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# iOS example: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

9/9 chunks read. Code-read findings: Edit Remarks Done has target nil/action nil (enabled in updateTags, does nothing) - same inert Done on Android and HarmonyOS; AppDelegate first-level placeholders "Search examples"/"Search"/"Search tags" and CYLSearchSecondLevelViewController recent/popular tags hard-coded English (also CYLRevealSearchViewController placeholder "search", port of sample). iOS "+ New Tag" uses UIAlertController text field (works). Menu comments mention a removed .m file only in CYLSVGADemoTagButton header (CYLSearchDemoMenuViewController.m). next=08-example-flutter

## Files read (30)

- `CYLSearchExample/CYLContactListViewController.swift` (95)
- `CYLSearchExample/CYLContactRemarkViewController.swift` (236)
- `CYLSearchExample/CYLContactTagEditorViewController.swift` (909)
- `CYLSearchExample/CYLContactTagServer.swift` (125)
- `CYLSearchExample/CYLContactTagStore.swift` (400)
- `CYLSearchExample/CYLKenBurnsView.swift` (73)
- `CYLSearchExample/CYLLapismSearchViewController.swift` (105)
- `CYLSearchExample/CYLMaterialSearchMenuViewController.swift` (317)
- `CYLSearchExample/CYLMultiSearchDemoViewController.swift` (74)
- `CYLSearchExample/CYLOriginalSearchDemoViewController.swift` (192)
- `CYLSearchExample/CYLRevealSearchViewController.swift` (54)
- `CYLSearchExample/CYLSearchBarDemoViewController.swift` (80)
- `CYLSearchExample/CYLSearchBarInViewDemoViewController.swift` (95)
- `CYLSearchExample/CYLSearchBarStylesViewController.swift` (159)
- `CYLSearchExample/CYLSearchCollectionViewDemoViewController.swift` (159)
- `CYLSearchExample/CYLSearchControllerDemoViewController.swift` (98)
- `CYLSearchExample/CYLSearchDemoMenuViewController.swift` (492)
- `CYLSearchExample/CYLSearchDiscoverData.swift` (121)
- `CYLSearchExample/CYLSearchDiscoverViewController.swift` (642)
- `CYLSearchExample/CYLSearchExampleAppDelegate.swift` (140)
- `CYLSearchExample/CYLSearchExampleSceneDelegate.swift` (27)
- `CYLSearchExample/CYLSearchExampleViewController.swift` (240)
- `CYLSearchExample/CYLSearchNavigationItemDemoViewController.swift` (74)
- `CYLSearchExample/CYLSearchPortsViewController.swift` (83)
- `CYLSearchExample/CYLSearchShortListDemoViewController.swift` (55)
- `CYLSearchExample/CYLSuggestionDemoPages.swift` (31)
- `CYLSearchExample/CYLSVGADemoTagButton.swift` (50)
- `CYLSearchExample/CYLSVGASwiftUIDemo.swift` (56)
- `CYLSearchExample/CYLTabBarConfiguration.json` (31)
- `CYLSearchExample/CYLYechaoaSearchViewController.swift` (68)

Declarations with line numbers: [../reference/07-example-ios.md](../reference/07-example-ios.md)
