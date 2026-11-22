# macOS-only: iOS, Xcode, CocoaPods (tag: `macos`)

Details of the `macos` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

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

## Search bar placement

- A search bar never covers any view, at any time: not a view controller's
  view (`self.view`), not a sibling, a background view or a bar item; for a
  navigation-item search controller, `CYLSearchBarView` and the overlay; in
  every state and at every Dynamic Type size. Views of search screens do not
  extend under the top bar (`edgesForExtendedLayout` without
  `UIRectEdgeTop`); a `CYLSearchBarView` is laid out against the safe area,
  beside the content, never on top of it, and a colored area behind it ends
  where the bar begins. `testSearchBarsCoverNoView` checks every search bar
  with `CYLViewsCoveredByView`; add each new one there.

## Issue #1317

The reproduction uses `UISearchController` in `navigationItem.searchController`
and pull-to-refresh on its table through the core's refresh API:
`CYLSearchView.setRefreshHandler(_:for:)` adds it and `CYLSearchView.endRefreshing(in:)` stops it
(CYLTableViewPlaceHolder's normal header inside; the example never calls CYLTableViewPlaceHolder's refresh API
directly). Pinning the search bar with
`hidesSearchBarWhenScrolling = NO` is the known workaround for repeated inset
updates on affected iOS versions. Refresh handlers must not retain their
controller strongly and must always end the refresh (`endRefreshing(in:)` on every completion path).

## Running scripts: prefer bash (added 2026-11-16)

- Run scripts with bash first: write them as `#!/usr/bin/env bash` files and run them with `bash script.sh`, or pipe
  a heredoc to `bash` (`bash <<'EOF' … EOF`), instead of typing them straight into the interactive shell.
- Reason: the default shell here is zsh, and zsh does not split an unquoted variable into words. For example, with
  `box="10 20 30 40"`, `sips --cropOffset $box …` passes one argument in zsh but four in bash. The error this rule
  avoids: "zsh doesn't split $box into words either. Running the same measurement as a bash script."
- In zsh, when a script cannot be used, split explicitly (`${=box}`) or use an array; never rely on word splitting.

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

- The sample combines a navigation-item `UISearchController` with pull-to-refresh
  added through the core: `CYLSearchView.setRefreshHandler(_:for:)` on the table and
  `CYLSearchView.endRefreshing(in:)` to stop it. The example never calls CYLTableViewPlaceHolder's refresh API
  directly.
- Keep `navigationItem.hidesSearchBarWhenScrolling = NO` in the safe default
  reproduction. Setting it to `YES` is the documented trigger to investigate;
  it may cause repeated inset updates on affected UIKit versions.
- End refresh on every completion path and avoid strong captures of view
  controllers in refresh blocks.
