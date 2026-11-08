---
name: cyl-new-project
description: "Create or extend an Objective-C example using CYLTableViewPlaceHolder."
---

# New example project

- Prefer the existing `CYLSearchViewController.xcodeproj`; do not create a
  second app target for a focused issue reproduction.
- Declare the local dependency in the app Podfile with
  `pod 'CYLTableViewPlaceHolder', :path => '../CYLTableViewPlaceHolder'`.
- Keep `platform :ios, '12.0'`, `use_frameworks!`, and the project declaration
  aligned with the app target. Run `pod install` and open the workspace.
- Import only `<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>`.
- Use `CYL`-prefixed names for newly created project-owned classes and
  protocols. Keep third-party copyright and attribution intact.
- Keep the issue reproduction small and independently configurable. Do not
  couple dependency APIs to the demo's app delegate or sample model.
- Document the run steps and the known `hidesSearchBarWhenScrolling` workaround
  in the repository README.
