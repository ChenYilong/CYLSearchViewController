> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Written by a subagent: its claims and contradictions were NOT re-checked (only items marked S in 02-findings.md were). What the source documents report as done or passing is their claim.

# F. Agent rules, folder instructions, cyl-* skills, READMEs, changelog, transcription notes

Knowledge export of CYLSearchViewController (read-only pass, 2026-11-29). Working tree at HEAD `ad32984` (2026-11-28 00:13 +1300, "merge origin feat/harmonyos-parity"), branch `feat/harmonyos-parity`, with uncommitted changes (including `docs/harmonyos-api-alignment.md`, `CYLSearchBarView.ets`, `scripts/harmonyos-api-alignment.py`, the Flutter example `pubspec.lock`) and untracked mini program `index.wxss` files (`git status --short`).

Conventions: everything in sections 1-11 is what the documents **claim**; tests, builds, "done" statuses and screenshots were not verified. Section 12.1 holds what I checked myself with read-only commands. Cites are `file:line`. "The project author line" means the commit author line the rules require (not copied here). Short names: AG = `AGENTS.md`, `di/` = `docs/instructions/`, skill X = `.agents/skills/X/SKILL.md`.

## 0. Orientation in ten lines

- Repo = search library "CYLSearchBar": iOS Swift core, ports to Android (Kotlin), HarmonyOS (ArkTS), WeChat mini program, Flutter, React Native, plus examples and the Issue #1317 reproduction (AG:3-5).
- **Core** = anything published to a registry; **example layer** = everything else. Bugs are fixed in the core first (di/core.md:14-27).
- Instruction files are organised by **tag**; AG / `instructions.md` hold short summaries, `di/<tag>.md` the full text (AG:7-8, di/meta.md:16-30).
- Before any task read `di/behavioral.md` in full (AG:10-14); before any git write read `di/git.md` in full (AG:67-68).
- Skills live in `.agents/skills`; `.claude/skills` only points there (di/skills.md:13).
- Newest big design rules (2026-11-25/26): tag lists in examples, one search field and no system search bar, built-in default search button, bar-owned keyboard life cycle.
- Several "core is three files" and pin-hash statements are stale (section 12).

## 1. Instruction system

- Files: `AGENTS.md`, `instructions.md`, `CLAUDE.md`; each at most 200 lines (`wc -l`); one always-visible heading `## <Category> (tag: <tag>)` per category, no folding; a new rule goes in full into the tag file plus one line under the heading if every agent must know it; never drop a rule to save lines (di/meta.md:16-30, skill cyl-docs:8-15).
- Tag order: behavioral (always first), skills, meta, workflow, git, core, dependencies, example-demos, animation, testing, docs, macos, windows, harmonyos, miniprogram, accessibility-i18n, licenses, code-style (cyl-docs:9-11).
- `AGENTS.md` and `instructions.md` differ only in lines 1 and 3-5 (title and intro); verified by script.
- `CLAUDE.md` (5 lines): an HTML comment, `@docs/instructions/behavioral.md`, then `@AGENTS.md` (CLAUDE.md:1-4).
- Most tag files were split out on 2026-11-22 "unchanged"; where AGENTS and instructions worded a rule differently **both wordings are kept**, so duplicated sections are intentional. "Code wins over the text" (line 3 of most tag files).
- Every new integration rule updates AG, instructions.md and affected skills in the same change (di/skills.md:39-40).
- Instruction and skill files are English only (di/core.md:112, di/code-style.md:104).
- Many docs preserve the owner's prompts verbatim (often Chinese) with an English translation; commits must not quote Chinese.

### 1.1 Behavioral guidelines (di/behavioral.md:12-66; read in full at every task start)
1. Think before coding: state assumptions, present multiple interpretations, push back, ask when unclear.
2. Simplicity first: minimum code, nothing speculative.
3. Surgical changes: touch only what is needed, match style, mention (do not delete) unrelated dead code, remove only your own orphans.
4. Goal-driven execution: success criteria, tests first for bugs, step -> verify plan.
Where these disagree with project rules, the user's explicit instructions and tag rules win, and the disagreement is named in the reply (di/behavioral.md:90-91). The guideline text itself must stay unchanged (:82).

### 1.2 Skills map (AG:24-46, di/skills.md:15-37)

| Skill | When |
|---|---|
| cyl-task-start | start / score / finish any task; hung emulators |
| cyl-commit | any commit message |
| cyl-fix-in-core | any bug |
| cyl-docs | editing README or docs |
| cyl-verify | build, test, simulator, real-pointer scroll tests |
| cyl-simulator-run | before any simulator / emulator |
| cyl-search-field | any search or text field |
| cyl-example-taglist | grouped lists in demos |
| cyl-naming | adding or renaming symbols |
| cyl-api-map / cyl-api-parity | find public API / parity tables |
| cyl-tabbar-integration / cyl-plus-button | tab bar and plus button |
| cyl-new-project / cyl-xcode-compat | example projects, pbxproj, Podfile |
| cyl-sub-repositories | sibling dependency pins |
| cyl-license | published packages |
| cyl-accessibility-i18n | screen readers, localization, UI tests by label |
| cyl-harmonyos-setup | DevEco and HarmonyOS emulator |

Third party (do not edit by hand; pins in `.agents/skills.json`): swift-language, swift-api-design-guidelines, swift-concurrency, swift-testing, swift-architecture (dpearson2699/swift-ios-skills `8d90fd12`, PolyForm Perimeter 1.0.0), uikit (Prisma-Labs-Dev/apple-skills `49862600`, MIT), uikit-layouting (JordanCoin/ios-skills-collection `90d18076`, MIT) (pins read from skills.json, a file outside my set).

WeChat work uses `wechatide-skill` (ships with WeChat DevTools, linked into the user skill folder) for every build, run, automation and screenshot; marked DONE 2026-11-15 (di/skills.md:7-10, AG:151). Windows notes: `docs/miniprogram-api-alignment.md`.

Boilerplate repeated at the foot of many skills: task log before every task; Swift standard; screenshot rule; translated-project PRs/issues; screenshot stitching order; "Swift core: examples adapt to the core".

## 2. Task workflow (di/workflow.md, skill cyl-task-start)

Order for every task:
0. `git pull`, then `git log --since=<session start> -p -- AGENTS.md instructions.md .agents/skills` and apply rule changes (di/workflow.md:39-41; added after a rule landed mid-session and was missed, di/docs.md:94-97).
1. Check other sessions (`ListAgents`). Same branch and same task: do not duplicate, ask. Different task: keep out of their files (:42-47).
2. Platform split (2026-11-19): session names starting `Mac` (case-insensitive) do iOS; `Win` do Android, HarmonyOS, Flutter, React Native, mini program; hand parts across when both exist; ignore if no such names (:92-101).
3. First reply lines: `TODO (branch <git branch --show-current>): <task>` (:48-51).
4. Log in the feature's `docs/` file, else `docs/task-log.md`, heading `## TODO (YYYY-MM-DD): <task>` with Context, Requirements, Prompt (verbatim + English), Status, Acceptance (100 = full marks, 60 = pass). **Commit and push this entry before starting** (:11-24, :52-54). One tracker per task (cyl-docs:110-115).
5. Score after each milestone; below 60 do not hand back. An unlabelled screenshot keeps the task below a pass (cyl-task-start:38-40).
6. End: explain every missing point; final reply ends with `TODO (n points): …` lines; doc gets score and `DONE (YYYY-MM-DD)` with evidence. Interrupted tasks stay TODO (:55-66).

The pre-commit stale-notes search skips the open TODO of the task in progress (di/workflow.md:29-31). Before every commit search `docs/` and README for `TODO`, `Linux`, "without Xcode", "no simulator"; verify what can be verified (cyl-docs:35-37).

Hung emulator/simulator (2026-11-18; restart without asking; tell sessions using it first and again afterwards) (di/testing.md:34-49, cyl-task-start:51-61):
- Android `adb -s emulator-5556 reboot`, or `adb -s emulator-5556 emu kill` then `emulator -avd <name> -no-snapshot-load`
- HarmonyOS `hdc -t 127.0.0.1:5555 shell reboot`
- iOS `xcrun simctl shutdown <udid> && xcrun simctl boot <udid>`
- Won't open / won't boot: restart first, before other diagnosis.

Simulator run rule (owner, 2026-11-25; read before any run) (di/testing.md:60-71, cyl-simulator-run:13-32): when the run ends terminate the app and stop the device immediately; only what you started; never `xcrun simctl shutdown all`.
- iOS: `xcrun simctl terminate <udid> <bundle id>`; `xcrun simctl shutdown <udid>`; check `xcrun simctl list devices booted`
- Android: `adb -s <serial> shell am force-stop <package>`; `adb -s <serial> emu kill`; check `adb devices`
- HarmonyOS: `hdc -t <target> shell aa force-stop <bundle name>`, stop from DevEco Device Manager (`shell reboot` is not a stop)
- Write code first, test once in one batch (`static-code-then-one-test-batch`).

## 3. Git, commits, pull requests (di/git.md, skill cyl-commit)

- Read `di/git.md` in full before any git write (commit, push, pull, rebase, merge, cherry-pick, reset, revert, stash, branch, checkout/switch, tag, worktree, writing `gh` calls); once per task unless the file changed (`git log -1 --format=%H -- docs/instructions/git.md`), session restarted or context summarised. `status/log/diff/show/grep/ls-remote` are exempt (git.md:13-20; added 2026-11-22; re-applied 2026-11-26, :203-205).
- Every branch with commits has an open PR: check `gh pr list --head <branch> --state open`. Base = previously active PR's head branch, else `master`. More than two open PRs: ask (git.md:26-35; differs from "source branch" rule, see 12.2).
- Non-master branches: commit and push without asking (at the end of every exchange). `master`/`main`: ask first (git.md:36-38, :61-62).
- New branch: `gh pr create` right after first push; name the base in the reply (git.md:64-67).
- Before every `git cz` commit: `touch .git/hooks/NO_AUTO_SYNC` (stops the vault auto-sync committing mid-way) (git.md:43-47).
- Format `<type>(<scope>): <emoji> <subject>` or `<type>: <emoji> <subject>`. Types: test, feat, fix, chore, docs, refactor, style, ci, perf, release (release not in the interactive list). Length 3-64. No preconfigured scopes. Question order: type, scope, subject, body, breaking, issues, lerna (git.md:50-52, :86-97).
- Emojis: Commitizen defaults chore 🤖, ci 🎡, docs ✏️, feat 🎸, fix 🐛, perf ⚡️, refactor 💡, style 💄, test 💍, release 🏹; follow project history where it differs (feat ✨, docs 📝, chore 🔧, refactor ♻️) (git.md:90-94, cyl-commit:30-41).
- Entire message English only, no CJK even in quoted prompts: quote the prompt in the docs task log and link it (git.md:53-55).
- Body carries the project author line (two spaces after "By"), after the description and before trailers such as `Claude-Session:` (git.md:69-72). Check with `git log -1 --format=%B`.
- Checker: `scripts/check-commit-message.sh <file>` or `git log -1 --format=%B | scripts/check-commit-message.sh -` (form, 3-64 subject, CJK). `git commit --amend` only while unpushed (cyl-commit:54-57).
- `commit-msg` hook the rules ask to install before Commitizen commits (git.md:144-156): rewrites the message deleting **every** line containing `Co-Authored-By:` (case-insensitive, other authors' too). Inspect an existing hook first; assumes `.git` is a directory with default hooks path (:158-162). Installed in that clone on 2026-11-22 per git.md:21-22.
- Readiness: review scope and related docs; every unfinished/unverified item under a `TODO` heading in the most relevant docs file (status/score, remaining work, constraints, defects, verification, API/compat risks). Stubs, reserved keys and compiling do not prove completion (git.md:75-81, :101-108). Detail over 50 chars goes into a docs note linked from the body.
- Commit adding images: `sh scripts/check-screenshot-labels.sh` must print `screenshot labels: ok` (git.md:40-41).
- Never commit `Pods/`, generated workspace state, `._*` (di/macos.md:20).

## 4. Core architecture rules (di/core.md, skill cyl-fix-in-core)

### 4.1 What is core (cyl-fix-in-core:12-20)

| Platform | Core (published) | Example layer |
|---|---|---|
| iOS | `Sources/CYLSearchBar`, `CYLSearchViewController.podspec` | `CYLSearchExample` |
| Android | `android/merged/cylsearch` | `android/merged/app`, samples |
| React Native | `CrossPlatform/react-native-cylsearch/{src,android,ios}` | its `example` |
| Flutter | `CrossPlatform/flutter_cylsearch/{lib,android,ios}` | its `example` |
| Mini program | `CrossPlatform/wechat-miniprogram-cylsearch/src` | its `example` |
| HarmonyOS | `harmonyos/cylsearch` | `harmonyos/entry` |
| Sub-repos | CYLTabBarController, CYLTableViewPlaceHolder, CollectionViewClassifyMenu libraries | their demos |

Procedure (cyl-fix-in-core:28-52): (0) record the bug in the doc and screenshot **before** fixing; (1) locate it: if any library user could hit it, it is core; (2) fix in core so the class of bug cannot recur, add a test; sub-repo bugs are fixed there (own branch + PR) and the new commit pinned here; (3) if the core cannot fix it, ask the user with the reason **before** touching the example; (4) document why (or "example-only: the core has no such code"). Rule dated 2026-11-17 (di/core.md:5-28).

### 4.2 Core owns the content below the bar (2026-11-20, di/core.md:40-74)
- Core creates and owns the search bar and the content page below it (mini: `cyl-search-bar` + content area of `cyl-search`). Examples never create, look up or hold that scroller: no own `<scroll-view>`, no `getCurrentPages()/selectComponent/currentPage` lookup of the content page, no `reordering` flag bound to `scroll-y`. Calling a core component's public API (e.g. `setQuery`) is fine. automator's `currentPage()` is test-only.
- The content page listens to the tag list's `reorderingchange {reordering}` and `smearingchange {smearing}` and disables scrolling **only during an active drag** (start to end/cancel), editing mode included otherwise.
- It is the single scroller (fixed-height column) holding its own switch (`scroll-y`, `isScrollEnabled`).
- WeChat facts (documented as checked): `catchtouchmove` only stops propagation; iOS ignores page-level `overflow: hidden` for touch scroll; `"disableScroll": true` only stops the page; `<page-meta page-style>` (base lib 2.9.0) must be first node of a page so does nothing inside a component; `wx.setPageStyle` undocumented and had no effect/callback in DevTools 3.6.6. So the host keeps the page still by layout.
- Cross-repo tag lists emit bubbling + composed events; fix there first.
- Testing: **real pointer input** (mouse drags in DevTools simulator), not miniprogram-automator touch events (synthetic, cannot scroll); check pointer is over the simulator before each press; read scroll offsets and tag order on the **same automator connection** (a new connection restarts the simulator); run a control with protection off. Cases: swipe on tag scrolls; long-press + drag moves tag without scrolling; move before long press fires scrolls (cyl-verify:191-200).

### 4.3 Other core rules
- Stated target design: iOS three files / four public classes (`CYLSearchBarView`, `CYLSearchBarItem`, `CYLSearchView`, `CYLSearchResources`); same on every platform; refresh only in `CYLSearchView`; no dependency on another search kernel; new features are a parameter or mode, not a new public class; design in `docs/search-core-merge.md` (di/core.md:95-100, Sources/CYLSearchBar/instructions.md:4-17). **Stale against code, see 12.1.**
- Do not rename existing APIs or vendor symbols unprompted; keep attribution (di/core.md:105-106). Use only CYLTableViewPlaceHolder's umbrella header (:107-109). Keep the sample configurable through protocols/public properties; no `AppDelegate`/global coupling (:110-111).
- Examples adapt to the Swift core (2026-11-13): examples have the lowest weight; never keep a core API/shim/deprecated alias just for an example (di/core.md:114-116). Compatibility matters only for published-API callers.
- Focus alone (cursor, keyboard) changes nothing below the bar; only text changes or data changes do (2026-11-13, di/core.md:118-120; rule list in `docs/core-todo.md`).
- New core images go in folder bundles (`<Name>.bundle` with @1x/@2x/@3x PNG, copied by podspec and `Package.swift` `.copy`), never asset catalogs (2026-11-19, :122-129). Doc says the core has no image files today (icons are SF Symbols) (:129).
- Refresh is core-only: apps/examples never call CYLTableViewPlaceHolder's refresh header directly; check `grep -rnE 'CYLRefreshNormalHeader|cyl_header' CYLSearchExample` prints nothing (cyl-verify:25-27).

### 4.4 One search field, no system search bar (2026-11-26, di/core.md:140-180, skill cyl-search-field)
1. Every search field is the core's `CYLSearchBarView` (Flutter/RN `CYLSearchBar` over native per core.md:145; mini `cyl-search-bar`). Banned: iOS `UISearchBar`, `UISearchController` bar, `UISearchTextField`; Android `SearchView`/`SearchBar`/Material SearchView; HarmonyOS `Search()`; Flutter `SearchBar/SearchAnchor/SearchDelegate/CupertinoSearchTextField`; RN `TextInput` as search box; mini `<input type="search">`/`<search>`.
2. One look = navigation field preset ("Discover look"): bordered capsule radius 18, shadow opacity 0.06, no magnifier, scaling 16 pt text, opaque white/black fill, divider before trailing items. iOS `applyNavigationFieldStyle()`; same name on other platforms; Flutter/RN pass `navigationFieldStyle`; examples never set the values. In nav bars use the embed call (iOS `embedInNavigationBar(of:)`, cyl-search-field:19).
3. Ports of third-party libraries keep their classes only as API replicas; their demos show the core field. Non-search text inputs (remark name) use the same field.
5. Default search button: after field and owner's items (divider if preceded). `searchButtonStyle` `icon` (default: filled capsule with SF `magnifyingglass`; reference = black capsule, white glyph, equal gaps) or `text` (localized "Search", en/ja/zh-Hans/zh-Hant); custom `searchButtonTitle`/`searchButtonImage`, `searchButtonHandler`, `showsSearchButton = false`. None on `editingBar(...)` or multiple mode; not in `items`. Tap submits and calls `searchBarViewSearchButtonClicked` even for empty text on a plain bar; `CYLSearchView` ignores an empty tap (no submit/record/close, keyboard stays) (core.md:158-164).
6. Keyboard owned by the bar: `returnKeyType = .search`; `focusesOnAppear` (default off) focuses on each appearance (first push, pop, foreground) but **only on second-level or deeper pages** (not first VC of its nav controller; `isOnSecondLevelOrDeeperPage`); `dismissesKeyboardOnOutsideTouch` (default on; never for editing bar) hides on any outside window touch, so also at the start of finger scrolls. Both use CYLDeallocBlockExecutor events `didEnterScreen`, `appDidBecomeActiveOnScreen` (library PR #30), `didTouchOutside` (PR #29 on top of #30); all platform pins must name the same commit; other platforms port the events (core.md:165-174).
- Trailing group layout (2026-11-26, core.md:176-180): field takes all remaining width; right group spaced only by stack spacing, equal gaps by dividers; plain icon/text items hug content with 36 pt hit area by hit testing; shaped items (e.g. capsule) keep size.
- Leftover greps and per-platform status: `docs/task-log.md` entry "no system search bar on any platform" (core.md:175).

## 5. Example demo rules (di/example-demos.md, skill cyl-example-taglist; 2026-11-25/26)

1. Grouped table-like list -> CollectionViewClassifyMenu tag list: cell = tag (title + icon); every section header has a non-empty title.
2. Default init first; adaptive width; titles may wrap.
3. Fold at 3 rows. **Fold control = tail control**: the last tag, chevron only, no text, no more/less, no header button. Set explicitly where the pinned default differs: Android `CYLMenuFoldControlPosition.TAIL` + `CYLMenuFoldControlContentIcon`; HarmonyOS `.tail` + `.icon`; Flutter/RN `foldControlPosition` inline + `foldControlContent` icon; mini `foldControlContent="icon"`. Never `iconAndTitle/titleAndIcon/title`. Enforced by `bash scripts/check-example-fold.sh` (:22). This 2026-11-25 owner directive supersedes the original prompt's more/less wording (:7-8, :34).
4. Tap = cell tap; long press = subtitle bubble with arrow (`longPressAction`, `menuSubtitleForItem`).
5. Missing capability: add to core/bridge first.
6. Liquid Glass background via one core parameter (Flutter/RN `backgroundStyle liquidGlass`; iOS/Android/HarmonyOS `CYLTagBackgroundStyleLiquidGlass`/`tagBackgroundStyle`; mini glass tag style). No custom fills; below Android 12 flat fallback expected; default content inset 14 from core.
7. Gradient page background (light and dark), list background clear, `backdropSource` outside the list where needed; never fake refraction; record core gaps in task-log.
8. Nav bar / header fields are `CYLSearchBarView` with preset.
9. Every example field shows the default search button (style/title/icon may change; never hide except editing bar; never add a duplicate button).
10. First-level (tab root) pages hold the whole real `CYLSearchBarView` at full safe-area width (never a fake button); each tab shows its own bar style; tapping it does one push (back button slides in, bar narrows, keyboard, second-level page with recent/popular tag lists); swipe-back reverses. Core default behaviour, API `CYLSearchBarView.embedInNavigation...` per platform, others follow the iOS names set by the Mac session; examples never animate it (:46-52).
- Check: `sh scripts/check-example-taglist.sh` (cell-list menus, missing glass or explicit tail icon) (cyl-example-taglist:22). Long-press/wrapping status per platform: `docs/task-log.md`.

Animation (di/animation.md): record + labelled screenshot first; animated component bugs are fixed in CYLTabBarController (it adds the API the example needs), never in the example (:5-18). Animation pages (all platforms) offer Play all (restart from 0), speed slider, loop switch, applied live and accessible; **this repo has no animation example yet** (2026-11-13, :20-26).

Search bar placement (di/macos.md:22-32, cyl-verify:99-110): a search bar never covers any view at any Dynamic Type size; no extending under top bar (`edgesForExtendedLayout` without top); lay out against safe area; add every new bar/state to `testSearchBarsCoverNoView` (`viewsCoveredByView`), run with `hidesSearchBarWhenScrolling` both ways and largest text, in a real window.

## 6. Dependencies, tab bar, plus button

### 6.1 Sub-repositories (di/dependencies.md:93-136, skill cyl-sub-repositories)
- Sibling `../<Name>` used by the library. iOS: root podspec `s.dependency` + Podfile `:git`/`:commit`. Android: by commit via Gradle/Maven else `android/merged/settings.gradle.kts` `pinnedCheckout` into `.cyl-deps/` (commit in `android/merged/gradle.properties`). Others: package manager git+commit. Local path only during development.
- Newest commit on any branch: `git -C ../<Name> fetch`; `git -C ../<Name> log --remotes -1`.
- Core first with enum/parameter; missing interfaces added in the sub-repo, pushed, re-pinned; example shows every style and passes only data/style/taps.
- **CYLTabBarController and ClassifyMenu move together** (2026-11-18): ClassifyMenu vendors the animated item (mini `miniprogram_dist/cyl-animated-item/COMMIT`, HarmonyOS `harmony/cylanimateditem/README.md`); pin the commit it bundles; otherwise ask it to re-vendor (cyl-sub-repositories:24-30; rows 33-34 of `docs/animated-icon-component.md`).
- Podfile edits change `PODFILE CHECKSUM`: three lock files (root, Flutter example, RN example) are refreshed only by `pod install` on macOS; Windows sessions ask a Mac session (:31-33).
- Empty search results must show CYLTableViewPlaceHolder's placeholder on all six platforms (documented done). Documented pin `62e40c0` (stale, 12.1).

### 6.2 CYLTabBarController (di/dependencies.md:5-91, skill cyl-tabbar-integration)
- Example default: tab bar from a **local config file** + plus button with a **plus child view controller**; page providers registered per page ID in `CYLTabBarPageRegistry.sharedRegistry` before `+[CYLTabBarController tabBarControllerWithConfigurationFile:error:]`; handle the error with a fallback root; missing page ID skips that tab.
- Keys: `CYLTabBarControllerTabBarItemsAttributes` (even count, plus excluded; else `CYLPlusButtonIndexInTabBar`), `CYLTabBarControllerPlusButton` with `CYLTabBarItemTitle/Image/PageIdentifier`. Tap action code-only: `+configurationWithContentsOfFile:error:`, add `CYLTabBarControllerPlusButtonAction`, `-initWithConfiguration:`.
- Pin: `scripts/latest-cyl-commit.sh` (`--podfile` prints the line) before every build; never version/branch/tag; if fetch fails keep pin and say so. Exception (owner 2026-11-17): a PR branch already merged into the newest branch does not count even if it later gets a newer commit (example: take `9a54e26`, merge of #814 into #788, not `47aec88`). This repo and ClassifyMenu pin the same commit.
- Import only `<CYLTabBarController/CYLTabBarController.h>`; search pages sit in a `UINavigationController` tab; `Sources/` must not import it; `CYL` prefix for new example classes; clean derived data after dependency changes (check symbols with `strings <app>/<binary> | grep <sym>`).
- Upstream docs are bilingual (read [EN]); precedence code > docs > README; link at pinned commit. Rules adapted from upstream `caf3c92` (branch `feat/cross-platform-components`, 2026-11-11).
- Raised plus button preferred in demos: `CYLPlusButtonCenterYMultiplier` < 0.5 with button taller than half the bar, or `CYLPlusButtonCenterYOffset`; fully tappable (`touchableRect`); never cover content. Android example: 56 dp, multiplier 0.3 (cyl-plus-button:105-110).

### 6.3 Plus button limits (skill cyl-plus-button)
- Required: title, image, page ID. Optional: selected title/colour/image, identifier, title colour/font. Layout: IndexInTabBar, CenterYMultiplier/Offset, AlignsTitle, KeepsTitleVisible, ShowsSelection, Size, ImageSize, BackgroundImage. One per `CYLTabBarControllerContext`. Code registration only on request (`+[CYLPlusButton cyl_registerPlusButtonWithAttributes:action:context:]`; subclass `+registerPlusButton` before any controller, never in `+load`).
- Aligned title requires a title (otherwise on Liquid Glass the button covers the whole tab item); do not align with a title drawn on a background image or with no title. Aligned on Liquid Glass: `currentTitle` is nil, read plus child's `tabBarItem.title`.
- Liquid Glass (iOS 26+, non-FlatDesign): real button + stand-in draw only the normal image; `+isLiquidGlassActive` is YES even with FlatDesign on iOS 26 so guard both; badges via library only.
- Images drawn original, never tinted; background-image button takes no theme icon; late image changes must match launch; `plusButton.reportsTapsToDelegate` (default YES); `cyl_userInteractionDisabled`, `cyl_shouldNotSelect` deprecated; do not override `-touchableRect` to return frame; touch-taking subviews win (#202); `CYL_NAVIGATION_TITLE_FOLLOWS_TAB_BAR_ITEM(vc)`; accessibility label required.

Troubleshooting (cyl-verify:51-58):

| Symptom | Fix |
|---|---|
| tab missing | register provider first; read NSError |
| no plus child VC | add PageIdentifier in plus dict and a provider |
| "cannot find ... in scope" after pod update | `pod install` |
| pod install "Unicode Normalization not appropriate for ASCII-8BIT" | `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install` |
| statusBarStyle no-op warning | remove `UIViewControllerBasedStatusBarAppearance = NO` |
| simulator taps dead | shutdown, boot, retry |

## 7. Build, test, verify: exact commands

### 7.1 iOS (skill cyl-verify, di/testing.md, di/macos.md, cyl-xcode-compat)
- `pod install`; parse `ruby -rxcodeproj -e 'Xcodeproj::Project.open(ARGV[0])' CYLSearchExample.xcodeproj`; build shared scheme from the generated workspace; `xcodebuild analyze` + test. Do not claim a visual fix without launching on a simulator; report warnings, missing simulator checks, toolchain overrides.
- Local CI replica (cyl-verify:66-74):
```sh
scripts/ci-checkout-dependencies.sh        # sibling CYLTableViewPlaceHolder at ../
scripts/check-public-api-comments.sh
scripts/pod-lint.sh lib --verbose
rm -rf build && scripts/ci-build-example.sh build
scripts/ci-build-example.sh analyze        # warnings in Sources/ fail CI
scripts/unit-tests.sh "iPhone 17"
shellcheck scripts/*.sh && actionlint
```
- CI `.github/workflows/ios.yml`: PRs, pushes to `master` and `claude/**`, manual; runner `macos-26` unless `MACOS_RUNNER`. Name the environment in reports. New scripts pass shellcheck; workflow changes pass actionlint.
- `scripts/pod-lint.sh push` is the only publish path and only when explicitly invoked (README:223-225); validation scripts never publish (scripts/instructions.md:4-5).
- Xcode: `objectVersion = 46`, compatibility "Xcode 3.2" (CI opens with Xcode 26), explicit file refs (no synchronized groups), shared xcscheme under `CYLSearchExample.xcodeproj/xcshareddata/xcschemes/`, iOS 15.0 app/test/pods, consistent bundle IDs, AppIcon + `UILaunchStoryboardName` (copy from `CYLTabBarController/Example/Images.xcassets` if missing). Do not start from an Xcode template.
- Podfile header: `platform :ios, '15.0'`, `ENV['SWIFT_VERSION'] = '5'`, `project '<name>.xcodeproj'`; exactly one trailing `post_install` hook:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
    end
  end
end
```
- macOS shell is zsh (no word splitting of unquoted vars): run scripts with bash (`bash script.sh` or heredoc), or `${=box}`/arrays (di/macos.md:45-52).
- Do not set `UIViewControllerBasedStatusBarAppearance = NO`; no orientation limit in code (cyl-new-project:39-40).
- Folder rules: `CYLSearchExampleTests`: Swift, one `XCTestCase` subclass of `CYLSearchExampleTestCase` per area, helpers in `CYLSearchExampleTestSupport.swift`; one ObjC file `CYLSearchCoreObjectiveCSmokeTests.m` stays; update explicit target refs. **API fence**: `CYLSearchAPIFenceTests.swift` (public import, no `@testable`) + ObjC fence name every public/@objc member; add lines for new members, never delete (`docs/qmui-search-controller.md` phase 0). `CYLSearchViewController/` holds only shared assets (icon, `CYLPlusButton`, `CYLLaunchScreen.storyboard`, the original GIF, keep unchanged); no source there. `Resources/`: keep resources in shipped bundle with notices. `CYLSearchExample/`: refresh only via `CYLSearchView` API; keep pbxproj refs and test header search path in sync. Sources core stays independent of the example; module `CYLSearchViewController`; bundle `CYLSearchViewController.bundle` keeps all files (other platforms import them).

### 7.2 HarmonyOS (skill cyl-harmonyos-setup, di/windows.md, di/harmonyos.md)
- Target: HarmonyOS NEXT 6.0.1 (API 21) min and target, ArkTS + ArkUI V2 (`@ComponentV2`), DevEco Studio 6.0.1 (machine checked 2026-11-16: build `DS-243.24978.46.36.601251`, `C:\Program Files\Huawei\DevEco Studio`). API = iOS names, `harmonyos/entry` = 1:1 iOS example, internals ported from Android Kotlin. Resources via `harmonyos/scripts/import-ios-resources.py`; scorecard `python3 scripts/harmonyos-scorecard.py` over `docs/harmonyos-cross-platform.md` until no TODO.
- Env (PowerShell): `$env:DEVECO_SDK_HOME = 'C:\Program Files\Huawei\DevEco Studio\sdk'`; prepend `...\DevEco Studio\jbr\bin` and `...\sdk\default\openharmony\toolchains` (`hdc.exe`) to PATH.
- hvigor rejects spaces / non-ASCII: mirror `harmonyos/` to `C:\cylbuild\harmonyos` (repo path became ASCII 2026-11-17 but still has spaces). `ohpm install` first.
- Prereqs: 64-bit Win10/11 or Apple silicon; VT-x/AMD-V; Hyper-V + HypervisorPlatform + VirtualMachinePlatform (`Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All,HypervisorPlatform,VirtualMachinePlatform -All`, restart); check `(Get-CimInstance Win32_ComputerSystem).HypervisorPresent` (`VirtualizationFirmwareEnabled` reads False under a hypervisor, expected); 16 GB RAM min; Huawei ID; Device Manager privacy accepted (`deviceManager.xml` `isConfirmPrivacyStatement true`); **region CN**.
- Region: `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml` (mac `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/`) must contain `<application><component name="CountryRegionSetting"><countryregion name="CN"/></component></application>`. Close the IDE before editing (it rewrites on exit); original kept as `.bak-NZ`. Doc status 2026-11-16: CN; HypervisorPresent True; 64 GB.
- Emulator: Mate 70 Pro, 6.0.1 (API 21), image `phone_all_x86` in `%LOCALAPPDATA%\Huawei\Sdk\system-image`; instances `%LOCALAPPDATA%\Huawei\Emulator\deployed`; download lock in `...\Sdk\.temp` (do not delete while IDE runs). `hdc list targets` (~`127.0.0.1:5555`); `[Empty]` -> wait or `hdc kill` / `hdc start` from DevEco toolchains.
- No signing for emulator (2026-11-16): `signingConfigs` empty, install unsigned HAPs, ask for nothing; signing only for device/release on request.
- **x86_64 emulator (2026-11-22)**: Rive (`@ohos/rive`) and PAG (`@tencent/libpag`) are arm64-only, install fails "install parse native so failed … Abi type". Build:
```sh
hvigorw --mode module -p module=entry@emulator -p product=default assembleHap
hvigorw --mode module -p module=entry@ohosTest -p isOhosTest=true -p buildMode=emulatorTest -p product=default assembleHap
unzip -l entry/build/default/outputs/emulator/entry-emulator-unsigned.hap | grep arm64-v8a   # must print nothing
hdc install <outputs/emulator/entry-emulator-unsigned.hap>
hdc install <outputs/ohosTest/entry-ohosTest-unsigned.hap>
hdc shell aa test -b com.cyl.search.harmonyos -m entry_test -s unittest OpenHarmonyTestRunner -s timeout 40000
```
Phones/arm64/release: `default` target, `-p buildMode=test`. Fix only in build profile (never drop Rive/PAG, never edit `overrides`, never filter `default`); Rive/PAG show stills on x86 (state in report and footer). After sub-repo sync delete mirror `build`, `.hvigor`, `oh_modules` (robocopy `/XD` keeps them; stale build once dropped an export). **Git Bash robocopy**: set `MSYS2_ARG_CONV_EXCL='*'` for robocopy only (hvigor fails silently with it), quote Windows paths; a failed robocopy prints usage and keeps the old mirror, so verify mirror `oh-package.json5` commits (2026-11-22 a stale mirror passed tests at old pins) (cyl-harmonyos-setup:139-145).
- Arm64 test plans (2026-11-22, di/harmonyos.md:34-63): **Plan 1** in CYLTabBarController `cylanimateditem` only: x86_64 Rive/PAG built from official sources (`rive-app/rive-runtime`, `Tencent/libpag`) with URL/commit/license recorded; use only when `deviceInfo.abiList` is x86_64; order compile -> no crash/no regressions -> playback; keep behind debug build guard; **removing guard needs user approval** with evidence. **Plan 2** if plan 1 fails: hand to the macOS session, log in task-log. cylanimateditem owns the x86 test recipe, still-image fallback and tests; local build profile is a stopgap.
- Host checks without emulator: `node harmonyos/scripts/host-logic-test.mjs` (Node >= 22.18; keep `CYLSearchLogic.ets` free of kit imports); `node harmonyos/scripts/check-ios-parity.mjs` (exit 1 lists gaps); `node harmonyos/scripts/check-accessibility-i18n.mjs`; `node harmonyos/scripts/import-cyltabbar-localizations.mjs` after CYLTabBarController strings change (never overwrites the four iOS languages). Report unverified without emulator/device.

### 7.3 Android, Flutter, React Native, mini program
- Android: `cd android/merged && ./gradlew assembleDebug` (JDK 17) (README:74-75). `cylsearch` module package `com.cyl.search`.
- Flutter: `flutter test`; example `flutter build apk --debug` (JDK 17), `flutter build ios --simulator`. Android composite build of `../../android/merged` forces one AGP version; iOS uses CocoaPods (SPM off), static frameworks (flutter README:59-68).
- React Native: library+example Yarn workspaces (no npm for dev): `yarn`, `yarn example start|android|ios|web|build:web`, `yarn typecheck`, `yarn lint [--fix]`, `yarn test`, `yarn release` (release-it); Node per `.nvmrc`; Xcode `example/ios/CylsearchExample.xcworkspace`, sources under Pods > Development Pods > react-native-cylsearch. Conventional commits fix/feat/refactor/docs/test/chore with pre-commit hook; small PRs, discuss API changes in an issue (CONTRIBUTING.md). **Windows**: clone to a short path or enable `LongPathsEnabled` (CMake/ninja exceed 260 chars; junction does not help); Android SDK path without spaces; `JAVA_HOME` JDK 17 (21 unsupported); after the CYLTabBarController pin changes delete `vendor/CYLTabBarController/CrossPlatform/react-native-cyltabbar/android/build` (prefix `\\?\` with `Remove-Item -LiteralPath ... -Recurse`) or build fails "Cannot access ...: it is internal in file" (RN README:46-55). The RN example README is the stock React Native template (`npm start`, `npm run android|ios`, `bundle install`, `bundle exec pod install`).
- Mini program: `npm test` (node --test), `npm run import-ios`, `npm run sync-example`, `scripts/devtools-screenshots.js` (automator), `npm pack` (publishes `src/`, README, LICENSE) (mini README:182-190).

## 8. Documentation, screenshots, parity, translation rules (di/docs.md, skill cyl-docs, cyl-api-parity)

- README: update when dependency setup, reproduction steps or public integration change; append/revise only the relevant section, preserve existing material and links; repo-relative paths; never claim unverified simulator results (cyl-docs:19-26). CYLTabBarController changes go in README and `docs/CYLTabBarController-Integration.md`.
- **Every** screenshot (local or CI/CD) is committed under `docs/assets/` and shown in a related `docs/` file; original pixels, cropped, never downscaled/enlarged; raw may live in `docs/assets/raw/`.
- Current layout rule (2026-11-18): one column, several rows; if taller than one phone screen (e.g. 2622 px iPhone 17/18 Pro sim, 2400 px 1080x2400 Android; full-width crops: cell width x 19.5/9) use two columns (left-right then down); never more than three in one row (di/docs.md:58-64). This replaces the 2026-11-12 order (top-to-bottom, two columns, one row of max three).
- Header band (bold red #FF3B30 on white, English, 1-2 lines): platform + OS + device; IDE/SDK; host OS if relevant; library and repo commits, branch; date (time zone when comparing); purpose. Red caption per panel (state, timing, measured result). Dark-gray footer (pass/fail, bug no., repro details). Bands never cover pixels (di/docs.md:65-84).
- Every committed image is stitched, even single: macOS `swift scripts/stitch-screenshots.swift --header "<l1>\n<l2>" --footer "<r>" --out docs/assets/<name>.png "<shot>.png=<caption>" ...` (`--columns auto`, `--screen-height <px>`); Windows `powershell -ExecutionPolicy Bypass -File scripts/stitch-screenshots.ps1 -Header "..." -Footer "..." -Out docs/assets/<name>.png "<shot>.png=<caption>"`. Header/footer stored in PNG "Description" (`CYL header: ... | CYL footer: ...`).
- Check: `sh scripts/check-screenshot-labels.sh` (staged) or with `BASE HEAD`; fails if not PNG, no header/footer, not shown by any Markdown, or showing line lacks date (YYYY-MM-DD) and commit. CI `.github/workflows/screenshot-labels.yml`.
- The document line with the image link carries platform, device and OS, SDK/IDE, host OS, library commits, date+time+zone (di/docs.md:110-111).
- Milestones (TODO/Linux note removable, PR mergeable, no known bug): update README screenshot section.
- **API parity**: table (source API | description | target counterpart, `TODO` default); score = non-TODO/rows x 100 with dated score log; match existing code -> score -> implement (core first, then example copying source's) -> rescore until 100, then reverse table; same logic and names. Tables: `docs/ios-api-alignment.md` (Android -> iOS), `docs/android-api-alignment.md` (iOS -> Android, written by `android/merged/scripts/api-alignment.py`). Prefer a script listing source public API.
- **Translated projects**: merge their open PRs (before translating, or translate+merge after); open-issues table (link | description | status `TODO`, read date); DONE with commit or N/A with reason; score until 100; translation may start at 60; applies to all platforms (di/docs.md:144-176).

## 9. Accessibility, localization, licenses, naming, code style

### 9.1 Accessibility / i18n (all platforms; 2026-11-16)
- Every tappable/readable control has a localized label (hint if unclear); tappable rows are one element; no hard-coded user text; fix gaps **first** (di/accessibility-i18n.md:41-76).
- HarmonyOS: `accessibilityText` or Text child; decorative `accessibilityLevel('no')`; touch >= 44 vp via `responseRegion`; list position/selection (`accessibilityDescription`, `accessibilitySelected`); announce invisible state changes (`sendAccessibilityEvent` / `announceForAccessibility`); `$r('app.string.…')`, defaults `ResourceStr`; en/ja/zh-Hans/zh-Hant from iOS, others from CYLTabBarController table filtered to used texts.
- iOS announcements `UIAccessibility.post(.announcement)`; example label `multisearch.item` "Search 2 of 3" (cyl-accessibility-i18n:23-27).
- UI tests locate by label/localized text from app resources first, id only if unlabeled, coordinates last. HarmonyOS helpers `findByLabel` (`ON.text` then `ON.description`), `tapLabel`, flow test `searchFlowByLabels` in `CYLSearchUI.test.ets`; iOS `app.buttons[label]`; Android `withContentDescription/withText` from `R.string`. Note: di/accessibility-i18n.md:73-75 also lists identifiers/`.id()` first in its third wording.

### 9.2 Licenses (2026-11-17; di/licenses.md, cyl-license)
MIT, "Copyright (c) 2015 ChenYilong"; root `LICENSE` is the source, copies byte-identical; manifest declares MIT; third-party notices (`NOTICE`, `LICENSE.<source>`, `ICON-SOURCES`) beside it. Check `bash scripts/check-licenses.sh` (CI "Public API comments" job); new package adds a script line and table row. Record `docs/licenses.md`.

| Package | License location |
|---|---|
| CocoaPods | `LICENSE` + `Resources/CYLSearchViewController.bundle/LICENSE` |
| Android `cylsearch` | `src/main/resources/META-INF/cylsearch/LICENSE` (POM licenses block to add when publishing config exists) |
| ohpm | root `LICENSE` + `src/main/resources/rawfile/CYLSearchViewController.bundle/LICENSE` |
| npm RN | root |
| npm mini | root + `src/LICENSE` |
| pub Flutter | root (iOS podspec points at it) |

### 9.3 Naming (cyl-naming, re-evaluated 2026-11-22; SonarCloud S100/S101/S115/S116/S117)
- Swift public types keep `CYL`; internal/private none. Own-type members: lowerCamelCase, no prefix. `@objc` extension members on system/third-party types: `@objc(cyl_name)`, Swift name `cylName`; public Swift-only extension: `cyl` camel prefix; private: none. No new global functions (static members; C names kept via `@_cdecl`). Constants `static let` lowerCamelCase.
- Renames: keep ObjC name, add `@available(*, deprecated, renamed:)` Swift forward one release (only those may stay Sonar-flagged; `// NOSONAR` does not work in Swift).
- Kotlin: classes CYL; members unprefixed; companion constants UPPER_SNAKE. ArkTS/JS/TS: exported classes CYL. Mini: keep `cyl-` component tags. RN: keep `Cylsearch`/`CYL` on native component/module names. Dart: classes CYL; channel/view-type ids reverse-domain or `cyl`.
- Check: `grep -rnE "func [A-Za-z0-9]*_|func [A-Z]" Sources CYLSearchExample CYLSearchExampleTests` lists only kept forwards.
- ObjC categories: `<SystemClass>+CYL<Feature>.h/.m`.

### 9.4 Swift and comments (di/code-style.md, cyl-verify:16-24, cyl-docs:42-61)
- Follow `docs/swift-coding-standard.md` + vendored skills; translation score in `docs/swift-migration.md`; keep ObjC class names/selectors via `@objc(...)`.
- Public API comments: official language rules win; one block directly above; even one-liners are three lines; never `/*! Text. */`, never trailing `/**< */ /*!< */ ///< //`; one format per file. ObjC/C `/*!`; Swift/Kotlin/Java/TS/JS `/** */`; Python PEP 257; Go `//`; C# `///` XML; Rust `///` (`//!`); Dart `///`. Check `bash scripts/check-public-api-comments.sh`.

## 10. Public usage examples and API facts

### 10.1 iOS (README.md; claims)
Files table (README:123-127): `CYLSearchBarView.swift` (`CYLSearchBarView`, `mode = CYLSearchBarModeMultiple`; `CYLSearchBarItem` drawn by ClassifyMenu `CYLTagButton`, `animationURL`; delegate), `CYLSearchView.swift` (`CYLSearchView` + delegate + `CYLSearchViewDataSource`), `CYLSearchResources.swift` (resources, `CYLSearchSuggestionCache(+Policy)`). Main thread only.
```swift
let searchView = CYLSearchView()
searchView.resultsDataSource = dataSource
searchView.showsEmptyResultsPlaceholder = true
searchView.showSearch(in: navigationController ?? self)

let bar = CYLSearchBarView()
bar.mode = .multiple
bar.delegate = self // searchBarView(_:didCompleteSearch:at:), didSelectSearch, didRemoveSearchAt, textDidChange(_:at:)
bar.addSearch("Rive")

CYLSearchView.setRefreshHandler({ [weak self] in
    self?.reload { CYLSearchView.endRefreshing(in: table) }
}, for: table)
```
- With a data source and non-empty query, `resultsTableView` lists `searchResults`; call `reloadResults`; delegate `searchView:didSelectResult:`; close `closeSearchAnimated:completion:`. Instance refresh `refreshHandler/beginRefreshing/endRefreshing/isRefreshing`; class `setRefreshHandler(_:for:)/beginRefreshing(in:)/endRefreshing(in:)/isRefreshing(in:)`. End on every completion path, capture weakly.
- Extra names (cyl-api-map:13-21): multiple mode `searches, selectedSearchIndex (NSNotFound), isEditingNewSearch, newSearchButton, beginNewSearch(), completeSearch(), addSearch(_:), selectSearch(at:), removeSearch(at:)`; `showSearch(in:animated:)`, `closeSearch(animated:completion:)`, `searchOpen` (ObjC `isSearchOpen`).
- Placeholders: `CYLPlaceholderView` (styles, messages, custom image/text), `CYLPlaceholderStackView` scenarios via `CYLSearchView.emptyResultsScenario/emptySuggestionsScenario`; `UITableView (CYLTableViewPlaceHolder) -cyl_reloadData`, `CYLTableViewPlaceHolderDelegate`.
```objc
[[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleNoResults message:CYLPlaceholderMessageNoInternet];
[[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleEmpty text:@"Your message"];
[[CYLPlaceholderView alloc] initWithImage:yourImage text:@"Your message"];
```
- `CYLSearchResources`: Pod bundle images, localized strings with preferred-language fallback to English; en, zh-Hans, zh-Hant, ja; caller can request a language.
- Local pod: `pod 'CYLSearchViewController', :path => '../CYLSearchViewController'`. The podspec `0.1.0` is **unpublished** (README:200-202). Module `CYLSearchViewController`, iOS 15+.
- Animated icons: core plays nothing itself; add engine subspecs pinned by commit (README:134-145):
```ruby
pod 'CYLTabBarController', :subspecs => ['CYLAnimatedItem', 'CYLAnimatedItemSVGA'], # or …LottieSwift, …PAG, …Rive, …GIF
    :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '<sha>'
pod 'CYLTableViewPlaceHolder', :subspecs => ['Core', 'Lottie'],
    :git => 'https://github.com/ChenYilong/CYLTableViewPlaceHolder.git', :commit => '<sha>'
```
(Pod naming differs from the podspec/root Podfile, which use the separate pod `CYLAnimatedItem`; see 12.) Fallback order: animation; else static image/selectedImage (no engine, unknown type, missing/corrupt file, failed or in-progress download); placeholder only for animation-only items. Without engine `playAnimation()` is a no-op. iOS remote URLs: Rive and SVGA yes; Lottie/PAG/GIF local only. Android all engines read URLs; app adds SVGAPlayer/Lottie/libpag/rive-android and `placeholder-lottie`; core gets `io.github.chenyilong:cyltabbarcontroller-animateditem` via ClassifyMenu.
- Example: `pod install`, `open CYLSearchExample.xcworkspace`; root tab bar from `CYLSearchExample/CYLTabBarConfiguration.json`. README describes "Search and refresh", "Repro: OFF/ON", "Overlay" (stale, 12.1). The original iOS 12.3 inset-loop report has **not** been reproduced (README:115-116, :219-221).

### 10.2 Android summary (README:68-90)
`CYLSearchView.suggestionStyle`: tags (default since 2026-11-22, two rows with fold control as last tag) or list. `android/merged` = one Gradle project: five translated libraries, `cylsearch` (CYLSearchBarView.kt, CYLSearchView.kt, CYLSearchResources.kt; refresh from `:placeholder-refresh`), example with CYLTabBarController and raised plus. Docs `docs/android-and-cross-platform.md`, `docs/android-api-alignment.md`.

### 10.3 Flutter (flutter README + CHANGELOG 0.1.0)
Platform views (`UiKitView`; Android hybrid composition). `CYLSearchView` props `suggestions, suggestionStyle, placeholder, query, showsSuggestionsForEmptyQuery, submitsOnSuggestionSelection, showsEmptyResultsPlaceholder, emptyResultsScenario, results, refreshEnabled, controller`; events `onTextChanged, onSubmitted, onSuggestionSelected, onSelectResult, onRefresh, onClose`; `CYLSearchViewWidgetController.beginRefreshing/endRefreshing/isRefreshing/reloadResults` (filter `results` yourself; end refresh on every path). `CYLSearchBarView` (height about 48; 56 for multiple): `placeholder, text, showsCancelButton, fieldShadowOpacity, searchBarStyle, items, mode, searches, controller`. `CYLTagListView(tags:, onTagSelected:)` sizes to content. Theme brightness follows the app. Push the search page full screen.
CHANGELOG 0.1.0 (single undated release; newest entry first): phase 5 merge adds `scrimColor`, `noResultsText`, `resultMatchHighlightColor` (case/diacritic-insensitive), `onWillShow/onDidShow/onWillClose` (`onClose` = did close), native launch area, `setQuery(query, submit:)`, `leadingView`/`trailingAccessoryViews`; removed Dart overlays and the unreleased `dimmingColor, onUpdateResults, onWill/DidPresent, onWill/DidDismiss, showEmptyView, hideEmptyView, isEmptyViewShowing, ...AccessoryView`. Earlier: moved to merged core (results, refresh, multiple mode, controllers; iOS pod no longer declares CYLTableViewPlaceHolder), added `CYLTagListView`, first version. Launch image assets: replace files in the imageset or use `open ios/Runner.xcworkspace` (stock text).

### 10.4 React Native (RN README)
Fabric components. `npm install react-native-cylsearch`. `CYLSearchBarView` (`placeholder, text, items, mode single|multiple, searches, onTextChange(text,index), onSubmit, onCompleteSearch, onRemoveSearch, onSelectSearch`); `CYLSearchView` (`suggestions, suggestionStyle, results, onSelectResult, refreshEnabled, refreshing, onRefresh, onClose`); `CYLTagListView` (`tags, foldControlPosition, onTagSelect`). Text events come through `e.nativeEvent.text`; refresh is controlled (`setRefreshing(true)` ... `finally(false)`). MIT; scaffold create-react-native-library. CODE_OF_CONDUCT = Contributor Covenant 2.1 (enforcement ladder Correction, Warning, Temporary Ban, Permanent Ban).

### 10.5 WeChat mini program (package `cyl-search-miniprogram`)
- Components `<cyl-search-bar>`, `<cyl-search>` + modules `core/CYLSearchBarView.js`, `CYLSearchView.js`, `CYLSearchResources.js`; four languages.
- Install: `npm i cyl-search-miniprogram`; copy `cyl-placeholder` and `cyl-refresh` (from CYLTableViewPlaceHolder `CrossPlatform/wechat-miniprogram-cylplaceholder`) to `miniprogram_npm/cyl-placeholder-miniprogram/` (not on npm; else compile error "component not found in the path: …/cyl-refresh/index", checked 2026-11-19); copy ClassifyMenu `.../cyl-tag-list-miniprogram/miniprogram_dist` to `miniprogram_npm/cyl-tag-list-miniprogram/` (`cyl-tag-button` draws bar items; vendors `cyl-animated-item`); DevTools > Tools > Build npm. `usingComponents` paths `cyl-search-miniprogram/<component>/index`; or copy `src/` as `components/` and `require('/components/index')`.
- JS exports: `CYLSearchBarView, CYLSearchBarItem, CYLSearchBarMode, CYLSearchView, CYLSearchViewDelegate, CYLSearchViewDataSource, CYLSearchSuggestionStyle, CYLSearchResources, CYLSearchSuggestionCache, CYLSearchSuggestionCachePolicy, cylFoldTags, cylNavigationMetrics, cylClampAnimationSpeed, cylFormatString`.
- Animation players are abstract nodes `cyl-lottie-view/cyl-pag-view/cyl-rive-view/cyl-svga-view` passed with `generic:...`; else the item shows `image`. GIF: `gifFirstFrame, gifLastFrame, gifDuration` (0 = registered, else 1000 ms); `animationAutoplay` (default false), `animationEmbedded` (false).
```html
<cyl-search-bar placeholder="Search" searchBarStyle="bordered" items="{{items}}" bind:focuschange="openSearch" bind:itemselect="onItem" />
<cyl-search id="search" suggestions="{{suggestions}}" suggestionStyle="tags" showsEmptyResultsPlaceholder cacheName="MySearch"
  results="{{results}}" refresherEnabled bind:textchange="onText" bind:selectresult="onResult" bind:refresh="onRefresh" bind:submit="onSubmit" />
```
`openSearch(){ this.selectComponent('#search').showSearch() }`; refresh `load().finally(() => this.selectComponent('#search').endRefreshing())`.
- Bar props (README:86-98): `mode` (single|multiple), `value, placeholder, focus`, `searchBarStyle` (plain|bordered), `items`, `navigationIcon` (none|arrow|search), `shows{Cancel,Voice,Submit,Clear}Button, showsSearchIcon`, look (`fieldHeight 36, fieldCornerRadius -1`, ...), `secure, maximumTextLength 0, minimumTextLength 3, returnKeyType search`, `editable` (false -> `tapwhilenoteditable`), `iconified, iconifiedByDefault, iconPosition trailing, expansionAnimation fade, animationDuration 0.3`, `searchIndicatorColor, unselectedSearchAlpha 0.5, searchFieldWidth 160`. Events `textchange, submit, focuschange, cancel, itemselect, navigationtap, voicetap, tapwhilenoteditable, iconifiedchange`; multiple `completesearch, removesearch, selectsearch`. Methods `setText(text,submit), setIconified, showKeyboard, hideKeyboard, beginNewSearch, completeSearch, addSearch, selectSearch, removeSearch, searches`. Slots `leading, trailing`.
- `<cyl-search>` (:108-130): `suggestions, suggestionStyle` (tags default, was list until 2026-11-22), `cacheName CYLSearchView, focusesSearchFieldOnShow, closesOnSubmit` (true), `results null, showsResultsForEmptyQuery, refresherEnabled, inline, hidesSearchBarWhenScrolling, showsEmptyResultsPlaceholder, emptyResultsScenario NoSearchResults, emptySuggestionsScenario NoContent, emptyPlaceholderAnimated, animationSpeed, animationLoops, showsContent` (slot content; page already scrolls, do not add scroll-view), `coversNavigationBar` (custom nav style). Events `show, close, submit, textchange, suggestionselect, selectresult, refresh, focuschange, voicetap, itemselect`. Methods `showSearch, closeSearch, isSearchOpen, setQuery, setResultsDataSource({searchViewResultsForQuery, searchViewConfigureResultCell?}), reloadResults, searchResults, setRefreshHandler, begin/endRefreshing, isRefreshing, emptyResultsView, emptySuggestionsView, playAnimationFromStart`; static refresh variants take component or `CYLSearchView`. Abstract `cyl-empty-view`; slots `content, placeholder-footer`.
- QMUI layer (opt-in, :132-161): `CYLSearchBar, CYLSearchBarAppearance (default(), styles(), copy()), CYLSearchController(+Delegate), CYLSearchTableViewController, CYLSearchNavigationBar, CYLSearchTagListStyle/Header`; `resultMatchHighlightColor, resultsHeaderTitleProvider, resultsHeaderTextColor, suggestionCacheFooterTitle, setSnapsHeader(), suggestionCache(), observeHistory()`. Bar: `centersPlaceholder, textFieldMargins/active..., cancelButtonMargins/active..., set*MarginsProvider, cancelButtonFont, setShowsCancelButton`, slots leading/trailing (+ old accessory aliases), `showsLeadingView, showsTrailingAccessoryViews` (old `showsLeading/TrailingAccessory` deprecated). Search: `showsSearchBar`+`showsContent` list screen (`hidesSearchBarInitially, hidesSearchBarWhenEmptyViewShowing, snapsHeaderSearchBar`), `showsSuggestionsLaunchView` (wins over `showsLaunchView`/slot `launch-view`), `scrimColor, highlightsResultMatches, noResultsText, supportsSwipeToDismissSearch` (24 px edge, 10 px slop); events `updateresults, will/didpresent, will/diddismiss, historychange`; methods `setActive, isActive, showEmptyView, hideEmptyView, isEmptyViewShowing, history, clearHistory`. Parity: `docs/qmui-search-controller.md`.
- `cyl-search-navigation-bar` (custom navigation style; measures width around capsule via `cylNavigationBarWidthsFrom`; slot for the bar): props `showsBack` false, `backLabel`, `autoBack` true (calls `wx.navigateBack()` after `back` event); metrics in `data.metrics` / `cylNavigationMetrics()`; fieldHeight 36.
- `cyl-search-refresh-button`: tag-list header refresh (built-in svg, label key `cyl_tagList_refresh`: Refresh/更新/刷新/重新整理); prop `label`, event `tap`; test `test/cyl_search_refresh_button_label.test.js`.
- Example: open `CrossPlatform/wechat-miniprogram-cylsearch` in DevTools; `miniprogramRoot example/miniprogram/`; beforeCompile/Preview/Upload run `node scripts/sync-example.js` (copies src; installs tab bar/Lottie, placeholder, tag list at `package.json` commits; override with `CYL_TABBAR_DIR, CYL_PLACEHOLDER_DIR, CYL_CLASSIFYMENU_DIR`). DevTools refuses `touristappid`: own AppID in git-ignored `project.private.config.json`. 1:1 copy of iOS example (same tabs, pages, en/ja/zh-Hans/zh-Hant, data, images via `scripts/import-ios-resources.js`, never retype; same task as iOS change; platform-forced differences listed in `docs/miniprogram-api-alignment.md`) (di/miniprogram.md:5-14). Dark mode follows system.



_Continues in [part 2](F-rules-skills-readmes-part2.md)._
