> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# iOS example: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `CYLSearchExample/CYLContactListViewController.swift` | 95 |
| `CYLSearchExample/CYLContactRemarkViewController.swift` | 236 |
| `CYLSearchExample/CYLContactTagEditorViewController.swift` | 909 |
| `CYLSearchExample/CYLContactTagServer.swift` | 125 |
| `CYLSearchExample/CYLContactTagStore.swift` | 400 |
| `CYLSearchExample/CYLKenBurnsView.swift` | 73 |
| `CYLSearchExample/CYLLapismSearchViewController.swift` | 105 |
| `CYLSearchExample/CYLMaterialSearchMenuViewController.swift` | 317 |
| `CYLSearchExample/CYLMultiSearchDemoViewController.swift` | 74 |
| `CYLSearchExample/CYLOriginalSearchDemoViewController.swift` | 192 |
| `CYLSearchExample/CYLRevealSearchViewController.swift` | 54 |
| `CYLSearchExample/CYLSearchBarDemoViewController.swift` | 80 |
| `CYLSearchExample/CYLSearchBarInViewDemoViewController.swift` | 95 |
| `CYLSearchExample/CYLSearchBarStylesViewController.swift` | 159 |
| `CYLSearchExample/CYLSearchCollectionViewDemoViewController.swift` | 159 |
| `CYLSearchExample/CYLSearchControllerDemoViewController.swift` | 98 |
| `CYLSearchExample/CYLSearchDemoMenuViewController.swift` | 492 |
| `CYLSearchExample/CYLSearchDiscoverData.swift` | 121 |
| `CYLSearchExample/CYLSearchDiscoverViewController.swift` | 642 |
| `CYLSearchExample/CYLSearchExampleAppDelegate.swift` | 140 |
| `CYLSearchExample/CYLSearchExampleSceneDelegate.swift` | 27 |
| `CYLSearchExample/CYLSearchExampleViewController.swift` | 240 |
| `CYLSearchExample/CYLSearchNavigationItemDemoViewController.swift` | 74 |
| `CYLSearchExample/CYLSearchPortsViewController.swift` | 83 |
| `CYLSearchExample/CYLSearchShortListDemoViewController.swift` | 55 |
| `CYLSearchExample/CYLSuggestionDemoPages.swift` | 31 |
| `CYLSearchExample/CYLSVGADemoTagButton.swift` | 50 |
| `CYLSearchExample/CYLSVGASwiftUIDemo.swift` | 56 |
| `CYLSearchExample/CYLTabBarConfiguration.json` | 31 |
| `CYLSearchExample/CYLYechaoaSearchViewController.swift` | 68 |

## `CYLSearchExample/CYLContactListViewController.swift`

CYLContactListViewController.swift CYLSearchExample The contacts that have a tag: the page a tap on a tag opens in the contact tags demo's "Manage" mode. A tag without contacts (a new one, or one nobody has) shows CYLTableViewPlaceHolder's placeholder in the table (cyl_reloadData).

- L15 `final class CYLContactListViewController: UITableViewController, CYLTableViewPlaceHolderDelegate` — The contacts that have `tag`, in a table; CYLTableViewPlaceHolder's placeholder when there are none.

## `CYLSearchExample/CYLContactRemarkViewController.swift`

CYLContactRemarkViewController.swift CYLSearchExample "Edit Remarks": the screen the tag editor is presented from, as in a chat app's contact remarks, ported from CollectionViewClassifyMenu's CYLTagEditorExample (CYLRemarkViewController). Its "Tags" row shows the chosen tags (a display-only CYLTagListView); tapping it opens "Edit Tags" (CYLContactTagEditorViewController) as a sheet. Without tags, 

- L19 `final class CYLContactRemarkViewController: UIViewController` — "Edit Remarks": a remark name and the contact's tags; the tags open "Edit Tags".
- L212 `extension CYLContactRemarkViewController: CYLMenuDataSource, CYLMenuDelegate`

## `CYLSearchExample/CYLContactTagEditorViewController.swift`

CYLContactTagEditorViewController.swift CYLSearchExample "Edit Tags": a sheet for choosing a contact's tags, as in a chat app, ported from CollectionViewClassifyMenu's CYLTagEditorExample (CYLTagEditorViewController). The search field is this library's CYLSearchBarView; the tags are CollectionViewClassifyMenu's CYLTagListView. - "Recent" (with a trash button) and "My Tags" (with "Manage"; folded t

- L38 `final class CYLContactTagEditorViewController: UIViewController` — "Edit Tags": chooses, creates and deletes a contact's tags, searched with `CYLSearchBarView`.
- L728 `extension CYLContactTagEditorViewController: CYLSearchBarViewDelegate`
- L749 `extension CYLContactTagEditorViewController: CYLMenuDataSource`
- L861 `extension CYLContactTagEditorViewController: CYLMenuDelegate`

## `CYLSearchExample/CYLContactTagServer.swift`

CYLContactTagServer.swift CYLSearchExample The contact tags demo's simulated server (CollectionViewClassifyMenu's CYLTagListRemoteSource). The local cache, A, is CYLTagListStore's database (CYLContactTagStore.cache); the server's data, B, is a second CYLTagListStore, a JSON file in the sandbox, that stands for the server shared by the user's devices. Every request waits `latency` (5 s) and shows C

- L22 `final class CYLContactTagServer: NSObject, CYLTagListRemoteSource` — The simulated server of the contact tags demo: cache B in the sandbox, reached with a delay and a HUD.

## `CYLSearchExample/CYLContactTagStore.swift`

CYLContactTagStore.swift CYLSearchExample The contact tags demo, ported from CollectionViewClassifyMenu's CYLTagEditorExample (CYLTagStore): the user's tags, in the user's order, the recently used ones and the contacts. The demo data is read from CYLContactTags.bundle/ <language>.lproj/contact-tags.json (CYLContactTagData); every change (a reorder in editing mode, a deleted or added tag, a cleared

- L19 `struct CYLContactTag: Codable, Equatable` — A tag: its id is its primary key (a reorder or a rename keeps it, and contacts are bound to it); its title is what the lists show.
- L36 `final class CYLContactTagStore` — The user's tags (like a chat app's contact tags), keyed by id: every tag in the user's order, and the recently used ones. New tags are added here; the editor only reads and asks it to change. Changes are saved to `cache` (cache A) as CollectionViewClassifyMenu
- L283 `struct CYLContactTagData: Codable, Equatable` — The contents of contact-tags.json: the demo tags (id and title), the ids of the recently used ones and of the tags the remark screen starts with, and the contacts.
- L338 `enum CYLContactTagsLocalization` — The example-level bundle of the contact tags demo (`CYLContactTags.bundle`, one `.lproj` per language).
- L368 `final class CYLContactTagsDemo: NSObject` — The entry of the contact tags demo for the Objective-C Examples menu (row 6): its title and its first screen.

## `CYLSearchExample/CYLKenBurnsView.swift`

CYLKenBurnsView.swift CYLSearchExample The Ken Burns background of the original demo (the Swift replacement of the Objective-C CYLKenBurnsView).

- L15 `final class CYLKenBurnsView: UIView` — An image that slowly zooms and drifts inside its bounds, forever: the "Ken Burns" effect behind the original demo's search field. The animation restarts whenever the view is shown (Core Animation drops it when the app goes to the background) and is off while R

## `CYLSearchExample/CYLLapismSearchViewController.swift`

Port of lapism/search's README usage: a `MaterialSearchBar` (magnifier navigation icon, hint, taps open the search) over a list, and a `MaterialSearchView` (arrow navigation icon, a filtered list added with `addView`, query and focus listeners).

- L10 `final class CYLLapismSearchViewController: UIViewController` — Port of lapism/search's README usage: a `MaterialSearchBar` (magnifier navigation icon, hint, taps open the search) over a list, and a `MaterialSearchView` (arrow navigation icon, a filtered list added with `addView`, query and focus listeners).
- L67 `extension CYLLapismSearchViewController: CYLSearchBarViewDelegate`
- L77 `extension CYLLapismSearchViewController: CYLSearchViewDelegate`
- L93 `extension CYLLapismSearchViewController: UITableViewDataSource`

## `CYLSearchExample/CYLMaterialSearchMenuViewController.swift`

Port of MiguelCatalan/MaterialSearchView's sample `MainActivity`: one button per sample screen.

- L10 `final class CYLMaterialSearchMenuViewController: UITableViewController` — Port of MiguelCatalan/MaterialSearchView's sample `MainActivity`: one button per sample screen.
- L55 `enum CYLMaterialSearchSample: CaseIterable` — The sample screens: `DefaultActivity`, `ColoredActivity`, `VoiceActivity`, `StickyActivity`, `TabActivity` and `InputTypeActivity`.
- L78 `final class CYLMaterialSearchSampleViewController: UIViewController` — One sample screen: a toolbar with a search item that opens a `CYLSearchView` with the sample's suggestions; a submitted query shows "Query: …" in a snackbar and closes the search, as `onQueryTextSubmit` returning false does.
- L208 `extension CYLMaterialSearchSampleViewController`
- L229 `extension CYLMaterialSearchSampleViewController: CYLSearchViewDelegate`
- L260 `final class CYLSpeechRecognizer` — Turns one spoken phrase into text with the Speech framework (the sample's `RecognizerIntent`).

## `CYLSearchExample/CYLMultiSearchDemoViewController.swift`

Port of iammert/MultiSearchView's sample `MainActivity`: a `CYLSearchBarView` in `CYLSearchBarModeMultiple`, styled like the README's `SearchTextStyle` (hint "Search", 18 pt text, at most 15 characters, sentence capitalization, the Search key, gray hint, black text), 16 pt from the top, with every event logged (the sample's `Log.v`).

- L11 `final class CYLMultiSearchDemoViewController: UIViewController` — Port of iammert/MultiSearchView's sample `MainActivity`: a `CYLSearchBarView` in `CYLSearchBarModeMultiple`, styled like the README's `SearchTextStyle` (hint "Search", 18 pt text, at most 15 characters, sentence capitalization, the Search key, gray hint, black
- L58 `extension CYLMultiSearchDemoViewController: CYLSearchBarViewDelegate`

## `CYLSearchExample/CYLOriginalSearchDemoViewController.swift`

CYLOriginalSearchDemoViewController.swift CYLSearchExample The original CYLSearchViewController demo (the README's screenshot) rebuilt on the Swift core's `CYLSearchView`, replacing the Objective-C `CYLSearchController`, `CYLSearchResultViewController` and `CYLKenBurnsView`.

- L41 `final class CYLOriginalSearchDemoViewController: UIViewController, CYLSearchViewDelegate, CYLSearchViewDataSource,` — The original demo: a blue bar titled with the author's name, a search field over a Ken Burns sky; a tap on the field opens `CYLSearchView` with the search history (newest first) and a "clear history" button below it, the sky still showing under the list, and C

## `CYLSearchExample/CYLRevealSearchViewController.swift`

Port of android-cjj/MaterialSearchView's sample: on the primary color, a round search button opens a light search card with a one-second circular reveal; the magnifier in the card closes it again.

- L9 `final class CYLRevealSearchViewController: UIViewController` — Port of android-cjj/MaterialSearchView's sample: on the primary color, a round search button opens a light search card with a one-second circular reveal; the magnifier in the card closes it again.

## `CYLSearchExample/CYLSearchBarDemoViewController.swift`

CYLSearchBarDemoViewController.swift CYLSearchExample Translated from Objective-C (docs/swift-migration.md).

- L16 `public final class CYLSearchBarDemoViewController: UIViewController, CYLSearchBarViewDelegate` — Shows a `CYLSearchBarView` with a camera accessory and Cancel, and prints the text and the Search key below it. Used by the "Search bar" demo row and as the plus page of the tab bar.
- L21 `public override func viewDidLoad()`
- L67 `public func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String)`
- L71 `public func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView)`
- L76 `public func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView)`

## `CYLSearchExample/CYLSearchBarInViewDemoViewController.swift`

CYLSearchBarInViewDemoViewController.swift CYLSearchExample The "Bar in a view" screen (QMUI issue #1251, row I2): the search bar is a plain subview of the view controller's view, not a table header or a navigation item. UIKit animates only those two places, so with a plain subview the controller must not hide the navigation bar (the core never hides it): the bar then stays where it is, inside the

- L19 `public final class CYLSearchBarInViewDemoViewController: UIViewController, CYLSearchControllerDelegate` — A search bar above a table, both subviews of the view; the bar is laid out against the safe area and the table starts at the bar's bottom edge, so the bar covers no view.
- L26 `public override func viewDidLoad()`
- L62 `public override func viewDidLayoutSubviews()`
- L69 `public func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String)`
- L77 `extension CYLSearchBarInViewDemoViewController`
- L79 `public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int`
- L83 `public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`
- L92 `public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`

## `CYLSearchExample/CYLSearchBarStylesViewController.swift`

CYLSearchBarStylesViewController.swift CYLSearchExample The "Search bar styles" screen: a replica of QMUI's QDSearchBarViewController (QMUIDemo_iOS). Sections Placeholder, Layout and AccessoryView drive one `CYLSearchBar` that is the table header.

- L18 `public final class CYLSearchBarStylesViewController: CYLSearchTableViewController` — Shows every style knob of `CYLSearchBar` the way QMUI's demo does: a centered placeholder, a changed placeholder, margins of the text field at rest and of the Cancel button while searching, and leading and trailing accessory views that are shown and hidden wit
- L34 `public override func viewDidLoad()`
- L42 `public override func setUpSearchBar()`
- L70 `public override func numberOfSections(in tableView: UITableView) -> Int`
- L74 `public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int`
- L78 `public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?`
- L82 `public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`
- L122 `public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`

## `CYLSearchExample/CYLSearchCollectionViewDemoViewController.swift`

CYLSearchCollectionViewDemoViewController.swift CYLSearchExample The "Collection view" screen (QMUI issue #1313, row I5): the search bar sits in a container view that this screen owns, above the collection view. After Cancel, the system search controller puts the bar back into its original superview; a bar inside a reusable collection view header was re-laid out at that moment and jittered. A cont

- L18 `final class CYLSearchBarContainerView: UIView` — Holds the search bar and lays it out to fill the container each time the container is laid out, so the frame is right as soon as UIKit hands the bar back after Cancel.
- L67 `public final class CYLSearchCollectionViewDemoViewController: UIViewController, CYLSearchControllerDelegate,` — A grid of items below a search bar in a container view (a plain view above the collection view, never a reusable view).
- L80 `public override func viewDidLoad()`
- L121 `public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int`
- L125 `public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell`
- L131 `public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,`
- L139 `public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int`
- L143 `public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`
- L153 `public func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String)`

## `CYLSearchExample/CYLSearchControllerDemoViewController.swift`

CYLSearchControllerDemoViewController.swift CYLSearchExample The "Search controller" screen: a replica of QMUI's QDSearchViewController (QMUIDemo_iOS). A table of ten keywords with a CYLSearchBar as its header; the search shows the core's launch view (recent searches as tags) while the text is empty, the matching keywords (twenty rows each) with the match in the tint color, an empty view when noth

- L20 `public final class CYLSearchControllerDemoViewController: UITableViewController, CYLSearchControllerDelegate` — Ten keywords in a table whose header is a search bar. `CYLSearchController` shows the recent searches while the text is empty, then the matching keywords, and leaves the search when the person swipes from the left edge.
- L35 `public override func viewDidLoad()`
- L54 `public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int`
- L58 `public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`
- L71 `public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`
- L94 `public func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String)`

## `CYLSearchExample/CYLSearchDemoMenuViewController.swift`

CYLSearchDemoMenuViewController.swift CYLSearchExample The examples menu, its placeholder gallery and the SVGA demo header (translated from Objective-C, docs/swift-migration.md).

- L92 `struct CYLDemoTagItem` — One tag of a demo tag list: the cell's main title and icon; `subtitle` is what a long press shows in the tag list's callout (`menuSubtitleForItem`).
- L102 `struct CYLDemoTagSection` — A titled section of a demo tag list: a table view section's header and rows.
- L111 `final class CYLDemoGradientView: UIView` — The page behind a demo glass tag list (docs/instructions/example-demos.md, rule 7): a diagonal gradient with light and dark variants, so the Liquid Glass board and tags have something to blur and refract.
- L150 `extension UIViewController`
- L169 `class CYLDemoTagListViewController: UIViewController, CYLMenuDataSource, CYLMenuDelegate` — The example's grouped demo lists (docs/instructions/example-demos.md): a sectioned CollectionViewClassifyMenu tag list in place of a grouped table view. Every tag is a Liquid Glass tag (the core's one `backgroundStyle` parameter, set through `CYLSearchTagListS
- L255 `final class CYLSearchPlaceholderGalleryViewController: CYLDemoTagListViewController` — Every `CYLPlaceholderStyle` with four messages, and three custom placeholders, as demo tag lists (a section per style). The styles, images and texts are CYLTableViewPlaceHolder's `CYLPlaceholderView` (the core's former CYLSearchPlaceholderView was a duplicate 
- L325 `public final class CYLSearchDemoMenuViewController: UITableViewController` — The examples menu: the SVGA demo above a list of the example screens.
- L332 `public override func viewDidLoad()`
- L339 `public override func viewDidAppear(_ animated: Bool)`
- L347 `public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int`
- L358 `public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`
- L384 `public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`
- L435 `final class CYLSearchSecondLevelViewController: CYLDemoTagListViewController` — The second-level search page behind a first-level search bar: the same look, the keyboard up, "Recently searched" and "Popular" as glass tag lists. Its bar brings the back button in with the push and focuses itself (`focusesOnAppear`); the page never animates 
- L473 `extension UIViewController`

## `CYLSearchExample/CYLSearchDiscoverData.swift`

CYLSearchDiscoverData.swift CYLSearchExample Copied from CollectionViewClassifyMenu's CYLMenuExample (commit e550a01). The data of the search history and discover demo, from CYLSearchDiscover.bundle/<language>.lproj/search-discover.json (one file per language, the same topics in the same order): recent searches, and a pool of pages of discover topics; the refresh icon shows the next page, cyclical

- L18 `struct CYLDiscoverTopic: Codable, Equatable` — One discover topic: a title (in the file's language), and an optional icon after it: "hot" for the localized hot icon (discover-hot.png of the same .lproj: 热, 熱, HOT).
- L26 `struct CYLSearchDiscoverData: Codable` — The demo's data as stored in the JSON file.
- L98 `enum CYLSearchDiscoverLocalization` — The example-level bundle of the discover demo (`CYLSearchDiscover.bundle`, one `.lproj` per language).

## `CYLSearchExample/CYLSearchDiscoverViewController.swift`

CYLSearchDiscoverViewController.swift CYLSearchExample Copied from CollectionViewClassifyMenu's CYLMenuExample (commit e550a01, the pinned sub-dependency; docs/tag-view-suggestions.md), strings moved to CYLSearchDiscover.bundle. Search history and discover: a search app's search page. "最近搜索" is a CYLTagListView whose fold control is a tag cell (CYLMenuFoldControlPosition.tail: the chevron after th

- L22 `final class CYLRecentSearchSource: NSObject, CYLMenuDataSource` — The recent searches, one section.
- L57 `final class CYLDiscoverSource: NSObject, CYLMenuDataSource` — The discover topics, one section with the core's More button.
- L99 `final class CYLSearchDiscoverViewController: UIViewController`
- L522 `extension CYLSearchDiscoverViewController: CYLMenuDelegate`
- L542 `extension CYLSearchDiscoverViewController: CYLSearchBarViewDelegate`
- L553 `final class CYLAskBackgroundView: UIView` — The light gray area behind the mic button, its top edge a wide arc.
- L593 `final class CYLSearchDiscoverEntryViewController: UITableViewController` — The entry of the "Discover" tab: a one-row page that opens the Discover page, so the Discover page is always a second-level page and its navigation bar always has a back button on the left (owner's rule for every example). The first time this page appears it o

## `CYLSearchExample/CYLSearchExampleAppDelegate.swift`

CYLSearchExampleAppDelegate.swift CYLSearchExample The example's app delegate and the tab bar it builds (translated from Objective-C, docs/swift-migration.md).

- L29 `public final class CYLSearchExampleAppDelegate: UIResponder, UIApplicationDelegate` — Starts the app; `CYLSearchExampleSceneDelegate` creates the window (Info.plist, UIApplicationSceneManifest), since apps built with the iOS 27 SDK must adopt the scene life cycle.
- L31 `public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool`
- L39 `@objc public static func rootViewController() -> UIViewController` — The tab bar built from CYLTabBarConfiguration.json (search, examples and the plus page), or the examples menu when the file cannot be read.

## `CYLSearchExample/CYLSearchExampleSceneDelegate.swift`

CYLSearchExampleSceneDelegate.swift CYLSearchExample Creates the example's window in its scene (translated from Objective-C, docs/swift-migration.md).

- L16 `final class CYLSearchExampleSceneDelegate: UIResponder, UIWindowSceneDelegate` — Creates the example's window in its scene, with `CYLSearchExampleAppDelegate.rootViewController()` as the root. Apps built with the iOS 27 SDK must adopt the scene life cycle; without it the app does not launch. The Objective-C name is the one Info.plist's `UI

## `CYLSearchExample/CYLSearchExampleViewController.swift`

Reloads the example's data for pull to refresh.

- L9 `public protocol CYLSearchExampleRefreshing: NSObjectProtocol` — Reloads the example's data for pull to refresh.
- L21 `public final class CYLSearchExampleDataSource: NSObject, CYLSearchViewDataSource, CYLSearchExampleRefreshing` — Forty localized sample results, filtered by the query; also the example's refresh provider.
- L30 `public func searchView(_ searchView: CYLSearchView, resultsForQuery query: String) -> [Any]` — All items for an empty query, else the items that contain the query (case-insensitive).
- L37 `public func searchView(_ searchView: CYLSearchView, configureResultCell cell: UITableViewCell, withResult result: Any)` — Shows the result's text.
- L44 `public func reload(completion: @escaping (Error?) -> Void)` — Finishes after 0.4 seconds without an error.
- L57 `public final class CYLSearchExampleViewController: UITableViewController, CYLSearchBarViewDelegate, CYLTableViewPlaceHolderDelegate` — The results page: the core's one navigation-bar search field (`CYLSearchBarView`, `applyNavigationFieldStyle()`) over a list with pull to refresh and an empty state from CYLTableViewPlaceHolder. The refresh goes through `CYLSearchView`'s class methods (`+setRe
- L67 `@objc public let searchBar = CYLSearchBarView()` — The search field in the navigation bar: the core's `CYLSearchBarView` with the shared navigation field look.
- L73 `@objc public let overlaySearchView = CYLSearchView(frame: .zero)` — The search page opened by "Overlay", with `resultsDataSource` set to the page's data source. The page's own list asks the same data source with this view as the sender.
- L78 `@objc public private(set) var searchResults: [Any] = []` — The results of the current query.
- L84 `public init(searchDataSource: CYLSearchViewDataSource, refreshProvider: CYLSearchExampleRefreshing)` — The search data source and the refresh provider (the same `CYLSearchExampleDataSource` in the app).
- L94 `public required init?(coder: NSCoder)` — Not available: use `init(searchDataSource:refreshProvider:)`.
- L98 `override public func viewDidLoad()`
- L138 `override public func viewWillAppear(_ animated: Bool)` — The field goes into the navigation bar once the page sits in a navigation controller (at load, or when it first appears).
- L187 `@objc public func reloadResults()` — Asks the data source again for the search bar's text and reloads the list (with its empty state).
- L196 `public func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String)` — Requeries the results when the search text changes.
- L208 `override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int`
- L212 `override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`
- L219 `override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`
- L228 `public func makePlaceHolderView() -> UIView` — The empty state: CYLTableViewPlaceHolder's `CYLPlaceholderView`, "No matching results".
- L237 `public func enableScrollWhenPlaceHolderViewShowing() -> Bool` — The list keeps scrolling (and refreshing) while the empty state shows.

## `CYLSearchExample/CYLSearchNavigationItemDemoViewController.swift`

CYLSearchNavigationItemDemoViewController.swift CYLSearchExample The "Navigation item" screen (QMUI issue #1229, docs/qmui-search-controller.md, row I3): a CYLSearchController is installed on the navigation item. QMUI's wrapper is not the system search controller, so assigning it to `navigationItem.searchController` crashed; `install(in:)` assigns the system controller inside and keeps the wrapper

- L19 `public final class CYLSearchNavigationItemDemoViewController: UITableViewController, CYLSearchControllerDelegate` — A list of ten keywords with the search in the navigation bar (`install(in:)`). The screen keeps the wrapper only weakly: the contents view controller retains it, which is what #1229 needed.
- L27 `public override func viewDidLoad()`
- L48 `public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int`
- L52 `public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`
- L61 `public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`
- L67 `public func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String)`

## `CYLSearchExample/CYLSearchPortsViewController.swift`

A localized text of the example (the `demo.*` keys of CYLSearchViewController.bundle).

- L14 `enum CYLSnackbar` — A short message at the bottom of a view, like Android's `Snackbar.make(...).show()`.
- L57 `final class CYLSearchPortsViewController: CYLDemoTagListViewController` — The Swift ports of the examples of five search libraries (docs/search-api-comparison.md), as a demo tag list (docs/instructions/example-demos.md): one tag per port with its name and icon, a tap opens it, a long press shows its subtitle. Each port only passes d

## `CYLSearchExample/CYLSearchShortListDemoViewController.swift`

CYLSearchShortListDemoViewController.swift CYLSearchExample The "Short list" screen (QMUI issue #1160 and #1207, rows I4 and B10): three rows under a header search bar. UIKit let the header stay half visible after a drag, and with so few rows it could not be scrolled out of sight at all. The core's `installSearchBar(asHeaderOf:)` turns the estimated heights off, adds the bottom inset the header ne

- L19 `public final class CYLSearchShortListDemoViewController: CYLSearchTableViewController` — Three rows below a search bar that is the table header (`CYLSearchTableViewController` with `showsSearchBar`).
- L24 `public override func viewDidLoad()`
- L33 `public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int`
- L37 `public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`
- L45 `public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`
- L51 `public override func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String)`

## `CYLSearchExample/CYLSuggestionDemoPages.swift`

The pages of the suggestion style demos (docs/tag-view-suggestions.md), for the Objective-C app delegate, which registers them for the "tagStyle" and "discover" tabs of CYLTabBarConfiguration.json.

- L9 `public final class CYLSuggestionDemoPages: NSObject` — The pages of the suggestion style demos (docs/tag-view-suggestions.md), for the Objective-C app delegate, which registers them for the "tagStyle" and "discover" tabs of CYLTabBarConfiguration.json.
- L15 `@objc public static func tagStyleViewController() -> UIViewController` — The "Tag style" tab: MaterialSearchView's six samples, the same suggestions and parameters as the list-style ports, shown as tags (`CYLSearchView.suggestionStyle = .tags`).
- L27 `@objc public static func discoverViewController() -> UIViewController` — The "Discover" tab: the search history and discover page copied from CollectionViewClassifyMenu (recent searches and discover topics as CYLTagListView tags).

## `CYLSearchExample/CYLSVGADemoTagButton.swift`

CYLTagButton's base class, CYLAnimatedItemView, is in the CYLAnimatedItem module: imported here so that the generated CYLSearchExample-Swift.h can declare this class, whose method returns a CYLTagButton (CI on bb261ce: "use of undeclared identifier 'CYLSVGADemoTagButton'" in CYLSearchDemoMenuViewController.m).

- L15 `final class CYLSVGADemoTagButton: NSObject` — The animated icon and title of the SVGA demo above the Examples list: a `CYLTagButton` (CollectionViewClassifyMenu, the one icon + title + animated icon component) whose `animationURL` is an `.svga` file, drawn by CYLTabBarController's animation engine (the `C

## `CYLSearchExample/CYLSVGASwiftUIDemo.swift`

The SwiftUI host of the SVGA tab bar (docs/CYLTabBarController-Integration.md, SVGA TODO, the SwiftUI row), as CYLTabBarController's Example-SwiftUI-Rive hosts its tab bar: a `CYLTabBarController` made from `CYLTabBarConfiguration_svga_swiftui.json` (SVGA icons, `CYLTabBarSVGAFilePath`) inside a SwiftUI view through `UIViewControllerRepresentable`; the pages come from the same page registry as the

- L9 `struct CYLSVGATabBarRepresentable: UIViewControllerRepresentable` — The SwiftUI host of the SVGA tab bar (docs/CYLTabBarController-Integration.md, SVGA TODO, the SwiftUI row), as CYLTabBarController's Example-SwiftUI-Rive hosts its tab bar: a `CYLTabBarController` made from `CYLTabBarConfiguration_svga_swiftui.json` (SVGA icon
- L18 `struct CYLSVGASwiftUIDemoView: View` — A SwiftUI screen: a localized title bar with a close button above the hosted tab bar.
- L40 `final class CYLSVGASwiftUIDemo: NSObject`

## `CYLSearchExample/CYLYechaoaSearchViewController.swift`

Port of yechaoa/MaterialDesign's `SearchViewActivity`: an iconified search view in the toolbar with a submit button, the Search return key, a hint and custom colors; a submitted query shows a snackbar and a search result, and clearing the text hides the result again.

- L10 `final class CYLYechaoaSearchViewController: UIViewController` — Port of yechaoa/MaterialDesign's `SearchViewActivity`: an iconified search view in the toolbar with a submit button, the Search return key, a hint and custom colors; a submitted query shows a snackbar and a search result, and clearing the text hides the result
- L52 `extension CYLYechaoaSearchViewController: CYLSearchBarViewDelegate`
