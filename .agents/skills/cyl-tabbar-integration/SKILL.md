---
name: cyl-tabbar-integration
description: "Integrate CYLTabBarController into the CYLSearchViewController example: the default is a local configuration file plus a plus button with a plus child view controller, depending on the latest CYLTabBarController commit. Use whenever a CYLTabBarController is added to or changed in the example."
---

# CYLTabBarController in CYLSearchViewController

Adapted from CYLTabBarController's `AGENTS.md` and its `cyl-new-project`,
`cyl-plus-button` and `cyl-verify` skills at commit `caf3c92`
(`feat/cross-platform-components`, 2026-11-11). Upstream source of truth:
code, then `docs/`, then `README.md`. Upstream docs for this recipe:

- [Configuration-File](https://github.com/ChenYilong/CYLTabBarController/blob/caf3c925966f71edfc87d1dd2ed9f03cbad6aba1/docs/Configuration-File.md)
- [Tab-Page-Registry](https://github.com/ChenYilong/CYLTabBarController/blob/caf3c925966f71edfc87d1dd2ed9f03cbad6aba1/docs/Tab-Page-Registry.md)
- [PlusButton](https://github.com/ChenYilong/CYLTabBarController/blob/caf3c925966f71edfc87d1dd2ed9f03cbad6aba1/docs/PlusButton.md)

These are bilingual: read `[EN]` and skip `[CN]`.

## Default: configuration file + plus child view controller

Unless the task says otherwise, every `CYLTabBarController` in the example layer
is built this way. Do not fall back to `-initWithViewControllers:tabBarItemsAttributes:`
or a code-only `CYLPlusButton` subclass for the default demo.

### 1. Podfile: the latest commit

```sh
scripts/latest-cyl-commit.sh            # <sha> <date> <branch>, newest on any branch
scripts/latest-cyl-commit.sh --podfile  # the Podfile line
```

```ruby
target 'CYLSearchExample' do
  use_frameworks!
  pod 'CYLTabBarController', :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '<sha>'
  # existing pods stay
end
```

Run it again before every build; never a version, branch or tag. Keep the
Podfile header and the single `post_install` hook (`cyl-xcode-compat`).

### 2. The local configuration file

Add `CYLSearchExample/CYLTabBarConfiguration.json` to the app target's
Resources phase (explicit file reference, project format 46). Supported
formats also include plist, YAML and TOML; JSON is the default here.

```json
{
  "CYLTabBarControllerContext": "CYLSearchExample",
  "CYLTabBarControllerStyleType": "default",
  "CYLTabBarControllerTitlePositionAdjustment": "{0, -2}",
  "CYLTabBarControllerTabBarItemsAttributes": [
    { "CYLTabBarItemTitle": "Search", "CYLTabBarItemImage": "system:magnifyingglass",
      "CYLTabBarItemSelectedImage": "system:magnifyingglass", "CYLTabBarItemIdentifier": "search",
      "CYLTabBarItemPageIdentifier": "search" },
    { "CYLTabBarItemTitle": "Menu", "CYLTabBarItemImage": "system:list.bullet",
      "CYLTabBarItemSelectedImage": "system:list.bullet", "CYLTabBarItemIdentifier": "menu",
      "CYLTabBarItemPageIdentifier": "menu" }
  ],
  "CYLTabBarControllerPlusButton": {
    "CYLTabBarItemTitle": "Publish",
    "CYLTabBarItemImage": "system:plus.circle.fill",
    "CYLTabBarItemIdentifier": "plus",
    "CYLTabBarItemPageIdentifier": "plus"
  }
}
```

- An even number of normal tabs puts the plus button in the middle; otherwise
  set `CYLPlusButtonIndexInTabBar`.
- The plus button is not in `CYLTabBarControllerTabBarItemsAttributes`.
- `CYLTabBarItemPageIdentifier` inside `CYLTabBarControllerPlusButton` is what
  creates the plus child view controller: the library resolves it like a tab
  page and, when the page has no title, gives it the plus button's title.
- Give the plus button a title: aligned titles without one are not supported.

### 3. Pages and the controller

```objc
#import <CYLTabBarController/CYLTabBarController.h>

CYLTabBarPageRegistry *pages = CYLTabBarPageRegistry.sharedRegistry;
[pages registerPageProvider:^UIViewController *(NSString *pageIdentifier, NSDictionary<NSString *, id> *tab) {
    // A search page lives in a navigation controller, so navigationItem.searchController
    // and the Issue #1317 workaround (hidesSearchBarWhenScrolling = NO) keep working.
    return [[UINavigationController alloc] initWithRootViewController:[[CYLSearchExampleViewController alloc] init]];
} forPageIdentifier:@"search"];
// ... one provider per page ID, including @"plus" for the plus child view controller.

NSError *error = nil;
CYLTabBarController *tabBarController =
    [CYLTabBarController tabBarControllerWithConfigurationFile:@"CYLTabBarConfiguration.json" error:&error];
NSAssert(tabBarController, @"CYLTabBarConfiguration.json: %@", error);
window.rootViewController = tabBarController ?: fallbackViewController;
```

- Register providers before creating the controller. A missing page ID skips
  that tab: check `error` and the console.
- A tap action on the plus button is code only: load the dictionary with
  `+configurationWithContentsOfFile:error:`, add
  `CYLTabBarControllerPlusButtonAction`, then `-initWithConfiguration:`.
- Keep the composition in the example (scene or app delegate). Search
  components in `Sources/` must not import CYLTabBarController.
- Use `CYL`-prefixed names for new example classes (`CYLSearchExamplePlusViewController`).

## Checks

1. `scripts/latest-cyl-commit.sh` and the Podfile name the same sha.
2. `pod install`, then a clean build of the shared scheme.
3. On a simulator: the tabs and the plus button appear from the file, the
   plus button opens its child view controller, the search tab still pins
   its search bar, and VoiceOver reads every tab and the plus button.
4. Record anything not run on a simulator under `TODO` in
   `docs/CYLTabBarController-Integration.md`.

## Search bar placement

A search bar never covers the main view, the view controller's view
(`self.view`), or any other view, at any time: a navigation-item
`UISearchController`, a `CYLSearchBarView` and the overlay, in every state and
at every Dynamic Type size. Full rule: `AGENTS.md`, "Search bar placement".

- Inside a tab, a search page sits in a `UINavigationController`; its view
  starts below the navigation bar and its search field, and the tab bar does
  not change that.
- The plus child view controller follows the same rule when it shows a
  search bar.

## Task log before every task

Before any task, log it as `TODO` in the most suitable document in `docs/`
(else `docs/task-log.md`): context, the user's requirements, the user's prompt
(verbatim plus English translation) and a status line. Commit and push it,
then start; mark it `DONE (YYYY-MM-DD)` with the result when the task ends.
Full rule: `AGENTS.md`, "Task log before every task".

## Swift

Swift code follows `docs/swift-coding-standard.md` and the third-party Swift skills in `.agents/skills`
(`swift-api-design-guidelines`, `swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture`,
`uikit`, `uikit-layouting`). The core's translation and its score: `docs/swift-migration.md`.

## Screenshots

Screenshots of builds and CI/CD: committed, shown in `docs/`, clear originals, labeled with platform,
environment, version or commit, and time; README updated at key milestones (`AGENTS.md`, "Screenshots of builds
and CI/CD").

## Open pull requests and issues of projects we translate

When we translate or port another GitHub project's code (for example `android/`), merge its open pull requests
(before translating, or translate and merge them afterwards), list its open issues in a `docs/` table (issue link,
description, fix status `TODO`), fix them in our code and score after every fix until 100; a translation that has not
started begins at 60. Full rule: `AGENTS.md`, same section.

## Raised plus button in examples

When an example demonstrates a plus button, always prefer the raised effect: the top of the plus button rises
above the top edge of the tab bar (`CYLPlusButtonCenterYMultiplier` below 0.5 with a button taller than half the bar,
or `CYLPlusButtonCenterYOffset`). Keep the whole button tappable and never let it cover the page content above the
bar. Example: `android/merged/app/src/main/assets/CYLTabBarConfiguration.json` (56 dp, multiplier 0.3).

## Screenshot stitching order

Stitched screenshots: stacked top to bottom first, then two columns over several rows, then one row of at most
three. Correction (user, 2026-11-12): the original wording, "prefer the horizontal arrangement" and "worst is horizontal stitching", contradicted itself; the rule is to prefer the vertical arrangement, one image per row stacked top to bottom.
