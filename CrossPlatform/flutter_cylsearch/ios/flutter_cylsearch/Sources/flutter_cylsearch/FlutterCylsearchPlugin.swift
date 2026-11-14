import CollectionViewClassifyMenu
import CYLSearchViewController
import CYLTableViewPlaceHolder
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
    private let make: (CGRect, Int64, [String: Any], FlutterMethodChannel) -> FlutterPlatformView

    init(messenger: FlutterBinaryMessenger, make: @escaping (CGRect, Int64, [String: Any], FlutterMethodChannel) -> FlutterPlatformView) {
        self.messenger = messenger
        self.make = make
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let channel = FlutterMethodChannel(name: "cyl_search/view_\(viewId)", binaryMessenger: messenger)
        return make(frame, viewId, args as? [String: Any] ?? [:], channel)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

/**
 * `CYLSearchView` in a container, open from the start (Dart pops its route in `onClose`).
 */
final class CYLFlutterSearchView: NSObject, FlutterPlatformView, CYLSearchViewDelegate {
    private let container: UIView
    private let searchView = CYLSearchView(frame: .zero)
    private let channel: FlutterMethodChannel

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
        // The Flutter app's brightness, whatever the system setting is.
        container.overrideUserInterfaceStyle = (arguments["brightness"] as? String) == "dark" ? .dark : .light
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
}

/**
 * `CYLSearchBarView` filling the platform view.
 */
final class CYLFlutterSearchBarView: NSObject, FlutterPlatformView, CYLSearchBarViewDelegate {
    private let bar: CYLSearchBarView
    private let channel: FlutterMethodChannel

    init(frame: CGRect, arguments: [String: Any], channel: FlutterMethodChannel) {
        bar = CYLSearchBarView(frame: frame)
        self.channel = channel
        super.init()
        bar.delegate = self
        apply(arguments)
        channel.setMethodCallHandler { [weak self] call, result in
            if call.method == "update", let arguments = call.arguments as? [String: Any] {
                self?.apply(arguments)
            }
            result(nil)
        }
    }

    func view() -> UIView {
        bar
    }

    private func apply(_ arguments: [String: Any]) {
        bar.overrideUserInterfaceStyle = (arguments["brightness"] as? String) == "dark" ? .dark : .light
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
}

/**
 * CollectionViewClassifyMenu's `CYLTagListView` filling the platform view; it reports the height its tags need at the
 * view's width (`didChangeHeight`), so Dart can size it.
 */
final class CYLFlutterTagListView: NSObject, FlutterPlatformView {
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
    let positions: [String: CYLMenuFoldControlPosition] = ["none": .none, "inline": .inline, "bottom": .bottom,
                                                           "topTrailing": .topTrailing, "topLeading": .topLeading]
    let contents: [String: CYLMenuFoldControlContent] = ["iconAndTitle": .iconAndTitle, "title": .title, "icon": .icon]
    return CYLMenuFoldControl(position: positions[position as? String ?? ""] ?? .inline, content: contents[content as? String ?? ""] ?? .icon)
}

