# CYLTabBarController [`cyl-tabbar`]

This project integrates CYLTabBarController by default. Rules adapted from
CYLTabBarController's `AGENTS.md` and `cyl-*` skills at its latest commit
(`caf3c92`, branch `feat/cross-platform-components`, 2026-11-11); see
`docs/CYLTabBarController-Integration.md` for the source and the status.

- **Default integration in the example layer.** Unless a task says otherwise,
  every `CYLTabBarController` in the example (`CYLSearchExample/`) is created
  from a **local configuration file** in the app bundle, and has a **plus
  button with a plus child view controller**. Never write tabs, the plus
  button or a `CYLPlusButton` subclass only in code for the default demo.
  - The file (for example `CYLSearchExample/CYLTabBarConfiguration.json`) holds
    `CYLTabBarControllerTabBarItemsAttributes` (an even number of tabs, each
    with `CYLTabBarItemIdentifier` / `CYLTabBarItemPageIdentifier`) and
    `CYLTabBarControllerPlusButton` with `CYLTabBarItemTitle`,
    `CYLTabBarItemImage` and `CYLTabBarItemPageIdentifier`. The page found for
    the plus button's page ID becomes the plus child view controller.
  - Register a page provider for every page ID in
    `CYLTabBarPageRegistry.sharedRegistry` (or a registry passed as
    `CYLTabBarControllerPageRegistry`), then create the controller with
    `+[CYLTabBarController tabBarControllerWithConfigurationFile:error:]`.
    Handle the error: never leave the window without a root view controller.
  - Plus button taps that need code use `CYLTabBarControllerPlusButtonAction`
    (code only); read the configuration with
    `+configurationWithContentsOfFile:error:` and add the action before
    `-initWithConfiguration:`.
  - Full recipe: the `cyl-tabbar-integration` skill. Plus button limits: the
    `cyl-plus-button` skill.
- **Depend on the latest commit, through CocoaPods.** Before every build, run
  `scripts/latest-cyl-commit.sh --podfile`; it prints the newest commit on any
  branch by commit timestamp. Put that line into the Podfile:
  `pod 'CYLTabBarController', :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '<sha>'`.
  Never a version number, branch or tag. Run `pod install`, then build. Name
  the commit (sha, date, branch) in the report; if it cannot be fetched, say
  so and keep the sha already in the Podfile.
- **Imports.** The example imports only
  `#import <CYLTabBarController/CYLTabBarController.h>`, like the other pods'
  umbrella headers.
- **Search inside tabs.** A tab page that shows search embeds its view
  controller in a `UINavigationController`, so
  `navigationItem.searchController` and the Issue #1317 workaround keep
  working. Do not put the search bar on the tab bar controller itself.
- **Reading CYLTabBarController docs.** Its `docs/` and comments are
  bilingual: read the `[EN]` part and skip the `[CN]` part; in a
  `中文 | English` table read the right column. Code wins over `docs/`, and
  `docs/` over `README.md`.
- **Accessibility.** Tabs, the plus button, badges and every control in the
  example have meaningful accessibility labels; tests find elements by label
  or identifier before coordinates.
- **Clean builds.** Build into an empty derived data folder after a
  dependency change, so the app does not run stale pod code.
