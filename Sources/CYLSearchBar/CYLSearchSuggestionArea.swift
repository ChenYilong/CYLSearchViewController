//
//  CYLSearchSuggestionArea.swift
//  CYLSearchViewController
//
//  The suggestion area of the search core, written once (docs/qmui-search-controller.md, "Merge design", row
//  `launchView`, and "Merge phase 2 log"): the tags of CollectionViewClassifyMenu's `CYLTagListView` folded with a
//  trailing fold control, and the header above cached queries with its title and clear button. `CYLSearchView` installs
//  these views into its page (they are its public `suggestionsTagView`, `suggestionCacheHeaderView`,
//  `suggestionCacheTitleLabel` and `clearSuggestionCacheButton`); `CYLSearchController` shows them as its launch view.
//

import CollectionViewClassifyMenu
import UIKit

/**
 * Owns, styles and lays out the views of the suggestion area, and, when it has a `cache`, fills them with the history
 * (newest first) or else with `suggestions`. A host (the search page, or the launch view of the search controller)
 * installs the views into its own view and calls `layout(in:headerHeight:)`.
 */
final class CYLSearchSuggestionArea: NSObject {

    let tagView = CYLTagListView(foldControl: CYLMenuFoldControl(position: .tail, content: .icon))
    let headerView = UIView()
    let titleLabel = UILabel()
    let clearButton = UIButton(type: .system)

    /**

     * A tag was tapped: its index in `titles` and its title.

     */
    var onSelect: ((Int, String) -> Void)?
    /**
     * The clear button was tapped; without a handler the area clears its `cache`.
     */
    var onClear: (() -> Void)?
    /**
     * The height of the tags changed (folding, unfolding, other titles): the host lays out again.
     */
    var onHeightChange: (() -> Void)?

    /**

     * The titles the tags show.

     */
    private(set) var titles: [String] = []

    /**

     * The store of submitted queries: the area shows it (header, tags) while it holds queries.

     */
    var cache: CYLSearchSuggestionCache? {
        didSet { reload() }
    }

    /**

     * What the tags show while the cache is empty or nil.

     */
    var suggestions: [String] = [] {
        didSet { reload() }
    }

    /**

     * Whether the tags show the history of the cache (the header is shown over it).

     */
    private(set) var showsHistory = false

    private lazy var menuObserver = CYLSearchTagMenuObserver { [weak self] in self?.onHeightChange?() }

    override init() {
        super.init()
        tagView.isHidden = true
        tagView.showsSectionHeaders = false
        tagView.accessibilityLabel = CYLSearchResources.localizedString(forKey: "search.suggestions")
        tagView.defaultVisibleRows = 2
        // Folding and unfolding change the tags' height: the host lays out again (the page can be as tall as its content).
        tagView.menuDelegate = menuObserver
        tagView.tagClickHandler = { [weak self] index, _ in
            guard let self, self.titles.indices.contains(index) else { return }
            self.onSelect?(index, self.titles[index])
        }
        // iOS 26 softens the top edge of a scroll view with a blur: it would blur the first tag row under the search bar.
        Self.hidesTopEdgeEffect(in: tagView)
        titleLabel.text = CYLSearchResources.localizedString(forKey: "search.recent")
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .secondaryLabel
        titleLabel.accessibilityTraits = .header
        headerView.addSubview(titleLabel)
        clearButton.setImage(UIImage(systemName: "trash"), for: .normal)
        clearButton.tintColor = .secondaryLabel
        clearButton.accessibilityLabel = CYLSearchResources.localizedString(forKey: "search.clearRecent")
        clearButton.accessibilityIdentifier = "CYLSearchClearSuggestionCache"
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        headerView.addSubview(clearButton)
        headerView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)),
                                               name: CYLSearchSuggestionStore.didChangeNotification, object: nil)
    }

    /**

     * Adds the tags, then the header over them, to `host`.

     */
    func install(in host: UIView) {
        host.addSubview(tagView)
        host.addSubview(headerView)
    }

    /**

     * The height of the header: 0 while it is not `shown`.

     */
    func headerHeight(shown: Bool) -> CGFloat {
        shown ? max(44, ceil(titleLabel.font.lineHeight) + 16) : 0
    }

    /**
     * Places the header at the top of `area` and the tags under it; returns the rectangle left under the header.
     */
    @discardableResult
    func layout(in area: CGRect, headerHeight: CGFloat) -> CGRect {
        headerView.frame = CGRect(x: area.minX, y: area.minY, width: area.width, height: headerHeight)
        clearButton.frame = CGRect(x: area.width - 44 - 4, y: 0, width: 44, height: headerHeight)
        titleLabel.frame = CGRect(x: 16, y: 0, width: max(0, area.width - 16 - 52), height: headerHeight)
        let list = area.inset(by: UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0))
        tagView.frame = list
        return list
    }

    /**

     * Shows `titles` as tags.

     */
    func setTitles(_ titles: [String]) {
        self.titles = titles
        tagView.setTags(withTitles: titles)
    }

    /**

     * Reads the cache again: the history, newest first, or else `suggestions`.

     */
    func reload() {
        let history = cache?.cachedQueries() ?? []
        showsHistory = !history.isEmpty
        headerView.isHidden = !showsHistory
        tagView.isHidden = false
        setTitles(showsHistory ? history : suggestions)
        onHeightChange?()
    }

    @objc private func clearTapped() {
        if let onClear {
            onClear()
        } else if let cache {
            cache.removeAllQueries()
            CYLSearchSuggestionStore.announceChange(of: cache)
            reload()
            UIAccessibility.post(notification: .announcement, argument: CYLSearchResources.localizedString(forKey: "search.recentCleared"))
        }
    }

    // The history signal: one notification for every change of a store, whoever made it.
    @objc private func storeChanged(_ notification: Notification) {
        if CYLSearchSuggestionStore.matches(notification, cache) { reload() }
    }

    private static func hidesTopEdgeEffect(in view: UIView) {
        if #available(iOS 26.0, *) {
            (view as? UIScrollView)?.topEdgeEffect.isHidden = true
            view.subviews.forEach { hidesTopEdgeEffect(in: $0) }
        }
    }
}

/**
 * The launch view of `CYLSearchController` (`showsSuggestionsLaunchView`): the suggestion area filling the space under the
 * search bar. It reads the history again each time it comes on screen.
 */
final class CYLSearchSuggestionsLaunchView: UIView {

    let area = CYLSearchSuggestionArea()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        accessibilityIdentifier = "CYLSearchSuggestionsLaunchView"
        area.install(in: self)
        area.onHeightChange = { [weak self] in self?.setNeedsLayout() }
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil { area.reload() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let safe = safeAreaInsets
        let content = CGRect(x: safe.left, y: 0, width: max(0, bounds.width - safe.left - safe.right), height: bounds.height)
        area.layout(in: content, headerHeight: area.headerHeight(shown: area.showsHistory))
    }
}

/**
 * Forwards the tag list's height changes (folding, unfolding) to the host of the suggestion area.
 */
final class CYLSearchTagMenuObserver: NSObject, CYLMenuDelegate {
    private let heightChanged: () -> Void

    init(heightChanged: @escaping () -> Void) {
        self.heightChanged = heightChanged
    }

    func menu(_ menu: Any, didChangeContentHeight height: CGFloat) {
        heightChanged()
    }

    func menu(_ menu: Any, didChangeExpanded expanded: Bool, inSection section: Int) {
        heightChanged()
    }
}

// MARK: - History signal

extension CYLSearchSuggestionStore {

    /**
     * Posted after a built-in store changed (object: the store); `announceChange(of:)` posts it for a store of the app's
     * own. A listener compares the stores with `matches(_:_:)`: `CYLSearchResources.suggestionCache(policy:name:)` returns
     * a new instance on each call, so the instances of one history are told apart by policy and name.
     */
    static let didChangeNotification = Notification.Name("CYLSearchSuggestionStoreDidChange")

    /**

     * Posts `didChangeNotification` for `cache` unless it is a built-in store, which posts by itself.

     */
    static func announceChange(of cache: CYLSearchSuggestionCache) {
        guard !(cache is CYLSearchSuggestionStore) else { return }
        NotificationCenter.default.post(name: didChangeNotification, object: cache)
    }

    /**

     * Whether `notification` tells that `cache` (or another instance of the same history) changed.

     */
    static func matches(_ notification: Notification, _ cache: CYLSearchSuggestionCache?) -> Bool {
        guard let cache, let object = notification.object else { return false }
        if let changed = object as? CYLSearchSuggestionStore, let own = cache as? CYLSearchSuggestionStore {
            return changed.policy == own.policy && changed.name == own.name
        }
        return (object as AnyObject) === (cache as AnyObject)
    }
}
