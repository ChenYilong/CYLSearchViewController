//
//  CYLContactTagEditorViewController.swift
//  CYLSearchExample
//
//  "Edit Tags": a sheet for choosing a contact's tags, as in a chat app, ported from CollectionViewClassifyMenu's
//  CYLTagEditorExample (CYLTagEditorViewController). The search field is this library's CYLSearchBarView; the tags are
//  CollectionViewClassifyMenu's CYLTagListView.
//  - "Recent" and "My Tags" (with "Manage") list the tags; a selected tag is green, in both sections.
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
     * In "Manage" mode a tap on one of "My Tags" deletes the tag (after a confirmation).
     */
    private(set) var isManaging = false

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
    let tagListView = CYLTagListView()

    /**
     * The search bar (this library).
     */
    let searchBar = CYLSearchBarView(frame: .zero)

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
        for case let scrollView as UIScrollView in tagListView.subviews {
            scrollView.keyboardDismissMode = .onDrag
        }

        placeholderArea.isUserInteractionEnabled = false
        placeholderArea.isHidden = true
        for subview in [cancelButton, titleLabel, doneButton, searchBar, tagListView] as [UIView] {
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
            searchBar.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            tagListView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tagListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tagListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        reload()
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
        sections.append(Section(kind: .mine, title: cylContactTagsText("mine"), items: store.tags.map(Item.tag) + [.create(nil)]))
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
        isManaging.toggle()
        reload()
    }

    private func confirmDeleting(_ tag: String) {
        let alert = UIAlertController(title: cylContactTagsText("deleteTitle", tag), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cylContactTagsText("cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: cylContactTagsText("delete"), style: .destructive) { [weak self] _ in
            self?.deleteTag(tag)
        })
        present(alert, animated: true)
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

    func menuItemIsSelectable(at indexPath: IndexPath) -> Bool {
        !isManaging
    }

    /**
     * In "Manage" mode a tag of "My Tags" is deleted by a tap: VoiceOver says so.
     */
    func menuAccessibilityHintForItem(at indexPath: IndexPath) -> String? {
        guard isManaging, sections[indexPath.section].kind == .mine,
              case .tag = sections[indexPath.section].items[indexPath.item] else { return nil }
        return cylContactTagsText("hintDelete")
    }

    func menuAccessoryView(forSection section: Int) -> UIView? {
        sections[section].kind == .mine ? manageButton : nil
    }
}

// MARK: - CYLMenuDelegate

extension CYLContactTagEditorViewController: CYLMenuDelegate {

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        guard case let .tag(tag) = sections[indexPath.section].items[indexPath.item] else { return }
        if isManaging {
            confirmDeleting(tag)
        } else {
            select(tag)
        }
    }

    /**
     * "+ New Tag": with the searched name, creates it; otherwise asks for one.
     */
    func menu(_ menu: Any, didRequestNewItemWithName name: String, at indexPath: IndexPath) {
        if name.isEmpty {
            promptForNewTag()
        } else {
            createTag(named: name)
        }
    }

    func menu(_ menu: Any, didDeselectItemAt indexPath: IndexPath) {
        if case let .tag(tag) = sections[indexPath.section].items[indexPath.item] {
            deselect(tag)
        }
    }
}
