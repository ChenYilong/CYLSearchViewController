//
//  CYLSearchExampleSearchBarTests.swift
//  CYLSearchExampleTests
//
//  The search bar view, demo row, tab bar, plus button and search-bar-cover tests (translated from
//  CYLSearchExampleTests.m, docs/swift-migration.md, step 4).
//

import CYLAnimatedItem
@testable import CYLSearchViewController
import CYLTabBarController
import CYLTableViewPlaceHolder
import CollectionViewClassifyMenu
import UIKit
import XCTest
@testable import CYLSearchExample

/**
 * The search bar view, demo row, tab bar, plus button and search-bar-cover tests.
 */
final class CYLSearchExampleSearchBarTests: CYLSearchExampleTestCase {

    func testSearchBarViewLayoutStyleAndEvents() throws {
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 375, height: 48))
        let recorder = CYLSearchBarRecorder()
        bar.delegate = recorder
        bar.placeholder = "主播昵称/直播间ID/神曲名"
        XCTAssertEqual(bar.textField.placeholder, "主播昵称/直播间ID/神曲名")
        XCTAssertEqual(bar.intrinsicContentSize.height, 48)
        XCTAssertTrue(bar.cancelButton.isHidden)

        bar.showsCancelButton = true
        bar.cancelButtonTitle = "取消"
        let camera = UIButton(type: .system)
        camera.setImage(UIImage(systemName: "camera"), for: .normal)
        bar.trailingAccessoryViews = [camera]
        bar.fieldCornerRadius = 4
        bar.layoutIfNeeded()
        XCTAssertFalse(bar.cancelButton.isHidden)
        XCTAssertEqual(bar.cancelButton.configuration?.attributedTitle.map { String($0.characters) }, "取消")
        let font = try XCTUnwrap(bar.font)
        let titleWidth = ("取消" as NSString).size(withAttributes: [.font: font]).width
        XCTAssertGreaterThanOrEqual(bar.cancelButton.frame.width, titleWidth, "the whole title fits")
        XCTAssertLessThanOrEqual(bar.fieldView.frame.maxX, bar.cancelButton.frame.minX)
        XCTAssertTrue(camera.superview === bar.fieldView)
        XCTAssertLessThanOrEqual(bar.textField.frame.maxX, camera.frame.minX)
        XCTAssertEqual(bar.fieldView.layer.cornerRadius, 4)
        bar.fieldCornerRadius = -1
        bar.layoutIfNeeded()
        XCTAssertEqual(bar.fieldView.layer.cornerRadius, 18, "a capsule")

        bar.text = "IDG"
        XCTAssertEqual(bar.textField.text, "IDG")
        bar.textField.sendActions(for: .editingChanged)
        _ = bar.textField.delegate?.textFieldShouldReturn?(bar.textField)
        bar.cancelButton.sendActions(for: .touchUpInside)
        let expected = ["text IDG", "search", "cancel"]
        XCTAssertEqual(recorder.events, expected)

        let back = UIButton(type: .system)
        bar.leadingView = back
        bar.layoutIfNeeded()
        XCTAssertLessThanOrEqual(back.frame.maxX, bar.fieldView.frame.minX + 0.5)
        XCTAssertEqual(CYLSearchResources.localizedString(forKey: "search.cancel", language: "zh-Hans"), "取消")
        XCTAssertEqual(CYLSearchResources.localizedString(forKey: "search.cancel", language: "en"), "Cancel")
    }

    func testSearchBarViewSupportsVoiceOverAndDynamicType() throws {
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 375, height: 48))
        // The field keeps a spoken name when the placeholder is gone; the magnifier is decorative.
        XCTAssertEqual(bar.textField.accessibilityLabel, CYLSearchResources.localizedString(forKey: "search.field"))
        XCTAssertFalse(bar.searchIconView.isAccessibilityElement)
        XCTAssertEqual(CYLSearchResources.localizedString(forKey: "search.field", language: "zh-Hant"), "搜尋")
        XCTAssertEqual(CYLSearchResources.localizedString(forKey: "search.field", language: "ja"), "検索")

        // A scaled font is used as given (not scaled twice), and the field grows instead of clipping the text.
        let large = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
        XCTAssertEqual(bar.intrinsicContentSize.height, 48, "36 pt is enough at the default size")
        let scaled = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 16), compatibleWith: large)
        bar.font = scaled
        XCTAssertIdentical(bar.font, scaled)
        XCTAssertGreaterThan(bar.intrinsicContentSize.height, 48, "the field grows with large text")
        bar.fieldHeight = 10
        let font = try XCTUnwrap(bar.font)
        XCTAssertGreaterThanOrEqual(bar.intrinsicContentSize.height, ceil(font.lineHeight + 12) + 12, "never shorter than the text")

        // At the largest size the text keeps 40% of the bar: Cancel and a large accessory are drawn smaller instead.
        bar.fieldHeight = 36
        // This check is about Cancel and the accessory; the default search button has its own test.
        bar.showsSearchButton = false
        bar.showsCancelButton = true
        bar.cancelButtonTitle = "Cancel"
        let camera = UIButton(type: .system)
        camera.setImage(UIImage(systemName: "camera", withConfiguration: UIImage.SymbolConfiguration(pointSize: 64)), for: .normal)
        bar.trailingAccessoryViews = [camera]
        bar.frame = CGRect(x: 0, y: 0, width: 390, height: bar.intrinsicContentSize.height)
        bar.layoutIfNeeded()
        let available = 390 - bar.contentInsets.left - bar.contentInsets.right
        XCTAssertGreaterThanOrEqual(bar.textField.frame.width, floor(available * 0.4) - 1)
        XCTAssertLessThanOrEqual(bar.cancelButton.frame.width, floor(available * 0.3) + 0.5)
        XCTAssertLessThan(camera.transform.a, 1, "the camera is drawn smaller")
        XCTAssertLessThanOrEqual(bar.textField.frame.maxX, camera.frame.minX + 0.5)
        XCTAssertLessThanOrEqual(camera.frame.maxX, bar.fieldView.bounds.width)
        XCTAssertEqual(bar.cancelButton.accessibilityLabel, "Cancel", "VoiceOver reads the whole title")

        // The placeholder keeps the text's size at large sizes (cut off with an ellipsis, never shrunk), hides while
        // there is text, and stays on the text field for VoiceOver.
        bar.placeholder = "主播昵称/直播间ID/神曲名"
        bar.layoutIfNeeded()
        XCTAssertEqual(bar.placeholderLabel.font.pointSize, bar.font.pointSize)
        XCTAssertFalse(bar.placeholderLabel.adjustsFontSizeToFitWidth)
        XCTAssertEqual(bar.placeholderLabel.lineBreakMode, .byTruncatingTail)
        XCTAssertEqual(bar.placeholderLabel.text, "主播昵称/直播间ID/神曲名")
        XCTAssertEqual(bar.textField.placeholder, "主播昵称/直播间ID/神曲名", "VoiceOver still gets the placeholder")
        XCTAssertTrue(bar.textField.frame.insetBy(dx: -0.5, dy: -0.5).contains(bar.placeholderLabel.frame))
        XCTAssertFalse(bar.placeholderLabel.isHidden)
        bar.text = "IDG"
        XCTAssertTrue(bar.placeholderLabel.isHidden)
        bar.text = nil
        XCTAssertFalse(bar.placeholderLabel.isHidden)
    }

    func testOriginalDemoRebuiltOnTheCore() throws {
        // The README screenshot's demo: the menu's seventh row opens a page whose search field opens CYLSearchView with the
        // history below the field and a text button that clears it, the sky under the list, and results under a header.
        let menu = CYLSearchDemoMenuViewController(style: .grouped)
        let navigation = CYLSearchTestNavigationController(rootViewController: menu)
        menu.loadViewIfNeeded()
        let row = IndexPath(row: 6, section: 0)
        XCTAssertGreaterThan(menu.tableView(menu.tableView, cellForRowAt: row).textLabel?.text?.count ?? 0, 0, "the row has a title")
        menu.tableView(menu.tableView, didSelectRowAt: row)
        let demo = try XCTUnwrap(navigation.lastPushedController)
        XCTAssertTrue(demo is CYLOriginalSearchDemoViewController)
        let window = testWindow(CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        demo.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        demo.view.layoutIfNeeded()
        let field = viewWithAccessibilityIdentifier(demo.view, "CYLOriginalDemoSearchField") as? CYLSearchBarView
        XCTAssertNotNil(field, "the field that opens the search")
        // A tap on the field asks to begin editing; the demo refuses and opens the search instead.
        _ = field?.textField.becomeFirstResponder()
        runLoop(0.5)
        let search = try XCTUnwrap(viewOfClass(window, CYLSearchView.self), "the core's search page opened")
        XCTAssertFalse(search.showsSuggestionCacheHeader, "the clear button is the text button below the list")
        XCTAssertNotNil(search.suggestionsTableView.tableFooterView)
        XCTAssertNotNil(search.contentView, "the sky stays under the list")
        // The GIF: Cancel after the field, no back arrow before it.
        XCTAssertTrue(search.searchBarView.showsCancelButton)
        XCTAssertEqual(search.searchBarView.navigationIcon, CYLSearchBarNavigationIcon.none)
        // Search lists the results under the header and puts the term in the history, shown again for an empty field.
        search.clearSuggestionCache()
        search.searchBarView.text = "Gf"
        search.searchBarView(search.searchBarView, textDidChange: "Gf")
        search.searchBarViewSearchButtonClicked(search.searchBarView)
        XCTAssertEqual(search.resultsTableView.numberOfRows(inSection: 0), 4)
        let header = search.resultsTableView.tableHeaderView.flatMap { viewOfClass($0, UILabel.self) }
        XCTAssertTrue(header?.text?.contains("Gf") ?? false, String(describing: header?.text))
        search.searchBarView.text = ""
        search.searchBarView(search.searchBarView, textDidChange: "")
        search.suggestionsTableView.layoutIfNeeded()
        XCTAssertFalse(search.suggestionsTableView.isHidden, "the history is listed")
        XCTAssertEqual(search.suggestionsTableView.numberOfRows(inSection: 0), 1)
        let historyCell = try XCTUnwrap(search.suggestionsTableView.dataSource?.tableView(search.suggestionsTableView,
                                                                                          cellForRowAt: IndexPath(row: 0, section: 0)))
        XCTAssertEqual((historyCell.contentConfiguration as? UIListContentConfiguration)?.text, "Gf")
        XCTAssertEqual(historyCell.backgroundConfiguration?.backgroundColor, UIColor.systemBackground, "white rows, as in the GIF")
        search.clearSuggestionCache()
        XCTAssertEqual(search.suggestionsTableView.numberOfRows(inSection: 0), 0, "the text button clears the history")
        window.rootViewController?.dismiss(animated: false, completion: nil)
    }

    func testSearchBarDemoRow() throws {
        let menu = CYLSearchDemoMenuViewController(style: .grouped)
        let navigation = CYLSearchTestNavigationController(rootViewController: menu)
        menu.loadViewIfNeeded()
        let row = IndexPath(row: 2, section: 0)
        XCTAssertEqual(menu.tableView(menu.tableView, cellForRowAt: row).textLabel?.text, CYLSearchResources.localizedString(forKey: "demo.searchBar"))
        menu.tableView(menu.tableView, didSelectRowAt: row)
        let demo = try XCTUnwrap(navigation.lastPushedController)
        demo.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        demo.view.layoutIfNeeded()
        let foundBar = demo.view.subviews.compactMap { $0 as? CYLSearchBarView }.first
        let foundStatus = demo.view.subviews.compactMap { $0 as? UILabel }.first
        XCTAssertNotNil(foundBar)
        let bar = try XCTUnwrap(foundBar)
        let status = try XCTUnwrap(foundStatus)
        XCTAssertEqual(bar.placeholder, CYLSearchResources.localizedString(forKey: "demo.searchBar.placeholder"))
        XCTAssertFalse(bar.cancelButton.isHidden)
        let camera = bar.trailingAccessoryViews.first
        XCTAssertEqual(camera?.accessibilityLabel, CYLSearchResources.localizedString(forKey: "demo.searchBar.camera"))
        XCTAssertGreaterThan(bar.frame.width, 0)
        XCTAssertGreaterThanOrEqual(status.frame.minY, bar.frame.maxY)

        bar.text = "IDG"
        bar.textField.sendActions(for: .editingChanged)
        XCTAssertEqual(status.text, String(format: CYLSearchResources.localizedString(forKey: "demo.searchBar.text"), "IDG"))
        _ = bar.textField.delegate?.textFieldShouldReturn?(bar.textField)
        XCTAssertEqual(status.text, String(format: CYLSearchResources.localizedString(forKey: "demo.searchBar.searched"), "IDG"))
        bar.cancelButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(bar.text, "")

        let titles = ["en": "Search bar", "zh-Hans": "搜索栏", "zh-Hant": "搜尋列", "ja": "検索バー"]
        for (language, title) in titles {
            XCTAssertEqual(CYLSearchResources.localizedString(forKey: "demo.searchBar", language: language), title)
        }
    }

    func testTabBarComesFromTheConfigurationFile() throws {
        let root = CYLSearchExampleAppDelegate.rootViewController()
        XCTAssertTrue(root is CYLTabBarController, "CYLTabBarConfiguration.json is read")
        let tabBarController = try XCTUnwrap(root as? CYLTabBarController)
        tabBarController.loadViewIfNeeded()
        XCTAssertTrue(tabBarController.hasPlusButton())
        XCTAssertTrue(tabBarController.hasPlusChildViewController(), "the plus page ID resolves to a child")
        let pages = tabBarController.viewControllers ?? []
        // Search, Examples, the plus page, Tag style and Discover (docs/tag-view-suggestions.md).
        XCTAssertEqual(pages.count, 5)
        let roots: [UIViewController.Type] = [CYLSearchExampleViewController.self, CYLSearchBarDemoViewController.self, CYLSearchDemoMenuViewController.self]
        for rootClass in roots {
            let index = pages.firstIndex { page in
                guard let navigationPage = page as? UINavigationController,
                      let first = navigationPage.viewControllers.first else { return false }
                return first.isKind(of: rootClass)
            }
            XCTAssertNotNil(index, "\(rootClass) sits in a navigation controller")
        }
        // Loading a page does not rename its tab: the tab titles come from the file, page titles go to navigationItem.
        let fileTitles = pages.map { $0.tabBarItem.title }
        for page in pages {
            (page as? UINavigationController)?.viewControllers.first?.loadViewIfNeeded()
        }
        XCTAssertEqual(pages.map { $0.tabBarItem.title }, fileTitles)
        // VoiceOver reads the plus button by its title from the file.
        XCTAssertGreaterThan(cylExternPlusButton?.accessibilityLabel?.count ?? 0, 0)
        XCTAssertTrue((cylExternPlusButton?.isAccessibilityElement ?? false) || (cylExternPlusButton?.accessibilityLabel?.count ?? 0) > 0)
        // The titles are keys translated from CYLSearchTabs.bundle.
        let language: String? = Bundle.main.preferredLocalizations.first?.hasPrefix("zh") == true ? nil : "en"
        if language != nil {
            let titles = pages.map { $0.tabBarItem.title }
            XCTAssertTrue(titles.contains("Search"), "\(titles)")
            XCTAssertTrue(titles.contains("Examples"), "\(titles)")
            XCTAssertTrue(titles.contains("Tag style"), "\(titles)")
            XCTAssertTrue(titles.contains("Discover"), "\(titles)")
            XCTAssertEqual(cylExternPlusButton?.accessibilityLabel, "Search bar")
        }
        // Every language has exactly the keys of en (the tab titles, then the SVGA demo's texts), not a fixed count.
        let tablePath: (String) -> String? = { code in
            Bundle.main.path(forResource: "CYLSearchTabs", ofType: "strings", inDirectory: "CYLSearchTabs.bundle/\(code).lproj")
        }
        let english = tablePath("en").flatMap { NSDictionary(contentsOfFile: $0) }
        XCTAssertNotNil(english?["tab.search"])
        for code in ["en", "zh-Hans", "zh-Hant", "ja"] {
            let path = tablePath(code)
            let table = path.flatMap { NSDictionary(contentsOfFile: $0) }
            XCTAssertEqual((table?.allKeys).map { NSSet(array: $0) }, (english?.allKeys).map { NSSet(array: $0) }, "\(code) has every key")
        }
    }

    func testPlusButtonIsRaisedAboveTheTabBar() throws {
        // AGENTS.md, "Raised plus button": CYLTabBarConfiguration.json keeps the title on the button
        // (CYLPlusButtonAlignsTitle false), so CYLPlusButtonCenterYMultiplier lifts the 52 pt image above the bar.
        let tabBarController = try XCTUnwrap(CYLSearchExampleAppDelegate.rootViewController() as? CYLTabBarController)
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        tabBarController.tabBar.layoutIfNeeded()
        let externPlusButton: UIButton? = cylExternPlusButton
        let plusButton = try XCTUnwrap(externPlusButton)
        XCTAssertNotNil(plusButton.superview)
        let plusFrame = plusButton.convert(plusButton.bounds, to: tabBarController.tabBar)
        let barFrame = tabBarController.tabBar.bounds
        XCTAssertLessThan(plusFrame.minY, barFrame.minY, "the plus button rises above the tab bar: \(NSCoder.string(for: plusFrame)) in \(NSCoder.string(for: barFrame))")
        XCTAssertEqual(plusFrame.midX, barFrame.midX, accuracy: 1, "it stays in the middle")
        let imageSize = plusButton.currentImage?.size ?? .zero
        XCTAssertTrue(imageSize.equalTo(CGSize(width: 52, height: 52)), "the CYLPlusButton image: \(NSCoder.string(for: imageSize))")
        window.isHidden = true
    }

    func testSearchBarNeverCoversTheViewControllersView() {
        let source = CYLSearchExampleDataSource()
        let controller = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source)
        let navigation = UINavigationController(rootViewController: controller)
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        navigation.view.setNeedsLayout()
        navigation.view.layoutIfNeeded()
        let searchBar: UIView = controller.searchBar
        XCTAssertTrue(controller.navigationItem.titleView === searchBar, "the core field sits in the navigation bar")
        let searchBarFrame = searchBar.convert(searchBar.bounds, to: window)
        let viewFrame = controller.view.convert(controller.view.bounds, to: window)
        XCTAssertGreaterThanOrEqual(viewFrame.minY, navigation.navigationBar.frame.maxY - 0.5)
        XCTAssertNotNil(searchBar.window, "the search bar is shown")
        XCTAssertFalse(searchBarFrame.insetBy(dx: 0, dy: 0.5).intersects(viewFrame),
                       "\(NSCoder.string(for: searchBarFrame)) / \(NSCoder.string(for: viewFrame))")
        window.isHidden = true
    }

    func testSearchBarsCoverNoView() throws {
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let sizes: [UIContentSizeCategory] = [.large, .accessibilityExtraExtraExtraLarge]

        // The core search field in the results screen's navigation bar.
        let source = CYLSearchExampleDataSource()
        var results = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source)
        var navigation = UINavigationController(rootViewController: results)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        runLoop(0.3)
        navigation.view.setNeedsLayout()
        navigation.view.layoutIfNeeded()
        let resultsBar: UIView = results.searchBar
        XCTAssertNotNil(resultsBar.window, "the search bar is shown")
        let resultsCovered = viewsCoveredByView(resultsBar, nil)
        XCTAssertEqual(resultsCovered.count, 0, "results: \(resultsCovered)")

        // CYLSearchBarView on the search bar demo page, at the default and the largest text size.
        let demo = CYLSearchBarDemoViewController()
        navigation = UINavigationController(rootViewController: demo)
        window.rootViewController = navigation
        for size in sizes {
            if #available(iOS 17.0, *) {
                window.traitOverrides.preferredContentSizeCategory = size
            }
            runLoop(0.2)
            navigation.view.setNeedsLayout()
            navigation.view.layoutIfNeeded()
            let foundBar = demo.view.subviews.compactMap { $0 as? CYLSearchBarView }.first
            XCTAssertNotNil(foundBar?.window)
            let bar = try XCTUnwrap(foundBar)
            let covered = viewsCoveredByView(bar, nil)
            XCTAssertEqual(covered.count, 0, "demo at \(size.rawValue): \(covered)")
        }

        // The discover page (the "Discover" tab, copied from CollectionViewClassifyMenu): a second-level page whose
        // CYLSearchBarView sits in the navigation bar (`embedInNavigationBar`), and the lists start below that bar.
        let discover = CYLSearchDiscoverViewController()
        navigation = UINavigationController(rootViewController: UIViewController())
        navigation.pushViewController(discover, animated: false)
        window.rootViewController = navigation
        for size in sizes {
            if #available(iOS 17.0, *) {
                window.traitOverrides.preferredContentSizeCategory = size
            }
            runLoop(0.2)
            navigation.view.setNeedsLayout()
            navigation.view.layoutIfNeeded()
            XCTAssertTrue(discover.searchBar.isEmbeddedInNavigationBar)
            XCTAssertTrue(discover.navigationItem.titleView === discover.searchBar, "the bar is the title view of the navigation bar")
            let barBottom = navigation.navigationBar.convert(navigation.navigationBar.bounds, to: navigation.view).maxY
            let listTop = discover.recentList.convert(discover.recentList.bounds, to: navigation.view).minY
            XCTAssertGreaterThanOrEqual(listTop, barBottom - 0.5, "discover at \(size.rawValue): the lists start below the navigation bar")
        }
        if #available(iOS 17.0, *) {
            window.traitOverrides.preferredContentSizeCategory = .large
        }

        // The "Search bar styles" screen: a CYLSearchBar as the table header with Cancel and both accessory views shown, at
        // the default and the largest text size, at rest and while searching (the bar then lives in the search presentation,
        // so the presentation's view is the root of the check).
        let styles = CYLSearchBarStylesViewController(style: .grouped)
        navigation = UINavigationController(rootViewController: styles)
        window.rootViewController = navigation
        runLoop(0.2)
        let stylesBar = try XCTUnwrap(styles.searchBar)
        let stylesSearch = try XCTUnwrap(styles.searchController)
        stylesBar.showsCancelButton = true
        stylesBar.setShowsLeadingView(true, animated: false)
        stylesBar.setShowsTrailingAccessoryViews(true, animated: false)
        for editing in [false, true] {
            if editing {
                stylesSearch.setActive(true, animated: false)
                runLoop(0.5)
            }
            for size in sizes {
                if #available(iOS 17.0, *) {
                    window.traitOverrides.preferredContentSizeCategory = size
                }
                runLoop(0.3)
                navigation.view.setNeedsLayout()
                navigation.view.layoutIfNeeded()
                XCTAssertNotNil(stylesBar.window, "the styles screen's bar is shown")
                let covered = viewsCoveredByView(stylesBar, editing ? stylesSearch.activePageView : nil)
                XCTAssertEqual(covered.count, 0, "search bar styles, editing \(editing), at \(size.rawValue): \(covered)")
            }
        }
        stylesSearch.setActive(false, animated: false)
        if #available(iOS 17.0, *) {
            window.traitOverrides.preferredContentSizeCategory = .large
        }

        // The "Search controller" screen: the bar as the table header at rest, and while searching, when it lives in the
        // search presentation on top of the contents table (a full-screen scroll view that is not the bar's ancestor, so the
        // search view is the root there). Nothing in the presentation may sit under the bar: the launch view, the results
        // and the empty view all start at or below its bottom edge.
        let controllerDemo = CYLSearchControllerDemoViewController(style: .plain)
        navigation = UINavigationController(rootViewController: controllerDemo)
        window.rootViewController = navigation
        runLoop(0.3)
        let search = try XCTUnwrap(controllerDemo.cylSearchController)
        for active in [false, true] {
            if active {
                search.setActive(true, animated: false)
                runLoop(0.5)
            }
            for size in sizes {
                if #available(iOS 17.0, *) {
                    window.traitOverrides.preferredContentSizeCategory = size
                }
                runLoop(0.4)
                navigation.view.setNeedsLayout()
                navigation.view.layoutIfNeeded()
                XCTAssertNotNil(search.searchBar.window, "the search controller screen's bar is shown")
                let covered = viewsCoveredByView(search.searchBar, active ? search.activePageView : nil)
                XCTAssertEqual(covered.count, 0, "search controller, active \(active), at \(size.rawValue): \(covered)")
                if active {
                    let barBottom = search.searchBar.convert(search.searchBar.bounds, to: window).maxY
                    let launch = try XCTUnwrap(search.launchView)
                    XCTAssertGreaterThanOrEqual(launch.convert(launch.bounds, to: window).minY, barBottom - 0.5,
                                                "the launch view starts under the bar at \(size.rawValue)")
                }
            }
        }
        if #available(iOS 17.0, *) {
            window.traitOverrides.preferredContentSizeCategory = .large
        }
        for text in ["H", "zzz"] {
            search.searchBar.text = text
            runLoop(0.4)
            let barBottom = search.searchBar.convert(search.searchBar.bounds, to: window).maxY
            // The results table's frame spans the whole screen, as UIKit lays it out; its top inset keeps the rows (checked below)
            // and the empty view under the bar, so the table itself is left out.
            let results = search.searchResultsController.view!
            let covered = viewsCoveredByView(search.searchBar, search.activePageView).filter {
                !$0.hasPrefix("\(NSStringFromClass(type(of: results))) ")
            }
            XCTAssertEqual(covered.count, 0, "search controller with \"\(text)\": \(covered)")
            XCTAssertFalse(results.isHidden)
            if let empty = search.emptyView {
                XCTAssertGreaterThanOrEqual(empty.convert(empty.bounds, to: window).minY, barBottom - 0.5, "the empty view is under the bar")
            }
            if let table = search.tableView, let first = table.cellForRow(at: IndexPath(row: 0, section: 0)) {
                XCTAssertGreaterThanOrEqual(first.convert(first.bounds, to: window).minY, barBottom - 0.5, "the first result is under the bar")
            }
        }
        search.setActive(false, animated: false)

        // The issue scenario screens (docs/qmui-search-controller.md, rows I2 to I5 and the short list of I4): the bar at rest and
        // while searching, at both text sizes, then with results and with the empty view. The results table spans the whole
        // screen as UIKit lays it out, so it is left out of the cover check, like in the search controller screen above.
        func checkScenario(_ name: String, _ controller: UIViewController,
                           _ find: (UIViewController) -> CYLSearchController?) throws {
            let scenarioNavigation = UINavigationController(rootViewController: controller)
            window.rootViewController = scenarioNavigation
            runLoop(0.4)
            let scenarioSearch = try XCTUnwrap(find(controller), name)
            func covered(_ bar: UIView, active: Bool) -> [String] {
                let root: UIView? = active ? scenarioSearch.activePageView : nil
                let results = scenarioSearch.searchResultsController.view
                // A bar in the navigation bar is drawn over the presentation, whose full-screen backdrop (the dimming view and the
                // presentation's own view) reaches under the navigation bar by design: what is checked is that no content
                // (results, launch view, empty view) sits under the bar, below.
                let backdrop = bar.isDescendant(of: scenarioNavigation.navigationBar)
                    ? ["UIDimmingView ", "_UISearchControllerView "] : []
                return viewsCoveredByView(bar, root).filter { entry in
                    if backdrop.contains(where: { entry.hasPrefix($0) }) { return false }
                    guard let results else { return true }
                    return !entry.hasPrefix("\(NSStringFromClass(type(of: results))) ")
                }
            }
            for active in [false, true] {
                if active {
                    scenarioSearch.setActive(true, animated: false)
                    runLoop(0.5)
                }
                for size in sizes {
                    if #available(iOS 17.0, *) {
                        window.traitOverrides.preferredContentSizeCategory = size
                    }
                    runLoop(0.4)
                    scenarioNavigation.view.setNeedsLayout()
                    scenarioNavigation.view.layoutIfNeeded()
                    let bar: UIView = scenarioSearch.searchBar
                    XCTAssertNotNil(bar.window, "\(name): the bar is shown")
                    if !bar.isDescendant(of: scenarioNavigation.navigationBar) {
                        // Not in the navigation bar: it is under it, not over it.
                        XCTAssertGreaterThanOrEqual(bar.convert(bar.bounds, to: window).minY,
                                                    scenarioNavigation.navigationBar.frame.maxY - 0.5,
                                                    "\(name), active \(active), at \(size.rawValue): the bar is under the navigation bar")
                    }
                    let list = covered(bar, active: active)
                    XCTAssertEqual(list.count, 0, "\(name), active \(active), at \(size.rawValue): \(list)")
                }
            }
            if #available(iOS 17.0, *) {
                window.traitOverrides.preferredContentSizeCategory = .large
            }
            for text in ["1", "zzz"] {
                scenarioSearch.searchBar.text = text
                runLoop(0.4)
                let bar: UIView = scenarioSearch.searchBar
                let list = covered(bar, active: true)
                XCTAssertEqual(list.count, 0, "\(name) with \"\(text)\": \(list)")
                let barBottom = bar.convert(bar.bounds, to: window).maxY
                if let empty = scenarioSearch.emptyView {
                    XCTAssertGreaterThanOrEqual(empty.convert(empty.bounds, to: window).minY, barBottom - 0.5,
                                                "\(name): the empty view is under the bar")
                }
                if let table = scenarioSearch.tableView, let first = table.cellForRow(at: IndexPath(row: 0, section: 0)) {
                    XCTAssertGreaterThanOrEqual(first.convert(first.bounds, to: window).minY, barBottom - 0.5,
                                                "\(name): the first result is under the bar")
                }
            }
            scenarioSearch.setActive(false, animated: false)
            runLoop(0.3)
        }
        try checkScenario("navigation item", CYLSearchNavigationItemDemoViewController(style: .plain)) {
            ($0 as? CYLSearchNavigationItemDemoViewController)?.cylSearchController
        }
        try checkScenario("bar in a view", CYLSearchBarInViewDemoViewController()) {
            ($0 as? CYLSearchBarInViewDemoViewController)?.cylSearchController
        }
        try checkScenario("short list", CYLSearchShortListDemoViewController(style: .plain)) {
            ($0 as? CYLSearchShortListDemoViewController)?.searchController
        }
        try checkScenario("collection view", CYLSearchCollectionViewDemoViewController()) {
            ($0 as? CYLSearchCollectionViewDemoViewController)?.cylSearchController
        }

        // The overlay (a CYLSearchView over the results page's navigation controller) is a page of its own: inside that
        // page its search bar covers no view, with results shown.
        results = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source)
        navigation = UINavigationController(rootViewController: results)
        window.rootViewController = navigation
        runLoop(0.3)
        window.layoutIfNeeded()
        let overlay = results.overlaySearchView
        overlay.animationDuration = 0
        overlay.showSearch(in: navigation, animated: false)
        overlay.setQuery("1", submit: false)
        overlay.layoutIfNeeded()
        XCTAssertNotNil(overlay.searchBarView.window, "the overlay's search bar is shown")
        let overlayCovered = viewsCoveredByView(overlay.searchBarView, overlay)
        XCTAssertEqual(overlayCovered.count, 0, "overlay: \(overlayCovered)")
        overlay.closeSearch(animated: false)

        // A CYLSearchBarView in CYLSearchBarModeMultiple, with searches.
        let multi = CYLSearchBarView(frame: .zero)
        multi.mode = .multiple
        let multiHost = UIViewController()
        multiHost.edgesForExtendedLayout = []
        window.rootViewController = UINavigationController(rootViewController: multiHost)
        runLoop(0.3)
        multi.frame = CGRect(x: 8, y: 16, width: multiHost.view.bounds.width - 16, height: multi.intrinsicContentSize.height)
        multiHost.view.addSubview(multi)
        multi.addSearch("Rive")
        multi.addSearch("Lottie")
        multi.layoutIfNeeded()
        let multiCovered = viewsCoveredByView(multi, nil)
        XCTAssertEqual(multiCovered.count, 0, "multiple searches: \(multiCovered)")
        window.isHidden = true
    }
}

/**
 * Playback of a search bar item's animation (docs/animated-icon-component.md, board rows 41 and 42): loops, speed and
 * restart, read from the dictionaries the cross-platform bridges send.
 */
extension CYLSearchExampleSearchBarTests {

    @MainActor
    func testItemDictionaryReadsAnimationLoopsAndSpeedWithDefaults() {
        let plain = CYLSearchBarItem.item(dictionary: ["style": "icon", "title": "A"])
        let (plainLoops, plainSpeed) = (plain.animationLoops, plain.animationSpeed)
        XCTAssertFalse(plainLoops)
        XCTAssertEqual(plainSpeed, 1)

        let playing = CYLSearchBarItem.item(dictionary: [
            "style": "icon", "title": "A", "animationURL": "tab_activity.svga", "animationLoops": true, "animationSpeed": 0.5,
        ])
        let (loops, speed, file) = (playing.animationLoops, playing.animationSpeed, playing.animationURL?.lastPathComponent)
        XCTAssertTrue(loops)
        XCTAssertEqual(speed, 0.5)
        XCTAssertEqual(file, "tab_activity.svga")
        playing.restartAnimation()
        // An item without an animation ignores a restart.
        plain.restartAnimation()
    }

    @MainActor
    func testSetItemsKeepsTheItemsWhenOnlyLoopsAndSpeedChange() {
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 375, height: 48))
        let base: [String: Any] = ["style": "icon", "title": "A", "animationURL": "tab_activity.svga"]
        bar.setItems(dictionaries: [base])
        let first = bar.items.first
        let count = bar.items.count
        XCTAssertEqual(count, 1)

        var changed = base
        changed["animationLoops"] = true
        changed["animationSpeed"] = 2
        bar.setItems(dictionaries: [changed])
        let kept = bar.items.first === first
        let (keptLoops, keptSpeed) = (bar.items.first?.animationLoops, bar.items.first?.animationSpeed)
        XCTAssertTrue(kept, "only loops and speed changed: the item, and its loaded animation, stay")
        XCTAssertEqual(keptLoops, true)
        XCTAssertEqual(keptSpeed, 2)

        changed["title"] = "B"
        bar.setItems(dictionaries: [changed])
        let rebuilt = bar.items.first !== first
        let title = bar.items.first?.title
        XCTAssertTrue(rebuilt, "any other change rebuilds the items")
        XCTAssertEqual(title, "B")
    }

    /// A speed-only change does not reload the animation: the same animation view stays in the tag (docs row 42).
    @MainActor
    func testSpeedOnlyChangeKeepsTheLoadedAnimationView() throws {
        let url = try XCTUnwrap(CYLSearchDiscoverLocalization.resourceBundle?.url(forResource: "search_camera", withExtension: "json"))
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 375, height: 48))
        let item: [String: Any] = ["style": "icon", "title": "Camera", "animationURL": url.absoluteString]
        bar.setItems(dictionaries: [item])
        bar.layoutIfNeeded()
        let tag = bar.items.first?.itemView as? CYLTagButton
        let before = tag?.animationView
        try XCTSkipIf(before == nil, "no animation engine in this test build")

        var faster = item
        faster["animationSpeed"] = 2
        faster["animationLoops"] = true
        bar.setItems(dictionaries: [faster])
        bar.layoutIfNeeded()
        let sameTag = bar.items.first?.itemView === tag
        let after = tag?.animationView
        XCTAssertTrue(sameTag)
        XCTAssertTrue(after === before, "the animation view is the same instance: nothing was reloaded")

        // Back to speed 1 and no loop: still the same animation view (loops and speed alone never reload).
        bar.setItems(dictionaries: [item])
        bar.layoutIfNeeded()
        let sameTagAgain = bar.items.first?.itemView === tag
        let afterBack = tag?.animationView
        XCTAssertTrue(sameTagAgain)
        XCTAssertTrue(afterBack === before, "going back to speed 1 does not reload the animation either")
    }

    /// The item's speed reaches the drawn tag at once, also when only the speed changes (docs row 42).
    @MainActor
    func testItemSpeedReachesTheTagButtonAndFollowsChanges() {
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 375, height: 48))
        bar.setItems(dictionaries: [["style": "icon", "title": "A", "animationURL": "tab_activity.svga", "animationSpeed": 0.5]])
        bar.layoutIfNeeded()
        let tag = bar.items.first?.itemView as? CYLTagButton
        let first = tag?.animationSpeed
        XCTAssertNotNil(tag)
        XCTAssertEqual(first ?? -1, 0.5, accuracy: 0.001)

        bar.setItems(dictionaries: [["style": "icon", "title": "A", "animationURL": "tab_activity.svga", "animationSpeed": 2]])
        let sameTag = bar.items.first?.itemView === tag
        let second = tag?.animationSpeed
        XCTAssertTrue(sameTag, "a speed-only change keeps the tag")
        XCTAssertEqual(second ?? -1, 2, accuracy: 0.001)

        // The tag's style carries the item's speed too: going back to the style keeps it.
        tag?.resetAnimationSpeed()
        let afterReset = tag?.animationSpeed
        XCTAssertEqual(afterReset ?? -1, 2, accuracy: 0.001, "the style's speed is the item's, not 1")
    }

    /// A tag drawn with a tag list's style keeps that style's speed while the bar items next to it are set to speed 1:
    /// the items' speed lives in each item's own style, never in a shared one.
    @MainActor
    func testTagListStyleSpeedSurvivesBarItemsAtSpeedOne() {
        let listStyle = CYLMenuStyle()
        listStyle.animationSpeed = 3
        let listTag = CYLTagButton(frame: CGRect(x: 0, y: 0, width: 80, height: 44))
        listTag.style = listStyle
        let before = listTag.animationSpeed
        XCTAssertEqual(before, 3, accuracy: 0.001, "a tag follows its list style's speed")

        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 375, height: 48))
        bar.setItems(dictionaries: [["style": "icon", "title": "A", "animationURL": "tab_activity.svga", "animationSpeed": 1]])
        bar.layoutIfNeeded()
        let itemTag = bar.items.first?.itemView as? CYLTagButton
        let itemSpeed = itemTag?.animationSpeed
        XCTAssertEqual(itemSpeed ?? -1, 1, accuracy: 0.001)

        bar.setItems(dictionaries: [["style": "icon", "title": "A", "animationURL": "tab_activity.svga", "animationSpeed": 1, "animationLoops": true]])
        bar.layoutIfNeeded()
        let after = listTag.animationSpeed
        let styleSpeed = listTag.style.animationSpeed
        XCTAssertEqual(after, 3, accuracy: 0.001, "the bar items at speed 1 leave the list tag's speed alone")
        XCTAssertEqual(styleSpeed, 3, accuracy: 0.001, "and its list style's speed")
        XCTAssertEqual(listStyle.animationSpeed, 3, accuracy: 0.001, "the list's own style object is untouched")

        listTag.animationSpeed = 2
        listTag.resetAnimationSpeed()
        let reset = listTag.animationSpeed
        XCTAssertEqual(reset, 3, accuracy: 0.001, "resetting goes back to the list style's speed, not to 1")
    }

    /// The layout contract (docs/animated-icon-component.md, "Default layout contract"): an edge-to-edge bar's capsule
    /// lines up with the tag list's tags and section header below it, on both sides.
    @MainActor
    func testBarCapsuleLinesUpWithTheTagListInset() {
        let width: CGFloat = 390
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: width, height: 60))
        bar.layoutIfNeeded()
        let tagStyle = CYLMenuStyle()
        XCTAssertEqual(bar.fieldView.frame.minX, tagStyle.sectionInsets.left, accuracy: 0.5, "leading: capsule = first tag")
        XCTAssertEqual(bar.fieldView.frame.maxX, width - tagStyle.sectionInsets.right, accuracy: 0.5, "trailing: capsule = last tag")
        XCTAssertEqual(bar.fieldView.frame.minX, tagStyle.headerHorizontalInset, accuracy: 0.5, "leading: capsule = section title")
    }

    /// The refresh icon of a tag list's section header: an icon, a localized VoiceOver label, set as the More button's icon.
    @MainActor
    func testTagListHeaderRefreshIconIsAnIconWithALocalizedLabel() {
        XCTAssertNotNil(CYLSearchTagListHeader.refreshImage)
        let english = CYLSearchResources.localizedString(forKey: "tagList.refresh", language: "en")
        let chinese = CYLSearchResources.localizedString(forKey: "tagList.refresh", language: "zh-Hans")
        XCTAssertEqual(english, "Refresh")
        XCTAssertEqual(chinese, "刷新")
        XCTAssertFalse(CYLSearchTagListHeader.refreshAccessibilityLabel.isEmpty)
        let list = CYLTagListView()
        XCTAssertNil(list.style.moreButtonImage, "the default is the three dots")
        CYLSearchTagListHeader.applyRefreshIcon(to: list)
        XCTAssertNotNil(list.style.moreButtonImage)
    }

    /// The search bar core's default tag style is the iOS example's recent-searches look (capsule tags, light border,
    /// bold header, 16 pt inset); the corner radius and any other value can be customized.
    @MainActor
    func testDefaultTagStyleMatchesTheExampleRecentSearchesAndCanBeCustomized() {
        let core = CYLMenuStyle()
        CYLSearchTagListStyle.applyDefaults(to: core)
        let example = CYLSearchDiscoverViewController.recentStyle()
        let (coreTag, exampleTag) = (core.appearance(for: .normal), example.appearance(for: .normal))
        XCTAssertEqual(coreTag.cornerRadius, exampleTag.cornerRadius, "the corner radius: a capsule")
        XCTAssertEqual(coreTag.borderWidth, 1, "a flat tag has a light border")
        XCTAssertEqual(exampleTag.borderWidth, 0, "a glass tag has none")
        XCTAssertEqual(exampleTag.margin, CYLTagAppearance().margin, "the example leaves the inset unset: glass keeps 14 itself")
        XCTAssertEqual(coreTag.font, exampleTag.font)
        XCTAssertEqual(core.backgroundStyle, .flat, "the core's background is flat by default")
        XCTAssertEqual(example.backgroundStyle, .liquidGlass, "the example passes the one glass parameter")
        XCTAssertEqual(core.itemHeight, example.itemHeight)
        XCTAssertEqual(core.interitemSpacing, example.interitemSpacing)
        XCTAssertEqual(core.lineSpacing, example.lineSpacing)
        XCTAssertEqual(core.sectionInsets, example.sectionInsets)
        XCTAssertEqual(core.headerHeight, example.headerHeight)
        XCTAssertEqual(core.headerFont, example.headerFont)
        XCTAssertEqual(core.headerHorizontalInset, example.headerHorizontalInset)

        CYLSearchTagListStyle.tagCornerRadius = 8
        CYLSearchTagListStyle.tagBackgroundStyle = .liquidGlass
        CYLSearchTagListStyle.styleCustomizer = { $0.itemHeight = 44 }
        defer {
            CYLSearchTagListStyle.tagBackgroundStyle = .flat
            CYLSearchTagListStyle.tagCornerRadius = CYLAnimatedItemCornerRadiusCapsule
            CYLSearchTagListStyle.styleCustomizer = nil
        }
        let custom = CYLMenuStyle()
        CYLSearchTagListStyle.applyDefaults(to: custom)
        XCTAssertEqual(custom.appearance(for: .normal).cornerRadius, 8)
        XCTAssertEqual(custom.itemHeight, 44)
        XCTAssertEqual(custom.backgroundStyle, .liquidGlass, "the background style reaches CollectionViewClassifyMenu's style")

        let list = CYLTagListView()
        CYLSearchTagListStyle.applyDefaultStyle(to: list)
        XCTAssertEqual(list.style.appearance(for: .selected).cornerRadius, 8, "the list gets the defaults for every state")
        XCTAssertNotNil(list.style.moreButtonImage)
    }

    /// The discover data: whole pages, one hot topic per page in its own record, at a different slot on every refresh.
    @MainActor
    func testDiscoverRefreshShowsTheNextPageWithTheHotTopicMoving() throws {
        let bundle = try XCTUnwrap(CYLSearchDiscoverLocalization.stringsBundle)
        for language in ["en", "ja", "zh-Hans", "zh-Hant"] {
            let url = try XCTUnwrap(bundle.url(forResource: "search-discover", withExtension: "json", subdirectory: nil, localization: language))
            let data = try JSONDecoder().decode(CYLSearchDiscoverData.self, from: Data(contentsOf: url))
            XCTAssertGreaterThanOrEqual(data.pageCount, 2, language)
            XCTAssertEqual(data.discover.count % data.discoverCount, 0, "whole pages in \(language)")
            var page = 0
            var previousSlot: Int?
            for _ in 0 ..< 2 * data.pageCount {
                let hot = data.topics(onPage: page).enumerated().filter { $0.element.icon == "hot" }.map(\.offset)
                XCTAssertEqual(hot.count, 1, "one hot topic on page \(page) in \(language)")
                if let slot = hot.first {
                    XCTAssertNotEqual(slot, previousSlot, "the hot slot moves on every refresh in \(language)")
                    previousSlot = slot
                }
                page = data.nextPage(after: page)
            }
            XCTAssertEqual(page, 0, "the pages are cyclic")
        }

        let data = try CYLSearchDiscoverData.bundled()
        let controller = CYLSearchDiscoverViewController(data: data)
        controller.loadViewIfNeeded()
        XCTAssertEqual(controller.discoverSource.topics, data.topics(onPage: 0))
        controller.refreshDiscover()
        XCTAssertEqual(controller.discoverSource.topics, data.topics(onPage: 1), "refresh shows the next page")
        XCTAssertNotNil(controller.discoverList.style.moreButtonImage, "the refresh icon, not the three dots")
    }

    /// The navigation bar always exists: without a navigation controller the core creates one (part C of the contract).
    @MainActor
    func testEmbedInNavigationBarCreatesTheBarWhenTheViewControllerHasNone() {
        let controller = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        let bar = CYLSearchBarView()
        let navigationBar = bar.embedInNavigationBar(of: controller)
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        controller.view.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            content.heightAnchor.constraint(equalToConstant: 100),
        ])
        runLoop(0.3)
        controller.view.layoutIfNeeded()
        navigationBar.layoutIfNeeded()
        XCTAssertTrue(navigationBar is CYLSearchNavigationBar)
        XCTAssertTrue(navigationBar.superview === controller.view)
        XCTAssertTrue(navigationBar.topItem?.titleView === bar)
        XCTAssertTrue(bar.isEmbeddedInNavigationBar)
        XCTAssertEqual(navigationBar.frame.height, CYLSearchNavigationBar.standardHeight, accuracy: 0.5)
        XCTAssertGreaterThanOrEqual(content.frame.minY, navigationBar.frame.maxY - 0.5, "content never sits under the bar")
        XCTAssertEqual(controller.additionalSafeAreaInsets.top, CYLSearchNavigationBar.standardHeight, "content under the safe area guide starts below the bar")
        window.isHidden = true
    }

    /// With a navigation controller the bar becomes the title view of its navigation bar.
    @MainActor
    func testEmbedInNavigationBarUsesTheNavigationControllersBar() {
        let controller = UIViewController()
        let navigation = UINavigationController(rootViewController: controller)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        let bar = CYLSearchBarView()
        let navigationBar = bar.embedInNavigationBar(of: controller)
        runLoop(0.3)
        navigation.view.layoutIfNeeded()
        navigationBar.layoutIfNeeded()
        XCTAssertTrue(navigationBar === navigation.navigationBar)
        XCTAssertTrue(controller.navigationItem.titleView === bar)
        XCTAssertTrue(bar.isEmbeddedInNavigationBar)
        XCTAssertEqual(bar.intrinsicContentSize.width, UIView.layoutFittingExpandedSize.width, "the title view asks for the whole width")
        XCTAssertEqual(bar.fieldHeight, 36)
        window.isHidden = true
    }

    /// The core's navigation bar can show the back button of a second-level page and reports its tap to the host.
    @MainActor
    func testNavigationBarHoldingTheBarCanShowABackButton() {
        let plain = CYLSearchNavigationBar.holding(CYLSearchBarView())
        XCTAssertEqual(plain.items?.count, 1, "no back button by default")
        let bar = CYLSearchBarView()
        let navigationBar = CYLSearchNavigationBar.holding(bar, showsBackButton: true)
        XCTAssertEqual(navigationBar.items?.count, 2, "a root item below the item of the search bar: the back button")
        XCTAssertTrue(navigationBar.topItem?.titleView === bar)
        XCTAssertEqual(navigationBar.items?.first?.title, CYLSearchResources.localizedString(forKey: "navigationBar.back", language: nil))
        var taps = 0
        navigationBar.backHandler = { taps += 1 }
        let popped = navigationBar.navigationBar(navigationBar, shouldPop: navigationBar.topItem ?? UINavigationItem())
        XCTAssertFalse(popped, "the bar never pops, the host decides")
        XCTAssertEqual(taps, 1)
        XCTAssertEqual(CYLSearchResources.localizedString(forKey: "navigationBar.back", language: "zh-Hans"), "返回")
    }

    /// The adaptive width is the core's job: an embedded bar asks the navigation bar for the whole width (UIKit then gives it
    /// what is left beside a back button), a plain bar keeps the width it is offered; no example sets a width.
    @MainActor
    func testEmbeddedBarAsksForTheWholeWidthAndAPlainBarKeepsItsOwn() {
        let plain = CYLSearchBarView()
        XCTAssertEqual(plain.sizeThatFits(CGSize(width: 320, height: 100)).width, 320)
        XCTAssertEqual(plain.intrinsicContentSize.width, UIView.noIntrinsicMetric)
        let navigationBar = CYLSearchNavigationBar.holding(plain, showsBackButton: true)
        XCTAssertNotNil(navigationBar.topItem)
        XCTAssertEqual(plain.sizeThatFits(.zero).width, UIView.layoutFittingExpandedSize.width, "a navigation bar first asks with a zero width")
        XCTAssertEqual(plain.sizeThatFits(CGSize(width: 320, height: 100)).width, UIView.layoutFittingExpandedSize.width)
        XCTAssertEqual(plain.intrinsicContentSize.width, UIView.layoutFittingExpandedSize.width)
        XCTAssertEqual(plain.intrinsicContentSize.height, 44, accuracy: 0.5, "the field and its insets fit the 44 pt navigation bar")
    }

    // MARK: - Focus on appear

    /// `focusesOnAppear`: only a bar on a second-level or deeper page takes focus (its page is not the first view controller of its
    /// navigation controller), when it is on screen and every time it reappears (a push and pop remove its view from the window); a
    /// first-level page never focuses; nothing happens while the option is
    /// off. The moments come from CYLDeallocBlockExecutor's `didEnterScreen`.
    @MainActor
    func testFocusesOnAppearEveryTimeTheBarReappears() {
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let root = UIViewController()
        let navigation = UINavigationController(rootViewController: root)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        // A first-level page: the option does nothing.
        let rootBar = CYLSearchBarView()
        rootBar.embedInNavigationBar(of: root)
        runLoop(0.3)
        rootBar.focusesOnAppear = true
        runLoop(0.4)
        XCTAssertFalse(rootBar.isOnSecondLevelOrDeeperPage)
        XCTAssertFalse(rootBar.textField.isFirstResponder, "a first-level page never focuses")
        // A second-level page: the bar focuses on entering and again when the page reappears.
        let page = UIViewController()
        let bar = CYLSearchBarView()
        navigation.pushViewController(page, animated: false)
        bar.embedInNavigationBar(of: page)
        bar.focusesOnAppear = true
        runLoop(0.6)
        XCTAssertTrue(bar.isOnSecondLevelOrDeeperPage)
        XCTAssertTrue(bar.textField.isFirstResponder, "a pushed page focuses on entering")
        // A bar that is a plain subview of a second-level page is on that level too; one on the root page is not.
        let plain = CYLSearchBarView(frame: CGRect(x: 0, y: 200, width: 402, height: 44))
        page.view.addSubview(plain)
        XCTAssertTrue(plain.isOnSecondLevelOrDeeperPage)
        let rootPlain = CYLSearchBarView(frame: CGRect(x: 0, y: 200, width: 402, height: 44))
        root.view.addSubview(rootPlain)
        XCTAssertFalse(rootPlain.isOnSecondLevelOrDeeperPage)
        let another = UIViewController()
        navigation.pushViewController(another, animated: false)
        runLoop(0.6)
        bar.textField.resignFirstResponder()
        navigation.popViewController(animated: false)
        runLoop(0.6)
        XCTAssertTrue(bar.textField.isFirstResponder, "reappears: focus again")
        bar.focusesOnAppear = false
        bar.textField.resignFirstResponder()
        navigation.pushViewController(UIViewController(), animated: false)
        runLoop(0.4)
        navigation.popViewController(animated: false)
        runLoop(0.6)
        XCTAssertFalse(bar.textField.isFirstResponder, "option off: no focus")
        window.isHidden = true
    }

    // MARK: - Default search button

    private final class SearchButtonRecorder: NSObject, CYLSearchBarViewDelegate {
        var clicks = 0
        func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView) { clicks += 1 }
    }

    /// Every bar has the core's default search button: the icon style by default (the built-in magnifier in a filled capsule, or the
    /// caller's icon), a localized title on request, a custom title, hidden on request; an editing bar has none; a tap tells the delegate also for empty text.
    @MainActor
    func testDefaultSearchButton() throws {
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 390, height: 56))
        XCTAssertTrue(bar.showsSearchButton)
        XCTAssertEqual(bar.searchButtonStyle, .icon, "the icon style is the default")
        XCTAssertEqual(bar.searchButtonItem.style, .icon)
        XCTAssertEqual(bar.searchButtonItem.title, CYLSearchResources.localizedString(forKey: "search.button"), "the title is the accessibility label")
        XCTAssertFalse(bar.itemStack.isHidden, "the default button is shown")
        XCTAssertTrue(bar.items.isEmpty, "the built-in button is not one of the owner's items")
        for language in ["en", "zh-Hans", "zh-Hant", "ja"] {
            XCTAssertNotEqual(CYLSearchResources.localizedString(forKey: "search.button", language: language), "search.button")
        }
        let recorder = SearchButtonRecorder()
        bar.delegate = recorder
        bar.searchButtonItem.itemControl.sendActions(for: .touchUpInside)
        XCTAssertEqual(recorder.clicks, 1, "tapped with empty text: the delegate hears it")
        bar.text = "swift"
        bar.searchButtonItem.itemControl.sendActions(for: .touchUpInside)
        XCTAssertEqual(recorder.clicks, 2, "tapped with text: submitted")
        var custom = 0
        bar.searchButtonHandler = { _ in custom += 1 }
        bar.searchButtonItem.itemControl.sendActions(for: .touchUpInside)
        XCTAssertEqual(custom, 1)
        XCTAssertEqual(recorder.clicks, 2, "a handler replaces the default action")
        bar.searchButtonItem.itemAccessibilityIdentifier = "mine"
        bar.searchButtonStyle = .text
        XCTAssertEqual(bar.searchButtonItem.style, .text)
        XCTAssertNil(bar.searchButtonItem.backgroundColor, "the text style has no fill")
        bar.searchButtonStyle = .icon
        XCTAssertEqual(bar.searchButtonItem.style, .icon)
        XCTAssertNotNil(bar.searchButtonItem.image, "the built-in magnifier")
        // The icon style is a filled capsule with the icon in the inverse color: one item view with its own background and corner.
        XCTAssertEqual(bar.searchButtonItem.backgroundColor, .label)
        XCTAssertEqual(bar.searchButtonItem.tintColor, .systemBackground)
        XCTAssertEqual(bar.searchButtonItem.cornerRadius, CYLAnimatedItemCornerRadiusCapsule)
        XCTAssertGreaterThan(bar.searchButtonItem.itemHeight, 0)
        XCTAssertEqual(bar.searchButtonItem.itemAccessibilityIdentifier, "mine", "kept when the item is replaced")
        let image = UIImage(systemName: "arrow.right")
        bar.searchButtonImage = image
        XCTAssertTrue(bar.searchButtonItem.image === image, "a custom icon")
        bar.searchButtonStyle = .text
        bar.searchButtonTitle = "Go"
        XCTAssertEqual(bar.searchButtonItem.title, "Go", "a custom title")
        bar.showsSearchButton = false
        XCTAssertTrue(bar.itemStack.isHidden)
        let editing = CYLSearchBarView.editingBar(placeholder: nil, actionTitle: "Add")
        XCTAssertTrue(editing.itemStack.isHidden, "an editing bar has its own action button")
    }

    /// The divider has the same VISIBLE gap on both sides: the plain icon hugs its glyph, so the stack view's spacing is the gap
    /// between the glyph and the divider and between the divider and the capsule button; the touch area still has the 36 pt minimum.
    @MainActor
    func testDividerGapsAreEven() throws {
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 390, height: 44))
        bar.fieldHeight = 36
        bar.searchBarStyle = .bordered
        let camera = CYLSearchBarItem.iconItem(image: UIImage(systemName: "camera.viewfinder"), title: "Camera", handler: nil)
        camera.imageSize = CGSize(width: 22, height: 22)
        bar.addItem(camera)
        bar.layoutIfNeeded()
        let divider = try XCTUnwrap(bar.itemStack.dividerViews.first)
        let dividerFrame = bar.fieldView.convert(divider.bounds, from: divider)
        let cameraFrame = bar.fieldView.convert(camera.itemView.bounds, from: camera.itemView)
        let pill = bar.fieldView.convert(bar.searchButtonItem.itemView.bounds, from: bar.searchButtonItem.itemView)
        let left = dividerFrame.minX - cameraFrame.maxX
        let right = pill.minX - dividerFrame.maxX
        XCTAssertEqual(left, right, accuracy: 0.5, "the gaps beside the divider are equal: \(left) / \(right)")
        XCTAssertGreaterThan(left, 4)
        XCTAssertEqual(cameraFrame.width, 22, accuracy: 1, "the plain icon hugs its glyph")
        // The touch area is still 36 pt wide.
        let center = CGPoint(x: camera.itemView.bounds.midX, y: camera.itemView.bounds.midY)
        XCTAssertTrue(camera.itemView.point(inside: CGPoint(x: center.x - 17, y: center.y), with: nil))
        XCTAssertFalse(camera.itemView.point(inside: CGPoint(x: center.x - 19, y: center.y), with: nil))
        // The camera is the first item of its row: a real touch 6 pt left of the glyph still reaches it through the row.
        let leftOfGlyph = bar.convert(CGPoint(x: camera.itemView.convert(CGPoint(x: -6, y: center.y), to: bar).x,
                                             y: camera.itemView.convert(center, to: bar).y), to: bar)
        XCTAssertTrue(bar.hitTest(leftOfGlyph, with: nil) === camera.itemView, "the left of the first item is hittable")
        // The field takes everything the right-hand group leaves.
        XCTAssertEqual(bar.textField.frame.maxX + 0, bar.itemStack.frame.minX - 8, accuracy: 1.5, "the text field ends where the group begins")
    }

    /// A first-level bar (`pushesOnTap`): a tap on the field runs `onFirstLevelTap` and never edits, so no keyboard comes up.
    @MainActor
    func testFirstLevelBarPushesOnTapAndNeverEdits() {
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 100, width: 402, height: 44))
        host.view.addSubview(bar)
        var taps = 0
        bar.onFirstLevelTap = { _ in taps += 1 }
        XCTAssertFalse(bar.pushesOnTap, "off by default")
        XCTAssertTrue(bar.textField.delegate?.textFieldShouldBeginEditing?(bar.textField) ?? false, "editable by default")
        bar.pushesOnTap = true
        XCTAssertTrue(bar.textField.accessibilityTraits.contains(.button), "VoiceOver reads the field as a button")
        XCTAssertEqual(bar.textField.delegate?.textFieldShouldBeginEditing?(bar.textField), false, "the tap does not edit")
        XCTAssertEqual(taps, 1)
        bar.textField.becomeFirstResponder()
        XCTAssertFalse(bar.textField.isFirstResponder, "no keyboard on the first level")
        XCTAssertEqual(taps, 2, "asking for focus is a tap too")
        bar.performFirstLevelTap()
        XCTAssertEqual(taps, 3)
        window.isHidden = true
    }

    /// The five looks of the core, each replacing the one before; the back button API toggles the bar's own arrow.
    @MainActor
    func testPresetsAndTheBackButtonAPI() {
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 390, height: 44))
        bar.applyPreset(.navigationField)
        XCTAssertEqual(bar.searchBarStyle, .bordered)
        XCTAssertEqual(bar.fieldCornerRadius, 18)
        XCTAssertNil(bar.searchIcon)
        bar.applyPreset(.pill)
        XCTAssertEqual(bar.searchBarStyle, .plain)
        XCTAssertEqual(bar.fieldCornerRadius, -1, "a capsule")
        XCTAssertNotNil(bar.searchIcon, "a magnifier")
        XCTAssertNil(bar.fieldBorderColor, "no outline: the earlier preset is replaced")
        bar.applyPreset(.rounded)
        XCTAssertEqual(bar.fieldCornerRadius, 10)
        XCTAssertEqual(bar.searchBarStyle, .plain)
        bar.applyPreset(.outlined)
        XCTAssertEqual(bar.searchBarStyle, .bordered)
        XCTAssertEqual(bar.fieldCornerRadius, 8)
        XCTAssertNotNil(bar.fieldBorderColor)
        bar.applyPreset(.centeredCapsule)
        XCTAssertEqual(bar.searchBarStyle, .bordered)
        XCTAssertEqual(bar.fieldCornerRadius, -1)
        XCTAssertTrue(bar.centersPlaceholder)
        XCTAssertGreaterThan(bar.fieldShadowOpacity, 0)
        bar.applyPreset(.pill)
        XCTAssertFalse(bar.centersPlaceholder, "centered placeholder replaced")
        XCTAssertEqual(bar.fieldShadowOpacity, 0)

        XCTAssertFalse(bar.isBackButtonShown)
        XCTAssertEqual(bar.backButtonProgress, 0)
        bar.showBackButton(animated: false)
        XCTAssertTrue(bar.isBackButtonShown)
        XCTAssertEqual(bar.backButtonProgress, 1)
        bar.hideBackButton(animated: false)
        XCTAssertFalse(bar.isBackButtonShown)
        bar.backButtonProgress = 1
        XCTAssertTrue(bar.isBackButtonShown)
    }

    /// The example's first-level pages: a tab root's bar pushes the second-level page, whose bar sits on a second-level page and
    /// focuses itself.
    @MainActor
    func testFirstLevelPageInstallsAPushingBar() throws {
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let root = UIViewController()
        let navigation = UINavigationController(rootViewController: root)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        let bar = root.cylInstallFirstLevelSearchBar(preset: .rounded, placeholder: "Search examples")
        runLoop(0.3)
        XCTAssertTrue(bar.pushesOnTap)
        XCTAssertTrue(root.navigationItem.titleView === bar, "the whole bar sits in the navigation bar")
        XCTAssertFalse(bar.isOnSecondLevelOrDeeperPage)
        bar.performFirstLevelTap()
        runLoop(0.8)
        XCTAssertEqual(navigation.viewControllers.count, 2, "the tap pushed the second-level page")
        let second = try XCTUnwrap(navigation.topViewController as? CYLSearchSecondLevelViewController)
        let secondBar = try XCTUnwrap(second.navigationItem.titleView as? CYLSearchBarView)
        XCTAssertTrue(secondBar.isOnSecondLevelOrDeeperPage)
        XCTAssertTrue(secondBar.textField.isFirstResponder, "the second-level bar focuses itself")
        XCTAssertFalse(secondBar.pushesOnTap)
        navigation.popViewController(animated: false)
        runLoop(0.4)
        XCTAssertFalse(bar.textField.isFirstResponder, "the first-level bar never took focus")
        window.isHidden = true
    }

    /// The default search button tapped with empty text submits nothing and closes nothing in a search page (as the Search key).
    @MainActor
    func testDefaultSearchButtonWithEmptyTextDoesNothingInASearchView() {
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        let search = CYLSearchView(frame: host.view.bounds)
        search.animationDuration = 0
        search.showSearch(in: host, animated: false)
        runLoop(0.3)
        let recorder = SearchViewSubmitRecorder()
        search.delegate = recorder
        search.searchBarView.searchButtonItem.itemControl.sendActions(for: .touchUpInside)
        XCTAssertEqual(recorder.submitted, [], "empty text: nothing submitted")
        XCTAssertTrue(search.searchOpen, "empty text: the page stays open")
        search.setQuery("swift", submit: false)
        search.searchBarView.searchButtonItem.itemControl.sendActions(for: .touchUpInside)
        XCTAssertEqual(recorder.submitted, ["swift"], "text: submitted")
        window.isHidden = true
    }

    private final class SearchViewSubmitRecorder: NSObject, CYLSearchViewDelegate {
        var submitted: [String] = []
        func searchView(_ searchView: CYLSearchView, didSubmitText text: String) -> Bool {
            submitted.append(text)
            return true
        }
    }

    /// The icon button is a capsule inside the field's capsule with the same gap above, below and at its right (the reference look).
    @MainActor
    func testIconSearchButtonHasAnEqualGapOnThreeSides() {
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 390, height: 44))
        bar.fieldHeight = 36
        bar.searchBarStyle = .bordered
        bar.searchButtonStyle = .icon
        bar.layoutIfNeeded()
        let pill = bar.fieldView.convert(bar.searchButtonItem.itemView.bounds, from: bar.searchButtonItem.itemView)
        let field = bar.fieldView.bounds
        let top = pill.minY
        let bottom = field.maxY - pill.maxY
        let right = field.maxX - pill.maxX
        XCTAssertEqual(pill.height, 28, accuracy: 0.5, "the capsule is smaller than the field")
        XCTAssertEqual(top, bottom, accuracy: 0.5, "same gap above and below")
        XCTAssertEqual(right, top, accuracy: 0.5, "same gap at the right")
        XCTAssertGreaterThan(top, 0)
    }

    /// The keyboard has the search key, and a bar in editing mode hides the keyboard for an outside touch (observed only while
    /// editing; the touch itself comes from CYLDeallocBlockExecutor's `didTouchOutside`, which XCTest cannot create).
    @MainActor
    func testSearchKeyAndOutsideTouchHidesTheKeyboard() {
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 100, width: 402, height: 56))
        host.view.addSubview(bar)
        XCTAssertEqual(bar.returnKeyType, .search)
        XCTAssertTrue(bar.dismissesKeyboardOnOutsideTouch)
        XCTAssertFalse(bar.cylCancelLifecycleCallback(key: "CYLSearchBarViewOutsideTouch"), "nothing observed while the keyboard is down")
        bar.showKeyboard()
        runLoop(0.3)
        XCTAssertTrue(bar.textField.isFirstResponder)
        bar.hideKeyboardForOutsideTouch()
        XCTAssertFalse(bar.textField.isFirstResponder, "an outside touch hides the keyboard")
        runLoop(0.2)
        XCTAssertFalse(bar.cylCancelLifecycleCallback(key: "CYLSearchBarViewOutsideTouch"), "no longer observed after editing ended")
        bar.showKeyboard()
        runLoop(0.3)
        XCTAssertTrue(bar.cylCancelLifecycleCallback(key: "CYLSearchBarViewOutsideTouch"), "observed while editing")
        bar.dismissesKeyboardOnOutsideTouch = false
        bar.hideKeyboardForOutsideTouch()
        XCTAssertTrue(bar.textField.isFirstResponder, "option off: the keyboard stays")
        let editing = CYLSearchBarView.editingBar(placeholder: nil, actionTitle: "Add")
        host.view.addSubview(editing)
        editing.showKeyboard()
        runLoop(0.3)
        XCTAssertFalse(editing.cylCancelLifecycleCallback(key: "CYLSearchBarViewOutsideTouch"), "an editing bar drives its own focus")
        window.isHidden = true
    }

}
