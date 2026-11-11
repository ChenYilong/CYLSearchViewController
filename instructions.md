# Folder Instructions

This repository contains an Objective-C search UI sample and the Issue #1317
reproduction for `UISearchController` with `CYLTableViewPlaceHolder` refresh.
Read this file and `AGENTS.md` before changing project files.

## Naming

- Write all instruction and skill files in English.
- Prefix every new project-owned class, protocol, enum, type, function, and
  constant with `CYL`. Name a class file after its primary type.
- Name UIKit category files `<SystemClass>+CYL<Feature>.h` and `.m`; prefix
  every new category method and property with `cyl_`.
- Apply these rules to copied or newly introduced code. Remove unrelated
  third-party prefixes from new code and retain source attribution.
- Do not rename existing project APIs or vendor code as part of unrelated
  changes.

## Xcode and dependencies

- Keep `objectVersion = 46` and `compatibilityVersion = "Xcode 3.2"`.
- Keep explicit project file references; do not use synchronized folder groups.
- For any Xcode project, inspect the Podfile before building or changing
  project settings. Its top section must declare the iOS 15.0 platform, Swift
  5, and the `.xcodeproj` file in the same directory:

  ```ruby
  platform :ios, '15.0'

  ENV['SWIFT_VERSION'] = '5'

  project '<projectname>.xcodeproj'
  ```

- Ensure the Podfile ends with this `post_install` hook. Add it at the bottom
  only if it is missing; do not add duplicate hooks:

  ```ruby
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
      end
    end
  end
  ```

- Keep all app and test Xcode deployment targets at iOS 15.0 to match the
  Podfile and generated Pods project.
- Check that the app target has a populated AppIcon asset set and a launch
  screen storyboard/image configured through `UILaunchStoryboardName`. If
  either is missing, copy the icon and custom launch image from
  `CYLTabBarController/Example/Images.xcassets` and wire them into the target.
- Install dependencies with CocoaPods and open the generated workspace.
- Import the dependency's public umbrella header. Do not access its private
  implementation.
- Keep sample behavior behind protocols or public configuration rather than
  coupling library code to this app, `AppDelegate`, or a concrete data source.

## Issue #1317 reproduction

- The sample combines a navigation-item `UISearchController` with a
  `CYLRefreshNormalHeader`.
- Keep `navigationItem.hidesSearchBarWhenScrolling = NO` in the safe default
  reproduction. Setting it to `YES` is the documented trigger to investigate;
  it may cause repeated inset updates on affected UIKit versions.
- End refresh on every completion path and avoid strong captures of view
  controllers in refresh blocks.

## CYLTabBarController

Adapted from CYLTabBarController's instruction files at its latest commit
(`caf3c92`, branch `feat/cross-platform-components`). Details and the TODO
list: `docs/CYLTabBarController-Integration.md`.

- This project integrates CYLTabBarController by default. Unless a task says
  otherwise, every `CYLTabBarController` in the example layer:
  1. is created from a local configuration file shipped in the app bundle,
     with `+[CYLTabBarController tabBarControllerWithConfigurationFile:error:]`;
  2. has a plus button declared in that file under
     `CYLTabBarControllerPlusButton`, whose `CYLTabBarItemPageIdentifier`
     resolves to the plus child view controller;
  3. gets its pages from providers registered in `CYLTabBarPageRegistry` for
     each `CYLTabBarItemPageIdentifier`, not from a hard-coded array.
- Keep an even number of normal tabs so the plus button sits in the middle;
  set `CYLPlusButtonIndexInTabBar` otherwise. The plus button is not counted
  in the tab items.
- Give the plus button a title when titles are aligned with the tab titles.
- Depend on the newest CYLTabBarController commit on any branch:
  `scripts/latest-cyl-commit.sh --podfile` prints the Podfile line
  (`:git => …, :commit => '<sha>'`). Refresh it before every build; never use
  a version number, branch or tag.
- Import only `<CYLTabBarController/CYLTabBarController.h>`.
- Put search pages inside a `UINavigationController` tab so the
  navigation-item search controller and its Issue #1317 workaround still
  apply.
- Follow the `cyl-tabbar-integration` and `cyl-plus-button` skills.

## Verification

- Validate the CocoaPods integration, parse the Xcode project, and build the
  shared scheme for an installed simulator.
- Run static analysis when supported. Report simulator behavior as unverified
  unless the app was actually launched and exercised.
- Preserve the existing project's license and third-party notices.

## Commit readiness

- Before every commit, review the changed scope and related issue, comparison,
  and implementation-status documents. Record every unfinished or unverified
  item from the commit under a `TODO` heading in the most relevant existing
  document under `docs/`.
- A TODO must state the current status or score, remaining work, implementation
  constraints, known defects or optimization opportunities, API design and
  compatibility concerns, and verification required for completion. Reserved
  keys, stubs, and compilation alone are not evidence of completion.
- Every commit message body carries the author line
  `By  @ChenYilong <luohanchenyilong@163.com>` (two spaces after `By`), after
  the description and before trailers.
- Use an English Conventional Commit subject compatible with Commitizen.
  Summarize completed work in the subject and keep details and remaining work
  in the body. If the detailed description exceeds 50 characters, create or
  update a suitable document under `docs/` and link it from the commit body.
  Reuse relevant documents and avoid duplicate trackers.

### Commitizen defaults

- Use `{type}{scope}: {emoji}{subject}` with emojis enabled. Omit an unnecessary
  scope; no scopes are preconfigured. The configured message length is 3–64
  characters. In readable subjects, separate the emoji and subject with a
  space as shown in the project examples below.
- The interactive type choices, in order, are `test`, `feat`, `fix`, `chore`,
  `docs`, `refactor`, `style`, `ci`, and `perf`. `release` has a type definition
  but is not an interactive choice; use it only for an intentional release.
- Default meanings and emojis: `chore` (build or auxiliary-tool changes, 🤖),
  `ci` (CI changes, 🎡), `docs` (documentation only, ✏️), `feat` (new feature,
  🎸), `fix` (bug fix, 🐛), `perf` (performance improvement, ⚡️), `refactor`
  (neither a feature nor a fix, 💡), `style` (markup or formatting only, 💄),
  `test` (adding missing tests, 💍), and `release` (release commit, 🏹).
- The question sequence is `type`, `scope`, `subject`, `body`, `breaking`,
  `issues`, and `lerna`. Prompts request the type, optional scope, short
  imperative subject, longer description, breaking changes, issues closed
  (for example `#123`), and affected packages.
- Respect established repository history when it uses project-specific
  mappings. CYLTabBarController examples include `feat: ✨`, `fix: 🐛`,
  `docs: 📝`, `chore: 🔧`, and `refactor: ♻️`. Commit text must remain English.

### Commit-message hook before Commitizen commits

Before a Commitizen-style commit, run the following from the repository root:

```sh
cat > .git/hooks/commit-msg << 'HOOKEOF'
#!/bin/sh
tmpfile="$1"
if grep -qi "Co-Authored-By:" "$tmpfile" 2>/dev/null; then
  tmp_clean=$(mktemp)
  grep -vi "Co-Authored-By:" "$tmpfile" > "$tmp_clean"
  cat "$tmp_clean" > "$tmpfile"
  rm -f "$tmp_clean"
fi
HOOKEOF
chmod +x .git/hooks/commit-msg
```

This overwrites the existing `commit-msg` hook and removes every line containing
`Co-Authored-By:`, case-insensitively, including other authors' attribution.
Inspect any existing hook before replacing it. The command assumes `.git` is
a directory and Git uses its default hooks path; linked worktrees and custom
`core.hooksPath` require the appropriate hooks path instead.

## Commitizen commits

Before every Commitizen-style (`git cz`) commit, run this first in the repository root:

```sh
touch .git/hooks/NO_AUTO_SYNC
```

## Committing on branches

On any branch other than `master` or `main`, commit and push as soon as the work is written, without asking for
confirmation. On `master` or `main`, ask first.
