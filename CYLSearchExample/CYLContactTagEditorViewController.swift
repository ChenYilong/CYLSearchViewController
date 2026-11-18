//
//  CYLContactTagEditorViewController.swift
//  CYLSearchExample
//
//  "Edit Tags": a sheet for choosing a contact's tags, as in a chat app, ported from CollectionViewClassifyMenu's
//  CYLTagEditorExample (CYLTagEditorViewController). The search field is this library's CYLSearchBarView; the tags are
//  CollectionViewClassifyMenu's CYLTagListView.
//  - "Recent" (with a trash button) and "My Tags" (with "Manage"; folded to three rows, the chevron as its last tag)
//    list the tags; a selected tag is green, in both sections.
//  - "Manage" switches the tag list into CollectionViewClassifyMenu's editing mode in place (setEditing(_:animated:)):
//    the tags of "My Tags" show a delete button and can be dragged, an add control shows below them, and a tap on a tag
//    opens the contacts that have it (CYLContactListViewController). Every change is saved (CYLTagListStore).
//  - Network sync (CYLContactTagServer, a simulated server): opening loads with the tag list's load policy (the
//    cache at once, then the server's data after its delay); leaving "Manage" uploads the edited lists; the sync
//    button (top right) pulls an edit simulated on another device. `-CYLContactTagsLoadPolicy cacheFirst` or
//    `networkFirst` picks another policy.
//  - "+ New Tag" after the last tag adds a tag (the menu's create item), never selected.
//  - Typing in the search bar shows "Search Results" (case-insensitive) and "+ New tag: <text>" when that exact tag does
//    not exist yet; tapping it, or the keyboard's search key, creates, selects and shows the tag.
//  - "Done" (green) returns the selection; it is off while searching.
//  - CYLTableViewPlaceHolder's CYLPlaceholderView shows the empty states: a search that matches no tag (below "+ New
//    tag: <text>") and no tags at all; it is centred in the free space above the keyboard.
//

import UIKit
import CollectionViewClassifyMenu
import CYLSearchViewController
import CYLTableViewPlaceHolder

/**
 * "Edit Tags": chooses, creates and deletes a contact's tags, searched with `CYLSearchBarView`.
 */
final class CYLContactTagEditorViewController: UIViewController {

    /**
     * One item of a section: a tag, or "+ New Tag" (nil: asks for a name) / "+ New tag: <name>".
     */
    enum Item: Equatable {
        case tag(String)
        case create(String?)
    }

    /**
     * The kind of a section.
     */
    enum SectionKind: Equatable {
        case recent, mine, results
    }

    /**
     * The empty state shown with `CYLPlaceholderView`.
     */
    enum EmptyState: Equatable {
        case none
        /**
         * A search that matches no tag.
         */
        case noMatch
        /**
         * No tags at all.
         */
        case noTags
    }

    /**
     * A titled group of items.
     */
    struct Section: Equatable {
        let kind: SectionKind
        let title: String
        let items: [Item]
    }

    /**
     * The tags edited here.
     */
    let store: CYLContactTagStore

    /**
     * The selection the editor opened with.
     */
    let initialSelection: [String]

    /**
     * The selected tags, in the order they were chosen.
     */
    private(set) var selectedTags: [String]

    /**
     * The search query, trimmed.
     */
    private(set) var query = ""

    /**
     * "Manage" mode: the tag list's editing mode (`CYLTagListView.isEditing`).
     */
    @objc var isManaging: Bool {
        tagListView.isEditing
    }

    /**
     * The sections shown.
     */
    private(set) var sections: [Section] = []

    /**
     * Called with the selection when "Done" is tapped.
     */
    var onDone: (([String]) -> Void)?

    /**
     * The tags (CollectionViewClassifyMenu).
     */
    let tagListView = CYLTagListView(foldControl: CYLMenuFoldControl(position: .tail, content: .icon))

    /**
     * The search bar (this library).
     */
    let searchBar = CYLSearchBarView(frame: .zero)

    /**
     * The simulated server (cache B); the tag list's remote source.
     */
    @objc let server = CYLContactTagServer()

    /**
     * Pulls an edit simulated on another device (top right, next to "Done").
     */
    let syncButton = UIButton(type: .system)

    /**
     * The empty state shown now.
     */
    private(set) var emptyState = EmptyState.none

    /**
     * CYLTableViewPlaceHolder's placeholder of the current empty state; nil while there is none.
     */
    private(set) var placeholderView: CYLPlaceholderView?

    /**
     * The free space below the tags and above the keyboard, where the placeholder is centred.
     */
    private let placeholderArea = UIView()

    /**
     * "Cancel", "Done" and the title of the sheet.
     */
    let cancelButton = UIButton(type: .system)
    let doneButton = UIButton(type: .custom)
    let titleLabel = UILabel()

    private(set) lazy var clearRecentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .secondaryLabel
        button.accessibilityLabel = cylContactTagsText("clearRecent")
        button.accessibilityIdentifier = "CYLContactTagsClearRecent"
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 32)
        button.addTarget(self, action: #selector(clearRecent), for: .touchUpInside)
        return button
    }()

    private(set) lazy var manageButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 15))
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitleColor(CYLContactTagEditorViewController.linkColor, for: .normal)
        button.addTarget(self, action: #selector(toggleManaging), for: .touchUpInside)
        return button
    }()

    /**
     * The chat app's green (#07C160) and link color (#576B95).
     */
    static let green = UIColor(red: 0.027, green: 0.757, blue: 0.376, alpha: 1)
    static let linkColor = UIColor(red: 0.341, green: 0.420, blue: 0.584, alpha: 1)

    /**
     * The tags' look: gray tags, green selected tags.
     */
    static func tagStyle() -> CYLMenuStyle {
        let style = CYLMenuStyle()
        // A plain font: CYLMenuStyle scales it for Dynamic Type itself (a scaled font must not be scaled again).
        let font = UIFont.systemFont(ofSize: 16)
        for state in [UIControl.State.normal, .selected, .disabled] {
            let appearance = style.appearance(for: state)
            appearance.font = font
            appearance.cornerRadius = 6
            appearance.borderWidth = 0
            appearance.margin = 14
        }
        style.normalAppearance.backgroundColor = .systemGray6
        style.normalAppearance.textColor = .label
        style.selectedAppearance.backgroundColor = green.withAlphaComponent(0.1)
        style.selectedAppearance.textColor = green
        style.itemHeight = 36
        style.interitemSpacing = 12
        style.lineSpacing = 12
        style.sectionInsets = UIEdgeInsets(top: 4, left: 16, bottom: 20, right: 16)
        style.headerHeight = 40
        style.headerFont = .systemFont(ofSize: 15)
        style.headerTextColor = .secondaryLabel
        style.headerHorizontalInset = 16
        style.backgroundColor = .systemBackground
        style.imageSize = CGSize(width: 14, height: 14)
        style.imageTitleSpacing = 6
        return style
    }

    /**
     * An editor of `store` that starts with `selectedTags` (those still in the store).
     */
    init(store: CYLContactTagStore, selectedTags: [String]) {
        self.store = store
        self.initialSelection = selectedTags.filter(store.contains)
        self.selectedTags = initialSelection
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        cancelButton.setTitle(cylContactTagsText("cancel"), for: .normal)
        cancelButton.setTitleColor(.label, for: .normal)
        cancelButton.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 17))
        cancelButton.titleLabel?.adjustsFontForContentSizeCategory = true
        cancelButton.accessibilityIdentifier = "CYLContactTagsCancel"
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)

        titleLabel.text = cylContactTagsText("editTags")
        titleLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: .systemFont(ofSize: 17, weight: .semibold))
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityTraits = .header

        // A custom button with explicit colors: green with white text when enabled, gray otherwise.
        doneButton.setTitle(cylContactTagsText("done"), for: .normal)
        doneButton.titleLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: .systemFont(ofSize: 17, weight: .semibold))
        doneButton.titleLabel?.adjustsFontForContentSizeCategory = true
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        doneButton.setTitleColor(.tertiaryLabel, for: .disabled)
        doneButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        doneButton.layer.cornerRadius = 4
        doneButton.layer.masksToBounds = true
        doneButton.accessibilityIdentifier = "CYLContactTagsDone"
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)

        // The search field is CYLSearchBarView: its delegate reports each change and the search key.
        searchBar.placeholder = cylContactTagsText("search")
        searchBar.textField.accessibilityLabel = cylContactTagsText("searchTags")
        searchBar.accessibilityIdentifier = "CYLContactTagsSearchBar"
        searchBar.returnKeyType = .search
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.delegate = self

        tagListView.style = CYLContactTagEditorViewController.tagStyle()
        tagListView.selectionMode = .multiple
        tagListView.allowsEmptySelection = true
        tagListView.menuDataSource = self
        tagListView.menuDelegate = self
        tagListView.accessibilityIdentifier = "CYLContactTagsList"
        // "My Tags" folds to three rows, the chevron as its last tag (as the Discover page's recent searches).
        tagListView.defaultVisibleRows = 3
        // The list saves "My Tags" after each edit, in the store's database cache (same name and keys).
        tagListView.cacheName = CYLContactTagStore.cacheName
        tagListView.cachePolicy = .database
        // The server and the load policy (the core's default, cache then network, unless a launch argument says).
        tagListView.remoteSource = server
        switch UserDefaults.standard.string(forKey: "CYLContactTagsLoadPolicy") {
        case "cacheFirst": tagListView.loadPolicy = .cacheFirst
        case "networkFirst": tagListView.loadPolicy = .networkFirst
        default: tagListView.loadPolicy = .cacheThenNetwork
        }
        // Leaving "Manage" uploads the edited lists (cache A, already saved) to the server.
        tagListView.editingFinishHandler = { [weak self] _ in
            self?.uploadToServer()
        }

        syncButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        syncButton.tintColor = CYLContactTagEditorViewController.linkColor
        syncButton.accessibilityLabel = cylContactTagsText("sync")
        syncButton.accessibilityIdentifier = "CYLContactTagsSync"
        syncButton.addTarget(self, action: #selector(syncFromOtherDevices), for: .touchUpInside)
        for case let scrollView as UIScrollView in tagListView.subviews {
            scrollView.keyboardDismissMode = .onDrag
        }

        placeholderArea.isUserInteractionEnabled = false
        placeholderArea.isHidden = true
        for subview in [cancelButton, titleLabel, doneButton, syncButton, searchBar, tagListView] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        // The tag list fills the rest of the sheet and scrolls: its intrinsic (content) height gives way, so the search bar
        // keeps its own height whether there are few tags or many.
        tagListView.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        tagListView.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
        searchBar.setContentHuggingPriority(.required, for: .vertical)
        searchBar.setContentCompressionResistancePriority(.required, for: .vertical)
        // Laid out by frame (viewDidLayoutSubviews): constraints to the keyboard would fight the header when space is short.
        view.addSubview(placeholderArea)
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: cancelButton.trailingAnchor, constant: 8),
            doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 56),
            doneButton.heightAnchor.constraint(equalToConstant: 32),
            syncButton.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -4),
            syncButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            syncButton.widthAnchor.constraint(equalToConstant: 44),
            syncButton.heightAnchor.constraint(equalToConstant: 44),
            searchBar.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            tagListView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tagListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tagListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        reload()
        loadFromServer()
    }

    // MARK: Network sync

    /**
     * The tag list's load policy over cache A and the server (B): the cache is what the store already shows; the
     * server's sections, when they arrive, replace them.
     */
    private func loadFromServer() {
        tagListView.loadSections(withKeys: [CYLContactTagStore.mineCacheKey, CYLContactTagStore.recentCacheKey]) { [weak self] sections, origin in
            guard let self else { return }
            if self.store.apply(sections) {
                self.reload()
            }
        }
    }

    /**
     * Uploads "My Tags" and "Recent" (cache A) to the server.
     */
    @objc func uploadToServer() {
        server.upload([CYLContactTagStore.mineCacheKey: store.tags, CYLContactTagStore.recentCacheKey: store.recentTags])
    }

    /**
     * The sync button: another device edits the server's data (a random new tag, the first two tags swapped), then
     * this device pulls it, with the server's delay and HUD.
     */
    @objc func syncFromOtherDevices() {
        server.simulateOtherDeviceEdit(localTags: store.tags)
        server.fetchSections(withKeys: [CYLContactTagStore.mineCacheKey]) { [weak self] sections, _ in
            guard let self, let sections else { return }
            if self.store.apply(sections) {
                self.reload()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The free space: below the tags shown ("+ New tag" stays visible and tappable above it) and above the keyboard,
        // so the keyboard never covers the placeholder.
        let top = tagListView.frame.minY + tagListView.contentHeight
        let bottom = min(view.bounds.maxY - view.safeAreaInsets.bottom, view.keyboardLayoutGuide.layoutFrame.minY)
        placeholderArea.frame = CGRect(x: 16, y: top, width: max(0, view.bounds.width - 32), height: max(0, bottom - top))
        layoutPlaceholder()
    }

    /**
     * Centres the placeholder at its fitting size in the free space; in a short space (a raised keyboard) it keeps its
     * top edge. CYLPlaceholderView reports its content size through `reportsContentSize` and `preferredMaxLayoutWidth`.
     */
    private func layoutPlaceholder() {
        guard let placeholder = placeholderView else { return }
        let area = placeholderArea.bounds
        placeholder.reportsContentSize = true
        placeholder.preferredMaxLayoutWidth = area.width
        let size = placeholder.intrinsicContentSize
        let width = min(size.width, area.width)
        placeholder.frame = CGRect(x: (area.width - width) / 2, y: max(0, (area.height - size.height) / 2),
                                   width: width, height: size.height)
    }

    // MARK: Content

    /**
     * The sections for the current query: "Recent" and "My Tags", or "Search Results".
     */
    func makeSections() -> [Section] {
        if !query.isEmpty {
            var items = store.tags(matching: query).map(Item.tag)
            if store.canCreate(query) {
                items.append(.create(query))
            }
            return [Section(kind: .results, title: cylContactTagsText("results"), items: items)]
        }
        var sections: [Section] = []
        if !store.recentTags.isEmpty {
            sections.append(Section(kind: .recent, title: cylContactTagsText("recent"), items: store.recentTags.map(Item.tag)))
        }
        // While managing, the list's add control replaces "+ New Tag".
        let create: [Item] = isManaging ? [] : [.create(nil)]
        sections.append(Section(kind: .mine, title: cylContactTagsText("mine"), items: store.tags.map(Item.tag) + create))
        return sections
    }

    /**
     * Rebuilds the sections and the buttons from the store, the query and the selection.
     */
    func reload() {
        sections = makeSections()
        manageButton.setTitle(cylContactTagsText(isManaging ? "doneManaging" : "manage"), for: .normal)
        manageButton.accessibilityHint = cylContactTagsText(isManaging ? "hintDoneManaging" : "hintManage")
        manageButton.sizeToFit()
        tagListView.reloadMenuData()
        syncSelection()
        updateDoneButton()
        updatePlaceholder()
    }

    /**
     * The empty state for the store and the query: no match for a search, or no tags at all.
     */
    func makeEmptyState() -> EmptyState {
        if !query.isEmpty {
            return store.tags(matching: query).isEmpty ? .noMatch : .none
        }
        return store.tags.isEmpty ? .noTags : .none
    }

    /**
     * Shows CYLPlaceholderView for the empty state (a new one when the state changes), or hides it.
     */
    private func updatePlaceholder() {
        let state = makeEmptyState()
        defer {
            placeholderArea.isHidden = state == .none
            view.setNeedsLayout()
        }
        guard state != emptyState else { return }
        emptyState = state
        placeholderView?.removeFromSuperview()
        placeholderView = nil
        let placeholder: CYLPlaceholderView
        switch state {
        case .none:
            return
        case .noMatch:
            placeholder = CYLPlaceholderView(style: .noResults, text: cylContactTagsText("noMatch"))
        case .noTags:
            placeholder = CYLPlaceholderView(style: .empty, text: cylContactTagsText("noTags"))
        }
        placeholder.accessibilityIdentifier = "CYLContactTagsPlaceholder"
        placeholderArea.addSubview(placeholder)
        placeholderView = placeholder
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }

    /**
     * Shows every occurrence of a selected tag as selected (a tag in both sections).
     */
    func syncSelection() {
        var indexPaths: [IndexPath] = []
        for (section, content) in sections.enumerated() {
            for (item, element) in content.items.enumerated() {
                if case let .tag(tag) = element, selectedTags.contains(tag) {
                    indexPaths.append(IndexPath(item: item, section: section))
                }
            }
        }
        tagListView.selectedIndexPaths = indexPaths
    }

    /**
     * "Done" is green with a selection or a change, and off while searching.
     */
    var isDoneEnabled: Bool {
        query.isEmpty && (!selectedTags.isEmpty || Set(selectedTags) != Set(initialSelection))
    }

    private func updateDoneButton() {
        doneButton.isEnabled = isDoneEnabled
        doneButton.backgroundColor = isDoneEnabled ? CYLContactTagEditorViewController.green : .secondarySystemFill
    }

    /**
     * Where `tag` is shown first, if it is.
     */
    func indexPath(of tag: String) -> IndexPath? {
        for (section, content) in sections.enumerated() {
            if let item = content.items.firstIndex(of: .tag(tag)) {
                return IndexPath(item: item, section: section)
            }
        }
        return nil
    }

    // MARK: Actions

    /**
     * As typing `text` in the search bar.
     */
    @objc(setQuery:)
    func setQuery(_ text: String) {
        searchBar.text = text
        queryChanged(text)
    }

    private func queryChanged(_ text: String) {
        if isManaging && !text.isEmpty {
            // Searching leaves "Manage".
            tagListView.setEditing(false, animated: false)
        }
        query = CYLContactTagStore.normalizedName(text)
        reload()
    }

    /**
     * Selects `tag`.
     */
    func select(_ tag: String) {
        if !selectedTags.contains(tag) {
            selectedTags.append(tag)
        }
        syncSelection()
        updateDoneButton()
    }

    /**
     * Deselects `tag`.
     */
    func deselect(_ tag: String) {
        selectedTags.removeAll { $0 == tag }
        syncSelection()
        updateDoneButton()
    }

    /**
     * Creates the tag (or finds it), selects it, leaves the search and scrolls to it.
     */
    @discardableResult
    @objc(createTagNamed:)
    func createTag(named name: String) -> String? {
        guard let tag = store.createTag(named: name) else { return nil }
        if !selectedTags.contains(tag) {
            selectedTags.append(tag)
        }
        searchBar.text = ""
        query = ""
        searchBar.hideKeyboard()
        reload()
        if let indexPath = indexPath(of: tag), sections[indexPath.section].kind == .mine {
            tagListView.scrollToItem(at: indexPath, animated: false)
        }
        UIAccessibility.post(notification: .announcement, argument: cylContactTagsText("created", tag))
        return tag
    }

    private func promptForNewTag() {
        let alert = UIAlertController(title: cylContactTagsText("newTag"), message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = cylContactTagsText("tagName")
            field.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: cylContactTagsText("cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: cylContactTagsText("ok"), style: .default) { [weak self, weak alert] _ in
            self?.createTag(named: alert?.textFields?.first?.text ?? "")
        })
        present(alert, animated: true)
    }

    @objc private func toggleManaging() {
        if isManaging {
            tagListView.setEditing(false, animated: true)
        } else {
            setQuery("")
            searchBar.hideKeyboard()
            tagListView.setEditing(true, animated: true)
        }
        reload()
    }

    @objc private func clearRecent() {
        store.clearRecent()
        reload()
        UIAccessibility.post(notification: .announcement, argument: cylContactTagsText("recentCleared"))
    }

    /**
     * Pushes the contacts that have `tag`.
     */
    @discardableResult
    @objc(showContactsWithTag:)
    func showContacts(withTag tag: String) -> UIViewController {
        let list = CYLContactListViewController(tag: tag, contacts: store.contacts(withTag: tag))
        navigationController?.pushViewController(list, animated: true)
        return list
    }

    /**
     * Deletes `tag` from the store and the selection.
     */
    @objc(deleteTag:)
    func deleteTag(_ tag: String) {
        store.deleteTag(tag)
        selectedTags.removeAll { $0 == tag }
        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The sheet draws its own header; the contacts page shows the navigation bar.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc private func cancel() {
        dismiss(animated: true)
    }

    @objc private func done() {
        guard isDoneEnabled else { return }
        store.markUsed(selectedTags)
        onDone?(selectedTags)
        dismiss(animated: true)
    }
}

// MARK: - CYLSearchBarViewDelegate

extension CYLContactTagEditorViewController: CYLSearchBarViewDelegate {

    func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String) {
        queryChanged(text)
    }

    /**
     * The keyboard's search key creates the tag typed when it does not exist yet.
     */
    func searchBarView(_ searchBarView: CYLSearchBarView, shouldSubmitText text: String) -> Bool {
        if store.canCreate(query) {
            createTag(named: query)
        } else {
            searchBarView.hideKeyboard()
        }
        return false
    }
}

// MARK: - CYLMenuDataSource

extension CYLContactTagEditorViewController: CYLMenuDataSource {

    func numberOfSectionsInMenu() -> Int {
        sections.count
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        sections[section].items.count
    }

    func menuTitle(forSection section: Int) -> String {
        sections[section].title
    }

    /**
     * A tag's name; for "+ New Tag" the name to create ("" asks for one). The menu draws the create item with its plus
     * icon and its own localized title.
     */
    func menuTitleForItem(at indexPath: IndexPath) -> String {
        switch sections[indexPath.section].items[indexPath.item] {
        case let .tag(tag): return tag
        case let .create(name): return name ?? ""
        }
    }

    func menuItemType(at indexPath: IndexPath) -> CYLMenuItemType {
        if case .create = sections[indexPath.section].items[indexPath.item] {
            return .create
        }
        return .tag
    }

    /**
     * In "Manage" mode a tap on a tag of "My Tags" opens its contacts (the delete button and dragging are the list's,
     * with their own VoiceOver actions).
     */
    func menuAccessibilityHintForItem(at indexPath: IndexPath) -> String? {
        guard isManaging, sections[indexPath.section].kind == .mine,
              case .tag = sections[indexPath.section].items[indexPath.item] else { return nil }
        return cylContactTagsText("hintContacts")
    }

    func menuAccessoryView(forSection section: Int) -> UIView? {
        switch sections[section].kind {
        case .mine: return manageButton
        case .recent: return clearRecentButton
        case .results: return nil
        }
    }

    /**
     * Only "My Tags" takes part in "Manage" (delete buttons, dragging, the add control).
     */
    func menuSectionAllowsEditing(_ section: Int) -> Bool {
        sections.indices.contains(section) && sections[section].kind == .mine
    }

    /**
     * Stable cache keys: "Recent" comes and goes, so section indexes would change.
     */
    func menuCacheKey(forSection section: Int) -> String {
        switch sections[section].kind {
        case .recent: return CYLContactTagStore.recentCacheKey
        case .mine: return CYLContactTagStore.mineCacheKey
        case .results: return "results"
        }
    }

    /**
     * A delete button in "Manage" mode.
     */
    func menuRemoveItem(at indexPath: IndexPath) {
        guard case let .tag(tag) = sections[indexPath.section].items[indexPath.item] else { return }
        store.deleteTag(tag)
        selectedTags.removeAll { $0 == tag }
        sections = makeSections()
    }

    /**
     * A drag in "Manage" mode.
     */
    func menuMoveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        store.moveTag(from: sourceIndexPath.item, to: destinationIndexPath.item)
        sections = makeSections()
    }
}

// MARK: - CYLMenuDelegate

extension CYLContactTagEditorViewController: CYLMenuDelegate {

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        guard case let .tag(tag) = sections[indexPath.section].items[indexPath.item] else { return }
        if isManaging {
            showContacts(withTag: tag)
        } else {
            select(tag)
        }
    }

    /**
     * "+ New Tag": with the searched name, creates it; otherwise asks for one.
     */
    func menu(_ menu: Any, didRequestNewItemWithName name: String, at indexPath: IndexPath) {
        if isManaging {
            // The add control in "Manage" mode: added at the end of "My Tags", the list stays in editing mode.
            store.createTag(named: name)
            reload()
            if let indexPath = self.indexPath(of: CYLContactTagStore.normalizedName(name)) {
                tagListView.scrollToItem(at: indexPath, animated: true)
            }
            return
        }
        if name.isEmpty {
            promptForNewTag()
        } else {
            createTag(named: name)
        }
    }

    func menu(_ menu: Any, didChangeEditing editing: Bool) {
        reload()
    }

    func menu(_ menu: Any, didDeselectItemAt indexPath: IndexPath) {
        if case let .tag(tag) = sections[indexPath.section].items[indexPath.item] {
            deselect(tag)
        }
    }
}
