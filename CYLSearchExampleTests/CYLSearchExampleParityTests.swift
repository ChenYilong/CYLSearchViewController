//
//  CYLSearchExampleParityTests.swift
//  CYLSearchExampleTests
//
//  The parity options, suggestions, multiple mode, Swift ports and empty-results tests (translated from
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
 * Parity options, suggestions, multiple mode, the Swift ports and the empty-results placeholder.
 */
final class CYLSearchExampleParityTests: CYLSearchExampleTestCase {

    func testSearchBarViewParityOptions() throws {
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 375, height: 56))
        let recorder = CYLParityRecorder()
        bar.delegate = recorder

        // Navigation button (lapism NavigationIconCompat): hidden by default, shown for an icon, read by VoiceOver.
        bar.layoutIfNeeded()
        XCTAssertTrue(bar.navigationButton.isHidden)
        bar.navigationIcon = .arrow
        bar.layoutIfNeeded()
        XCTAssertFalse(bar.navigationButton.isHidden)
        XCTAssertEqual(bar.navigationButton.accessibilityLabel, CYLSearchResources.localizedString(forKey: "search.back"))
        XCTAssertGreaterThan(bar.fieldView.frame.minX, bar.navigationButton.frame.maxX - 8, "the field starts after the button")
        bar.navigationButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(recorder.events.last, "navigation")

        // Voice while empty, submit while there is text (MaterialSearchView showVoice, SearchView isSubmitButtonEnabled).
        bar.showsVoiceButton = true
        bar.showsSubmitButton = true
        bar.layoutIfNeeded()
        XCTAssertFalse(bar.voiceButton.isHidden)
        XCTAssertTrue(bar.submitButton.isHidden)
        bar.voiceButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(recorder.events.last, "voice")
        bar.text = "rive"
        bar.layoutIfNeeded()
        XCTAssertTrue(bar.voiceButton.isHidden)
        XCTAssertFalse(bar.submitButton.isHidden)
        bar.submitButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(recorder.events.last, "search rive")

        // setText:submit: and the delegate's veto (setQuery / setTextQuery).
        bar.setText("lottie", submit: true)
        XCTAssertEqual(recorder.events.last, "search lottie")
        recorder.refuseSubmit = true
        XCTAssertFalse(bar.submit())
        recorder.refuseSubmit = false
        bar.setText("   ", submit: true)
        XCTAssertEqual(recorder.events.last, "search lottie", "blank text is never submitted")

        // Keyboard options and the length limit (inputType, imeOptions, maxLength).
        bar.keyboardType = .webSearch
        bar.returnKeyType = .go
        XCTAssertEqual(bar.textField.keyboardType, .webSearch)
        XCTAssertEqual(bar.textField.returnKeyType, .go)
        bar.text = ""
        bar.maximumTextLength = 3
        XCTAssertEqual(bar.textField.delegate?.textField?(bar.textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "abc"), true)
        bar.text = "abc"
        XCTAssertEqual(bar.textField.delegate?.textField?(bar.textField, shouldChangeCharactersIn: NSRange(location: 3, length: 0), replacementString: "d"), false)
        bar.maximumTextLength = 2
        XCTAssertEqual(bar.text, "ab")

        // Clear on cancel (setTextClearOnBackPressed) and a custom clear icon (setCloseIcon / setClearIcon).
        bar.showsCancelButton = true
        bar.clearsTextOnCancel = true
        bar.cancelButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(bar.text, "")
        bar.clearImage = UIImage(systemName: "xmark")
        XCTAssertEqual(bar.textField.clearButtonMode, .never)
        XCTAssertNotNil(bar.textField.rightView)

        // Iconified (SearchView setIconifiedByDefault / isIconified): only the icon button shows.
        bar.isIconified = true
        bar.layoutIfNeeded()
        XCTAssertTrue(bar.fieldView.isHidden)
        XCTAssertFalse(bar.iconButton.isHidden)
        XCTAssertTrue(bar.cancelButton.isHidden)
        XCTAssertEqual(recorder.events.last, "iconified")
        XCTAssertEqual(bar.iconButton.accessibilityLabel, CYLSearchResources.localizedString(forKey: "search.field"))
        bar.iconPosition = .center
        bar.layoutIfNeeded()
        XCTAssertEqual(bar.iconButton.frame.midX, bar.bounds.midX, accuracy: 1, "centered like a floating button")
        bar.setIconified(false, animated: false)
        XCTAssertFalse(bar.fieldView.isHidden)
        XCTAssertTrue(bar.iconButton.isHidden)
        XCTAssertEqual(recorder.events.last, "expanded")

        // State restoration (onSaveInstanceState / onRestoreInstanceState).
        bar.text = "saved"
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        bar.encodeRestorableState(with: archiver)
        archiver.finishEncoding()
        let restored = CYLSearchBarView(frame: .zero)
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: archiver.encodedData)
        unarchiver.requiresSecureCoding = false
        restored.decodeRestorableState(with: unarchiver)
        XCTAssertEqual(restored.text, "saved")

        // Cursor color (setCursorDrawable) and a bar that opens another page instead of editing (setOnClickListener).
        bar.cursorColor = .systemPink
        XCTAssertEqual(bar.textField.tintColor, UIColor.systemPink)
        let button = CYLParityRecorder()
        button.refuseEditing = true
        bar.delegate = button
        XCTAssertEqual(bar.textField.delegate?.textFieldShouldBeginEditing?(bar.textField), false)
        XCTAssertEqual(button.events.last, "tapped")
    }

    func testSearchViewSuggestionsOpenAndClose() throws {
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 390, height: 844))
        let host = UIViewController()
        window.rootViewController = host
        window.isHidden = false
        let searchView = CYLSearchView(frame: .zero)
        let recorder = CYLParityRecorder()
        searchView.delegate = recorder
        searchView.animationDuration = 0
        searchView.suggestions = ["Android", "iOS", "Café", "SwiftUI"]
        searchView.install(in: host.view)
        XCTAssertFalse(searchView.searchOpen)
        XCTAssertTrue(searchView.isHidden)

        // A bar button item opens it (setMenuItem).
        let item = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
        searchView.attach(to: item)
        XCTAssertIdentical(item.target, searchView)
        UIApplication.shared.sendAction(try XCTUnwrap(item.action), to: item.target, from: item, for: nil)
        XCTAssertTrue(searchView.searchOpen)
        XCTAssertFalse(searchView.isHidden)
        XCTAssertEqual(recorder.events.last, "shown")

        // Filtering: case- and diacritic-insensitive "contains", nothing for an empty query.
        searchView.setQuery("cafe", submit: false)
        XCTAssertEqual(searchView.filteredSuggestions, ["Café"])
        searchView.setQuery("I", submit: false)
        XCTAssertEqual(searchView.filteredSuggestions, ["Android", "iOS", "SwiftUI"])
        XCTAssertEqual(searchView.suggestionsTableView.numberOfRows(inSection: 0), 3)
        searchView.setQuery("", submit: false)
        XCTAssertEqual(searchView.filteredSuggestions.count, 0)
        searchView.showsSuggestionsForEmptyQuery = true
        XCTAssertEqual(searchView.filteredSuggestions.count, 4)
        searchView.suggestionFilter = { suggestion, query in suggestion.hasPrefix(query) }
        searchView.setQuery("S", submit: false)
        XCTAssertEqual(searchView.filteredSuggestions, ["SwiftUI"])
        searchView.dismissSuggestions()
        XCTAssertTrue(searchView.suggestionsTableView.isHidden)
        searchView.showSuggestions()
        XCTAssertFalse(searchView.suggestionsTableView.isHidden)

        // Tapping a suggestion fills the field; submitting closes unless the delegate handles it.
        searchView.suggestionsTableView.delegate?.tableView?(searchView.suggestionsTableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(searchView.query, "SwiftUI")
        XCTAssertTrue(recorder.events.contains("suggestion 0 SwiftUI"))
        recorder.handleSubmit = true
        searchView.setQuery("Swift", submit: true)
        XCTAssertTrue(searchView.searchOpen, "a handled query keeps it open")
        recorder.handleSubmit = false
        searchView.setQuery("Swift", submit: true)
        XCTAssertFalse(searchView.searchOpen)
        XCTAssertEqual(recorder.events.last, "closed")

        // Its own page: the bar covers no view of the page, and the page sits above the host.
        searchView.contentView = UILabel()
        searchView.showSearch(animated: false)
        searchView.layoutIfNeeded()
        XCTAssertGreaterThanOrEqual(try XCTUnwrap(searchView.contentView).frame.minY, searchView.searchBarView.frame.maxY)
        let covered = CYLViewsCoveredByView(searchView.searchBarView, searchView)
        XCTAssertEqual(covered.count, 0, "\(covered)")
        XCTAssertTrue(searchView.accessibilityViewIsModal)
        // State restoration (onSaveInstanceState): the query and the open state come back.
        searchView.setQuery("kept", submit: false)
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        searchView.encodeRestorableState(with: archiver)
        archiver.finishEncoding()
        searchView.closeSearch(animated: false)
        let restored = CYLSearchView(frame: .zero)
        restored.animationDuration = 0
        restored.install(in: host.view)
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: archiver.encodedData)
        unarchiver.requiresSecureCoding = false
        restored.decodeRestorableState(with: unarchiver)
        XCTAssertEqual(restored.query, "kept")
        XCTAssertTrue(restored.searchOpen)
        restored.closeSearch(animated: false)
        window.isHidden = true
    }

    func testSearchBarViewMultipleModeFlow() {
        // CYLSearchBarModeMultiple (was CYLMultiSearchView, iammert MultiSearchView): add, type, complete, select and
        // remove searches, each reported to the bar's delegate.
        let bar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 375, height: 56))
        let recorder = CYLParityRecorder()
        bar.delegate = recorder
        bar.animationDuration = 0
        XCTAssertEqual(bar.mode, .single)
        bar.beginNewSearch()
        XCTAssertFalse(bar.isEditingNewSearch, "nothing happens in the single mode")
        bar.addSearch("ignored")
        XCTAssertEqual(bar.searches.count, 0)

        bar.mode = .multiple
        bar.layoutIfNeeded()
        XCTAssertTrue(bar.fieldView.isHidden, "the single field is hidden")
        XCTAssertFalse(bar.newSearchButton.isHidden)
        XCTAssertGreaterThanOrEqual(bar.intrinsicContentSize.height, 56)
        XCTAssertFalse(bar.isEditingNewSearch)
        XCTAssertEqual(bar.selectedSearchIndex, NSNotFound)

        // A short search is dropped, as in MultiSearchView (3 characters).
        bar.beginNewSearch()
        XCTAssertTrue(bar.isEditingNewSearch)
        XCTAssertEqual(bar.searches.count, 1)
        bar.completeSearch()
        XCTAssertEqual(bar.searches.count, 0)
        XCTAssertEqual(bar.selectedSearchIndex, NSNotFound)
        XCTAssertFalse(recorder.events.last?.hasPrefix("complete") ?? false, "a dropped search is not reported")

        // Typing reports the index; completing selects the new search.
        bar.beginNewSearch()
        var field = CYLSearchFields(bar).last
        XCTAssertNotNil(field)
        field?.text = "Rive"
        field?.sendActions(for: .editingChanged)
        XCTAssertEqual(recorder.events.last, "typed 0 Rive")
        bar.completeSearch()
        XCTAssertEqual(recorder.events.last, "complete 0 Rive")
        XCTAssertEqual(bar.selectedSearchIndex, 0)

        bar.addSearch("Lottie")
        bar.addSearch("PAG")
        XCTAssertEqual(bar.searches, ["Rive", "Lottie", "PAG"])
        XCTAssertEqual(bar.selectedSearchIndex, 2)
        bar.selectSearch(at: 0)
        XCTAssertEqual(recorder.events.last, "selected 0 Rive")
        XCTAssertEqual(bar.selectedSearchIndex, 0)

        // Removing the selected search selects the next one, or the previous one at the end.
        bar.removeSearch(at: 0)
        XCTAssertEqual(recorder.events.last, "removed 0")
        XCTAssertEqual(bar.searches, ["Lottie", "PAG"])
        XCTAssertEqual(bar.selectedSearchIndex, 0)
        bar.selectSearch(at: 1)
        bar.removeSearch(at: 1)
        XCTAssertEqual(bar.selectedSearchIndex, 0)
        bar.removeSearch(at: 7)
        XCTAssertEqual(bar.searches.count, 1, "an index out of range is ignored")

        // The bar's text style and length limit apply to the searches.
        bar.maximumTextLength = 4
        bar.beginNewSearch()
        field = CYLSearchFields(bar).last
        XCTAssertEqual(field.flatMap { $0.delegate?.textField?($0, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "12345") }, false)
        bar.placeholder = "Category"
        XCTAssertEqual(field?.attributedPlaceholder?.string, "Category")
        XCTAssertEqual(bar.newSearchButton.accessibilityLabel, CYLSearchResources.localizedString(forKey: "multisearch.add"))
        bar.newSearchButton.sendActions(for: .touchUpInside)
        XCTAssertFalse(bar.isEditingNewSearch, "the button completes the search being typed")

        // Back to one field.
        bar.mode = .single
        bar.layoutIfNeeded()
        XCTAssertFalse(bar.fieldView.isHidden)
        XCTAssertEqual(bar.newSearchButton.superview?.isHidden, true)
    }

    func testSwiftPortsOfOtherLibrariesLoad() throws {
        // Each Swift port (docs/search-api-comparison.md) opens in a window, and no visible search bar covers a view.
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 390, height: 844))
        window.isHidden = false
        let ports: [UIViewController.Type] = [CYLSearchPortsViewController.self, CYLLapismSearchViewController.self,
                                              CYLMaterialSearchMenuViewController.self, CYLYechaoaSearchViewController.self,
                                              CYLRevealSearchViewController.self, CYLMultiSearchDemoViewController.self]
        for port in ports {
            let name = String(describing: port)
            // The Swift types are referenced directly, so the lookup by name checks the runtime still finds each class.
            XCTAssertNotNil(NSClassFromString(NSStringFromClass(port)), "\(name) is compiled into the app")
            let controller: UIViewController
            if let tableControllerType = port as? UITableViewController.Type {
                controller = tableControllerType.init(style: .insetGrouped)
            } else {
                controller = port.init()
            }
            let navigation = UINavigationController(rootViewController: controller)
            window.rootViewController = navigation
            CYLRunLoop(0.3)
            navigation.view.layoutIfNeeded()
            XCTAssertNotNil(controller.view.window, "\(name) is shown")
            var bars: [UIView] = []
            var queue: [UIView] = [controller.view]
            while !queue.isEmpty {
                let view = queue.removeFirst()
                if view is CYLSearchBarView { bars.append(view) }
                queue.append(contentsOf: view.subviews)
            }
            for bar in bars {
                var visible = bar.window != nil && !bar.isHidden && bar.alpha > 0.01
                var parent = bar.superview
                while let current = parent, visible {
                    visible = !current.isHidden
                    parent = current.superview
                }
                if !visible { continue }
                let covered = CYLViewsCoveredByView(bar, controller.view)
                XCTAssertEqual(covered.count, 0, "\(name): \(covered)")
            }
        }
        // The MaterialSearchView samples, one by one.
        let menu = CYLMaterialSearchMenuViewController(style: .insetGrouped)
        let navigation = UINavigationController(rootViewController: menu)
        window.rootViewController = navigation
        menu.loadViewIfNeeded()
        let samples = menu.tableView(menu.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(samples, 6, "Default, Themed, Voice, Sticky, Tabs, Input type")
        for row in 0..<samples {
            menu.tableView(menu.tableView, didSelectRowAt: IndexPath(row: row, section: 0))
            CYLRunLoop(0.4)
            let sample = navigation.topViewController
            XCTAssertNotEqual(sample, menu, "row \(row) opens a sample")
            sample?.loadViewIfNeeded()
            let searchView = sample?.view.subviews.first { $0 is CYLSearchView } as? CYLSearchView
            XCTAssertNotNil(searchView, "row \(row) has a search view")
            // The search item opens the search in place of the navigation bar (docs/search-api-comparison.md, "Default"):
            // the navigation bar hides, the search bar takes its place, and the bar comes back when the search closes.
            let item = sample?.navigationItem.rightBarButtonItem
            XCTAssertIdentical(item?.target, sample, "the search item opens the search")
            UIApplication.shared.sendAction(try XCTUnwrap(item?.action), to: item?.target, from: item, for: nil)
            CYLRunLoop(0.5)
            XCTAssertEqual(searchView?.searchOpen, true, "row \(row) opens the search")
            XCTAssertTrue(navigation.isNavigationBarHidden, "row \(row): the search bar takes the navigation bar's place")
            searchView?.closeSearch(animated: false)
            CYLRunLoop(0.5)
            XCTAssertFalse(navigation.isNavigationBarHidden, "row \(row): the navigation bar comes back")
            navigation.popToRootViewController(animated: false)
        }
        window.isHidden = true
    }

    func testEmptyResultsShowTheCYLTableViewPlaceHolderPlaceholder() {
        // docs/sub-repositories.md: a query that matches no suggestion shows CYLTableViewPlaceHolder's placeholder, in both
        // suggestion styles, only when showsEmptyResultsPlaceholder is on.
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        let searchView = CYLSearchView(frame: .zero)
        searchView.suggestions = ["Android", "Kotlin", "Swift"]
        searchView.install(in: host.view)
        searchView.showSearch(animated: false)
        searchView.setQuery("zzz", submit: false)
        XCTAssertNil(searchView.emptyResultsView, "off by default")
        searchView.showsEmptyResultsPlaceholder = true
        for style in [CYLSearchSuggestionStyle.list, .tags] {
            searchView.suggestionStyle = style
            searchView.setQuery("zzz", submit: false)
            searchView.layoutIfNeeded()
            XCTAssertNotNil(searchView.emptyResultsView, "style \(style.rawValue)")
            XCTAssertEqual(searchView.emptyResultsView?.isHidden, false, "no match shows the placeholder, style \(style.rawValue)")
            XCTAssertEqual(searchView.emptyResultsView?.scenario, CYLPlaceholderScenario.noSearchResults)
            XCTAssertGreaterThan(searchView.emptyResultsView?.frame.height ?? 0, 0)
            searchView.setQuery("swi", submit: false)
            XCTAssertEqual(searchView.emptyResultsView?.isHidden, true, "a match hides it, style \(style.rawValue)")
            searchView.setQuery("", submit: false)
            XCTAssertEqual(searchView.emptyResultsView?.isHidden, true, "an empty query hides it, style \(style.rawValue)")
        }
        searchView.emptyResultsScenario = .noContent
        searchView.setQuery("zzz", submit: false)
        XCTAssertEqual(searchView.emptyResultsView?.scenario, CYLPlaceholderScenario.noContent, "the scenario is a parameter")
        window.isHidden = true
    }

    func testEmptyResultsPlaceholderStaysAboveTheKeyboard() {
        // docs/core-todo.md, "the empty-results placeholder sits under the keyboard": the placeholders take the same bottom
        // keyboard inset as the lists, so a placeholder centres in the part of the page the keyboard leaves visible.
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        let searchView = CYLSearchView(frame: .zero)
        searchView.suggestions = ["Android", "Kotlin", "Swift"]
        searchView.showsEmptyResultsPlaceholder = true
        searchView.install(in: host.view)
        searchView.showSearch(animated: false)
        searchView.setQuery("zzz", submit: false)
        searchView.layoutIfNeeded()
        let fullHeight = searchView.emptyResultsView?.frame.height ?? 0
        let keyboard = CGRect(x: 0, y: 874 - 336, width: 402, height: 336)
        let screenKeyboard = window.convert(keyboard, to: window.screen.coordinateSpace)
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil,
                                        userInfo: [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: screenKeyboard)])
        searchView.layoutIfNeeded()
        let placeholder = searchView.emptyResultsView.map { $0.convert($0.bounds, to: window) } ?? .zero
        XCTAssertLessThanOrEqual(placeholder.maxY, keyboard.minY + 0.5, "the placeholder ends at the keyboard")
        XCTAssertLessThan(searchView.emptyResultsView?.frame.height ?? 0, fullHeight)
        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: nil)
        searchView.layoutIfNeeded()
        XCTAssertEqual(searchView.emptyResultsView?.frame.height ?? 0, fullHeight, accuracy: 0.5, "the keyboard gone, full height again")
        window.isHidden = true
    }
}
