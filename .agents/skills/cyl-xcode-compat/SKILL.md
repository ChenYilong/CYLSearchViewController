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

## CYLTabBarController

- Add the CYLTabBarController configuration file to the app target with an
  explicit file reference and a Resources build phase entry; no folder sync.
- The CYLTabBarController pod line uses `:git` and `:commit` from
  `scripts/latest-cyl-commit.sh --podfile`, inside the existing target, with
  the single `post_install` hook unchanged.
- Deployment targets stay at iOS 15.0 (below 27); CI opens projects with
  Xcode 26, so keep project format 46.

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
