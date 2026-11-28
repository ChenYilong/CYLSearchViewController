> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Produced by script comparison or setting extraction; run-time effects are unverified.

# Build and app configuration

Read 2026-11-29 by the main session. Small files were read in full; project, lock, scheme and storyboard files were read **by extracting selected settings with a script**, not line by line. Lock files record what was resolved last; nothing was resolved or built now.

## Toolchain
- Gradle 9.4.1: `android/merged`, React Native example, Flutter example (the `-all` distribution).
- `android/merged/gradle/libs.versions.toml`: svgaplayer = 2.6.1; agp = 9.2.1; kotlin = 2.2.20; appcompat = 1.7.0; fragment = 1.8.5; material = 1.12.0; constraintlayout = 2.2.0; recyclerview = 1.3.2; cardview = 1.0.0; viewpager = 1.0.0; json = 20240303; robolectric = 4.14.1; junit = 4.13.2; lottie = 6.6.2; androidx-test-core = 1.6.1; viewpager2 = 1.0.0; core-ktx = 1.13.1; activity = 1.9.3; customview = 1.1.0; swiperefreshlayout = 1.1.0; cyldeallocblockexecutor = c85c10c0dac23308a5373e4ab4f4e1da7bc41ed9.
- CocoaPods 1.17.0 in all three `Podfile.lock` files.
- Flutter `pubspec.lock` (has an uncommitted change): Dart >=3.13.7 <4.0.0; direct packages: cupertino_icons 1.0.9 (direct main); flutter 0.0.0 (direct main); flutter_cylsearch 0.1.0 (direct main); flutter_cyltabbar 0.0.1 (direct main); flutter_lints 6.0.0 (direct dev); flutter_test 0.0.0 (direct dev); integration_test 0.0.0 (direct dev).
- React Native 0.88.0 (iOS lock).
- `scripts/pod-lint.xcconfig`: iOS 15.0 for `pod lint`.

## Xcode projects
| Project | objectVersion | iOS target | Native targets | Bundle ids |
|:---|---:|:---|:---|:---|
| `CYLSearchExample.xcodeproj` | 46 | 15.0 | CYLSearchExampleTests, CYLSearchExample | com.chenyilong.CYLSearchExample ; com.chenyilong.CYLSearchExampleTests |
| `CrossPlatform/flutter_cylsearch/example/ios/Runner.xcodeproj` | 54 | 15.0 | RunnerTests, Runner | com.cyl.search.flutterCylsearchExample ; com.cyl.search.flutterCylsearchExample.RunnerTests |
| `CrossPlatform/react-native-cylsearch/example/ios/CylsearchExample.xcodeproj` | 54 | 15.1 | CylsearchExample | cylsearch.example |

All use Swift 5.0 and device families 1,2. Script phases: iOS example: [CP] Check Pods Manifest.lock, [CP] Copy Pods Resources. flutter_cylsearch: Fetch Rive tab icons, [CP] Embed Pods Frameworks, Thin Binary, [CP] Copy Pods Resources, Run Script, [CP] Check Pods Manifest.lock. react-native-cylsearch: Bundle React Native code and images, [CP] Embed Pods Frameworks, Copy Rive tab icons, [CP] Check Pods Manifest.lock, [CP] Copy Pods Resources.

## Resolved iOS pods (git commits in the lock files)
| Lock file | Commits |
|:---|:---|
| `CrossPlatform/flutter_cylsearch/example/ios/Podfile.lock` | CollectionViewClassifyMenu `c0b183de`, CYLAnimatedItem `08343e9f`, CYLDeallocBlockExecutor `eab21d10`, CYLTabBarController `08343e9f`, CYLTableViewPlaceHolder `f4cf9785` |
| `CrossPlatform/react-native-cylsearch/example/ios/Podfile.lock` | CollectionViewClassifyMenu `c0b183de`, CYLDeallocBlockExecutor `eab21d10`, CYLTableViewPlaceHolder `f4cf9785` |
| `Podfile.lock` | CollectionViewClassifyMenu `c0b183de`, CYLAnimatedItem `08343e9f`, CYLDeallocBlockExecutor `eab21d10`, CYLTabBarController `08343e9f`, CYLTableViewPlaceHolder `f4cf9785` |

In the React Native example, CYLTabBarController and CYLAnimatedItem come from the local path `../vendor/CYLTabBarController`, so its lock records no commit for them. The other pins match across the three locks.

Non-React pods:
- `CrossPlatform/flutter_cylsearch/example/ios/Podfile.lock`: CollectionViewClassifyMenu (0.1.0), CYLAnimatedItem (1.100.0), CYLDeallocBlockExecutor (1.4.0), CYLSearchViewController (0.1.0), CYLTabBarController (1.100.0), Flutter (1.0.0), flutter_cylsearch (0.1.0), flutter_cyltabbar (0.1.0), integration_test (0.0.1), lottie-ios (4.6.1), Protobuf (3.27.2), RiveRuntime (6.29.0), SSZipArchive (2.4.3), SVGAPlayerLite (1.0.8)
- `CrossPlatform/react-native-cylsearch/example/ios/Podfile.lock`: CollectionViewClassifyMenu (0.1.0), CYLAnimatedItem (1.100.0), CYLDeallocBlockExecutor (1.4.0), Cylsearch (0.1.0), CYLSearchViewController (0.1.0), Cyltabbar (0.1.0), CYLTabBarController (1.100.0), lottie-ios (4.6.1), Protobuf (3.27.2), react-native-safe-area-context (5.11.1), RiveRuntime (6.29.0), SSZipArchive (2.4.3), SVGAPlayerLite (1.0.8)
- `Podfile.lock`: CollectionViewClassifyMenu (0.1.0), CYLAnimatedItem (1.100.0), CYLDeallocBlockExecutor (1.4.0), CYLSearchViewController (0.1.0), lottie-ios (4.6.1), Protobuf (3.27.2), SSZipArchive (2.4.3), SVGAPlayerLite (1.0.8)

## App settings
- **iOS example** (`CYLSearchExample/Info.plist`): localizations en, zh-Hans, zh-Hant, ja; scene delegate `CYLSearchExampleSceneDelegate`; portrait only; microphone and speech-recognition usage texts (voice search example), written in English in the plist; launch storyboard `CYLLaunchScreen` (shows the image `CYLTabBar`).
- **Flutter example** `Info.plist`: portrait and both landscapes on iPhone, all four on iPad; scene delegate; no usage-description keys. Debug and Release xcconfig include the Pods file and `Generated.xcconfig`.
- **React Native example** `Info.plist`: new architecture on; arbitrary loads off, local networking on; `NSLocationWhenInUseUsageDescription` is present with an empty string; portrait on iPhone. A search of `CrossPlatform` for speech, recording and location APIs found nothing.
- **Privacy manifests:** the Flutter plugin declares no tracking, collected data or required-reason APIs. The React Native example declares UserDefaults (CA92.1), file timestamp (C617.1) and system boot time (35F9.1), no tracking.
- **Resource bundle** id: `com.chenyilong.CYLSearchViewController.resources`.
- **HarmonyOS:** app name `CYLSearch`; layered icon (background + foreground); one page `pages/Index`; tests use `testability/pages/Index`.
- **Schemes:** each app scheme lists its test target; for React Native that target is missing (see findings).

## Not read
The debug keystore, `.xcode.env`, `.bundle/config`, the bundled yarn file, Gradle wrapper jars and scripts, workspace settings files, asset catalog `Contents.json` files, Android drawable/theme XML, animation JSON.
