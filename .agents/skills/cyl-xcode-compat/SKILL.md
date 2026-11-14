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

## Screenshots

Screenshots of builds and CI/CD: committed, shown in `docs/`, clear originals, labeled with platform,
environment, version or commit, and time; README updated at key milestones (`AGENTS.md`, "Screenshots of builds
and CI/CD").

## Open pull requests and issues of projects we translate

When we translate or port another GitHub project's code (for example `android/`), merge its open pull requests
(before translating, or translate and merge them afterwards), list its open issues in a `docs/` table (issue link,
description, fix status `TODO`), fix them in our code and score after every fix until 100; a translation that has not
started begins at 60. Full rule: `AGENTS.md`, same section.

## Sub-repositories

CollectionViewClassifyMenu and CYLTableViewPlaceHolder are sub-repositories: pinned to their newest commit (never a
local path in a commit), used through an enum or parameter of the core, shown in the example, on every platform.
CYLTableViewPlaceHolder shows its empty-content placeholder when a search has no results. Follow the
`cyl-sub-repositories` skill.

## Screenshot stitching order

Stitched screenshots: stacked top to bottom first, then two columns over several rows, then one row of at most
three. Correction (user, 2026-11-12): the original wording, "prefer the horizontal arrangement" and "worst is horizontal stitching", contradicted itself; the rule is to prefer the vertical arrangement, one image per row stacked top to bottom.

## Swift core: examples adapt to the core (added 2026-11-13)

When an Objective-C to Swift change of the core breaks an example's build, fix the example: example code has the lowest weight of all code here. Change any example code as needed; never keep a core API, overload, shim or deprecated alias only because an example uses it, and never lower the Swift core's quality (naming, types, optionality, access control) to fit an example. Compatibility matters only for callers outside the examples (published API users). The Swift coding standard (docs/swift-coding-standard.md) decides. Rule and context: [docs/swift-migration.md](../../../docs/swift-migration.md).
