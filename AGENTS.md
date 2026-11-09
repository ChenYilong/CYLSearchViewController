# Agent Instructions

This repository is an Objective-C iOS search sample. It uses
`CYLTableViewPlaceHolder` to demonstrate the interaction between a
navigation-item search controller and pull-to-refresh. Read `instructions.md`
and the applicable skill in `.agents/skills/` before making changes.

## Project rules

- New project-owned types and identifiers use the `CYL` prefix. New UIKit
  category files use `+CYL`; category methods and properties use `cyl_`.
- Do not rename existing APIs or vendor symbols in a task that does not require
  it. Keep original copyright and attribution when adapting third-party code.
- The public integration surface of `CYLTableViewPlaceHolder` is its umbrella
  header. The example must not depend on private headers or implementation
  details.
- Keep the sample configurable through protocols or public properties. Avoid
  dependencies on `AppDelegate`, global state, or concrete model types.
- Keep all instructions and skill files in English.

## Xcode project

- Preserve Xcode project format 46, compatibility version Xcode 3.2, explicit
  file lists, and a shared scheme.
- The Podfile top declares `platform :ios, '15.0'`,
  `ENV['SWIFT_VERSION'] = '5'`, and this directory's `.xcodeproj`.
- The Podfile ends with one `post_install` hook that sets every Pods target's
  `IPHONEOS_DEPLOYMENT_TARGET` to `"15.0"`. Append it at the bottom if missing;
  never add duplicate hooks.
- Keep Xcode app and test deployment targets at iOS 15.0 and use the local
  sibling `CYLTableViewPlaceHolder` pod for this reproduction.
- Verify that the AppIcon asset set contains actual icon files and that the
  launch storyboard/image is configured in the app target. If either is
  missing, reuse the icon and custom launch image from
  `CYLTabBarController/Example/Images.xcassets`.
- Never commit `Pods/`, generated workspace state, or AppleDouble `._*` files.

## Issue #1317

The reproduction uses `UISearchController` in `navigationItem.searchController`
and a `CYLRefreshNormalHeader`. Pinning the search bar with
`hidesSearchBarWhenScrolling = NO` is the known workaround for repeated inset
updates on affected iOS versions. Refresh callbacks must not retain their
controller strongly and must always stop the refresh control.

## Verification

Run `pod install`, validate the project with Xcodeproj/CocoaPods, build and
analyze the shared scheme, and run tests when available. Do not claim a visual
reproduction or fix without launching the sample on a simulator.

## Commit readiness

- **Before every Commitizen-style (`git cz`) commit**, run this first in the repository root, so the vault's auto sync does not commit or push in the middle of it:

  ```sh
  touch .git/hooks/NO_AUTO_SYNC
  ```

- Before a Commitizen-style commit, follow the commit-message hook instructions
  in `instructions.md`; inspect an existing hook before replacing it.
- Before every commit, review the changed scope and its related issue,
  comparison, and implementation-status documentation.
- Track each unfinished or unverified item from the commit under a `TODO`
  heading in the most relevant existing `docs/` document. Include remaining
  work, implementation constraints, known defects, verification steps, and API
  design or compatibility risks. Reserved keys, stubs, and compilation alone
  do not prove completion.
- Use an English Conventional Commit subject compatible with Commitizen. Put
  detailed completion and pending-work summaries in the body. If the detailed
  description exceeds 50 characters, create or update a suitable `docs/` note
  and link it from the commit body; reuse existing tracking documents.
- Follow the Commitizen defaults: `{type}{scope}: {emoji}{subject}`, emojis
  enabled, no predefined scopes, and a 3–64 character message. The interactive
  format examples separate the emoji from the subject with a space. The
  type list is `test`, `feat`, `fix`, `chore`, `docs`, `refactor`, `style`,
  `ci`, `perf`; `release` is defined but not listed. Default emojis are
  `chore` 🤖, `ci` 🎡, `docs` ✏️, `feat` 🎸, `fix` 🐛, `perf` ⚡️,
  `refactor` 💡, `style` 💄, `test` 💍, and `release` 🏹. Follow the established
  project emoji where it differs (e.g. CYLTabBarController uses `feat: ✨`,
  `docs: 📝`, `chore: 🔧`, and `refactor: ♻️`). The question sequence is
  `type`, `scope`, `subject`, `body`, `breaking`, `issues`, and `lerna`;
  prompts cover optional scope, imperative subject, longer description,
  breaking changes, issue references, and affected packages.
