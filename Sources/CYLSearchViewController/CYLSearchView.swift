import UIKit

/**
 * Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button.
 */
@objc(CYLSearchViewDelegate)
public protocol CYLSearchViewDelegate: NSObjectProtocol {
    /**
     * The search view finished opening (MaterialSearchView `onSearchViewShown`).
     */
    @objc(searchViewDidShow:)
    optional func searchViewDidShow(_ searchView: CYLSearchView)

    /**
     * The search view finished closing (MaterialSearchView `onSearchViewClosed`).
     */
    @objc(searchViewDidClose:)
    optional func searchViewDidClose(_ searchView: CYLSearchView)

    /**
     * The query changed (`onQueryTextChange`).
     */
    @objc(searchView:textDidChange:)
    optional func searchView(_ searchView: CYLSearchView, textDidChange text: String)

    /**
     * The query was submitted (`onQueryTextSubmit`). Return YES when you handled it and the search view stays open;
     * return NO (or leave this method out) to let the search view close.
     */
    @objc(searchView:didSubmitText:)
    optional func searchView(_ searchView: CYLSearchView, didSubmitText text: String) -> Bool

    /**
     * The field started or stopped editing (lapism `OnFocusChangeListener`).
     */
    @objc(searchView:didChangeFocus:)
    optional func searchView(_ searchView: CYLSearchView, didChangeFocus focused: Bool)

    /**
     * A suggestion was tapped (MaterialSearchView `setOnItemClickListener`). The field shows it first, and it is
     * submitted when `submitsOnSuggestionSelection` is YES.
     */
    @objc(searchView:didSelectSuggestion:atIndex:)
    optional func searchView(_ searchView: CYLSearchView, didSelectSuggestion suggestion: String, at index: UInt)

    /**
     * The voice button was tapped. Start speech recognition and pass the result to `-setQuery:submit:`.
     */
    @objc(searchViewVoiceButtonClicked:)
    optional func searchViewVoiceButtonClicked(_ searchView: CYLSearchView)

    /**
     * The navigation button (the back arrow by default) was tapped. Without this method it closes the search view.
     */
    @objc(searchViewNavigationButtonClicked:)
    optional func searchViewNavigationButtonClicked(_ searchView: CYLSearchView)
}

/**
 * A search page that opens over its host view: a `CYLSearchBarView` at the top of the safe area, a divider, a list
 * of suggestions filtered as you type, and an optional content view of yours below (MiguelCatalan and lapism
 * `MaterialSearchView`). The page is opaque, so the bar never covers a view of the host.
 */
@objc(CYLSearchView)
public final class CYLSearchView: UIView, CYLSearchBarViewDelegate, UITableViewDataSource, UITableViewDelegate {

    private static let cellIdentifier = "CYLSearchSuggestionCell"

    /**
     * Receives the events of the search view.
     */
    @objc public weak var delegate: CYLSearchViewDelegate?

    /**
     * The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button).
     */
    @objc public let searchBarView = CYLSearchBarView(frame: .zero)

    /**
     * The line under the search bar.
     */
    @objc public let dividerView = UIView()

    /**
     * The table that lists the suggestions.
     */
    @objc public let suggestionsTableView = UITableView(frame: .zero, style: .plain)

    private let pageView = UIView()
    private let scrimView = UIControl()
    private var suggestionsVisible = false
    private var keyboardOverlap: CGFloat = 0
    private var customDividerColor: UIColor?
    private var customSuggestionTextColor: UIColor?
    private var customSuggestionImageTintColor: UIColor?

    /**
     * The color of `dividerView` (lapism `setDividerColor`). `separatorColor` by default; clear hides it.
     */
    @objc public var dividerColor: UIColor! {
        get { customDividerColor ?? .separator }
        set { customDividerColor = newValue; applyStyle() }
    }

    /**
     * A view of yours shown under the divider, behind the suggestions (lapism `addView`): a results list, a
     * history, anything. Nil by default.
     */
    @objc public var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let contentView {
                pageView.insertSubview(contentView, belowSubview: suggestionsTableView)
            }
            setNeedsLayout()
        }
    }

    /**
     * The color behind the page while it is open (lapism `setScrimColor`). Nil (none) by default; the page itself
     * uses `backgroundColor`, `systemBackgroundColor` by default.
     */
    @objc public var scrimColor: UIColor? { didSet { applyStyle() } }

    // MARK: - Suggestions

    /**
     * The suggestions to filter as the text changes (MaterialSearchView `setSuggestions`).
     */
    @objc public var suggestions: [String] = [] { didSet { refilter() } }

    /**
     * Decides whether a suggestion matches the query. Nil uses a case- and diacritic-insensitive "contains" test.
     * An empty query matches nothing unless `showsSuggestionsForEmptyQuery` is YES.
     */
    @objc public var suggestionFilter: ((String, String) -> Bool)? { didSet { refilter() } }

    /**
     * Lists every suggestion while the query is empty. NO by default.
     */
    @objc public var showsSuggestionsForEmptyQuery = false { didSet { refilter() } }

    /**
     * The suggestions that match the current query, in their original order.
     */
    @objc public private(set) var filteredSuggestions: [String] = []

    /**
     * The icon before each suggestion (MaterialSearchView `setSuggestionIcon`). `magnifyingglass` by default; nil
     * shows none.
     */
    @objc public var suggestionImage: UIImage? = UIImage(systemName: "magnifyingglass") { didSet { suggestionsTableView.reloadData() } }

    /**
     * The tint of `suggestionImage`. `secondaryLabelColor` by default.
     */
    @objc public var suggestionImageTintColor: UIColor! {
        get { customSuggestionImageTintColor ?? .secondaryLabel }
        set { customSuggestionImageTintColor = newValue; suggestionsTableView.reloadData() }
    }

    /**
     * The background of the suggestion rows (`setSuggestionBackground`). Nil keeps the page background.
     */
    @objc public var suggestionBackgroundColor: UIColor? {
        didSet {
            suggestionsTableView.backgroundColor = suggestionBackgroundColor ?? .clear
            suggestionsTableView.reloadData()
        }
    }

    /**
     * The color of the suggestion text. `labelColor` by default.
     */
    @objc public var suggestionTextColor: UIColor! {
        get { customSuggestionTextColor ?? .label }
        set { customSuggestionTextColor = newValue; suggestionsTableView.reloadData() }
    }

    /**
     * How a long suggestion is cut (MaterialSearchView `setEllipsize`). `NSLineBreakByWordWrapping` by default (whole
     * text on several lines); `NSLineBreakByTruncatingTail` keeps one line with an ellipsis.
     */
    @objc public var suggestionLineBreakMode: NSLineBreakMode = .byWordWrapping { didSet { suggestionsTableView.reloadData() } }

    /**
     * Submits a suggestion as soon as it is tapped (`setSubmitOnClick`). NO by default: the field shows it and the
     * person can edit it.
     */
    @objc public var submitsOnSuggestionSelection = false

    /**
     * Configures each suggestion cell after the defaults (a custom adapter's `getView`). Optional.
     */
    @objc public var suggestionCellConfiguration: ((UITableViewCell, String, UInt) -> Void)? { didSet { suggestionsTableView.reloadData() } }

    // MARK: - Opening and closing

    /**
     * YES while the search view is open (MaterialSearchView `isSearchOpen`).
     */
    @objc(isSearchOpen) public private(set) var searchOpen = false

    /**
     * The length of the open and close animations, in seconds (`setAnimationDuration`). 0.25 by default.
     */
    @objc public var animationDuration: TimeInterval = 0.25

    /**
     * Closes the search view after a submitted query that the delegate did not handle. YES by default.
     */
    @objc public var closesOnSubmit = true

    /**
     * The current query (lapism `getTextQuery`).
     */
    @objc public var query: String? {
        get { searchBarView.text }
        set { setQuery(newValue, submit: false) }
    }

    /**
     * The page background (the view itself only shows the scrim). `systemBackgroundColor` by default.
     */
    override public var backgroundColor: UIColor? {
        get { pageView.backgroundColor }
        set {
            super.backgroundColor = .clear
            pageView.backgroundColor = newValue ?? .systemBackground
        }
    }

    // MARK: - Initializers

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isHidden = true
        super.backgroundColor = .clear
        scrimView.isAccessibilityElement = false
        scrimView.addTarget(self, action: #selector(closeSearch as () -> Void), for: .touchUpInside)
        addSubview(scrimView)
        pageView.backgroundColor = .systemBackground
        pageView.clipsToBounds = true
        addSubview(pageView)
        searchBarView.navigationIcon = .arrow
        searchBarView.fieldBackgroundColor = .clear
        searchBarView.delegate = self
        pageView.addSubview(searchBarView)
        dividerView.isAccessibilityElement = false
        pageView.addSubview(dividerView)
        suggestionsTableView.dataSource = self
        suggestionsTableView.delegate = self
        suggestionsTableView.rowHeight = UITableView.automaticDimension
        suggestionsTableView.estimatedRowHeight = 48
        suggestionsTableView.keyboardDismissMode = .onDrag
        suggestionsTableView.backgroundColor = .clear
        suggestionsTableView.accessibilityLabel = CYLSearchResources.localizedString(forKey: "search.suggestions")
        suggestionsTableView.isHidden = true
        suggestionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
        pageView.addSubview(suggestionsTableView)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        applyStyle()
    }

    private func applyStyle() {
        dividerView.backgroundColor = dividerColor
        scrimView.backgroundColor = scrimColor ?? .clear
        setNeedsLayout()
    }

    // MARK: - Layout

    override public func layoutSubviews() {
        super.layoutSubviews()
        let safe = safeAreaInsets
        let width = bounds.width
        let barHeight = searchBarView.intrinsicContentSize.height
        let dividerHeight = 1 / max(1, traitCollection.displayScale)
        let top = safe.top + barHeight + dividerHeight
        let bottom = bounds.height
        // With a scrim, the page is only as tall as its content and the host shows through below it; without one,
        // the page fills the view.
        var pageHeight = bottom
        if scrimColor != nil, contentView == nil {
            suggestionsTableView.layoutIfNeeded()
            let listHeight = suggestionsVisible ? suggestionsTableView.contentSize.height : 0
            pageHeight = min(bottom, top + listHeight)
        }
        pageView.frame = CGRect(x: 0, y: 0, width: width, height: pageHeight)
        // The scrim lies only below the page, so nothing sits behind the search bar.
        scrimView.frame = CGRect(x: 0, y: pageHeight, width: width, height: max(0, bottom - pageHeight))
        scrimView.isHidden = scrimColor == nil || pageHeight >= bottom
        searchBarView.frame = CGRect(x: safe.left, y: safe.top, width: width - safe.left - safe.right, height: barHeight)
        dividerView.frame = CGRect(x: 0, y: safe.top + barHeight, width: width, height: dividerHeight)
        let below = CGRect(x: safe.left, y: top, width: width - safe.left - safe.right, height: max(0, pageHeight - top))
        contentView?.frame = below
        suggestionsTableView.frame = below
        var insets = suggestionsTableView.contentInset
        insets.bottom = max(keyboardOverlap - (bottom - pageHeight), safe.bottom)
        suggestionsTableView.contentInset = insets
        suggestionsTableView.verticalScrollIndicatorInsets = insets
    }

    override public func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        setNeedsLayout()
    }

    @objc private func keyboardChanged(_ notification: Notification) {
        guard let window, let keyboard = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let local = convert(keyboard, from: window.screen.coordinateSpace)
        keyboardOverlap = max(0, bounds.maxY - local.minY)
        setNeedsLayout()
    }

    @objc private func keyboardHidden(_ notification: Notification) {
        keyboardOverlap = 0
        setNeedsLayout()
    }

    // MARK: - Opening and closing

    /**
     * Adds the search view over `view` (pinned to its edges) without opening it. `-showSearch` calls it with the key
     * window's root view when the search view has no superview.
     */
    @objc(installInView:)
    public func install(in view: UIView) {
        if superview !== view {
            view.addSubview(self)
        }
        frame = view.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.bringSubviewToFront(self)
    }

    private func defaultHostView() -> UIView? {
        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            if let window = scene.windows.first(where: \.isKeyWindow) {
                return window.rootViewController?.view ?? window
            }
        }
        return nil
    }

    /**
     * Opens the search view with animation and starts editing (`showSearch`).
     */
    @objc public func showSearch() {
        showSearch(animated: true)
    }

    /**
     * Opens the search view and starts editing (`showSearch(animate)`).
     */
    @objc(showSearchAnimated:)
    public func showSearch(animated: Bool) {
        if superview == nil {
            guard let host = defaultHostView() else {
                return
            }
            install(in: host)
        }
        superview?.bringSubviewToFront(self)
        if searchOpen {
            searchBarView.showKeyboard()
            return
        }
        searchOpen = true
        isHidden = false
        accessibilityViewIsModal = true
        refilter()
        setNeedsLayout()
        layoutIfNeeded()
        searchBarView.showKeyboard()
        let finish: (Bool) -> Void = { _ in
            UIAccessibility.post(notification: .screenChanged, argument: self.searchBarView.textField)
            self.delegate?.searchViewDidShow?(self)
        }
        guard animated, animationDuration > 0 else {
            alpha = 1
            finish(true)
            return
        }
        alpha = 0
        pageView.transform = CGAffineTransform(translationX: 0, y: -12)
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.pageView.transform = .identity
        }, completion: finish)
    }

    /**
     * Closes the search view with animation and ends editing (`closeSearch`).
     */
    @objc public func closeSearch() {
        closeSearch(animated: true)
    }

    /**
     * Closes the search view and ends editing.
     */
    @objc(closeSearchAnimated:)
    public func closeSearch(animated: Bool) {
        guard searchOpen else {
            return
        }
        searchOpen = false
        searchBarView.hideKeyboard()
        let finish: (Bool) -> Void = { _ in
            self.isHidden = true
            self.alpha = 1
            self.pageView.transform = .identity
            self.accessibilityViewIsModal = false
            UIAccessibility.post(notification: .screenChanged, argument: nil)
            self.delegate?.searchViewDidClose?(self)
        }
        guard animated, animationDuration > 0 else {
            finish(true)
            return
        }
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            self.pageView.transform = CGAffineTransform(translationX: 0, y: -12)
        }, completion: finish)
    }

    /**
     * Saves whether the search view is open and its query (`onSaveInstanceState`). UIKit calls it for a view with a
     * `restorationIdentifier` inside a restored view controller.
     */
    override public func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(query ?? "", forKey: "CYLSearchViewQuery")
        coder.encode(searchOpen, forKey: "CYLSearchViewOpen")
    }

    /**
     * Restores the query and reopens the search view when it was open (`onRestoreInstanceState`).
     */
    override public func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let query = coder.decodeObject(of: NSString.self, forKey: "CYLSearchViewQuery") as String? {
            setQuery(query, submit: false)
        }
        if coder.decodeBool(forKey: "CYLSearchViewOpen") {
            showSearch(animated: false)
        }
    }

    override public func accessibilityPerformEscape() -> Bool {
        closeSearch()
        return true
    }

    /**
     * Makes a bar button item open the search view (`setMenuItem`).
     */
    @objc(attachToBarButtonItem:)
    public func attach(to item: UIBarButtonItem) {
        item.target = self
        item.action = #selector(showSearch as () -> Void)
    }

    // MARK: - Query and suggestions

    /**
     * Sets the query and submits it when `submit` is YES (`setQuery`, `setTextQuery`).
     */
    @objc(setQuery:submit:)
    public func setQuery(_ query: String?, submit: Bool) {
        searchBarView.text = query
        queryChanged(query ?? "")
        if submit {
            searchBarView.submit()
        }
    }

    private func refilter() {
        let query = searchBarView.text ?? ""
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        filteredSuggestions = suggestions.filter { suggestion in
            if trimmed.isEmpty {
                return showsSuggestionsForEmptyQuery
            }
            if let suggestionFilter {
                return suggestionFilter(suggestion, query)
            }
            return suggestion.range(of: trimmed, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
        suggestionsVisible = !filteredSuggestions.isEmpty
        updateSuggestionsVisibility()
    }

    /**
     * Lists the suggestions that match the current query (`showSuggestions`).
     */
    @objc public func showSuggestions() {
        refilter()
    }

    /**
     * Hides the suggestions (`dismissSuggestions`).
     */
    @objc public func dismissSuggestions() {
        suggestionsVisible = false
        updateSuggestionsVisibility()
    }

    private func updateSuggestionsVisibility() {
        suggestionsTableView.isHidden = !suggestionsVisible
        suggestionsTableView.reloadData()
        setNeedsLayout()
    }

    private func queryChanged(_ text: String) {
        refilter()
        delegate?.searchView?(self, textDidChange: text)
    }

    // MARK: - CYLSearchBarViewDelegate

    /**
     * Filters the suggestions and reports the change.
     */
    public func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String) {
        queryChanged(text)
    }

    /**
     * Reports the submitted query and closes unless the delegate handled it.
     */
    public func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView) {
        let text = searchBarView.text ?? ""
        let handled = delegate?.searchView?(self, didSubmitText: text) ?? false
        if !handled && closesOnSubmit {
            closeSearch()
        } else {
            dismissSuggestions()
        }
    }

    /**
     * Reports the navigation button, or closes the search view.
     */
    public func searchBarViewNavigationButtonClicked(_ searchBarView: CYLSearchBarView) {
        if let delegate, delegate.responds(to: #selector(CYLSearchViewDelegate.searchViewNavigationButtonClicked(_:))) {
            delegate.searchViewNavigationButtonClicked?(self)
        } else {
            closeSearch()
        }
    }

    /**
     * Reports the voice button.
     */
    public func searchBarViewVoiceButtonClicked(_ searchBarView: CYLSearchBarView) {
        delegate?.searchViewVoiceButtonClicked?(self)
    }

    /**
     * Cancel closes the search view.
     */
    public func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView) {
        closeSearch()
    }

    /**
     * Reports focus.
     */
    public func searchBarViewDidBeginEditing(_ searchBarView: CYLSearchBarView) {
        delegate?.searchView?(self, didChangeFocus: true)
    }

    /**
     * Reports the loss of focus.
     */
    public func searchBarViewDidEndEditing(_ searchBarView: CYLSearchBarView) {
        delegate?.searchView?(self, didChangeFocus: false)
    }

    // MARK: - Table

    /**
     * One row per matching suggestion while the suggestions are shown.
     */
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggestionsVisible ? filteredSuggestions.count : 0
    }

    /**
     * A suggestion row: icon, text, background, then `suggestionCellConfiguration`.
     */
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)
        let suggestion = filteredSuggestions[indexPath.row]
        var content = UIListContentConfiguration.cell()
        content.text = suggestion
        content.textProperties.color = suggestionTextColor
        content.textProperties.lineBreakMode = suggestionLineBreakMode
        content.textProperties.numberOfLines = suggestionLineBreakMode == .byWordWrapping || suggestionLineBreakMode == .byCharWrapping ? 0 : 1
        content.image = suggestionImage
        content.imageProperties.tintColor = suggestionImageTintColor
        cell.contentConfiguration = content
        var background = UIBackgroundConfiguration.listPlainCell()
        background.backgroundColor = suggestionBackgroundColor ?? .clear
        cell.backgroundConfiguration = background
        cell.accessibilityTraits.insert(.button)
        suggestionCellConfiguration?(cell, suggestion, UInt(indexPath.row))
        return cell
    }

    /**
     * Fills the field with the suggestion, reports it, and submits it when `submitsOnSuggestionSelection` is YES.
     */
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard filteredSuggestions.indices.contains(indexPath.row) else {
            return
        }
        let suggestion = filteredSuggestions[indexPath.row]
        searchBarView.text = suggestion
        delegate?.searchView?(self, didSelectSuggestion: suggestion, at: UInt(indexPath.row))
        if submitsOnSuggestionSelection {
            searchBarView.submit()
        } else {
            queryChanged(suggestion)
        }
    }
}
