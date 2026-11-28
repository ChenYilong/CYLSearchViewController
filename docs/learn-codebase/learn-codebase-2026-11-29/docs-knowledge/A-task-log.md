> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Written by a subagent: its claims and contradictions were NOT re-checked (only items marked S in 02-findings.md were). What the source documents report as done or passing is their claim.

# Task log digest: docs/task-log.md (CYLSearchViewController)

## 0. How to read this

- Source: `docs/task-log.md` (2382 lines, 430,685 bytes). **`L123` means `docs/task-log.md:123`.** A range is `L123-130`.
- Dates run 2026-11-12 to 2026-11-27. "Claimed" below is what the log says. **I did not run any build, test, emulator or screenshot.** Only section 5 holds things I checked myself (read-only git/grep).
- The log's rule (L3-6): tasks with no better home in `docs/` go here (feature tasks go in the feature doc); entry is `TODO` before work, `DONE` at the end. So this is **not** the complete project history.
- Platform key: AND = Android, HOS = HarmonyOS, MP = WeChat mini program, FL = Flutter, RN = React Native. "CVCM" / ClassifyMenu = CollectionViewClassifyMenu; TabBar = CYLTabBarController (also ships CYLAnimatedItem / cylanimateditem); PH = CYLTableViewPlaceHolder; Dealloc = CYLDeallocBlockExecutor.

### Structural traps in the file (read before trusting a status)

1. **Headings are often stale.** These say `TODO` but the body says finished: L505 (85, later 93/100; 7 points left), L558 (DONE 100), L586, L611, L627 (all DONE 100), L706 (DONE 100), L722 (DONE 90), L751 (DONE 100), L802 (DONE 100), L876 (DONE 100), L920 (94/100), L1156 (DONE 100 HOS part), L1233 (DONE). Always read the body's Status.
2. **Misplaced I3 result.** Heading L2275 says DONE (bug I3) but L2287 says "entry written; work not started". Its real result is L2298-2304, which sits *after* the unrelated mini program entry L2289-2297 (75/100). L2298-2304 (`CYLSearchPageView`, test `testI3SizeChangeLaysThePageOutAgain`, 100/100, 154 tests) belongs to I3, not to the mini program.
3. **Container entry L1523** (Android Liquid Glass look in Flutter): its Plan / Acceptance / "Status: TODO" are at L1557-1559; between them L1528-1556 are many dated sub-results, including unrelated RN/Flutter iOS batches, each with its own DONE.
4. **Out-of-place bullets:** 11-16/11-17 one-liners sit under the 11-18 CI entry (L464-467); pin/update bullets sit under "Tag list tint" (L1576-1578); one-line dated entries 2026-11-15/16 (L209-362) follow the L120 entry with no heading; commit stamps are spliced mid-text (L137, L198, L217-218, L267).
5. Some entries were written after the work, against the rule (L2191, L2272).

---

## 1. Entries in file order

### 1.1 Rules and early work (11-12 to 11-16)

- **L8 (11-12) Log every task in docs/ before starting** (so interrupted multi-session work is recoverable). DONE: rule in `AGENTS.md`, `instructions.md`, folder instruction files, all seven `cyl-*` skills; logged first (`eb0ce70`), branch `feat/search-bar-view`.
- **L38 (11-12) Merge PR #6 then #5 after CI.** DONE: #6 CI 6/6 (run 43112176663), merge `51a0e39`; #5 CI 6/6 on `ac03541`, merged to master `55022ba`. #6 carried the scene life cycle fix (example did not launch with iOS 27 SDK), tab-renaming page titles, `scripts/public-api-doc-coverage.sh`.
- **L58 (11-12) Retarget all open PRs to current branch, merge, keep only it.** DONE: fork PR #2 merged (`e9ca91e`), #7 closed (no new commits), #8 retargeted to master; four remote branches deleted; `feat/swift-core` + master remain. Another session's local `feat/search-bar-view` checkout untouched.
- **L77 PR for clean sibling checkout** (built against a detached `18971fe` of PH because sibling had half-finished `CYLRefresh/Custom/Drawn/`). DONE 11-14: nothing to PR.
- **L88 (11-12) Rule: translated third-party projects** must get their open PRs merged/translated and open issues tabled in docs (link, description, status default TODO), fixed with scoring to 100; translation may start at 60. DONE (rule); applying it to the five Kotlin transcriptions in `android/` is a follow-up in `docs/android-and-cross-platform.md` (L110-113).
- **L115 PH as sub-repository on every platform:** DONE 11-16; details in `docs/sub-repositories.md`.
- **L120 (11-14 to 11-16) Finish all CVSC tasks and every TODO in docs.** DONE 11-16 (L134-139): iPhone Duo overlap (`c9d1da3`, core fix; 26/26 on both devices), iOS raised plus, RN touch checks + tab bar (`94b6621`, TabBar `2a12582`), native iOS Discover screenshot (`-CYLDemoTab 4` is Discover, 2 is plus), AND animated placeholder (PH PR #28/#30, pin `6d8b264`; PR #28 merged to PH master `7bc27a1`, L209), HOS scorecards to 100. Left out: SVGA tab icons in RN example. Notable sub-facts:
  - RN tap tool is xcodebuildmcp's bundled `axe` (`/opt/homebrew/Cellar/xcodebuildmcp/2.7.0/libexec/bundled/axe`) (L172).
  - User skipped raised plus on Liquid Glass (L181); iOS 26 ignores the raised plus config keys (L166).
  - HOS emulator was thought to need signing (L187-191); superseded L213-216: hvigor builds `entry-default-unsigned.hap` and `hdc install` accepts it on the emulator.
  - MP: fixed `cyl-search` infinite recursion (observer on `suggestions` calling `sync()`; drawn list now `shownSuggestions`); tourist AppID cannot be automated; real AppID lives only in git-ignored `project.private.config.json`, committed config keeps `touristappid` (L194-207).
  - MP example made a 1:1 copy of iOS example (`d19e0bb`; 18 pages, 11 interactions, Node 26/26) and packaged as library (Node 30/30, `npm pack` found 3 library-only faults) (L219-227). npm publishing waits for the user (L289).
  - iOS CI fix: TabBar `CYLTabBarManifest.swift:812` failed at `2a12582`; pinned `c006143` (L228-234).
  - HOS example strings moved to resources (emulator runs zh-CN) (L235-237).
- **L239-262 (11-15) HOS tests and Back gesture:** hypium added (6/6, then UI 11/11, then 13/13). Command: `hvigorw -p module=entry@ohosTest -p isOhosTest=true -p buildMode=test assembleHap`, `hdc install` both HAPs, `hdc shell aa test -b com.cyl.search.harmonyos -m entry_test -s unittest /ets/testrunner/OpenHarmonyTestRunner`. New APIs `handleBackPress()` on `CYLSearchView`, `CYLSearchController`, `CYLMultiSearchView`.
- **L269-286 Back parity:** AND `CYLMultiSearchView` fixed (17/17). MP `cyl-search` uses `page-container`; **still unverified**: automation cannot prove it (`wx.navigateBack` and `automation_navigate` bypass `page-container`). Manual steps at L281-284 (Examples > "MiguelCatalan" = `pages/materialSample`, open search, tap nav back: search closes, page stays).
- **L291-296** AND/RN/FL TODO table done 100/100 (`docs/android-and-cross-platform.md` "Open TODOs").
- **L297-331, L337-362, L464-467 (11-16/17), one-liners:** RN raised plus (`alignsTitle: false`; 52 pt PNG because `imageSize` drew SF Symbol black; title follows text color). SVGA demos progressed 1/12 to 13/13 (L300-329, L466); found "light after dark keeps dark SVGA files" (L304). HOS table 397/397=100 (67 UIKit-only rows "TODO: N/A on HarmonyOS"); **a11y + localization rule everywhere; UI tests locate through them** (L305-317). Rules added: git cz English-only (skill `cyl-commit`); prefer bash over zsh (L331-336); every branch with commits needs an open PR (base = previous active PR branch else master; >2 open PRs: ask) (L343-354); on non-master/main branches commit and push without asking (L355-361). HOS "ignores touches" BUG was wrong (stale uitest dumpLayout) (L342). HOS Rive crash fixed by pins (L362). AND/HOS pin checks (L465-467).

### 1.2 Process rules and screenshot policy (11-18 to 11-20)

- **L364 (11-18) Start/score/other-sessions/hung-emulator rules.** Prompt: TODO + branch at top; docs entry with acceptance (100 and pass); never stop below pass; list missing points as TODOs; check other sessions; restart hung emulators from CLI without asking but tell sessions first. DONE 100: `AGENTS.md`, `instructions.md`, new skill `cyl-task-start`.
- **L399 (11-18) Stitched screenshot layout:** header+footer outside the shots with English key facts (platform, OS, host, IDE, purpose); one column unless taller than a phone screen, then two. DONE 100: `scripts/stitch-screenshots.swift` (`--header`, `--footer`, `IN.png=caption`, `--columns auto`); example image `docs/assets/screenshot-style-example-ios27.2-rive-tags-20261118.png`.
- **L423 (11-18) Why label rule was skipped.** Root causes: rule landed after session read AGENTS.md with no re-read rule; partial application; only a macOS tool; no check. DONE 100: `scripts/stitch-screenshots.ps1` (both write `CYL header: ... | CYL footer: ...` into PNG), `scripts/check-screenshot-labels.sh` (fails added `docs/assets` image lacking that text, a Markdown link, or date+commit on the link line), workflow `screenshot-labels.yml`. 12 shots relabelled, originals in `docs/assets/raw/`.
- **L456** removed that workflow (done); **L469 (11-20) restored** it (`86e6cc8` reverted by `a68405f`; user says it was deleted by accident). Current intent: workflow exists.
- **L479 (11-20)** job diffed whole PR history (338 problems, run 44689036538). Fix: use `github.event.before` on synchronize. Not tested locally; relabelling old images left undone then (later done, L1233).

### 1.3 Pins, TODO sweeps, iOS fixes (11-21 to 11-22)

- **L505 (11-21) Fix every open TODO (Windows).** 85/100, later 93/100 (L545-546). Done: stale notes (`bf1b2f8`), `showsSuggestionCacheHeader` on AND/HOS/MP/FL/RN (`efb3b78`), HOS emulator target + `-p buildMode=emulatorTest` (hypium 29/29, `90b3dcf`), Maven `com.cyl:cylsearch` MIT POM (`626e3c5`), RN `onReorderingChange`/`onSmearingChange` AND (`1a2a7cb`), RN AND build fixed (duplicate SVGA assets, `8310962`). Left: **7 pts MP back gesture (manual)**; owned elsewhere: MP keyboard placeholder + tab-switch retest on user's phone; Maven coordinates (later solved, L611).
- **L558 Test all non-iOS platforms.** DONE 11-22 100 at `11b4b33`: AND 26/26; HOS host 30/30, parity 549/549, a11y 0 problems, hypium 29/29; MP 61/61; FL 18+3; RN jest 4/4; API tables 289/289, scorecard 314/314. Gotchas: no androidTest tests; RN release build fails on Windows (ninja >260 chars under react-native-safe-area-context); RN debug APK used bundled JS assets.
- **L586** pin TabBar `ace1af0e` (PR #822 renamed `CYLAnimatedItemView.style` to `itemStyle`; contains AND More-tab fix `c1abdffe`) + CVCM `1f8c1001`. DONE 100; quick switch 8/8. Gotchas: `CYL_*_DIR` copies a local clone's **working tree, not the pin**; after pin change delete stale `vendor/.../react-native-cyltabbar/android/build` ("it is internal in file" error); `Remove-Item` with long-path prefix silently did nothing, `rm -rf` worked. Rule: both repos pin the same TabBar commit.
- **L611** PH `a169386`, POM mapping dropped (PH publishes its own coordinates, `io.github.chenyilong:cyltableviewplaceholder(-refresh):0.1.0`). DONE 100.
- **L627** CVCM `881476a` + PH `c473fdc`. DONE 100 (**its HOS result is invalid**, see L776-779). `ci-screenshots` is an orphan image branch, not code.
- **L647 (11-21/22) All iOS/Swift TODOs (Mac, branch fix/ios-swift-todos, PR 13).** 97 then 98/100: Quick Help 291/301 (10 are UIKit overrides, `218ba50`); raised plus 90 (title stays gray; asked TabBar for dynamic color); More tab 8/8 (found More item shows first moved tab's SVGA icon, sent upstream); FL iOS tag drag; Swift migration steps 2-4 (legacy ObjC removed, Swift tests + ObjC smoke test, 40/40); RN iOS drag events. Six commit subjects break the commit-message check (left as pushed). Build from APFS worktree (`/tmp/xpr/csvc-ios`; vault volume is exFAT).
- **L691** reviewed/merged PR 13 (CI run 44901322830 green).
- **L706** CI compile error `CYLSearchBar.swift:419` implicit self (Xcode 26.6 rejects what Xcode 27 accepts). DONE `ff1e4de`, run 44955819321 7/7.
- **L722** QMUI port leftovers. 90/100: 185 tests on iOS 17.5/26.5/27.2; launch view refresh `0b3cbcf`; other platforms ported (AND 92, HOS 90, FL 86, RN 87, MP 79/85). Missing: iOS 15-16/18-25 unverified, MP device test, dark/large-type shots. Note at L739-740: **no rule then gave other platforms to Windows** (superseded, see contradictions).
- **L751** pins TabBar `618ac11a`, CVCM `9dc1f761`, PH `6117fcf`. DONE 100 (AND 50/50, hypium 41/41, MP 84/84, FL 18+3, RN 4/4). **Correction L776-779:** robocopy from Git Bash had silently failed since 11-22 00:33 (MSYS turned `/MIR` into a path; unquoted backslashes lost), so the HOS mirror held old pins. Always verify the mirror's `oh-package.json5`.
- **L783** x86_64 HOS emulator HAP rule: `@ohos/rive` and `@tencent/libpag` ship arm64-v8a only; use `entry@emulator` target + `emulatorTest` mode; check with `unzip -l`. DONE 100.
- **L802** x86_64 plan moved into TabBar `cylanimateditem` (`62715829`, `882ece17`). DONE 100.
- **L822** merge QMUI search components with ours (one implementation per concept; tag list = CVCM `CYLTagListView`; examples call core). Status L849-854: phases 0-5b done (`faf68da`..`4f8e22f`, log in `docs/qmui-search-controller.md`): iOS 88, AND 91, HOS 90, FL 88, RN 87, MP 85/90. **TODO phase 6** in CVCM (69x29 min tag size, AND tag border clip, owner decision on fold control when all tags fit) and MP device test.
- **L856** CYL/cyl_ prefix re-evaluation against SonarCloud (rules DONE; skill `cyl-naming`). Test helpers renamed to lowerCamelCase (`fe82e0c`, 185x3 sims). TabBar renames belong to that repo.
- **L876** pins TabBar `882ece17`, CVCM `405bf498`, PH `f4cf978`; DONE 100 (AND 51/51, hypium 41/41, MP 84/84). Notes: a HAR cannot filter native libs of the consuming app, so the app keeps the build profile; example PAG/Rive views are only built when `CYLAnimatedItemEngines.canPlay`.
- **L903** arm64-only Rive/PAG tests: plan 1 = x86_64 libs in TabBar's CYLAnimatedItemView, ABI-guarded, compile-safe first, **behind debug guard; removal requires user approval**; plan 2 = macOS arm64 testing. Status 60/100 (rule + handoff). Later reports: see L1068, L1467.
- **L920** default `suggestionStyle` = tags, folded (2 rows), trailing fold tag always present, on all platforms; list-replica screens set list style explicitly. 94/100; details `docs/tag-view-suggestions.md`. TODO: MP device test, HOS `CYLSearchUI` rerun, AND 5 px cut of first/last tag row (CVCM).
- **L943** instruction files reorganised by tag, ≤200 lines each, 16 tags, details in `docs/instructions/<tag>.md`. DONE.
- **L960 TODO** move PH pin past its Swift rename (`0c8961f`; ObjC selectors unchanged, Swift spellings change with no aliases; mapping in PH `docs/Swift-Naming.md`).
- **L971, L987** `docs/instructions/behavioral.md` is first category, read in full every task, CLAUDE.md imports it. DONE.
- **L1000** read `docs/instructions/git.md` in full before any git op. DONE; found the commit-msg hook that strips `Co-Authored-By:` was never installed; installed in that clone (L1010-1012).
- **L1015** CI flake `testB7CancelDoesNotJitterWhenLeavingSearch` (runner keeps bar off-window entire sample window). DONE `327d9c5`.
- **L1029** CI: labels, `contentEdgeInsets` deprecation (use `UIButton.Configuration`), flaky `testShowDuringCloseKeepsTheViewOnScreen`. DONE; one run waited 80 min and blocked the concurrency group.
- **L1045** pins TabBar `c8fee654` + CVCM `111c73aa`. DONE. Gotcha: AND core tests failed 22/66 from leftover views observing the history signal under Robolectric legacy SQLite; tests now detach views (`efc20a1`).
- **L1064** pins TabBar `c4a1f8fd` (adds PAG x86_64 kit) + CVCM `04b39e26`. DONE (AND 76/76 after `2d4ffb8` same detach fix; hypium 55/55). Peer reports Rive+PAG OK on x86_64 HOS (L1068-1069).
- **L1079** iOS TODOs after QMUI port. DONE 100: black band behind nav-item bar fixed in core (`bfbee55`, `systemBackground`); RN smear needed new prop `allowsSmearSelection`; CI label + `testDelegateLifecycleOrder` timing fixed.

### 1.4 Animation engines, iOS leftovers, labels (11-23)

- **L1121** Rive on HOS: no change needed (pins already contain fixes; this repo ships no `.riv`).
- **L1133** move animation players into TabBar's CYLAnimatedItemView. Ownership given to the CVCM session (TabBar PR #824, one engine module per format). No `CYLPagIcon` exists. Audit found 3 contributions (Rive `615fc30` trigger-after-reset fix; AND `012343f` `isClickable=false`; x86 HAP recipe). HOS done `6d3f2a8` (not scored 100 here: only SVGA seen).
- **L1156** one shared Rive engine `cylanimateditemrive` (TabBar `3074c51d`). HOS DONE: pins TabBar `f51057a7`, CVCM `e474f469`; sync scripts copy the module; 55 run, 48 pass, 7 UI errors that also fail on previous commit (cause open). No Rive file actually played. Other platforms surveyed only.
- **L1200** I2/I5 116 pt offset while searching: DONE 100 (`0a7deab`, 188 tests x 3 iOS versions); `Podfile.lock` committed (`b0096d9`).
- **L1233** label 338 failing old screenshots: DONE (202 images; unknown metadata written "not recorded", never guessed; unlinked ones listed in `docs/screenshot-index.md`). Real device/OS of old images unknown.
- **L1250** label job on first push of new branch compared to root commit (64 problems); fix: merge base with default branch. DONE.
- **L1265** HOS build broken at TabBar `f66e85d5` + CVCM `325c7a31` (missing `cylanimateditem_lottie` vendoring, `Slider.accessibilityValue` absent in API 21). DONE `72197dd`, 55/55. `jbr/bin` must be on PATH for PackageHap.
- **L1284** switch to shared engines: AND done (TabBar `9c8cf475`); HOS done later (`6d3f2a8`); **TODO MP** (needs CVCM `cyl-tag-list-miniprogram` at same TabBar commit; PAG/Rive need wasm in package + subpackage wrapper); iOS assigned to Mac; AND emulator/screenshot not verified.
- **L1305** iOS check of animated-item changes (rows 38-42): 85/100; remaining 15 closed in part by L1518-1520 (test, no-reload, analyze; score 90 there). Gotcha: 278 MB TabBar fetch stalled, so pods used temporary uncommitted `:path` overrides. RN needed `CYLRNSearchSupport.h` to import SVGAPlayerLite first.
- **L1330** HOS example plays through PR #824 engines; own players (~1470 lines) deleted; DONE 100 (pins CVCM `14b6b955` + TabBar `a5e4434c`; 55/55).
- **L1358** FL/RN pins to `9c8cf475` (user decision: AND/FL/RN stay there then). RN reads `cyl.tabbar.commit` from `android/merged/gradle.properties` via `fetch-cyltabbar.sh`.

### 1.5 Discover page and core-cohesion work (11-24)

- **L1369 PARTLY DONE** animation demo rule: animate the camera button itself (`search_camera.json`), no extra bar item; loop/speed controls outside the bar (rule in `docs/animated-icon-component.md` "Animation demo rule"). iOS `a746489`; others handed to Windows. Status line L1376 still says TODO.
- **L1379 IN PROGRESS** all pins to PR #824 `f45a8f1d` (superseded by later repins). Owner approved CVCM PR #26 (merged 11-22 `1fc954a4`).
- **L1385** RN Discover spacing + missing HOT badge. DONE (example only).
- **L1392 TODO** move Discover layout into core: one 16 pt/dp content inset shared by bar capsule, header title and tag list; core header view with built-in trash/refresh icons; ClassifyMenu unchanged; contract "Default layout contract". **L1397 TODO** move "Discover" header + refresh button into core, icon by default. (Later entries implement much of this on iOS/FL/RN; the headings were never closed.)
- **L1403 DONE on iOS** i18n of FL/RN texts; core `CYLSearchTagListStyle` default (copies iOS `recentStyle()`: capsule, 1 pt separator border, margin 14, 17 pt, height 36, spacing 12, insets 16, bold 20 pt header), customizable, using only CVCM public API. AND/HOS/MP TODO. Rule: "into the core" = localized strings and built-in icons.
- **L1411 DONE on iOS** Discover topics in FL/RN built from CVCM tag list grid (new bridge props `columns`, `tagImages`, `foldedRowCount: 0`; fold default differs FL=2 vs RN codegen; noted, unchanged). Rule applies to every platform's example.
- **L1419 IN PROGRESS** CVCM radius semantics: remove `CYLTagCornerRadiusSquare`; plain number: 0 square, 1000 capsule (CVCM PR #35). RN tab titles localized; open: RN tab page descriptions/buttons and FL tab titles English; other platforms.
- **L1425 PARTLY** refresh icon everywhere, larger data set with "hot" flag inside each record at a different position each refresh, **search bar always embedded in a navigation bar (core; create one if none)**. iOS done (`docs/animated-icon-component.md` contract). Open: AND, HOS, MP, RN AND ViewManager setters (`showsRefreshButton`, `columns`, `tagImages`, `embedsInNavigationBar`). Old data: 12 topics, window of 6, hot tag at 0 or never.
- **L1432 PARTLY** Discover always a second-level page with a back button (iOS root entry page pushes it; `CYLSearchNavigationBar.holding(_:hasBackButton:backHandler:)`; FL `showsBackButton`/`onBackPressed`; RN `onBackButtonTap`). Windows platforms open.
- **L1439** pins CVCM `4be6cda` + TabBar `c6b3e976`; `capsuleCornerRadius` removed; `tagBackgroundStyle` default flat. Not run then.
- **L1445** Liquid Glass tags in every example; pins `551072a` + `b4299707`. One parameter per list (`style.backgroundStyle = .liquidGlass` / `backgroundStyle="liquidGlass"`). Finding: untinted glass on white is invisible; glass tint keeps 75% alpha. 200 tests (one flaky `testI2PlainBarInAnExtendedViewStaysInPlace`).
- **L1451 (a4) hand-over to Mac:** only SVGA seen on HOS; HOS pins lag; a mixed-module HOS build crashed (all `cylanimateditem*` must come from one TabBar commit); MP 95/96; CI queued; 7 owner-only points (MP back arrow, phone tab switch, keyboard placeholder). Reports a *peer claim* that the owner approved removing the x86 debug guard (TabBar `269eff24`), approval **not seen** by that session (L1467).
- **L1471 (11-25) Owner delegated to advisor:** merge CVCM branches (TabBar ≥ `a4fcb998`, Dealloc `4276a6da`); selected tag look stays glass at tint 1. Status line TODO.
- **L1478 TODO(3e) all-platform interface score.** At `fdaa37f`: AND 83 (`api-alignment.py`) and 93 (`ios-alignment.mjs`), HOS 74, MP 69 (443 public Swift API rows after QMUI port). Result (static): all alignment scripts 100 (AND 412 done+31 N/A), host 72, MP 119 pass/5 fail (need git-ignored `sync-example` output). Task score 60; L1501-1505 Windows batch TODO (Gradle test, HOS build/aa test, MP DevTools, labeled shots). Known: `cyl-search-bar` didn't draw `clearIconImage`/`cancelTitle` (fixed L2289); `CYLSearchController` re-exported in MP although listed removed (owner decision); `docs/ios-api-alignment.md` not regenerated (8 AND-only reverse rows TODO); `CYLSearchComponent` does not call `searchBarLayoutChanged` on HOS.
- **L1507 TODO(3e) claimed tasks** → 90/100 (L1518-1521): speed test + no-reload test; 201 tests; analyze clean in Sources (`CYLContactTagEditorViewController.swift:259` `contentEdgeInsets` left). RN/FL iOS glass nearly invisible (flat white appearance kept).
- **L1523 container (3e), Flutter-on-Android glass/search bar/HOT icon:**
  - Measured: **no glass is drawn on Android at all** (L1532); static theory about backdrop unproven. Agreed order: flat defects, then iOS pins, then AND CVCM pin + glass wiring (L1533).
  - L1535 flat fixes: Toolbar 6 dp insets clipped border (now 4 dp); border/fill; HOT icon loads 2x/3x assets. Robolectric needs JDK 17 (Studio's JDK 25 fails).
  - L1536-1537: `applyBackgroundStyle` uses `.clear` fill for glass; upstream TabBar `4980ef65`/`a4fcb998`: nil **or fully transparent** host color gets default frosted tint on all platforms.
  - L1538-1541 successive pins `8cd4efa`+`235f6e96` → `755aa30`+`11fc94be` (14 pt glass content inset) → `ca04a77` (default .label tint) → `603592b`+`230b5266`. AND tests ended 107/0.
  - L1542 owner: apply search bar change to all platforms; found missing placeholder and no FL dark theme; fixed; verified.
  - L1543-1556 RN/FL iOS batch series (each DONE, screenshots, simulator stopped): pins `05ba8abb`; `0de4546b`+`09bde3ca` (MP pin guard fails since CVCM ships `230b5266`); `22c9f5ca`+`6f563ef4` (topic grid has no glass board by design, owner decision pending); `6a2fbf25`/`1207883c`+`08343e9f` (found FL first-open nav bar clipped); L1548 fix: display link waits until window x steady 3 frames, then re-sets items; L1549 `c0b183de`; L1550 nav field preset; fixed RN Fabric view recycling leaking Discover back button (`CylsearchBarView.mm updateProps`); L1551 default Search button + Dealloc `eab21d10`; found duplicate Search buttons; L1552 verified one button; editing bar keeps focus; L1553 first-level push verified, RN camera missing on first display; L1554 fixed in core (item stack must be measured by intrinsic size, not `fittingSize`); L1555 icon default PASS, FAIL gaps 10.7 vs 8.3 pt and camera hit area one-sided; L1556 after core hit-area fix and trimmed Lottie: 8.7 vs 8.3 pt, taps pass.
  - L1557-1559 original plan/acceptance (glass visible on AND/FL-AND in light+dark, HOT ~20 dp) and **Status: TODO** never updated. Later glass work L1674-1803 supersedes it.
  - Minor still-open observations: FL light shows white status bar (L1547, fixed L1815), RN contact tags pages stay white in dark, FL "Tags" labels dim in dark, RN Discover tab bar camera (fixed).

### 1.6 Tint, tag-list demos, glass (11-25)

- **L1561** glass screenshots iOS (`99a664d`). DONE iOS.
- **L1568** tag-list dark tint: core `tagListTintColor`/`applyTint`; superseded by CVCM `ca04a77` default tint, overrides removed (L1578; commit `1e411ad`; 201/0). AND/HOS/MP still fixed grays then.
- **L1580** placeholder `.secondaryLabel`; `CYLSearchBarTextField` forwards a directly assigned placeholder (`1003f9f`). Camera icon then open.
- **L1588** camera icon dark: core hex `animationTint`/`animationDarkTint` (`41f2d98`); **L1596** replaced by `animationTint="title"` with pins `3ed13b9`+`5a212de9` (`cd3f19b`), live switching works.
- **L1603** built-in default tint spec (UIView.tintColor semantics: item > stack > built-in; selected = inherited tint; host value overrides). Status line TODO, but updates L1610-1613 show shipped in `603592b`+`230b5266`: **the bar sets no tint**; items live in one `CYLAnimatedItemStackView` (spacing 8, `dispatchesItemTaps false`), dividers via `appendDivider` (`76618c0`). DONE iOS. Open: plus button title dim gray.
- **L1615** AND/MP dark defaults. AND defects then: headers/titles dark, More icons black, tab bar light, theme change returns to first tab. HOS unrun.
- **L1624** iOS grouped demo lists → glass tag lists (`CYLDemoTagListViewController`; `titleMaxLines` 3; callout via `menuSubtitleForItem`); pins `05ba8abb`; core fix: list background `.clear`. DONE, 201/0. Examples menu and styles screen not converted.
- **L1634** advisor score: all API tables 100; correction: the "201 pass" for `35bb62a` predated the last edit; re-run 201/0.
- **L1642** tail fold default must be **icon only** everywhere. Audit: AND core default was `IconAndTitle` (asked CVCM), MP lacked `iconAndTitle` (added `851c233`). iOS done (`CYLMenuFoldControl(position: .tail)`).
- **L1650** Windows results: AND 114/0 alone; **`CYLSearchViewQMUIPortTest` 10/10 fail in combined/incremental runs (Robolectric SQLite "Illegal connection pointer")**, pass with `--rerun-tasks` alone. FL bridge done; RN props added but Kotlin not compiled; HOS 57/57 (a vendor `CYLAnimatedItemColorCount.ts` patched only in mirror; later unnecessary, L2078); MP lists unconverted.
- **L1661** examples: tail control icon only, supersedes all earlier "more/less" wording; check `scripts/check-example-fold.sh`. DONE.
- **L1670** pins `0de4546b`+`09bde3ca`; iOS 201/0.
- **L1674** gradient page behind glass (rule 7). AND/FL partial, HOS/RN code only, MP missing. Core gaps L1691-1697: AND `CYLTagButton` never sets `CYLLiquidGlassView.backdropSource` (default root contains the tag, so only tint+rim); board needs it too; FL/RN have no backdrop parameter; HOS/MP no backdrop-blur property; <Android 12 flat expected. L1698 asked iOS.
- **L1700** Windows repin; `liquidGlass` now sets glass board + glass tags on AND/HOS/MP; FL PNG tab icons need `CYLTabBarItemIconRenderingMode: template`. `C:/w/heavy.lock` = shared heavy-job lock. TODOs L1727-1730.
- **L1732** iOS gradient + glass **WORKS** (`CYLDemoGradientView`). **L1737** Discover/contact tags converted; **deliberately not converted (owner's word needed):** examples menu, search bar styles screen, MaterialSearchView samples list (tests depend on tables).
- **L1744** rule: after any simulator run, terminate app and stop simulator at once (only your own); new skill `cyl-simulator-run`.
- **L1751** Windows converts all lists (new `common/DemoTagMenu.ets`, `utils/cyl_demo_tag_list.js`, `check-example-taglist.sh`). Table L1758-1764 all PARTIAL; core gaps L1767-1773; TODO L1774. L1775: FL gradient moved to `MaterialApp.builder`.
- **L1777, L1781** pins `22c9f5ca`+`6f563ef4` (CVCM ran no unit suites); iOS 201/0; AND 114/0 (the 10 failures did not occur); dark-glass icon lift (CYLIconContrast) iOS-only; AND/HOS use static `iconColor`.
- **L1788** `6a2fbf25`+`08343e9f`: AND example gradient moved to sibling **backdrop plate** (`CYLBackdropPlate.kt`) assigned to `backdropSource`; PARTIAL.
- **L1796 (11-26)** `1207883c`: debug striped plate (`--ez CYLDebugStripes true`): **AND blur and scroll-follow WORK**; refraction not separately visible. Gap: Discover recent list defaults Flat on AND (fixed L1816). Window `wm size 1080x1300` to enable scrolling; headless `-no-window -no-metrics` after crash-consent dialog. ClassifyMenu's own larger test counts (258/292/188) are not this repo's.
- **L1805, L1822** iOS repins `6a2fbf25` (`82d77da`), then `1207883c`; 201/0 each.
- **L1810** FL iOS first-open fix by static reasoning (`CYLFlutterNavigationBarContainer`), status bar style, Glass default on AND Discover (`316a2cd`). Needed Mac verification → found incomplete, completed in L1548. HOS test 25 "App died" noted. Dark FL back arrow dark-on-dark (fixed L1832).
- **L1827** `c0b183de`: AND board 16 dp / tags 28 dp; FL AND back arrow fixed (`tintBackArrow`). **HOS app freeze** (THREAD_BLOCK_6S): 42 sections / 168 glass tags built at once; fix `CYLGalleryChunks.ets` builds 6 sections per chunk.
- **L1836** iOS `c0b183de`, 201/0, header 17 pt semibold.
- **L1841** HOS UI 57/57: glass tags expose no text to uitest; helper `tapDemoTag` finds id `CYLTagListItem-0-<row>`, expands via `CYLTagListFold-0`, scrolls.

### 1.7 One search field, no system search bar, focus, first level (11-26)

- **L1855** (TODO heading; delivered by L1862) one nav-bar field component. **L1862 DONE iOS:** `CYLSearchBarView.applyNavigationFieldStyle()` (radius 18, soft shadow, no magnifier, 16 pt, opaque white/black) in `CYLSearchNavigationBar.swift`; 201/0.
- **L1870 DONE** Search tab uses `CYLSearchBarView` (owner chose); "Repro: OFF/ON" button removed (iOS only; other platforms keep Issue #1317 Repro page).
- **L1878 TODO** **no system search bar on any platform**, core or example. Progress L1885-1903: preset on AND/FL/RN (`b9e5982`, flag `navigationFieldStyle`), HOS `applyNavigationFieldStyle()`, MP property `navigationFieldStyle` + method `applyNavigationFieldStyle()`; examples migrated. L1887 (###) HOS/MP. Open: AND classes wrapping system search widgets as facades over `CYLSearchView` (`docs/no-system-searchbar.md`); L1902 later says Windows reports AND/MP wrap none (conflict, see contradictions); cjj reveal/lapism replicas keep own looks; device verification of HOS/MP (later L2075, L2111).
- **L1904 DONE iOS** no system search bar: `CYLSearchController` rebuilt over `CYLSearchBarView` with own page; **`CYLSearchBar` class deleted** (breaking public API); suite 201→141 (60 removed/merged tests, itemized L1910-1917: UIKit-presentation-only behaviours).
- **L1921 TODO** auto-focus whenever bar reappears (via Dealloc events). Iterations: iOS stage 1 `didEnterScreen` (L1928, 142/0); AND back-button filter (L1929-1936); HOS/MP same (L1937-1944).
- **L1946 DONE iOS** keyboard lifecycle + default search button: Dealloc PR #29 (`775fc2f6`) events `didBecomeActiveOnScreen`, `didTouchOutside`; props `focusesOnAppear`, `dismissesKeyboardOnOutsideTouch` (YES), `showsSearchButton`, `searchButtonStyle`, `searchButtonTitle`, `searchButtonImage`, `searchButtonHandler`, `searchButtonItem`; localized `search.button`; 144/0. Open then: back-button filter (L1955), bridges (L1956-1957), real touches/background return unverified.
- **L1959 TODO** AND/FL/RN first-level whole-bar push (rule 10 of `example-demos.md`). AND API: `embedInToolbar`, `showBackButton/hideBackButton(animated)`, `backButtonProgress`, `onFirstLevelTap`, `pushesOnTap`, `performFirstLevelTap()`, predictive back. Tests ok; no device (later L2051). Heading never closed.
- **L1973** icon style: capsule 28 pt drawn by the item's own `CYLAnimatedItemView`; item props `cornerRadius`, `borderColor`, `borderWidth`, `itemHeight`.
- **L1975** HOS/MP first-level (static). API names mirrored plus `firstLevelTapped()`, `syncBackButton`, `applyPreset(CYLSearchBarPreset.x)`; presets navigationField, pill, rounded, outlined, centeredCapsule; HOS uses `NavPathStack.setInterception`. L1985: Dealloc event renamed **`appDidBecomeActiveOnScreen`** (PR #30, `32c2103`) + `didTouchOutside` (PR #29 `eab21d10`); both must merge (#30 first) before pin can name a master commit. L1986 iOS applied back-button filter; L1987 rule 10 then not on iOS (done at L2025).
- **L1989, L1998** default search button on AND/FL/RN and HOS/MP (static). Icon pill concentric: gap = (fieldHeight − itemHeight)/2 = 4. Open then: empty tap behaviour; READMEs.
- **L2008-2012 depth rule (owner):** `focusesOnAppear` focuses only on a **second-level or deeper page** (not by back button). iOS `isOnSecondLevelOrDeeperPage`; 145/0.
- **L2013** iOS bridges; empty-text tap on a `CYLSearchView` page submits/records/closes nothing, keeps keyboard (146/0). **L2014-2023** HOS/MP/AND/FL/RN adopt depth rule (`pageDepth`; HOS 1 = first level; AND `Int?` 0 = first level; RN default −1 unset) and empty-tap rule; AND Discover tag inset fix: `applyGrid` must set `margin = 14` (ClassifyMenu grid style sets 0).
- **L2025 DONE iOS first-level push** (`pushesOnTap`, `onFirstLevelTap`, presets, `cylInstallFirstLevelSearchBar(preset:placeholder:)`, `CYLSearchSecondLevelViewController`). **Gotcha: hiding the system back button on iOS 27.2 disables swipe-back (unit test passed, real swipe failed), so keep the system back button.** 149/0. iOS `pageDepth`: −1 reads nav stack, 0 first, ≥1 deeper (L2034). `animatesBackButton` ignored on iOS.
- **L2037 DONE** **icon is the default search button style**; text opt-in (only remark name field). 149/0; `77a5193`.
- **L2044 DONE** even trailing gaps: plain icon/text items hug content; 36 pt touch via `point(inside:with:)`; shaped items keep size; test `testDividerGapsAreEven`; 150/0.
- **L2051 DONE AND device check** (own AVD CYL_Second_API_37, port 5558): (a) PASS with notes: extra OVERLAY/magnifier actions beside bars (rule 9 owner decision), plus-tab is API demo not first-level (gap); (b) PASS after fixes `10e1cb7` (whole field is tap target with centered placeholder) and `ea757a4` (FL back arrow stayed: watch `ModalRoute.isCurrent`, new `hideBackButton` method); (c) conflict: Discover second-level empty tap searches the placeholder topic (owner decision); (d),(e) PASS; FL Discover tab root showed empty glass box (fixed L2202). RN not run.
- **L2063, L2065** `docs/Release-RAM.md`, `release-ram.ps1`, `scripts/release-ram/*.ps1` (Windows done, macOS stub). Tested on own AVD; HOS start needs `Emulator.exe -path -imageRoot`, stop `Emulator.exe -stop`.
- **L2067** icon default + even gaps AND/FL/RN/MP (static; AND `CYLTrailingGroup`, `hugsContent`).
- **L2075 DONE HOS device check** (fix `c5c1c60`): only compile error was foreground listener (keep an `ApplicationStateChangeCallback` object from `@kit.AbilityKit` for on/off). (a)-(e) PASS; edge swipe-back not verified. 57/57 **only with `-s timeout 40000`** (15000 too short). Host 105. TODO: port trailing group (done L2101), recording, real swipe.
- **L2088 DONE CI fixes:** SC2086 in `check-example-fold.sh`; podspec dependency Dealloc not on trunk, `pod-lint.sh` checks it out at Podfile pin; public comments must be three-line `/** */`; `check-licenses.sh` dropped deleted `CYLSearchBar`. L2094: camera touch area fixed in core (`CYLSearchBarItemStack` widens 8 pt each side).
- **L2096** trimmed `search_camera.json` 44→36 comp (`784aea4`); AND `CYLFieldLayout` forwards taps; iOS canonical bundle copy L2109 (150/0).
- **L2101** HOS icon default + even group (`8706106`): host 110, 57/57; measured 9.7 vs 8.4-8.8 vp (pure function gives 8/8). TODO tap test, text-style shot.
- **L2111 MP DevTools check** (`cbea34a`, `npm test` 173): fixed missing magnifier (pass **absolute** image paths across component folders), divider lost gap (`.cyl-divider{margin:0}` overrode gap), `showsBack` needs observer. How-to: skill `wechatide-skill` 0.3.11; tools give `APPID_ERROR` unless `appid` temporarily set in `project.config.json` (revert); **beforeCompile hook does not refresh components; run `node scripts/sync-example.js` first**; close window/IDE after. (a)-(f) PASS with limits. TODO dark mode, real pointer tap, pill outline vs iOS.
- **L2127 RN AND first real build/run** (`e8b4927`): vendor checkout must equal `cyl.tabbar.commit` (silent mismatch → 250 Kotlin errors); Windows 260-char: build from short worktree `C:/w/rn` with `-Pcyl.tabbar.dir` etc. (`subst` doesn't help); cold AVD needs `-Headless`. Fixed dark tag text (pass context to `applyDefaults/applyGrid`). **Open DEFECT 2** (gaps 10.3 vs 7.0 dp), **DEFECT 3** (tab bar light in dark; plus label invisible), hardware back no reverse animation (fixed by goBack L2240).

### 1.8 Tab bar tint (11-26), handover, bug fixes (11-26/27)

- **L2138** AND pin TabBar `d19e138e`: static icons black in all states (labels tint OK); SVGA unselected gray by design; bar stays light in dark.
- **L2150** HOS `d19e138e`: shipped example uses pre-colored SVGs (so does not exercise tint). Probe: stroke SVGs tint, **fill-based SVGs don't** (ArkUI ignores ColorFilter; suggest `fillColor`); dark flat bar mid-grey. Table L2163-2168 shots.
- **L2170** AND fix: config key `"CYLTabBarControllerIconRenderingMode": "template"` in both tab JSONs (tint spec v2 is opt-in); More overflow still black.
- **L2179** TabBar `af56db22` (AND only) fixes More icon. Dark bar background = owner decision (TabBar `docs/Dark-Mode-Adaptation.md`).
- **L2186** handover doc: `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md` (one file per week folder `YYYYMM0W`; sections: iOS chapter 10-17, 18 Windows, 19 I1, 20 pin split). Owner stated they are leaving and handing over (L2188).
- **L2192 (11-27) Windows takeover:** 85/100. I7: 29 AND images relabelled (`7ce7c73`). **FL bug fixed:** platform-view widgets dropped updates made before view creation (`_channel?.invokeMethod`); each `_created` now sends `update` (`test/cyl_created_update_test.dart`, FL 44/44). Missing: emulator run (10), CI run unfinished (5). L2204: 10 iOS label failures left for Mac. L2205: macOS jobs use `vars.MACOS_RUNNER || 'macos-26'`.
- **L2208 I1 DONE 100:** `CYLSearchController` overlay left after pop/dismiss; now watches contents page `viewDidDisappear` via Dealloc (key `CYLSearchControllerLeaveOnDisappear`), removes page+recognizer on end and `deinit`. 153/0 (iPhone Air sim, iOS 26.1). Untested: real device, cancelled interactive pop.
- **L2240 RN `goBack()`** on `CYLSearchBarHandle` (`3289796`): 65→80/100; jest 22/22; AND `compileDebugKotlin` OK. Missing: device run (blocked by pin split), iOS build (later Release OK, L2324), README. **Pin split finding (L2252):** FL AND build fails: `CYLTabBarStyle.kt` at FL pin `08343e9f` imports `CYLGlassHighlight` absent from `cylanimateditem` at AND pin `af56db22`; aligning FL pin gives other unresolved refs. RN AND expected same (not run). Incident: `restart-emulators.ps1 -Force` killed another session's emulator-5558 (L2253).
- **L2257 I8:** CI stuck because queued macOS jobs never got a runner and `cancel-in-progress: false` held the concurrency group; cancelled run 45745662592. TODO timeout/cleanup, check runner minutes. 10 iOS labels fixed; 4 AND remained at that moment.
- **L2275 + L2298-2304 I3 DONE 100:** page now `CYLSearchPageView` with autoresizing and relayout; 154/0. Untested: real rotation/iPad split.
- **L2289 MP `cancelTitle`/`clearIconImage`** drawn (bar's own `cancelButtonTitle` wins); npm 174/174; 75/100 (DevTools unchecked).
- **L2306 TODO one pin pair everywhere.** Split: iOS/FL/MP TabBar `08343e9f`, AND `af56db22`, HOS `d19e138e`. Owner decided to wait for a newer TabBar commit and repin once. CVCM `c0b183de` does **not** compile against `dd691795` (missing `CYLAnimatedItemCornerRadiusCapsule`, `isAnimationEngineAvailable` override errors). **Frozen TabBar pin `d5f1b436e112fb88761d99177f294e2155be98ea`; waiting for CVCM SHA** (L2330-2332; CVCM PR #42 branch `fix/shared-contrast-ios`). **Owner rule (11-27): integrators check compiling only; no full suites, no CI waiting.** RN iOS `goBack` Release build OK; Debug link fails (RN debug symbols like `Props::getDebugProps()`), uninvestigated. Old vendor copy preserved as `example/vendor/CYLTabBarController.bak-20261127`.
- **L2334 I2 DONE 100:** results VC now gets `begin/endAppearanceTransition` (no containment; containment/trait propagation still missing). 156/0 (latest full iOS count in log).
- **L2357 TODO first-level bar not full width on AND + parity to 100** (2026-11-27). Parity at start: AND 98 (8 TODO), HOS 99 (4), MP 97 (10); FL/RN have no table. Compile checks only. Acceptance 100/60 at L2362. Also open decision: `dismissesKeyboardOnOutsideTouch`. Status "started" (stale vs git, section 5).
- **L2366 I6 iOS side DONE:** FL iOS bridge reads `searchButtonImage` (asset key; empty keeps magnifier; `cylFlutterAssetImage(_:displayScale:)`). TODO Dart param (Windows), RN spec prop then `CylsearchBarView.mm`.

---

## 2. Cross-entry summary

### 2.1 Decisions / rules still in force (latest version)

**Process**
- Log in docs as TODO with context, requirements, verbatim + English prompt before work; acceptance 100 and 60; keep going until pass; report missing points as TODOs; mark DONE with evidence (L8, L364). Read behavioral.md in full (L971-997) and git.md before any git op (L1000).
- Check other sessions first; Mac takes iOS, Windows takes everything else (owner order quoted L1307-1308; also L1481, L1637).
- git cz, English only (L322); non-master/main: commit+push without asking; every committed branch needs an open PR; >2 open PRs ask (L343-361).
- Latest verification rule: **compile checks only, no full suites, no CI waiting** for integrators (L2322, L2361-2363, L2372-2375). This overrides the earlier "run everything" acceptance style for that period.
- Simulators/emulators: restart hung ones from CLI without asking, tell sessions; terminate app and stop device after runs, only your own (L364, L1744). Shared Windows lock `C:/w/heavy.lock`.
- Screenshots: header+footer via stitch tools, in `docs/assets`, linked on a line with date+commit; never fabricate metadata ("not recorded") (L399-455, L490, L1245). Check CI-equivalent range: `sh scripts/check-screenshot-labels.sh $(git merge-base origin/master HEAD) HEAD`.
- Scripts run with bash; accessibility + localization everywhere; UI tests locate via labels/ids (L305, L331). en, ja, zh-Hans, zh-Hant from iOS files (L1406). "Into the core" = localized text + bundled icons.
- Translated third-party code: handle upstream open PRs/issues (L88).

**Architecture / UX**
- Fix in the core first; examples call core API; no duplicate implementations (L822-837, L1855).
- **No system search bar** anywhere; one field = `CYLSearchBarView` + navigation field preset (L1878, L1904). Tag UI = CVCM `CYLTagListView` (L832).
- Default suggestion style tags, folded 2 rows (L920); **demo** tag lists: sections, wrapping titles, 3 visible rows, **tail fold tag icon only**, tap = cell tap, long press = callout, glass board + glass tags over gradient page with clear list background (L1624, L1661, L1674). No hacks around missing core capability; list gaps.
- Corner radius is a plain number: 0 square, 1000 capsule (L1419-1443).
- Tint: built-in defaults; bar sets no tint; host value overrides (L1603-1612).
- Default search button always present in examples, exactly one per bar (examples drop own Search item), **icon default**, text opt-in (only remark name field), concentric 4 pt gaps (L1552, L2037, L2067-2070).
- Trailing group: field flexible, items hug, only container spacing 8, 36 pt touch (L2044).
- `focusesOnAppear`: only second-level or deeper page (L2008-2023); empty search tap on `CYLSearchView` page does nothing, keeps keyboard (L2013-2019).
- First-level pages: whole bar per tab with own preset; tap pushes, never focuses; iOS keeps system back button (L2025-2031).
- Discover is always second-level with back button; bar embedded in a navigation bar (L1427, L1434).
- Pins: pinned by commit on all platforms; TabBar commit must equal what CVCM vendors/pins; all `cylanimateditem*` modules from one commit (L602, L754, L1459).
- Selected tag stays glass tint 1 (L1474). x86 debug guard removal needs owner's own approval (L907, L1467). `CYLTabBarController` bugs get fixed upstream, not in examples.

### 2.2 Pin history (CVCM / TabBar), chronological
c006143 TabBar (L230) → 41660d24/cf478388, PH c84fce9 (L570) → ace1af0e/1f8c1001 (L586) → PH a169386 (L611) → CVCM 881476a, PH c473fdc (L627) → 618ac11a/9dc1f761/PH 6117fcf (L751) → 882ece17/405bf498/PH f4cf978 (L876; **PH f4cf9785 still current**) → c8fee654/111c73aa (L1045) → c4a1f8fd/04b39e26 (L1064) → HOS-only f51057a7/e474f469 (L1172), a5e4434c/14b6b955 (L1340) → f66e85d5, 9c8cf475 (L1265-1365) → f45a8f1d (L1382) → c6b3e976/4be6cda (L1440) → b4299707/551072a (L1446) → 235f6e96/8cd4efa → 11fc94be/755aa30 → ca04a77 (L1538-1540) → 570fc657+5a212de9 (L1576) → 3ed13b9+5a212de9 (L1599) → 230b5266/603592b (L1541, L1610: this pair replaced 3ed13b9+5a212de9) → 05ba8abb (L1632) → 09bde3ca/0de4546b (L1672) → 6f563ef4/22c9f5ca (L1779) → 08343e9f/6a2fbf25 (L1790) → 1207883c (L1798) → **c0b183de (L1829, current CVCM)** → platform-specific TabBar d19e138e (L2140, L2152), AND af56db22 (L2180) → frozen target d5f1b436 not yet applied (L2330). Order within 11-25 is partly ambiguous because entries are not strictly chronological. Dealloc: c85c10c0 → 4276a6da → 775fc2f6 → **eab21d10** (L1985).

### 2.3 Latest claimed test baselines (not verified by me)
iOS 156/0 (L2353; simulator iPhone Air iOS 26.1). AND `CYLSearch*` subsets; `:cylsearch` ~114-146 (146/0 on Mac L1555; on Windows the 10 `CYLSearchViewQMUIPortTest` failures recur in full runs). FL plugin 44/44 (L2202). RN jest 22/22 (L2251). MP npm 174/174 (L2295). HOS host 110 (L2105), emulator 57/57 (L2085, L2106).

### 2.4 Recurring gotchas
- **CI queue blocking:** `cancel-in-progress: false`; pushes replace pending runs; queued macOS jobs can block for hours (L1042, L1461, L1496, L2194, L2262).
- **Xcode version skew:** CI Xcode 26.6 stricter than local 27 (L706); older-runtime timing flakes: testB7 (L1015, L1229), `testShowDuringCloseKeepsTheViewOnScreen`, `testDelegateLifecycleOrder` (L1117), `testI2PlainBarInAnExtendedViewStaysInPlace` (L1449).
- **Podfile.lock** edits belong to Mac (`pod install`).
- **Pin/vendor drift:** git-ignored vendor folders keep old commits (RN `example/vendor`, HOS mirror, MP `sync-example` output); `CYL_*_DIR` copies working tree; MP pin guard test fails when CVCM's shipped `cyl-animated-item/COMMIT` differs.
- **Windows:** robocopy from Git Bash silent failure (L776); 260-char paths (L582, L2129); stray `\r` broke sync script (L1576); stale `oh_modules` (L1817); stale Kotlin incremental cache gives false unresolved refs (L1539, L774, L1792) → clean/`--rerun`; JDK 17 for Robolectric (L1535).
- **Robolectric SQLite** "Illegal connection pointer" / leftover views, order dependent (L1058, L1619, L1653).
- **HOS:** ASCII mirror `C:\cylbuild\harmonyos`; x86_64 needs `entry@emulator` + `emulatorTest`; `aa test` timeout 40000; glass tags have no uitest text; large tag lists freeze (chunk); uitest swipe from edge opens dock; stale `uitest dumpLayout`.
- **MP DevTools:** AppID dance, sync-example first, no dark toggle, element taps skip hit testing, `page-container` not automatable.
- **Flutter platform views:** updates before creation dropped; layout before window/transition finished mis-places nav bar; native glass cannot sample Flutter-drawn backdrop.
- **RN Fabric** recycles native views: reset state in `updateProps`.
- **iOS:** unit tests can pass while real gestures fail (swipe-back L2029); XCTest cannot create UITouch / edge touch.
- **Measurement honesty:** one earlier "201 pass" predated the final edit (L1638); static-only entries are marked DONE without device runs (L1975, L1998, L2067, L2096).
- Disk/lock etiquette: don't force another session's lock or emulator (incident L2253; emulator-5556 left alone).

---

## 3. Open TODOs / unfinished work (as of the end of the log; later entries checked where noted)

### 3.1 Open, no later closure found in this log
**Newest (top priority)**
1. One pin pair everywhere: TabBar frozen `d5f1b436` + a CVCM commit built on it (awaited); then repin all, compile iOS examples (L2306-2332). Blocks FL AND (and likely RN AND) builds (L2252).
2. RN iOS **Debug** link failure (L2325-2329).
3. L2357: AND first-level bar full width, parity tables to 100, FL/RN scorecards, I6 (see section 5: partly committed afterwards).
4. I6: Dart parameter and RN TS prop + `CylsearchBarView.mm` for `searchButtonImage` (L2380-2382).
5. `goBack()`: device run of reverse animation; README entry (owner rule) (L2255).
6. FL Discover tag fix: emulator verification (L2206). MP cancelTitle/clear icon: DevTools check (L2296).
7. CI: protect against long-queued macOS jobs; check runner minutes (L2266).
8. I2 follow-up: results VC containment/trait propagation absent (L2354). I1/I3 not tested on devices, cancelled pop, real rotation/iPad (L2237, L2304).
9. Other bugs (I4, I5-numbered handover items etc.) live in the handover doc, which is outside this assignment; this log only reports I1, I2, I3, I6, I7, I8.

**Tab bar / dark mode**
10. HOS fill-based SVG tint + dark flat bar background (upstream) (L2158-2160); AND dark bar background = owner decision (L2184); SVGA playback/variant not re-measured (L2177, L2184).
11. RN AND DEFECT 2 (uneven trailing gaps) and 3 (light tab bar, invisible plus label) (L2132-2133); AND example tab bar light in dark (L1655, L2144). RN AND CI + vendor-pin check (L2136).

**Search bar / first level / focus**
12. Device checks: real touches (tag tap/drag hides keyboard), return from background (L1954, L2033); AND/FL/RN trailing group, 36 dp touch, TalkBack (L2073); HOS edge swipe-back, recording, tap beside camera, remark-field text-style screenshot, TalkBack, arm64 (L2087, L2107-2108); MP dark mode, real pointer tap, pill outline comparison (L2124-2125); FL predictive back, RN AND other tabs/release/arm64 (L2060, L2135).
13. Owner decisions: empty tap on Discover second-level (placeholder search vs nothing) (L2057; HOS note says by design L2081; RN same L2130); extra magnifier/Overlay actions beside tab bars (L2055; settled for AND by commit d958f73 per section 5); `dismissesKeyboardOnOutsideTouch` parity (L2359); AND plus-tab not a first-level bar (L2055).
14. HOS/MP: Examples-menu pushed pages keep in-page bars; Overlay/Repro only on pushed page; round black text-item look (L1984). READMEs lack new API (L2006).
15. Move off Dealloc-independent focus moments: AND/HOS/MP to adopt Dealloc on-screen events once shipped (L1930, L1942). Dealloc PRs #30 then #29 must merge so pins name a master commit (L1985).
16. No system search bar: AND facades / replica port looks (L1884, L1901).

**Glass / tag lists / tint**
17. FL, RN: no backdrop parameter; HOS/MP no backdrop sampling property (L1691-1697, L1794). AND refraction unproven (L1800). HOS gradient light only, HOS Examples rows lack subtitles; MP subtitles empty; run DevTools/hvigor (L1763-1774; partly superseded by later HOS builds).
18. MP: `cyl-tag-list` 0.2.0 migration for grouped lists (L1659; later converted L1754, runtime unverified then). RN/MP Examples-as-tag-list converted L1754.
19. L1523 acceptance (HOT ~20 dp, glass visible on FL-AND) never formally closed; Dart/TS and library parity items inside it.
20. iOS: converting examples menu/styles screen/samples list only on owner's word (L1742). Topic grid glass board awaits owner decision (L1545). "Hold to ask" opaque curve (L1742). Plus button title dim gray (L685, L1613). Library default tint follow-up on AND/HOS/MP grays (L1578).
21. Icon-contrast lift on FL/RN/MP bridges lack icon color parameter (L1784).
22. QMUI merge phase 6 in CVCM; MP device test (L852-854, L920 TODOs: AND 5 px row cut). iOS 15-16, 18-25 unverified (L747).

**Pins / PH**
23. L960: move PH pin past Swift rename (`0c8961f`); PH still `f4cf978` (section 5).

**Discover / localization**
24. L1369 animation demo rule on AND/HOS/MP/FL/RN verification (L1376); L1392/L1397 core layout + header on AND; L1403/L1411 AND/HOS/MP; L1419 RN tab page texts + FL tab titles English, CVCM other platforms; L1425/L1432 AND/HOS/MP refresh data, back button, RN AND setters. (Some may be satisfied by later Windows work, but the log never closes these headings.)

**Animation engines**
25. MP engine switch (L1297-1302); Lottie/PAG/Rive/GIF never seen playing on HOS (L1154, L1192, L1458); 7 HOS UI failures at L1186 (later suites show 57/57, so apparently resolved, never stated for those 7); AND emulator check (L1303). iOS board rows leftovers: pin and 10 points (L1324-1326, L1521).
26. Plan 1 arm64 Rive/PAG: 60/100, debug guard removal needs owner approval (L916, L1467). CYLTabBar S100 renames upstream (L874).

**Owner/phone-only**
27. MP back-gesture on non-tab page (L276-286, L551-552), MP keyboard placeholder, phone tab-switch retest (L555, L1468). npm publishing waits for user (L289).
28. Apply third-party PR/issue rule to five AND transcriptions (L112). SVGA tab icons in RN example (L139; RN SVGA iOS done L466, so probably closed). Raised plus on iOS 26 Liquid Glass with title (L166-170; user skipped L181; iOS later raised L675 with gray title).
29. Release RAM: macOS section stub; HOS part and app-closing/explorer/brightness not live-tested at L2063 (explorer + emulators run L2065).
30. L1478 Windows batch (Gradle/hvigor/DevTools after parity classes): much was run later (L1538+, L1650+, L2075, L2111), but entry never closed. L1727-1730 repin TODOs: AND shots and HOS hvigor later done; MP COMMIT mismatch resolved at 22c9f5ca (L1545, L1785).

### 3.2 Other headings / status lines that read open (disposition per the log)
- L120: DONE; its progress notes mention then-blocked items, left outside: RN SVGA tab icons (L139).
- L822: TODO heading; still open (phase 6, MP device test, L852-854).
- L856: "DONE (rules) / TODO (code)" heading; the code rename is DONE at L875; TabBar renames stay upstream (L874).
- L903: TODO heading; status 60/100 (L916), open (item 26).
- L1133: TODO heading; status L1154 DONE for HOS only, not scored 100 (only SVGA seen playing).
- L1079: DONE 100; "TODO" is only in its title.
- L1284: TODO heading; AND and HOS done, **MP open** (L1297-1302); iOS part was assigned to Mac (L1303; related L1305).
- L1305: TODO heading, PARTLY DONE 85 (L1314); L1518-1520 later claims the test, no-reload check and analyze; the pin-move item is superseded by later repins as far as the log shows, never formally closed.
- L1379: IN PROGRESS (`f45a8f1d` pin); **superseded** by later repins (L1439 onward), never closed.
- L1451: TODO heading; the hand-over itself is DONE (L1469), "the items above stay open" (several handled later: iOS suite at newer pins; others have no recorded closure).
- L1471: owner pin decision, **Status TODO (L1477)**; its follow-ups (repin batch, `.clear` glass fill at L1536) happened and the pair was superseded by later repins (L1779, L1829); the dark selected-tag screenshot/contrast is only partly recorded (L1563, label text fix). Never closed.
- L1507: TODO heading, 90/100 (L1518); glass recheck done in later batches (L1542); no closing line.
- L1855: TODO heading; delivered on iOS by L1862; other platforms continued under L1878.
- L1878: TODO heading, status "platform work below" (L1883); iOS done L1904, others preset/examples L1885-1903; never closed.
- L1921: TODO heading, status "in progress" (L1927); implemented across L1928-1945 and L2008-2023; background-return device check open.
- L1959: TODO heading; AND/FL/RN implemented, device check at L2051; never closed.
- L2192: heading DONE; status line begins "started" but ends 85/100 (L2200).
- L2275: heading DONE; L2287 "not started" is stale (see section 0, item 2).

---

## 4. Contradictions and supersessions

| # | Earlier / one side | Later / other side | Note |
|---|---|---|---|
| 1 | L639-643: pins 881476a/c473fdc verified, HOS 29/29 | L776-779: that HOS run used a stale mirror | HOS claim of L627 invalid |
| 2 | L740: no rule gives other platforms to Windows | L1307-1308, L1481, L1637 (owner: iOS on Mac, rest on Windows); AGENTS.md now says Mac iOS / Win others | newer wins |
| 3 | L187-191 HOS needs signing | L213-216 unsigned HAP installs | superseded |
| 4 | L456-463 label workflow removed at owner prompt | L469-475 owner says accidental, restored | restored; present today |
| 5 | L502 relabel of 269 old images not done | L1245 done (202 images) | superseded |
| 6 | L1106-1107 Podfile.lock uncommitted on purpose | L1222 committed | superseded |
| 7 | L1924 focus on every reappearance | L1931/L1938/L1955/L1986 back-button filter | L2008-2023 depth rule (L2013 interim: Windows still on filter) |
| 8 | L1948 search button default text; L1973 Discover text | L2037-2042 icon default; L2040 Dart/TS still "text" | fixed L2069 |
| 9 | L1629/L1646 fold shows icon+title | L1642-1649, L1661 icon only | superseded |
| 10 | L1409 radius 0 = capsule | L1422, L1441 0 = square, 1000 = capsule | superseded |
| 11 | L1884/L1901 TODO: AND classes wrapping system search widgets | L1902 Windows: AND and MP wrap none | unresolved in log |
| 12 | L2204 ten iOS label failures remain | L2268-2271 Mac fixed them; "only 4 Android" remain, which L2204 says Windows had fixed | timing/merge order; both claim the other's leftovers |
| 13 | L2255 RN iOS goBack build missing | L2324 Release build succeeded (Debug fails) | superseded |
| 14 | L916 plan 1 at 60/100, guard needs approval | L1068 peer: Rive+PAG OK on x86; L1467 peer says approved, unseen | do not treat as approved |
| 15 | L2275 heading DONE | L2287 "work not started" | misplaced result L2298-2304 |
| 16 | L1542 heading/bullet says TODO etc. | bodies say DONE | headings unreliable throughout (L1542-1556) |
| 17 | L1532 no glass drawn on AND; L1594 iOS-only statements | L1796-1800 AND blur works with backdropSource at 1207883c | superseded |
| 18 | L1535 known failing test embeddedBarAsksForTheWholeWidth... | L1540 passes | resolved |
| 19 | L1585 camera icon open; L1593 "title" tint did not work | L1599 title tint works with new pins; L1610 bar sets no tint | superseded |
| 20 | L1603-1608 status TODO waiting for library | L1610-1613 shipped, DONE iOS | stale status |
| 21 | L1696/L1764 MP lists not using cyl-tag-list | L1754 converted | superseded |
| 22 | L2055 extra tab actions allowed/owner decision | commit d958f73 removes them on tab roots | see section 5 |
| 23 | L2322 acceptance "suite passes" | L2322-2323 changed to compile only | owner rule |
| 24 | AGENTS.md "Task workflow" entry format uses TODO heading then DONE | log has many headings never updated | process drift |
| 25 | L1634-1639 "201 tests pass for 35bb62a" | L1638 correction: measured before final edit | re-run claimed |
| 26 | L584 etc: suite counts vary by repo | L1803 notes ClassifyMenu's 258/292/188 are not this repo's | requested counts mismatched |
| 27 | L2266 TODO add timeout-minutes to macOS jobs | ios.yml already has job `timeout-minutes` (section 5) | such timeouts normally limit run time, not queue wait (my understanding, not verified), so they would not fix L2262 |
| 28 | `AGENTS.md:78` and `instructions.md:78`: the search core is `CYLSearchBar` (iOS `Sources/CYLSearchBar`, "the same classes on every platform") | L1907: the iOS `CYLSearchBar` class is deleted; my git grep over `Sources` finds no `class CYLSearchBar` | doc vs code; the folder name still exists |
| 29 | `instructions.md:4`: the repo has a reproduction for `UISearchController` | L1904-1909: no system search bar left on iOS; my grep over `Sources` and `CYLSearchExample` found no match | doc vs code |
| 30 | L2364: "Status: started 2026-11-27" | commit `d958f73` **message claims** the AND tab-root full width, API table 98 to 100 and "settles open decision 3" | code history newer than the log; I did not verify the claim in code |

---

## 5. What I checked myself (targeted, read-only, 2026-11-29 session)

- **Git head:** `ad32984` (2026-11-28 00:13 +13:00), after `79db668` and `d958f73`. Working tree has uncommitted changes in `docs/harmonyos-api-alignment.md`, `harmonyos/cylsearch/src/main/ets/CYLSearchBarView.ets`, `scripts/harmonyos-api-alignment.py`, `CrossPlatform/flutter_cylsearch/example/pubspec.lock` (4 files, +94/−8) plus three untracked MP `index.wxss` files. I did not read the diffs, so whose work or what stage they are is unknown.
- **L2357 lags git:** commit `d958f73` (2026-11-27) message claims: tab roots with a first-level bar show no toolbar actions ("settles open decision 3"), adds AND `CYLSearchBarPreset`/`applyPreset` and outside-touch dismissal, AND API table 98→100, compile checks only. It added 9 lines to the log (the diffstat), apparently the TODO entry itself; the log still says "started". HOS/MP/FL/RN completion of that task is not established. Commit `115ef09` regenerated the four API tables.
- **Pins today match the split of L2308-2309:** TabBar `08343e9f` in root and FL iOS Podfiles, FL `pubspec.yaml:23`, MP `package.json:34`; AND `gradle.properties:8` `af56db22`; HOS `oh-package.json5:5` `d19e138e`. CVCM `c0b183de` and PH `f4cf978` wherever matched. Dealloc `eab21d10` in root, FL and RN iOS Podfiles. `d5f1b436` not applied in the matched manifests.
- **No `UISearchBar`/`UISearchController` word matches** in `Sources` or `CYLSearchExample` (git grep), and no `class CYLSearchBar`; `CYLSearchBarView` at `Sources/CYLSearchBar/CYLSearchBarView.swift:251`. Consistent with L1904-1909.
- `isOnSecondLevelOrDeeperPage` is at `CYLSearchBarView.swift:1697` and gates focus at :1732; no `isInNavigationBarWithBackButton` match, so the depth rule (L2010) replaced the L1986 filter.
- `searchButtonImage` matches exist in iOS core, FL iOS Swift plugin, AND core, HOS core/host test, MP; **none in Dart, TS/TSX or .mm**, consistent with the L2380 TODO.
- `AGENTS.md:78` and `instructions.md:78` still name the search core "`CYLSearchBar` (iOS `Sources/CYLSearchBar`; the same classes...)": the directory name remains but the iOS class of that name is deleted. `instructions.md:4` still describes a `UISearchController` reproduction.
- `.github/workflows/` holds `ios.yml` and `screenshot-labels.yml`; `ios.yml:23` `cancel-in-progress: false`; job `timeout-minutes` already present at lines 32, 58, 67, 79, 107, 185, 210.
- `docs/todo/20261104/` holds exactly the one handover file.

## Coverage

| Assigned file | Line count | Lines read | Skipped / unread |
|---|---|---|---|
| `docs/task-log.md` | 2382 (`wc -l`; 430,685 bytes) | 1-2382, all. Loaded with the Read tool in 24 offset/limit pages of 100 lines (Read reports a 2383rd, empty line); reassembled byte length equals file size; longest line 3,039 chars; displayed to me in 16 contiguous chunks (1-293 ... 2309-2383) with no truncation marker | None. Linked documents, screenshots and the handover file were not read |

Targeted checks (not full reads): git log/diff --stat/show --stat, git grep over Sources, CYLSearchExample, pin manifests, workflows, AGENTS.md, instructions.md; directory listings; size/line count of the log. Section 5 states their limits.
