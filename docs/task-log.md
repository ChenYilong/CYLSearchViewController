# Task Log

Tasks that have no better home in `docs/` are logged here (`AGENTS.md`,
"Task log before every task"). A task that belongs to a feature is logged in
that feature's document instead. Each entry starts as `TODO` before the work
begins and becomes `DONE` when it ends.

## DONE (2026-11-12): log every task in docs/ before starting it

- Context: the user runs several Claude sessions on this repository at once,
  and a session can stop mid-task (context limits, restarts, another session
  taking over a branch or the simulator). The next session needs to find
  what was asked and how far it got.
- Requirements:
  - Write the rule into the instruction files (`AGENTS.md`,
    `instructions.md`, folder `instructions.md` files) and the skills, in
    English.
  - Before any task: find the most suitable document in `docs/`, add the
    task there marked `TODO`, with the detailed context, the user's
    requirements and the user's prompt; then start the task.
  - When the task ends, mark it done.
  - Purpose: no context is lost when a task is interrupted.
- Prompt (verbatim): "写入instructions相关文件，skills相关文件，开始任何任务前总是找到docs里的合适文档，现将任务标记为TODO ，给出任务详细上下文以及我的要求，我的提示词，再开始任务，目的是防止任务中断后，丢失上下文，无法找到上下文。任务结束后再标记TODO为已完成。"
- Prompt (English): "Write into the instruction files and the skill files:
  before starting any task, always find a suitable document in docs/, first
  mark the task as TODO with the task's detailed context, my requirements
  and my prompt, then start the task. The purpose is to avoid losing the
  context when a task is interrupted. When the task ends, mark the TODO as
  done."
- Result: the rule is in `AGENTS.md` ("Task log before every task"),
  `instructions.md`, `docs/instructions.md`, the folder `instructions.md`
  files (`CYLSearchExample/`, `CYLSearchExampleTests/`,
  `Sources/CYLSearchViewController/`, `scripts/`) and all seven `cyl-*`
  skills; `cyl-docs` adds how to pick the document. This entry was logged
  first (commit `eb0ce70`), as the rule requires. Branch
  `feat/search-bar-view`.

## DONE (2026-11-12): merge PR #6, then PR #5, after CI

- Context: PR #6 (`docs/todo-sweep` → `feat/search-bar-view`) holds one
  commit, `29fdf24`: the scene life cycle (the example did not launch when
  built with the iOS 27 SDK), page titles that renamed their tabs, and
  `scripts/public-api-doc-coverage.sh`. PR #5 (`feat/search-bar-view` →
  `master`) holds CYLSearchBarView, the CYLTabBarController example and the
  search bar placement rule. The duplicate tab bar integration that was on
  `docs/todo-sweep` was dropped (local tag `backup/todo-sweep-935da41`).
- Requirements: wait until CI has finished, merge #6 into
  `feat/search-bar-view`, then wait for #5's CI and merge #5 into `master`.
- Prompt (verbatim): "CI结束后，合并分支，以下分支 #5 feat/search-bar-view → master … #6 docs/todo-sweep → feat/search-bar-view (its source)"
- Prompt (English): "After CI finishes, merge these branches: #5
  feat/search-bar-view → master, and #6 docs/todo-sweep →
  feat/search-bar-view."
- Result: #6 passed CI (6/6 jobs, run 43112176663) and was merged into
  `feat/search-bar-view` (merge commit `51a0e39`). #5 passed CI on
  `ac03541` (6/6 jobs) and was merged into `master` (merge commit
  `55022ba`).

## DONE (2026-11-12): retarget every open PR to the current branch, merge, keep only it

- Context: current branch `feat/swift-core` (PR #8 → `feat/search-api-parity`). Open PRs: #7
  (`feat/search-api-parity` → `master`), #8, and #2 from a fork (`master` → `master`, "Fix broken headings in
  Markdown files"). Remote branches `claude/youthful-mendel-pn01ru`, `docs/todo-sweep`, `feat/search-api-parity`
  and `feat/search-bar-view` have no commit that `feat/swift-core` lacks.
- Requirements: point every open PR at `feat/swift-core`; merge them all into it, resolving conflicts; keep only
  the current branch (delete the others; `master` stays as the default branch); then continue the unfinished tasks.
- Prompt (verbatim): "将所有处于open状态的分支的target branch指向本分支，当前分支，全部合并仅仅保留当前分支，处理冲突后合并，继续以上未完成的任务。"
- Prompt (English): "Point the target branch of every open branch at this branch, the current branch; merge them
  all and keep only the current branch; merge after resolving conflicts; continue the unfinished tasks above."
- Result: #2 (fork, README heading fix) retargeted to `feat/swift-core` and merged (`e9ca91e`). #7 could not be
  retargeted (GitHub: no new commits; all of `feat/search-api-parity` is in `feat/swift-core`), so it was closed
  with a note. #8 (`feat/swift-core`) now targets `master`. Remote branches `claude/youthful-mendel-pn01ru`,
  `docs/todo-sweep`, `feat/search-api-parity` and `feat/search-bar-view` (each with 0 commits missing from
  `feat/swift-core`) were deleted; `feat/swift-core` and `master` (the default branch, which cannot be deleted)
  remain. Local branches and worktrees of this session were removed. The shared working folder is still on the
  local `feat/search-bar-view` of another session and was not touched.

## DONE (2026-11-14; TODO 2026-11-12): pull request for the clean sibling checkout

- Context: while building, the sibling `CYLTableViewPlaceHolder` had another session's uncommitted, half-finished
  `CYLRefresh/Custom/Drawn/` folder, so this session built against a clean detached checkout of its last commit
  (`18971fe`) in its own scratch folder. That checkout has no changes of this session.
- Requirement: "then create a PR that merges into the current branch".
- Prompt (verbatim): "found an uncommitted, half-finished Drawn/ folder in the sibling's working tree, so I'm building from a clean checkout of their last commit in my own folder instead. then create pr merge to current branch"
- Status: logged; to check what can be put in a PR (this session changed nothing in the sibling).
- Status: DONE (2026-11-14): nothing to put in a pull request: the clean checkout had no changes of this session.
  The work built against it went in through this repository's own pull requests (#6 merged, then #8).

## DONE (2026-11-12): rule for open PRs and issues of projects we translate

- Context: `android/` holds Kotlin transcriptions of five GitHub projects, made from their default branches without
  their open pull requests and issues (`docs/android-and-cross-platform.md`).
- Requirements: write a rule (English) into the instruction files and the skills: when a document of this project
  links to another project's GitHub repository for translation or similar work, merge that project's open PRs
  (before translating; or, when the translation is done, translate the open PRs and merge them in); list its open
  issues in a `docs/` table (issue link, description, fix status, default `TODO`); find each issue's counterpart in
  our code and fix it; score after each fix until 100. Translation may start once the issues reach 60. The same rule
  applies on every platform.
- Prompt (verbatim): "写入一条规则到。instructions相关文件和skills文件中，全英文写入以下规则：如果本项目文档中出现了 非本项目的 GitHub 链接，切该链接是用来 做代码翻译等任务的，那么在翻译过程前，或者翻译过程后，需要 访问该GitHub 的 pr 链接，将处于open状态的pr合并进来。并且为该项目的issues页面，中处于open状态的issues在docs文件夹下相关文档，如果没有就新建文档中制作表格，第一列为issue地址 第二列为issue描述，第三列为修复状态，默认填TODO。你需要找到这些issue在我们项目代码中的对应项，尝试修复。issues修复完为满分，每修复一个issue打一次分，一直到满分为止。 举例说明：比如：本项目的android文件夹内，存在多个其他项目翻译为kotlin的任务，这些任务均默认翻译master分支代码，忽略了pr与issues内容，如果翻译任务还未开启那么就先 merge 该项目处于open状态的pr，再尝试解决open issues，只要issues处理状态达到60分，就可以开始翻译工作，翻译完成后，再开始尝试解决剩余的issues到满分。如果翻译工作已经完成，那么就单独对open pr内容进行翻译后，再merge到我们的项目中。基于翻译过的代码还是要处理issues。一直到满分。其他平台同样规则执行。"
- Prompt (English): "Write a rule into the instruction files and the skill files, all in English: if this project's
  documents contain a GitHub link that is not this project's, and the link is used for code translation or similar
  tasks, then before or after translating, visit that GitHub project's PRs and merge the open ones in. For the open
  issues on its issues page, make a table in a related document in docs (create one if none): first column the issue
  link, second the issue description, third the fix status, TODO by default. Find each issue's counterpart in our
  code and try to fix it. All issues fixed is full marks; score after each fixed issue until full marks. Example: the
  android folder has several projects translated to Kotlin, all from the master branch, ignoring PRs and issues. If a
  translation has not started, first merge the project's open PRs, then try to solve the open issues; once the issue
  status reaches 60 the translation may start, and after it, solve the remaining issues to full marks. If the
  translation is already done, translate the open PRs' content separately and merge it into our project, and still
  handle the issues on the translated code, until full marks. Other platforms follow the same rule."
- Result: the rule is in `AGENTS.md` ("Open pull requests and issues of projects we translate"), `instructions.md`,
  `docs/instructions.md`, `android/README.md` and every `cyl-*` skill. Applying it to the five projects in `android/`
  (their translation is done: translate and merge their open PRs, then the issue tables and fixes) is a follow-up
  recorded in `docs/android-and-cross-platform.md`.

## DONE (2026-11-16; TODO 2026-11-12): CYLTableViewPlaceHolder as a sub-repository on every platform

- Logged in [sub-repositories.md](sub-repositories.md) (context, requirements, prompt verbatim and in English).
  Done on every platform (2026-11-16): see the DONE entry in [sub-repositories.md](sub-repositories.md).

## DONE (2026-11-16; TODO 2026-11-14): finish the unfinished CYLSearchViewController tasks, then every `TODO` in the documents

- Context: after the search bar items work (`7d254d6` to `6a9b5d9`), several entries in `docs/` still say `TODO`:
  some are done but their status line is stale, some are open (the native iOS Discover screenshot, the "iPhone Duo"
  overlap, the iOS example's raised plus button, React Native touch checks and tab bar, the sibling-checkout pull
  request, Android's animated placeholder, HarmonyOS, mini programs).
- Requirements: 1) from the memory files and the local memory documents, continue and finish the unfinished tasks
  of CYLSearchViewController; 2) go through every document, find the keyword `TODO`, and complete all `TODO` work.
- Prompt (verbatim): "根据Memory 以及本地Memory文档，尝试继续完成对于 CYLSearchViewController 我们未结束的任务，然后遍历所有文档，找到关键词TODO 完成所有TODO工作。"
- Prompt (English): "From Memory and the local Memory documents, try to continue and finish our unfinished tasks for
  CYLSearchViewController, then go through all documents, find the keyword TODO and complete all TODO work."
- Order (oldest instruction first): the sibling-checkout pull request (2026-11-12); the "iPhone Duo" overlap; the
  iOS raised plus button; the tag-style, placeholder, cache and focus entries (status lines against what is done);
  React Native; the search bar items' last screenshot; HarmonyOS; mini programs.
- Status: DONE (2026-11-16). Every item of the order is done: the sibling-checkout pull request; the "iPhone Duo"
  overlap (`search-bar-view.md`); the iOS raised plus button; the tag-style, placeholder, cache and focus entries; React
  Native (touch checks and tab bar, `android-and-cross-platform.md`, Open TODOs 5/5); the native iOS Discover screenshot
  (`assets/ios-discover-tab.png`); Android's animated placeholder (CYLTableViewPlaceHolder PR #28, pin `6d8b264`);
  HarmonyOS (Scorecards 1 to 3 at 100, the last screenshot checks listed in `harmonyos-cross-platform.md`); mini programs.
  Left outside this entry: SVGA tab icons in the React Native example (`CYLTabBarController-Integration.md`).
- Progress (2026-11-14, usage limit reached mid-task):
  - Sibling-checkout pull request: DONE (entry above).
  - Android animated placeholder: not started here on purpose. CYLTableViewPlaceHolder's Android port is in progress
    in another session (its PR #28, `6ef5000`: the full scenario catalog and `CYLPlaceholderView` with
    `CYLPlaceholderAnimationPlayer` / `registerAnimationFactory`); `CYLPlaceholderStackView` does not play the
    scenarios' animations yet. When it does, `cylsearch` registers a Lottie factory and pins that commit.
  - iOS raised plus button: the iOS configuration file has no keys for it (Android has `CYLPlusButtonSize`,
    `CYLPlusButtonCenterYMultiplier`); on iOS it needs a `CYLPlusButton` subclass (`+multiplierOfTabBarHeight:`), and
    on iOS 26 the plus button is drawn by its tab item in the glass bar. A CYLTabBarController feature gap: open.
  - Native iOS Discover screenshot: `-CYLDemoTab 4` is Discover (2 is the plus page); the retake was running.
  - Not started: the "iPhone Duo" overlap, stale status lines (cache, focus, tag style, placeholder sub-repository),
    React Native touch checks and tab bar, HarmonyOS (0/323), mini programs. The React Native example's
    `Podfile.lock` still names `a96e9d2`; `pod install` updates it to `bdd78c7`.
- Progress (2026-11-14, later):
  - "iPhone Duo" overlap: DONE (`c9d1da3`): core fix in both search screens; iPhone 17 26/26, iPhone Duo 26/26.
  - Status lines of the cache, focus, tag style and placeholder entries: updated (`b073588`).
  - Search bar items: DONE (all four Discover pages screenshotted).
  - HarmonyOS: API table 397/397, 100/100 by the script (`db5481f`), library compiles; not run (no emulator device),
    no example app or tests yet.
  - React Native tab bar: wiring works for yarn, Metro, TypeScript and `pod install`; blocked on iOS by a
    CYLTabBarController header bug (details in `docs/android-and-cross-platform.md`); fix goes in that repository first.
  - Still open: mini programs; Android animated placeholder (waits for CYLTableViewPlaceHolder PR #28); iOS raised
    plus button (CYLTabBarController gap); React Native touch checks (no tap tool: `axe` is gone); HarmonyOS example
    app and tests.
- Progress (2026-11-15): React Native tab bar DONE (`94b6621`, CYLTabBarController `2a12582`); CYLTableViewPlaceHolder
  pinned at `c202b8c` (`04611dc`); mini program package, first increment (`c3f82f9`); HarmonyOS example app (`2da246e`);
  raised plus button on iOS 26: the config keys have no effect, see `docs/CYLTabBarController-Integration.md`.
  What remains needs something this machine lacks or another repository's decision: WeChat DevTools (mini program
  components, an example), a HarmonyOS device and hypium (tests, screenshots), a tap tool (React Native touch checks),
  CYLTableViewPlaceHolder's Android port (animated placeholder), CYLTabBarController (raised plus with a title on
  Liquid Glass). The headings above say IN PROGRESS where part is done.

- Progress (2026-11-15, later): React Native touch checks DONE (`a3f48b0`): the tap tool is xcodebuildmcp's bundled
  `axe` (`/opt/homebrew/Cellar/xcodebuildmcp/2.7.0/libexec/bundled/axe`); typing filters to "Swift", "More" unfolds.
  Still blocked: WeChat DevTools, a HarmonyOS device with hypium, CYLTableViewPlaceHolder PR #28, CYLTabBarController
  raised plus on Liquid Glass.
- Progress (2026-11-15, Android animated placeholder): DONE. The user set the order of what remains: the Android
  animated placeholder, then the raised plus button, then the mini program components, then HarmonyOS.
  CYLTableViewPlaceHolder PR #30 → PR #28's branch (`af23ea0`); Android pin moved; details and screenshot in
  `docs/core-todo.md`. Prompt: "Android animated placeholder: CYLTableViewPlaceHolder PR #28 merged with a Lottie
  animator. order is 3。4 1 2。"
- Progress (2026-11-15, raised plus button): skipped by the user's choice; stays TODO in
  `docs/CYLTabBarController-Integration.md`.
- Progress (2026-11-15, mini program): WeChat DevTools is installed and logged in. Added the example
  (`CrossPlatform/wechat-miniprogram-cylsearch/example`, `scripts/sync-example.js`) and a DevTools screenshot script
  (`scripts/devtools-screenshots.js`, miniprogram-automator). Not run: auto mode refused to launch the logged-in
  DevTools from this session; the user runs the script. Component rendering is still unverified.
- Progress (2026-11-15, HarmonyOS): an emulator is deployed (Mate 70 Pro, HarmonyOS 6.0.1, API 21), but there is no
  signing material (`build-profile.json5` `signingConfigs` is empty; no `.p12`/`.cer`/`.p7b` under `~/.ohos` or
  DevEco's support folder). A HarmonyOS emulator installs only signed HAPs, so the example run, the hypium tests and the
  screenshots wait for automatic signing in DevEco Studio (Huawei ID sign-in, then Project Structure > Signing Configs >
  "Automatically generate signature").
- Progress (2026-11-15, mini program, run by the user's go-ahead "item1自行执行 脚本"): the example runs in WeChat
  DevTools through `scripts/devtools-screenshots.js`. Fixed on the way: `cyl-search` recursed without end (its
  `sync()` wrote the `suggestions` property, whose observer calls `sync()`; the drawn list is now `shownSuggestions`);
  the example uses the AppID of CYLTabBarController's mini program example, since the tourist AppID cannot be automated.
  Verified: bar with items, search page with the empty-cache placeholder and the keyboard down, `submit: Swift`;
  screenshot `docs/assets/miniprogram-search-devtools.png`. Node tests 8/8. Still open: a search icon image in the
  field; Lottie in the mini program placeholders.
- Progress (2026-11-15, mini program core and example): DONE, see `docs/miniprogram-api-alignment.md` (397/397, the
  tab bar example, screenshot). The HarmonyOS project moved to `~/develop/CYLSearchViewController-swift-core/harmonyos`
  (the `feat/swift-core` worktree) for the user to open in DevEco Studio.
- Progress (2026-11-15, mini program playback controls and DevTools Skills, branch `feat/swift-core-next`): DONE, see
  `docs/miniprogram-api-alignment.md` ("playback controls on the animated placeholders"); verified in WeChat DevTools
  through `wechatide-skill`, Node tests 17/17.
- Progress (2026-11-15, mini program AppID): the example's AppID is local only, as the user chose: `project.config.json`
  keeps `touristappid` (DevTools refuses it), the real one is in the git-ignored `example/project.private.config.json`.
  Verified in DevTools: `wx.getAccountInfoSync()` reports the private AppID, the example renders, no console error.

- 2026-11-15 DONE: CYLTableViewPlaceHolder PR #28 merged into master (merge commit `7bc27a1`) at the user's
  go-ahead ("Merge PR #28 to master"). The Android pin `6d8b264` is now on master. HarmonyOS run still waits for
  DevEco signing (`signingConfigs: []`).

- 2026-11-15 DONE: HarmonyOS example on the emulator without signing. Prompt: "请使用模拟器 开发鸿蒙 忽略签名 继续开发"
  (use the emulator for HarmonyOS, ignore signing, keep developing). hvigor `assembleHap` skips signing and builds
  `entry-default-unsigned.hap`; `hdc install` accepts it on the Mate 70 Pro emulator (HarmonyOS 6.0.1, API 21),
  and `aa start` opens it. Screenshots (commit `ca56d68`, original 1316×2832), top to bottom:
  1. ![Discover](assets/harmonyos-discover-emulator-unsigned.jpeg)
  2. ![Search, empty cache](assets/harmonyos-search-empty-cache-emulator-unsigned.jpeg)
- Progress (2026-11-15, "小程序example层要一比一复刻", branch `feat/swift-core-next`): DONE. The mini program example is a
  1:1 copy of the iOS example (tabs, pages, texts in four languages, data, images, interactions), with the core
  components it needed (`d19e0bb`); see `docs/miniprogram-api-alignment.md`. Verified in WeChat DevTools: 18 pages,
  11 interactions, no console error; Node tests 26/26.
- Progress (2026-11-15, "将searchviewcontroller封装为一个小程序库", branch `feat/swift-core-next`): DONE, modeled on
  CYLTableViewPlaceHolder's `wechat-miniprogram-cylplaceholder`: the DevTools project and the sync hooks at the package
  root (the AppID moved to the package's git-ignored `project.private.config.json`), `package.json` entry and files,
  MIT `LICENSE`, README; checked with `npm pack` in a new mini program (Build npm), which found and fixed three
  library-only faults. See `docs/miniprogram-api-alignment.md`. Node tests 30/30.
- Progress (2026-11-15, iOS CI, branch `feat/swift-core-next`): the example build failed in CYLTabBarController's
  `CYLTabBarManifest.swift:812` (`remote ?? dictionary`, two optionals of different types) at the pinned `2a12582`.
  The newest commit on any branch (`scripts/latest-cyl-commit.sh`), `c006143` on `feat/cross-platform-components`,
  fixes that line; its own `pod lib lint` and unit tests pass. Podfile and Podfile.lock now pin `c006143` (same version
  1.100.0 and subspecs; the lock's spec checksum is refreshed by the next `pod install`, which CI runs). The 4 commits
  of `fix/flutter-plus-title-hidden` that `c006143` lacks are Flutter/React Native work; the Flutter and Android pins
  stay on `2a12582`.
  Fixed ("fix 1"): the emulator runs in zh-CN; the library was localized ("暂无数据" is its zh_CN string) but the
  example hard-coded English. The example strings are now resources (`entry/.../base` and `zh_CN/element/string.json`),
  read with `getStringByNameSync`; the screenshots above are retaken in Chinese. Open: hypium tests not run yet.

- 2026-11-15 DONE: HarmonyOS hypium tests on the emulator. Prompt: "Run tests". There were none, so this adds
  `harmonyos/entry/src/ohosTest` (TestAbility, OpenHarmonyTestRunner, `CYLSearchCore.test.ets`: cache order and
  duplicates, maximum count and blanks, `none` policy, localized strings, placeholder kinds, search bar items),
  the `ohosTest` target in `entry/build-profile.json5` and `@ohos/hypium` 1.0.21. Run (unsigned):
  `hvigorw -p module=entry@ohosTest -p isOhosTest=true -p buildMode=test assembleHap`, `hdc install` both HAPs,
  `hdc shell aa test -b com.cyl.search.harmonyos -m entry_test -s unittest /ets/testrunner/OpenHarmonyTestRunner`.
  Result on the Mate 70 Pro emulator (HarmonyOS 6.0.1, API 21): Tests run: 6, Failure: 0, Error: 0, Pass: 6.

- 2026-11-15 DONE: HarmonyOS UI tests. Prompt: "ui tests". `entry/src/ohosTest/ets/test/CYLSearchUI.test.ets` drives
  the example with `@kit.TestKit` `Driver` (strings read from resources, so it passes in any system language):
  Discover shows its title and search bar; "Open search" (id `CYLSearchDiscoverOpenSearch`) shows the empty
  placeholder; typing "Kot" lists Kotlin and hides Flutter; Back returns to Discover.
  Bug found and fixed: the system Back gesture never closed the search page (the second press left the app). New core
  API `CYLSearchView.handleBackPress()` closes an open search view and returns true; the example page's
  `onBackPress()` returns it. Core test `handleBackPressOnlyWhenOpen` added.
  Result on the Mate 70 Pro emulator: Tests run: 11, Failure: 0, Error: 0, Pass: 11.

- 2026-11-15 DONE: Back gesture on the other HarmonyOS search views. Prompt: "check others". Same gap in
  `CYLSearchController` (the overlay stayed on Back) and `CYLMultiSearchView` (typing never ended on Back); neither
  is in the example, so they are covered by core tests. New API: `CYLSearchController.handleBackPress()` hides the
  presented overlay like its Cancel button (calls `searchControllerDidCancel`); `CYLMultiSearchView.handleBackPress()`
  ends the search being typed like `completeSearch`. `CYLSearchResultsViewController` is shown inside
  `CYLSearchController`, so it needs nothing. Tests `controllerHandleBackPressOnlyWhenPresented` and
  `multiSearchHandleBackPressCompletesTyping`; result on the emulator: Tests run: 13, Pass: 13.

- 2026-11-15 Screenshot: Back closes the search page (Mate 70 Pro emulator, HarmonyOS 6.0.1, API 21, unsigned,
  commit `82797a4`, originals 1316×2832 stacked top to bottom): the search page with "Kot" typed, then Discover after
  one Back press (the keyboard was already hidden).
  ![Back closes the search page](assets/harmonyos-back-closes-search-emulator.jpeg)

- 2026-11-15 Back gesture parity on Android and mini programs. Prompt: "screenshot back continue" (the screenshot was
  already in; continued with the parity check offered next).
  - Android: `CYLSearchView` and `CYLSearchController` already close on Back (`OnBackPressedCallback`).
    `CYLMultiSearchView` did not: Back only hid the keyboard. DONE: a callback enabled while `isInSearchMode` ends
    the typed search like `completeSearch`; Robolectric test `CYLMultiSearchBackTest`; `:cylsearch` tests 17/17.
  - Mini program: the back button or gesture left the page with the search page open. `cyl-search` now holds a
    `page-container` while open, so back closes the search page (`onBackLeave`). The example's plus page (the only
    non-tab page) gets an "Open search" button to show it. Verify in WeChat DevTools (2026-11-21: still open, but not by
    automation: `page-container` intercepts the user's back gesture and the navigation bar's back button, and the automator
    can only call `wx.navigateBack`, which `page-container` does not intercept, so an automated run proves nothing; the plus
    page is a tab page now, so the check needs a non-tab page with `<cyl-search>` and a real back tap in DevTools or on a
    phone; listed as a user check in "fix every open TODO in docs"; 2026-11-22: WeChat DevTools' automation tools have no
    native back action either (`automation_navigate` `navigateBack` is the same API). Manual steps: open
    `CrossPlatform/wechat-miniprogram-cylsearch/example` in DevTools, Examples, "MiguelCatalan" (`pages/materialSample`, a
    non-tab page with `<cyl-search>`), open the search, tap the navigation bar's back arrow (or a phone's back gesture):
    expected, the search closes and `materialSample` stays; a second back leaves the page) — the run stopped at
    "Login is required" (APPID_ERROR); the check script is `back-test.js` (navigateTo plus, open, navigateBack,
    expect plus still shown with the search page closed).
- Progress (2026-11-15, "先把本项目的example 丰富到与iOS端保持一致再考虑发布npm", branch `feat/swift-core-next`): DONE.
  The mini program example now shows CYLTableViewPlaceHolder's scenario placeholders and CYLRefreshNormalHeader, as
  iOS, and follows dark mode; see `docs/miniprogram-api-alignment.md`. Publishing to npm waits for the user.

- 2026-11-16 DONE: Android / React Native / Flutter TODO table in `docs/android-and-cross-platform.md` ("Open TODOs").
  4 of 5 rows done (two stale status lines fixed); the raised plus button stays TODO (user skipped it 2026-11-15).
  Prompt (verbatim): "找到跨端，相关文档，找到以下android端 rn端 flutter端，的TODO事项，汇总成表格第一列为找到的内容，第二列默认TODO，每每完成一项就删除一个TODO 没有TODO视为满分一直完成到满分。"
  Prompt (English): "Find the cross-platform docs, collect the Android, RN and Flutter TODOs into a table (first column:
  what was found; second column: TODO by default); remove a TODO each time one is done; no TODO = full score; keep going
  until full score."
- 2026-11-16 DONE: raised plus button in the React Native example (`alignsTitle: false`); Android/RN/Flutter table 100/100. Prompt: "continue do plus".
- 2026-11-16 DONE: RN raised plus icon green again (52 pt PNG instead of `imageSize`, which drew the SF Symbol black). Prompt: "green".
- 2026-11-16 DONE: RN plus title color follows the text color (black / white in dark mode). Prompt: "title black".
- 2026-11-16 TODO logged: SVGA animations + one SVGA demo per Rive demo, `docs/CYLTabBarController-Integration.md`.
- 2026-11-16 IN PROGRESS: SVGA TODO, 12 Rive scenes listed (0/12). Prompt: "start svga".
- 2026-11-16 DONE: SVGA rows 1-2 (iOS tab icons from keys and from a config file), 2/12. Prompt: "go ios svga".
- 2026-11-16 DONE: SVGA row 3 (FlatDesign on iOS 26.3, classic on iOS 17.5), 3/12. Prompt: "go flat classic".
- 2026-11-16 DONE: SVGA rows 4-5 (dark files, plus page), 5/12. Found: light after dark keeps dark SVGA files. Prompt: "go dark plus".
- 2026-11-16 DONE (no simulator, compiled only): HarmonyOS score table 397/397 = 100, the 67 UIKit-only rows now read
  `TODO: N/A on HarmonyOS: <reason>`; accessibility labels/ids on suggestions, tags, results, cancel, fold control,
  multi-search field; `cancelButtonTitle` / `navigationAccessibilityLabel` default to localized resources; "More/Less"
  localized; 5 shared strings (OK, Cancel, Default, No data, Hot) copied from CYLTabBarController into 30 new locales;
  rule "accessibility + localization everywhere, UI tests locate through them" in AGENTS.md, instructions.md,
  `cyl-verify` skill. App and test HAPs build.
  Prompt (verbatim): "在不需要模拟器的前提下开始代码开发。继续完成鸿蒙评分表。marking the rest "TODO: N/A on HarmonyOS" with a reason. 适配视觉辅助 盲人辅助 为鸿蒙代码 。 适配国际化本地化，本地化文件可以从CYLTabBarController中复制一份过来。筛选本项目用到的文字。并将下面的内容规则写入instructions相关文件并写入skills相关文件，如果相关文件不存在就新建文件确保成功。全英文写入：本项目全部代码已经支持适配视觉辅助 盲人辅助 为鸿蒙代码 。 适配国际化本地化，本地化文件。如果发现不支持请先支持，然后在自动化UI测试过程中，优先使用刚刚提到的功能进行UI控件定位。触发点击事件，或者触发复杂流程，连续操作等。"
  Prompt (English): "Without a simulator, develop code: finish the HarmonyOS score table, marking the rest "TODO: N/A on
  HarmonyOS" with a reason; add visual accessibility / screen reader support to the HarmonyOS code; internationalize and
  localize, copying the localization files from CYLTabBarController and keeping only the texts this project uses; write
  the rule (all code supports accessibility and localization; add it where missing; UI tests locate controls through
  these features first, for taps, complex flows and series of actions) in English into the instruction files and the
  skills, creating them if missing."
- 2026-11-16 DONE: SVGA rows 6-7 (SVGA animation above the Examples list; tab icon source switch), 7/12. Prompt: "go menu switch".
- 2026-11-16 DONE: SVGA Android row (pin 5682b9e, SVGAPlayer-Android, SVGA config file), 8/12. Prompt: "go android svga".
- 2026-11-16 PARTLY DONE: HarmonyOS run on the emulator (installs, starts, Examples screenshot); UI tests 10-11/13, blocked by another session using the same emulator. Prompt: "run our HarmonyOS version code on an emulator and update screenshot in docs".
- 2026-11-16 DONE: SVGA SwiftUI row (SwiftUI screen hosting the SVGA tab bar), 9/12. Prompt: "go swiftui svga".
- 2026-11-16 DONE: commit rule "git cz style, English-only commit messages, no Chinese" appended to the Commitizen
  sections of AGENTS.md and instructions.md; new skill `.agents/skills/cyl-commit` (listed in AGENTS.md). Last 30
  commits checked: no Chinese.
  Prompt (verbatim): "写入instructions相关文件以及skills，找到commit规范，如果没找到就新建，寻找关键字 git cz，如果没有就新建，如果有就追加以下规则：全英文写入： git cz 风格提交，全英文commit 不允许出现中午。 continue"
  Prompt (English): "Write into the instruction files and the skills: find the commit conventions (create them if missing),
  look for the keyword git cz (create if missing, append if present), and add in English: commit in git cz style,
  English-only commit messages, no Chinese allowed. continue"
- 2026-11-16 DONE (iOS): SVGA Flutter row, 10/12; plugin platform views made @MainActor for the new pin. Prompt: "go flutter svga".
- 2026-11-16 PARTLY DONE: HarmonyOS re-run with the new tab bar: builds (after sync-sub-repositories + ohpm install), runs, Search screenshot; taps did not reach the app, other tabs not captured. Prompt: "run our HarmonyOS version code on an emulator and update more screenshot in docs".
- 2026-11-16 DONE: rule "prefer bash for scripts (zsh does not split unquoted variables)" in a new section of
  AGENTS.md, instructions.md and the `cyl-verify` skill.
  Prompt (verbatim): "写入instructions相关文件，skills相关指令，找到脚本执行的相关章节，没有的话就新建，保证写入成功：全英文写入：优先使用bash 执行脚本 避免以下错误zsh doesn't split $box into words either. Running the same measurement as a bash script."
  Prompt (English): "Write into the instruction files and the skills, in the script-running section (create it if
  missing), in English: prefer running scripts with bash, to avoid this error: zsh doesn't split $box into words
  either. Running the same measurement as a bash script."
- 2026-11-16 DONE: open PRs #11 (feat/harmonyos-parity -> feat/swift-core) and #8 (feat/swift-core -> master) checked
  for sync: both branches had the same tree (3f4981e), so nothing was cherry-picked; this entry is committed on both.
  Prompt (verbatim): "将所有处于open状态的pr 互相cherry pick 保持所有pr保持代码同步" / "log both"
  Prompt (English): "Cherry-pick all open PRs into each other so every PR keeps the same code." / "log both"
- 2026-11-16 BLOCKED: HarmonyOS next-page screenshots: the current build ignores all touches and the CYLDemoTab launch parameter (BUG TODO in docs/android-and-cross-platform.md). Prompt: "run our HarmonyOS version code on an emulator and push next page update more screenshot in docs".
- 2026-11-16 DONE: HarmonyOS pushed-page screenshots (Examples + 4 pages, Tag style, Discover, plus page); the "ignores touches" BUG TODO was wrong (stale uitest dumpLayout), corrected. Prompt: "continue "fix harmony touch".
- 2026-11-16 DONE: rule "every branch with commits has an open pull request; check before each commit; base = the
  previously active pull request's branch, else master; ask the user when more than two pull requests are open" in
  AGENTS.md ("Commit readiness"), instructions.md ("Pull requests for new branches") and the `cyl-commit` skill.
  Applied: PR #8 (feat/swift-core) was closed unmerged, so feat/swift-core got a new pull request to
  feat/harmonyos-parity (PR #11, the active one).
  Prompt (verbatim): "写入instructions相关文件，skills相关指令，找到commit 的相关章节，没有的话就新建，保证写入成功：全英文写入：创建分支后有任何commit必须提交pr。不允许只新建分支，持续向该分支commit代码，但不创建pr。因为不创建pr会导致该分支上的所有commit代码全部被忽略。 commit前必须检查该分支pr是否处于open状态，如果不处于open状态必须新建pr。target 目标优先设置为 在创建pr前的活跃pr，如果没有才设置为master分支。如果open状态的pr已经超过两个，那么就要慎重，你需要询问我，是否新建分支创建pr还是保持在本分支继续提交。因为超过两个分支会导致代码合并困难，无法合理分配分支的目标分支。"
  Prompt (English): "Write into the instruction files and skills, in the commit section (create it if missing), in
  English: any branch with commits must have a pull request; never keep committing to a branch without one, because
  its commits are ignored. Before committing, check that the branch's pull request is open; if not, open one. Target:
  the active pull request from before, else master. When more than two pull requests are open, be careful and ask me
  whether to create a new branch with a pull request or keep committing on this branch, because more branches make
  merging hard and leave no sensible target."
- 2026-11-16 DONE: rule extended: at the end of every exchange, on any branch other than master / main, commit and push
  without asking (AGENTS.md, instructions.md, `cyl-commit` skill, under the pull request rule). PR #12 is open for
  feat/swift-core.
  Prompt (verbatim, new part): "一次问答结束后，只要当前分支不是master main，则必须commit 必须push ，无须询问，因为代码总是在分支上，并不会push 到master main分支。非常安全。无须担心push后的任何风险。"
  Prompt (English): "After every exchange, as long as the current branch is not master / main, commit and push without
  asking: the code is always on a branch and never pushed to master / main, so it is safe; no need to worry about any
  risk after pushing."
- 2026-11-16 DONE: HarmonyOS Rive crash fix via pins (CYLTableViewPlaceHolder 76762c6, CYLTabBarController c795d08); every platform checked. Prompt: "...learn from it update our 鸿蒙os core component library to fix crash..."

## DONE (2026-11-18; TODO 2026-11-18): rules for starting a task, scoring it, other sessions and hung emulators

- **Branch**: `feat/harmonyos-parity`.
- **Context**: `AGENTS.md` and `instructions.md` already have "Task log before every task", and four skills point to it
  (`cyl-api-map`, `cyl-docs`, `cyl-new-project`, `cyl-plus-button`). No rule yet for the session's TODO header,
  acceptance scores, checking other sessions or restarting hung emulators.
- **Requirements**:
  1. Before a task: mark `TODO` and the current branch at the top of the session; write the task into the most
     suitable `docs/` document with acceptance criteria (what full marks are, what a pass is).
  2. Score the work; do not stop before a pass; keep scoring until it passes. Say why it is not full marks, print the
     missing points as `TODO`s at the end of the session, and update the document written at the start.
  3. Check other sessions first (read their tasks, usually marked `TODO` at the top of their session): if none is
     editing the same branch, go on; if one is, check whether the task is a duplicate.
  4. An emulator that stays hung until restarted: tell the other sessions first, then restart it. An emulator that
     does not open: restart first. Restart from the command line without asking.
  5. Written in English, in the instructions files and the skills; create files where none exist.
- **Acceptance**: full marks (100) = the rules in `AGENTS.md`, `instructions.md`, a skill of their own, the skills
  table and the four skills' task-log sections, all consistent, committed and pushed. Pass (60) = the rules in
  `AGENTS.md`, `instructions.md` and a skill, committed and pushed.
- **Prompt** (verbatim): 找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：找到开始任务先标注todo写入文档的相关描述没有就新建该规则，如果有就插入以下规则：开始任务前总是在任务顶部标注TODO 以及当前分支，并找到合适的文档将任务写进docs文档以及验收评分标准什么是满分，什么什么是及格，不达到及格不允许中断任务，一直打分到及格为止。并标注为什么打不到满分，并将缺失的分数以TODO的形式打印在会话结束末端。并更新任务开始时写入的文档。看看 check other sessions first read their task ，第一步看看有没有session在编辑相同分支，如果没有就继续，如果有继续坚持任务是否重复。usually marked as TODO at top of 会话， 遇到 emulator stays hung until it's restarted,  please tell the other sessions first, then restart it. 遇到模拟器打不开的情况优先使用重启策略。无须询问是否重启直接命令行执行重启。
- **Prompt** (English): Find this project's instructions files and skills files; create them if missing so the write
  succeeds; write in English. Find the rule about marking a task TODO in a document before starting; create it if
  missing, else insert: before a task, always mark TODO and the current branch at the top; write the task into a
  suitable docs document with acceptance criteria (what is full marks, what is a pass); do not stop before a pass,
  keep scoring until it passes; say why it is not full marks and print the missing points as TODOs at the end of the
  session; update the document written at the start. Check other sessions first and read their tasks: first see
  whether a session edits the same branch; if not, go on; if so, check whether the task is a duplicate (usually
  marked TODO at the top of a session). An emulator that stays hung until restarted: tell the other sessions first,
  then restart it. An emulator that will not open: prefer restarting. Restart from the command line without asking.
- **Status**: done. Other sessions checked (none busy on this repository). Written: `AGENTS.md` ("Start, score and
  finish every task" under "Task log before every task"; "Emulators and simulators: restart when hung"; the skills
  table), `instructions.md` (both rules), the new skill `.agents/skills/cyl-task-start/SKILL.md` (also seen through
  `.claude/skills`), and a pointer in `cyl-docs`, `cyl-api-map`, `cyl-new-project` and `cyl-plus-button`.
- **Score**: 100 of 100 (every acceptance item done, committed and pushed); pass mark 60.

## DONE (2026-11-18; TODO 2026-11-18): stitched screenshot layout, header and footer

- **Context**: the user attached a stitched screenshot (red header "iOS 27.2, iPhone 17 Pro sim, Xcode 27.2,
  CYLTabBarController dcbfdec6 (ef1d0313), feat/harmony, 2026-11-18. Rive tags at rest (no play)"; one caption above
  each panel: "launch, no play", "11 s later, 0 changed pixels") as the example of the style to follow.
- **Prompt, verbatim**: "找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：找到截图相关规范，如果没有就新建保证写入成功，截图除了 优先选用竖版排列风格。优先两列，多行。且给拼接好的图增加header，footer，header，footer不能与截图区域重叠 覆盖，标注关键信息：关键信息也是英文，测试模拟器平台，模拟器系统版本，操作系统版本，ide 版本，以及测试目的等等。以附带的截图为例。提取截图的附带信息以及风格 完善我的描述规则。 更新截图规则，优选一列多行 如果一列拼接后长度超过普通手机的一屏幕 则两列多行"
- **Prompt, English**: find this project's instruction files and skill files (create them if missing, make sure the
  write succeeds), all in English: find the screenshot rules (create them if missing). Stitched screenshots use a
  vertical layout; give the stitched image a header and a footer that never overlap or cover the screenshots, with the
  key information in English: simulator platform, simulator OS version, host OS version, IDE version, the purpose of
  the test, and so on. Take the attached screenshot as the example: extract its information and style and refine the
  rule. Update: prefer one column over several rows; if the one-column image is taller than one screen of an ordinary
  phone, use two columns over several rows.
- **Acceptance**: the rule in `AGENTS.md`, `instructions.md`, `cyl-verify` and `cyl-docs`; `scripts/stitch-screenshots.swift`
  draws the header, the captions and the footer outside the screenshots and picks one or two columns by that height.
- **Status**: done. Written (appended, nothing removed): `AGENTS.md` ("Stitched screenshots: layout, header and
  footer", under "Screenshots of builds and CI/CD", with the user's example image
  `docs/assets/screenshot-style-example-ios27.2-rive-tags-20261118.png`), `instructions.md`, `.agents/skills/cyl-verify`
  and `.agents/skills/cyl-docs` (also seen through `.claude/skills`). `scripts/stitch-screenshots.swift` now takes
  `--header`, `--footer`, `IN.png=caption` and `--columns auto` (default; `--screen-height`). Checked on macOS 27.3:
  two full iPhone 18 Pro screenshots give 2 columns (2460 x 2869 px), three tab bar crops give 1 column; no text
  touches a screenshot.
- **Score**: 100 of 100 (rule in all four files, tool and check done, committed and pushed); pass mark 60.

## DONE (2026-11-18; TODO 2026-11-18): why the screenshot label rule was not applied; make it impossible to skip

- **Branch**: `feat/harmonyos-parity`.
- **Context**: the label rule ("Labels" in "Screenshots of builds and CI/CD", 2026-11-12) and the header / footer rule
  ("Stitched screenshots: layout, header and footer", `a8450f7`, 2026-11-18 11:12 +13:00, from the Mac session) exist,
  but the Windows session's screenshots of 2026-11-17/18 have neither a header nor a footer and their captions miss the
  host OS, the SDK / IDE version and the time zone.
- **Root causes**: (1) the header / footer rule landed after the session read `AGENTS.md`, and no rule makes a session
  re-read changed rules; (2) the older label rule was applied only in part (platform, device, pins); (3) the only tool,
  `scripts/stitch-screenshots.swift`, runs on macOS only, so Windows sessions could not draw a header or footer;
  (4) nothing checks a screenshot before it is committed.
- **Requirements**: find why; strengthen the rule so every future screenshot follows it.
- **Acceptance**: full marks (100) = a Windows tool with the same header / footer output, a check script that fails an
  unlabelled screenshot, the check wired into the commit readiness steps and CI, the rules and skills updated (every
  screenshot, not only stitched ones; re-read changed rules at each task start), today's Windows screenshots relabelled,
  all pushed. Pass (60) = the tool, the check script and the rules updated, pushed.
- **Prompt** (verbatim): 检查为什么没有应用新增的截图Label规范，并强化该策略保证以后截图必须遵循该规范，避免再出现该问题。
- **Prompt** (English): Find out why the newly added screenshot label rule was not applied, and strengthen the policy
  so that screenshots must follow it from now on, so the problem does not happen again.
- **Status**: done. `scripts/stitch-screenshots.ps1` (Windows twin of the Swift tool, same look; both now require a
  header and footer and write `CYL header: ... | CYL footer: ...` into the PNG); `scripts/check-screenshot-labels.sh`
  (fails an added `docs/assets` image without that text, without a Markdown link, or whose link line has no date and
  commit); `.github/workflows/screenshot-labels.yml` runs it on pull requests and pushes; rules in `AGENTS.md`
  ("Screenshot labels are enforced", commit readiness, step 0 of the task start), `instructions.md`, `cyl-verify`,
  `cyl-docs`, `cyl-commit`, `cyl-task-start`. The 12 screenshots this session took on 2026-11-17/18 are relabelled
  (originals in `docs/assets/raw/`); the check passes on them.
- **Score**: 100 of 100. The Swift tool was checked on macOS 27.3 + Xcode 27.2 by the Mac session (compiles; the PNG
  carries "CYL header:"; without --header / --footer it writes nothing), and that session relabelled its two iOS
  screenshots of the day (`f8df045`). Running the check over every image added since 2026-11-18 00:00 (`4e212ed~1..HEAD`) also found
  abbreviated file names (`…-rn-search-filter.png`, `{rn,flutter}-rive-at-…`) in this session's documents; they are written
  in full with their labels now. Left to the iOS session: `docs/assets/ios-ci-animated-icons-svga.png` (`261673f`, a
  stitched iOS CI capture without header, footer or label line).

## DONE (2026-11-18; TODO 2026-11-18): remove the screenshot label check from CI

- **Prompt, verbatim**: "Remove label CI screenshots from ci"
- **English**: remove the screenshot label check (`.github/workflows/screenshot-labels.yml`) from CI.
- **Scope**: delete the workflow; keep `scripts/check-screenshot-labels.sh` and the local rule (run it before every
  commit that adds an image); the rule texts that said CI runs it now say it does not (`AGENTS.md`,
  `instructions.md`, skills `cyl-docs` and `cyl-verify`).
- **Status**: done, in the same commit.
- 2026-11-16 DONE: HarmonyOS Scorecard 3 emulator check: rows 6, 9, 16, 18, 20-23 and the SVGA row verified DONE; row 10 still fails; row 7 not reached; new row 24. Prompt: "fix 鸿蒙os TODO with emulator / fix TODO need 模拟器截图验证".
- 2026-11-16 DONE: HarmonyOS CYLTabBarController pin eba8c44; emulator run of every tab and pushed page (11 screenshots); Scorecard 3 row 10 verified DONE. Prompt: "continue then update CYLTabBatController use new commit run our HarmonyOS version code on an emulator and push next page update more screenshot in docs".
- 2026-11-16 DONE: React Native SVGA on iOS (SVGA tracker 13/13; Xcode group path fixed); HarmonyOS Scorecard 3 row 24 fixed and verified on the emulator. Prompt: "continue".
- 2026-11-17 DONE: Android check at pin c795d08 (merged: build, tests, SVGA; RN Android: builds after manifest + clean, launches; empty system: icons TODO); HarmonyOS Scorecard 3 row 7 verified. Prompt: "check android  start emulator".

## DONE (2026-11-20): screenshot-labels workflow restored

- **Prompt (verbatim)**: "ci 的xml 在最近提交中意外删除 无法在github触发ci ，请恢复"
  (English: the CI file was deleted by accident in a recent commit and CI cannot be triggered on GitHub; restore it.)
- **What happened**: `.github/workflows/screenshot-labels.yml` was removed in 86e6cc8 (2026-11-18; its message says "at the
  maintainer's request"). That commit is reverted (a68405f): the workflow and the rules that said CI no longer checks
  screenshot labels (AGENTS.md, instructions.md, skills cyl-docs and cyl-verify) are back. The entry above stays as history.
- **Other workflows**: `ios.yml` was never deleted (runs on every pull request and push). No other workflow file was removed in
  the last 3 days in CYLSearchViewController, CYLTabBarController, CollectionViewClassifyMenu or CYLTableViewPlaceHolder.

## DONE (2026-11-20): the restored "Screenshot labels" job checked this PR's whole history, not just this push

- **Context**: branch `feat/harmonyos-parity`, pull request 11. After the workflow restore above, the "Screenshot
  labels" job (run 44689036538) failed with 338 problems, almost every screenshot `docs/assets` has ever held on this
  long-lived branch (`git diff --name-only --diff-filter=A origin/master HEAD -- docs/assets` lists 269 files locally).
- **Cause**: for a `pull_request` event the job computed `BASE` from `github.event.pull_request.base.sha`, the tip of
  `master` the PR currently targets. For a branch that has lived for over a week and merged `master` only rarely, that
  diff is effectively "every screenshot this branch has ever added", not "what this push adds" — the check the
  workflow's own comment and `scripts/check-screenshot-labels.sh`'s usage line describe ("the images added between two
  commits, as CI runs it"). Relabeling hundreds of pre-existing screenshots from earlier sessions, several of which
  predate the labelling rule (2026-11-18) by days, is not something this session can do without inventing metadata
  (host OS, IDE build, exact time) it cannot verify, which the repository's rules forbid ("compilation alone is not
  completion evidence" extends to screenshot labels: a fabricated label is worse than an honest gap).
- **Fix (no relabeling needed)**: `pull_request` `synchronize` events carry `before`/`after` in the webhook payload
  (confirmed against GitHub's webhook documentation): the PR's head commit before and after this specific push. The
  workflow now prefers `github.event.before` for `synchronize`, keeping `base.sha` only for `opened`/`reopened` (a
  fresh PR, or one with no earlier push to diff against) and the all-zero fallback. This makes the check incremental,
  as the rule always intended ("Enforced... every clone runs... blocks a commit with an unlabeled screenshot"), without
  touching any of the 269 pre-existing images.
- **Verified**: `git diff --name-only --diff-filter=A <previous-push-sha> <this-push-sha> -- docs/assets` only lists
  images added by the current push (none, for this change, since it touches no `docs/assets` file); `actionlint` and a
  real run of the job are not available in this session (no macOS/act here) — the next push to this PR is the real
  test, watched after pushing.
- **Not done**: relabeling the 269 pre-existing screenshots so the check could pass unconditionally; left as future
  work if the maintainer wants the historical backlog cleared instead of (or in addition to) this incremental fix.

## TODO (2026-11-21): fix every open TODO in docs/

- **Branch**: `feat/harmonyos-parity` (pull request 11). Windows 11 session (no Xcode, no Mac); Android SDK with the API 37
  emulator, DevEco Studio with the Mate 70 Pro emulator, Flutter, Node and WeChat DevTools are available.
- **Context**: `grep TODO docs/` gives 329 lines; most are history (`DONE (…; TODO …)` headings, quoted prompts, the
  `TODO: N/A on HarmonyOS` rows that count as handled). The open items, triaged on 2026-11-21:
  1. Stale (the work is done; the note was not updated): `harmonyos-api-alignment.md` status "score 0";
     `svga-tab-icons.md` (points at a heading that is now DONE); `search-core-merge.md` "not verified yet";
     `animated-icon-component.md` (the CYLTableViewPlaceHolder `8dc39c3` pin, the HarmonyOS / mini program component,
     the verification list, the PR #814 pin note, the `57a527e` heading's status); `sub-repositories.md` status;
     `ios-api-alignment.md` "TODO" heading; `core-todo.md` "TODO: Flutter and React Native" (the editing bar exists in
     both); `task-log.md` plus-button lines.
  2. Can be done on this machine: `CYLSearchView.showsSuggestionCacheHeader` (iOS only, `swift-migration.md` step 2) on
     Android, HarmonyOS, the mini program, Flutter and React Native; Maven publishing with an MIT POM for the Android
     library (`licenses.md`); React Native forwards the tag list's drag and smear states (`CYLTabBarController-Integration.md`,
     tag drag, plan step 4); re-pin CYLTabBarController to a commit with the Android More-tab fix `c1abdffe` and re-run
     the quick-switch check (two entries of 2026-11-20); HarmonyOS Scorecard 3 row 25 on the emulator (the disk is no
     longer full: 318 GB free); the mini program back-gesture check in WeChat DevTools (`task-log.md`, 2026-11-15).
  3. Blocked here, kept `TODO` with the reason: iOS (the example's raised plus button, the Swift migration steps 2 to 4,
     Flutter iOS tag drag, the iOS More tab check) needs the macOS session; the mini program keyboard placeholder and the
     tab-switch retest need the user's phone.
- **Requirements**: fix every TODO in `docs/` that can be fixed; follow AGENTS.md (core first, tests, labelled
  screenshots, scores in each document).
- **Prompt (verbatim)**: "fix all todo in docs"
- **Acceptance**: 100 = every item of groups 1 and 2 done with evidence (tests, builds, labelled screenshots, commits
  pushed) and every group 3 item says why it is blocked and who owns it; 60 = group 1 and at least four of the six
  group 2 items.
- **Status** (2026-11-21, end of session): score 85/100, a pass. Done:
  - Group 1, all stale notes closed with their evidence (`bf1b2f8`).
  - `showsSuggestionCacheHeader` on Android, HarmonyOS, the mini program, Flutter and React Native (`efb3b78`;
    `core-todo.md`), with the three API tables back to 289 of 289.
  - HarmonyOS row 25: the emulator target runs on the x86_64 emulator; new `-p buildMode=emulatorTest` for the ohosTest
    HAP; hypium 29 of 29 (`90b3dcf`). Pull to refresh driven on the emulator (`3b1a408`).
  - Maven publication `com.cyl:cylsearch` with an MIT POM (`626e3c5`).
  - React Native `onReorderingChange` / `onSmearingChange` on Android (`1a2a7cb`). Found on the way: the React Native
    Android example did not build at all (duplicate SVGA assets), fixed in `8310962`.
  - The mini program generics note closed (a required package, checked in DevTools 2026-11-19).
  Update (2026-11-22, later): CYLTableViewPlaceHolder pinned at `a169386` and the POM mapping dropped ("pin
  CYLTableViewPlaceHolder a169386" below). The 7 points left need a manual back tap (steps in the 2026-11-15 mini program
  entry above).
  Update (2026-11-22): the 8 points below are earned (CYLTabBarController `ace1af0e` and ClassifyMenu `1f8c1001` pinned,
  the quick switch checked; "pin CYLTabBarController ace1af0e" below). Score 93/100.
  Missing points:
  - 8 points (DONE 2026-11-22): re-pin CYLTabBarController to a commit with `c1abdffe` and re-run the quick switch check. Blocked by the
    `style` name clash in CollectionViewClassifyMenu (Android and iOS). A public API decision, asked of the user by
    that repository's session, which sends the commit.
  - 7 points: the mini program back gesture on a non-tab page with `<cyl-search>`. Automation cannot press the real
    back button (`wx.navigateBack` bypasses `page-container`); it needs a tap in DevTools or on a phone.
  Still `TODO` and owned elsewhere (group 3): the iOS example's raised plus button, the Swift migration steps 2 to 4,
  Flutter iOS tag drag, the iOS More tab check, React Native iOS drag events (the macOS session, after the iOS
  ClassifyMenu callbacks); the mini program keyboard placeholder and the tab switch retest on the user's phone; Maven
  coordinates of CYLTableViewPlaceHolder's Android modules (its owner decides).

## TODO (2026-11-21): test every platform except iOS

- **Branch**: `feat/harmonyos-parity`, at `77f6503`. Windows 11 session; Android API 37 emulator (emulator-5554), HarmonyOS
  Mate 70 Pro emulator (127.0.0.1:5557).
- **Prompt (verbatim)**: "process test all platform (not include ios)"
- **Requirements**: run the tests of Android, HarmonyOS, the mini program, Flutter and React Native; report the results.
- **Acceptance**: 100 = every suite below runs and passes, and each example builds: Android `:cylsearch` unit tests and
  `:app:assembleDebug`; HarmonyOS host tests, the parity scripts, the emulator and ohosTest HAPs, hypium on the emulator;
  mini program `npm test`; Flutter `flutter test` and the Android example build; React Native jest and the Android
  example build; the repository checks (public API comments, licenses, the API tables). 60 = every suite runs, with
  failures explained.
- **Status**: DONE (2026-11-22), score 100/100. Results at `11b4b33` (pins: CYLTabBarController `41660d24`,
  CollectionViewClassifyMenu `cf478388`, CYLTableViewPlaceHolder `c84fce9`; Windows 11 Pro 10.0.22631, JDK 17):

  | Platform | Tests | Build | Runs on the emulator |
  |:---|:---|:---|:---|
  | Android | `:cylsearch` 26 of 26 (Robolectric) | `:app:assembleDebug` (clean) | launches, no crash (API 37) |
  | HarmonyOS | host logic 30 of 30; iOS parity 549 of 549; accessibility and i18n 0 problems; hypium 29 of 29 | emulator HAP and ohosTest HAP (`emulatorTest`), clean | installed on the Mate 70 Pro emulator (HarmonyOS 6.0.0.112, API 21) |
  | Mini program | `npm test` 61 of 61 | — | not run (DevTools not used in this task) |
  | Flutter | plugin 18 of 18; example 3 of 3 | `flutter build apk --debug` | launches, no crash |
  | React Native | jest 4 of 4 | `:app:assembleDebug` | launches, no crash, with the JS bundle in the APK's assets |
  | Checks | public API comments OK; licenses OK (9 files); API tables Android, HarmonyOS, mini program 289 of 289; HarmonyOS scorecard 314 of 314 | | |

  Notes: there are no instrumented (androidTest) Android tests. The React Native debug APK reads its bundle from
  assets, not from Metro, and a release build fails on Windows: ninja's object paths under
  `react-native-safe-area-context` pass 260 characters even from `C:\cylbuild\repo` (the README's known limit). So
  the run used `react-native bundle` into the mirror's assets, not committed. iOS was not tested (not part of the task).

## TODO (2026-11-22): pin CYLTabBarController ace1af0e and CollectionViewClassifyMenu 1f8c1001 on every platform

- **Branch**: `feat/harmonyos-parity`. Context: CYLTabBarController PR #822 (`CYLAnimatedItemView.style` renamed
  `itemStyle` on iOS and Android) is merged as `ace1af0e` and contains the Android More-tab fix `c1abdffe`;
  CollectionViewClassifyMenu `1f8c1001` (`feat/harmony`, PR #26) pins `ace1af0e` (message from its session).
  Closes the 8-point TODO of "fix every open TODO in docs" and the two 2026-11-20 tab switch entries in
  `CYLTabBarController-Integration.md`.
- **Prompt**: none new; it continues "fix all todo in docs" (this session's task log entry of 2026-11-21).
- **Acceptance**: 100 = every pin file moved (Podfiles, `android/merged/gradle.properties`, `harmonyos/oh-package.json5`
  and its vendor copies, the mini program `package.json`, the Flutter `pubspec.yaml`); Android, HarmonyOS, mini program,
  Flutter and React Native build and pass their tests; the quick switch to More checked at the pin with a screenshot.
  iOS (`Podfile.lock`, builds) is left to the macOS session and CI. 60 = pins moved, Android and HarmonyOS green.
- **Status**: DONE (2026-11-22), score 100/100 (the iOS part was outside this session by the acceptance). Results at the
  new pins: Android `:cylsearch` 26 of 26 and the example builds (clean); HarmonyOS vendor copies synced (`cyltabbar`
  `ace1af0e`, `classifymenu` and `cylanimateditem` `1f8c1001`), both HAPs build clean, hypium 29 of 29 on the emulator;
  mini program `npm test` 61 of 61 (after a re-sync from the pinned commits: `CYL_*_DIR` copies a local clone's working
  tree, not the pin); Flutter 18 of 18 and 3 of 3, Android example builds and launches; React Native jest 4 of 4, Android
  example builds and launches. Its first build failed with "Cannot access …: it is internal in file": stale classes in
  `vendor/CYLTabBarController/CrossPlatform/react-native-cyltabbar/android/build`, which the README says to delete after a
  pin change; deleted with `rm -rf` (a `Remove-Item` with a long-path prefix silently did nothing here), it builds. Quick
  switch to More: eight of eight correct (`CYLTabBarController-Integration.md`). Left for the macOS session: `pod install`
  (the three `Podfile.lock` files still name `41660d24`) and the iOS builds. The newer CYLTabBarController commit
  `e51743e0` (a refactor, 1 minute after `ace1af0e`) is not pinned: ClassifyMenu pins `ace1af0e`, and both repositories
  pin the same commit.

## TODO (2026-11-22): pin CYLTableViewPlaceHolder a169386 on every platform; drop the POM mapping

- **Branch**: `feat/harmonyos-parity`. Context: CYLTableViewPlaceHolder `94c7bbd` publishes its Android modules' Maven
  coordinates from their own build files (`licenses.md`), so the `pom.withXml` mapping in `cylsearch/build.gradle.kts`
  goes with the next placeholder pin. Newest commit on any branch (the pin rule in `gradle.properties`): `a169386` (its
  PR #35, onto PR #31's branch), which contains `94c7bbd` and the current pin `c84fce9`.
- **Prompt (verbatim)**: "continue fix todo"
- **Acceptance**: 100 = the pin moved in every file (Podfiles, Gradle, HarmonyOS, mini program) with the vendor copies
  synced; the mapping removed and the POM still naming `io.github.chenyilong:cyltableviewplaceholder(-refresh):0.1.0`;
  Android, HarmonyOS, mini program, Flutter and React Native build and pass their tests. 60 = pins moved, Android green.
- **Status**: DONE (2026-11-22), score 100/100 (iOS: `Podfile.lock` and builds for the macOS session, as before). At
  `a169386`: Android `:cylsearch` 26 of 26, the POM names both placeholder coordinates without the mapping, the example
  builds and launches; HarmonyOS `vendor/cylplaceholder` synced, both HAPs build clean, hypium 29 of 29; mini program
  61 of 61; Flutter 18 of 18, the example builds and launches; React Native jest 4 of 4, the example builds and launches.


## TODO (2026-11-22): pin CollectionViewClassifyMenu 881476a and CYLTableViewPlaceHolder c473fdc on every platform

- **Branch**: `feat/harmonyos-parity`. Context: newer sub-repository commits (the pin rule in `gradle.properties`: the
  newest commit on any branch). CollectionViewClassifyMenu `881476a1` (`feat/harmony`; the newer `ci-screenshots` head
  is an orphan branch of CI screenshots, not code): HarmonyOS `CYLTagButton` tints animated tag icons through
  `CYLAnimatedItemView.iconColor`. CYLTableViewPlaceHolder `c473fdc3`: docs and the iOS scenarios Podfile only.
  CYLTabBarController stays at `ace1af0e`: its newer commits (`7a39ad36`) are iOS, sample and docs changes, and
  ClassifyMenu `881476a` still pins `ace1af0e` (both repositories pin the same commit).
- **Prompt (verbatim)**: "continue fix todo"
- **Acceptance**: 100 = both pins moved in every file (Podfiles, Gradle, HarmonyOS, mini program) with the vendor copies
  synced; Android, HarmonyOS (hypium on the emulator), mini program, Flutter and React Native tests pass. 60 = pins moved,
  HarmonyOS green.
- **Status**: DONE (2026-11-22), score 100/100 (iOS: the macOS session moved the `Podfile.lock` files to `a169386` in `a53a704`; `pod install` at these two pins is theirs). Both pins
  moved in the three Podfiles, `android/merged/gradle.properties`, `harmonyos/oh-package.json5` and the mini program
  `package.json`; `sync-sub-repositories.sh` and `npm run sync-example` synced the vendor copies. Android `:cylsearch`
  26 of 26 (re-run with `--rerun`: the Android sources of both sub-repositories are unchanged); HarmonyOS both HAPs build
  from a clean mirror, hypium 29 of 29 on the Mate 70 Pro emulator, host logic tests 30 of 30; mini program 61 of 61;
  Flutter 18 of 18 and 3 of 3; React Native jest 4 of 4; `check-licenses.sh` OK. The Flutter and React Native examples
  were not rebuilt: neither pin changes Android, Dart or JavaScript code they use.

## DONE (2026-11-22; TODO 2026-11-21): fix every iOS / Swift TODO in docs/ and test with Xcode

- **Branch**: `fix/ios-swift-todos` (from `feat/harmonyos-parity`, pull request 11). macOS 27 session, Xcode 27.2, a
  dedicated iPhone simulator. Built from an APFS worktree (`/tmp/xpr/csvc-ios`; the vault volume is exFAT).
- **Context**: the Windows session's "fix every open TODO in docs/" (above) left group 3 to the macOS session. The
  iOS / Swift items open on 2026-11-21:
  1. `CYLTabBarController-Integration.md`, Status: Quick Help and the generated interface of `Sources/CYLSearchBar` not
     measured on Xcode.
  2. `CYLTabBarController-Integration.md`, raised plus button: the iOS example's plus button
     (`CYLSearchExample/CYLTabBarConfiguration.json`) is not raised; `CYLPlusButtonAlignsTitle` false is the fix React
     Native proved.
  3. `CYLTabBarController-Integration.md`, tab switch mid-animation: the iOS More tab check (more than five tabs).
  4. `CYLTabBarController-Integration.md`, tag list drag: Flutter iOS forwards the drag state.
  5. `swift-migration.md`: steps 2 (GIF comparison, legacy removal) to 4 (`CYLSearchViewControllerTests`,
     `CYLSearchExampleTests` in Swift, an Objective-C smoke test of the public API kept).
  6. Added from the Windows session's final status (merged 2026-11-21): React Native iOS forwards the tag list's drag and
     smear states (`onReorderingChange` / `onSmearingChange`, done on Android in `1a2a7cb`), after the iOS ClassifyMenu
     callbacks.
- **Requirements**: fix every iOS / Swift TODO in `docs/`; test with Xcode (build, unit tests, simulator runs with
  labelled screenshots); follow AGENTS.md (core first, examples have the lowest weight, scores in each document).
- **Prompt (verbatim)**: "fix all todo in docs about ios/swift and test with  Xcode"
- **Prompt (English)**: "Fix all the TODOs in docs about iOS/Swift and test with Xcode."
- **Status**: DONE (2026-11-22). Score 97/100 (100 = items 1 to 6 done with evidence, or blocked with the reason and
  the owner). Per item:
  1. Quick Help: 100. 291 of 301 public Swift symbols documented; the 10 left are UIKit overrides (inherit by rule);
     `scripts/public-api-doc-coverage.sh` measures the Swift module (`218ba50`).
  2. Raised plus button: 90. Raised in the three configurations and the code-built tab bar, test
     `testPlusButtonIsRaisedAboveTheTabBar`, screenshot (`a5158b8`, `2fa5667`). Left: the plus title keeps the core's gray (a
     dynamic title color asked of the CYLTabBarController session, 2026-11-22).
  3. iOS More tab: 100. 8 of 8 quick switches keep one item selected, screenshot (`2fa5667`); found: the More item shows
     the first moved tab's SVGA icon (sent to the CYLTabBarController session).
  4. Flutter iOS tag drag: 100. The tag lifts, the page holds, a swipe still scrolls; `didChangeDragging` forwarded
     (`df3283a`, `414bdb2`). Not bisected against the 2026-11-20 failure.
  5. Swift migration steps 2 to 4: 100. The demo matches the GIF, the legacy Objective-C is removed, the tests are Swift
     with an Objective-C smoke test (`726a2da`, `f46d814`); 40 of 40 tests.
  6. React Native iOS drag events: 95. `onReorderingChange` reaches JavaScript (true, then false) on a Release build;
     `onSmearingChange` wired the same way, not exercised.
  Pins: ClassifyMenu `1f8c1001`, CYLTabBarController `ace1af0e`, CYLTableViewPlaceHolder `a169386` on iOS as on every
  platform, verified locally (40 of 40, `a53a704`); ClassifyMenu's own iOS CI on that commit was still pending when
  pinned (its session watches it). Local checks: public API comments, shellcheck, `pod lib lint`, analyze (0 warnings in
  `Sources/`). Six earlier commit subjects of this branch break `scripts/check-commit-message.sh` (five over 64
  characters, one merge subject); pushed, so left as they are, every later commit checked.

## DONE (2026-11-22): review pull request 13, merge it into feat/harmonyos-parity, README screenshots

- **Branch**: `fix/ios-swift-todos` (pull request 13, base `feat/harmonyos-parity`). macOS session.
- **Context**: the iOS / Swift TODO sweep above is done (97/100); its screenshot rule puts key details in the README at
  milestones: the Swift migration at 100 (the original demo rebuilt on the core) and the raised plus button qualify.
- **Requirements**: review the pull request; add the README screenshots (labelled, key details, stitched); merge into
  `feat/harmonyos-parity` after CI.
- **Prompt (verbatim)**: "Next: review PR #13 and merge it into feat/harmonyos-parity. The Swift migration and the raised
  plus button are good candidates for README screenshots."
- **Status**: DONE (2026-11-22). README: "iOS milestone (2026-11-22)" with the labelled demo-vs-GIF and raised plus images
  (`812cc17`). Review of the 48 code files: the project file wires the six Swift test files and the smoke test, no dangling
  references; the three plus configurations match; the bridges match Android; no finding. CI: run 44901322830 on `a53a704` fully
  green (unit tests included); later commits change only `docs/` and `README.md`. Merged into `feat/harmonyos-parity`.


## TODO (2026-11-22): fix the iOS CI failure on feat/harmonyos-parity

- **Branch**: `feat/harmonyos-parity` (PR #11). Context: the iOS workflow fails since the QMUI search port
  (`1ffabb0`, "CYLSearchBar and CYLSearchBarAppearance in Swift"); runs 44913488301 to 44921717079 (head `6014474`). The
  jobs "pod lib lint", "Example build and analyze", "Unit tests" and "Example screenshots" all stop at the same compiler
  error on CI's Xcode 26.6: `Sources/CYLSearchBar/CYLSearchBar.swift:419:70: error: implicit use of 'self' in closure;
  use 'self.' to make capture semantics explicit` (`bounds.width` inside the `UIView.animate` closure of
  `setShowsTrailingAccessoryView(_:animated:)`). Xcode 27 on the macOS session accepts it, so it passed locally.
- **Prompt (verbatim)**: "continue fix todo fix ci error"
- **Acceptance**: 100 = the core fixed (`self.bounds`), every job of the iOS workflow green on the new head. 60 = the
  compiler error gone, "pod lib lint" and "Example build and analyze" green.
- **Status**: DONE (2026-11-22), score 100/100. `ff1e4de` writes `self.bounds.width` in that closure. Its own run was
  cancelled by the next push; run 44955819321 on `adb6aeb` (which contains it) is green in all seven jobs: Public API
  comments, shellcheck, Changes, pod lib lint, Unit tests, Example build and analyze, Example screenshots.


## TODO (2026-11-22): the open items of the QMUI search port (iOS versions, launch view refresh, other platforms)

- **Branch**: `feat/harmonyos-parity` (PR #11). macOS session. Context: the QMUI search port (`docs/qmui-search-controller.md`,
  94/100) left three items outside its score. The CI failure of the same prompt is the entry above (another session,
  `ff1e4de`); this entry only watches its run.
- **Requirements**:
  1. Test the port on older iOS: the full suite on the iOS 17.5 and 26.5 simulators of this host (iOS 15.0 is
     unavailable on macOS 15 and later, no iOS 16 runtime: a missing point with that reason).
  2. The launch view of the "Search controller" screen reads the history again after a submitted query while it stays on
     screen (core first: the controller announces the new query).
  3. The new screens on the mini program, Android, HarmonyOS, React Native and Flutter: a parity table first
     (`docs/qmui-search-controller.md`), then one port per platform with labelled screenshots.
- **Prompt (verbatim)**: "fix ci error and fix" followed by the pasted list: "Open, outside the score / - Only iOS 27.2
  was tested; iOS 15–26 are unverified. CYLSearchBar watches frame changes on views UIKit owns, which may behave
  differently on older iOS versions. / - The new screens have no versions yet on the mini program, Android, HarmonyOS,
  React Native or Flutter. Per AGENTS.md those belong to a Win session. / - The recent-search list doesn't refresh while
  it stays on screen."
- **Prompt (English)**: fix the CI error and fix the three open items above. Note: no rule in `AGENTS.md` or
  `instructions.md` gives the other platforms to a Windows session (checked 2026-11-22); the earlier report was wrong.
- **Acceptance**: 100 = the 122 tests green on iOS 17.5, 26.5 and 27.2; the refresh covered by a test; every platform
  has the six screens with its own test or screenshot; CI green. 60 = items 1 and 2 done, the parity table written.
- **Status**: in progress.


## TODO (2026-11-22): pin CYLTabBarController 618ac11a, ClassifyMenu 9dc1f761, CYLTableViewPlaceHolder 6117fcf

- **Branch**: `feat/harmonyos-parity` (PR #11). Context: CollectionViewClassifyMenu `9dc1f761` (`feat/harmony`, newest code
  commit; `ci-screenshots` is an orphan branch of CI images) moves its CYLTabBarController pins to `618ac11a`
  (`feat/cross-platform-components`, 19 commits after `ace1af0e`: `b13b88f1` `showsImageWhenAnimationEnds`, `73d352d5`
  the iOS tab player in Swift). Both repositories pin the same tab bar commit, so this one moves to `618ac11a` too (not
  the newer `61ba2131`, which ClassifyMenu does not pin; not `master` `960dc211`, older and without CYLAnimatedItem, as
  that session warned). CYLTableViewPlaceHolder `6117fcfb` (`feat/android-refresh-port-followup`, PR #31, newest on any
  branch): the Success scenario's still check mark after its animation ends (Android, HarmonyOS, mini program), the
  HarmonyOS Rive end of playback; its examples pin tab bar `b13b88f1`, which `618ac11a` contains. It has diverged from
  `c473fdc3` (PR #35's branch): the 6 commits it lacks are docs and the iOS example fix `a169386c` (#1628), none in
  code this repository builds.
- **Prompt (verbatim)**: "continue fix todo fix ci error"
- **Acceptance**: 100 = the three pins moved in every manifest (Podfiles, Gradle, HarmonyOS, mini program, Flutter
  `pubspec`) with the vendor copies synced; Android, HarmonyOS (hypium on the emulator), mini program, Flutter and React
  Native tests pass; the iOS CI green. 60 = pins moved, Android and HarmonyOS green. The `Podfile.lock` files are left to
  the macOS session (`pod install`).
- **Status**: DONE (2026-11-22), score 100/100 (`Podfile.lock` files and the iOS build left to the macOS session). The
  three pins moved in the three Podfiles, `android/merged/gradle.properties`, `harmonyos/oh-package.json5`, the mini
  program `package.json` and the Flutter example `pubspec.yaml` / `pubspec.lock` (`flutter pub get`); vendor copies synced.
  Android `:cylsearch` 50 of 50, the POM still names both placeholder coordinates, `assembleDebug` of the whole build
  passes; HarmonyOS both HAPs build from a clean mirror, hypium 41 of 41 on the Mate 70 Pro emulator; mini program 84 of
  84; Flutter 18 of 18 and 3 of 3, the example APK builds (after `flutter clean`: a stale Kotlin build in the mirror
  failed first with "package CYLTabBarItemAnimationStyleSource does not exist"); React Native jest 4 of 4, the example
  APK builds with the vendor copy at `618ac11a`.
  Correction: robocopy run from Git Bash had silently failed since 2026-11-22 00:33 (Git Bash turned `/MIR` into a path,
  and an unquoted `C:\cylbuild\…` lost its backslashes), so the HarmonyOS mirror kept the `a169386` / `1f8c1001` pins:
  the HarmonyOS result of the `881476a` / `c473fdc` entry above tested that stale copy. This entry's HarmonyOS run is
  from a mirror checked to hold `618ac11a`, `9dc1f761` and `6117fcfb` (its `oh-package.json5`), and supersedes it. The
  skill `cyl-harmonyos-setup` now says how to call robocopy from Git Bash.


## DONE (2026-11-22): write the x86_64 emulator HAP rule (arm64-only Rive and PAG) into the instructions and skills

- **Branch**: `feat/harmonyos-parity` (PR #11). Context: the default HAPs do not install on the x86_64 HarmonyOS emulator
  because `@ohos/rive` and `@tencent/libpag` ship `arm64-v8a` libraries only; the build profile already has the fix (the
  `emulator` target, 2026-11-17, and the `emulatorTest` build mode, `90b3dcf`), described so far only in a paragraph of
  `cyl-harmonyos-setup`.
- **Requirements**: write the fix, in English, into the instruction files and the skill files (create them when missing).
- **Prompt (verbatim)**: "到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：    to fix HAP won't install on this x86_64 emulator because its Rive and PAG libraries are arm64-only,"
- **Prompt (English)**: write into the instruction and skill files how to fix a HAP that won't install on this x86_64
  emulator because its Rive and PAG libraries are arm64-only.
- **Acceptance**: 100 = the rule (problem, fix, commands, check, rules) in `AGENTS.md` and `instructions.md`, a section and
  a troubleshooting row in `cyl-harmonyos-setup`, a pointer in `cyl-verify`, the check command verified on a built HAP.
- **Status**: DONE (2026-11-22), 100/100. `AGENTS.md` and `instructions.md`: "HarmonyOS: HAPs for the x86_64 emulator
  leave out the arm64-only Rive and PAG libraries"; `cyl-harmonyos-setup`: "Arm64-only native libraries on the x86_64
  emulator" and a troubleshooting row; `cyl-verify`, "HarmonyOS": a pointer. Checked on today's build (tab bar
  `618ac11a`): `unzip -l` finds no `.so` file in `entry-emulator-unsigned.hap` and no `arm64-v8a` entry in the ohosTest
  HAP; both install, and hypium runs 41 of 41 on the Mate 70 Pro emulator with them.


## TODO (2026-11-22): the x86_64 emulator test plan in CYLTabBarController's cylanimateditem

- **Branch**: `feat/harmonyos-parity` here; the work is in CYLTabBarController (`feat/cross-platform-components`, session
  chen-yilong-b6). Context: the user's second prompt puts the x86_64 test plan into CYLTabBarController's HarmonyOS
  `cylanimateditem` (`CYLAnimatedItemView`), so every dependent tests fully on the x86_64 emulator; rule: `AGENTS.md`,
  "HarmonyOS: HAPs for the x86_64 emulator …", "Where the fix belongs".
- **Prompt (verbatim)**: "、到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：    to fix HAP won't install on this x86_64 emulator because its Rive and PAG libraries are arm64-only, 最好的CYLTabBarController里的CYLAnimatedItemView库中完成该测试方案， 以让依赖该组件的example以及其他库完成完整测试 x86_64 emulator"
- **Prompt (English)**: write the x86_64 fix into the instruction and skill files; the best place to complete this test
  plan is CYLTabBarController's CYLAnimatedItemView library, so that the examples and libraries depending on it can
  test completely on the x86_64 emulator.
- **Acceptance**: 100 = the rule written here (done), CYLTabBarController ships the plan (ABI declaration per engine,
  still image when a native library is missing, the build recipe or helper, tests on x86_64), this repository pins that
  commit and drops its local build-profile copy, hypium passes on the x86_64 emulator. 60 = the rule written and the
  request accepted by the CYLTabBarController session.
- **Status**: DONE (2026-11-22), 100/100. Rule written (`AGENTS.md`, `instructions.md`, `cyl-harmonyos-setup` rule 6).
  CYLTabBarController shipped it in `62715829` and `882ece17` (6 hypium tests on x86_64); pinned here with ClassifyMenu
  `405bf498` and adopted (the entry "pin CYLTabBarController 882ece17 …" below), hypium 41 of 41 on the x86_64 emulator.
  Rive and PAG playback on x86_64 is the next entry (two plans).


## TODO (2026-11-22): merge the QMUI search components with ours (one implementation each)

- **Branch**: `feat/harmonyos-parity` (PR #11). macOS session. Context: the QMUI port added `CYLSearchBar`,
  `CYLSearchController`, `CYLSearchTableViewController` and their example screens beside the existing
  `CYLSearchBarView` / `CYLSearchView`; there are now two search fields, two overlay concepts and example screens that
  rebuild UI with native views.
- **Requirements**: evaluate both sets; the one with more strengths is the base, the other's strengths are kept; every
  integrated API stays compatible; one input field component, one suggestion area, the tag list is the sub-repository's
  `CYLTagListView` (no native or QMUI-style tag layout); no duplicate code; examples call core API instead of rebuilding
  with native views, example customisation goes through the core. The advisor designs (doc in `docs/`), Sonnet refactors.
- **Prompt (verbatim)**: "继续改造最近相关提交commit ，关于新加入的qmui相关组件以及Example， 重构我们已有的相关组件， 只保留一份，
  或者merge两套方案到一个。 advisor需要评估我们已经存在的组件，与qmui相关组件， 选择两个的优点，谁的优点更多以谁的方案为主，
  并保留另一个方案的优点， 兼容所有已经集成的api， 尽可能复用所有组件，改造core代码， 比如输入框仅仅保留一个输入框组件，比如
  底部的备选区域 ， taglist 也复用我们已经集成的子仓库的taglist方案， 不能使用qmui类似的系统原生taglist方案，
  或者merge两个方案的优点进行重构，尽可能复用， 不要使用不同实现， 避免重复代码，Example层面也尽可能调用api而非使用原生组件重新实现。，
  代码重复要避免， 通过改造core代码完成Example自定义需求。 然后advisor 设计好方案后交给sonnet默认模型进行代码重构"
- **Prompt (English)**: continue on the recent commits: refactor our existing components together with the new QMUI
  components and examples so only one remains, or merge both into one. The advisor evaluates both, picks the one with
  more strengths as the base and keeps the other's strengths, keeps every integrated API compatible, reuses components,
  changes the core (one input field component; the bottom suggestion area and the tag list reuse the sub-repository's
  tag list, never a native QMUI-style tag list), avoids different implementations and duplicate code; examples call the
  API instead of rebuilding with native components, and example customisation is done by changing the core. Then the
  advisor's design goes to the default Sonnet model for the refactor.
- **Acceptance**: 100 = design doc with the evaluation and decisions; one class per concept on iOS (and the same merge
  on the platforms that ported both); old public API compiles (deprecated forwards where renamed); examples free of
  native re-implementations; all suites green on iOS 17.5 / 26.5 / 27.2 and the platforms' own tests; screenshots before
  and after. 60 = design doc plus the iOS merge with green tests.
- **Status**: TODO (after the React Native and Flutter ports of the previous entry finish).


## DONE (rules) / TODO (code) (2026-11-22): re-evaluate the CYL / cyl_ prefixes against static analysis

- **Branch**: `feat/harmonyos-parity` (PR #11). macOS session.
- **Context**: the SonarCloud report on CYLTabBarController PR #788 (956 open issues: swift:S100 743, S115 146, S116 16,
  S117 11, S101 3) flags `cyl_` / `CYL` function and constant names. CYLSearchViewController is not analysed by
  SonarCloud; its own S100 cases are only the global test helpers (`CYLRunLoop`, `CYLTestWindow`, … in
  `CYLSearchExampleTests/*TestSupport.swift`); the core has no `cyl_` functions.
- **Prompt (verbatim)**: "找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入： 根据github pr评论区的静态分析报告，
  重新评估 instructions 中关于cyl_ CYL 方法名前缀名，类名前缀名的必要性， 这个前缀目的主要是为了在objc项目中，
  兼容分类方法可能覆盖其他同名实现的场景， 以及弥补objc没有命名空间导致类名冲突的问题，请在Swift上重新评估该前缀必要性，
  以及其他有相关机制，能保证我们的库不会导致类名冲突， 方法名冲突的其他语言， 以静态分析为指导意见， 重新调整代码命名， 以适应静态分析建议"
- **Prompt (English)**: find this project's instruction and skill files (add one if missing), write in English: using the
  static analysis report in the PR comments, re-evaluate the need for the `cyl_` / `CYL` prefixes, which exist for
  Objective-C category overrides and the missing namespace; re-evaluate them for Swift and for the other languages that
  have namespaces, and rename the code to follow the static analysis.
- **Done**: new skill `.agents/skills/cyl-naming/SKILL.md` (reasons, Swift table, other platforms, check); rules updated in
  `instructions.md` ("Naming"), `AGENTS.md` ("Project rules" and the skills table), `docs/swift-coding-standard.md`.
- **TODO**: rename the test helpers to lowerCamelCase after the merge phases (they edit the same test files); the
  CYLTabBarController renames belong to that repository's session and pull request.
## TODO (2026-11-22): pin CYLTabBarController 882ece17, ClassifyMenu 405bf498, CYLTableViewPlaceHolder f4cf978; adopt the x86_64 plan

- **Branch**: `feat/harmonyos-parity` (PR #11). Context: CYLTabBarController `882ece17` ships the x86_64 emulator test plan
  in `cylanimateditem` (`62715829`: PAG and Rive `canPlay` false without `arm64-v8a`, still image, `isSupportedOnDevice`,
  `tools/cyl_hap_x86_64.py`, README "x86_64 emulator"; `882ece17`: 6 hypium tests on x86_64), asked for in the entry
  "the x86_64 emulator test plan" above. CollectionViewClassifyMenu `405bf498` (`feat/harmony`) pins `882ece17` on every
  platform (both repositories pin the same tab bar commit, so not the newer `89886a3e`). CYLTableViewPlaceHolder
  `f4cf9785` (`feat/android-refresh-port-followup`, 8 commits after `6117fcfb`).
- **Prompt (verbatim)**: "continue fix todo fix ci error" and the x86_64 prompt quoted in that entry.
- **Acceptance**: 100 = the three pins in every manifest with vendor copies synced (from a mirror checked to hold them);
  Android, HarmonyOS (hypium on the x86_64 emulator), mini program, Flutter and React Native tests pass and the examples
  build; the x86_64 plan adopted (our recipe matches `cylanimateditem`'s README; any PAG or Rive view this repository
  builds itself guarded by `isSupportedOnDevice`). 60 = pins moved, Android and HarmonyOS green.
- **Status**: DONE (2026-11-22), score 100/100 (`Podfile.lock` files and the iOS build left to the macOS session). Pins
  moved in the three Podfiles, `android/merged/gradle.properties`, `harmonyos/oh-package.json5`, the mini program
  `package.json` and the Flutter example `pubspec.yaml` / `pubspec.lock`; vendor copies synced; the HarmonyOS mirror
  checked to name `882ece17`, `405bf498` and `f4cf9785`. Android `:cylsearch` 51 of 51 and `assembleDebug`; HarmonyOS both
  HAPs built clean (no `arm64-v8a` entry in the emulator HAP), the app reinstalled, hypium 41 of 41 on the x86_64 Mate 70
  Pro emulator; mini program 84 of 84; Flutter 18 of 18 and 3 of 3, the example APK builds; React Native jest 4 of 4, the
  example APK builds with the vendor copy at `882ece17`. Adoption of the x86_64 plan: our `emulator` target and
  `emulatorTest` mode are the recipe of `cylanimateditem`'s README "x86_64 emulator"; a HAR cannot filter the native
  libraries of the app that bundles it, so the app keeps that build profile. The example builds its PAG and Rive views only
  in `cylExampleAnimationBuilder`, the `animationBuilder` that `CYLAnimatedItemView` calls only when
  `CYLAnimatedItemEngines.canPlay` is true (false for PAG and Rive on x86_64 since `62715829`), so no extra
  `isSupportedOnDevice` guard is needed here.


## TODO (2026-11-22): Rive and PAG tests that need arm64: plan 1 (x86_64 builds in cylanimateditem), else plan 2 (macOS)

- **Branch**: `feat/harmonyos-parity` here; plan 1 is CYLTabBarController's (session chen-yilong-b6). Context: on the x86_64
  emulator Rive and PAG cannot play (their packages ship `arm64-v8a` only; `882ece17` shows the still image there).
- **Prompt (verbatim)**: "找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：   Rive; pag 编译问题： 针对需要只能在arm64上才能执行的测试， 有两个方案可供实现， 第一个方案是在CYLTabBarController的CYLAnimatedItemView中进行改造， 从GitHub中引入x86 架构的依赖库， 以完成测试功能。判断guards条件为， 运行系统的版本。 为x86架构， 首先你要保证x86架构能编译通过，且不会crash影响其他功能，其次才是实现功能运行正常。 在该方案未测试通过前使用debug环境编译选项进行guards，因为该方案目前只在运行模拟器时候会触发， 当该方案验证可行时候才再移除debug编译guards，你在移除该guards前需要经过我的同意。如果该方案实现失败， 则选择第二个方案， 将任务转发给正在macOS上的session进行测试， 因为macOS就是arm64架构的。"
- **Prompt (English)**: see `AGENTS.md`, "HarmonyOS: Rive and PAG tests that need arm64, two plans".
- **Requirements**: write the two plans into the instruction and skill files (done); plan 1 in CYLTabBarController's
  `CYLAnimatedItemView`: x86_64 libraries from GitHub, guarded by the device ABI, compiles first, no crash or side effect,
  then working playback, behind a debug build guard until it passes; the guard removed only with the user's approval;
  plan 2 if plan 1 fails: the macOS session tests on arm64.
- **Acceptance**: 100 = the rule written; plan 1 passing (Rive and PAG play on the x86_64 emulator, debug build, hypium and
  labelled screenshots) or plan 2 done (the macOS session's arm64 result recorded); this repository pinned to the result.
  60 = the rule written and plan 1 handed to the CYLTabBarController session.
- **Status**: rule written (`AGENTS.md`, `instructions.md`, `cyl-harmonyos-setup`, `cyl-verify`); plan 1 sent to the
  CYLTabBarController session (2026-11-22). Score 60/100.


## TODO (2026-11-22): tags as the default suggestion style, folded, with the trailing fold tag

- **Branch**: `feat/harmonyos-parity` (PR #11). macOS session.
- **Requirements**: in the core (`CYLSearchView` on every platform) the default `suggestionStyle` becomes tags; every other
  default stays (CollectionViewClassifyMenu's `CYLTagListView` in `suggestionsTagView`, `CYLMenuFoldControl` at the tail
  with an icon, 2 folded rows), so the tags start folded and the last tag is always the fold control, folded or
  unfolded, and toggles the fold. Screens that replicate a list design set the list style explicitly.
- **Prompt (verbatim)**: "修改searchbarcore核心代码， 修改taglist 默认样式保持当前当前的配置的基础上仅仅修改默认样式为taglist，且启动折叠，
  折叠样式为tag尾部折叠按钮， 下面是详细描述， 该样式是已经封装好的样式 ， 其特点为无论折叠还是展开taglist ，
  其最后一个tag总是折叠按钮，可以响应折叠展开操作。"
- **Prompt (English)**: change the search bar core: keep the current configuration and only change the default
  suggestion style to the tag list, folded at start, with the fold button as the trailing tag (the existing packaged
  style): folded or unfolded, the last tag is always the fold button and it toggles folding.
- **Acceptance**: 100 = the default is tags on iOS, Android, HarmonyOS, the mini program, React Native and Flutter; folded
  at start; the trailing fold tag present in both states and toggling (test per platform); list-only tests and list
  replica screens set the list style explicitly; suites green; labelled screenshots folded / unfolded. 60 = iOS and
  Android done with tests.
- **Status**: in progress.


## DONE (2026-11-22): sort the instruction files by tag, 200 lines each, details in docs/instructions

- **Branch**: `feat/harmonyos-parity` (PR #11). Context: `AGENTS.md` had 882 lines and `instructions.md` 616, mostly the same
  sections twice; `CLAUDE.md` only imports `AGENTS.md`.
- **Prompt (verbatim)**: see `docs/instructions/meta.md` (quoted in full there).
- **Prompt (English)**: write the rule into the instruction and skill files, and apply it once now: categories managed by
  tags, shown as headings that are never hidden; each file within 200 lines; the overflow of each tag in
  `docs/instructions/<tag>.md`, linked by relative paths and read only when the tag is triggered.
- **Acceptance**: 100 = both files within 200 lines with one heading per tag; every section of the old files present
  word for word in a tag file (both wordings kept where they differed); every relative link resolves; the rule in the
  `meta` tag file, both index files and the `cyl-docs` skill; committed and pushed.
- **Status**: DONE (2026-11-22), 100/100. `AGENTS.md` and `instructions.md`: 145 lines each, 16 tags (skills, meta,
  workflow, git, core, dependencies, animation, testing, docs, macos, windows, harmonyos, miniprogram, accessibility-i18n,
  licenses, code-style). `docs/instructions/`: 16 files, 21 to 182 lines; a script compared every old section's body with
  the tag files: none lost; a link check found no broken relative link. The two check scripts now name the tag files in
  their messages. Skill `cyl-docs`: the rule.

## TODO (2026-11-22): move the CYLTableViewPlaceHolder pin past its Swift rename

- **Branch**: `feat/harmonyos-parity` (PR #11). Context: CYLTableViewPlaceHolder renamed its Swift `cyl_` names (S100) in
  `0c8961f` (`fix/ios-swift-todos-placeholder`, its PR #35; mapping table `docs/Swift-Naming.md` there). Objective-C
  selectors are unchanged, Swift spellings change and get no deprecated aliases. Our pin is `c473fdc`.
- **Requirements**: after that commit's CI is green and it reaches the branch we pin from, move the pin on every
  platform together (skill `cyl-sub-repositories`), update our Swift call sites from the mapping table, all suites green.
- **Source**: message from the CYLTableViewPlaceHolder session (chenyilong-83), 2026-11-22; no prompt of the owner.
- **Status**: TODO (after the merge refactor phases).
