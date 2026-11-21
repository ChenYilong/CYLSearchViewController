//
//  CYLSearchExampleCacheFocusItemTests.swift
//  CYLSearchExampleTests
//
//  The suggestion cache, focus, tag suggestion and search bar item tests (translated from CYLSearchExampleTests.m,
//  docs/swift-migration.md, step 4).
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
 * The suggestion cache policies, the cache shown by CYLSearchView, focusing the field, the tag suggestions' fold
 * control and the items appended to CYLSearchBarView.
 */
final class CYLSearchExampleCacheFocusItemTests: CYLSearchExampleTestCase {

    @MainActor
    func testEverySuggestionCachePolicyKeepsSubmittedQueriesNewestFirst() throws {
        // docs/core-todo.md: each policy stores the queries newest first, moves a repeated query to the front, keeps at most
        // maximumCount and clears everything; separate names keep separate caches.
        // The built-in store is internal: a search view makes it from its policy and name.
        let makeCache: (CYLSearchSuggestionCachePolicy, String) -> CYLSearchSuggestionCache? = { policy, name in
            let searchView = CYLSearchView(frame: .zero)
            searchView.suggestionCachePolicy = policy
            searchView.suggestionCacheName = name
            return searchView.suggestionCache
        }
        for policy in [CYLSearchSuggestionCachePolicy.database, .userDefaults, .sandboxFile] {
            let cache = try XCTUnwrap(makeCache(policy, "CYLTestCache"), "policy \(policy.rawValue)")
            let other = try XCTUnwrap(makeCache(policy, "CYLTestOther"), "policy \(policy.rawValue)")
            cache.removeAllQueries()
            other.removeAllQueries()
            // KVC: maximumCount belongs to the core's internal store class (CYLSearchSuggestionStore), which
            // @testable import CYLSearchExample does not reach.
            (cache as? NSObject)?.setValue(3, forKey: "maximumCount")
            cache.addQuery("Swift")
            cache.addQuery("Kotlin")
            cache.addQuery("  ")
            cache.addQuery("Swift")
            XCTAssertEqual(cache.cachedQueries(), ["Swift", "Kotlin"], "policy \(policy.rawValue)")
            cache.addQuery("Dart")
            cache.addQuery("Rust")
            XCTAssertEqual(cache.cachedQueries(), ["Rust", "Dart", "Swift"], "the oldest goes, policy \(policy.rawValue)")
            XCTAssertEqual(other.cachedQueries(), [], "names are separate, policy \(policy.rawValue)")
            let reopened = makeCache(policy, "CYLTestCache")
            XCTAssertEqual(reopened?.cachedQueries(), ["Rust", "Dart", "Swift"], "persisted, policy \(policy.rawValue)")
            cache.removeQuery("Dart")
            XCTAssertEqual(cache.cachedQueries(), ["Rust", "Swift"], "policy \(policy.rawValue)")
            cache.removeAllQueries()
            XCTAssertEqual(cache.cachedQueries(), [], "policy \(policy.rawValue)")
        }
        XCTAssertNil(makeCache(CYLSearchSuggestionCachePolicy.none, "CYLTestCache"))
    }

    @MainActor
    func testTheSearchViewCachesSubmittedQueriesAndClearsThemFromTheHeader() throws {
        // docs/core-todo.md: a submitted query is cached; an empty query lists the cache under a header whose delete button
        // clears it; an empty cache shows CYLTableViewPlaceHolder's placeholder.
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        let searchView = CYLSearchView(frame: .zero)
        XCTAssertEqual(searchView.suggestionCachePolicy, CYLSearchSuggestionCachePolicy.database, "a local database by default")
        searchView.suggestionCacheName = "CYLTestSearchView"
        searchView.suggestionCache?.removeAllQueries()
        searchView.suggestions = ["Android", "Kotlin", "Swift"]
        searchView.closesOnSubmit = false
        searchView.install(in: host.view)
        searchView.showSearch(animated: false)
        searchView.layoutIfNeeded()
        XCTAssertFalse(try XCTUnwrap(searchView.emptySuggestionsView).isHidden, "an empty cache shows the placeholder")
        XCTAssertTrue(searchView.suggestionCacheHeaderView.isHidden)
        searchView.setQuery("Flutter", submit: true)
        searchView.setQuery("Kotlin", submit: true)
        searchView.setQuery("", submit: false)
        searchView.layoutIfNeeded()
        XCTAssertEqual(searchView.filteredSuggestions, ["Kotlin", "Flutter"], "the cache, newest first")
        XCTAssertFalse(searchView.suggestionCacheHeaderView.isHidden, "with its header")
        XCTAssertTrue(searchView.emptySuggestionsView?.isHidden ?? false)
        XCTAssertGreaterThan(searchView.suggestionCacheHeaderView.frame.height, 0)
        // 0.01: on a 3x screen the two edges are the same third of a point, apart by float rounding ("iPhone Duo").
        XCTAssertGreaterThanOrEqual(searchView.suggestionsTableView.frame.minY, searchView.suggestionCacheHeaderView.frame.maxY - 0.01,
                                    "the list starts under the header")
        searchView.setQuery("t", submit: false)
        XCTAssertEqual(searchView.filteredSuggestions, ["Kotlin", "Flutter", "Swift"], "cached matches first, no repeats")
        searchView.setQuery("", submit: false)
        searchView.clearSuggestionCacheButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(searchView.suggestionCache?.cachedQueries(), [])
        XCTAssertFalse(try XCTUnwrap(searchView.emptySuggestionsView).isHidden, "cleared: the placeholder again")
        let again = CYLSearchView(frame: .zero)
        again.suggestionCacheName = "CYLTestSearchView"
        again.suggestionCache?.addQuery("Rust")
        searchView.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.database
        searchView.setQuery("", submit: false)
        XCTAssertEqual(searchView.filteredSuggestions, ["Rust"], "another view with the same name shares the cache")
        again.suggestionCache?.removeAllQueries()
        searchView.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.none
        XCTAssertNil(searchView.suggestionCache)
        window.isHidden = true
    }

    @MainActor
    func testFocusesSearchFieldOnShowDecidesWhenTheKeyboardAppears() {
        // docs/core-todo.md: YES (default) focuses the field when the search opens; NO leaves it unfocused until tapped.
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        for focuses in [true, false] {
            let searchView = CYLSearchView(frame: .zero)
            XCTAssertTrue(searchView.focusesSearchFieldOnShow, "YES by default")
            searchView.focusesSearchFieldOnShow = focuses
            searchView.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.none
            searchView.install(in: host.view)
            searchView.showSearch(animated: false)
            XCTAssertEqual(searchView.searchBarView.textField.isFirstResponder, focuses, "focusesSearchFieldOnShow \(focuses)")
            searchView.closeSearch(animated: false)
            searchView.removeFromSuperview()
        }
        window.isHidden = true
    }

    @MainActor
    func testFocusAloneChangesNothingBelowTheSearchBar() {
        // docs/core-todo.md, core behavior rule 1: focusing the field without typing, and losing focus, leave the list,
        // its header and the empty placeholder exactly as they were.
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        for cached in [["Kotlin", "Swift"], [String]()] {
            let searchView = CYLSearchView(frame: .zero)
            searchView.suggestionCacheName = "CYLTestFocus"
            searchView.suggestionCache?.removeAllQueries()
            for query in cached.reversed() {
                searchView.suggestionCache?.addQuery(query)
            }
            searchView.suggestions = ["Android", "Kotlin", "Swift"]
            searchView.focusesSearchFieldOnShow = false
            searchView.install(in: host.view)
            searchView.showSearch(animated: false)
            searchView.layoutIfNeeded()
            let snapshot: () -> [AnyHashable] = {
                [searchView.filteredSuggestions, searchView.suggestionCacheHeaderView.isHidden,
                 searchView.emptySuggestionsView == nil || searchView.emptySuggestionsView?.isHidden == true,
                 searchView.suggestionsTableView.isHidden, NSCoder.string(for: searchView.suggestionsTableView.frame)]
            }
            let before = snapshot()
            XCTAssertFalse(searchView.searchBarView.textField.isFirstResponder)
            searchView.searchBarView.textField.becomeFirstResponder()
            searchView.layoutIfNeeded()
            XCTAssertTrue(searchView.searchBarView.textField.isFirstResponder)
            XCTAssertEqual(snapshot(), before, "focus alone, cache \(cached)")
            searchView.searchBarView.textField.resignFirstResponder()
            searchView.layoutIfNeeded()
            XCTAssertEqual(snapshot(), before, "blur alone, cache \(cached)")
            searchView.suggestionCache?.removeAllQueries()
            searchView.closeSearch(animated: false)
            searchView.removeFromSuperview()
        }
        window.isHidden = true
    }

    @MainActor
    func testTagSuggestionsEndWithTheFoldButtonByDefault() {
        // docs/tag-view-suggestions.md, BUG TODO: the tag suggestions fold to two rows behind an inline chevron, and both
        // are parameters.
        let searchView = CYLSearchView(frame: .zero)
        XCTAssertEqual(searchView.suggestionsFoldControl.position, CYLMenuFoldControlPosition.tail)
        XCTAssertEqual(searchView.suggestionsFoldControl.content, CYLMenuFoldControlContent.icon)
        XCTAssertEqual(searchView.suggestionsFoldedRowCount, 2)
        XCTAssertEqual(searchView.suggestionsTagView.defaultVisibleRows, 2)
        searchView.suggestionsFoldControl = CYLMenuFoldControl(position: .footer, content: .title)
        searchView.suggestionsFoldedRowCount = 3
        XCTAssertEqual(searchView.suggestionsFoldControl.position, CYLMenuFoldControlPosition.footer)
        XCTAssertEqual(searchView.suggestionsTagView.defaultVisibleRows, 3)
    }

    @MainActor
    func testSearchBarItemsFollowTheAnimatedItemDisplayPriority() {
        // The items' CYLTagButton is CYLTabBarController's CYLAnimatedItemView (docs/animated-icon-component.md; guide:
        // https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md): a
        // file that cannot play (here an unknown type) shows the static image, the component's placeholder only without
        // one, and a text item never grows an icon.
        let unknown = URL(fileURLWithPath: (NSTemporaryDirectory() as NSString).appendingPathComponent("cyl-bar-item.unknown-type"))
        try? "not an animation".write(to: unknown, atomically: true, encoding: .utf8)
        let image = UIImage(systemName: "camera")
        let withImage = CYLSearchBarItem(style: .icon, title: "Camera", image: image)
        withImage.animationURL = unknown
        let withImageView = withImage.itemView
        withImageView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        withImageView.layoutIfNeeded()
        XCTAssertNil(withImageView.animationView)
        XCTAssertTrue(withImageView.imageView.image === image, "The static image wins over the placeholder")
        XCTAssertFalse(withImageView.imageView.isHidden)
        XCTAssertEqual(withImageView.accessibilityLabel, "Camera")

        let withoutImage = CYLSearchBarItem(style: .icon, title: "Camera", image: nil)
        withoutImage.animationURL = unknown
        let withoutImageView = withoutImage.itemView
        withoutImageView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        withoutImageView.layoutIfNeeded()
        if CYLAnimatedItemView.defaultPlaceholderImage != nil {
            XCTAssertNotNil(withoutImageView.imageView.image, "No static image: the component's placeholder")
            XCTAssertEqual(withoutImageView.imageView.bounds.width, 20, accuracy: 0.5, "Sized like the item's icon")
        }
        withoutImageView.playAnimation()

        let text = CYLSearchBarItem.textItem(title: "Search", handler: nil)
        let textView = text.itemView
        textView.layoutIfNeeded()
        XCTAssertNil(textView.imageView.image, "A text item without an icon shows no placeholder")
    }

    @MainActor
    func testSearchBarItemsAreAppendedLikeFlatDesignTabBarItems() {
        // docs/search-bar-view.md, "Mimicking the tab bar's FlatDesign item-appending API": the field stays, the camera,
        // a divider and the Search button are items appended after the text.
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 390, height: 56))
        let recorder = CYLSearchItemRecorder()
        bar.delegate = recorder
        var cameraTaps = 0
        let camera = CYLSearchBarItem.iconItem(image: UIImage(systemName: "camera"), title: "Camera") { _ in
            cameraTaps += 1
        }
        let divider = CYLSearchBarItem.divider()
        let search = CYLSearchBarItem.textItem(title: "Search", handler: nil)
        XCTAssertEqual(camera.index, NSNotFound)
        XCTAssertFalse(bar.hasItem(of: .text))
        bar.addItem(camera)
        bar.addItem(search)
        bar.insertItem(divider, at: 1)
        XCTAssertEqual(bar.items, [camera, divider, search])
        XCTAssertEqual(search.index, 2)
        XCTAssertTrue(camera.searchBarView === bar)
        XCTAssertTrue(bar.hasItem(of: .text))
        XCTAssertEqual(bar.itemViews.count, 3)
        XCTAssertTrue(camera.itemView.superview === bar.fieldView)
        // KVC: "item" belongs to the core's private CYLSearchBarItemButton class.
        XCTAssertTrue((camera.itemView.value(forKey: "item") as? CYLSearchBarItem) === camera)
        XCTAssertTrue(camera.actualBadgeSuperView() === camera.itemView)

        // Layout: in order after the text, inside the field, a 36 pt camera, a 1 pt divider skipped by VoiceOver.
        bar.layoutIfNeeded()
        let cameraFrame = camera.itemView.frame
        let dividerFrame = divider.itemView.frame
        let searchFrame = search.itemView.frame
        XCTAssertLessThanOrEqual(bar.textField.frame.maxX, cameraFrame.minX + 0.5)
        XCTAssertLessThanOrEqual(cameraFrame.maxX, dividerFrame.minX + 0.5)
        XCTAssertLessThanOrEqual(dividerFrame.maxX, searchFrame.minX + 0.5)
        XCTAssertLessThanOrEqual(searchFrame.maxX, bar.fieldView.bounds.width + 0.5)
        XCTAssertEqual(cameraFrame.width, 36, accuracy: 0.5)
        XCTAssertFalse(divider.itemView.isAccessibilityElement)
        XCTAssertTrue(camera.itemView.isAccessibilityElement)
        XCTAssertEqual(camera.itemView.accessibilityLabel, "Camera")
        XCTAssertEqual(search.itemView.titleLabel.text, "Search")

        // Each item is drawn by CollectionViewClassifyMenu's CYLTagButton: the item's title, icon, badge and animated icon.
        XCTAssertTrue(camera.itemView.isKind(of: CYLTagButton.self))
        XCTAssertTrue(search.itemView.isKind(of: CYLTagButton.self))
        XCTAssertEqual(search.itemView.title, "Search")
        XCTAssertNil(camera.itemView.title)
        XCTAssertTrue(camera.itemView.image === camera.image)
        camera.badgeValue = "5"
        camera.badgeColor = UIColor.systemOrange
        XCTAssertEqual(camera.itemView.badgeValue, "5")
        XCTAssertEqual(camera.itemView.badgeColor, UIColor.systemOrange)
        XCTAssertEqual(camera.itemView.accessibilityValue, "5")
        camera.badgeValue = nil
        camera.badgeColor = nil
        let animationURL = URL(fileURLWithPath: "/nonexistent/CYLSearchBarItemIcon.json")
        camera.animationURL = animationURL
        XCTAssertEqual(camera.itemView.animationURL, animationURL)
        camera.animationURL = nil
        XCTAssertNil(camera.itemView.animationURL)

        // Events: the delegate first, then the handler; a disabled item ignores taps; a selectable item toggles.
        camera.itemView.sendActions(for: .touchUpInside)
        XCTAssertEqual(cameraTaps, 1)
        XCTAssertEqual(recorder.items, [camera])
        camera.isEnabled = false
        camera.itemView.sendActions(for: .touchUpInside)
        XCTAssertEqual(cameraTaps, 1)
        camera.isEnabled = true
        camera.isSelectable = true
        XCTAssertNil(bar.selectedItem)
        XCTAssertEqual(bar.selectedIndex, NSNotFound)
        camera.itemView.sendActions(for: .touchUpInside)
        XCTAssertTrue(camera.isSelected)
        XCTAssertTrue(bar.selectedItem === camera)
        XCTAssertEqual(bar.selectedIndex, 0)

        // Badge, text attributes and tint.
        camera.badgeValue = "3"
        camera.itemView.layoutIfNeeded()
        let badge = camera.itemView.badgeLabel
        XCTAssertFalse(badge.isHidden)
        XCTAssertEqual(badge.text, "3")
        camera.badgeValue = nil
        XCTAssertTrue(badge.isHidden)
        search.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        XCTAssertEqual(search.titleTextAttributes(for: .normal)?[.foregroundColor] as? UIColor, UIColor.systemBlue)
        bar.itemTintColor = UIColor.systemGreen
        XCTAssertEqual(camera.itemView.imageView.tintColor, UIColor.systemGreen)

        // The fixed bordered style, and removal.
        bar.searchBarStyle = .bordered
        XCTAssertEqual(bar.fieldBorderWidth, 1)
        XCTAssertNotNil(bar.fieldBorderColor)
        bar.removeItem(divider)
        XCTAssertEqual(bar.items, [camera, search])
        XCTAssertNil(divider.searchBarView)
        XCTAssertNil(divider.itemView.superview)
        bar.addItem(style: .divider, title: nil, image: nil, index: 1, handler: nil)
        XCTAssertEqual(bar.items[1].style, CYLSearchBarItemStyle.divider)
        bar.removeAllItems()
        XCTAssertEqual(bar.items.count, 0)

        // Plain values from the cross-platform wrappers (Flutter, React Native).
        let wrapped = CYLSearchBarItem.item(dictionary: ["style": "icon", "title": "Camera", "image": "camera", "accessibilityIdentifier": "camera", "isSelectable": true, "badgeValue": ""])
        XCTAssertEqual(wrapped.style, CYLSearchBarItemStyle.icon)
        XCTAssertNotNil(wrapped.image)
        XCTAssertEqual(wrapped.itemAccessibilityIdentifier, "camera")
        XCTAssertTrue(wrapped.isSelectable)
        XCTAssertEqual(wrapped.badgeValue, "")
        XCTAssertEqual(CYLSearchBarItem.item(dictionary: ["style": "divider"]).style, CYLSearchBarItemStyle.divider)
        let wrappedText = CYLSearchBarItem.item(dictionary: ["style": "text", "title": "Search"])
        XCTAssertEqual(wrappedText.style, CYLSearchBarItemStyle.text)
    }
}
