---
name: cyl-xcode-compat
description: "Xcode project format, deployment target, CocoaPods workspace, and simulator compatibility for this sample."
---

# Xcode compatibility

- Keep `objectVersion = 46` and `compatibilityVersion = "Xcode 3.2"`.
- Use explicit `PBXFileReference` / `PBXBuildFile` entries. Do not add
  `PBXFileSystemSynchronizedRootGroup` or newer project-format keys.
- Keep a shared `.xcscheme` under
  `CYLSearchExample.xcodeproj/xcshareddata/xcschemes/`.
- The Podfile declares `platform :ios, '15.0'`,
  `ENV['SWIFT_VERSION'] = '5'`, and the matching `.xcodeproj` at the top.
- Ensure its final section contains one `post_install` hook that sets every
  Pods target's `IPHONEOS_DEPLOYMENT_TARGET` to `"15.0"`; append only if
  missing.
- Keep app and test Xcode deployment targets at iOS 15.0.
- Verify AppIcon files and a configured `UILaunchStoryboardName` launch
  storyboard/image. If either is missing, copy from
  `CYLTabBarController/Example/Images.xcassets` and add it to the target.
- Keep `PRODUCT_BUNDLE_IDENTIFIER` consistent with the app and test Info.plists.
- Open the generated `.xcworkspace` after installing pods.
