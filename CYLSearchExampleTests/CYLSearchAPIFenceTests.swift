//
//  CYLSearchAPIFenceTests.swift
//  CYLSearchExampleTests
//
//  The API fence of the merge refactor (docs/qmui-search-controller.md, "Merge design", phase 0): every public and open
//  member of CYLSearchBarView, CYLSearchBarItem, CYLSearchView, CYLSearchBar, CYLSearchBarAppearance,
//  CYLSearchController, CYLSearchTableViewController, their delegate protocols and their enums is named below. Removing
//  or renaming one of them breaks this file's compilation. The module is imported without `@testable`, so a member that
//  loses its `public` or `open` breaks it too. Properties are read and written back; methods are taken as typed
//  function references (the signature is part of the fence) and some are called with harmless arguments.
//

import UIKit
import XCTest
import CYLSearchViewController
import CYLTableViewPlaceHolder

// MARK: - Dummies that conform to every protocol with every optional method

private final class FenceSearchBarViewDelegate: NSObject, CYLSearchBarViewDelegate {
    @objc func searchBarViewShouldBeginEditing(_ searchBarView: CYLSearchBarView) -> Bool { true }
    @objc func searchBarViewDidTapWhileNotEditable(_ searchBarView: CYLSearchBarView) {}
    @objc func searchBarViewDidBeginEditing(_ searchBarView: CYLSearchBarView) {}
    @objc func searchBarViewDidEndEditing(_ searchBarView: CYLSearchBarView) {}
    @objc(searchBarView:textDidChange:) func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String) {}
    @objc func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView) {}
    @objc func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView) {}
    @objc func searchBarViewNavigationButtonClicked(_ searchBarView: CYLSearchBarView) {}
    @objc func searchBarViewVoiceButtonClicked(_ searchBarView: CYLSearchBarView) {}
    @objc(searchBarView:shouldSubmitText:) func searchBarView(_ searchBarView: CYLSearchBarView, shouldSubmitText text: String) -> Bool { true }
    @objc(searchBarView:didChangeIconified:) func searchBarView(_ searchBarView: CYLSearchBarView, didChangeIconified iconified: Bool) {}
    @objc(searchBarView:didSelectItem:) func searchBarView(_ searchBarView: CYLSearchBarView, didSelect item: CYLSearchBarItem) {}
    @objc(searchBarView:textDidChange:atIndex:) func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String, at index: Int) {}
    @objc(searchBarView:didCompleteSearch:atIndex:) func searchBarView(_ searchBarView: CYLSearchBarView, didCompleteSearch text: String, at index: Int) {}
    @objc(searchBarView:didRemoveSearchAtIndex:) func searchBarView(_ searchBarView: CYLSearchBarView, didRemoveSearchAt index: Int) {}
    @objc(searchBarView:didSelectSearch:atIndex:) func searchBarView(_ searchBarView: CYLSearchBarView, didSelectSearch text: String, at index: Int) {}
}

private final class FenceSearchViewDelegate: NSObject, CYLSearchViewDelegate {
    @objc func searchViewWillShow(_ searchView: CYLSearchView) {}
    @objc func searchViewWillClose(_ searchView: CYLSearchView) {}
    @objc func searchViewDidShow(_ searchView: CYLSearchView) {}
    @objc func searchViewDidClose(_ searchView: CYLSearchView) {}
    @objc(searchView:textDidChange:) func searchView(_ searchView: CYLSearchView, textDidChange text: String) {}
    @objc(searchView:didSubmitText:) func searchView(_ searchView: CYLSearchView, didSubmitText text: String) -> Bool { true }
    @objc(searchView:didChangeFocus:) func searchView(_ searchView: CYLSearchView, didChangeFocus focused: Bool) {}
    @objc(searchView:didSelectSuggestion:atIndex:) func searchView(_ searchView: CYLSearchView, didSelectSuggestion suggestion: String, at index: UInt) {}
    @objc func searchViewVoiceButtonClicked(_ searchView: CYLSearchView) {}
    @objc func searchViewNavigationButtonClicked(_ searchView: CYLSearchView) {}
    @objc(searchView:didSelectResult:) func searchView(_ searchView: CYLSearchView, didSelectResult result: Any) {}
}

private final class FenceSearchViewDataSource: NSObject, CYLSearchViewDataSource {
    @objc(searchView:resultsForQuery:) func searchView(_ searchView: CYLSearchView, resultsForQuery query: String) -> [Any] { [query] }
    @objc(searchView:configureResultCell:withResult:) func searchView(_ searchView: CYLSearchView, configureResultCell cell: UITableViewCell, withResult result: Any) {}
}

private final class FenceSearchControllerDelegate: NSObject, CYLSearchControllerDelegate {
    @objc(searchController:updateResultsForSearchString:) func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String) {}
    @objc func willPresentSearchController(_ searchController: CYLSearchController) {}
    @objc func didPresentSearchController(_ searchController: CYLSearchController) {}
    @objc func willDismissSearchController(_ searchController: CYLSearchController) {}
    @objc func didDismissSearchController(_ searchController: CYLSearchController) {}
    @objc(searchController:didLoadSearchResultsTableView:) func searchController(_ searchController: CYLSearchController, didLoad tableView: UITableView) {}
    @objc(searchController:willShowEmptyView:) func searchController(_ searchController: CYLSearchController, willShow emptyView: UIView) {}
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 0 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { UITableViewCell() }
}

// MARK: - Subclasses: the open members stay open

private final class FenceSearchController: CYLSearchController {
    override func viewDidLoad() { super.viewDidLoad() }
}

private final class FenceSearchTableViewController: CYLSearchTableViewController {
    override func viewDidLoad() { super.viewDidLoad() }
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated) }
    override func viewDidLayoutSubviews() { super.viewDidLayoutSubviews() }
    override func setUpSearchBar() { super.setUpSearchBar() }
    override func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String) {
        super.searchController(searchController, updateResultsFor: searchString)
    }
}

@MainActor
final class CYLSearchAPIFenceTests: XCTestCase {

    /// Writes a property's own value back through its key path (Swift refuses `x.p = x.p`).
    private func touch<Root, Value>(_ root: Root, _ keyPath: ReferenceWritableKeyPath<Root, Value>) {
        root[keyPath: keyPath] = root[keyPath: keyPath]
    }

    // MARK: Enums

    func testEnumsKeepEveryCase() {
        XCTAssertEqual([CYLSearchBarMode.single, .multiple].map(\.rawValue), [0, 1])
        XCTAssertEqual([CYLSearchBarNavigationIcon.none, .arrow, .search].map(\.rawValue), [0, 1, 2])
        XCTAssertEqual([CYLSearchBarIconPosition.trailing, .center, .leading].map(\.rawValue), [0, 1, 2])
        XCTAssertEqual([CYLSearchBarExpansionAnimation.fade, .circularReveal].map(\.rawValue), [0, 1])
        XCTAssertEqual([CYLSearchBarItemStyle.icon, .divider, .text].map(\.rawValue), [0, 1, 2])
        XCTAssertEqual([CYLSearchBarStyle.plain, .bordered].map(\.rawValue), [0, 1])
        XCTAssertEqual([CYLSearchSuggestionStyle.list, .tags].map(\.rawValue), [0, 1])
    }

    // MARK: CYLSearchBarView

    func testSearchBarViewMembers() {
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 320, height: 56))
        let _: (CGRect) -> CYLSearchBarView = CYLSearchBarView.init(frame:)
        let _: (NSCoder) -> CYLSearchBarView? = CYLSearchBarView.init(coder:)
        touch(bar, \.delegate)
        _ = bar.textField
        _ = bar.fieldView
        _ = bar.searchIconView
        _ = bar.cancelButton
        _ = bar.placeholderLabel
        _ = bar.navigationButton
        _ = bar.voiceButton
        _ = bar.submitButton
        _ = bar.iconButton
        touch(bar, \.text)
        touch(bar, \.placeholder)
        touch(bar, \.font)
        touch(bar, \.textColor)
        touch(bar, \.placeholderColor)
        touch(bar, \.cursorColor)
        touch(bar, \.fieldHeight)
        touch(bar, \.contentInsets)
        touch(bar, \.fieldBackgroundColor)
        touch(bar, \.fieldCornerRadius)
        touch(bar, \.fieldBorderColor)
        touch(bar, \.fieldBorderWidth)
        touch(bar, \.fieldShadowOpacity)
        touch(bar, \.searchIcon)
        touch(bar, \.searchIconTintColor)
        touch(bar, \.trailingAccessoryViews)
        _ = bar.items
        _ = bar.itemViews
        touch(bar, \.itemTintColor)
        touch(bar, \.searchBarStyle)
        touch(bar, \.fieldBackgroundImage)
        _ = bar.selectedItem
        _ = bar.selectedIndex
        touch(bar, \.leadingView)
        touch(bar, \.showsCancelButton)
        // Merge phase 1: the knobs CYLSearchBarView shares with CYLSearchBar.
        touch(bar, \.centersPlaceholder)
        touch(bar, \.textFieldMarginsProvider)
        touch(bar, \.cancelButtonMarginsProvider)
        touch(bar, \.cancelButtonFont)
        touch(bar, \.appearanceStyle)
        touch(bar, \.showsLeadingView)
        touch(bar, \.showsTrailingAccessoryViews)
        let _: CYLSearchBarViewMarginsProvider? = bar.textFieldMarginsProvider
        let _: (Bool, Bool) -> Void = bar.setShowsCancelButton
        let _: (Bool, Bool) -> Void = bar.setShowsLeadingView
        let _: (Bool, Bool) -> Void = bar.setShowsTrailingAccessoryViews
        let _: () -> Void = bar.applyDefaultAppearance
        touch(bar, \.cancelButtonTitle)
        touch(bar, \.cancelButtonEndsEditing)
        touch(bar, \.clearsTextOnCancel)
        _ = bar.isEditingBar
        touch(bar, \.editingSubmitHandler)
        touch(bar, \.clearsTextOnEndEditing)
        touch(bar, \.navigationIcon)
        touch(bar, \.navigationImage)
        touch(bar, \.navigationAccessibilityLabel)
        touch(bar, \.navigationBackgroundColor)
        touch(bar, \.navigationShadowOpacity)
        touch(bar, \.navigationHandler)
        touch(bar, \.showsVoiceButton)
        touch(bar, \.voiceImage)
        touch(bar, \.showsSubmitButton)
        touch(bar, \.submitImage)
        touch(bar, \.clearImage)
        touch(bar, \.keyboardType)
        touch(bar, \.returnKeyType)
        touch(bar, \.autocapitalizationType)
        touch(bar, \.autocorrectionType)
        touch(bar, \.isSecureTextEntry)
        touch(bar, \.maximumTextLength)
        touch(bar, \.isIconified)
        touch(bar, \.iconifiedByDefault)
        touch(bar, \.expansionAnimation)
        touch(bar, \.iconPosition)
        touch(bar, \.animationDuration)
        touch(bar, \.mode)
        _ = bar.searches
        _ = bar.selectedSearchIndex
        _ = bar.isEditingNewSearch
        _ = bar.newSearchButton
        touch(bar, \.minimumTextLength)
        touch(bar, \.searchIndicatorColor)
        touch(bar, \.unselectedSearchAlpha)
        touch(bar, \.searchFieldWidth)
        touch(bar, \.newSearchImage)
        touch(bar, \.removeSearchImage)
        _ = bar.intrinsicContentSize
        // Methods.
        let item = CYLSearchBarItem(title: "A", image: nil)
        let _: (CYLSearchBarItem) -> Void = bar.addItem
        let _: (CYLSearchBarItem, Int) -> Void = bar.insertItem
        let _: (CYLSearchBarItemStyle, String?, UIImage?, Int, ((CYLSearchBarItem) -> Void)?) -> CYLSearchBarItem = bar.addItem
        let _: (CYLSearchBarItem) -> Void = bar.removeItem
        let _: () -> Void = bar.removeAllItems
        let _: (CYLSearchBarItemStyle) -> Bool = bar.hasItem
        let _: (String?, String) -> CYLSearchBarView = CYLSearchBarView.editingBar
        let _: (UIView) -> Void = bar.pinToKeyboard
        let _: () -> Void = bar.beginNewSearch
        let _: () -> Void = bar.completeSearch
        let _: (String) -> Void = bar.addSearch
        let _: (Int) -> Void = bar.selectSearch
        let _: (Int) -> Void = bar.removeSearch
        let _: (String?, Bool) -> Void = bar.setText
        let _: () -> Bool = bar.submit
        let _: () -> Void = bar.showKeyboard
        let _: () -> Void = bar.hideKeyboard
        let _: (Bool, Bool) -> Void = bar.setIconified
        let _: (UITextField) -> Bool = bar.textFieldShouldBeginEditing
        let _: (UITextField) -> Bool = bar.textFieldShouldReturn
        let _: (UITextField, NSRange, String) -> Bool = bar.textField(_:shouldChangeCharactersIn:replacementString:)
        let _: (UITextField) -> Void = bar.textFieldDidBeginEditing
        let _: (UITextField) -> Void = bar.textFieldDidEndEditing
        let _: () -> Bool = bar.becomeFirstResponder
        let _: () -> Bool = bar.resignFirstResponder
        let _: (CGSize) -> CGSize = bar.sizeThatFits
        // Harmless calls.
        bar.addItem(item)
        XCTAssertTrue(bar.hasItem(of: item.style))
        bar.removeItem(item)
        XCTAssertFalse(bar.hasItem(of: .icon))
        bar.removeAllItems()
        bar.setText("fence", submit: false)
        XCTAssertEqual(bar.text, "fence")
        bar.setIconified(false, animated: false)
        // The delegate: a dummy answers every optional method, each called through the protocol.
        let delegate = FenceSearchBarViewDelegate()
        bar.delegate = delegate
        let d: CYLSearchBarViewDelegate = delegate
        _ = d.searchBarViewShouldBeginEditing?(bar)
        d.searchBarViewDidTapWhileNotEditable?(bar)
        d.searchBarViewDidBeginEditing?(bar)
        d.searchBarViewDidEndEditing?(bar)
        d.searchBarView?(bar, textDidChange: "a")
        d.searchBarViewSearchButtonClicked?(bar)
        d.searchBarViewCancelButtonClicked?(bar)
        d.searchBarViewNavigationButtonClicked?(bar)
        d.searchBarViewVoiceButtonClicked?(bar)
        _ = d.searchBarView?(bar, shouldSubmitText: "a")
        d.searchBarView?(bar, didChangeIconified: false)
        d.searchBarView?(bar, didSelect: item)
        d.searchBarView?(bar, textDidChange: "a", at: 0)
        d.searchBarView?(bar, didCompleteSearch: "a", at: 0)
        d.searchBarView?(bar, didRemoveSearchAt: 0)
        d.searchBarView?(bar, didSelectSearch: "a", at: 0)
    }

    // MARK: CYLSearchBarItem

    func testSearchBarItemMembers() {
        let item = CYLSearchBarItem(style: .icon, title: "Item", image: nil)
        let _: (CYLSearchBarItemStyle, String?, UIImage?) -> CYLSearchBarItem = CYLSearchBarItem.init(style:title:image:)
        let _: (String?, UIImage?) -> CYLSearchBarItem = CYLSearchBarItem.init(title:image:)
        let _: (String?, UIImage?, UIImage?) -> CYLSearchBarItem = CYLSearchBarItem.init(title:image:selectedImage:)
        _ = item.style
        touch(item, \.title)
        touch(item, \.image)
        touch(item, \.selectedImage)
        touch(item, \.animatedImage)
        touch(item, \.animationURL)
        touch(item, \.imageSize)
        touch(item, \.itemAccessibilityLabel)
        touch(item, \.itemAccessibilityIdentifier)
        touch(item, \.isEnabled)
        touch(item, \.isSelectable)
        touch(item, \.isSelected)
        touch(item, \.tintColor)
        touch(item, \.backgroundColor)
        touch(item, \.selectedBackgroundColor)
        touch(item, \.contentInsets)
        touch(item, \.imagePositionAdjustment)
        touch(item, \.titlePositionAdjustment)
        touch(item, \.badgeValue)
        touch(item, \.badgeColor)
        touch(item, \.badgeSize)
        touch(item, \.badgeContentInsets)
        touch(item, \.badgePositionAdjustment)
        touch(item, \.handler)
        _ = item.searchBarView
        _ = item.index
        _ = item.itemView
        let _: (UIImage?, String?, ((CYLSearchBarItem) -> Void)?) -> CYLSearchBarItem = CYLSearchBarItem.iconItem
        let _: (String, ((CYLSearchBarItem) -> Void)?) -> CYLSearchBarItem = CYLSearchBarItem.textItem
        let _: () -> CYLSearchBarItem = CYLSearchBarItem.divider
        let _: ([String: Any]) -> CYLSearchBarItem = CYLSearchBarItem.item(dictionary:)
        let _: ([NSAttributedString.Key: Any]?, UIControl.State) -> Void = item.setTitleTextAttributes
        let _: (UIControl.State) -> [NSAttributedString.Key: Any]? = item.titleTextAttributes(for:)
        let _: ([NSAttributedString.Key: Any]?, UIControl.State) -> Void = item.setBadgeTextAttributes
        let _: (UIControl.State) -> [NSAttributedString.Key: Any]? = item.badgeTextAttributes(for:)
        let _: () -> UIView = item.actualBadgeSuperView
        item.setTitleTextAttributes([.foregroundColor: UIColor.red], for: .normal)
        XCTAssertNotNil(item.titleTextAttributes(for: .normal))
        XCTAssertEqual(CYLSearchBarItem.divider().style, .divider)
        XCTAssertEqual(CYLSearchBarItem.textItem(title: "T", handler: nil).style, .text)
    }

    // MARK: CYLSearchView

    func testSearchViewMembers() {
        let view = CYLSearchView(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        let _: (CGRect) -> CYLSearchView = CYLSearchView.init(frame:)
        let _: (NSCoder) -> CYLSearchView? = CYLSearchView.init(coder:)
        touch(view, \.delegate)
        _ = view.searchBarView
        _ = view.dividerView
        _ = view.suggestionsTableView
        _ = view.suggestionsTagView
        touch(view, \.suggestionsFoldControl)
        touch(view, \.suggestionsFoldedRowCount)
        touch(view, \.suggestionStyle)
        touch(view, \.showsEmptyResultsPlaceholder)
        touch(view, \.emptyResultsScenario)
        _ = view.emptyResultsView
        touch(view, \.resultsDataSource)
        _ = view.resultsTableView
        _ = view.searchResults
        touch(view, \.highlightsResultMatches)
        touch(view, \.resultMatchHighlightColor)
        touch(view, \.resultsHeaderTitleProvider)
        touch(view, \.resultsHeaderTextColor)
        touch(view, \.suggestionCacheFooterTitle)
        touch(view, \.refreshHandler)
        _ = view.isRefreshing
        touch(view, \.dividerColor)
        touch(view, \.contentView)
        touch(view, \.scrimColor)
        touch(view, \.suggestions)
        touch(view, \.suggestionFilter)
        touch(view, \.showsSuggestionsForEmptyQuery)
        _ = view.filteredSuggestions
        touch(view, \.suggestionImage)
        touch(view, \.suggestionImageTintColor)
        touch(view, \.suggestionBackgroundColor)
        touch(view, \.suggestionTextColor)
        touch(view, \.suggestionLineBreakMode)
        touch(view, \.submitsOnSuggestionSelection)
        touch(view, \.suggestionCellConfiguration)
        touch(view, \.suggestionCachePolicy)
        touch(view, \.suggestionCacheName)
        touch(view, \.suggestionCache)
        touch(view, \.noResultsText)
        let _: (Bool, UIView, UITableView) -> Void = view.setSnapsHeader
        _ = view.suggestionCacheHeaderView
        touch(view, \.showsSuggestionCacheHeader)
        _ = view.suggestionCacheTitleLabel
        _ = view.clearSuggestionCacheButton
        touch(view, \.showsEmptySuggestionsPlaceholder)
        touch(view, \.emptySuggestionsScenario)
        _ = view.emptySuggestionsView
        touch(view, \.focusesSearchFieldOnShow)
        _ = view.searchOpen
        touch(view, \.isActive)
        let _: (Bool, Bool) -> Void = view.setActive
        touch(view, \.supportsSwipeToDismissSearch)
        touch(view, \.animationDuration)
        touch(view, \.closesOnSubmit)
        touch(view, \.query)
        touch(view, \.backgroundColor)
        let _: (UIView) -> Void = view.install
        let _: () -> Void = view.showSearch
        let _: (Bool) -> Void = view.showSearch(animated:)
        let _: (UIViewController, Bool) -> Void = view.showSearch(in:animated:)
        let _: () -> Void = view.closeSearch
        let _: (Bool) -> Void = view.closeSearch(animated:)
        let _: (Bool, (() -> Void)?) -> Void = view.closeSearch(animated:completion:)
        let _: (UIBarButtonItem) -> Void = view.attach
        let _: (String?, Bool) -> Void = view.setQuery
        let _: () -> Void = view.showSuggestions
        let _: () -> Void = view.reloadResults
        let _: () -> Void = view.dismissSuggestions
        let _: () -> Void = view.clearSuggestionCache
        let _: () -> Void = view.beginRefreshing
        let _: () -> Void = view.endRefreshing
        let _: ((() -> Void)?, UIScrollView) -> Void = CYLSearchView.setRefreshHandler(_:for:)
        let _: (UIScrollView) -> Void = CYLSearchView.beginRefreshing(in:)
        let _: (UIScrollView) -> Void = CYLSearchView.endRefreshing(in:)
        let _: (UIScrollView) -> Bool = CYLSearchView.isRefreshing(in:)
        // The CYLSearchBarViewDelegate, UITableViewDataSource and UITableViewDelegate members the view implements.
        let _: (CYLSearchBarView, String) -> Void = view.searchBarView(_:textDidChange:)
        let _: (CYLSearchBarView) -> Void = view.searchBarViewSearchButtonClicked
        let _: (CYLSearchBarView) -> Void = view.searchBarViewNavigationButtonClicked
        let _: (CYLSearchBarView) -> Void = view.searchBarViewVoiceButtonClicked
        let _: (CYLSearchBarView) -> Void = view.searchBarViewCancelButtonClicked
        let _: (CYLSearchBarView) -> Void = view.searchBarViewDidBeginEditing
        let _: (CYLSearchBarView) -> Void = view.searchBarViewDidEndEditing
        let _: () -> Bool = view.accessibilityPerformEscape
        let _: (UITableView, Int) -> Int = view.tableView(_:numberOfRowsInSection:)
        let _: (UITableView, IndexPath) -> UITableViewCell = view.tableView(_:cellForRowAt:)
        let _: (UITableView, IndexPath) -> Void = view.tableView(_:didSelectRowAt:)
        // Harmless calls.
        view.suggestions = ["Swift"]
        view.setQuery("Sw", submit: false)
        view.clearSuggestionCache()
        let delegate = FenceSearchViewDelegate()
        let dataSource = FenceSearchViewDataSource()
        view.delegate = delegate
        view.resultsDataSource = dataSource
        let d: CYLSearchViewDelegate = delegate
        d.searchViewWillShow?(view)
        d.searchViewWillClose?(view)
        d.searchViewDidShow?(view)
        d.searchViewDidClose?(view)
        d.searchView?(view, textDidChange: "a")
        _ = d.searchView?(view, didSubmitText: "a")
        d.searchView?(view, didChangeFocus: true)
        d.searchView?(view, didSelectSuggestion: "a", at: 0)
        d.searchViewVoiceButtonClicked?(view)
        d.searchViewNavigationButtonClicked?(view)
        d.searchView?(view, didSelectResult: "a")
        let s: CYLSearchViewDataSource = dataSource
        XCTAssertEqual(s.searchView(view, resultsForQuery: "q").count, 1)
        s.searchView(view, configureResultCell: UITableViewCell(), withResult: "q")
    }

    // MARK: CYLSearchBarAppearance

    func testSearchBarAppearanceMembers() {
        let app = CYLSearchBarAppearance()
        let _: () -> CYLSearchBarAppearance = CYLSearchBarAppearance.init
        touch(app, \.font)
        touch(app, \.textColor)
        touch(app, \.placeholderColor)
        touch(app, \.placeholder)
        touch(app, \.cancelTitle)
        touch(app, \.tintColor)
        touch(app, \.searchIconImage)
        touch(app, \.clearIconImage)
        touch(app, \.textFieldBackgroundColor)
        touch(app, \.textFieldBackgroundImage)
        touch(app, \.textFieldBorderColor)
        touch(app, \.textFieldCornerRadius)
        touch(app, \.barBackgroundImage)
        touch(app, \.barBackgroundColor)
        touch(app, \.barBorderColor)
        touch(app, \.hidesBarBackground)
        _ = CYLSearchBarAppearance.default
        let _: (NSZone?) -> Any = app.copy(with:)
        XCTAssertTrue(app.copy(with: nil) is CYLSearchBarAppearance)
        XCTAssertTrue(CYLSearchBarAppearance.default.copy() is CYLSearchBarAppearance)
    }

    // MARK: CYLSearchController

    func testSearchControllerMembers() {
        let host = UIViewController()
        let sc = CYLSearchController(contentsViewController: host)
        let _: (UIViewController, UIViewController) -> CYLSearchController = CYLSearchController.init(contentsViewController:resultsViewController:)
        let _: (UIViewController, UITableView.Style) -> CYLSearchController = CYLSearchController.init(contentsViewController:resultsTableViewStyle:)
        let _: (UIViewController) -> CYLSearchController = CYLSearchController.init(contentsViewController:)
        let _: (NSCoder) -> CYLSearchController? = CYLSearchController.init(coder:)
        touch(sc, \.searchResultsDelegate)
        _ = sc.searchResultsController
        _ = sc.searchBar
        _ = sc.tableView
        touch(sc, \.launchView)
        touch(sc, \.showsSuggestionsLaunchView)
        touch(sc, \.suggestions)
        touch(sc, \.dimmingColor)
        touch(sc, \.isActive)
        _ = sc.searchOpen
        let _: (Bool) -> Void = sc.showSearch(animated:)
        let _: (Bool) -> Void = sc.closeSearch(animated:)
        touch(sc, \.highlightsResultMatches)
        touch(sc, \.resultMatchHighlightColor)
        touch(sc, \.noResultsText)
        touch(sc, \.alwaysShowsSearchResultsController)
        touch(sc, \.supportsSwipeToDismissSearch)
        _ = sc.swipeGestureRecognizer
        _ = sc.searchBarMaxY
        _ = sc.isEmptyViewShowing
        touch(sc, \.historyStore)
        _ = CYLSearchController.historyDidChangeNotification
        _ = CYLSearchResources.historyDidChangeNotification
        touch(sc, \.snapsHeaderSearchBar)
        let _: (Bool, Bool) -> Void = sc.setActive
        let _: (UITableView) -> Void = sc.installSearchBar(asHeaderOf:)
        let _: (UINavigationItem) -> Void = sc.install(in:)
        let _: (String?, String?, String?, (() -> Void)?) -> Void = sc.showEmptyView(text:detailText:buttonTitle:buttonAction:)
        let _: (CYLPlaceholderScenario) -> Void = sc.showEmptyView(scenario:)
        let _: () -> Void = sc.hideEmptyView
        let _: (UIGestureRecognizer) -> Bool = sc.gestureRecognizerShouldBegin
        let _: (UIGestureRecognizer, UIGestureRecognizer) -> Bool = sc.gestureRecognizer(_:shouldBeRequiredToFailBy:)
        let delegate = FenceSearchControllerDelegate()
        sc.searchResultsDelegate = delegate
        let d: CYLSearchControllerDelegate = delegate
        d.searchController(sc, updateResultsFor: "a")
        d.willPresentSearchController?(sc)
        d.didPresentSearchController?(sc)
        d.willDismissSearchController?(sc)
        d.didDismissSearchController?(sc)
        d.searchController?(sc, didLoad: UITableView())
        d.searchController?(sc, willShow: UIView())
        XCTAssertNotNil(FenceSearchController(contentsViewController: host))
    }

    // MARK: CYLSearchTableViewController

    func testSearchTableViewControllerMembers() {
        let tvc = FenceSearchTableViewController(style: .plain)
        let base: CYLSearchTableViewController = tvc
        touch(base, \.showsSearchBar)
        _ = base.searchController
        _ = base.searchBar
        touch(base, \.hidesSearchBarWhenEmptyViewShowing)
        touch(base, \.hidesSearchBarInitially)
        _ = base.isEmptyViewShowing
        let _: () -> Void = base.setUpSearchBar
        let _: (CYLSearchController, String) -> Void = base.searchController(_:updateResultsFor:)
        let _: (String?, String?) -> Void = base.showEmptyView(text:detailText:)
        let _: (CYLPlaceholderScenario) -> Void = base.showEmptyView(scenario:)
        let _: () -> Void = base.hideEmptyView
        base.loadViewIfNeeded()
        base.showsSearchBar = true
        base.showEmptyView(text: "None", detailText: nil)
        XCTAssertTrue(base.isEmptyViewShowing)
        base.hideEmptyView()
        // The screen is its own delegate (CYLSearchControllerDelegate).
        let _: CYLSearchControllerDelegate = base
    }
}
