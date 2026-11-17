import CollectionViewClassifyMenu
// CYLTableViewPlaceHolder (the empty results placeholder and the refresh header) comes only through the core: its
// types are used through `CYLSearchView`'s API, never imported here.
import CYLSearchViewController
import Flutter
import UIKit

/**
 * Registers the platform views of CYLSearchViewController for Flutter: `cyl_search/search_view` (`CYLSearchView`),
 * `cyl_search/search_bar_view` (`CYLSearchBarView`) and `cyl_search/tag_list_view` (CollectionViewClassifyMenu's
 * `CYLTagListView`, the tags of `CYLSearchView.suggestionsTagView`). Each view talks to Dart on `cyl_search/view_<id>`.
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
        var content = UIListContentConfiguration.cell()
        content.text = (result as? CYLFlutterSearchResult)?.text
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

    init(frame: CGRect, arguments: [String: Any], channel: FlutterMethodChannel) {
        container = UIView(frame: frame)
        self.channel = channel
        super.init()
        searchView.delegate = self
        // The page stays open after a submit: Dart decides what a submitted query does.
        searchView.closesOnSubmit = false
        apply(arguments)
        searchView.install(in: container)
        searchView.showSearch(animated: false)
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
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func view() -> UIView {
        container
    }

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
        searchView.suggestionsFoldControl = cylFoldControl(arguments["suggestionsFoldControlPosition"], arguments["suggestionsFoldControlContent"])
        searchView.suggestionsFoldedRowCount = UInt(max(0, arguments["suggestionsFoldedRowCount"] as? Int ?? 2))
    }

    func searchView(_ searchView: CYLSearchView, textDidChange text: String) {
        channel.invokeMethod("textDidChange", arguments: ["text": text])
    }

    func searchView(_ searchView: CYLSearchView, didSubmitText text: String) -> Bool {
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
 * `CYLSearchBarView` filling the platform view.
 */
// Platform views live on the main thread, as the core views they wrap (main-actor isolated).
@MainActor
final class CYLFlutterSearchBarView: NSObject, @preconcurrency FlutterPlatformView, CYLSearchBarViewDelegate {
    private let bar: CYLSearchBarView
    private let channel: FlutterMethodChannel

    init(frame: CGRect, arguments: [String: Any], channel: FlutterMethodChannel) {
        bar = CYLSearchBarView(frame: frame)
        self.channel = channel
        super.init()
        bar.delegate = self
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
        bar
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
        if let text = arguments["text"] as? String, text != bar.text { bar.text = text }
        bar.showsCancelButton = arguments["showsCancelButton"] as? Bool ?? false
        bar.fieldShadowOpacity = CGFloat(arguments["fieldShadowOpacity"] as? Double ?? 0)
        bar.searchBarStyle = (arguments["searchBarStyle"] as? String) == "bordered" ? .bordered : .plain
        bar.searchIcon = arguments["showsSearchIcon"] as? Bool ?? true ? UIImage(systemName: "magnifyingglass") : nil
        let items = arguments["items"] as? [[String: Any]] ?? []
        // Rebuilt only when Dart sends other items, so a rebuild of the widget keeps the native selection.
        if (items as NSArray) != (appliedItems as NSArray) {
            appliedItems = items
            bar.removeAllItems()
            items.forEach { bar.addItem(CYLSearchBarItem.item(dictionary: $0)) }
        }
    }

    private var appliedItems: [[String: Any]] = []

    func searchBarView(_ searchBarView: CYLSearchBarView, didSelect item: CYLSearchBarItem) {
        channel.invokeMethod("didSelectItem", arguments: ["index": item.index, "selected": item.isSelected])
    }

    func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String) {
        channel.invokeMethod("textDidChange", arguments: ["text": text])
    }

    func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView) {
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
 * CollectionViewClassifyMenu's `CYLTagListView` filling the platform view; it reports the height its tags need at the
 * view's width (`didChangeHeight`), so Dart can size it.
 */
// Platform views live on the main thread, as the core views they wrap (main-actor isolated).
@MainActor
final class CYLFlutterTagListView: NSObject, @preconcurrency FlutterPlatformView {
    private let container: CYLFlutterTagListContainer
    private let channel: FlutterMethodChannel

    init(frame: CGRect, arguments: [String: Any], channel: FlutterMethodChannel) {
        container = CYLFlutterTagListContainer(frame: frame)
        self.channel = channel
        super.init()
        container.tagListView.tagClickHandler = { [weak channel] index, tag in
            channel?.invokeMethod("didSelectTag", arguments: ["index": Int(index), "title": tag.title ?? ""])
        }
        container.heightChanged = { [weak channel] height in
            channel?.invokeMethod("didChangeHeight", arguments: ["height": Double(height)])
        }
        apply(arguments)
        channel.setMethodCallHandler { [weak self] call, result in
            if call.method == "update", let arguments = call.arguments as? [String: Any] {
                self?.apply(arguments)
            }
            result(nil)
        }
    }

    func view() -> UIView {
        container
    }

    private func apply(_ arguments: [String: Any]) {
        container.overrideUserInterfaceStyle = (arguments["brightness"] as? String) == "dark" ? .dark : .light
        container.tagListView.foldControl = cylFoldControl(arguments["foldControlPosition"], arguments["foldControlContent"])
        container.tagListView.defaultVisibleRows = UInt(max(0, arguments["foldedRowCount"] as? Int ?? 2))
        container.tagListView.setTags(withTitles: arguments["tags"] as? [String] ?? [])
        container.setNeedsLayout()
    }
}

/**
 * The tag list and the height it reported last.
 */
final class CYLFlutterTagListContainer: UIView, CYLMenuDelegate {
    let tagListView = CYLTagListView(foldControl: nil)
    var heightChanged: ((CGFloat) -> Void)?
    private var reportedHeight: CGFloat = -1

    override init(frame: CGRect) {
        super.init(frame: frame)
        tagListView.showsSectionHeaders = false
        // Folding and unfolding change the height: report it again.
        tagListView.menuDelegate = self
        // The Flutter page shows through, as around any other widget.
        backgroundColor = .clear
        let style = tagListView.style.copy() as! CYLMenuStyle
        style.backgroundColor = .clear
        tagListView.style = style
        addSubview(tagListView)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func menu(_ menu: Any, didChangeContentHeight height: CGFloat) {
        setNeedsLayout()
    }

    func menu(_ menu: Any, didChangeExpanded expanded: Bool, inSection section: Int) {
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tagListView.frame = bounds
        guard bounds.width > 0 else { return }
        let height = ceil(tagListView.heightThatFitsWidth(bounds.width))
        if height != reportedHeight {
            reportedHeight = height
            heightChanged?(height)
        }
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

