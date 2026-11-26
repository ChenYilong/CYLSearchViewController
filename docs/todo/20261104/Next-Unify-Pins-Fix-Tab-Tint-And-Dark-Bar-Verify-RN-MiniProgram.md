# Handover: what you do next is unify the pins, finish the tab icon tint, decide the dark tab bar, and verify RN and the mini program on real runs

Written 2026-11-26 (Thursday) by the outgoing developer's Windows coordination session, for the colleague who takes over. This is the
only file in this folder. Folder rule: `docs/todo/<year><month><week of the month>`, week = `ceil(day / 7)`, so `20261104` is the 4th
week of November 2026. When the week changes, create the next folder; when a folder already has a file, append to that file.

Scope: the work of the Windows session on **Android, HarmonyOS, the WeChat mini program, React Native and Flutter** of
CYLSearchViewController. iOS belongs to the Mac sessions; iOS items appear here only as cross-references. The task text said "the
document address to update is here:" but gave no address, so this is a new document. If you were meant to update a specific document, ask.

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
