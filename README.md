# CYLSearchViewController
模仿iPhone短信聊天里的搜索框样式，点击搜索后，搜索框平滑移动到导航栏上。

## 功能展示
![Example screenshot](https://github.com/ChenYilong/CYLSearchViewController/blob/master/CYLSearchViewController/it_is_effect_show__SearchBar.gif)

## Screenshots

Key details of the current example, stacked top to bottom: `CYLSearchBarView` with text, a camera accessory and
Cancel (plus page); the Issue #1317 screen with its pinned search bar; `CYLSearchView` suggestions (the
MaterialSearchView "Default" port); `CYLMultiSearchView` with two searches and its event log.

![Key details of the iOS example](docs/assets/readme-ios-key-details.png)

| Field | Value |
|:---|:---|
| Platform | iOS (the core is Swift; the example is Objective-C and Swift) |
| Host | macOS 27.3 (26C5035r), Xcode 27.2 (27B52) |
| Simulator | iPhone 17, iOS 26.1 |
| SDK | iOS SDK 27.2, Swift 5 language mode, deployment target iOS 15.0 |
| Repository | [`9735f79`](https://github.com/ChenYilong/CYLSearchViewController/commit/9735f79) on `feat/swift-core` |
| Taken | 2026-11-12 16:14–16:17 NZDT |

More screenshots, one state per row: `docs/search-api-comparison.md` (the Swift ports of five search libraries'
examples) and `docs/CYLTabBarController-Integration.md`.

## Android

`android/` holds the Kotlin translations of the five search libraries and `android/merged`, one Gradle project with
all of them, the `cylsearch` module (the iOS API in Kotlin, under the same names) and an example app that ports the
iOS example. The app uses CYLTabBarController's Android tab bar from a configuration file, with a raised plus
button; CYLTabBarController and CollectionViewClassifyMenu are pinned by commit. Build:
`cd android/merged && ./gradlew assembleDebug` (JDK 17). Details: `docs/android-and-cross-platform.md`, the API
table `docs/android-api-alignment.md`.

`CYLSearchView.suggestionStyle` shows suggestions as a list (top) or as tags from CollectionViewClassifyMenu
(bottom); both tabs of the example filter the same suggestions for "a":

![Android suggestion styles: list and tags](docs/assets/android-suggestion-styles-readme.png)

| Field | Value |
|:---|:---|
| Platform | Android (Kotlin, `android/merged`) |
| Host | macOS 27.3 (26C5035r), JDK 17.0.21, Gradle 9.3.1, AGP 8.7.3, Kotlin 2.0.21 |
| Emulator | `CYL_API35_arm64`, Android 15 (API 35), arm64-v8a, 1080 × 2400 |
| SDK | compileSdk / targetSdk 35, minSdk 23 |
| Repository | [`ffac758`](https://github.com/ChenYilong/CYLSearchViewController/commit/ffac758) on `feat/swift-core`; CYLTabBarController `f410fa7`, CollectionViewClassifyMenu `eb3590e` |
| Taken | 2026-11-12 21:30–21:40 NZDT |





[我的微博][1]


  [1]: http://weibo.com/luohanchenyilong/

## Issue #1317 reproduction

The app demonstrates `UISearchController` in a navigation item's search bar
with pull-to-refresh and the `CYLTableViewPlaceHolder` empty-state API.

1. Install CocoaPods dependencies with `pod install`.
2. Open `CYLSearchExample.xcworkspace`.
3. Select **Search and refresh**, then pull down on the results table to refresh, or search for text with no
   matching results to show the placeholder.
4. The search bar is pinned by default with
   `navigationItem.hidesSearchBarWhenScrolling = NO`. Tap **Repro: OFF** to
   enable the original scrolling behavior on affected iOS versions; tap again
   to restore the workaround.

The reported repeated inset updates were observed with iOS 12.3 and
`UISearchController`. Whether the issue reproduces depends on the UIKit version.

## Local CocoaPods component

The reusable `CYLSearchResultsViewController` lives in
`Sources/CYLSearchViewController` and requires iOS 15 or later. It has no
dependency on the sample app, a particular result model, or a refresh library.
Supply a `CYLSearchResultsDataSource` to provide results and configure cells;
the optional selection callback receives the selected result. The public
`searchController`, `searchResults`, and `reloadSearchResults` allow consumers
to customize search and refresh data. Override `reloadResultsTableView` when
integrating a custom empty-state or table reload mechanism. Use these APIs on
the main thread.

For local development, add the following to a Podfile, adjusting the path:

```ruby
pod 'CYLSearchViewController', :path => '../CYLSearchViewController'
```

The podspec is an unpublished starting point; its `0.1.0` version and source
tag do not imply a CocoaPods release. The original sample remains in the
repository. The Pod also exposes a redesigned `CYLSearchController` that
animates a search overlay over a host view controller. Initialize it with the
same data-source protocol, call `showInViewController:`, and call `hide:` or
use its cancel button to dismiss it. The overlay's public
`resultsViewController` provides the search and results integration points;
its optional delegate receives cancellation. The redesigned interface does not
include the old hard-coded demo results and search-history storage.

## Local Pod reproduction example

The root `CYLSearchExample.xcodeproj` uses app sources in `CYLSearchExample/`
and integration tests in `CYLSearchExampleTests/`. It consumes this Pod and
the sibling `CYLTableViewPlaceHolder` repository through local paths. The example owns the
refresh provider, empty-state view, and reproduction switch; these are not
dependencies of the reusable search component.

```sh
pod install
open CYLSearchExample.xcworkspace
```

Run the `CYLSearchExample` scheme, select **Search and refresh**, pull down to refresh, and tap **Repro: OFF**
to allow the navigation search bar to scroll. Tap **Repro: ON** to restore the
pinned-bar workaround. Tap **Overlay** to exercise the animated search
controller using the same injected data source. This builds the affected interaction, but iOS 15 is
the minimum for this example and the original iOS 12.3 report has not been
reproduced by these tests.

From the repository root, `scripts/pod-lint.sh lib` validates the Pod and
`scripts/ci-build-example.sh` installs and builds the example. Publishing is
only performed when `scripts/pod-lint.sh push` is explicitly invoked.

## Placeholder resources and localization

The Pod includes `CYLSearchViewController.bundle` with 41 offline placeholder
images. `CYLSearchPlaceholderView` exposes its image view and label for
customization; it does not depend on a particular placeholder library. The
example uses it with `CYLTableViewPlaceHolder`.

Choose an image and a message independently, or supply either or both
yourself. Custom text is displayed verbatim, so localize it in your app.

```objc
CYLSearchPlaceholderView *view =
    [[CYLSearchPlaceholderView alloc] initWithStyle:CYLSearchPlaceholderStyleNoResults
                                           message:CYLSearchPlaceholderMessageNetwork];
CYLSearchPlaceholderView *customText =
    [[CYLSearchPlaceholderView alloc] initWithStyle:CYLSearchPlaceholderStyleEmpty text:@"Your message"];
CYLSearchPlaceholderView *customImage =
    [[CYLSearchPlaceholderView alloc] initWithImage:yourImage message:CYLSearchPlaceholderMessageError];
CYLSearchPlaceholderView *customBoth =
    [[CYLSearchPlaceholderView alloc] initWithImage:yourImage text:@"Your message"];
```

The `CYLSearchPlaceholderStyle` enum lists every bundled image, including
network, cloud, sync, error, files, media, people and location states. No
network access is needed. The messages are `Empty`, `NoResults`, `Error` and
`Network`. Image and text inputs must
not be nil; an empty string is allowed. Set `imageView.tintColor` for template
images or customize `imageView` and `textLabel` directly. `initWithKind:`
continues to select the corresponding matching image and message. In the
example, select **Placeholder styles** to explore all 164 built-in combinations
and three custom-input cases.

`CYLSearchResources` loads images from the Pod bundle and resolves localized
strings using preferred languages, falling back to English. English, Simplified
Chinese, Traditional Chinese and Japanese are included; callers can also
request a specific language. Attribution and licenses for the bundled icons
are included in the bundle's `NOTICE` and license files.

## CYLTabBarController (default integration)

The example integrates CYLTabBarController by default: each tab bar controller
is created from a local configuration file and has a plus button with a plus
child view controller. The pod is pinned to the newest CYLTabBarController
commit on any branch (`scripts/latest-cyl-commit.sh --podfile`). The rules are
in `AGENTS.md` and the `cyl-tabbar-integration` skill. The example's root is a
tab bar built from `CYLSearchExample/CYLTabBarConfiguration.json`: Search,
Examples and a plus button that opens the search bar demo, with titles in
English, Simplified and Traditional Chinese and Japanese. Details and
screenshots: `docs/CYLTabBarController-Integration.md`.
