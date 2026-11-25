import CollectionViewClassifyMenu
// CYLTableViewPlaceHolder: the core's placeholder sub-dependency; imported for `CYLPlaceholderScenario`, the type of
// `CYLSearchView.emptyResultsScenario` (Swift does not see a dependency's types through the core).
import CYLTableViewPlaceHolder
import CYLSearchViewController
import Flutter
import UIKit

/**
 * Registers the platform views of CYLSearchViewController for Flutter: `cyl_search/search_view` (`CYLSearchView`),
 * `cyl_search/search_bar_view` (`CYLSearchBarView`, or its editing bar), `cyl_search/tag_list_view`
 * (CollectionViewClassifyMenu's `CYLTagListView`) and `cyl_search/placeholder_view` (CYLTableViewPlaceHolder's
 * `CYLPlaceholderView`). Each view talks to Dart on `cyl_search/view_<id>`.
 */
public final class FlutterCylsearchPlugin: NSObject, FlutterPlugin {

    /**
     * Called by the Flutter engine when the app starts.
     */
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        registrar.register(CYLFlutterViewFactory(messenger: messenger) { frame, id, arguments, channel in
            CYLFlutterSearchView(frame: frame, arguments: arguments, channel: channel)
        }, withId: "cyl_search/search_view")
        registrar.register(CYLFlutterViewFactory(messenger: messenger) { frame, id, arguments, channel in
            CYLFlutterSearchBarView(frame: frame, arguments: arguments, channel: channel)
        }, withId: "cyl_search/search_bar_view")
        registrar.register(CYLFlutterViewFactory(messenger: messenger) { frame, id, arguments, channel in
            CYLFlutterTagListView(frame: frame, arguments: arguments, channel: channel)
        }, withId: "cyl_search/tag_list_view")
        registrar.register(CYLFlutterViewFactory(messenger: messenger) { frame, id, arguments, channel in
            CYLFlutterPlaceholderView(frame: frame, arguments: arguments, channel: channel)
        }, withId: "cyl_search/placeholder_view")
    }
}

/**
 * Makes one kind of platform view with its channel.
 */
final class CYLFlutterViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private let make: @MainActor (CGRect, Int64, [String: Any], FlutterMethodChannel) -> FlutterPlatformView

    init(messenger: FlutterBinaryMessenger, make: @escaping @MainActor (CGRect, Int64, [String: Any], FlutterMethodChannel) -> FlutterPlatformView) {
        self.messenger = messenger
        self.make = make
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let channel = FlutterMethodChannel(name: "cyl_search/view_\(viewId)", binaryMessenger: messenger)
        // The engine creates platform views on the main thread.
        return MainActor.assumeIsolated { make(frame, viewId, args as? [String: Any] ?? [:], channel) }
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

/**
 * One row of the results Dart sent: its text and its index in Dart's `results` list.
 */
final class CYLFlutterSearchResult: NSObject {
    let text: String
    let index: Int

    init(text: String, index: Int) {
        self.text = text
        self.index = index
    }
}

/**
 * The results data source of a `CYLFlutterSearchView`: Dart filters the results itself, so every query gets the list
 * Dart sent last.
 */
@MainActor
final class CYLFlutterSearchResultsDataSource: NSObject, CYLSearchViewDataSource {
    var results: [String] = []

    func searchView(_ searchView: CYLSearchView, resultsForQuery query: String) -> [Any] {
        results.enumerated().map { CYLFlutterSearchResult(text: $0.element, index: $0.offset) }
    }

    func searchView(_ searchView: CYLSearchView, configureResultCell cell: UITableViewCell, withResult result: Any) {
        // The highlight of a match is the core's option (`highlightsResultMatches`), applied after this configuration.
        var content = UIListContentConfiguration.cell()
        content.text = (result as? CYLFlutterSearchResult)?.text ?? ""
        cell.contentConfiguration = content
        cell.accessibilityTraits.insert(.button)
    }
}

/**
 * `CYLSearchView` in a container, open from the start (Dart pops its route in `onClose`).
 */
// Platform views live on the main thread, as the core views they wrap (main-actor isolated).
@MainActor
final class CYLFlutterSearchView: NSObject, @preconcurrency FlutterPlatformView, CYLSearchViewDelegate {
    private let container: UIView
    private let searchView = CYLSearchView(frame: .zero)
    private let channel: FlutterMethodChannel
    // `resultsDataSource` is weak: the platform view keeps it.
    private let resultsDataSource = CYLFlutterSearchResultsDataSource()
    private var appliedResults: [String]?
    // The last history reported to Dart: an event goes out only for a change.
    private var reportedHistory: [String] = []

    init(frame: CGRect, arguments: [String: Any], channel: FlutterMethodChannel) {
        let layoutContainer = CYLFlutterLayoutReportingView(frame: frame)
        container = layoutContainer
        self.channel = channel
        super.init()
        layoutContainer.didLayout = { [weak self] in self?.reportSearchBar() }
        searchView.delegate = self
        // The page stays open after a submit: Dart decides what a submitted query does.
        searchView.closesOnSubmit = false
        apply(arguments)
        searchView.install(in: container)
        searchView.showSearch(animated: false)
        reportedHistory = history()
        // The core's history signal: its stores post a notification after each change (a submit, the trash button, another
        // page of the same name), with the policy and the name of that history.
        NotificationCenter.default.addObserver(self, selector: #selector(historyChanged(_:)), name: CYLSearchResources.historyDidChangeNotification, object: nil)
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }
            switch call.method {
            case "update":
                if let arguments = call.arguments as? [String: Any] {
                    self.apply(arguments)
                }
                result(nil)
            case "setQuery":
                let arguments = call.arguments as? [String: Any] ?? [:]
                self.searchView.setQuery(arguments["query"] as? String, submit: arguments["submit"] as? Bool ?? false)
                result(nil)
            case "beginRefreshing":
                self.searchView.beginRefreshing()
                result(nil)
            case "endRefreshing":
                self.searchView.endRefreshing()
                result(nil)
            case "isRefreshing":
                result(self.searchView.isRefreshing)
            case "reloadResults":
                self.searchView.reloadResults()
                result(nil)
            case "setActive":
                let arguments = call.arguments as? [String: Any] ?? [:]
                let animated = arguments["animated"] as? Bool ?? true
                if arguments["active"] as? Bool ?? true {
                    self.searchView.showSearch(animated: animated)
                } else {
                    self.searchView.closeSearch(animated: animated)
                }
                result(nil)
            case "history":
                result(self.history())
            case "clearHistory":
                // The store's notification reports the change.
                self.searchView.clearSuggestionCache()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func view() -> UIView {
        container
    }

    /// The submitted queries in the page's cache, newest first (the history of the launch view).
    private func history() -> [String] {
        searchView.suggestionCache?.cachedQueries() ?? []
    }

    /// Tells Dart the history when it differs from the one it has (the core's store notification).
    @objc private func historyChanged(_ notification: Notification) {
        guard notification.userInfo?["policy"] as? Int == searchView.suggestionCachePolicy.rawValue,
              notification.userInfo?["name"] as? String == searchView.suggestionCacheName else { return }
        let current = history()
        guard current != reportedHistory else { return }
        reportedHistory = current
        channel.invokeMethod("historyDidChange", arguments: ["history": current])
    }

    /// Tells Dart where the bar ends, in points: Dart lays the launch view, the dimming and the empty view from there down.
    fileprivate func reportSearchBar() {
        let bottom = searchView.searchBarView.convert(searchView.searchBarView.bounds, to: container).maxY
        if bottom != reportedBarBottom, bottom > 0 {
            reportedBarBottom = bottom
            channel.invokeMethod("didLayoutSearchBar", arguments: ["bottom": Double(bottom)])
        }
    }

    private var reportedBarBottom: CGFloat = -1

    private func apply(_ arguments: [String: Any]) {
        // The Flutter app's brightness, whatever the system setting is.
        container.overrideUserInterfaceStyle = (arguments["brightness"] as? String) == "dark" ? .dark : .light
        // Results: a list sets the data source (and reloads the rows when it changed); null removes it.
        let results = arguments["results"] as? [String]
        if results != appliedResults {
            appliedResults = results
            resultsDataSource.results = results ?? []
            if results == nil {
                searchView.resultsDataSource = nil
            } else if searchView.resultsDataSource == nil {
                searchView.resultsDataSource = resultsDataSource
            } else {
                searchView.reloadResults()
            }
        }
        // Refresh: the handler only reports the pull to Dart, which calls `endRefreshing` when it is done.
        let refreshEnabled = arguments["refreshEnabled"] as? Bool ?? false
        if refreshEnabled != (searchView.refreshHandler != nil) {
            if refreshEnabled {
                searchView.refreshHandler = { [weak channel] in
                    channel?.invokeMethod("refresh", arguments: nil)
                }
            } else {
                searchView.refreshHandler = nil
            }
        }
        if let suggestions = arguments["suggestions"] as? [String] { searchView.suggestions = suggestions }
        searchView.suggestionStyle = (arguments["suggestionStyle"] as? String) == "tags" ? .tags : .list
        searchView.searchBarView.placeholder = arguments["placeholder"] as? String
        if let query = arguments["query"] as? String, query != searchView.query { searchView.query = query }
        searchView.showsSuggestionsForEmptyQuery = arguments["showsSuggestionsForEmptyQuery"] as? Bool ?? false
        searchView.submitsOnSuggestionSelection = arguments["submitsOnSuggestionSelection"] as? Bool ?? false
        searchView.emptyResultsScenario = (arguments["emptyResultsScenario"] as? String) == "noContent" ? .noContent : .noSearchResults
        searchView.showsEmptyResultsPlaceholder = arguments["showsEmptyResultsPlaceholder"] as? Bool ?? false
        let policies: [String: CYLSearchSuggestionCachePolicy] = ["none": .none, "database": .database, "userDefaults": .userDefaults, "sandboxFile": .sandboxFile]
        let policy = policies[arguments["suggestionCachePolicy"] as? String ?? ""] ?? .database
        let name = arguments["suggestionCacheName"] as? String ?? "CYLSearchView"
        if policy != searchView.suggestionCachePolicy || name != searchView.suggestionCacheName {
            searchView.suggestionCacheName = name
            searchView.suggestionCachePolicy = policy
        }
        searchView.focusesSearchFieldOnShow = arguments["focusesSearchFieldOnShow"] as? Bool ?? true
        searchView.showsSuggestionCacheHeader = arguments["showsSuggestionCacheHeader"] as? Bool ?? true
        searchView.suggestionsFoldControl = cylFoldControl(arguments["suggestionsFoldControlPosition"], arguments["suggestionsFoldControlContent"])
        searchView.suggestionsFoldedRowCount = UInt(max(0, arguments["suggestionsFoldedRowCount"] as? Int ?? 2))
        searchView.highlightsResultMatches = arguments["highlightsResultMatches"] as? Bool ?? false
        searchView.resultMatchHighlightColor = color(arguments["resultMatchHighlightColor"])
        searchView.scrimColor = color(arguments["scrimColor"])
        searchView.supportsSwipeToDismissSearch = arguments["supportsSwipeToDismissSearch"] as? Bool ?? false
        searchView.noResultsText = (arguments["noResultsText"] as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    private func color(_ value: Any?) -> UIColor? {
        guard let argb = (value as? NSNumber)?.uint32Value else { return nil }
        return UIColor(red: CGFloat((argb >> 16) & 0xFF) / 255, green: CGFloat((argb >> 8) & 0xFF) / 255,
                       blue: CGFloat(argb & 0xFF) / 255, alpha: CGFloat((argb >> 24) & 0xFF) / 255)
    }

    func searchViewWillShow(_ searchView: CYLSearchView) {
        channel.invokeMethod("willShow", arguments: nil)
    }

    func searchViewWillClose(_ searchView: CYLSearchView) {
        channel.invokeMethod("willClose", arguments: nil)
    }

    func searchViewDidShow(_ searchView: CYLSearchView) {
        channel.invokeMethod("didShow", arguments: nil)
    }

    func searchView(_ searchView: CYLSearchView, textDidChange text: String) {
        channel.invokeMethod("textDidChange", arguments: ["text": text])
    }

    func searchView(_ searchView: CYLSearchView, didSubmitText text: String) -> Bool {
        // A tapped tag reports its text as a change before this submit (the core does), so Dart's results follow.
        channel.invokeMethod("didSubmit", arguments: ["text": text])
        return true
    }

    func searchView(_ searchView: CYLSearchView, didSelectSuggestion suggestion: String, at index: UInt) {
        channel.invokeMethod("didSelectSuggestion", arguments: ["suggestion": suggestion, "index": Int(index)])
    }

    func searchViewDidClose(_ searchView: CYLSearchView) {
        channel.invokeMethod("didClose", arguments: nil)
    }

    func searchView(_ searchView: CYLSearchView, didSelectResult result: Any) {
        guard let result = result as? CYLFlutterSearchResult else {
            return
        }
        channel.invokeMethod("didSelectResult", arguments: ["result": result.text, "index": result.index])
    }
}

/**
 * A container that reports each layout, so Dart learns where the search bar ends.
 */
final class CYLFlutterLayoutReportingView: UIView {
    var didLayout: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        didLayout?()
        // The bar is laid out after its parent: report once more on the next turn.
        DispatchQueue.main.async { [weak self] in self?.didLayout?() }
    }
}

/**
 * Holds the core's navigation bar of an embedded search bar. A `UINavigationBar` that is laid out before it is in a window
 * (the Flutter route is still sliding in) takes zero layout margins and no safe area: the back button sat flush with the
 * left edge and the search bar began about 47 px early until the next layout pass (the Discover page, first open). The
 * container lays the bar out again once it is in the window, on every safe area change and on the next turn.
 */
final class CYLFlutterNavigationBarContainer: UIView {
    let navigationBar: CYLSearchNavigationBar

    init(navigationBar: CYLSearchNavigationBar, frame: CGRect) {
        self.navigationBar = navigationBar
        super.init(frame: frame)
        backgroundColor = .clear
        navigationBar.frame = bounds
        navigationBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(navigationBar)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        navigationBar.frame = bounds
        navigationBar.layoutIfNeeded()
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        relayout()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else {
            settleLink?.invalidate()
            settleLink = nil
            return
        }
        relayout()
        DispatchQueue.main.async { [weak self] in self?.relayout() }
        startSettleWatch()
    }

    // A route transition can still be moving this view when it enters the window: the bar lays its items out from the
    // window position of that moment (an inset that is too small) and never again. Watch the window position until it
    // stops moving, then lay the items out once more.
    private var settleLink: CADisplayLink?
    private var lastWindowX: CGFloat = .nan
    private var itemsWindowX: CGFloat = .nan
    private var stableFrames = 0
    private var settleFrames = 0

    private func startSettleWatch() {
        settleLink?.invalidate()
        itemsWindowX = convert(CGPoint.zero, to: nil).x
        lastWindowX = itemsWindowX
        stableFrames = 0
        settleFrames = 0
        let link = CADisplayLink(target: self, selector: #selector(settleTick))
        link.add(to: .main, forMode: .common)
        settleLink = link
    }

    @objc private func settleTick() {
        settleFrames += 1
        let x = convert(CGPoint.zero, to: nil).x
        stableFrames = abs(x - lastWindowX) < 0.5 ? stableFrames + 1 : 0
        lastWindowX = x
        guard stableFrames >= 3 || settleFrames > 120 || window == nil else { return }
        settleLink?.invalidate()
        settleLink = nil
        guard window != nil, abs(x - itemsWindowX) >= 0.5 else { return }
        let items = navigationBar.items
        navigationBar.setItems([], animated: false)
        navigationBar.setItems(items, animated: false)
        relayout()
    }

    private func relayout() {
        navigationBar.setNeedsLayout()
        navigationBar.layoutIfNeeded()
        setNeedsLayout()
    }
}

/**
 * `CYLSearchBarView` filling the platform view; with `editingBar` (read at creation), the core's editing bar
 * (`CYLSearchBarView.editingBar(placeholder:actionTitle:)`), whose submit is sent as `didSubmitEditing`.
 */
// Platform views live on the main thread, as the core views they wrap (main-actor isolated).
@MainActor
final class CYLFlutterSearchBarView: NSObject, @preconcurrency FlutterPlatformView, CYLSearchBarViewDelegate {
    private let bar: CYLSearchBarView
    /// The core's navigation bar holding the bar, when Dart asks for `embedsInNavigationBar`: the page's search bar is
    /// always in a navigation bar.
    private var navigationBar: CYLSearchNavigationBar?
    /// The platform view when the bar is embedded: it lays the navigation bar out again once it is in the window.
    private var container: CYLFlutterNavigationBarContainer?
    private let channel: FlutterMethodChannel

    init(frame: CGRect, arguments: [String: Any], channel: FlutterMethodChannel) {
        if arguments["editingBar"] as? Bool ?? false {
            let title = arguments["actionTitle"] as? String ?? ""
            bar = CYLSearchBarView.editingBar(placeholder: arguments["placeholder"] as? String,
                                              actionTitle: title.isEmpty ? NSLocalizedString("Done", comment: "") : title)
            bar.frame = frame
        } else {
            bar = CYLSearchBarView(frame: frame)
        }
        self.channel = channel
        super.init()
        bar.delegate = self
        if arguments["embedsInNavigationBar"] as? Bool ?? false {
            navigationBar = CYLSearchNavigationBar.holding(bar, showsBackButton: arguments["showsBackButton"] as? Bool ?? false)
            if let navigationBar {
                container = CYLFlutterNavigationBarContainer(navigationBar: navigationBar, frame: frame)
            }
            // The back button of a second-level page: Dart pops its route.
            navigationBar?.backHandler = { [weak channel] in
                channel?.invokeMethod("didTapBackButton", arguments: nil)
            }
        }
        // The editing bar's submit: the trimmed text to Dart, then an empty field for the next name.
        bar.editingSubmitHandler = { [weak channel] bar, text in
            channel?.invokeMethod("didSubmitEditing", arguments: ["text": text])
            bar.text = ""
        }
        apply(arguments)
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }
            let arguments = call.arguments as? [String: Any] ?? [:]
            switch call.method {
            case "update":
                self.apply(arguments)
                result(nil)
            case "beginNewSearch":
                self.bar.beginNewSearch()
                result(nil)
            case "completeSearch":
                self.bar.completeSearch()
                result(nil)
            case "addSearch":
                self.bar.addSearch(arguments["text"] as? String ?? "")
                result(nil)
            case "selectSearch":
                self.bar.selectSearch(at: arguments["index"] as? Int ?? -1)
                result(nil)
            case "removeSearch":
                self.bar.removeSearch(at: arguments["index"] as? Int ?? -1)
                result(nil)
            case "setShowsCancelButton":
                self.bar.setShowsCancelButton(arguments["shows"] as? Bool ?? false, animated: arguments["animated"] as? Bool ?? true)
                result(nil)
            case "showKeyboard":
                self.bar.showKeyboard()
                result(nil)
            case "restartItemAnimation":
                let index = arguments["index"] as? Int ?? -1
                if self.bar.items.indices.contains(index) {
                    self.bar.items[index].restartAnimation()
                }
                result(nil)
            case "searches":
                result(self.bar.searches)
            case "selectedSearchIndex":
                let index = self.bar.selectedSearchIndex
                result(index == NSNotFound ? -1 : index)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func view() -> UIView {
        container ?? bar
    }

    /**
     * True while Dart's `searches` replace the bar's own: the removals are not reported back.
     */
    private var syncingSearches = false

    /**
     * Dart's `searches` as applied last.
     */
    private var appliedSearches: [String] = []

    /**
     * Takes Dart's completed searches when Dart sent another list and it differs from the bar's own, unless a search
     * is being typed.
     */
    private func applySearches(_ searches: [String]) {
        guard bar.mode == .multiple, !bar.isEditingNewSearch, searches != appliedSearches else {
            return
        }
        appliedSearches = searches
        guard searches != bar.searches else {
            return
        }
        syncingSearches = true
        while !bar.searches.isEmpty {
            bar.removeSearch(at: bar.searches.count - 1)
        }
        searches.forEach { bar.addSearch($0) }
        syncingSearches = false
    }

    private func apply(_ arguments: [String: Any]) {
        bar.overrideUserInterfaceStyle = (arguments["brightness"] as? String) == "dark" ? .dark : .light
        let mode: CYLSearchBarMode = (arguments["mode"] as? String) == "multiple" ? .multiple : .single
        if mode != bar.mode { bar.mode = mode }
        applySearches(arguments["searches"] as? [String] ?? [])
        bar.placeholder = arguments["placeholder"] as? String
        let text = arguments["text"] as? String ?? ""
        if !text.isEmpty, text != bar.text { bar.text = text }
        // An editing bar given a new title (Dart's answer to `didRequestRename`) takes focus with the title selected,
        // once per new value, so the rename is typed at once.
        if bar.isEditingBar, !text.isEmpty, text != appliedText {
            DispatchQueue.main.async { [bar] in
                bar.showKeyboard()
                bar.textField.selectAll(nil)
            }
        }
        appliedText = text
        applyStyle(arguments)
        bar.fieldShadowOpacity = CGFloat(arguments["fieldShadowOpacity"] as? Double ?? 0)
        bar.searchBarStyle = (arguments["searchBarStyle"] as? String) == "bordered" ? .bordered : .plain
        if bar.isEditingBar {
            // The core's own setup stays: no magnifier, its action button always shown.
            if let title = arguments["actionTitle"] as? String, !title.isEmpty { bar.cancelButtonTitle = title }
        } else {
            // The widget's flag only when it changed: a controller call (animated) must not be undone by the next update.
            let showsCancel = arguments["showsCancelButton"] as? Bool ?? false
            if showsCancel != appliedShowsCancelButton {
                appliedShowsCancelButton = showsCancel
                bar.showsCancelButton = showsCancel
            }
            bar.searchIcon = arguments["showsSearchIcon"] as? Bool ?? true ? UIImage(systemName: "magnifyingglass") : nil
        }
        let items = arguments["items"] as? [[String: Any]] ?? []
        // Rebuilt only when Dart sends other items, so a rebuild of the widget keeps the native selection; a change of
        // animationLoops or animationSpeed alone keeps the items (the core's setItems).
        if (items as NSArray) != (appliedItems as NSArray) {
            appliedItems = items
            bar.setItems(dictionaries: items)
        }
    }

    private var appliedItems: [[String: Any]] = []

    private func color(_ value: Any?) -> UIColor? {
        guard let argb = (value as? NSNumber)?.uint32Value else { return nil }
        return UIColor(red: CGFloat((argb >> 16) & 0xFF) / 255, green: CGFloat((argb >> 8) & 0xFF) / 255,
                       blue: CGFloat(argb & 0xFF) / 255, alpha: CGFloat((argb >> 24) & 0xFF) / 255)
    }

    /// The style options Dart sends, applied through the core's one `CYLSearchBarAppearance` (`appearanceStyle`) and the
    /// bar's own knobs (`centersPlaceholder`, `textFieldMarginsProvider`, `cancelButtonMarginsProvider`, `cancelButtonFont`).
    private func applyStyle(_ arguments: [String: Any]) {
        let placeholderColor = color(arguments["placeholderColor"])
        let textColor = color(arguments["textColor"])
        let font = (arguments["fontSize"] as? Double).map { UIFont.systemFont(ofSize: CGFloat($0)) }
        if let appearance = arguments["appearance"] as? [String: Any] {
            // One appearance for the bar; assigned again only when Dart sent another one (assigning resets every knob).
            let key = ["appearance": appearance, "placeholder": arguments["placeholder"] ?? NSNull(),
                       "placeholderColor": arguments["placeholderColor"] ?? NSNull(), "textColor": arguments["textColor"] ?? NSNull(),
                       "fontSize": arguments["fontSize"] ?? NSNull()] as NSDictionary
            if !key.isEqual(appliedAppearance) {
                appliedAppearance = key
                let style = CYLSearchBarAppearance()
                // A null value leaves the bar's own default of that property.
                style.textFieldBackgroundColor = color(appearance["fieldBackgroundColor"])
                style.textFieldBorderColor = color(appearance["fieldBorderColor"])
                style.textFieldCornerRadius = CGFloat(appearance["fieldCornerRadius"] as? Double ?? -1)
                style.tintColor = color(appearance["tintColor"])
                style.barBackgroundColor = color(appearance["barBackgroundColor"])
                // The editing bar's action title is Dart's `actionTitle`, not the appearance's.
                style.cancelTitle = bar.isEditingBar ? bar.cancelButtonTitle : (appearance["cancelTitle"] as? String ?? style.cancelTitle)
                style.placeholder = arguments["placeholder"] as? String
                style.placeholderColor = placeholderColor
                style.textColor = textColor
                style.font = font
                bar.appearanceStyle = style
            }
        } else {
            if let value = placeholderColor { bar.placeholderColor = value }
            if let value = textColor { bar.textColor = value }
            if let value = font { bar.font = value }
        }
        bar.centersPlaceholder = arguments["centersPlaceholder"] as? Bool ?? false
        applyMargins(arguments)
        bar.cancelButtonFont = (arguments["cancelButtonFontSize"] as? Double).map { UIFont.systemFont(ofSize: CGFloat($0)) }
    }

    /// Dart's margins as the core's providers: the field's are added to `contentInsets` (Dart's are on top of the native
    /// margins, the provider replaces them), the Cancel button's are the provider's answer; zero in both states installs none.
    private func applyMargins(_ arguments: [String: Any]) {
        func insets(_ value: Any?) -> UIEdgeInsets {
            guard let list = value as? [Double], list.count == 4 else { return .zero }
            return UIEdgeInsets(top: CGFloat(list[1]), left: CGFloat(list[0]), bottom: CGFloat(list[3]), right: CGFloat(list[2]))
        }
        let field = (insets(arguments["textFieldMargins"]), insets(arguments["activeTextFieldMargins"]))
        let cancel = (insets(arguments["cancelButtonMargins"]), insets(arguments["activeCancelButtonMargins"]))
        if field != appliedFieldMargins {
            appliedFieldMargins = field
            if field.0 == .zero, field.1 == .zero {
                bar.textFieldMarginsProvider = nil
            } else {
                bar.textFieldMarginsProvider = { bar, active in
                    let extra = active ? field.1 : field.0
                    let base = bar.contentInsets
                    return UIEdgeInsets(top: base.top + extra.top, left: base.left + extra.left,
                                        bottom: base.bottom + extra.bottom, right: base.right + extra.right)
                }
            }
        }
        if cancel != appliedCancelMargins {
            appliedCancelMargins = cancel
            if cancel.0 == .zero, cancel.1 == .zero {
                bar.cancelButtonMarginsProvider = nil
            } else {
                bar.cancelButtonMarginsProvider = { _, active in active ? cancel.1 : cancel.0 }
            }
        }
    }

    private var appliedAppearance: NSDictionary?
    private var appliedFieldMargins = (UIEdgeInsets.zero, UIEdgeInsets.zero)
    private var appliedCancelMargins = (UIEdgeInsets.zero, UIEdgeInsets.zero)
    private var appliedShowsCancelButton: Bool?

    /**
     * Dart's `text` as applied last (an editing bar takes focus when it changes).
     */
    private var appliedText = ""

    func searchBarView(_ searchBarView: CYLSearchBarView, didSelect item: CYLSearchBarItem) {
        channel.invokeMethod("didSelectItem", arguments: ["index": item.index, "selected": item.isSelected])
    }

    func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String) {
        channel.invokeMethod("textDidChange", arguments: ["text": text])
    }

    func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView) {
        // An editing bar reports its submit as `didSubmitEditing` and keeps the keyboard up for the next name.
        guard !searchBarView.isEditingBar else {
            return
        }
        channel.invokeMethod("didSubmit", arguments: ["text": searchBarView.text ?? ""])
        searchBarView.hideKeyboard()
    }

    func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView) {
        channel.invokeMethod("didCancel", arguments: nil)
    }

    func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String, at index: Int) {
        channel.invokeMethod("textDidChangeAtIndex", arguments: ["text": text, "index": index])
    }

    func searchBarView(_ searchBarView: CYLSearchBarView, didCompleteSearch text: String, at index: Int) {
        channel.invokeMethod("didCompleteSearch", arguments: ["text": text, "index": index])
    }

    func searchBarView(_ searchBarView: CYLSearchBarView, didRemoveSearchAt index: Int) {
        guard !syncingSearches else {
            return
        }
        channel.invokeMethod("didRemoveSearch", arguments: ["index": index])
    }

    func searchBarView(_ searchBarView: CYLSearchBarView, didSelectSearch text: String, at index: Int) {
        channel.invokeMethod("didSelectSearch", arguments: ["text": text, "index": index])
    }
}

/**
 * CollectionViewClassifyMenu's `CYLTagListView` filling the platform view, one section of tags from Dart: their titles
 * and ids, the selection, the header (title and clear button) and editing mode (crosses, dragging, rename requests), as
 * on Android and React Native. It reports the height its tags need at the view's width (`didChangeHeight`), so Dart can
 * size it.
 */
// Platform views live on the main thread, as the core views they wrap (main-actor isolated).
@MainActor
final class CYLFlutterTagListView: NSObject, @preconcurrency FlutterPlatformView {
    private let container: CYLFlutterTagListContainer

    init(frame: CGRect, arguments: [String: Any], channel: FlutterMethodChannel) {
        container = CYLFlutterTagListContainer(frame: frame, channel: channel)
        super.init()
        container.apply(arguments)
        channel.setMethodCallHandler { [weak self] call, result in
            if call.method == "update", let arguments = call.arguments as? [String: Any] {
                self?.container.apply(arguments)
            }
            result(nil)
        }
    }

    func view() -> UIView {
        container
    }
}

/**
 * The tag list, its data (titles, ids, selection, header) and the height it reported last.
 */
final class CYLFlutterTagListContainer: UIView, CYLMenuDataSource, CYLMenuDelegate {
    let tagListView = CYLTagListView(foldControl: nil)
    private let channel: FlutterMethodChannel
    private var reportedHeight: CGFloat = -1
    private var titles: [String] = []
    private var ids: [String] = []
    private var selectedIds: Set<String> = []
    private var sectionTitle = ""
    private var showsClearButton = false
    private var showsRefreshButton = false
    private var columns = 0
    private var backgroundStyle = ""
    private var tagImages: [String] = []
    private var tagImageLabels: [String] = []
    private var imageCache: [String: UIImage] = [:]
    private var supportsRenaming = false

    init(frame: CGRect, channel: FlutterMethodChannel) {
        self.channel = channel
        super.init(frame: frame)
        tagListView.showsSectionHeaders = false
        tagListView.selectionMode = .none
        tagListView.allowsEmptySelection = true
        // Dart adds tags in its own editing bar, as the iOS example and React Native do.
        tagListView.showsAddItemViewWhileEditing = false
        // The Flutter page shows through, as around any other widget.
        backgroundColor = .clear
        let style = tagListView.style.copy() as! CYLMenuStyle
        style.backgroundColor = .clear
        tagListView.style = style
        // The search bar core's default tag style (capsule tags, light border, bold header, 16 pt inset) and the
        // header's refresh icon (not the three dots); an app changes them through CYLSearchTagListStyle.
        CYLSearchTagListStyle.applyDefaultStyle(to: tagListView)
        // Renaming is Dart's: the list asks, Dart renames by id and sends the new titles.
        tagListView.renameRequestHandler = { [weak self] indexPath, title in
            guard let self else { return }
            self.channel.invokeMethod("didRequestRename", arguments: ["index": indexPath.item, "id": self.id(at: indexPath.item), "title": title])
        }
        tagListView.clearButtonHandler = { [weak self] section in
            self?.channel.invokeMethod("didTapClearButton", arguments: ["section": section])
        }
        tagListView.menuDataSource = self
        tagListView.menuDelegate = self
        addSubview(tagListView)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func apply(_ arguments: [String: Any]) {
        overrideUserInterfaceStyle = (arguments["brightness"] as? String) == "dark" ? .dark : .light
        tagListView.foldControl = cylFoldControl(arguments["foldControlPosition"], arguments["foldControlContent"])
        tagListView.defaultVisibleRows = max(0, arguments["foldedRowCount"] as? Int ?? 2)
        let mode: CYLMenuSelectionMode = (arguments["selectionMode"] as? String) == "multiple" ? .multiple : .none
        if mode != tagListView.selectionMode { tagListView.selectionMode = mode }
        let newTitles = arguments["tags"] as? [String] ?? []
        let newIds = arguments["tagIds"] as? [String] ?? []
        let newSectionTitle = arguments["sectionTitle"] as? String ?? ""
        let newShowsClearButton = arguments["showsClearButton"] as? Bool ?? false
        let newShowsRefreshButton = arguments["showsRefreshButton"] as? Bool ?? false
        let newColumns = max(0, arguments["columns"] as? Int ?? 0)
        let newBackgroundStyle = arguments["backgroundStyle"] as? String ?? ""
        let newTagImages = arguments["tagImages"] as? [String] ?? []
        let newTagImageLabels = arguments["tagImageLabels"] as? [String] ?? []
        if newColumns != columns {
            columns = newColumns
            // The grid of plain titles (the iOS example's discover topics), through the core's helper.
            if columns > 0 { CYLSearchTagListStyle.applyGrid(columns: columns, to: tagListView) } else { CYLSearchTagListStyle.applyDefaultStyle(to: tagListView) }
            backgroundStyle = ""
        }
        if newBackgroundStyle != backgroundStyle {
            backgroundStyle = newBackgroundStyle
            CYLSearchTagListStyle.applyBackgroundStyle(named: backgroundStyle, to: tagListView)
        }
        let newSupportsRenaming = arguments["supportsRenaming"] as? Bool ?? false
        // Reloaded only when Dart sends other content, so a rebuild keeps the native fold state.
        if newTitles != titles || newIds != ids || newSectionTitle != sectionTitle || newShowsClearButton != showsClearButton
            || newShowsRefreshButton != showsRefreshButton || newTagImages != tagImages || newTagImageLabels != tagImageLabels || newSupportsRenaming != supportsRenaming {
            titles = newTitles
            ids = newIds
            sectionTitle = newSectionTitle
            showsClearButton = newShowsClearButton
            showsRefreshButton = newShowsRefreshButton
            tagImages = newTagImages
            tagImageLabels = newTagImageLabels
            imageCache.removeAll()
            supportsRenaming = newSupportsRenaming
            tagListView.showsSectionHeaders = !sectionTitle.isEmpty || showsClearButton || showsRefreshButton
            tagListView.reloadMenuData()
        }
        selectedIds = Set(arguments["selectedIds"] as? [String] ?? [])
        let editing = arguments["editing"] as? Bool ?? false
        if editing != tagListView.isEditing { tagListView.setEditing(editing, animated: true) }
        // After the editing change: leaving editing mode drops the list's selection, and Dart sends no other update
        // (React Native re-renders and so applied it again; Flutter sends `update` only for changed arguments).
        applySelection()
        setNeedsLayout()
    }

    /**
     * The id of the tag at `index`: its entry in `tagIds`, or its title when no id is given.
     */
    private func id(at index: Int) -> String {
        if index < ids.count, !ids[index].isEmpty { return ids[index] }
        return index < titles.count ? titles[index] : ""
    }

    private func applySelection() {
        guard tagListView.selectionMode == .multiple else { return }
        tagListView.selectedIndexPaths = titles.indices.filter { selectedIds.contains(id(at: $0)) }.map { IndexPath(item: $0, section: 0) }
    }

    override func responds(to aSelector: Selector!) -> Bool {
        // The edit icon shows only for a data source that renames (`supportsRenaming`).
        if aSelector == #selector(CYLMenuDataSource.menuRenameItem(at:to:)) {
            return supportsRenaming
        }
        return super.responds(to: aSelector)
    }

    // MARK: - CYLMenuDataSource

    func numberOfSectionsInMenu() -> Int { 1 }

    func menuNumberOfItems(inSection section: Int) -> Int { titles.count }

    func menuTitle(forSection section: Int) -> String { sectionTitle }

    /// The image after a tag's title: a Flutter asset (the key Dart sends), the 3.0x / 2.0x variant of the screen's scale
    /// first, as Flutter picks them; nil for "" or a missing file.
    func menuImageForItem(at indexPath: IndexPath) -> UIImage? {
        guard indexPath.item < tagImages.count, !tagImages[indexPath.item].isEmpty else { return nil }
        let asset = tagImages[indexPath.item]
        if let cached = imageCache[asset] { return cached }
        let scale = Int(traitCollection.displayScale.rounded())
        let directory = (asset as NSString).deletingLastPathComponent
        let file = (asset as NSString).lastPathComponent
        var candidates: [(String, CGFloat)] = (2...3).reversed().filter { $0 <= scale }.map { ("\(directory)/\($0).0x/\(file)", CGFloat($0)) }
        candidates.append((asset, 1))
        for (candidate, imageScale) in candidates {
            let key = FlutterDartProject.lookupKey(forAsset: candidate)
            if let path = Bundle.main.path(forResource: key, ofType: nil), let image = UIImage(contentsOfFile: path), let cgImage = image.cgImage {
                let scaled = UIImage(cgImage: cgImage, scale: imageScale, orientation: .up)
                // VoiceOver reads the image's label as the tag's value (the localized "Hot").
                scaled.accessibilityLabel = indexPath.item < tagImageLabels.count ? tagImageLabels[indexPath.item] : nil
                imageCache[asset] = scaled
                return scaled
            }
        }
        return nil
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        indexPath.item < titles.count ? titles[indexPath.item] : ""
    }

    func menuIdentifierForItem(at indexPath: IndexPath) -> String { id(at: indexPath.item) }

    // One header action: the refresh icon takes the place of the trash.
    func menuShowsClearButton(forSection section: Int) -> Bool { showsClearButton && !showsRefreshButton }
    func menuShowsMoreButton(inSection section: Int) -> Bool { showsRefreshButton }
    func menuAccessibilityLabelForMoreButton(inSection section: Int) -> String? { CYLSearchTagListHeader.refreshAccessibilityLabel }

    func menuRenameItem(at indexPath: IndexPath, to title: String) {
        // Not used: `renameRequestHandler` hands renaming to Dart, which sends the new titles.
    }

    func menuRemoveItem(at indexPath: IndexPath) {
        let index = indexPath.item
        guard index < titles.count else { return }
        let removed = id(at: index)
        titles.remove(at: index)
        if index < ids.count { ids.remove(at: index) }
        channel.invokeMethod("didDeleteTag", arguments: ["index": index, "id": removed])
    }

    func menuMoveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let from = sourceIndexPath.item, to = destinationIndexPath.item
        guard from < titles.count, to < titles.count else { return }
        titles.insert(titles.remove(at: from), at: to)
        if ids.count == titles.count { ids.insert(ids.remove(at: from), at: to) }
        channel.invokeMethod("didMoveTag", arguments: ["from": from, "to": to])
    }

    // MARK: - CYLMenuDelegate

    func menu(_ menu: Any, didTapMoreButtonInSection section: Int) {
        channel.invokeMethod("didTapRefreshButton", arguments: ["section": section])
    }

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        let selected = tagListView.selectionMode == .multiple
        if selected { selectedIds.insert(id(at: index)) }
        channel.invokeMethod("didSelectTag", arguments: ["index": index, "title": menuTitleForItem(at: indexPath), "id": id(at: index), "selected": selected])
    }

    func menu(_ menu: Any, didDeselectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        selectedIds.remove(id(at: index))
        channel.invokeMethod("didSelectTag", arguments: ["index": index, "title": menuTitleForItem(at: indexPath), "id": id(at: index), "selected": false])
    }

    func menu(_ menu: Any, didChangeContentHeight height: CGFloat) {
        setNeedsLayout()
    }

    func menu(_ menu: Any, didChangeExpanded expanded: Bool, inSection section: Int) {
        setNeedsLayout()
    }

    func menu(_ menu: Any, didChangeEditing editing: Bool) {
        applySelection()
        reportedHeight = -1
        setNeedsLayout()
    }

    // A drag of a tag or a smear selection: Dart claims the pointer in the gesture arena while it lasts
    // (didChangeDragging), so a Flutter scroll view around the list does not scroll with it, as on Android.
    private var reordering = false
    private var smearing = false
    private var reportedDragging = false

    func menu(_ menu: Any, didChangeReordering reordering: Bool) {
        self.reordering = reordering
        reportDragging()
    }

    func menu(_ menu: Any, didChangeSmearing smearing: Bool) {
        self.smearing = smearing
        reportDragging()
    }

    private func reportDragging() {
        let dragging = reordering || smearing
        guard dragging != reportedDragging else { return }
        reportedDragging = dragging
        channel.invokeMethod("didChangeDragging", arguments: ["dragging": dragging])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tagListView.frame = bounds
        guard bounds.width > 0 else { return }
        let height = ceil(tagListView.heightThatFitsWidth(bounds.width))
        if height != reportedHeight {
            reportedHeight = height
            channel.invokeMethod("didChangeHeight", arguments: ["height": Double(height)])
        }
    }
}

/**
 * CYLTableViewPlaceHolder's `CYLPlaceholderView` filling the size Dart gives it, centred: the image of a
 * `CYLPlaceholderStyle` (by name, ignoring case; `.empty` when unknown, as on Android) above a text.
 */
@MainActor
final class CYLFlutterPlaceholderView: NSObject, @preconcurrency FlutterPlatformView {
    private let container: CYLFlutterPlaceholderContainer

    init(frame: CGRect, arguments: [String: Any], channel: FlutterMethodChannel) {
        container = CYLFlutterPlaceholderContainer(frame: frame)
        super.init()
        container.apply(arguments)
        channel.setMethodCallHandler { [weak self] call, result in
            if call.method == "update", let arguments = call.arguments as? [String: Any] {
                self?.container.apply(arguments)
            }
            result(nil)
        }
    }

    func view() -> UIView {
        container
    }
}

/**
 * The placeholder, rebuilt when its style or text changes, at its content size in the middle.
 */
final class CYLFlutterPlaceholderContainer: UIView {
    /**
     * CYLPlaceholderStyle's case names in order (their raw values), lowercased.
     */
    private static let styleNames = ["empty", "noresults", "error", "wifioff", "signalwifioff", "nointernet", "cloudoff", "syncproblem", "syncdisabled", "networklocked", "bluetoothdisabled", "locationoff", "publicoff", "erroroutline", "warning", "reportproblem", "blocked", "help", "hourglass", "locked", "visibilityoff", "searchoff", "folderoff", "folderopen", "downloadoff", "uploadoff", "inbox", "brokenimage", "imageunavailable", "photolibrary", "musicoff", "videooff", "personoff", "groupoff", "eventbusy", "emptycart", "favorite", "batteryalert", "unknowndevice", "phonedisabled", "wronglocation", "archive", "info", "refresh", "delete", "search", "mail", "image", "cloud", "notificationsoff", "history"]
    private var placeholderView: CYLPlaceholderView?
    private var styleName: String?
    private var text: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        nil
    }

    func apply(_ arguments: [String: Any]) {
        overrideUserInterfaceStyle = (arguments["brightness"] as? String) == "dark" ? .dark : .light
        let name = arguments["placeholderStyle"] as? String ?? "empty"
        let newText = arguments["text"] as? String ?? ""
        guard placeholderView == nil || name != styleName || newText != text else { return }
        styleName = name
        text = newText
        placeholderView?.removeFromSuperview()
        let raw = Self.styleNames.firstIndex(of: name.lowercased()) ?? 0
        let placeholder = CYLPlaceholderView(style: CYLPlaceholderStyle(rawValue: raw) ?? .empty, text: newText)
        placeholder.reportsContentSize = true
        addSubview(placeholder)
        placeholderView = placeholder
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let placeholderView else { return }
        placeholderView.preferredMaxLayoutWidth = bounds.width
        var size = placeholderView.intrinsicContentSize
        size.width = min(bounds.width, size.width > 0 ? size.width : bounds.width)
        size.height = min(bounds.height, max(0, size.height))
        placeholderView.frame = CGRect(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2, width: size.width, height: size.height)
    }
}

/**
 * The fold control for a Dart `CYLTagFoldControlPosition` and `CYLTagFoldControlContent` name; an inline icon by default.
 */
func cylFoldControl(_ position: Any?, _ content: Any?) -> CYLMenuFoldControl {
    // The plugin's names ("inline", "bottom", "topTrailing", "topLeading") and CollectionViewClassifyMenu's own since
    // its position rename ("tail", "footer", "headerTrailing", "headerLeading").
    let positions: [String: CYLMenuFoldControlPosition] = ["none": .none, "inline": .tail, "tail": .tail,
                                                           "bottom": .footer, "footer": .footer,
                                                           "topTrailing": .headerTrailing, "headerTrailing": .headerTrailing,
                                                           "topLeading": .headerLeading, "headerLeading": .headerLeading]
    let contents: [String: CYLMenuFoldControlContent] = ["iconAndTitle": .iconAndTitle, "title": .title, "icon": .icon]
    return CYLMenuFoldControl(position: positions[position as? String ?? ""] ?? .tail, content: contents[content as? String ?? ""] ?? .icon)
}

