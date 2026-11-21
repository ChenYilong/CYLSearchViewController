//
//  CYLSearchExampleContactTagsTests.swift
//  CYLSearchExampleTests
//
//  The contact tags demo and editing bar tests of the example (translated from CYLSearchExampleTests.m,
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
 * The contact tags demo (search, create, placeholders, Manage, network sync, rename) and the editing bar.
 */
final class CYLSearchExampleContactTagsTests: CYLSearchExampleTestCase {

    func testContactTagsDemoSearchesCreatesAndKeepsItsStrings() throws {
        // Edits are saved in the demo's cache: start from the bundled data.
        CYLContactTagsDemo.resetCache()
        addTeardownBlock { CYLContactTagsDemo.resetCache() }
        // docs/CYLTabBarController-Integration.md, "the contact tags example": the Examples row opens Edit Remarks; its
        // editor searches with CYLSearchBarView ("ios" finds "iOS ..." and offers "+ New tag: ios"), creates and selects a
        // tag; the bundle has the same tags and strings in every language.
        // The Objective-C name the Examples menu looks the demo up by.
        XCTAssertNotNil(NSClassFromString("CYLContactTagsDemo"))
        let title = CYLContactTagsDemo.rowTitle()
        XCTAssertFalse(title.hasPrefix("contactTags."), "the row title is localized: \(title)")
        let remark = try XCTUnwrap(CYLContactTagsDemo.viewController() as? CYLContactRemarkViewController)
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = UINavigationController(rootViewController: remark)
        window.makeKeyAndVisible()
        remark.view.layoutIfNeeded()
        let editor = remark.editTags(animated: false)
        editor.view.layoutIfNeeded()
        var hasSearchBar = false
        for subview in editor.view.subviews {
            hasSearchBar = hasSearchBar || subview is CYLSearchBarView
        }
        XCTAssertTrue(hasSearchBar, "the editor searches with CYLSearchBarView")
        let sections = editor.numberOfSectionsInMenu()
        XCTAssertEqual(sections, 2, "Recent and My Tags")
        let mine = editor.menuNumberOfItems(inSection: 1)
        editor.setQuery("ios")
        XCTAssertEqual(editor.numberOfSectionsInMenu(), 1, "Search Results")
        let results = editor.menuNumberOfItems(inSection: 0)
        XCTAssertGreaterThanOrEqual(results, 2, "a match and the create item")
        let first = editor.menuTitleForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertTrue(first.lowercased().contains("ios"), first)
        XCTAssertEqual(editor.menuItemType(at: IndexPath(item: results - 1, section: 0)), .create)
        editor.createTag(named: "Swift Search")
        XCTAssertEqual(editor.numberOfSectionsInMenu(), 2, "creating leaves the search")
        XCTAssertEqual(editor.menuNumberOfItems(inSection: 1), mine + 1, "the new tag is in My Tags")
        let bundle = Bundle.main.url(forResource: "CYLContactTags", withExtension: "bundle").flatMap { Bundle(url: $0) }
        var keys: Set<String>?
        for language in ["en", "ja", "zh-Hans", "zh-Hant"] {
            let lproj = bundle?.path(forResource: language, ofType: "lproj") as NSString?
            let strings = lproj.flatMap { NSDictionary(contentsOfFile: $0.appendingPathComponent("CYLContactTags.strings")) as? [String: Any] }
            let json = lproj.flatMap { FileManager.default.contents(atPath: $0.appendingPathComponent("contact-tags.json")) }
            let data = json.flatMap { (try? JSONSerialization.jsonObject(with: $0)) as? [String: Any] }
            XCTAssertEqual((data?["tags"] as? [Any])?.count ?? 0, 47, language)
            XCTAssertGreaterThan(strings?.count ?? 0, 0, language)
            let languageKeys = Set((strings ?? [:]).keys)
            if let keys { XCTAssertEqual(languageKeys, keys, "same keys in \(language)") }
            keys = languageKeys
        }
        remark.dismiss(animated: false)
        window.isHidden = true
    }

    func testContactTagsDemoShowsCYLPlaceholderViewWhenEmpty() throws {
        // Edits are saved in the demo's cache: start from the bundled data.
        CYLContactTagsDemo.resetCache()
        addTeardownBlock { CYLContactTagsDemo.resetCache() }
        // docs/CYLTabBarController-Integration.md, "CYLPlaceholderView in the contact tags example": a search without a
        // match and an empty tag list show CYLTableViewPlaceHolder's placeholder; a match or a tag hides it.
        let remark = try XCTUnwrap(CYLContactTagsDemo.viewController() as? CYLContactRemarkViewController)
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = UINavigationController(rootViewController: remark)
        window.makeKeyAndVisible()
        remark.view.layoutIfNeeded()
        let editor = remark.editTags(animated: false)
        let editorView: UIView = editor.view
        editorView.layoutIfNeeded()
        let placeholder: () -> UIView? = {
            var views: [UIView] = [editorView]
            while !views.isEmpty {
                let view = views.removeFirst()
                if view.accessibilityIdentifier == "CYLContactTagsPlaceholder" && !(view.superview?.isHidden ?? false) { return view }
                views.append(contentsOf: view.subviews)
            }
            return nil
        }
        XCTAssertNil(placeholder(), "tags shown: no placeholder")
        editor.setQuery("zzzz")
        editorView.layoutIfNeeded()
        let noMatch = placeholder()
        XCTAssertTrue(noMatch is CYLPlaceholderView, "no match shows CYLPlaceholderView")
        XCTAssertEqual(editor.menuNumberOfItems(inSection: 0), 1, "+ New tag: zzzz stays above it")
        XCTAssertGreaterThan(noMatch?.frame.height ?? 0, 0)
        editor.setQuery("ios")
        XCTAssertNil(placeholder(), "a match hides it")
        editor.setQuery("")
        var mine = editor.numberOfSectionsInMenu() - 1
        while editor.menuNumberOfItems(inSection: mine) > 1 {
            let tag = editor.menuTitleForItem(at: IndexPath(item: 0, section: mine))
            editor.deleteTag(tag)
            mine = editor.numberOfSectionsInMenu() - 1
        }
        editorView.layoutIfNeeded()
        XCTAssertTrue(placeholder() is CYLPlaceholderView, "no tags shows CYLPlaceholderView")
        editor.createTag(named: "Family")
        XCTAssertNil(placeholder(), "a new tag hides it")
        remark.dismiss(animated: false)
        // Edit Remarks: a contact without tags shows the placeholder below "Tags"; tags hide it.
        let remarkPlaceholder: () -> UIView? = {
            for view in remark.view.subviews {
                if view.accessibilityIdentifier == "CYLContactRemarkEmptyTags" && !view.isHidden { return view }
            }
            return nil
        }
        XCTAssertNil(remarkPlaceholder(), "the demo contact has tags")
        remark.updateTags([])
        remark.view.layoutIfNeeded()
        let emptyTags = remarkPlaceholder()
        XCTAssertTrue(emptyTags is CYLPlaceholderView, "no tags shows CYLPlaceholderView")
        XCTAssertGreaterThan(emptyTags?.frame.height ?? 0, 0)
        XCTAssertTrue(emptyTags?.accessibilityTraits.contains(.button) ?? false, "VoiceOver: it opens the editor")
        remark.updateTags(["Family"])
        XCTAssertNil(remarkPlaceholder(), "a tag hides it")
        window.isHidden = true
    }

    func testContactTagsManageEditsInPlaceSavesAndOpensContacts() throws {
        // docs/CYLTabBarController-Integration.md, "editing in the contact tags example": Manage switches CollectionViewClassifyMenu's
        // tag list into editing mode in place (delete buttons, dragging, the add control); a drag is saved and comes back
        // when the screen opens again; a tag opens its contacts, and a tag nobody has shows CYLTableViewPlaceHolder's
        // placeholder there.
        CYLContactTagsDemo.resetCache()
        addTeardownBlock { CYLContactTagsDemo.resetCache() }
        let remark = try XCTUnwrap(CYLContactTagsDemo.viewController() as? CYLContactRemarkViewController)
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = UINavigationController(rootViewController: remark)
        window.makeKeyAndVisible()
        remark.view.layoutIfNeeded()
        let editor = remark.editTags(animated: false)
        let editorView: UIView = editor.view
        editorView.layoutIfNeeded()
        XCTAssertNotNil(editor.navigationController, "the editor can push the contacts page")
        let mine = editor.numberOfSectionsInMenu() - 1
        let items = editor.menuNumberOfItems(inSection: mine)
        XCTAssertEqual(editor.menuItemType(at: IndexPath(item: items - 1, section: mine)), .create)
        XCTAssertFalse(editor.isManaging)

        // toggleManaging is private (the Manage button's action): reached through its selector.
        editor.perform(NSSelectorFromString("toggleManaging"))
        XCTAssertTrue(editor.isManaging, "Manage enters the list's editing mode")
        XCTAssertEqual(editor.numberOfSectionsInMenu() - 1, mine, "no page change: the same sections")
        XCTAssertEqual(editor.menuNumberOfItems(inSection: mine), items - 1, "the editing bar replaces + New Tag")
        let editingBar = editor.editingBar
        XCTAssertTrue(editingBar.isEditingBar)
        XCTAssertFalse(editingBar.isHidden, "Manage shows the editing bar above the keyboard")
        XCTAssertTrue(editor.menuSectionAllowsEditing(mine))
        XCTAssertFalse(mine > 0 && editor.menuSectionAllowsEditing(0), "Recent does not take part")
        editorView.layoutIfNeeded()
        var addControl = false
        var views: [UIView] = [editorView]
        while !views.isEmpty {
            let view = views.removeFirst()
            addControl = addControl || view is CYLTagListAddItemView
            views.append(contentsOf: view.subviews)
        }
        XCTAssertFalse(addControl, "the list's own field gives way to the editing bar")

        let first = editor.menuTitleForItem(at: IndexPath(item: 0, section: mine))
        let second = editor.menuTitleForItem(at: IndexPath(item: 1, section: mine))
        editor.menuMoveItem(at: IndexPath(item: 0, section: mine), to: IndexPath(item: 1, section: mine))
        XCTAssertEqual(editor.menuTitleForItem(at: IndexPath(item: 0, section: mine)), second)

        let contacts = editor.showContacts(withTag: first)
        contacts.view.layoutIfNeeded()
        XCTAssertTrue(contacts is CYLContactListViewController, "\(type(of: contacts))")
        let contactList = try XCTUnwrap(contacts as? UITableViewController)
        XCTAssertGreaterThan(contactList.tableView(contactList.tableView, numberOfRowsInSection: 0), 0, "\(first) has contacts")
        editor.createTag(named: "Nobody Yet")
        let empty = try XCTUnwrap(editor.showContacts(withTag: "Nobody Yet") as? UITableViewController)
        empty.view.layoutIfNeeded()
        var placeholder = false
        for view in empty.tableView.subviews {
            placeholder = placeholder || view is CYLPlaceholderView
            for inner in view.subviews { placeholder = placeholder || inner.accessibilityIdentifier == "CYLContactListEmpty" }
            placeholder = placeholder || view.accessibilityIdentifier == "CYLContactListEmpty"
        }
        XCTAssertEqual(empty.tableView(empty.tableView, numberOfRowsInSection: 0), 0)
        XCTAssertTrue(placeholder, "a tag without contacts shows CYLTableViewPlaceHolder's placeholder")
        remark.dismiss(animated: false)

        // Opened again, as after a relaunch: the saved order and the new tag come back.
        let again = try XCTUnwrap(CYLContactTagsDemo.viewController() as? CYLContactRemarkViewController)
        window.rootViewController = UINavigationController(rootViewController: again)
        again.view.layoutIfNeeded()
        let editor2 = again.editTags(animated: false)
        editor2.view.layoutIfNeeded()
        let mine2 = editor2.numberOfSectionsInMenu() - 1
        XCTAssertEqual(editor2.menuTitleForItem(at: IndexPath(item: 0, section: mine2)), second, "the drag was saved")
        XCTAssertEqual(editor2.menuTitleForItem(at: IndexPath(item: 1, section: mine2)), first)
        let count2 = editor2.menuNumberOfItems(inSection: mine2)
        XCTAssertEqual(editor2.menuTitleForItem(at: IndexPath(item: count2 - 2, section: mine2)), "Nobody Yet", "the new tag was saved")
        again.dismiss(animated: false)
        window.isHidden = true
    }

    func testContactTagsUploadSyncAndLoadTheServerCopy() throws {
        // docs/CYLTabBarController-Integration.md, "network sync in the contact tags example": leaving Manage uploads cache A
        // to the simulated server (cache B); Sync simulates another device (a new tag, the first two swapped) and pulls it;
        // opening again shows the server's data after the cache (CollectionViewClassifyMenu's cache-then-network default).
        CYLContactTagsDemo.resetCache()
        UserDefaults.standard.set(0.0, forKey: "CYLContactTagsServerLatency")
        addTeardownBlock {
            CYLContactTagsDemo.resetCache()
            UserDefaults.standard.removeObject(forKey: "CYLContactTagsServerLatency")
        }
        let spin = {
            CYLRunLoop(0.3)
        }
        // The upload and the sync finish on the main queue a moment later (the HUD's zero latency); a slow runner needs more
        // than a fixed wait, so poll for the result (up to 15 s).
        let waitUntil: (() -> Bool) -> Bool = { condition in
            let deadline = Date(timeIntervalSinceNow: 15)
            while !condition() && deadline.timeIntervalSinceNow > 0 {
                CYLRunLoop(0.1)
            }
            return condition()
        }
        let remark = try XCTUnwrap(CYLContactTagsDemo.viewController() as? CYLContactRemarkViewController)
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = UINavigationController(rootViewController: remark)
        window.makeKeyAndVisible()
        remark.view.layoutIfNeeded()
        let editor = remark.editTags(animated: false)
        editor.view.layoutIfNeeded()
        spin()
        let mine = editor.numberOfSectionsInMenu() - 1
        let first = editor.menuTitleForItem(at: IndexPath(item: 0, section: mine))
        let second = editor.menuTitleForItem(at: IndexPath(item: 1, section: mine))
        let third = editor.menuTitleForItem(at: IndexPath(item: 2, section: mine))

        // toggleManaging is private (the Manage button's action): reached through its selector.
        editor.perform(NSSelectorFromString("toggleManaging"))
        editor.menuMoveItem(at: IndexPath(item: 2, section: mine), to: IndexPath(item: 0, section: mine))
        editor.perform(NSSelectorFromString("toggleManaging"))
        let serverCopy = CYLTagListStore(policy: .sandboxFile, name: "CYLContactTagsServer")
        _ = waitUntil {
            let titles = serverCopy.cachedTitles(forSection: "mine") ?? []
            return titles.count >= 3 && titles.first == third
        }
        let uploaded = serverCopy.cachedTitles(forSection: "mine") ?? []
        XCTAssertGreaterThanOrEqual(uploaded.count, 3, "the upload reached B")
        XCTAssertEqual(Array(uploaded.prefix(3)), [third, first, second], "leaving Manage uploads the new order to B")

        let count = editor.menuNumberOfItems(inSection: mine)
        editor.syncFromOtherDevices()
        _ = waitUntil { editor.menuNumberOfItems(inSection: mine) == count + 1 }
        XCTAssertEqual(editor.menuNumberOfItems(inSection: mine), count + 1, "another device added a tag")
        XCTAssertEqual(editor.menuTitleForItem(at: IndexPath(item: 0, section: mine)), first, "and swapped the first two")
        XCTAssertEqual(editor.menuTitleForItem(at: IndexPath(item: 1, section: mine)), third)
        remark.dismiss(animated: false)

        // The server changes again behind this device's back; opening shows cache A, then B.
        var serverItems = serverCopy.cachedItems(forSection: "mine") ?? []
        guard serverItems.count >= 3 else {
            XCTFail("the server copy has \(serverItems.count) tags")
            return
        }
        serverItems.swapAt(0, 2)
        serverCopy.saveItems(serverItems, forSection: "mine")
        let server = serverItems.map(\.title)
        let again = try XCTUnwrap(CYLContactTagsDemo.viewController() as? CYLContactRemarkViewController)
        window.rootViewController = UINavigationController(rootViewController: again)
        again.view.layoutIfNeeded()
        let editor2 = again.editTags(animated: false)
        editor2.view.layoutIfNeeded()
        spin()
        _ = waitUntil {
            let section = editor2.numberOfSectionsInMenu() - 1
            return editor2.menuTitleForItem(at: IndexPath(item: 0, section: section)) == server[0]
        }
        let mine2 = editor2.numberOfSectionsInMenu() - 1
        XCTAssertEqual(editor2.menuTitleForItem(at: IndexPath(item: 0, section: mine2)), server[0], "the server's data replaces the cache")
        let local = CYLTagListStore(policy: .database, name: "CYLContactTags")
        XCTAssertEqual(local.cachedTitles(forSection: "mine"), server, "and is saved to cache A")
        again.dismiss(animated: false)
        window.isHidden = true
    }

    func testContactTagsRenameKeepsTheTagIDAndItsContacts() throws {
        // docs/CYLTabBarController-Integration.md, "renaming in the contact tags example": in Manage, the pencil renames a
        // tag; its id (the primary key) stays, so its contacts stay; the new name is saved to cache A, uploaded to the server
        // (cache B) when Manage ends, and shown again after reopening.
        CYLContactTagsDemo.resetCache()
        UserDefaults.standard.set(0.0, forKey: "CYLContactTagsServerLatency")
        addTeardownBlock {
            CYLContactTagsDemo.resetCache()
            UserDefaults.standard.removeObject(forKey: "CYLContactTagsServerLatency")
        }
        let spin = {
            CYLRunLoop(0.3)
        }
        // The upload and the sync finish on the main queue a moment later (the HUD's zero latency); a slow runner needs more
        // than a fixed wait, so poll for the result (up to 15 s).
        let waitUntil: (() -> Bool) -> Bool = { condition in
            let deadline = Date(timeIntervalSinceNow: 15)
            while !condition() && deadline.timeIntervalSinceNow > 0 {
                CYLRunLoop(0.1)
            }
            return condition()
        }
        let remark = try XCTUnwrap(CYLContactTagsDemo.viewController() as? CYLContactRemarkViewController)
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = UINavigationController(rootViewController: remark)
        window.makeKeyAndVisible()
        remark.view.layoutIfNeeded()
        let editor = remark.editTags(animated: false)
        editor.view.layoutIfNeeded()
        spin()
        let mine = editor.numberOfSectionsInMenu() - 1
        let first = IndexPath(item: 0, section: mine)
        let tagID = editor.menuIdentifierForItem(at: first)
        XCTAssertEqual(tagID, "t01", "tags are keyed by id")
        let before = try XCTUnwrap(editor.showContacts(withTag: tagID) as? UITableViewController)
        let contacts = before.tableView(before.tableView, numberOfRowsInSection: 0)
        XCTAssertGreaterThan(contacts, 0)

        // toggleManaging is private (the Manage button's action): reached through its selector.
        editor.perform(NSSelectorFromString("toggleManaging"))
        editor.renameTag(withID: tagID, to: "Home Folks")
        XCTAssertEqual(editor.menuTitleForItem(at: first), "Home Folks", "renamed in place")
        XCTAssertEqual(editor.menuIdentifierForItem(at: first), tagID, "the id stays")
        let after = try XCTUnwrap(editor.showContacts(withTag: tagID) as? UITableViewController)
        XCTAssertEqual(after.tableView(after.tableView, numberOfRowsInSection: 0), contacts, "the contacts are bound to the id")
        XCTAssertTrue(after.title?.hasPrefix("Home Folks") ?? false, after.title ?? "nil")
        let local = CYLTagListStore(policy: .database, name: "CYLContactTags")
        let saved = local.cachedItems(forSection: "mine")?.first
        XCTAssertEqual(saved?.identifier, tagID, "cache A keeps the id")
        XCTAssertEqual(saved?.title, "Home Folks", "with the new name")

        editor.perform(NSSelectorFromString("toggleManaging"))
        let serverCopy = CYLTagListStore(policy: .sandboxFile, name: "CYLContactTagsServer")
        _ = waitUntil { serverCopy.cachedItems(forSection: "mine")?.first != nil }
        XCTAssertEqual(serverCopy.cachedItems(forSection: "mine")?.first, saved, "leaving Manage uploads it to B")
        remark.dismiss(animated: false)

        let again = try XCTUnwrap(CYLContactTagsDemo.viewController() as? CYLContactRemarkViewController)
        window.rootViewController = UINavigationController(rootViewController: again)
        again.view.layoutIfNeeded()
        let editor2 = again.editTags(animated: false)
        editor2.view.layoutIfNeeded()
        spin()
        let mine2 = editor2.numberOfSectionsInMenu() - 1
        XCTAssertEqual(editor2.menuTitleForItem(at: IndexPath(item: 0, section: mine2)), "Home Folks", "the name comes back")
        again.dismiss(animated: false)
        window.isHidden = true
    }

    func testEditingBarSubmitsAndRidesOnTheKeyboard() {
        // docs/core-todo.md, "the editing bar": the search bar's look as an edit field; its action button and the return key
        // submit; pinToKeyboardInView: ties it to the keyboard's top.
        let bar = CYLSearchBarView.editingBar(placeholder: "Tag name", actionTitle: "Add")
        XCTAssertTrue(bar.isEditingBar)
        XCTAssertNil(bar.searchIcon, "no magnifier")
        XCTAssertTrue(bar.showsCancelButton)
        XCTAssertEqual(bar.cancelButtonTitle, "Add", "the trailing button is the action")
        XCTAssertEqual(bar.placeholder, "Tag name")
        var submitted: String?
        bar.editingSubmitHandler = { _, text in submitted = text }
        bar.text = "   "
        bar.cancelButton.sendActions(for: .touchUpInside)
        XCTAssertNil(submitted, "empty text submits nothing")
        bar.text = "  Book Club "
        bar.cancelButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(submitted, "Book Club", "the action button submits the trimmed text")
        submitted = nil
        bar.text = "Hiking"
        XCTAssertFalse(bar.textFieldShouldReturn(bar.textField))
        XCTAssertEqual(submitted, "Hiking", "so does the return key")

        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        bar.pinToKeyboard(in: host.view)
        host.view.layoutIfNeeded()
        XCTAssertEqual(bar.superview, host.view)
        var pinned = false
        for constraint in host.view.constraints {
            pinned = pinned || (constraint.firstItem === bar && constraint.firstAttribute == .bottom
                                && constraint.secondItem === host.view.keyboardLayoutGuide && constraint.secondAttribute == .top)
        }
        XCTAssertTrue(pinned, "the bar's bottom is the keyboard's top")
        XCTAssertEqual(bar.frame.maxY, host.view.safeAreaLayoutGuide.layoutFrame.maxY, accuracy: 0.5,
                       "with the keyboard down, at the bottom of the safe area")
        window.isHidden = true
    }
}
