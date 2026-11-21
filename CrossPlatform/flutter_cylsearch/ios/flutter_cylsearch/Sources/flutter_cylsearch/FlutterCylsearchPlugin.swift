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
        searchView.showsSuggestionCacheHeader = arguments["showsSuggestionCacheHeader"] as? Bool ?? true
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
 * `CYLSearchBarView` filling the platform view; with `editingBar` (read at creation), the core's editing bar
 * (`CYLSearchBarView.editingBar(placeholder:actionTitle:)`), whose submit is sent as `didSubmitEditing`.
 */
// Platform views live on the main thread, as the core views they wrap (main-actor isolated).
@MainActor
final class CYLFlutterSearchBarView: NSObject, @preconcurrency FlutterPlatformView, CYLSearchBarViewDelegate {
    private let bar: CYLSearchBarView
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
        bar.fieldShadowOpacity = CGFloat(arguments["fieldShadowOpacity"] as? Double ?? 0)
        bar.searchBarStyle = (arguments["searchBarStyle"] as? String) == "bordered" ? .bordered : .plain
        if bar.isEditingBar {
            // The core's own setup stays: no magnifier, its action button always shown.
            if let title = arguments["actionTitle"] as? String, !title.isEmpty { bar.cancelButtonTitle = title }
        } else {
            bar.showsCancelButton = arguments["showsCancelButton"] as? Bool ?? false
            bar.searchIcon = arguments["showsSearchIcon"] as? Bool ?? true ? UIImage(systemName: "magnifyingglass") : nil
        }
        let items = arguments["items"] as? [[String: Any]] ?? []
        // Rebuilt only when Dart sends other items, so a rebuild of the widget keeps the native selection.
        if (items as NSArray) != (appliedItems as NSArray) {
            appliedItems = items
            bar.removeAllItems()
            items.forEach { bar.addItem(CYLSearchBarItem.item(dictionary: $0)) }
        }
    }

    private var appliedItems: [[String: Any]] = []

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
        let newSupportsRenaming = arguments["supportsRenaming"] as? Bool ?? false
        // Reloaded only when Dart sends other content, so a rebuild keeps the native fold state.
        if newTitles != titles || newIds != ids || newSectionTitle != sectionTitle || newShowsClearButton != showsClearButton
            || newSupportsRenaming != supportsRenaming {
            titles = newTitles
            ids = newIds
            sectionTitle = newSectionTitle
            showsClearButton = newShowsClearButton
            supportsRenaming = newSupportsRenaming
            tagListView.showsSectionHeaders = !sectionTitle.isEmpty || showsClearButton
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

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        indexPath.item < titles.count ? titles[indexPath.item] : ""
    }

    func menuIdentifierForItem(at indexPath: IndexPath) -> String { id(at: indexPath.item) }

    func menuShowsClearButton(forSection section: Int) -> Bool { showsClearButton }

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

