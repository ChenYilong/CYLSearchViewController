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
        XCTAssertGreaterThan(CYLExternPlusButton?.accessibilityLabel?.count ?? 0, 0)
        XCTAssertTrue((CYLExternPlusButton?.isAccessibilityElement ?? false) || (CYLExternPlusButton?.accessibilityLabel?.count ?? 0) > 0)
        // The titles are keys translated from CYLSearchTabs.bundle.
        let language: String? = Bundle.main.preferredLocalizations.first?.hasPrefix("zh") == true ? nil : "en"
        if language != nil {
            let titles = pages.map { $0.tabBarItem.title }
            XCTAssertTrue(titles.contains("Search"), "\(titles)")
            XCTAssertTrue(titles.contains("Examples"), "\(titles)")
            XCTAssertTrue(titles.contains("Tag style"), "\(titles)")
            XCTAssertTrue(titles.contains("Discover"), "\(titles)")
            XCTAssertEqual(CYLExternPlusButton?.accessibilityLabel, "Search bar")
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
        let externPlusButton: UIButton? = CYLExternPlusButton
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
        for hides in [false, true] {
            controller.navigationItem.hidesSearchBarWhenScrolling = hides
            navigation.view.setNeedsLayout()
            navigation.view.layoutIfNeeded()
            let searchBar = visibleSearchView(controller.searchController.searchBar)
            let searchBarFrame = searchBar.convert(searchBar.bounds, to: window)
            let viewFrame = controller.view.convert(controller.view.bounds, to: window)
            XCTAssertGreaterThanOrEqual(viewFrame.minY, navigation.navigationBar.frame.maxY - 0.5, "hides \(hides)")
            if !hides { XCTAssertNotNil(searchBar.window, "the pinned search bar is shown") }
            if !searchBar.isHidden && searchBar.window != nil && searchBarFrame.height > 0 {
                XCTAssertFalse(searchBarFrame.insetBy(dx: 0, dy: 0.5).intersects(viewFrame),
                               "hides \(hides): \(NSCoder.string(for: searchBarFrame)) / \(NSCoder.string(for: viewFrame))")
            }
        }
        window.isHidden = true
    }

    func testSearchBarsCoverNoView() throws {
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let sizes: [UIContentSizeCategory] = [.large, .accessibilityExtraExtraExtraLarge]

        // The navigation-item search bar of the results screen, with the bar pinned and hiding on scroll.
        let source = CYLSearchExampleDataSource()
        var results = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source)
        var navigation = UINavigationController(rootViewController: results)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        for hides in [false, true] {
            results.navigationItem.hidesSearchBarWhenScrolling = hides
            runLoop(0.3)
            navigation.view.setNeedsLayout()
            navigation.view.layoutIfNeeded()
            let searchBar = visibleSearchView(results.searchController.searchBar)
            if !hides { XCTAssertNotNil(searchBar.window, "the pinned search bar is shown") }
            if searchBar.window != nil && !searchBar.isHidden {
                let covered = viewsCoveredByView(searchBar, nil)
                XCTAssertEqual(covered.count, 0, "results, hides \(hides): \(covered)")
            }
        }

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
        stylesBar.setShowsLeadingAccessoryView(true, animated: false)
        stylesBar.setShowsTrailingAccessoryView(true, animated: false)
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
                let covered = viewsCoveredByView(stylesBar, editing ? stylesSearch.searchController.view : nil)
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
                let covered = viewsCoveredByView(search.searchBar, active ? search.searchController.view : nil)
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
            let results = try XCTUnwrap(search.searchResultsController?.view)
            let covered = viewsCoveredByView(search.searchBar, search.searchController.view).filter {
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
                let root: UIView? = active && bar.isDescendant(of: scenarioSearch.searchController.view)
                    ? scenarioSearch.searchController.view : nil
                let results = scenarioSearch.searchResultsController?.view
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
                    let bar = visibleSearchView(scenarioSearch.searchBar)
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
                let bar = visibleSearchView(scenarioSearch.searchBar)
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
        XCTAssertEqual(coreTag.borderWidth, exampleTag.borderWidth)
        XCTAssertEqual(coreTag.margin, exampleTag.margin)
        XCTAssertEqual(coreTag.font, exampleTag.font)
        XCTAssertEqual(core.itemHeight, example.itemHeight)
        XCTAssertEqual(core.interitemSpacing, example.interitemSpacing)
        XCTAssertEqual(core.lineSpacing, example.lineSpacing)
        XCTAssertEqual(core.sectionInsets, example.sectionInsets)
        XCTAssertEqual(core.headerHeight, example.headerHeight)
        XCTAssertEqual(core.headerFont, example.headerFont)
        XCTAssertEqual(core.headerHorizontalInset, example.headerHorizontalInset)

        CYLSearchTagListStyle.tagCornerRadius = 8
        CYLSearchTagListStyle.styleCustomizer = { $0.itemHeight = 44 }
        defer {
            CYLSearchTagListStyle.tagCornerRadius = CYLSearchTagListStyle.capsuleCornerRadius
            CYLSearchTagListStyle.styleCustomizer = nil
        }
        let custom = CYLMenuStyle()
        CYLSearchTagListStyle.applyDefaults(to: custom)
        XCTAssertEqual(custom.appearance(for: .normal).cornerRadius, 8)
        XCTAssertEqual(custom.itemHeight, 44)

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
}
