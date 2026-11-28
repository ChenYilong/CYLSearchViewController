# Skills (tag: `skills`)

Details of the `skills` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md), moved here unchanged on 2026-11-22.

## Skills

WeChat DevTools Skills (<https://developers.weixin.qq.com/miniprogram/dev/devtools/Skills.html>): DONE
(2026-11-15). `wechatide-skill` ships with WeChat DevTools and is linked into the user skill folder
(`~/.claude/skills/wechatide-skill`); use it for every mini program build, run, automation and screenshot
(`CrossPlatform/wechat-miniprogram-cylsearch`). Notes for Windows: see `docs/miniprogram-api-alignment.md`.


`.agents/skills` holds the skills; `.claude/skills` only points there.

| Skill | Use it when |
|:---|:---|
| `cyl-tabbar-integration` | Adding or changing a `CYLTabBarController` in the example (configuration file, plus child view controller, latest commit) |
| `cyl-plus-button` | Writing or changing the plus button: configuration keys, title alignment, Liquid Glass limits |
| `cyl-new-project` | Creating or extending an example project |
| `cyl-api-map` | Finding the public API of `CYLTableViewPlaceHolder` and `CYLTabBarController` |
| `cyl-xcode-compat` | Touching the `.xcodeproj`, Podfile or deployment targets |
| `cyl-sub-repositories` | Adding or updating a sibling project as a sub-repository (CollectionViewClassifyMenu, CYLTableViewPlaceHolder): commit pin, core option, example, every platform |
| `cyl-license` | Any package published to a registry (CocoaPods, Maven/Gradle, npm, pub, ohpm): the MIT `LICENSE` inside its resource bundle, the manifest field, the check |
| `cyl-task-start` | Starting, scoring and finishing any task: check other sessions, `TODO` and branch at the top, the `docs/` entry with acceptance criteria, scoring until it passes, missing points as `TODO`s at the end; restarting a hung emulator |
| `cyl-docs` | Editing `README.md` or `docs/` |
| `cyl-verify` | Building, testing, running the simulator; real pointer input for scrolling and drag gestures |
| `cyl-search-field` | Any search or text field in the core or an example, on any platform: `CYLSearchBarView` with the navigation field preset, never a system search bar |
| `cyl-simulator-run` | Before running a simulator or emulator: the run rules; after the test or screenshot run, terminate the app and stop the simulator process at once, boot again when needed |
| `cyl-api-parity` | Comparing two platforms' APIs: the parity table (source API, description, target counterpart, `TODO` by default), its score, and the loop to 100 |
| `cyl-example-taglist` | A demo or example needs a table-view-like grouped list: show it as ClassifyMenu's tag list (sections, adaptive width, wrapping titles, 3-row fold whose control is the tail tag, icon only, long-press subtitle bubble) |
| `cyl-fix-in-core` | Fixing any issue or bug: in the core (code published to a package registry) first; example-layer fixes only after asking, with the reason documented; the content below the search bar and its scrolling belong to the core |
| `cyl-naming` | Adding or renaming any type, function, member, constant or component: when `CYL` / `cyl_` is required, and the SonarCloud naming rules |
| `cyl-commit` | Writing any commit message: `git cz` style, English only, the author line, the checks before committing |
| `cyl-accessibility-i18n` | Screen readers and localization in any code; writing UI tests that find controls by their labels |
| `cyl-harmonyos-setup` | Preparing DevEco Studio and the HarmonyOS emulator: SDK paths, virtualization, Huawei ID, region `CN` in `country.region.xml` |
| `swift-api-design-guidelines`, `swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture` | Writing or translating Swift (third-party, pinned in `.agents/skills.json`) |
| `uikit`, `uikit-layouting` | UIKit views, controllers and layout in Swift (third-party) |

Every new integration rule updates, in the same change, `AGENTS.md`,
`instructions.md` and the affected skills.
