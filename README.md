# CYLSearchViewController
模仿iPhone短信聊天里的搜索框样式，点击搜索后，搜索框平滑移动到导航栏上。

##功能展示
![Example screenshot](https://github.com/ChenYilong/CYLSearchViewController/blob/master/CYLSearchViewController/it_is_effect_show__SearchBar.gif)





[我的微博][1]


  [1]: http://weibo.com/luohanchenyilong/

## Issue #1317 reproduction

The app demonstrates `UISearchController` in a navigation item's search bar
with pull-to-refresh and the `CYLTableViewPlaceHolder` empty-state API.

1. Install CocoaPods dependencies with `pod install`.
2. Open `CYLSearchExample.xcworkspace`.
3. Pull down on the results table to refresh, or search for text with no
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

The `CYLSearchExample` app in the repository root consumes this Pod and the sibling
`CYLTableViewPlaceHolder` repository through local paths. The example owns the
refresh provider, empty-state view, and reproduction switch; these are not
dependencies of the reusable search component.

```sh
pod install
open CYLSearchExample.xcworkspace
```

Run the `CYLSearchExample` scheme, pull down to refresh, and tap **Repro: OFF**
to allow the navigation search bar to scroll. Tap **Repro: ON** to restore the
pinned-bar workaround. Tap **Overlay** to exercise the animated search
controller using the same injected data source. This builds the affected interaction, but iOS 15 is
the minimum for this example and the original iOS 12.3 report has not been
reproduced by these tests.

From the repository root, `scripts/pod-lint.sh lib` validates the Pod and
`scripts/ci-build-example.sh` installs and builds the example. Publishing is
only performed when `scripts/pod-lint.sh push` is explicitly invoked.
