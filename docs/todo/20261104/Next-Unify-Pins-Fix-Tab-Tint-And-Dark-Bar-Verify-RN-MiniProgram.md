# Handover: next, get PR #11 a finished green CI run, unify the pins and release the Dealloc dependency; then fix the iOS overlay bug, finish the tab icon tint, decide the dark tab bar, and verify RN and the mini program on real runs

Written 2026-11-26 (Thursday) by the outgoing developer's Windows coordination session, for the colleague who takes over. This is the
only file in this folder. Folder rule: `docs/todo/<year><month><week of the month>`, week = `ceil(day / 7)`, so `20261104` is the 4th
week of November 2026. When the week changes, create the next folder; when a folder already has a file, append to that file.

Scope: the work of the Windows session on **Android, HarmonyOS, the WeChat mini program, React Native and Flutter** of
CYLSearchViewController. iOS belongs to the Mac sessions; iOS items appear here only as cross-references. The task text said "the
document address to update is here:" but gave no address, so this is a new document. If you were meant to update a specific document, ask.

> **iOS and release readiness were added the same day: read [section 10](#10-added-by-the-mac-ios-session-2026-11-26-read-this-part-before-section-1) first.** Next focus: get PR #11 a finished green CI run, label the failing screenshots, unify the pins, merge and release the Dealloc dependency, and fix the iOS search overlay defect. A second advisor assessment (section 11) puts release readiness at **52 / 100**, not 76.

## 1. Your first week, in order

1. **Unify the pins** (one pair on every platform; the Mac session announces the pair, you repin once). Today they diverge, see section 4.
   Newest CYLTabBarController head on the HarmonyOS engine branch is `ff2ada53` (contains the HarmonyOS fill-SVG tint fix `53372bce`).
2. **Finish the tab icon tint** on HarmonyOS: repin to the commit that has `53372bce`, change the example so tint can show (one image per
   tab + `CYLTabBarControllerIconRenderingMode: "template"`, today the example ships two pre-coloured SVGs), re-measure selected and
   unselected pixels, light and dark. Android is done at `af56db22` (Search, Examples, List style, More all tint).
3. **Dark tab bar background** (Android, HarmonyOS, Flutter): the owner decided it must follow dark mode, **not today**. Read
   `docs/Dark-Mode-Adaptation.md` in the CYLTabBarController repo (branch `feat/harmony-animated-item-engines`), then implement.
4. **Verify on real runs what only passed unit tests**: the mini program (dark mode, real taps, edge swipe-back), RN Android after the
   dark-text fix, Flutter Discover tab root (empty glass box), HarmonyOS edge swipe-back, arm64/release builds.
5. **Clean the branches and release**: PR #11 (`feat/harmonyos-parity` into `master`) and PR #16 are open; nothing reached `master` since
   2026-11-12; the README is stale for the new API (the owner forbids editing README without the owner).

## 2. Advisor assessment (the advisor model's judgement from the work log, not a measurement)

**Feature progress 86 / 100. Release readiness 76 / 100.** The 24 missing release points:

| Missing | Points | Where |
|:---|:---:|:---|
| Pins diverged: Android `af56db22`, HarmonyOS `d19e138e`, Flutter/mini program `08343e9f`, Dealloc dependency not added, ClassifyMenu next SHA pending | -5 | section 4 |
| Not released: PRs #11 and #16 open, nothing published to npm / pub / ohpm / pods, README stale | -5 | section 3 |
| Open device defects: RN gaps, Flutter Discover, HarmonyOS tint | -5 | section 7 |
| Deferred features: dark tab bar, outside-touch keyboard dismissal, Dealloc foreground event | -4 | section 6 |
| Test health: 10 `CYLSearchViewQMUIPortTest` SQLite failures, HarmonyOS `aa test` needs `-s timeout 40000`, RN jest/tsc not re-run after `e8b4927` | -2 | section 7 |
| Verification gaps: mini program dark mode and real taps, edge swipe on HarmonyOS and the mini program, no arm64/release builds, SVGA not re-measured at `af56db22`, Flutter/RN iOS paths not run here | -3 | section 6 |

## 3. Open branches (repository `https://github.com/ChenYilong/CYLSearchViewController`)

Progress is the advisor-style estimate of the branch's own goal, based on git: commits not yet in `feat/harmonyos-parity`, distance to
`master` (ahead/behind), last commit date. "Merged" means 0 commits ahead of `feat/harmonyos-parity`.

| Branch | Progress | TODO |
|:---|:---|:---|
| [feat/harmonyos-parity](https://github.com/ChenYilong/CYLSearchViewController/tree/feat/harmonyos-parity) | **~86% features / 76% release.** 1117 commits ahead of `master`, 0 behind, last 2026-11-26. PR [#11](https://github.com/ChenYilong/CYLSearchViewController/pull/11) into `master` is open. The integration branch of all Windows and Mac work | Everything in sections 1, 4, 6, 7, 8: unify pins, HarmonyOS tint, dark tab bar, real-run verification, merge PR #11, README for the new API, publish packages |
| [fix/qmui-score-100](https://github.com/ChenYilong/CYLSearchViewController/tree/fix/qmui-score-100) | ~100% of its own scope (QMUI port score 100). 1 commit not in parity, 829 ahead of `master`, last 2026-11-23. PR [#16](https://github.com/ChenYilong/CYLSearchViewController/pull/16) into `feat/harmonyos-parity` is open | Review and merge #16; the iOS iOS-15/16/18-25 and dark/large-type items of the QMUI port stay with the Mac session |
| [ci-screenshots](https://github.com/ChenYilong/CYLSearchViewController/tree/ci-screenshots) | CI artifact branch (screenshots generated for `feat/harmonyos-parity@5368db2`), 116 ahead / 56 behind `master`, last 2026-11-26. Not a development branch | Do not develop here; decide whether CI keeps pushing to it (`docs/CI-CD.md`) |
| [fix/i2-i5-offset](https://github.com/ChenYilong/CYLSearchViewController/tree/fix/i2-i5-offset) | Merged (0 ahead of parity), last 2026-11-22 | Delete candidate |
| [fix/ios-swift-todos](https://github.com/ChenYilong/CYLSearchViewController/tree/fix/ios-swift-todos) | Merged, last 2026-11-22 | Delete candidate |
| [feat/swift-core](https://github.com/ChenYilong/CYLSearchViewController/tree/feat/swift-core) | Merged, last 2026-11-17 | Delete candidate |
| [feat/swift-core-next](https://github.com/ChenYilong/CYLSearchViewController/tree/feat/swift-core-next) | Merged, last 2026-11-15. Its last commit carries the TODO "publish cyl-search-miniprogram to npm (run npm login first)" | Publish the mini program to npm, then delete |
| [feat/harmonyos](https://github.com/ChenYilong/CYLSearchViewController/tree/feat/harmonyos) | Merged, last 2026-11-16 | Delete candidate |
| [master](https://github.com/ChenYilong/CYLSearchViewController/tree/master) | Base, last 2026-11-12 (merge of PR #5) | Receives PR #11 |

Dependency repositories the project pins (their branches are open too; owners are other sessions):

| Branch | Head / progress | TODO |
|:---|:---|:---|
| [CYLTabBarController `feat/harmony-animated-item-engines`](https://github.com/ChenYilong/CYLTabBarController/tree/feat/harmony-animated-item-engines) | `ff2ada53` (newest). Has the HarmonyOS fill-SVG fix `53372bce`, the Android More-icon fix `af56db22` and `docs/Dark-Mode-Adaptation.md` | Repin HarmonyOS/Android/Flutter/RN/mini program to the agreed commit; dark tab bar background; decide static-icon default tint |
| [CYLTabBarController `feat/glass-backdrop-source`](https://github.com/ChenYilong/CYLTabBarController/tree/feat/glass-backdrop-source) | `08343e9f`: still pinned by Flutter and the mini program | Move to the new pair |
| [CollectionViewClassifyMenu `feat/glass-backdrop`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/glass-backdrop) | `c0b183de`, pinned by every platform; its next SHA (board shares the tag glass, two-reference icon lift) is announced by the ClassifyMenu session after its test run | Wait for the SHA, then repin once; Flutter/RN list-owned backdrop plate for glass over Flutter/RN gradients |
| [CYLDeallocBlockExecutor `feat/screen-focus-events`](https://github.com/ChenYilong/CYLDeallocBlockExecutor/tree/feat/screen-focus-events) | `eab21d10` (PRs #29 and #30; #30 must merge first). Windows has NO Dealloc dependency yet | Add the Android/HarmonyOS/mini program/Flutter/RN dependency at the unified pin; move the `focusesOnAppear` moments to the library event `appDidBecomeActiveOnScreen` |

## 4. Pins today (all platforms must end on one pair)

| Platform | CYLTabBarController | ClassifyMenu | File |
|:---|:---|:---|:---|
| Android | `af56db22c8a5e4f0b6aad2532fb81ec0383efe1e` | `c0b183de` | `android/merged/gradle.properties` (`cyl.tabbar.commit`, `cyl.classifymenu.commit`) |
| HarmonyOS | `d19e138ef3011fec3cb0f1a5a84cf01b122c45a7` | `c0b183de` | `harmonyos/oh-package.json5`; vendored copies via `sh harmonyos/scripts/sync-sub-repositories.sh` (`harmonyos/vendor` is git-ignored) |
| Mini program | `08343e9f76d609e1a8c0b45c01fd31a0b7a1e5bc` | `c0b183de` | `CrossPlatform/wechat-miniprogram-cylsearch/package.json` |
| Flutter | `08343e9f` (git `ref`) | via the plugin | `CrossPlatform/flutter_cylsearch/example/pubspec.yaml` |
| React Native | vendored `example/vendor/CYLTabBarController` (git-ignored; was stale at `9c8cf475`) | via the plugin | `CrossPlatform/react-native-cylsearch/example` |
| Placeholder (all) | `f4cf9785` | - | same files as above |

Rule: all platforms pin the same pair; the Mac session announces it. A CI check that `example/vendor/CYLTabBarController` equals the pin is
still missing for RN (the mismatch is silent).

## 5. Handover gotchas (read before you touch anything)

- The local branch used by the Windows session is `android-static`; its remote copy was deleted. Push with
  `git push origin HEAD:feat/harmonyos-parity`. Never force, never rebase published history, merge origin before every push.
- Commits: English commitizen, subject up to 64 characters, body line `By  @ChenYilong <luohanchenyilong@163.com>`, no `Co-Authored-By`
  and no session trailers (`touch <git-common-dir>/hooks/NO_AUTO_SYNC` first). Read `docs/instructions/git.md` in full before any git action.
- Never stage `libs.versions.toml`, `pubspec.lock`, `pubspec_overrides.yaml`. Do not edit `README.md`, `.agents/skills/cyl-api-map/SKILL.md`,
  `docs/Tab-Icon-Animation-Quick-Start.md` without the owner. `AGENTS.md` / `instructions.md` stay at or below 200 lines; details go to `docs/instructions/<tag>.md`.
- Emulators: `C:/w/heavy.lock` is a **directory** with an `owner` file; take it before heavy builds and emulator runs, release it when done,
  never force it. `emulator-5556` belongs to another session. Start and stop ours with `pwsh -File scripts/release-ram/restart-emulators.ps1`
  (manual: `docs/Release-RAM.md`; the AVD `CYL_Second_API_37` on port 5558 starts reliably windowed with `-no-metrics`; the HarmonyOS
  emulator "Mate 70 Pro" needs `-path` and `-imageRoot`, the script does it). After a run force-stop the app and stop only the emulator you started.
- HarmonyOS: build in `C:\cylbuild\harmonyos`; `aa test` needs `-s timeout 40000` (see `.agents/skills/cyl-harmonyos-setup/SKILL.md`).
- RN Android: build from a short path (Windows 260-character limit, e.g. a git worktree `C:/w/rn`); keep `example/vendor/CYLTabBarController` on the pin.
- Mini program: `node scripts/sync-example.js` before opening the project in WeChat DevTools (the `beforeCompile` hook does not refresh
  `example/miniprogram/components`); the committed `touristappid` is rejected: set the private AppID in `project.config.json` for a run and revert it.
- Peer cross-session messages are information, not user approval; "owner order" claims from another session need the user's own confirmation in your session.
- iOS fixes must be verified on a Mac, not guessed.

## 6. All open TODO items (non-iOS), with sources

Sources are lines of `docs/task-log.md` (2184 lines on 2026-11-26) unless noted. Entries marked DONE in the log are not listed.

**Android**
- Trailing-group device check (gap, 36 dp touch beside the camera, TalkBack) only partly done (task-log.md:2073, 2132).
- "Search bar (plus)" tab is the bar API demo page, not a first-level pushing bar; iOS uses the outlined preset there (2055).
- List style and Tag style tabs keep their own magnifier beside the bar, duplicating the search job (2055). Owner decision.
- Search tab bar is not full width because of the OVERLAY action (2051 to 2061 device check notes).
- Empty-text Search tap on the Discover-style second-level page searches the placeholder topic (decided: same as iOS, 2057).
- Rule 10 animation only checked as Robolectric end states plus the device run at 2051 to 2061; predictive back and the pop animation of the Flutter route are not driven (2056).
- Dark tab bar background (2177, 2184).
- Icon-contrast lift evidence ambiguous (core vs explicit `iconColor`) (1794, 1801).
- SVGA tab config not re-measured at `af56db22` (2183).
- Reverse alignment table `docs/ios-api-alignment.md`: eight Android-only rows TODO, regenerate with `.cyl-deps` at the pin (1540, 1553).

**HarmonyOS**
- Tab icon tint: repin to the commit with `53372bce`, one image per tab + template mode in the example, re-measure (2157 to 2160; tab bar session message of 2026-11-26).
- Edge swipe-back test (`uitest swipe` from x=2 opens the dock), tap 6 vp beside the first item, text-style group screenshot (2087, 2108).
- Rive and PAG not verified: the x86_64 emulator HAP leaves them out; needs an arm64 device (2086, 2159; plan 1 at 903 to 918).
- Lottie, PAG, Rive tab icons, the plus tab, a real device, the system light/dark switch (only the app colour mode was forced) (2159).
- Examples-menu pushed pages keep in-page bars; the recording's round black search button is a rounded text item; the README lacks the new API (1984, 2006).
- Placeholder Discover page and gallery not converted to tag lists; gradient light only; most Examples and Ports rows have no subtitle (1658, 1685, 1763).
- Core gaps for glass: no backdrop-sampling property in `CYLMenuStyle`; `Image.fillColor` does not recolour PNG tag images (1694, 1784).
- Dark flat bar is mid-grey (2160).
- `animated-icon-component.md:260-264`: wrapped-`Navigation` branch not used by any page; `cyl_tagList_refresh` label not verified on a device; locales other than base, zh_CN, zh_TW, ja_JP fall back to English.
- ohosTest `discoverRefreshButtonHasItsLabel`, screen-reader labels, corner radius 0 vs 1000 are "written, not run" (animated-icon-component.md:40).

**WeChat mini program**
- Dark mode in DevTools (no tool toggles the appearance), real pointer tap beside the camera (the 36 px `::after` area), edge swipe-back, pill outline vs iOS (2125, 2119, 2124).
- Empty-results placeholder under the keyboard needs the owner's real phone (core-todo.md:229, 236; task-log.md:524, 555).
- `cyl-tag-list` has no `backdrop-filter` blur; subtitles empty (no localized strings); the tail control position cannot be expressed (1696, 1764, 1666).
- `cyl-search-bar` does not draw `clearIconImage` / `cancelTitle`; `CYLSearchTagListStyle.js` header keys unchecked against the pinned `cyl-tag-list`; keep or merge back the `CYLSearchController` export (owner decision) (1504).
- Docs: README does not document `cyl-search-refresh-button`, `cyl-search-navigation-bar` and the new search button API (animated-icon-component.md:263; 2006).
- Publish `cyl-search-miniprogram` to npm (`npm login` first) (last commit of `feat/swift-core-next`).
- WeChat DevTools "registry.js is not defined" judged upstream vendoring; re-check at the new pin (animated-icon-component.md:218 to 222).

**React Native**
- Trailing-group gaps uneven (10.3 dp vs 7.0 dp), cause not found (2132).
- Hardware back plays no reverse animation (`BackHandler` unmounts at once): needs an imperative `goBack()` on `CYLSearchBarHandle` (spec Commands, TS, tests) (2134).
- Tab bar stays light in dark and the "Search bar" plus label is invisible (2133); contact tags pages stay white in dark (1550, 1552).
- CI check for the vendored tab bar pin and an RN Android build job (2136).
- Not verified: Discover tag spacing numbers, Tag style tab, Search controller demo, release build, arm64 (2135); jest/tsc not re-run after `e8b4927` (2131).
- No typed `iconColor`/template parameter for tag images; hot icon keeps its colours on glass (1784, 1786).
- Glass cannot sample the RN-painted gradient behind a platform view (core gap 3: needs the ClassifyMenu list-owned plate) (1694, 1769).
- English descriptions and demo buttons on the RN tab pages (1423).

**Flutter**
- Discover tab root shows an empty glass box and no tags, never investigated (2059).
- Flutter's own back gesture does not drive the bar on Android; predictive back not run; the route watcher has no Dart test (needs a platform view) (2056, 1971).
- Dark: labels ("Tags", tab bar labels) unreadable (1551, 1656); the bar stays `#FAFAFA` (no `CYLTabBarBackgroundColor`; `identifierForTrait` pair could change it).
- Glass cannot sample the Flutter-painted gradient (core gap 3) (1694, 1769).
- English tab titles (1423); the "Search bar" tab plus button did not respond in one run, cause unknown (1552).

**Cross-cutting**
- Dealloc dependency on Android/HarmonyOS/mini program/Flutter/RN is deferred until the unified pin (1574, 1884, 1985); `dismissesKeyboardOnOutsideTouch` (hide the keyboard on a touch outside the bar) not implemented on Windows platforms.
- `focusesOnAppear` is not verified on a non-iOS device with a real soft keyboard (1936, 1944).
- Liquid Glass core-gap list for ClassifyMenu: Flutter/RN backdrop parameter, HarmonyOS sampling, mini program `backdrop-filter` (1692 to 1697, 1767 to 1773).
- Canonical iOS `CYLSearchExample/CYLSearchDiscover.bundle/search_camera.json` still 44x44; the trimmed 36x36 Lottie is in the Windows copies (Mac session).
- `Release-RAM.md`: macOS section is a stub; not run live: Obsidian/Android Studio/Chrome/Edge closing, brightness, external monitor dimming (`docs/Release-RAM.md`).
- `docs/no-system-searchbar.md:43-48` work list still says TODO although the log says done (1904 to 1919).
- Rive/PAG debug guard on x86_64 can be removed only with the owner's approval (903 to 918, 1467).

**iOS-only (Mac session, cross-reference)**: merge Dealloc PRs #30 then #29; real-touch checks with axe; QMUI port iOS 15/16/18-25 and dark/large-type screenshots; contact tag editor `contentEdgeInsets`.

## 7. All known bugs: why not fixed, plan, approach, documents

| Bug | Why it is not fixed | Fix plan | Approach | Documents |
|:---|:---|:---|:---|:---|
| RN Android trailing-group gaps uneven (glyph to divider 10.3 dp, divider to capsule 7.0 dp) | Cause not found; the trimmed camera asset (`784aea4`) did not close it on RN | Find where the extra 3.3 dp comes from, then re-measure | Compare the RN example camera item frame with the Android example; check Lottie scale type in `CYLTagButton` and divider insets in `CYLSearchBarItemView.onMeasure`; pixel-measure like `docs/task-log.md:2132` | task-log.md:2132; `docs/instructions/core.md` "Trailing group layout" |
| RN hardware back: no reverse animation | Needs a new API (not a one-line fix) | Add `goBack()` to `CYLSearchBarHandle` | Spec Commands + TS + Android native + tests; the example `BackHandler` calls it instead of `setSearchTab(null)` | task-log.md:2134 |
| RN dark: tab bar light, "Search bar" label invisible | Tied to the open dark tab bar decision | Implement with the dark tab bar work | Set `CYLTabBarBackgroundColor` with a dark theme pair, or a core dark default | `docs/Dark-Mode-Adaptation.md` (CYLTabBarController repo); task-log.md:2133 |
| Dark tab bar background on Android, HarmonyOS, Flutter | Owner: "must follow dark mode, not today" | Implement next | Decide: core dark default for the unset background vs per-example config with theme pairs; then re-measure | `docs/Dark-Mode-Adaptation.md`; task-log.md:2177, 2184 |
| HarmonyOS tab icons do not tint (fill SVG) | Library bug fixed upstream (`53372bce`), example not repinned; example ships two pre-coloured SVGs | Repin, one image + template mode, re-measure | Repin HarmonyOS to the agreed pair; replace `tab_*_selected.svg` + `tab_*_normal.svg` by one SVG per tab; set `CYLTabBarControllerIconRenderingMode: "template"`; measure like the probe in the task-log | task-log.md:2157 to 2160; CYLTabBarController `docs/Dark-Mode-Adaptation.md` tint section |
| Flutter Discover tab root: empty glass box | Never investigated | Reproduce on the emulator | Check the tag source of the Discover tab root in `flutter_cylsearch/example/lib/tab_search_bar.dart`; compare with the RN/Android Discover | task-log.md:2059 |
| Flutter back gesture does not drive the bar on Android | Flutter's route animation is not wired to `setBackButtonProgress` | Wire the route's `secondaryAnimation` to the bar progress, or keep the animated hide before pop | Platform-view method call per frame is costly: measure first | task-log.md:2056, 1971 |
| 10 `CYLSearchViewQMUIPortTest` SQLite failures in full runs (`Illegal connection pointer`) | Order dependent, intermittent, never baselined against the unmodified code | Baseline once, then isolate | Run the class alone and in the full suite on a clean checkout; close the Robolectric SQLite connections in `@Before`/`@After`; consider `@LooperMode`/shadow reset | task-log.md:1653, 1716, 1792, 1803, 1834 |
| HarmonyOS `aa test` needs `-s timeout 40000` (fragile; cascades at 15000) | The overlay test is slow on the emulator | Speed up or isolate that test | Split the overlay test or raise the default in the skill (done in the skill text only) | task-log.md (HarmonyOS device check entry); `.agents/skills/cyl-harmonyos-setup/SKILL.md` |
| Mini program `beforeCompile` does not refresh components (stale copy in DevTools) | Tooling quirk found on 2026-11-26 | Make the hook run `sync-example.js` or fail loudly | Fix the project hook or document it in the mini program README | task-log.md:2113 to 2125 |
| Mini program committed `touristappid` rejected by wechatide | AppID is account bound | Document the private AppID flow | Set the private AppID in `project.config.json` for a run, revert it | task-log.md:2113 |
| Mini program empty-results placeholder under the keyboard | Needs the owner's real phone; DevTools draws no keyboard | Test on the owner's phone | Compare the placeholder position with Android/iOS | `docs/core-todo.md:229, 236` |
| List style and Tag style tabs keep their own magnifier (duplicate search job, rule 9) | Owner never answered | Ask the owner, then remove or keep | Remove the tab-own action and rely on the default search button if the owner agrees | task-log.md:2055; `docs/instructions/example-demos.md` rule 9 |
| Search tab bar not full width (OVERLAY action beside it) | Example design; not decided | Move OVERLAY to the second-level page like HarmonyOS | Same move as the HarmonyOS Search tab (`SearchExample.ets`) | task-log.md:2051 to 2061, 2084 |
| "Search bar (plus)" tab is not a first-level pushing bar | Logged as a gap | Convert with the outlined preset like iOS | Use the first-level bar API on that tab root | task-log.md:2055 |
| Flutter / RN glass cannot see their own gradient | Needs ClassifyMenu "list-owned plate" (core gap 3) | Wait for the ClassifyMenu SHA, then wire the parameter in the bridges | Bridge parameter for a backdrop plate; example places a plate behind the list | task-log.md:1694, 1769 |
| HarmonyOS glass: no backdrop-sampling property in `CYLMenuStyle`; mini program no `backdrop-filter` | Library gaps in ClassifyMenu | Request in ClassifyMenu | Property + implementation per platform | task-log.md:1694 to 1697, 1767 to 1773 |
| iOS canonical `search_camera.json` not trimmed | Mac session's file | Mac copies the trimmed file | Copy the 36x36 Lottie over the 44x44 bundle copy | task-log.md (trimmed asset entry, `784aea4`) |
| Dealloc dependency not on Windows platforms | The library event name changed; unified pin pending | Add at the unified pin | gradle / oh-package / package.json / pubspec at `eab21d10`; move `focusesOnAppear` moments to `appDidBecomeActiveOnScreen` | task-log.md:1574, 1884, 1985 |
| README stale for the new API (search button, first-level bar, `focusesOnAppear`) | Owner forbids editing README without approval | Ask the owner | Document the new API in the platform READMEs | task-log.md:2006 |
| `-Apply` switch of `release-ram.ps1` questioned by the owner | The owner never said what was wrong | Ask the owner | Options: keep `-Apply`, or switch to PowerShell's `-WhatIf` convention with real run as default | `docs/Release-RAM.md` |
| Release-RAM macOS section missing | Needs a macOS session | Write it | Shell scripts under `scripts/release-ram/` plus an entry script in the root | `docs/Release-RAM.md` |
| Android `CYLSearchBarView` camera glyph gap and hit area (fixed) | Fixed in `784aea4` (listed so you know it is closed) | None | - | task-log.md (`784aea4`) |

## 8. Decisions the owner has not made

1. Should the core default-tint static tab icons (today opt-in via `CYLTabBarControllerIconRenderingMode: "template"`, `CYLTabBarItemIconRenderingMode`, or explicit icon colours), or tint by default only icons detected as one colour? (tab bar session; with the owner)
2. How exactly the tab bar background follows dark mode (core default vs configuration) and when (`docs/Dark-Mode-Adaptation.md`).
3. Keep or remove the magnifier on the List style and Tag style tabs (rule 9).
4. What was wrong with the `-Apply` parameter of `release-ram.ps1`; whether `Dark-Mode-Adaptation.md` gets a Chinese file name.
5. Remove the x86_64 debug guard for Rive and PAG (plan 1) (needs the owner's own approval).
6. Glass board behind the Discover topic grid, on every platform in one change.
7. Maven coordinates of CYLTableViewPlaceHolder's Android modules (its owner).
8. Keep or merge back the mini program `CYLSearchController` export; the fold control when all tags fit (QMUI merge phase 6).
9. The pin pair: ClassifyMenu next SHA, CYLTabBarController newest head, Dealloc `eab21d10` once PRs #30 and #29 merge.
10. `focusesOnAppear` depth rule: iOS and Windows now use "second level or deeper"; confirm it supersedes the earlier back-button filter.
11. External monitor dimming and `dismissesKeyboardOnOutsideTouch` on the Windows platforms (deferred).

## 9. Where things are

- Work log with every measurement and screenshot name: `docs/task-log.md` (screenshots in `docs/assets/`, named `<platform>-<device>-<date>-<what>-at-<sha>.png`, checked by `scripts/check-screenshot-labels.sh`).
- Rules: `AGENTS.md`, `instructions.md`, `docs/instructions/` (`core.md`, `example-demos.md`, `git.md`, `testing.md`, `skills.md`), skills in `.agents/skills/` (`cyl-search-field`, `cyl-example-taglist`, `cyl-simulator-run`, `cyl-harmonyos-setup`, `cyl-commit`).
- Release-RAM manual and scripts: `docs/Release-RAM.md`, `release-ram.ps1`, `scripts/release-ram/`.
- API scorecards: `docs/android-api-alignment.md` (100/100), `docs/harmonyos-api-alignment.md`, `docs/miniprogram-api-alignment.md` (100/100).
- Other open work: `docs/core-todo.md`, `docs/no-system-searchbar.md`, `docs/animated-icon-component.md`.

## 10. Added by the Mac iOS session (2026-11-26): read this part before section 1

Sections 1 to 9 cover Android, HarmonyOS, the mini program, React Native and Flutter. Sections 10 to 17 add iOS, a second advisor
assessment, corrections, and the bugs and TODOs missing above. State: pins and code at `9c9ae2d`; CI as seen at `1f02417`.
"Code reading" means found in the source and **not reproduced**.

**Order for your first day** (put these before the list in section 1):

1. **Get one `iOS` workflow run to finish.** None of the recent runs completed: later pushes cancelled them, and the run on `1f02417` was pending when this was written. Pause pushes, or change the workflow concurrency. The CI fixes in [`3f71ed5`](https://github.com/ChenYilong/CYLSearchViewController/commit/3f71ed5) are verified locally only.
2. **Label 8 screenshots**: `docs/assets/android-emulator-api37-20261126-tabbar-more-*-at-af56db22.png` have no header or footer and no Markdown link. The check failed on `9c9ae2d`. It passes on `1f02417`, a docs-only commit, but those images were not fixed.
3. **Unify the pins** (section 4; iOS pins are in section 12).
4. **Merge CYLDeallocBlockExecutor [PR #30](https://github.com/ChenYilong/CYLDeallocBlockExecutor/pull/30), then [PR #29](https://github.com/ChenYilong/CYLDeallocBlockExecutor/pull/29)** (retarget #29 to `master`), release it, and repin to a `master` commit.
5. **Reproduce and fix iOS bug I1** (section 14).

## 11. Second advisor assessment, including iOS (use this one for the release decision)

These are judgments of a stronger review model, not measurements. Section 2 scores 86 (features) and 76 (release) from the non-iOS work
log. This assessment saw the iOS work, CI and the dependency chain, and scores **84 / 100 progress** (iOS about 90, Android about 85,
HarmonyOS about 85, mini program, Flutter and React Native about 80 each) and **52 / 100 release readiness**. The release gap is mainly
red or unfinished CI, dependencies that cannot be published, and a breaking change without a version.

100 means: green CI on the release head; every dependency merged and published; a version bump with migration notes; current documents;
no open P1 defect; a device check on each platform.

| # | Missing point (release readiness) | Points |
|---|---|---|
| M1 | No proven green CI: screenshot labels failed on `9c9ae2d`, and no recent `iOS` run completed. | -10 |
| M2 | The dependency chain cannot be released: CYLDeallocBlockExecutor `eab21d10` is on unmerged PR #29 (stacked on #30) and 1.4 is not on the CocoaPods trunk. CYLAnimatedItem and CollectionViewClassifyMenu are pinned commits that are not on the trunk. `pod trunk push` would fail; the other package channels depend on the same pins. | -15 |
| M3 | Pins differ between platforms. | -4 |
| M4 | Breaking iOS API change while the podspec says `0.1.0`: no tag, changelog or migration guide. | -5 |
| M5 | Verification gaps: 60 UIKit-only tests removed or merged; swipe-to-dismiss checked only as a recognizer; no real-device touch or background-return check; iOS 15, 16, 18 to 25 not run on this code; Rive and PAG on arm64 and mini program dark mode not run. | -6 |
| M6 | Open defects (section 7 and section 14). | -5 |
| M7 | Stale documents (section 13 lists them). | -2 |
| M8 | Hygiene: PR #11 is about 2,100 files, PR #16 conflicts, merged branches not deleted. | -1 |

## 12. iOS chapter

### 12.1 Branches, additions to section 3

- **PR #16 conflicted** with its base when checked on `9c9ae2d` (GitHub showed "unknown" after the newest push). It holds one commit, a task-log entry. Resolve the `task-log.md` conflict keeping both sides, or close it.
- Dependency branches (progress is an estimate):

| Branch | Progress | TODO |
|---|---|---|
| [CYLDeallocBlockExecutor `feat/did-become-active-on-screen`](https://github.com/ChenYilong/CYLDeallocBlockExecutor/tree/feat/did-become-active-on-screen) | 90 % (89/89 tests reported) | [PR #30](https://github.com/ChenYilong/CYLDeallocBlockExecutor/pull/30), merge first; adds `appDidBecomeActiveOnScreen` |
| [CYLDeallocBlockExecutor `feat/screen-focus-events`](https://github.com/ChenYilong/CYLDeallocBlockExecutor/tree/feat/screen-focus-events) | 85 % (90/90 tests Debug and Release; `pod lib lint` of that library not run) | [PR #29](https://github.com/ChenYilong/CYLDeallocBlockExecutor/pull/29), merge second; adds `didTouchOutside` by wrapping `UIWindow.sendEvent(_:)` |

### 12.2 iOS pins (3 Podfiles: root example, Flutter, React Native)

| Dependency | iOS pin |
|---|---|
| CYLTabBarController and CYLAnimatedItem | `08343e9f76d609e1a8c0b45c01fd31a0b7a1e5bc` |
| CollectionViewClassifyMenu | `c0b183de12c62c8b0b575b5a9ff0613f9a970468` |
| CYLDeallocBlockExecutor | `eab21d10f8e80ccee67e6e74271cd5bc6ff9a50e` |
| CYLTableViewPlaceHolder | `f4cf978567e43288b44f6ddc266510fa837a0e72` |

### 12.3 What changed on iOS on 2026-11-26

| Area | Result | Commits |
|---|---|---|
| One navigation field look in the core (`applyNavigationFieldStyle()`) | Discover, Edit Remarks, Edit Tags and the Search tab use it | `9103ae5` `81e9c95` |
| No system search bar | `CYLSearchBar` (a `UISearchBar` subclass) deleted; `CYLSearchController` rebuilt over `CYLSearchBarView` with its own overlay page. A grep for `UISearchBar`, `UISearchController`, `UISearchTextField` in `Sources`, `CYLSearchExample` and `CrossPlatform/*/ios` returned nothing | `8995a7c` |
| Keyboard life cycle through CYLDeallocBlockExecutor | `focusesOnAppear` (second-level or deeper pages only), `dismissesKeyboardOnOutsideTouch` (on by default, never for editing bars), Search return key | `c771852` `6e8e28e` `f719cfb` `8a0bfc7` |
| Default search button | Always built in; icon style by default (filled capsule, equal gap above, below and at the end), text style on request | `6e8e28e` `6697875` `77a5193` |
| Trailing group | Plain items hug their content, 36 pt touch area on both sides, even gaps beside the divider | `f778fd1` `80d437a` |
| First-level search bar (example rule 10) | `pushesOnTap`, `onFirstLevelTap`, five `CYLSearchBarPreset` looks; tab roots show their own bar and push a second-level page | `24a58bd` |
| Flutter and React Native iOS bridges | Navigation preset, focus, search button settings, `pushesOnTap`, `pageDepth` | `3663529` `5c15d76` `5eaf047` `fd5745d` |
| CI fixes (local verification) | shellcheck, public API comments, licenses, `pod lib lint` | `3f71ed5` |

Last full native suite: **150 tests, 0 failures** (iOS 27.2 simulator, Xcode 27.2, at `5d0b0f5`). It was 201 before the rebuild; the
removed and merged tests are listed with reasons in [task-log.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/task-log.md).

### 12.4 Design facts to know before you change code

- Pushed pages keep the **system back button**. Hiding it to show the bar's own arrow disabled UIKit's swipe back on iOS 27.2. A gesture-delegate workaround passed a unit test and failed on the simulator, so it was removed. Other platforms draw their own back button.
- `CYLSearchController` is now a separate component. Removed: `searchController`, `hidesNavigationBarDuringPresentation`, `forwardsAppearanceFromContentsViewController`, the two status bar providers, the `UISearchResultsUpdating` and `UISearchControllerDelegate` conformances, and the window-snapshot swipe. API map: [no-system-searchbar.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/no-system-searchbar.md).
- A bar in a navigation bar sits in a system-owned view, so it calls `cylRefreshScreenState()` after layout while `focusesOnAppear` is on.
- `CYLSearchBarView.swift` is over 3,000 lines. Splitting it is recommended technical debt.

### 12.5 iOS TODOs

1. Fix bugs I1 to I6 (section 14).
2. Real device: a tag tap and a drag hide the keyboard, a tap on the bar's camera does not, the field refocuses after returning from the background. A pointer or trackpad scroll is not covered by `didTouchOutside`.
3. Look at the screens never checked visually after the rebuild: the active state of `CYLSearchController`, the Search bar styles screen, the Collection view demo.
4. Run the suite on iOS 17.5 and 26.5 again; iOS 15, 16 and 18 to 25 are unverified.
5. Re-mark rows E1 to E22 in [qmui-search-controller.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/qmui-search-controller.md) and close the work list in `no-system-searchbar.md`.
6. Bump the podspec version; write a changelog and a migration guide.
7. Add `searchButtonImage` to the Flutter and React Native APIs.
8. Record the push and the swipe back (only still frames exist).

### 12.6 Build and test

```sh
pod install
xcodebuild test -workspace CYLSearchExample.xcworkspace -scheme CYLSearchExample \
  -destination 'platform=iOS Simulator,id=<your simulator UDID>' -derivedDataPath /tmp/cyl-dd
bash scripts/check-public-api-comments.sh && bash scripts/check-licenses.sh && bash scripts/check-example-fold.sh
shellcheck scripts/*.sh
scripts/pod-lint.sh lib
sh scripts/check-screenshot-labels.sh <base> <head>
```

Use your own simulator and shut down only that one; never run `simctl shutdown all` on a shared Mac. Screenshot launch arguments:
`-CYLDemoTab <n>`, `-CYLDemoRow <n>`. Real taps and swipes: `axe`.

## 13. Corrections to sections 1 to 9

| Where | Correction |
|---|---|
| Section 6 (Cross-cutting) and section 7, "iOS canonical `search_camera.json` not trimmed" | Closed: the iOS file is 36x36 since `5d0b0f5`. |
| Section 9, API scorecards at 100/100 | The committed tables are out of date. Re-running the generators on `9c9ae2d` gave Android 98 (8 TODO rows), HarmonyOS 99 (4), mini program 97 (10). The rows are mostly today's new API: outside touch, `automaticCornerRadius`, `CYLSearchBarPreset`, first-level tap, back button, `focusesOnAppear`, `pageDepth`. The generators match declaration names, so check each row by hand. |
| Section 5, commit rules | They describe the Windows session. The Mac iOS commits also carry a `Claude-Session:` trailer. [git.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/instructions/git.md) is the authority. |
| Section 5, README | Besides the missing new API, the README still describes a `UISearchController` reproduction page that no longer exists (`CYLSearchBar` is removed too). `Sources/CYLSearchBar/instructions.md`, `CYLSearchExample/instructions.md` and `docs/ios-api-alignment.md` need the same pass. Ask the owner before editing the README. |

## 14. Bugs missing from section 7

I = iOS or release. X = other platforms. P1 blocks the release or can break an app.

Document addresses for section 7: `task-log.md:<line>` there means [docs/task-log.md](https://github.com/ChenYilong/CYLSearchViewController/blob/bc347b6/docs/task-log.md?plain=1) (add `#L<line>` to the address; this link is fixed to commit `bc347b6`, so the numbers stay right). The other files are under [docs/](https://github.com/ChenYilong/CYLSearchViewController/tree/feat/harmonyos-parity/docs). `Dark-Mode-Adaptation.md` is in the [CYLTabBarController branch](https://github.com/ChenYilong/CYLTabBarController/blob/feat/harmony-animated-item-engines/docs/Dark-Mode-Adaptation.md).

| ID | Pri | Bug | Why not fixed | Fix plan | Fix approach | Documents |
|---|---|---|---|---|---|---|
| I1 | P1 | Code reading: `CYLSearchController` adds its overlay page to the navigation view or the window and never removes it (no `removeFromSuperview` for it, no `deinit`). Popping or dismissing the page while the search is active can leave the overlay on screen. | Introduced by the rebuild; found while writing this handover | Remove the overlay whenever the contents page leaves for good. | First a failing test: activate, pop, expect no overlay. Then dismiss on a CYLDeallocBlockExecutor disappear event with `isMovingFromParent` or `isBeingDismissed`, and remove the view in `deinit`. | [CYLSearchController.swift](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/Sources/CYLSearchBar/CYLSearchController.swift) |
| I2 | P2 | Code reading: the results view controller is no child of any controller, so it gets no appearance callbacks or containment updates. | A child of the contents page raised `UIViewControllerHierarchyInconsistency`, so containment was removed | Give the results view controller a real parent. | A container controller that is a child of the host view's owner (or forwarded appearance calls); test with a recording results controller. | [CYLSearchController.swift](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/Sources/CYLSearchBar/CYLSearchController.swift) |
| I3 | P2 | Code reading: the overlay is laid out on activation, text, keyboard and empty view changes only; rotation or a size change can leave an old frame. | No rotation test | Lay the overlay out again on every size change. | Relayout from the page's `layoutSubviews` or the host's size changes; add a resize and rotation test. | [CYLSearchController.swift](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/Sources/CYLSearchBar/CYLSearchController.swift) |
| I4 | P2 | iOS example: English text is hard-coded on the second-level page (tags, some placeholders). | Added with rule 10 | Localize the strings. | Move them to the example string bundle: en, ja, zh-Hans, zh-Hant. | [CYLSearchDemoMenuViewController.swift](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/CYLSearchExample/CYLSearchDemoMenuViewController.swift), [accessibility-i18n.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/instructions/accessibility-i18n.md) |
| I5 | P2 | iOS example: the Search tab list can no longer be filtered by typing; a tap on its first-level bar pushes a generic second-level page. | Result of rule 10; the second-level page for this tab is not decided (D4) | Give the Search tab its own second-level page, after decision D4. | Push a filtering results page with `pushesOnTap` off. | [CYLSearchExampleViewController.swift](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/CYLSearchExample/CYLSearchExampleViewController.swift) |
| I6 | P3 | Flutter and React Native cannot set a custom image for the default search button. | Not in the Dart and TypeScript API | Add `searchButtonImage` to both APIs. | Add the Dart and TypeScript parameter and wire both native bridges. | [example-demos.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/instructions/example-demos.md) |
| I7 | P1 | 8 screenshots at `af56db22` break the label rules (first-day item 2). | Added by a late commit | Fix the 8 images, then run the check with base and head. | Add header and footer with the stitch script and link each image with date and commit. | [docs.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/instructions/docs.md) |
| I8 | P1 | `iOS` CI runs are cancelled by newer pushes. | Several sessions push to one branch | Let one run on the release head complete. | Pause pushes, or change the workflow concurrency group. | [CI-CD.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/CI-CD.md) |
| X1 | P2 | Flutter iOS: the raised plus button of the "Search bar" tab did not respond in one run. | Cause unknown, seen once | Reproduce it first. | Real taps on the Flutter example; check hit testing of the raised button. | [task-log.md line 1552](https://github.com/ChenYilong/CYLSearchViewController/blob/bc347b6/docs/task-log.md?plain=1#L1552) |
| X2 | P2 | React Native contact tag pages stay white in dark mode; Flutter "Tags" and "My Tags" labels are dim on the dark gradient. | Not investigated | Make the example pages follow dark mode. | Use dynamic colors for page, header and labels; re-shoot light and dark. | [task-log.md line 1550 to 1552](https://github.com/ChenYilong/CYLSearchViewController/blob/bc347b6/docs/task-log.md?plain=1#L1550-L1552) |
| X3 | P3 | React Native iOS: one tap 6 pt left of the camera missed once, then worked 6 times. | Not reproduced | Watch it in the next device pass. | Repeat the tap several times on a light and a dark build. | [task-log.md line 1556](https://github.com/ChenYilong/CYLSearchViewController/blob/bc347b6/docs/task-log.md?plain=1#L1556) |
| X4 | P2 | Dragging a tag list does not hold the page scrolling on every platform (55 / 100). | Platform work left | Finish the platforms listed under "Left". | Follow the entry's contract: the page scroller holds while a drag or smear is active. | [CYLTabBarController-Integration.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/CYLTabBarController-Integration.md) ([line 1044](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/CYLTabBarController-Integration.md?plain=1#L1044)) |
| X5 | P3 | Liquid Glass on Android and Flutter is partial; the 2026-11-25 entry still says TODO. | Needs library work | Re-verify, then close or repin. | Check color, border and corners on API 31 or newer against the entry's findings. | [task-log.md line 1523](https://github.com/ChenYilong/CYLSearchViewController/blob/bc347b6/docs/task-log.md?plain=1#L1523) |
| X6 | P3 | GitHub [issue #3](https://github.com/ChenYilong/CYLSearchViewController/issues/3) (2017): the search bar overlaps the status bar. | Never answered | Verify, answer, close. | Run the current example on a device with a notch and check the bar against the status bar. | [search-bar-view.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/search-bar-view.md) |

## 15. Open decisions missing from section 8

| # | Question for the owner | Current behavior |
|---|---|---|
| D1 | iOS: keep the system back button on pushed pages, or show the bar's own arrow and lose the swipe back? | System button. This departs from rule 10 and is not confirmed. |
| D2 | Should the field plus trailing group become a real stack view? | Laid out by the bar's code; measured gaps are 8 pt. Asked, not answered. |
| D3 | Rule 10 calls it default behaviour: should `pushesOnTap` be on by default? Should the camera and search button of a first-level bar push too? | Off by default. On iOS Discover the search button pushes, the camera does not. |
| D4 | What is the second-level page of the Search tab? | A generic tag page. |
| D5 | Should native, Flutter and React Native example looks match? | They differ. |
| D6 | Convert the examples menu, styles screen and MaterialSearchView samples to tag lists? | Not converted. |
| D7 | Version number, release plan and dependency publish order for the breaking change. | Not decided. |
| D8 | How to review and merge a PR of about 2,100 files. | Not decided. |
| D9 | Keep the Search button on the Edit Remarks name field? | Kept, because every example must show the default button. |

Decided, do not reopen without the owner: no system search bar on any platform; auto-focus only on second-level or deeper pages (by page
depth); the icon style is the default search button; the example fold control is the tail tag with an icon only.

## 16. TODOs from other documents that section 6 does not list

| TODO | State | Source (all in `docs/`) |
|---|---|---|
| Tab switch mid-animation leaves exactly one item selected | 95 / 100: mini program retest | `CYLTabBarController-Integration.md` |
| Tag list drag holds the scrolling | 55 / 100 (bug X4) | `CYLTabBarController-Integration.md` |
| Tags as the default suggestion style | 94 / 100: mini program device test, HarmonyOS `CYLSearchUI` rerun, Android 5 px cut of the first and last tag row | `task-log.md` |
| Animated item board rows 39 to 42 | Still marked TODO; later work covered parts; re-verify and mark | `animated-icon-component.md` |
| iOS check of the animated item changes | 85 / 100, then 90 / 100 in the follow-up; re-verify the rest | `task-log.md` |
| After the fold control fix | Owner decision, HarmonyOS and iOS 10-suggestion runs, a pretest step for the mini program components | `qmui-search-controller.md` |
| Entries with no final status: Discover layout into the core, Discover header into the core, "fix every open TODO", move the placeholder pin past its Swift rename | Re-verify before you close them | `task-log.md` |

Many headings still say TODO although a later "Results" or "Status: DONE" line closed them. Read the status lines of an entry before you
pick it up. Inline `TODO` words in the documents were **not** reviewed line by line for either part of this handover: search a document
for `TODO` before you close its area.

## 17. Where to start reading

[AGENTS.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/AGENTS.md), then
[core.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/instructions/core.md) ("One search field, no
system search bar" and "Trailing group layout"), [example-demos.md](https://github.com/ChenYilong/CYLSearchViewController/blob/feat/harmonyos-parity/docs/instructions/example-demos.md)
(rules 8 to 10) and the skill `.agents/skills/cyl-search-field/SKILL.md`. Later handover notes go at the end of this file; do not add a second file to this folder.

## 18. Taken over 2026-11-27 (Windows session, week 20261104)

Progress on the items above, branch `feat/harmonyos-parity`. Details: [task-log.md](../../task-log.md), "TODO (2026-11-27 ... take over the 20261104 handover".

| Item | State | Evidence |
|:---|:---|:---|
| I7: 8 screenshots at `af56db22` without header and footer | DONE, together with 21 more images of the same day with the same defect (`tabbar-tint-*-at-d19e138e`, `tabbar-template-*-at-b4993123`); originals in `docs/assets/raw/` | `sh scripts/check-screenshot-labels.sh 114ef3f^ HEAD` prints `screenshot labels: ok`; commit `7ce7c73` |
| Section 7, "Flutter Discover tab root: empty glass box" | FIXED in the Flutter plugin core, unit-tested; **device run still TODO** | Cause: the four platform-view widgets dropped a change made before the native view's creation callback (`_channel` still null); now `_created` sends `update`. `test/cyl_created_update_test.dart` 4/4 red before, green after; `flutter test` 44/44 |
| Section 7, mini program `beforeCompile` does not refresh the components | Not changed: `project.config.json` already has the three hooks and `scriptsEnable: true`; why DevTools skipped it can only be seen in DevTools. Still run `node scripts/sync-example.js` by hand | - |
| Screenshot labels against the PR #11 base (`sh scripts/check-screenshot-labels.sh $(git merge-base origin/master HEAD) HEAD`) | 14 failed (linking line without a date); the 4 Android ones fixed; **10 iOS images still fail** (`ios-iphone18pro-sim-ios27.2-20261125-*`, `-20261126-*`): Mac session | the check prints `10 problem(s)`, all iOS |
| I8, `iOS` CI never finishes | Not changed. `cancel-in-progress` is already `false`; the macOS jobs wait for `vars.MACOS_RUNNER` or `macos-26`, and a run queued for hours points to no available runner | `.github/workflows/ios.yml` |
| I1 to I6 (iOS) | With `mac/CYLSearchViewController` (on I1 since 2026-11-27) | - |

Next for the Windows side: run the Flutter Android example on `CYL_Second_API_37` and screenshot the Discover tab root light and dark at the fix commit; the pin pair is still waiting for the Mac session's announcement.

## 19. Taken over 2026-11-27 (Mac iOS session)

| Item | State | Evidence |
|:---|:---|:---|
| I1: `CYLSearchController` overlay left after a pop or a dismissal | FIXED in the core: the search ends when the contents page leaves for good; the page and the swipe recognizer leave the host when the search ends and in `deinit` | 3 new tests in `CYLSearchControllerLifecycleTests` red before, green after; full `CYLSearchExampleTests` 153/153 on iOS 26.1. Details: [task-log.md](../../task-log.md), "fix bug I1" |
