//
//  CYLSearchExampleSearchBarTests.swift
//  CYLSearchExampleTests
//
//  The search bar view, demo row, tab bar, plus button and search-bar-cover tests (translated from
//  CYLSearchExampleTests.m, docs/swift-migration.md, step 4).
//

import CYLAnimatedItem
import CYLSearchViewController
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
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        demo.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        demo.view.layoutIfNeeded()
        let cover = CYLViewWithAccessibilityIdentifier(demo.view, "CYLOriginalDemoSearchField") as? UIButton
        XCTAssertNotNil(cover, "the field that opens the search")
        cover?.sendActions(for: .touchUpInside)
        CYLRunLoop(0.5)
        let search = try XCTUnwrap(CYLViewOfClass(window, CYLSearchView.self), "the core's search page opened")
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
        let header = search.resultsTableView.tableHeaderView as? UILabel
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
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
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
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        for hides in [false, true] {
            controller.navigationItem.hidesSearchBarWhenScrolling = hides
            navigation.view.setNeedsLayout()
            navigation.view.layoutIfNeeded()
            let searchBar = CYLVisibleSearchView(controller.searchController.searchBar)
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
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let sizes: [UIContentSizeCategory] = [.large, .accessibilityExtraExtraExtraLarge]

        // The navigation-item search bar of the results screen, with the bar pinned and hiding on scroll.
        let source = CYLSearchExampleDataSource()
        var results = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source)
        var navigation = UINavigationController(rootViewController: results)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        for hides in [false, true] {
            results.navigationItem.hidesSearchBarWhenScrolling = hides
            CYLRunLoop(0.3)
            navigation.view.setNeedsLayout()
            navigation.view.layoutIfNeeded()
            let searchBar = CYLVisibleSearchView(results.searchController.searchBar)
            if !hides { XCTAssertNotNil(searchBar.window, "the pinned search bar is shown") }
            if searchBar.window != nil && !searchBar.isHidden {
                let covered = CYLViewsCoveredByView(searchBar, nil)
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
            CYLRunLoop(0.2)
            navigation.view.setNeedsLayout()
            navigation.view.layoutIfNeeded()
            let foundBar = demo.view.subviews.compactMap { $0 as? CYLSearchBarView }.first
            XCTAssertNotNil(foundBar?.window)
            let bar = try XCTUnwrap(foundBar)
            let covered = CYLViewsCoveredByView(bar, nil)
            XCTAssertEqual(covered.count, 0, "demo at \(size.rawValue): \(covered)")
        }

        // CYLSearchBarView of the discover page (the "Discover" tab, copied from CollectionViewClassifyMenu), which draws
        // it in place of the navigation bar.
        let discover = CYLSuggestionDemoPages.discoverViewController()
        navigation = UINavigationController(rootViewController: discover)
        window.rootViewController = navigation
        for size in sizes {
            if #available(iOS 17.0, *) {
                window.traitOverrides.preferredContentSizeCategory = size
            }
            CYLRunLoop(0.2)
            navigation.view.setNeedsLayout()
            navigation.view.layoutIfNeeded()
            let foundBar = discover.view.subviews.compactMap { $0 as? CYLSearchBarView }.first
            XCTAssertNotNil(foundBar?.window)
            let bar = try XCTUnwrap(foundBar)
            let covered = CYLViewsCoveredByView(bar, nil)
            XCTAssertEqual(covered.count, 0, "discover at \(size.rawValue): \(covered)")
        }
        if #available(iOS 17.0, *) {
            window.traitOverrides.preferredContentSizeCategory = .large
        }

        // The "Search bar styles" screen: a CYLSearchBar as the table header with Cancel and both accessory views shown, at
        // the default and the largest text size, at rest and while editing.
        let styles = CYLSearchBarStylesViewController(style: .grouped)
        navigation = UINavigationController(rootViewController: styles)
        window.rootViewController = navigation
        CYLRunLoop(0.2)
        styles.searchBar.showsCancelButton = true
        styles.searchBar.setShowsLeadingAccessoryView(true, animated: false)
        styles.searchBar.setShowsTrailingAccessoryView(true, animated: false)
        for editing in [false, true] {
            if editing { styles.searchBar.becomeFirstResponder() }
            for size in sizes {
                if #available(iOS 17.0, *) {
                    window.traitOverrides.preferredContentSizeCategory = size
                }
                CYLRunLoop(0.3)
                navigation.view.setNeedsLayout()
                navigation.view.layoutIfNeeded()
                XCTAssertNotNil(styles.searchBar.window, "the styles screen's bar is shown")
                let covered = CYLViewsCoveredByView(styles.searchBar, nil)
                XCTAssertEqual(covered.count, 0, "search bar styles, editing \(editing), at \(size.rawValue): \(covered)")
            }
        }
        styles.searchBar.resignFirstResponder()
        if #available(iOS 17.0, *) {
            window.traitOverrides.preferredContentSizeCategory = .large
        }

        // The overlay (a CYLSearchView over the results page's navigation controller) is a page of its own: inside that
        // page its search bar covers no view, with results shown.
        results = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source)
        navigation = UINavigationController(rootViewController: results)
        window.rootViewController = navigation
        CYLRunLoop(0.3)
        window.layoutIfNeeded()
        let overlay = results.overlaySearchView
        overlay.animationDuration = 0
        overlay.showSearch(in: navigation, animated: false)
        overlay.setQuery("1", submit: false)
        overlay.layoutIfNeeded()
        XCTAssertNotNil(overlay.searchBarView.window, "the overlay's search bar is shown")
        let overlayCovered = CYLViewsCoveredByView(overlay.searchBarView, overlay)
        XCTAssertEqual(overlayCovered.count, 0, "overlay: \(overlayCovered)")
        overlay.closeSearch(animated: false)

        // A CYLSearchBarView in CYLSearchBarModeMultiple, with searches.
        let multi = CYLSearchBarView(frame: .zero)
        multi.mode = .multiple
        let multiHost = UIViewController()
        multiHost.edgesForExtendedLayout = []
        window.rootViewController = UINavigationController(rootViewController: multiHost)
        CYLRunLoop(0.3)
        multi.frame = CGRect(x: 8, y: 16, width: multiHost.view.bounds.width - 16, height: multi.intrinsicContentSize.height)
        multiHost.view.addSubview(multi)
        multi.addSearch("Rive")
        multi.addSearch("Lottie")
        multi.layoutIfNeeded()
        let multiCovered = CYLViewsCoveredByView(multi, nil)
        XCTAssertEqual(multiCovered.count, 0, "multiple searches: \(multiCovered)")
        window.isHidden = true
    }
}
