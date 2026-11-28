> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Written by a subagent: its claims and contradictions were NOT re-checked (only items marked S in 02-findings.md were). What the source documents report as done or passing is their claim.

<!-- B-search-core-design: part 2 of 2 -->
_Part 2 of 2. Previous: [part 1](B-search-core-design.md)._

### 5.11 iOS merge phases (all 2026-11-22; claimed test counts)
- Phase 0 (QMUI:916-966): tests+screenshots only; 140/0 on three iOS versions.
- Phase 1 (bd57b21, d23149d, 7f61f55; 152/151/152 tests, one-test count difference unexplained): shared helper in CYLSearchBarAppearance (resolvedField, cornerRadius, margins, textWidth, centeringOffset, image generators); CYLSearchBarView gained appearanceStyle (opt-in, nil), applyDefaultAppearance, centersPlaceholder, textFieldMarginsProvider (typealias CYLSearchBarViewMarginsProvider; active = first responder; intrinsic height uses contentInsets), cancelButtonMarginsProvider, cancelButtonFont, setShowsCancelButton(animated), showsLeadingView/setShowsLeadingView, showsTrailingAccessoryViews/setter (animate flag+frame/alpha since layout resets transforms). CYLSearchBar kept B-fixes (815->790 lines). Not mapped: searchBarStyle type clash, clearIconImage, barBackgroundImage, barBorderColor, accessory margins.
- Phase 2 (26a1313, 3705a5a; 158): CYLSearchView not hosted by the controller because it is final and owns a second bar, keyboard observers, closesOnSubmit and its own overlay; instead the internal CYLSearchSuggestionArea (tag list folded to 2 rows, fold control last, iOS 26 topEdgeEffect fix, history header + clear, tag taps, store mode: history newest first else suggestions, header only over history) used by both. New CYLSearchController.showsSuggestionsLaunchView (default false) and suggestions. Tag tap sets text, records submit, dismisses keyboard. History signal posted by the built-in store (policy+name match; custom stores by identity). Example's CYLRecentSearchLaunchView deleted; default square tag look replaces tinted 29 pt tags on purpose.
- Phase 3 (e81f377, 54338a5; 176; score 92): internal CYLSearchResultsComponent.swift (CYLSearchEmptyView factory -> CYLPlaceholderStackView, CYLSearchEmptyViewSlot, CYLSearchKeyboardOverlap, CYLSearchResultHighlight, CYLSearchResultsDataSourceProxy forwarding everything but decorating cellForRowAt) and CYLSearchPresentationState.swift (CYLSearchDimmingView, state+events with send(_:) and generation count, CYLSearchEdgeSwipe). CYLSearchSuggestionArea.resolve(cache:suggestions:query:showsForEmptyQuery:filter:) is the one history-else-suggestions decision. Decisions: table instances NOT shared among the three screens; highlight = case+diacritic insensitive, first match, tint color unless resultMatchHighlightColor; remember label textColor so reused rows do not leak highlight; controller state mirrors UIKit (isActive = UIKit's); CYLSearchView drives its own; generation guard so show-during-close does not end hidden. New: highlightsResultMatches, resultMatchHighlightColor, CYLSearchView.isActive/setActive/supportsSwipeToDismissSearch (false), delegate searchViewWillShow:/WillClose:.
- Phase 4 (df5f0da swipe, 6c1d161 options, 815bb9b examples; 181; iOS merge score 88): new core options CYLSearchView.suggestionCacheFooterTitle, resultsHeaderTitleProvider, resultsHeaderTextColor, CYLSearchController.noResultsText (shows empty view when text non-empty and table has no row). Issue screens stay on UIKit adapter (they test UISearchController behavior). Swipe by real touch had NEVER worked (also on pre-merge 6014474): UIScreenEdgePanGestureRecognizer received touch but never left .possible under an active UISearchController; fixed by internal CYLSearchEdgePanGestureRecognizer subclass (touch down <= 24 pt from window left edge, rightward > 10 pt slop, more horizontal than vertical, smoothed velocity) + navigation interactivePop (and iOS 26 interactiveContentPop) required to fail via gestureRecognizer(_:shouldBeRequiredToFailBy:). Not mirrored for RTL. Run the three suites sequentially (parallel builds broke the shared Pods copy step once).

### 5.12 Merge phase 5 (other platforms, 2026-11-22): one implementation with iOS names
Common merges: accessories -> leadingView / trailingAccessoryViews (+shows flags, animated setters), trailing now INSIDE the field on Android/HarmonyOS/mini program (behavior change); dimmingColor -> scrimColor (one overlay, tap ends search); launch view -> core suggestion area on CYLTagListView, tapped tag submits; one empty view, noResultsText; highlight case+diacritic insensitive in core; one history signal; generation/present counter against stale close events.
- Android (QMUI:1388-1442; 91/100; 66 core + 9 app tests): CYLSearchEmptyViewSlot, CYLSearchHistorySignal, one fold function; dimmingColor now dims whole search; fixed core bug: tapped suggestion did not notify the bar delegate. CYLSearchView doubles as controller (no showsSuggestionsLaunchView). Manifest android:enableOnBackInvokedCallback="true".
- HarmonyOS (QMUI:1224-1300; 90/100; 55 hypium, 39 host; code e4a32f1): native Flex tag wrap replaced by CYLTagListState; cylsearch's CYLMenuFoldControl enums now deprecated adapters (inline=tail, bottom=footer); core observeHistory/announceHistoryChange (weak listeners); QMUI names deprecated. CYLSearchUI hang cause: startAbility never returns with display off/lock screen; fix wakes display + swipes in beforeAll; also run aa test with -s timeout 60000 (default 5000 ms causes cascading "uitest-api dose not allow calling concurrently"). Swipe only reachable between system edge zone (~40 px) and 24 vp (~66 px). Data source of demo stays case-sensitive like iOS ("Heal" matches, "heal" not).
- Mini program (QMUI:1311-1386; 85/90 without device 10 pts; 95 tests: 94 pass 1 skip): cyl-tag-list replaces flex-wrap chips; showsSuggestionsLaunchView wins over slot showsLaunchView; cylFold (per-char with offset map), cylEdgeSwipeBegins; accessory old props win over new if set; didpresent/diddismiss timer based. No DevTools run, no screenshots.
- React Native (QMUI:1443-1525; 87/100; 15 jest): JS deprecated forwards (cylListForwards, cylBarForwards in src/CYLSearchProps.ts): dimmingColor->scrimColor, emptyViewText->noResultsText, launchSuggestions->suggestions, historyPolicy/Name->suggestionCachePolicy/Name, accessories, appearance->appearanceStyle; removed launchTitle/launchLabel/clearHistoryLabel; CylsearchListView.mm now hosts core CYLSearchView; aliases onWillShow.. besides onWillPresent..; Podfile.lock churn not committed.
- Flutter (QMUI:1527-1578; 88/100; 36 plugin + 5 example + 6 JVM tests then): accessories and launchViewBuilder stay Dart widgets (platform view cannot host Flutter widget); removed onUpdateResults (use onTextChanged), onDidDismiss (use onClose), unreleased names removed without deprecation (CHANGELOG 0.1.0 unpublished); added setQuery(query, submit).
- Phase 5b (QMUI:1580-1619; 90/100): closed wrapper-reported core gaps and deleted workarounds: iOS CYLSearchView.noResultsText; Android noResultsText no longer stacks placeholders; public CYLSearchResources.historyDidChangeNotification with userInfo policy+name; CYLSearchHeaderSnapper takes any header + isSearching closure via public CYLSearchView.setSnapsHeader(_:for:in:); iOS selectSuggestion calls queryChanged before submit (textDidChange before submit); Android pads only the system-bar part overlapping the view; cancelButtonFontSize; Android tag list refills on width, margins instead of padding; Flutter CYLMatchHighlight deleted (Android core has highlight). Bisect hazard: Flutter Android build broken for commits 49006a2..878126c (pushed, not rewritten). Claims iOS 185/0 on 27.2/26.5/17.5, Android 74+9, RN 15 jest, Flutter 36+5.
- Fold control fix (QMUI:1621-1653): MISDIAGNOSIS closed, no code change. The launch screen has 8 suggestions (not 10; 10 is KEYWORDS); they fit in 2 rows so no fold control is correct; with more than 2 rows the last tag is the fold control. A control on a fitting list would need a new ClassifyMenu CYLTagListView option. Android test CYLSearchFoldControlTest needs Robolectric GraphicsMode.NATIVE (legacy text measure too narrow). :cylsearch 76/0 + app 9/0; mini program 91 pass, 2 skipped, 3 failed (missing generated example/miniprogram/components in fresh worktree).

### 5.13 Operational gotchas recorded in QMUI
- axe describe-ui can hang (pkill that only; never kill axe hid-broker: serves other sessions' simulators) (QMUI:960). Load average ~700-900 from parallel sessions caused test kills and emulator watchdog kills (QMUI:989, 1558).
- Each agent used its own simulator/AVD/ports and shut it down.
- Screenshot rules: originals in docs/assets/raw, stitched by scripts/stitch-screenshots.swift, checked by scripts/check-screenshot-labels.sh; one correction for a wrong sips crop offset (QMUI:1046).

## 6. Platform differences (summary; see 2.8, 5.8, 5.12)
- Android resultsDataSource strong, iOS weak (MERGE:68). iOS NSNotFound vs Android -1.
- Android overlay is an ordinary view: UIKit-defect rows (E1-E3, E5, E20-E23, B5, B7-B12, I1-I3, I5) N/A; E18 not ported (QMUI:540-544).
- Wrappers: closures become prop pairs; Flutter accessories/launchViewBuilder are Dart; RN accessories only a 30x30 square spec.
- The cross-platform "no system search bar" rule: NSS:3-4 applies to all platforms; only iOS needed removal of a system-bar port.

## 7. Contradictions and superseded statements

### Between documents
1. MERGE:160-162 removes CYLSearchController (11-17); QMUI/CMP:340/SBV:275-280 reintroduce the name as a UISearchController wrapper (11-22); NSS re-backs it without UIKit search (11-26). Same name, three meanings.
2. CMP:338-344 and SBV:275-280 tell users to use CYLSearchBar (UISearchBar subclass) and say CYLSearchBarView "did not change". Superseded by NSS:18,36 (removed). SBV and CMP were not updated. CYLSearchBarView also did change later the same day (QMUI:982), contradicting SBV:280 and QMUI:286 ("unchanged since 2ecf2ef", true only before the merge phases).
3. QMUI:108-109, 808-816 (keep CYLSearchBar as adapter; "dropping it would drop navigation-item search and #1229/#1319/#1251/#1313 fixes") vs NSS:3-4, 36-38 (removed). QMUI contains no note of this; NSS:48 lists marking rows E1-E22 as a work item and no such marks appear in QMUI.
4. MERGE:152-165 "3 files, 4 public classes" is historical: today Sources/CYLSearchBar has 13 .swift files (checked by Glob 2026-11-29: ResultsComponent, Resources, SuggestionArea, TagListHeader, TagListStyle, BarAppearance, HeaderSnapper, PresentationState, TableViewController, SearchView, SearchBarView, NavigationBar, SearchController).
5. MERGE:210 says navigation-item search is plain UIKit in the example; NSS forbids system search bars everywhere.
6. MERGE:245-247 pin f488e2f for PlaceHolder "every platform pins"; later pins e984868 / c84fce9 (MERGE:104-131), c473fdc on Android screenshots (QMUI:560), f4cf978 (QMUI:446).
7. SBV:101 (11-14) names CYLSearchResultsViewController (removed 11-17) and cylKeepViewBelowNavigationBar(); a Grep of Sources for KeepViewBelow/BelowNavigationBar found nothing (checked).
8. SBV:81 "no compatibility promise yet" vs QMUI:841-846 "old public API keeps compiling" + API fence; and NSS:18 makes a deliberate breaking change.

### Inside NSS
9. NSS:8-12 and NSS:20,22 (facade over CYLSearchView) vs NSS:31-33 (controller does NOT sit on CYLSearchView).
10. NSS:23 lists searchResultsController, alwaysShowsSearchResultsController, searchBarMaxY as removed; NSS:34-35 says kept. Code check: CYLSearchController.swift:99 `public let searchResultsController`, :193 alwaysShowsSearchResultsController, :215 searchBarMaxY exist (NSS status is right). supportsSwipeToDismissSearch at :203.
11. NSS:29 "steps 1 to 7 are done" vs NSS:43-46 items 1-4/5 still marked TODO (stale list; docs/task-log.md:1904 has "DONE (2026-11-26): iOS has no system search bar left").
12. NSS:19 says textFieldMargins, leading/trailingAccessoryView etc. are kept as same-named CYLSearchBarView members. Code check: Grep of Sources for `leadingAccessoryView|trailingAccessoryView\b|textFieldMargins\b` found NOTHING; CYLSearchBarView has leadingView (CYLSearchBarView.swift:890) and a margins provider instead (see QMUI:982-987). Treat NSS:19 names as unreliable.
Code check that agrees with NSS: Grep for UISearchBar|UISearchController|UISearchTextField returned no hit in Sources, CYLSearchExample, or CrossPlatform/**/ios (same path/glob searches for the token CYLSearch did return files in CYLSearchExample and the CrossPlatform ios folders, so the empty result is not an empty search scope; Pods/vendor coverage was not checked separately). CYLSearchController is declared `UIViewController, CYLSearchBarViewDelegate` (CYLSearchController.swift:83); textAssignedHandler exists (CYLSearchBarView.swift:345, used CYLSearchController.swift:298). No build or test was run.

### Inside SBV
13. SBV:151-153 lists lottieURL among 5 N/A rows, but table SBV:206 maps lottieURL -> animationURL; only 4 table rows are N/A (SBV:174,175,177,202).
14. SBV:150 "0/58" then SBV:151 58/58 (history, not conflict). SBV:250-251 "Open: Flutter/RN device runs and screenshots" vs SBV:255-273 screenshots + DONE.

### Inside MERGE
15. MERGE:115-121 mixes DONE (11-21 pull-to-refresh driven) with "the emulator does not start today" (older note).
16. MERGE:80 mini program placeholder "optional peer dependency" vs MERGE:113/138 required (package.json optional only for npm).

### Inside QMUI
17. QMUI:40 / 398 score 94 vs row QMUI:404 later 15/15 for issues (total not recomputed). QMUI:262-265 old "open" notes superseded by 2026-11-23 fixes.
18. QMUI:241 says E22 providers forwarded; NSS:37-38 removes both providers.
19. QMUI:439-440 and 749 call the E21 iOS 17.5 touch check open; QMUI:938 closes it (never visible).
20. Test counts: "123 each" (QMUI:416, 743), 125 (QMUI:435, 11-22), 188 on 11-23 (QMUI:427), merge phases 140..185. Different branches/dates (fix/ios-todos-qmui, fix/i2-i5-offset vs feat/harmonyos-parity).
21. QMUI:865 "phases 5 and 6 next", QMUI:962-963 "nothing moved yet", QMUI:1212 "phases 5 and 6 remain": superseded by phase 5/5b logs (6 still open).
22. Layout: the Android phase 5 TODO heading (QMUI:1215-1222) has no Status there; its result (QMUI:1388-1442) is placed after the mini program's TODO (Windows) table. Flutter "in progress" (QMUI:1309) superseded by QMUI:1527-1578.
23. Highlight: first Flutter port case-sensitive (QMUI:904, 1093); phase 5 insensitive (QMUI:1325, 1408, 1542). Flutter TODO "Android core has no highlightsResultMatches" (QMUI:1542, 1573) contradicts the Android phase 5 (QMUI:1408) and is closed by 5b (QMUI:1597). Flutter TODOs for iOS noResultsText and internal notification (QMUI:1570-1571) closed by 5b (QMUI:1588-1590). RN TODOs (QMUI:1522-1523) partly closed by 5b; RN iOS hidesSearchBarWhenEmptyViewShowing still ignored (QMUI:1616).
24. Mini program test totals: 84 (QMUI:691), "86/85/0/1 before" (QMUI:1346, no explanation of 84 -> 86), 95 (QMUI:1346), 91 pass/2 skip/3 fail (QMUI:1646).
25. Phase 5b TODO "10 tags, 8 shown, fold control missing" (QMUI:1617) declared a misreading (QMUI:1625-1634).
26. QMUI:1099 controller swipe not working by touch -> fixed QMUI:1159-1166.
27. QMUI:357 "use appearanceStyle" for hand-set background -> fixed 611ada8 (QMUI:251). QMUI:372 "blank page after completed pop" -> corrected QMUI:379.
28. QMUI:101 names the empty view component CYLTableViewPlaceHolder, later HarmonyOS/iOS add a CYLSearchEmptyView factory wrapping it (not a conflict, evolution).

## 8. Open TODOs and unfinished work (as stated by the documents; not verified; items closed later are omitted)

### iOS core and examples (check against NSS removal: several may be moot now)
- NSS:48 mark QMUI rows E1-E22 kept/replaced/dropped. NSS:43-47 list still says TODO (see contradiction 11).
- iOS 15, 16, 18-25 never run (QMUI:415-416, 748); B9 fill below iOS 26 justified by 17.5 only.
- Mini program twin of the new iOS screens (QMUI:343, 437).
- Merge score gaps (QMUI:1204-1212): accessory names not deprecated forwards; appearance fields searchBarStyle/clearIconImage/barBackgroundImage/barBorderColor missing on CYLSearchBarView; three table instances; CYLSearchView has no store mode; fence regeneration script and negative test; Discover page, port contentView lists, "searchable items" option; screenshots 27.2 only, no dark mode/large Dynamic Type; swipe only simulator-tested, RTL not mirrored, UIKit cause unknown (file Feedback); CYLSearchView demo lacks swipe; isActive mirrors UIKit.
- QMUI:1102 highlight proxy: changing searchResultsDelegate reassigns the same proxy as dataSource, UIKit may cache optional selectors (guard: set nil first; untested).
- Phase 1/2 leftovers (QMUI:999-1002, 1039-1043): centered placeholder screenshot; real touch checks; long history and dark/large text of launch view.
- Material demo before images only for Default (QMUI:965).
- Phase 6: ClassifyMenu CYLMenuStyle.minimumItemSize (QMUI tag 69x29) + pin move on every platform; task-log merge entry not done (QMUI:863, 1212, 1367).
- Possible ClassifyMenu option "always show fold control" (owner decision, QMUI:1651); HarmonyOS/iOS not run with 10 suggestions; mini program example tests need generated components folder (QMUI:1652-1653).
- SBV:82-84 no VoiceOver session on a device; CMP:60-61 speech recognition unverified.

### Android
- Real predictive-back swipe never exercised (QMUI:565, 1437); dark mode/ja/zh/large font screenshots; frame-by-frame animation test; focus sink is an invisible Tab stop (QMUI:569).
- Tag borders clipped 2-3 px (QMUI:1438; 5b says margins fix addressed clipping, QMUI:1595); after 5b: fold control missing note closed as misreading; list is now an inset white block with 12 dp margins (QMUI:1617).
- cancelButtonFontSize is a second property beside cancelButtonFont (QMUI:1619).
- controller.recent / controller.launch.label strings unused (QMUI:1439).
- RN/Flutter Android wrapper deprecated names (QMUI:1439) closed by 5b (QMUI:1598).

### HarmonyOS
- hidesSearchBarInitially/WhenEmptyViewShowing only unit-covered; no label-based UI test then; no detail push; dark mode/other languages (QMUI:631-636).
- Discover.ets Flex wrap (QMUI:1294); generation guard untested; swipe window 40-66 px decision; styles screen not re-shot; docs/harmonyos-api-alignment.md lacks rows for new members (QMUI:1298); unused iOS strings.

### WeChat mini program (all device checks pending in Windows session)
- Two Windows-session test checklists: QMUI:706-730 and QMUI:1369-1386 (steps and expected results; screenshot file names; wechatide skill, base library 3.6.6, clean build deleting example/miniprogram/components and miniprogram_npm, node scripts/sync-example.js).
- Overlay cyl-search bar lacks accessory slots/margin providers; timer-based didpresent/diddismiss; Discover page flex wrap; delete deprecated names after one release; dark-theme detection (isDark) unverified; 15 + 10 device points open (QMUI:699-704, 1363-1367).
- SBV:228-229 items still drawn by own code on HarmonyOS and mini program (TODO in docs/animated-icon-component.md).

### React Native
- iOS snapsHeaderSearchBar done by setSnapsHeader but no device check; hidesSearchBarWhenEmptyViewShowing ignored; CYLSearchView page component lacks scrimColor/noResultsText/swipe/setActive/events (QMUI:1523); no native tests; dark mode/large font; swipe/setActive/clearHistory never exercised; React children as accessories; list bar options (QMUI:1522-1525, 1616-1619); RN iOS Release not run in 5b.

### Flutter
- Android scrim/predictive back not run on device and Android scrim page height differs from iOS (QMUI:1574); dark/large text/other OS; accessories and launchViewBuilder stay Dart; no native bridge tests (now none on Android) (QMUI:1575-1578, 1618); Short list/emptyView unchanged.

## Coverage

All reads used the Read tool with offset/limit, in pages; no shell content reads (wc/awk were used only for line counts and page sizes). No page showed a truncation marker and the long lines inspected ended completely. Paths are relative to the repository.

| File | Lines | Ranges read | Skipped / unread |
|:--|--:|:--|:--|
| docs/qmui-search-controller.md | 1653 | 1-203, 204-239, 240-254, 255-354, 355-476, 477-608, 609-756, 757-870, 871-955, 956-1053, 1054-1109, 1110-1229, 1230-1326, 1327-1466, 1467-1573, 1574-1653 | none. Images referenced by the document were not opened |
| docs/search-api-comparison.md | 344 | 1-150, 151-296, 297-344 | none; images not opened |
| docs/search-core-merge.md | 272 | 1-100, 101-190, 191-272 | none |
| docs/search-bar-view.md | 280 | 1-110, 111-200, 201-280 | none; images not opened |
| docs/no-system-searchbar.md | 49 | 1-49 | none |

Checks beyond the assigned files (targeted Glob/Grep only, 2026-11-29): file list of Sources/**/*.swift; greps in Sources, CYLSearchExample, CrossPlatform ios folders, Android cylsearch main, *.podspec, and a heading search of docs/task-log.md. Prompts quoted verbatim in the documents are summarized (English) here, not copied. The digest condenses long tables and logs: for exact wording, test names or screenshot labels, go to the cited lines. docs/harmonyos-api-alignment.md was not in the assigned list and was not read.
