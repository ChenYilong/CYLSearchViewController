---
name: cyl-new-project
description: "Create or extend an Objective-C example using CYLTableViewPlaceHolder and CYLTabBarController (configuration file plus plus child view controller by default)."
---

# New example project

- Prefer the existing `CYLSearchExample.xcodeproj`; do not create a
  second app target for a focused issue reproduction.
- Declare the local dependency in the app Podfile with
  `pod 'CYLTableViewPlaceHolder', :path => '../CYLTableViewPlaceHolder'`.
- Keep `platform :ios, '15.0'`, `ENV['SWIFT_VERSION'] = '5'`,
  `use_frameworks!`, and the project declaration aligned with the app target. Run `pod install` and open the workspace.
- Import only `<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>`.
- Use `CYL`-prefixed names for newly created project-owned classes and
  protocols. Keep third-party copyright and attribution intact.
- Keep the issue reproduction small and independently configurable. Do not
  couple dependency APIs to the demo's app delegate or sample model.
- Document the run steps and the known `hidesSearchBarWhenScrolling` workaround
  in the repository README.

## CYLTabBarController

Adapted from CYLTabBarController's `cyl-new-project` skill (commit `caf3c92`).

- The example integrates CYLTabBarController by default. Unless a task says
  otherwise, build it from a local configuration file with a plus button that
  has a plus child view controller: follow `cyl-tabbar-integration`.
- Depend on the latest commit on any branch, never a version, branch or tag:
  `scripts/latest-cyl-commit.sh --podfile`, then `pod install`.
- Import only `<CYLTabBarController/CYLTabBarController.h>`.
- Do not start from an Xcode template: it writes a newer project format.
- Do not set `UIViewControllerBasedStatusBarAppearance = NO`, and add no
  orientation limit in code; the target settings decide.
- Plus button details: `cyl-plus-button`.
