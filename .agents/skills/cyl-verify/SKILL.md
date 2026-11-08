---
name: cyl-verify
description: "Install, build, analyze, and test the search sample and its local CocoaPods dependency."
---

# Verify

1. Run `pod install` from the repository root.
2. Parse the project using `ruby -rxcodeproj -e 'Xcodeproj::Project.open(ARGV[0])' CYLSearchViewController.xcodeproj`.
3. Build the shared scheme from the generated workspace. Confirm the app and
   tests use iOS 15.0, and the Podfile post-install hook sets all Pods targets
   to iOS 15.0.
4. Run `xcodebuild analyze` and the test action when available.
5. Launch and exercise the sample before claiming that the UI reproduces the
   issue or verifies its workaround.

Report build warnings, unavailable simulator checks, and any toolchain override
plainly. Do not commit generated Pods or `._*` files.
