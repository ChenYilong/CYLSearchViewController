> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# Scripts and CI: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `.github/workflows/ios.yml` | 241 |
| `.github/workflows/screenshot-labels.yml` | 37 |
| `android/merged/scripts/api-alignment.py` | 298 |
| `android/merged/scripts/import-ios-resources.py` | 51 |
| `android/merged/scripts/ios-alignment.mjs` | 342 |
| `CrossPlatform/react-native-cylsearch/.github/actions/setup/action.yml` | 36 |
| `CrossPlatform/react-native-cylsearch/.github/ISSUE_TEMPLATE/bug_report.yml` | 67 |
| `CrossPlatform/react-native-cylsearch/.github/ISSUE_TEMPLATE/config.yml` | 8 |
| `CrossPlatform/react-native-cylsearch/.github/workflows/ci.yml` | 180 |
| `CrossPlatform/react-native-cylsearch/example/scripts/fetch-cyltabbar.sh` | 26 |
| `CrossPlatform/wechat-miniprogram-cylsearch/scripts/devtools-screenshots.js` | 128 |
| `CrossPlatform/wechat-miniprogram-cylsearch/scripts/import-ios-resources.js` | 72 |
| `CrossPlatform/wechat-miniprogram-cylsearch/scripts/sync-example.js` | 124 |
| `harmonyos/scripts/check-accessibility-i18n.mjs` | 115 |
| `harmonyos/scripts/check-ios-parity.mjs` | 88 |
| `harmonyos/scripts/host-logic-test.mjs` | 892 |
| `harmonyos/scripts/import-android-strings.py` | 36 |
| `harmonyos/scripts/import-cyltabbar-localizations.mjs` | 74 |
| `harmonyos/scripts/import-ios-resources.py` | 100 |
| `harmonyos/scripts/sync-sub-repositories.py` | 102 |
| `harmonyos/scripts/sync-sub-repositories.sh` | 76 |
| `release-ram.ps1` | 68 |
| `scripts/check-commit-message.sh` | 44 |
| `scripts/check-example-fold.sh` | 18 |
| `scripts/check-example-taglist.sh` | 39 |
| `scripts/check-licenses.sh` | 59 |
| `scripts/check-public-api-comments.sh` | 71 |
| `scripts/check-screenshot-labels.sh` | 56 |
| `scripts/ci-build-example.sh` | 43 |
| `scripts/ci-checkout-dependencies.sh` | 24 |
| `scripts/example-screenshots.sh` | 88 |
| `scripts/harmonyos-api-alignment.py` | 163 |
| `scripts/harmonyos-scorecard.py` | 105 |
| `scripts/latest-cyl-commit.sh` | 30 |
| `scripts/local-run-environment.sh` | 45 |
| `scripts/miniprogram-api-alignment.py` | 183 |
| `scripts/pod-lint.sh` | 48 |
| `scripts/public-api-doc-coverage.sh` | 68 |
| `scripts/publish-screenshots.sh` | 57 |
| `scripts/release-ram/close-explorer-windows.ps1` | 54 |
| `scripts/release-ram/restart-emulators.ps1` | 249 |
| `scripts/release-ram/set-brightness.ps1` | 55 |
| `scripts/release-ram/stop-apps.ps1` | 55 |
| `scripts/stitch-screenshots.ps1` | 133 |
| `scripts/stitch-screenshots.swift` | 159 |
| `scripts/sync-discover-data.py` | 129 |
| `scripts/unit-tests.sh` | 48 |

## `.github/workflows/ios.yml`

local-run-environment: macOS 27.3 (26C5035r), Xcode 27.2 (27B52) iOS CI on GitHub-hosted macOS runners, modeled on CYLTabBarController's .github/workflows/ios.yml (commit d574501, branch feat/cross-platform-components). See docs/CI-CD.md. Runner: `macos-26` (Apple Silicon, stable image, default Xcode 26.x). To use another runner without editing this file, set the repository variable MACOS_RUNNER (

## `.github/workflows/screenshot-labels.yml`

Fails a pull request or push that adds a screenshot under docs/assets without its header, footer and label (AGENTS.md, "Screenshots of builds and CI/CD"; scripts/check-screenshot-labels.sh).

## `android/merged/scripts/api-alignment.py`

Builds the iOS-to-Android API table (docs/android-api-alignment.md, between the generated markers).

- L142 `def kotlin_sources():`
- L149 `def declared(sources, name):`
- L154 `def selector_name(selector):`
- L159 `def parse_swift():`
- L220 `def upstream_of(comment):`
- L229 `def main():`

## `android/merged/scripts/import-ios-resources.py`

Copies the iOS resource bundle (Resources/CYLSearchViewController.bundle) into the cylsearch module.

- L17 `def snake(name):`
- L20 `def android_format(value):`
- L26 `def main():`

## `android/merged/scripts/ios-alignment.mjs`

Builds the Android-core-to-iOS table (docs/ios-api-alignment.md, between the generated markers). Rows: every public Kotlin declaration (classes, interfaces, objects, enum entries, functions, properties) of A. this project's Android core, android/merged/cylsearch (com.cyl.search); B. CollectionViewClassifyMenu's Android library (com.cyl.classifymenu), the tag views the search uses, from the pinned 

- L20 `const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');`
- L21 `const DOC = join(ROOT, 'docs', 'ios-api-alignment.md');`
- L22 `const REVERSE = join(ROOT, 'docs', 'android-api-alignment.md');`
- L23 `const BEGIN = '<!-- ios-alignment:begin -->';`
- L24 `const END = '<!-- ios-alignment:end -->';`
- L25 `const MENU = join(ROOT, 'android', 'merged', '.cyl-deps', 'CollectionViewClassifyMenu');`
- L32 `const SECTIONS = [`
- L48 `const MANUAL =` — Counterparts with another name or shape, found by reading both sides: "Kotlin row key" -> "iOS counterpart". A. Android stand-ins for UIKit types map to the UIKit type the iOS API takes; B. Swift names of the tag library.
- L127 `function files(dir, exts)`
- L139 `function kdoc(lines, i)` — The first sentence of the KDoc right above line i.
- L153 `const MODIFIERS = /\b(private|internal|protected)\b/;`
- L154 `const DECL = /^(\s*)((?:@\w+(?:\([^)]*\))?\s+)*)((?:(?:public|open|abstract|final|data|enum|sealed|inline|value|annotation|inner|lateinit|const|operator|infix|suspend|override|companion|fun)\s+)*)(cla`
- L156 `function kotlinRows(dir)`
- L223 `function reverseMap()` — Kotlin "Class.member" -> iOS API, read from the iOS-to-Android table.
- L241 `function tableMap(path)` — Kotlin "Class.member" -> iOS API, read from a sub-repository's own Android-to-iOS table (rows "| `Android API` | description | iOS API |"; TODO rows are skipped).
- L252 `function iosIndex(dirs)`
- L258 `function iosMatch(row, index)`
- L279 `function existsInIOS(ios, index)` — A bare name taken from a sub-repository's table must exist in the iOS sources it was measured against: that table can lag behind its own Swift migration (renamed or removed Objective-C names). Prose cells and UIKit / Foundation / Core Graphics names pass; a na
- L298 `function build()`

## `CrossPlatform/react-native-cylsearch/example/scripts/fetch-cyltabbar.sh`

/bin/sh Usage: scripts/fetch-cyltabbar.sh     (run once before `yarn`, and again after the pinned commit changes) Checks out CYLTabBarController at the pinned commit into vendor/CYLTabBarController (not committed). Its React Native tab bar, CrossPlatform/react-native-cyltabbar, lives inside that repository, which is not a yarn workspace, so it cannot be a git dependency; the example depends on it 

## `CrossPlatform/wechat-miniprogram-cylsearch/scripts/devtools-screenshots.js`

Opens the package folder (its example) in WeChat DevTools (logged in; Settings > Security > service port on), visits every page of the example (a 1:1 copy of the iOS example: four tabs and the plus button's tab, the Examples menu and what it opens), drives the interactions of each, and saves a screenshot of each step: node scripts/devtools-screenshots.js <output folder> [project path, the package 

- L10 `const out = process.argv[2] || '.';`
- L11 `const projectPath = process.argv[3] || path.join(__dirname, '..');`
- L12 `const cliPath = process.env.CYL_DEVTOOLS_CLI || '/Applications/wechatwebdevtools.app/Contents/MacOS/cli';`
- L13 `const errors = [];`
- L16 `function callComponent(mp, selectors, method, args)` — Calls a method of a component of the current page: selectors from the page down, then the method and its arguments.

## `CrossPlatform/wechat-miniprogram-cylsearch/scripts/import-ios-resources.js`

Imports the resources of the iOS library and example, so the mini program shows the same texts, data and images: 1. (none: the placeholder images are CYLTableViewPlaceHolder's, from cyl-placeholder-miniprogram; the search core has no placeholder view of its own any more); 2. the texts of CYLSearchViewController.bundle, CYLSearchTabs.bundle and CYLSearchDiscover.bundle (en, ja, zh-Hans, zh-Hant), C

- L14 `const root = path.join(__dirname, '..');`
- L15 `const repository = path.join(root, '..', '..');`
- L16 `const libraryBundle = path.join(repository, 'Resources', 'CYLSearchViewController.bundle');`
- L17 `const exampleDir = path.join(repository, 'CYLSearchExample');`
- L18 `const languages = ['en', 'ja', 'zh-Hans', 'zh-Hant'];`
- L21 `function readStrings(file)` — Reads an Apple .strings file ("key" = "value";) into an object.
- L33 `const strings = {};` — 2. Texts and discover data, one table per language.
- L34 `const discover = {};`
- L35 `const contactTags = {};`
- L51 `const output = path.join(root, 'example', 'miniprogram', 'utils', 'cyl_demo_resources.js');`
- L58 `const discoverDir = path.join(root, 'example', 'miniprogram', 'utils', 'discover');` — The discover data: a whole copy of each language's search-discover.json.
- L66 `const hotDir = path.join(root, 'example', 'miniprogram', 'assets', 'discover');` — 3. Hot icons, one per language.

## `CrossPlatform/wechat-miniprogram-cylsearch/scripts/sync-example.js`

Prepares the example for WeChat DevTools, because a mini program cannot load files outside its miniprogramRoot: 1. copies the package's components (src/) into example/miniprogram/components/; 2. installs the sub-repositories the example uses, as the iOS example does through CocoaPods, into example/miniprogram/miniprogram_npm/, each with its licenses, from a sparse checkout at the commit pinned in 

- L25 `const root = path.join(__dirname, '..');`
- L27 `const miniprogram = path.join(root, 'example', 'miniprogram');`
- L30 `function copyDir(from, to, filter = () => true)` — fs.cpSync crashes Node 22 on Windows (0xC0000409) for some source folders; a plain recursive copy does not.
- L41 `function sync(from, to, filter = () => true)`
- L50 `function checkout(name, commit, folders)` — A sparse checkout of `folders` of a GitHub repository at `commit`, in example/vendor/<name>. A sparse checkout also keeps Windows below its path length limit, which full checkouts (deep Xcode folders) exceed with "Filename too long".
- L68 `function copyLicenses(fromDirs, to)`
- L80 `const tabBarRoot = process.env.CYL_TABBAR_DIR || checkout('CYLTabBarController', pkg.cylTabBarControllerCommit,` — CYLTabBarController: the tab bar, the Lottie player and the SVGA player (SVGA tab icons, docs/svga-tab-icons.md).
- L95 `const placeholderRoot = process.env.CYL_PLACEHOLDER_DIR || checkout('CYLTableViewPlaceHolder', pkg.cylTableViewPlaceHolderCommit,` — CYLTableViewPlaceHolder: the scenario placeholders, the HUD, the status views and the pull-to-refresh header, kept side by side as in the package (cyl-refresh uses ../cyl-placeholder and ../cyl-placeholder-hud). The locale .json tables stay out: the code loads
- L97 `const placeholderPackage = path.join(placeholderRoot, 'CrossPlatform', 'wechat-miniprogram-cylplaceholder');`
- L98 `const placeholderTo = path.join(miniprogram, 'miniprogram_npm', 'cyl-placeholder-miniprogram');`
- L102 `const placeholderComponents = fs.readdirSync(path.join(placeholderPackage, 'src'), { withFileTypes: true })` — Every component of the package: they require one another (cyl-refresh uses cyl-placeholder-hud since 62e40c0), so a fixed list broke the example when one was added (WeChat DevTools: "module …/cyl-placeholder-hud/… is not defined").
- L113 `const classifyMenuRoot = process.env.CYL_CLASSIFYMENU_DIR || checkout('CollectionViewClassifyMenu', pkg.collectionViewClassifyMenuCommit,` — CollectionViewClassifyMenu: its mini program package (cyl-tag-button draws the search bar items; it needs the rest of the package: cyl-tag-list's model and animations, cyl-animated-item, cyl-animation-placeholder, the strings). cyl-animated-item draws the icon
- L115 `const tagListPackage = path.join(classifyMenuRoot, 'CrossPlatform', 'wechat-miniprogram', 'packages', 'cyl-tag-list-miniprogram');`
- L116 `const tagListTo = path.join(miniprogram, 'miniprogram_npm', 'cyl-tag-list-miniprogram');`

## `harmonyos/scripts/check-accessibility-i18n.mjs`

Checks the HarmonyOS library for screen-reader and localization gaps, without an emulator. 1. No English text written in the library's UI code: Text(...), .accessibilityText(...), .accessibilityDescription(...) and string defaults of titles and labels take a resource. 2. Every element with .onClick has a screen-reader label: .accessibilityText, a Text child, or a group label within the 30 lines be

- L13 `const harmonyos = join(dirname(fileURLToPath(import.meta.url)), '..');`
- L14 `const library = join(harmonyos, 'cylsearch', 'src', 'main');`
- L15 `const example = join(harmonyos, 'entry', 'src', 'main');`
- L16 `const curated = ['base', 'ja_JP', 'zh_CN', 'zh_TW'];`
- L17 `const problems = [];`
- L19 `function etsFiles(folder)`
- L32 `function names(module, qualifier)`
- L38 `const literal = /(?:\bText|\.accessibilityText|\.accessibilityDescription)\(\s*(?:[^)]*\?\s*)?'([^']*[A-Za-z][^']*)'/;` — 1 and 2: the library's UI code.
- L39 `const titleDefault = /(?:Title|Label|title|label)\s*:\s*string\s*=\s*'([^']*[A-Za-z][^']*)'/;`
- L93 `const libraryNames = curated.map((q) => names(library, q));` — 3: the string resources used in code exist in every curated language.
- L94 `const exampleNames = curated.map((q) => names(example, q));`

## `harmonyos/scripts/check-ios-parity.mjs`

Checks, without an emulator, that the HarmonyOS resources are a 1:1 copy of the iOS ones (AGENTS.md, "HarmonyOS: API and example 1:1 with iOS"): every iOS string in en, ja, zh-Hans and zh-Hant, with the same text, and every placeholder image. The names follow harmonyos/scripts/import-ios-resources.py. Usage: node harmonyos/scripts/check-ios-parity.mjs   (exit code 1 when something is missing or di

- L9 `const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');`
- L10 `const bundle = join(root, 'Resources', 'CYLSearchViewController.bundle');`
- L11 `const example = join(root, 'CYLSearchExample');`
- L12 `const library = join(root, 'harmonyos', 'cylsearch', 'src', 'main', 'resources');`
- L13 `const app = join(root, 'harmonyos', 'entry', 'src', 'main', 'resources');`
- L14 `const languages = { en: 'base', ja: 'ja_JP', 'zh-Hans': 'zh_CN', 'zh-Hant': 'zh_TW' };`
- L16 `function iosStrings(path)`
- L25 `function harmonyStrings(path)`
- L36 `const problems = [];`
- L40 `function harmonyFormat(value)` — iOS format specifiers in HarmonyOS form, as the import does: %@ -> %s, %ld / %lu / %u -> %d (positions kept).
- L45 `function compare(pairs, target, nameOf, where)`
- L69 `const snake = (name) => name.replace(/(?<!^)(?=[A-Z])/g, '_').toLowerCase();`
- L70 `const images = new Set();`

## `harmonyos/scripts/host-logic-test.mjs`

Runs the pure logic of the HarmonyOS search core on the host, without an emulator or a device. Usage (Node 22.18 or newer, which strips TypeScript types itself): node harmonyos/scripts/host-logic-test.mjs The logic is private to the core files (CYLSearchBarView.ets, CYLSearchView.ets, CYLSearchResources.ets, CYLSearchController.ets, CYLSearchNavigationBar.ets, CYLSearchTagListStyle.ets), each betw

- L16 `const here = dirname(fileURLToPath(import.meta.url));`
- L17 `const core = join(here, '..', 'cylsearch', 'src', 'main', 'ets');`
- L18 `const parts = ['CYLSearchBarView.ets', 'CYLSearchView.ets', 'CYLSearchResources.ets', 'CYLSearchController.ets',`
- L27 `const examplePart = readFileSync(join(here, '..', 'entry', 'src', 'main', 'ets', 'demos', 'CYLGalleryChunks.ets'), 'utf8');` — The example's pure logic parts (the Placeholder styles page builds its tag lists in chunks).
- L30 `const folder = mkdtempSync(join(tmpdir(), 'cyl-logic-'));`
- L31 `const target = join(folder, 'CYLSearchLogic.ts');`
- L34 `const arkTsStubs = "const $r = (name: string) => ({ resource: name });\n";` — ArkTS resource lookups ($r) have no host counterpart: a stub returns the resource name, so a pure logic part may hold a colour constant such as $r('app.color.cyl_search_secondary_label').
- L36 `const logic = await import(pathToFileURL(target).href);`
- L322 `const discoverSource = readFileSync(join(here, '..', 'entry', 'src', 'main', 'ets', 'demos', 'Discover.ets'), 'utf8');` — The example's Discover page keeps its paging rule in the same kind of part (entry/src/main/ets/demos/Discover.ets) and the rawfile data it reads is checked here too: the rule of docs/animated-icon-component.md, "Discover data contract".
- L323 `const discoverBegin = discoverSource.indexOf('// MARK: - Pure logic (begin)');`
- L324 `const discoverEnd = discoverSource.indexOf('// MARK: - Pure logic (end)');`
- L326 `const discoverFolder = mkdtempSync(join(tmpdir(), 'cyl-discover-'));`
- L327 `const discoverTarget = join(discoverFolder, 'CYLDiscoverLogic.ts');`
- L329 `const discoverLogic = await import(pathToFileURL(discoverTarget).href);`

## `harmonyos/scripts/import-android-strings.py`

Copies the core strings of the Android library into the HarmonyOS library's resources.

- L18 `def main():`

## `harmonyos/scripts/import-cyltabbar-localizations.mjs`

Copies the translations of CYLTabBarController's string table into the HarmonyOS resources, keeping only the texts this project uses (user, 2026-11-16: "本地化文件可以从CYLTabBarController中复制一份过来。筛选本项目用到的文字。"). CYLTabBarController keys its table by the English text (CYLTabBarController.bundle/<lang>.lproj/ CYLTabBarController.strings). A string of ours is kept when its English text (base/element/string.js

- L15 `const repository = join(dirname(fileURLToPath(import.meta.url)), '..', '..');`
- L16 `const tabBar = process.argv[2] ?? join(repository, '..', 'CYLTabBarController');`
- L17 `const bundle = join(tabBar, 'CYLTabBarController', 'Resources', 'CYLTabBarController.bundle');`
- L18 `const modules = ['cylsearch', 'entry'];`
- L19 `const curated = new Set(['en', 'ja', 'zh-Hans', 'zh-Hant']);`
- L26 `function table(language)`
- L36 `const qualifier = (language) => language.replace('-', '_');` — The HarmonyOS qualifier of an iOS language: the language code, a region after an underscore (pt-BR -> pt_BR).
- L38 `const english = table('en');`
- L39 `const keyOfEnglish = new Map();`
- L43 `const languages = readdirSync(bundle)`

## `harmonyos/scripts/import-ios-resources.py`

Copies the iOS resources into the HarmonyOS library and example, so HarmonyOS shows the same texts, images and data.

- L25 `def strings(path):`
- L36 `def write(path, items):`
- L43 `def read(path):`
- L49 `def snake(name):`
- L53 `def main():`

## `harmonyos/scripts/sync-sub-repositories.py`

Installs the HarmonyOS libraries of the sub-repositories the iOS example uses through CocoaPods, at pinned commits:

- L56 `def pins():`
- L61 `def archive(repo_dir, commit, paths):`
- L67 `def main():`

## `harmonyos/scripts/sync-sub-repositories.sh`

/bin/sh Copies the HarmonyOS libraries of the sub-repositories into harmonyos/vendor at their pinned commits: the shell version of sync-sub-repositories.py (same pins, same folders), for machines without Python. - CYLTabBarController CrossPlatform/harmonyos-cyltabbar/cyltabbar (+ LICENSE)        -> vendor/cyltabbar - CYLTableViewPlaceHolder CrossPlatform/harmonyos-cylplaceholder/cylplaceholder (+ 

- L28 `pin()`
- L33 `sync()` — sync <name> <url> <pin key> <path in repo> <local clone env var> [extra files...]

## `release-ram.ps1`

.SYNOPSIS

## `scripts/check-commit-message.sh`

/bin/sh Checks a commit message against the commit rule (AGENTS.md, "Commit readiness"; skill cyl-commit): a git cz (Commitizen) style subject, `type(scope): emoji subject` or `type: emoji subject`, and the whole message in English, with no Chinese (CJK) characters. scripts/check-commit-message.sh <message file>     # as a commit-msg hook, or on a saved message git log -1 --format=%B | scripts/che

## `scripts/check-example-fold.sh`

/bin/sh Example tag lists use the tail fold control with the icon only (docs/instructions/example-demos.md, rule 3). Fails when an example sets a title fold content, or sets a fold (rows > 0) without an explicit icon content.

## `scripts/check-example-taglist.sh`

/bin/sh Example demo menus are glass tag lists (docs/instructions/example-demos.md, rules 1 to 7). Sibling of check-example-fold.sh. Fails when a demo menu is still a plain cell list, or a tag list of an example sets no glass style / no explicit tail icon.

- L6 `fail() { echo "check-example-taglist: $1"; bad=1; }`
- L7 `need() { # file pattern message`

## `scripts/check-licenses.sh`

Every package this repository publishes to an external registry carries its license declaration, inside its resource bundle when it has one (AGENTS.md, "Licenses in published packages"; docs/licenses.md).

## `scripts/check-public-api-comments.sh`

/bin/sh Usage: scripts/check-public-api-comments.sh Checks the core's documentation comments against AGENTS.md, "Comments on public API": - Objective-C headers (none at the moment): every documentation comment is a three-line `/*!` / ` * ...` / ` */` block above its declaration. Reports `///` lines, one-line blocks, trailing `/**< */`, `/*!< */`, `///<` and trailing `//` after a declaration or an 

## `scripts/check-screenshot-labels.sh`

/bin/sh Usage: sh scripts/check-screenshot-labels.sh            (the images staged for the next commit) sh scripts/check-screenshot-labels.sh BASE HEAD  (the images added between two commits, as CI runs it) Fails when a screenshot added under docs/assets breaks AGENTS.md, "Screenshots of builds and CI/CD" (Labels) and "Stitched screenshots: layout, header and footer": 1. it is a PNG made by script

- L23 `fail()`

## `scripts/ci-build-example.sh`

/bin/bash Usage: scripts/ci-build-example.sh [build|analyze] [extra xcodebuild settings...] Adapted from CYLTabBarController/scripts/ci-build-example.sh. Builds (default) or statically analyzes the CYLSearchExample scheme for the iOS Simulator, without code signing. - Runs `pod install` first; the Podfile is not changed. - Uses build/DerivedData/example; delete build/ for a clean build (AGENTS.md,

## `scripts/ci-checkout-dependencies.sh`

/bin/sh Usage: scripts/ci-checkout-dependencies.sh Clones the sibling repositories the Podfile reaches through local paths, so CI (and a fresh machine) can run `pod install`. The Podfile uses `pod 'CYLTableViewPlaceHolder', :path => '../CYLTableViewPlaceHolder'`. - An existing sibling folder is kept as it is (local development). - CYL_PLACEHOLDER_REF picks a branch, tag or commit; without it, the 

## `scripts/example-screenshots.sh`

Usage: scripts/example-screenshots.sh [simulator name] Adapted from CollectionViewClassifyMenu/scripts/example-screenshots.sh. Builds CYLSearchExample for an iOS simulator, opens each tab (`-CYLDemoTab <n>`) and each row of the demo menu (`-CYLDemoTab 1 -CYLDemoRow <n>`), and saves one screenshot per screen in build/screenshots/<name>.png at the simulator's original pixels. Needs a Mac with Xcode.

- L52 `capture()` — capture <name> <launch arguments...>

## `scripts/harmonyos-api-alignment.py`

Builds the iOS-to-HarmonyOS API table (docs/harmonyos-api-alignment.md, between the generated markers).

- L77 `def ets_sources():`
- L86 `def body_of(sources, owner):`
- L92 `def detect(sources, owner, swift, kind, kotlin):`
- L118 `def label(owner, swift, kind):`
- L124 `def existing(doc):`
- L134 `def main():`

## `scripts/harmonyos-scorecard.py`

The HarmonyOS scorecard: two tables scored together (docs/harmonyos-cross-platform.md).

- L47 `def cells(line):`
- L51 `def api_rows():`
- L62 `def kept_demos(text):`
- L73 `def table(header, rows):`
- L79 `def main():`

## `scripts/latest-cyl-commit.sh`

/bin/sh Copied from ChenYilong/CYLTabBarController scripts/latest-cyl-commit.sh (commit caf3c92); keep this attribution. Prints the newest commit of CYLTabBarController on ANY branch, by commit timestamp (AGENTS.md, "Depending on CYLTabBarController"). scripts/latest-cyl-commit.sh             # <sha> <committer date, ISO 8601> <branch> scripts/latest-cyl-commit.sh --sha       # the sha only script

## `scripts/local-run-environment.sh`

/bin/sh Copied from ChenYilong/CYLTabBarController scripts/local-run-environment.sh (commit d36c708); keep this attribution. Keeps the local run environment comment at the top of .github/workflows/ios.yml (docs/CI-CD.md, "Run locally"). scripts/local-run-environment.sh            # check and, when needed, write the comment scripts/local-run-environment.sh --check    # exit 1 when the comment is mi

## `scripts/miniprogram-api-alignment.py`

Builds the iOS-to-WeChat-Mini-Program API table (docs/miniprogram-api-alignment.md, between the generated markers).

- L76 `def mini(text):`
- L89 `def sources():`
- L97 `def frozen_enum(text, owner):`
- L103 `def body_of(text, owner):`
- L108 `def has_member(text, owner, name):`
- L119 `def detect(text, owner, swift, kind, kotlin):`
- L152 `def main():`

## `scripts/pod-lint.sh`

/bin/sh Adapted from CYLTabBarController/scripts/pod-lint.sh.

- L8 `version()`
- L15 `sub_repository_specs()` — Sub-repositories (AGENTS.md, "Sub-repositories") are not on CocoaPods trunk. `--include-podspecs` treats a podspec as a local pod rooted at its folder, so each one is checked out at the commit the Podfile pins (its whole tree) into build/lint-specs/<name>/, an

## `scripts/public-api-doc-coverage.sh`

/bin/sh Usage: scripts/public-api-doc-coverage.sh [built products dir]   (macOS with Xcode) e.g. scripts/public-api-doc-coverage.sh build/DerivedData/Build/Products/Debug-iphonesimulator Counts the public symbols of the core (Sources/CYLSearchBar) that carry a documentation comment, as the symbol graph (the data Xcode Quick Help and DocC read) sees them. - Swift (the core today): give the products

## `scripts/publish-screenshots.sh`

/bin/sh Usage: scripts/publish-screenshots.sh     (in GitHub Actions, after scripts/example-screenshots.sh) Copied from CollectionViewClassifyMenu/scripts/publish-screenshots.sh. Commits build/screenshots/*.png to the `ci-screenshots` branch under <branch>/<commit>/ and writes them into the job summary as images. Artifacts are served from changing storage hosts; files on a branch can always be rea

## `scripts/release-ram/close-explorer-windows.ps1`

.SYNOPSIS

## `scripts/release-ram/restart-emulators.ps1`

.SYNOPSIS

- L61 `function Write-Step([string]$text) { Write-Host $text }`
- L63 `function Find-AndroidTool([string]$relative, [string]$exe)`
- L72 `function Invoke-Limited([string]$file, [string[]]$arguments, [int]$seconds)` — Runs a program with a hard time limit: a hung adb must not hang this script.
- L81 `function Get-CommandLines([string]$namePattern)`
- L87 `function Get-AndroidBusyReasons($adb)`
- L101 `function Stop-AndroidEmulator($adb)`
- L159 `function Start-AndroidEmulator($adb)`
- L179 `function Get-HarmonyProcesses`
- L183 `function Stop-HarmonyEmulator`
- L215 `function Start-HarmonyEmulator`

## `scripts/release-ram/set-brightness.ps1`

.SYNOPSIS

## `scripts/release-ram/stop-apps.ps1`

.SYNOPSIS

## `scripts/stitch-screenshots.ps1`

Usage: powershell -ExecutionPolicy Bypass -File scripts/stitch-screenshots.ps1 [-Columns auto|1|2|3] [-ScreenHeight PIXELS] [-Gap PIXELS] -Header TEXT -Footer TEXT -Out OUT.png IN1.png[=caption] IN2.png[=caption] ... The Windows twin of scripts/stitch-screenshots.swift (same layout, same look; AGENTS.md, "Screenshots of builds and CI/CD" and "Stitched screenshots: layout, header and footer"). Ever

- L51 `function Measure-Text([string]$text, [int]$width)`
- L56 `function Get-Layout([int]$count)`
- L127 `function Get-BigEndian([uint32]$value) { $bytes = [BitConverter]::GetBytes($value); [Array]::Reverse($bytes); $bytes }`

## `scripts/stitch-screenshots.swift`

Usage: swift scripts/stitch-screenshots.swift [--columns auto|1|2|3] [--screen-height PIXELS] [--gap PIXELS] [--header TEXT] [--footer TEXT] --out OUT.png IN1.png[=caption] IN2.png[=caption] ... Stitches screenshots into one PNG (AGENTS.md, "Screenshots of builds and CI/CD" and "Stitched screenshots: layout, header and footer"). Layout: --columns auto (the default) stacks the images in one column 

## `scripts/sync-discover-data.py`

Keeps the Discover demo data of every example equal to the iOS source and checks its refresh rule.

- L39 `def read(path):`
- L44 `def write(path, data):`
- L50 `def validate(sources):`
- L77 `def main():`

## `scripts/unit-tests.sh`

/bin/sh Usage: scripts/unit-tests.sh [simulator name]     e.g. scripts/unit-tests.sh "iPhone 17" Adapted from CYLTabBarController/scripts/unit-tests.sh. Runs the test action of the shared CYLSearchExample scheme (CYLSearchExampleTests) on an iOS simulator, on a Mac with Xcode. Without a name, "iPhone 17" of the newest runtime (the device CI uses), else the first available iPhone. Builds into a new
