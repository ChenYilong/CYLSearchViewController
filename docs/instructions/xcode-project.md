# Xcode project [`xcode-project`]

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

## Podfile and dependency details (moved from `instructions.md`, 2026-11-29)

- Do not use synchronized folder groups.
- For any Xcode project, inspect the Podfile before building or changing project settings. Its top section:

  ```ruby
  platform :ios, '15.0'

  ENV['SWIFT_VERSION'] = '5'

  project '<projectname>.xcodeproj'
  ```

- The `post_install` hook at the bottom of the Podfile:

  ```ruby
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
      end
    end
  end
  ```

- The launch screen is configured through `UILaunchStoryboardName`.
- Install dependencies with CocoaPods and open the generated workspace.
