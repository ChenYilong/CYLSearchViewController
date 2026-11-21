# QMUISearchBar and QMUISearchController in CYLSearchBar (Swift)

Design and task record for bringing QMUI_iOS's `QMUISearchBar` and `QMUISearchController` (and the
`UISearchBar+QMUI` / `UISearchController+QMUI` categories they rely on) into this repository's Swift core
(`Sources/CYLSearchBar`), with CYL names, and their example into `CYLSearchExample`.

## TODO (2026-11-21, `feat/harmonyos-parity`, PR #11): port QMUISearchBar / QMUISearchController to Swift

- **Context**: source: `Vibe-Coding-Projects/QMUI_iOS-fixed` (fork of Tencent/QMUI_iOS, imported in `792c9dda`),
  files `QMUIKit/QMUIComponents/QMUISearchBar.{h,m}`, `QMUISearchController.{h,m}` and their dependencies
  `QMUIKit/UIKitExtensions/UISearchBar+QMUI.{h,m}`, `UISearchController+QMUI.{h,m}`. Our current search code:
  `Sources/CYLSearchBar/CYLSearchBarView.swift` (a custom `UIView` bar), `CYLSearchView.swift` (a custom overlay
  with suggestions and results), `CYLSearchResources.swift` (history), plus the legacy Objective-C app files
  `CYLSearchViewController/Class/CYLSearchBar` (a `UISearchBar` subclass) and
  `Class/Controller/CYLSearchController` (a hand-made search page). The owner chose to commit on PR #11's branch
  (asked 2026-11-21: three open PRs otherwise). Design by this session (with the advisor); code by Sonnet agents,
  one per phase, reviewed and tested here between phases. Clone: `/tmp/xpr/csvc-qmui`.
- **Requirements**:
  1. Design document in `docs/` (this file), then the code written by the default Sonnet model.
  2. Rename to this project's naming rules first (`CYL` prefix, `cyl_` for category members), then Swift.
  3. Merge into the project: into a fitting existing class, else as a new class; and merge our fitting code into the
     new class, so that QMUI's design and interfaces are available here.
  4. Replicate QMUI's search bar example in `CYLSearchExample`.
  5. Read QMUI's comments closely: keep its design reasoning and every edge case it handles (the QMUI classes are
     proven in production; our current code is a draft and less robust).
- **Prompt (verbatim)**: "advisor 请参考 下面几个searchbar实现， 进行设计， 设计文档放docs中， 并交给默认sonnet模型进行代码实现。 该实现与我们 的searchbar高度相似， 先改为 合适的类命名规范， 再转为Swift， 再merge到我们的项目中， 找到合适的类合并。 如果没有合适的类就单独放项目中，并将我们项目中合适的代码也按照这个新加入的类进行合并， 保证可以将下面的类的设计， 以及接口引入我们的项目。 并将下面项目中对应的searchbar 的exmaple 也复刻进我的的Example中， 并详细阅读下面代码中注释， 注意他说明的设计思路， 以及边界场景处理，下面几个类是经过实际项目的验证的， 我们现有代码仅仅是草稿， 总体没有下面的代码更健壮。 /Volumes/obsidian/chenyilong/chenyilong/Vibe-Coding-Projects/QMUI_iOS-fixed/QMUIKit/QMUIComponents/QMUISearchBar.h /Volumes/obsidian/chenyilong/chenyilong/Vibe-Coding-Projects/QMUI_iOS-fixed/QMUIKit/QMUIComponents/QMUISearchBar.m /Volumes/obsidian/chenyilong/chenyilong/Vibe-Coding-Projects/QMUI_iOS-fixed/QMUIKit/QMUIComponents/QMUISearchController.h /Volumes/obsidian/chenyilong/chenyilong/Vibe-Coding-Projects/QMUI_iOS-fixed/QMUIKit/QMUIComponents/QMUISearchController.m"
- **Prompt (English)**: "Advisor, use the search bar implementations below as the reference for a design; put the design
  document in docs and hand the implementation to the default Sonnet model. It is very similar to our search bar: first
  rename to suitable class naming rules, then convert to Swift, then merge into our project, finding the fitting classes
  to merge with. If no class fits, add it to the project on its own, and merge the fitting code of our project into the
  new class, so that the design and interfaces of the classes below come into our project. Also replicate the
  corresponding search bar example of that project into our Example. Read the comments in the code below in detail:
  note the design reasoning they explain and the handling of edge cases; these classes are proven in real projects,
  our existing code is only a draft and overall less robust than theirs." (followed by the four file paths above)
- **Requirements (added 2026-11-21, second message)**: the implementation follows QMUI_iOS-fixed
  `docs/issue-tracker.md` and handles the search issues [#1319](https://github.com/Tencent/QMUI_iOS/issues/1319),
  [#1251](https://github.com/Tencent/QMUI_iOS/issues/1251), [#1229](https://github.com/Tencent/QMUI_iOS/issues/1229),
  [#1313](https://github.com/Tencent/QMUI_iOS/issues/1313), [#1160](https://github.com/Tencent/QMUI_iOS/issues/1160) and
  the `issues1160-TestSearchBar` project. Prompt (verbatim): "默认模型在代码实现过程中， 要参考 /Volumes/obsidian/chenyilong/chenyilong/Vibe-Coding-Projects/QMUI_iOS-fixed/docs/issue-tracker.md  注意实现过程中， 考虑里面的searchbar相关的issue https://github.com/Tencent/QMUI_iOS/issues/1319 https://github.com/Tencent/QMUI_iOS/issues/1251  https://github.com/Tencent/QMUI_iOS/issues/1229  https://github.com/Tencent/QMUI_iOS/issues/1313 https://github.com/Tencent/QMUI_iOS/issues/1160 /Volumes/obsidian/chenyilong/chenyilong/Vibe-Coding-Projects/QMUI_iOS-fixed/issues1160-TestSearchBar". English: "While the default model implements the code, it must refer to issue-tracker.md and take the search bar issues in it into account: #1319, #1251, #1229, #1313, #1160, and the issues1160-TestSearchBar project."
- **Status**: design written (below); phase 1 next.

## Sources read (2026-11-21)

| Source | Where | Notes |
| --- | --- | --- |
| `QMUISearchBar.{h,m}` (20 + 40 lines) | QMUI_iOS-fixed `792c9dda`, `QMUIKit/QMUIComponents/` | A `UISearchBar` subclass that only calls `qmui_styledAsQMUISearchBar`. |
| `QMUISearchController.{h,m}` (168 + 537) | same | Wrapper view controller around `UISearchController`, its results table, launch view, empty view, swipe to dismiss, the #1541 leak fixes, `QMUICommonTableViewController (Search)`. |
| `UISearchBar+QMUI.{h,m}` (116 + 951) | `QMUIKit/UIKitExtensions/` | Styling (placeholder / text / font / margins / cancel button / accessory views) and the table-header bug fixes (#233, #830, #950, #1207, #1473, iOS 13/14 layout). |
| `UISearchController+QMUI.{h,m}` (42 + 279) | same | `alwaysShowSearchResultsController`, `forwardAppearanceMethodsFromPresentingController`, `dimmingColor`, `launchView`, `searchBarMaxY`, the #680 transition fix. |
| `QDSearchViewController.m`, `QDSearchBarViewController.m` | [QMUI/QMUIDemo_iOS](https://github.com/QMUI/QMUIDemo_iOS) `018ca3a3`, `qmuidemo/Modules/Demos/UIKit/` (not in the vault; read from GitHub) | The two demo screens to replicate (below). |
| `docs/issue-tracker.md`, `docs/issue-answers.md` | QMUI_iOS-fixed | Search issues the owner named: #1160, #1229, #1251, #1313, #1319; also #128, #233, #680, #830, #950, #1207, #1473, #1541 from the source comments. |
| `issues1160-TestSearchBar/` | QMUI_iOS-fixed | Only an empty Xcode template (`ViewController.m` has an empty `viewDidLoad`): the #1160 scenario is rebuilt here from the issue text. |

## Decisions

1. **Target**: this repository's core, `Sources/CYLSearchBar` (pod `CYLSearchViewController`, module
   `CYLSearchViewController`). Commits on `feat/harmonyos-parity` (PR #11), as the owner chose.
2. **No existing class fits a merge.** `CYLSearchBarView` is a custom `UIView` field (not a `UISearchBar`), and
   `CYLSearchView` is a custom overlay (not a `UISearchController`). QMUI's classes wrap UIKit's own search controller,
   so they come in as **new classes**, and our fitting code is merged into them (table below). `CYLSearchBarView` and
   `CYLSearchView` keep their API; they are not folded into the new classes.
3. **Names** (`CYL` prefix; Swift names without underscores, Objective-C names through `@objc(...)`):

   | QMUI | CYL (Swift / Objective-C) | File |
   | --- | --- | --- |
   | `QMUISearchBar` | `CYLSearchBar` (`UISearchBar` subclass) | `Sources/CYLSearchBar/CYLSearchBar.swift` |
   | `UISearchBar (QMUI)` members | members of `CYLSearchBar` (no category: the subclass can override `layoutSubviews`, so no swizzling) plus `CYLSearchBarAppearance` (the style values QMUI took from its configuration table) | same file + `CYLSearchBarAppearance.swift` |
   | `QMUISearchController` | `CYLSearchController` (`UIViewController` wrapper, same shape as QMUI's) | `CYLSearchController.swift` |
   | `UISearchController (QMUI)` members | members of `CYLSearchController`, implemented in a private `UISearchController` subclass (`CYLSystemSearchController`) that it owns | same file |
   | `QMUISearchControllerDelegate` | `CYLSearchControllerDelegate` (`@objc`, `UITableViewDataSource & UITableViewDelegate`) | same file |
   | `QMUISearchResultsTableViewController` | `CYLSearchResultsTableViewController` (internal) | same file |
   | `QMUICommonTableViewController (Search)` | `CYLSearchTableViewController` (`UITableViewController` subclass with `showsSearchBar`, `searchController`, `searchBar`, `hidesSearchBarWhenEmptyViewShowing`) | `CYLSearchTableViewController.swift` |
   | `QMUIEmptyView` | `CYLTableViewPlaceHolder` (already a dependency, `CYLPlaceholderScenario` as in `CYLSearchView`) | — |

   The legacy Objective-C `CYLSearchViewController/Class/CYLSearchBar` and `Class/Controller/CYLSearchController` are
   **not compiled** by any target (`CYLSearchExample.xcodeproj` has no reference to `CYLSearchViewController/Class`),
   so the names are free in the module. Their behaviour is merged (below) and the files stay untouched as history.
4. **iOS 15 floor, no private API, no global swizzling.** QMUI hooks private classes and selectors
   (`_UISearchControllerView`, `UIDimmingView`, `_updateVisibilityOfSearchResultsForSearchBar:`,
   `_updateInsetsForTableView:`, `_UISearchBarLayout`, `_modalSourceViewController`) and swizzles
   `UIViewController` / `UINavigationController` globally. Each one is replaced by public API, by an override in
   our own subclass, or dropped with a reason and a test (table below). `beginIgnoringInteractionEvents` becomes
   `window.isUserInteractionEnabled = false`; the delegate window becomes the contents view controller's
   `view.window` (scene-based apps). Code only for iOS 8–12 is dropped.
5. **License**: every ported file starts with Tencent's MIT notice (as in the source) followed by "Ported to Swift for
   CYLSearchViewController, 2026"; the port is added to `docs/licenses.md` and the pod's third-party notices
   (`AGENTS.md` "Licenses in published packages").

## Public API (Swift; every member `@objc`, three-line `/** */` comment, `scripts/check-public-api-comments.sh`)

```swift
@objc(CYLSearchBar) open class CYLSearchBar: UISearchBar {
    /** Applies CYLSearchBarAppearance.default (the merged default style). Called from both initializers. */
    @objc open func applyDefaultAppearance()
    @objc public var appearanceStyle: CYLSearchBarAppearance            // font, colors, field / bar background images, icons
    @objc public var usedAsTableHeaderView: Bool                        // QMUI qmui_usedAsTableHeaderView (default false)
    @objc public var centersPlaceholder: Bool                           // qmui_centerPlaceholder
    @objc public var placeholderColor: UIColor?
    @objc public var textColor: UIColor?
    @objc public var font: UIFont?                                      // text and placeholder
    @objc public var textFieldMargins: UIEdgeInsets                      // on top of UIKit's own (10, 8, 10, 8)
    @objc public var textFieldMarginsProvider: ((CYLSearchBar, Bool) -> UIEdgeInsets)?   // wins over textFieldMargins
    @objc public var cancelButton: UIButton? { get }                     // nil until UIKit creates it
    @objc public var cancelButtonFont: UIFont?
    @objc public var cancelButtonMarginsProvider: ((CYLSearchBar, Bool) -> UIEdgeInsets)?
    @objc public var alwaysEnablesCancelButton: Bool                     // default true; only without a UISearchController
    @objc public var backgroundView: UIView? { get }
    @objc public var segmentedControl: UISegmentedControl? { get }
    @objc public var leadingAccessoryView: UIView?                       // QMUI left accessory
    @objc public var showsLeadingAccessoryView: Bool
    @objc public func setShowsLeadingAccessoryView(_ shows: Bool, animated: Bool)
    @objc public var leadingAccessoryViewMargins: UIEdgeInsets
    @objc public var trailingAccessoryView: UIView?                      // QMUI right accessory
    @objc public var showsTrailingAccessoryView: Bool
    @objc public func setShowsTrailingAccessoryView(_ shows: Bool, animated: Bool)
    @objc public var trailingAccessoryViewMargins: UIEdgeInsets
    @objc public weak var searchController: UISearchController? { get }  // qmui_searchController
    @objc public static func textFieldBackgroundImage(color: UIColor?) -> UIImage?
    @objc public static func backgroundImage(color: UIColor?, borderColor: UIColor?) -> UIImage?
}

@objc(CYLSearchControllerDelegate) public protocol CYLSearchControllerDelegate: UITableViewDataSource, UITableViewDelegate {
    /** Called on every text change, also with "" (first activation, all text deleted, the clear button), as UIKit does. */
    @objc(searchController:updateResultsForSearchString:)
    func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String)
    @objc optional func willPresentSearchController(_ searchController: CYLSearchController)
    @objc optional func didPresentSearchController(_ searchController: CYLSearchController)
    @objc optional func willDismissSearchController(_ searchController: CYLSearchController)
    @objc optional func didDismissSearchController(_ searchController: CYLSearchController)
    @objc optional func searchController(_ searchController: CYLSearchController, didLoadSearchResultsTableView tableView: UITableView)
    @objc optional func searchController(_ searchController: CYLSearchController, willShowEmptyView emptyView: UIView)
}

@objc(CYLSearchController) open class CYLSearchController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    @objc public init(contentsViewController: UIViewController, resultsViewController: UIViewController)   // designated
    @objc public convenience init(contentsViewController: UIViewController, resultsTableViewStyle: UITableView.Style)
    @objc public convenience init(contentsViewController: UIViewController)
    @objc public weak var searchResultsDelegate: CYLSearchControllerDelegate?
    @objc public var searchController: UISearchController { get }       // for navigationItem.searchController (#1229)
    @objc public var searchResultsController: UIViewController? { get }
    @objc public var searchBar: CYLSearchBar { get }
    @objc public var tableView: UITableView? { get }
    @objc public var launchView: UIView?
    @objc public var dimmingColor: UIColor?
    @objc public var isActive: Bool
    @objc public func setActive(_ active: Bool, animated: Bool)
    @objc public var hidesNavigationBarDuringPresentation: Bool          // default true
    @objc public var alwaysShowsSearchResultsController: Bool            // UISearchController.showsSearchResultsController (public, iOS 13)
    @objc public var forwardsAppearanceFromContentsViewController: Bool
    @objc public var supportsSwipeToDismissSearch: Bool                  // default false
    @objc public var swipeGestureRecognizer: UIScreenEdgePanGestureRecognizer? { get }
    @objc public var searchBarMaxY: CGFloat { get }                      // in searchController.view coordinates
    @objc public var prefersStatusBarHiddenProvider: (() -> Bool)?
    @objc public var preferredStatusBarStyleProvider: (() -> UIStatusBarStyle)?
    @objc public func showEmptyView(text: String?, detailText: String?, buttonTitle: String?, buttonAction: (() -> Void)?)
    @objc public func showEmptyView(scenario: CYLPlaceholderScenario)
    @objc public func hideEmptyView()
    @objc public var isEmptyViewShowing: Bool { get }
    /** Installs the bar as the table's header (sets usedAsTableHeaderView and the #1160 / #1473 handling). */
    @objc public func installSearchBar(asHeaderOf tableView: UITableView)
    /** Installs the system controller on a navigation item (#1229: the wrapper itself is not a UISearchController). */
    @objc public func install(in navigationItem: UINavigationItem)
}
```

## Edge cases: every QMUI comment, its Swift approach, its test

Tests are XCTest classes in `CYLSearchExampleTests`, one class per feature (`CYLSearchBarStyleTests`,
`CYLSearchControllerLifecycleTests`, `CYLSearchControllerLaunchViewTests`, `CYLSearchControllerSwipeTests`,
`CYLSearchIssueScenarioTests`); Swift files if the target builds Swift, otherwise Objective-C (the target's
existing file is `CYLSearchExampleTests.m`). A row is done when its test passes.

| # | QMUI behaviour / comment | Swift approach | Test |
| --- | --- | --- | --- |
| E1 | `definesPresentationContext = YES` on the contents VC: the bar does not stay on the navigation bar after pushing from the results; the results table's top inset fits the bar | same, in the designated initializer | push from results: the bar is not in the pushed screen's window hierarchy; results `contentInset.top` ≥ `searchBarMaxY` |
| E2 | #1541 (a): popped (`popToRootViewController`) while searching leaks; QMUI swizzles `didMoveToParentViewController:` globally | an invisible child view controller (`CYLSearchPresentationGuard`) added to the contents VC; when it disappears and the contents VC is no longer in any window's view-controller hierarchy, dismiss the system search controller without animation. No swizzling | `testPopToRootWhileSearchingReleasesContents`: weak reference to the contents VC and the wrapper is nil after the pop |
| E3 | #1541 (b): `window.rootViewController = x` while searching leaks; QMUI overrides `-[UINavigationController dealloc]` in a category | the same guard (its view leaves the window) | `testReplacingRootWhileSearchingReleasesContents` |
| E4 | iOS 15 changed `obscuresBackgroundDuringPresentation` to NO; QMUI sets YES | same | default is `true`; `false` with `launchView` or `alwaysShowsSearchResultsController` |
| E5 | `loadViewIfNeeded` of the system controller in `viewDidLoad`, else dealloc loads its view and warns | same | create and release a wrapper without showing it: no "load the view while deallocating" log, weak ref nil |
| E6 | `setActive(false, animated: false)` leaves the Cancel button shown (UIKit bug); QMUI hides it and restores `automaticallyShowsCancelButton` in the next `willPresent` | same (`hasSetShowsCancelButton` flag) | `testDeactivateWithoutAnimationHidesCancel` and the next activation shows Cancel again |
| E7 | #1473: results table `contentInsetAdjustmentBehavior = .never` and `keyboardDismissMode = .onDrag` | same in `CYLSearchResultsTableViewController` | push from results and back: results `contentInset` unchanged |
| E8 | the empty view is not shown while the text is empty (it would sit on the dimming view) | `showEmptyView` returns early when `searchBar.text` is empty | activate with empty text and call `showEmptyView`: nothing added |
| E9 | the empty view is laid out again in the results' `viewDidLayoutSubviews`; hidden on dismiss | same | rotate / resize while shown: frame fills the results view; dismissed: hidden |
| E10 | `updateResults` also receives "" | forward `searchBar.text ?? ""` | clear button → delegate gets "" |
| E11 | swipe: the gesture lives on the window, so it only begins when the touch is inside the search view | `gestureRecognizerShouldBegin` checks `view.isDescendant(of: searchController.view)` | a gesture starting outside does not begin |
| E12 | swipe: snapshot of the window behind, mask alpha follows the finger, >¼ width and rightward velocity dismisses, else springs back; interaction off during the animations | same; `window.isUserInteractionEnabled` instead of `beginIgnoringInteractionEvents` | simulate states: completes, cancels, interaction restored in both |
| E13 | swipe: after completing, the snapshot moves on top of the window to hide the dismissal flicker, removed 0.15 s later | same | snapshot removed and gesture removed from the window after dismissal |
| E14 | swipe: start a swipe, cancel it, tap ×: the snapshot behind must go too; cancel button dismissal after a cancelled swipe shows no snapshot | `resetSnapshot` on empty text, `cleanSnapshot` in `willDismiss` unless dismissed by swipe | both sequences leave no snapshot in the window |
| E15 | launchView fills everything below the bar; shown while the text is empty; re-laid out in `viewDidLayoutSubviews` (animated with the transaction's duration) | `CYLSystemSearchController` overrides `viewWillAppear` / `viewDidLayoutSubviews`; frame = results superview bounds minus `searchBarMaxY` | launch view frame below the bar on activation and after rotation; hidden when text is entered |
| E16 | `searchBarMaxY` reads the private `_UISearchBarContainerView` | `searchBar.convert(searchBar.bounds, to: searchController.view).maxY` | equals the bar's bottom in the search view |
| E17 | `setActive(true, animated: false)` lays out the system controller but not the results: QMUI calls `setNeedsLayout` on the results view | same in the subclass's `viewDidLayoutSubviews` | activate without animation: results laid out with the right `searchBarMaxY` |
| E18 | `alwaysShowSearchResultsController` via a private selector; mutually exclusive with launchView and obscuring | public `showsSearchResultsController = true`; clears `launchView`, `obscures… = false`; turning it off restores obscuring only if it was used | results visible on activation with empty text |
| E19 | `dimmingColor` via private `UIDimmingView` | our own dimming view in the search view (behind the results, above the contents), shown while the text is empty, tap = cancel; `obscures… = false` while set; ignored when `launchView` is set | color of the view under the bar equals `dimmingColor`; tap cancels |
| E20 | `forwardAppearanceMethodsFromPresentingController` swizzles every `UIViewController` | the guard child receives its parent's appearance calls and forwards `begin/endAppearanceTransition` to the active system controller | push from contents while searching (navigation bar hidden case): results controller gets `viewWillDisappear` / `viewDidAppear` on return |
| E21 | #680: `_UISearchControllerView didMoveToWindow` removes a transition view when a half-cancelled pop gesture is followed by a push | **check on iOS 26 / 27 first**: interactive pop cancelled then push; port only if the results flash during the push, with the test | `testCancelledPopThenPushShowsNoResults` (kept as a passing regression test if not reproducible, with the note) |
| E22 | status bar blocks are forwarded to the system controller and `setNeedsStatusBarAppearanceUpdate` in will present / dismiss | `prefersStatusBarHiddenProvider`, `preferredStatusBarStyleProvider` on both | the system controller's `preferredStatusBarStyle` follows the provider |
| E23 | `searchBar.frame` empty → `sizeToFit` | same | width > 0, height > 0 right after init |
| B1 | #830: the placeholder color is reset when the bar moves to a window | `didMoveToWindow` re-applies placeholder color / font (`searchTextField.attributedPlaceholder`) | color still set after adding to a window |
| B2 | centred placeholder (search icon + placeholder centred while not editing); widths can be negative mid-animation, use `bounds.size.width` | the public `UISearchBar.setPositionAdjustment(_:for: .search)`, computed in `layoutSubviews` from the placeholder width, reset to `.zero` while editing | icon centred at rest, leading while editing, no negative widths |
| B3 | text field margins on top of UIKit's (10, 8, 10, 8); a per-active-state block wins | adjust `searchTextField.frame` in `layoutSubviews` after `super` | frames for both states |
| B4 | cancel button font / margins; the button is created lazily | find the `UIButton` among the bar's descendants after `super.layoutSubviews` (no private keys); apply font and margins | font applied once the button exists |
| B5 | `alwaysEnablesCancelButton` (no search controller): UIKit disables Cancel when the keyboard goes down | re-enable in `layoutSubviews` / `resignFirstResponder` when `searchController == nil` | Cancel enabled after editing ends |
| B6 | leading / trailing accessory views: `sizeToFit`, vertical centre with the field, 8 pt gap, show / hide animated with a guard against fast toggling (state flag, not `isHidden`) | same | toggling twice quickly ends in the requested state; field shrinks by the accessory width + gap |
| B7 | iOS 13: Cancel jitters when leaving search as a table header with `showsCancelButton` already on | **check on iOS 26 / 27**; port only if it reproduces | frame sequence of Cancel while deactivating |
| B8 | #233: as a table header on iOS 11 the bar's y is too high while searching; iOS 13 iPad negative y | **check**; if it does not reproduce on iOS 15+ drop, with the test kept | `testTableHeaderBarFrameWhileSearching` |
| B9 | #950: 1 px gap above the bar as a table header | **check**; port the background extension only if the gap is measured | pixel row above the bar has the bar's color |
| B10 | #1207: as a header with short content the bar can become invisible | covered with #1160 (I4) | — |
| B11 | iOS 14 beta font change breaks the field height; active height 56 forced | drop (beta-only / iOS 11-era); test that changing `font` keeps the field height | field height unchanged after font change |
| B12 | index bar (A–Z) moves a header search bar; private `_updateInsetsForTableView:` | drop the switch (private); document | — |
| B13 | `qmui_styledAsQMUISearchBar`: font, colors, search / clear icons, tint, field background image and border, bar background image with a bottom border (background image instead of `barTintColor` so the border colour can change) | `applyDefaultAppearance()` from `CYLSearchBarAppearance.default`; merged legacy `CYLSearchBar` defaults (below) | every appearance value lands on the bar |

## The owner's issues (QMUI_iOS-fixed `docs/issue-tracker.md`)

| # | Issue | What the port does | Example scenario | Test |
| --- | --- | --- | --- | --- |
| I1 | [#1319](https://github.com/Tencent/QMUI_iOS/issues/1319) the bar jumps on activation (a plain `UISearchController` too) | E1 `definesPresentationContext`; the examples set `edgesForExtendedLayout` / `extendedLayoutIncludesOpaqueBars` consistently and document it | the main replica screen | bar's frame in the window: no vertical jump > 0.5 pt between the last frame before and the first frame after activation when `hidesNavigationBarDuringPresentation = false` |
| I2 | [#1251](https://github.com/Tencent/QMUI_iOS/issues/1251) bar added as a plain subview is misplaced when the navigation bar hides | doc + example: plain subview with `hidesNavigationBarDuringPresentation = false` (UIKit only animates a header or a navigation-item bar) | "Bar in a view" screen | bar stays inside the safe area and covers no view while searching (`testSearchBarsCoverNoView`) |
| I3 | [#1229](https://github.com/Tencent/QMUI_iOS/issues/1229) assigning the wrapper to `navigationItem.searchController` crashes | `install(in:)` assigns `searchController` (the system one), keeps `usedAsTableHeaderView = false`; the wrapper is retained by the contents VC (associated or a stored property in the example) | "Navigation item" screen | install, activate, type, cancel: no crash, delegate gets the text |
| I4 | [#1160](https://github.com/Tencent/QMUI_iOS/issues/1160) the header bar does not snap under the navigation bar when content is short (UIKit bug; QMUI's answer: no estimated heights, avoid the four header/footer methods) | `installSearchBar(asHeaderOf:)` sets `estimatedRowHeight = 0` (and section header/footer estimates) and keeps enough bottom inset that the header can scroll out of sight; on end of dragging it snaps fully shown / hidden | "Short list" screen with 3 rows (rebuilds `issues1160-TestSearchBar`, which is empty) | scroll half the header away and release: ends fully hidden or fully shown |
| I5 | [#1313](https://github.com/Tencent/QMUI_iOS/issues/1313) bar in a collection view header jitters after cancel | doc + example: the bar lives in a container we own above the collection view (or `install(in:)`), never in a reusable view | "Collection view" screen | after cancel the bar's frame is the same as before activation |

## Merging our code into the new classes

| Our code | Goes into | How |
| --- | --- | --- |
| legacy `CYLSearchBar.m` defaults: field background RGB(187,186,193), tint RGB(0,104,248), placeholder "搜索", no bar background, Cancel title "取消" | `CYLSearchBarAppearance.default` | as defaults; placeholder and Cancel title localized through the core's string table (as `CYLSearchBarView` does) |
| `CYLSearchResources` search history (newest first, no duplicates, saved) | the example's launch view (recent searches) and an optional `CYLSearchController.historyStore` hook | reuse, no copy |
| `CYLSearchView` empty results placeholder (`CYLTableViewPlaceHolder`, `CYLPlaceholderScenario`) | `CYLSearchController.showEmptyView` | same placeholder component and scenarios |
| `CYLTagListView` (CollectionViewClassifyMenu, already a dependency) | the replica of `QDRecentSearchView` (QMUI's `QMUIFloatLayoutView` of ghost buttons) | tags instead of buttons |
| the search-bar placement rule (`AGENTS.md`, `testSearchBarsCoverNoView`) | every new screen | add each new bar to the test |

## Example (`CYLSearchExample`)

New rows in `CYLSearchDemoMenuViewController` (localized through `cylDemoText`):

1. **Search controller** — replica of `QDSearchViewController`: table of the 10 keywords (Helps, Maintain, Liver,
   Health, Function, Supports, Healthy, Fat, Metabolism, Nuturally), `CYLSearchController(contentsViewController:)`,
   `supportsSwipeToDismissSearch = true`, launch view = recent searches (title "Recent searches" with a bottom border,
   26 pt padding plus safe area, 20 pt gap, tags 69 × 29 minimum, 10 pt spacing, the 8 suggestions), bar as the table
   header (`installSearchBar(asHeaderOf:)`), results = matching keywords × 20 rows with the match highlighted in the
   tint color, empty view "No matching results" when nothing matches.
2. **Search bar styles** — replica of `QDSearchBarViewController` (`CYLSearchTableViewController` with
   `showsSearchBar = true`): sections Placeholder (switch "Center placeholder"; row "Change placeholder" → "A very very
   very long placeholder"), Layout (row "Adjust the field at rest" → margins (0, 32, 0, 32) at rest, 0 when active;
   row "Adjust Cancel while searching" → (0, −16, 0, 0) when active, and activates search), AccessoryView (switch
   "Animated"; rows "Show / Hide Cancel", "Show / Hide leading accessory", "Show / Hide trailing accessory"; accessories
   are 30 × 30 stroked rounded squares, margins 8, hidden at first).
3. **Issue scenarios**: "Navigation item" (I3), "Bar in a view" (I2), "Short list" (I4), "Collection view" (I5).

Every screen: English and Chinese strings, Dynamic Type, dark mode, the bar never covers a view.

## Phases (each by a Sonnet agent; reviewed, tested and pushed here before the next)

1. `CYLSearchBar` + `CYLSearchBarAppearance` (rows B1–B13), Objective-C visibility test, the "Search bar styles" screen.
2. `CYLSearchController` + `CYLSearchResultsTableViewController` + guard (rows E1–E23), the "Search controller" screen.
3. `CYLSearchTableViewController`, the issue scenarios I1–I5 and their screens.
4. Merge table above, docs (`docs/search-api-comparison.md` / `docs/search-bar-view.md` cross-links), licenses, final score.

## Acceptance (100; pass 60)

| Criterion | Points |
| --- | --- |
| Classes and API as above, `@objc` names, Objective-C visibility test, public API comments check passes | 15 |
| Edge-case rows E1–E23 and B1–B13: each implemented (or dropped with the written reason) and its test passing | 30 |
| Issue rows I1–I5: scenario screen and passing test each | 15 |
| Example: both QMUI demo screens replicated, all new screens in `testSearchBarsCoverNoView` | 15 |
| Merge table done; `CYLSearchBarView` / `CYLSearchView` / #1317 page unchanged and their tests still pass | 10 |
| Whole iOS suite green on a clean build; labeled screenshots of the two replica screens in `docs/assets/` | 10 |
| License notices, this document's status and score updated | 5 |
