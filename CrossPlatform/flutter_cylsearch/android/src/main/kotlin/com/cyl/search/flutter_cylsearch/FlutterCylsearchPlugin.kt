package com.cyl.search.flutter_cylsearch

import android.content.Context
import android.graphics.Rect
import android.view.ContextThemeWrapper
import android.view.View
import android.widget.FrameLayout
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.CYLTagLongPressActions
import com.cyl.classifymenu.CYLTagTitleMaxLines
import com.cyl.placeholder.CYLPlaceholderStyle
import com.cyl.placeholder.CYLPlaceholderView
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.search.CYLSearchBarAppearance
import com.cyl.search.CYLSearchBarItem
import com.cyl.search.CYLSearchBarMode
import com.cyl.search.CYLSearchBarStyle
import com.cyl.search.CYLSearchBarSearchButtonStyle
import com.cyl.search.CYLSearchBarView
import com.cyl.search.CYLSearchBarViewDelegate
import com.cyl.search.CYLSearchSuggestionCachePolicy
import com.cyl.search.CYLSearchSuggestionCell
import com.cyl.search.CYLSearchSuggestionStyle
import com.cyl.search.CYLSearchView
import com.cyl.search.CYLSearchViewDataSource
import com.cyl.search.CYLSearchTagListHeader
import com.cyl.search.CYLSearchTagListStyle
import com.cyl.search.CYLSearchViewDelegate
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Registers the platform views of CYLSearchViewController for Flutter: `cyl_search/search_view` (`CYLSearchView`),
 * `cyl_search/search_bar_view` (`CYLSearchBarView`) of the `cylsearch` module and `cyl_search/tag_list_view`
 * (CollectionViewClassifyMenu's `CYLTagListView`, the tags of `CYLSearchView.suggestionsTagView`). Each view talks to
 * Dart on `cyl_search/view_<id>`.
 */
class FlutterCylsearchPlugin : FlutterPlugin {

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = binding.binaryMessenger
        binding.platformViewRegistry.registerViewFactory("cyl_search/search_view", Factory(messenger) { context, args, channel ->
            CYLFlutterSearchView(context, args, channel)
        })
        binding.platformViewRegistry.registerViewFactory("cyl_search/search_bar_view", Factory(messenger) { context, args, channel ->
            CYLFlutterSearchBarView(context, args, channel)
        })
        binding.platformViewRegistry.registerViewFactory("cyl_search/tag_list_view", Factory(messenger) { context, args, channel ->
            CYLFlutterTagListView(context, args, channel)
        })
        binding.platformViewRegistry.registerViewFactory("cyl_search/placeholder_view", Factory(messenger) { context, args, channel ->
            CYLFlutterPlaceholderView(context, args, channel)
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) = Unit

    private class Factory(
        private val messenger: BinaryMessenger,
        private val make: (Context, Map<String, Any?>, MethodChannel) -> PlatformView,
    ) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        @Suppress("UNCHECKED_CAST")
        override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
            // Flutter's context has no theme for these views (it resolved to a dark default: a black page, white text)
            // and the system setting can differ from the app's: the views use the Flutter app's brightness.
            val arguments = (args as? Map<String, Any?>) ?: emptyMap()
            val theme = if (arguments["brightness"] == "dark") {
                androidx.appcompat.R.style.Theme_AppCompat_NoActionBar
            } else {
                androidx.appcompat.R.style.Theme_AppCompat_Light_NoActionBar
            }
            return make(ContextThemeWrapper(context, theme), arguments, MethodChannel(messenger, "cyl_search/view_$viewId"))
        }
    }
}

/**
 * `CYLSearchView` in a container, open from the start (Dart pops its route in `onClose`).
 */
internal class CYLFlutterSearchView(context: Context, arguments: Map<String, Any?>, private val channel: MethodChannel) :
    PlatformView, CYLSearchViewDelegate {

    private val container = FrameLayout(context)
    private val searchView = CYLSearchView(context)
    private val resultsDataSource = CYLFlutterSearchResultsDataSource()
    private var appliedResults: List<String>? = null
    // The last history reported to Dart: an event goes out only for a change.
    private var reportedHistory: List<String> = emptyList()

    init {
        searchView.delegate = this
        // The page stays open after a submit: Dart decides what a submitted query does.
        searchView.closesOnSubmit = false
        apply(arguments)
        searchView.installInView(container)
        searchView.showSearch(false)
        reportedHistory = history()
        // The core's history signal: a submitted query, a clear and the trash button of its header. Only a changed history
        // reaches Dart.
        searchView.addHistoryDidChangeListener { reportHistory() }
        container.addOnLayoutChangeListener { _, _, _, _, _, _, _, _, _ -> reportSearchBar() }
        searchView.searchBarView.addOnLayoutChangeListener { _, _, _, _, _, _, _, _, _ -> reportSearchBar() }
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "update" -> {
                    @Suppress("UNCHECKED_CAST")
                    val updated = call.arguments as? Map<String, Any?>
                    updated?.let { apply(it) }
                    result.success(null)
                }
                "beginRefreshing" -> {
                    searchView.beginRefreshing()
                    result.success(null)
                }
                "endRefreshing" -> {
                    searchView.endRefreshing()
                    result.success(null)
                }
                "isRefreshing" -> result.success(searchView.isRefreshing)
                "reloadResults" -> {
                    searchView.reloadResults()
                    result.success(null)
                }
                "setActive" -> {
                    val arguments = call.arguments as? Map<*, *>
                    searchView.setActive(arguments?.get("active") as? Boolean ?: true, arguments?.get("animated") as? Boolean ?: true)
                    result.success(null)
                }
                "history" -> result.success(history())
                "clearHistory" -> {
                    searchView.clearSuggestionCache()
                    result.success(null)
                }
                "setQuery" -> {
                    val arguments = call.arguments as? Map<*, *>
                    searchView.setQuery(arguments?.get("query") as? String, arguments?.get("submit") as? Boolean ?: false)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * The submitted queries in the page's cache, newest first (the history of the launch view).
     */
    private fun history(): List<String> = searchView.suggestionCache?.cachedQueries().orEmpty()

    /**
     * Tells Dart the history when it differs from the one it has.
     */
    private fun reportHistory() {
        val current = history()
        if (current == reportedHistory) return
        reportedHistory = current
        channel.invokeMethod("historyDidChange", mapOf("history" to current))
    }

    /**
     * Tells Dart where the bar ends, in dp: Dart lays the launch view, the dimming and the empty view from there down.
     */
    private fun reportSearchBar() {
        val density = container.resources.displayMetrics.density
        channel.invokeMethod("didLayoutSearchBar", mapOf("bottom" to searchView.searchBarMaxY / density.toDouble()))
    }

    @Suppress("UNCHECKED_CAST")
    private fun apply(arguments: Map<String, Any?>) {
        // Results: a list sets the data source (and reloads the rows when it changed); null removes it.
        val results = arguments["results"] as? List<String>
        if (results != appliedResults) {
            appliedResults = results
            resultsDataSource.results = results.orEmpty()
            when {
                results == null -> searchView.resultsDataSource = null
                searchView.resultsDataSource == null -> searchView.resultsDataSource = resultsDataSource
                else -> searchView.reloadResults()
            }
        }
        // Refresh: the handler only reports the pull to Dart, which calls `endRefreshing` when it is done.
        val refreshEnabled = arguments["refreshEnabled"] as? Boolean ?: false
        if (refreshEnabled != (searchView.refreshHandler != null)) {
            searchView.refreshHandler = if (refreshEnabled) ({ channel.invokeMethod("refresh", null) }) else null
        }
        (arguments["suggestions"] as? List<String>)?.let { searchView.suggestions = it }
        searchView.suggestionStyle = if (arguments["suggestionStyle"] == "tags") CYLSearchSuggestionStyle.Tags else CYLSearchSuggestionStyle.List
        searchView.searchBarView.placeholder = arguments["placeholder"] as? String
        (arguments["query"] as? String)?.takeIf { it != searchView.query }?.let { searchView.query = it }
        searchView.showsSuggestionsForEmptyQuery = arguments["showsSuggestionsForEmptyQuery"] as? Boolean ?: false
        searchView.submitsOnSuggestionSelection = arguments["submitsOnSuggestionSelection"] as? Boolean ?: false
        searchView.emptyResultsScenario =
            if (arguments["emptyResultsScenario"] == "noContent") CYLPlaceholderScenario.NoContent else CYLPlaceholderScenario.NoSearchResults
        searchView.showsEmptyResultsPlaceholder = arguments["showsEmptyResultsPlaceholder"] as? Boolean ?: false
        val policy = when (arguments["suggestionCachePolicy"]) {
            "none" -> CYLSearchSuggestionCachePolicy.None
            "userDefaults" -> CYLSearchSuggestionCachePolicy.UserDefaults
            "sandboxFile" -> CYLSearchSuggestionCachePolicy.SandboxFile
            else -> CYLSearchSuggestionCachePolicy.Database
        }
        val name = arguments["suggestionCacheName"] as? String ?: "CYLSearchView"
        if (policy != searchView.suggestionCachePolicy || name != searchView.suggestionCacheName) {
            searchView.suggestionCacheName = name
            searchView.suggestionCachePolicy = policy
        }
        searchView.focusesSearchFieldOnShow = arguments["focusesSearchFieldOnShow"] as? Boolean ?: true
        searchView.showsSuggestionCacheHeader = arguments["showsSuggestionCacheHeader"] as? Boolean ?: true
        searchView.suggestionsFoldControl = cylFoldControl(arguments["suggestionsFoldControlPosition"], arguments["suggestionsFoldControlContent"])
        searchView.suggestionsFoldedRowCount = maxOf(0, (arguments["suggestionsFoldedRowCount"] as? Number)?.toInt() ?: 2)
        searchView.highlightsResultMatches = arguments["highlightsResultMatches"] as? Boolean ?: false
        searchView.resultMatchHighlightColor = (arguments["resultMatchHighlightColor"] as? Number)?.toInt()
        searchView.scrimColor = (arguments["scrimColor"] as? Number)?.toInt()
        searchView.supportsSwipeToDismissSearch = arguments["supportsSwipeToDismissSearch"] as? Boolean ?: false
        searchView.noResultsText = (arguments["noResultsText"] as? String)?.takeIf { it.isNotEmpty() }
    }

    override fun searchViewWillShow(searchView: CYLSearchView) {
        channel.invokeMethod("willShow", null)
    }

    override fun searchViewWillClose(searchView: CYLSearchView) {
        channel.invokeMethod("willClose", null)
    }

    override fun searchViewDidShow(searchView: CYLSearchView) {
        channel.invokeMethod("didShow", null)
    }

    override fun getView(): View = container

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun searchViewTextDidChange(searchView: CYLSearchView, text: String) {
        channel.invokeMethod("textDidChange", mapOf("text" to text))
    }

    override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean {
        // A tapped tag reports its text as a change before this submit (the core does), so Dart's results follow.
        channel.invokeMethod("didSubmit", mapOf("text" to text))
        return true
    }

    override fun searchViewDidSelectSuggestion(searchView: CYLSearchView, suggestion: String, index: Int) {
        channel.invokeMethod("didSelectSuggestion", mapOf("suggestion" to suggestion, "index" to index))
    }

    override fun searchViewDidClose(searchView: CYLSearchView) {
        channel.invokeMethod("didClose", null)
    }

    override fun searchViewDidSelectResult(searchView: CYLSearchView, result: Any) {
        val row = result as? CYLFlutterSearchResult ?: return
        channel.invokeMethod("didSelectResult", mapOf("result" to row.text, "index" to row.index))
    }
}

/**
 * One row of the results Dart sent: its text and its index in Dart's `results` list.
 */
internal data class CYLFlutterSearchResult(val text: String, val index: Int)

/**
 * The results data source of a `CYLFlutterSearchView`: Dart filters the results itself, so every query gets the list
 * Dart sent last.
 */
internal class CYLFlutterSearchResultsDataSource : CYLSearchViewDataSource {
    var results: List<String> = emptyList()

    override fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any> =
        results.mapIndexed { index, text -> CYLFlutterSearchResult(text, index) }

    override fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any) {
        // The core draws the match (`highlightsResultMatches`) after this row is configured.
        cell.textLabel.text = (result as? CYLFlutterSearchResult)?.text ?: return
    }
}

/**
 * `CYLSearchBarView` filling the platform view.
 */
internal class CYLFlutterSearchBarView(context: Context, arguments: Map<String, Any?>, private val channel: MethodChannel) :
    PlatformView, CYLSearchBarViewDelegate {

    /**
     * The core's editing bar when Dart asked for one at creation (`editingBar`), else a search bar.
     */
    private val bar: CYLSearchBarView = if (arguments["editingBar"] == true) {
        CYLSearchBarView.editingBar(context, arguments["placeholder"] as? String, arguments["actionTitle"] as? String ?: "Done")
    } else {
        CYLSearchBarView(context)
    }

    /**
     * `embedsInNavigationBar` (read at creation): the bar sits in a toolbar, the Android navigation bar, and the core fills the
     * width beside the back arrow (CYLSearchBarView.embedInToolbar); `showsBackButton` adds the arrow, a tap calls Dart's
     * `onBackPressed` (method `didTapBackButton`). The platform view is then the toolbar.
     */
    private val toolbar: androidx.appcompat.widget.Toolbar? = if (arguments["embedsInNavigationBar"] == true) {
        androidx.appcompat.widget.Toolbar(context).also { target ->
            bar.embedInToolbar(target)
            // The core owns the back button and the width (CYLSearchBarView.showBackButton / hideBackButton): the arrow follows the
            // Flutter brightness, a tap takes the button out (animated) and then tells Dart, which pops the route.
            bar.backButtonDrawable = backArrow(context, arguments["brightness"] == "dark")
            bar.backButtonHandler = { bar.hideBackButton(true) { channel.invokeMethod("didTapBackButton", null) } }
            if (arguments["showsBackButton"] == true) {
                // The second-level page continues the first-level bar: it starts whole and the back button slides in once attached
                // (`animatesBackButton`, default true), or is in at once.
                val animated = arguments["animatesBackButton"] != false
                if (animated) bar.post { bar.showBackButton(true) } else bar.showBackButton(false)
            }
            // `pushesOnTap`: a tap on the field does not edit, the core brings the back button in and Dart pushes the second-level page.
            if (arguments["pushesOnTap"] == true) bar.onFirstLevelTap = { channel.invokeMethod("didTapFirstLevel", null) }
        }
    } else {
        null
    }

    /**
     * `showsBackButton` as last applied; a later change animates the back button in or out (the core adjusts the width).
     */
    private var appliedShowsBack: Boolean = arguments["showsBackButton"] == true

    /**
     * Dart's `searches` as applied last.
     */
    private var appliedSearches: List<String> = emptyList()

    /**
     * True while Dart's `searches` replace the bar's own: the removals are not reported back.
     */
    private var syncingSearches = false

    init {
        bar.delegate = this
        if (bar.isEditingBar) {
            bar.editingSubmitHandler = { view, text ->
                channel.invokeMethod("didSubmitEditing", mapOf("text" to text))
                view.text = ""
            }
        }
        apply(arguments)
        channel.setMethodCallHandler { call, result ->
            @Suppress("UNCHECKED_CAST")
            val callArguments = (call.arguments as? Map<String, Any?>) ?: emptyMap()
            val index = (callArguments["index"] as? Number)?.toInt() ?: -1
            when (call.method) {
                "update" -> apply(callArguments)
                "beginNewSearch" -> bar.beginNewSearch()
                "completeSearch" -> bar.completeSearch()
                "addSearch" -> bar.addSearch(callArguments["text"] as? String ?: "")
                "selectSearch" -> bar.selectSearch(index)
                "removeSearch" -> bar.removeSearch(index)
                "setShowsCancelButton" ->
                    bar.setShowsCancelButton(callArguments["shows"] as? Boolean ?: false, callArguments["animated"] as? Boolean ?: true)
                "showKeyboard" -> bar.showKeyboard()
                "hideBackButton" -> bar.hideBackButton(true)
                "focus" -> if (bar.isOnSecondLevelOrDeeperPage) bar.showKeyboard()
                "restartItemAnimation" -> bar.items.getOrNull(index)?.restartAnimation()
                "searches" -> return@setMethodCallHandler result.success(bar.searches)
                "selectedSearchIndex" -> return@setMethodCallHandler result.success(bar.selectedSearchIndex)
                else -> return@setMethodCallHandler result.notImplemented()
            }
            result.success(null)
        }
    }

    /**
     * Takes Dart's completed searches when Dart sent another list and it differs from the bar's own, unless a search
     * is being typed.
     */
    private fun applySearches(searches: List<String>) {
        if (bar.mode != CYLSearchBarMode.Multiple || bar.isEditingNewSearch || searches == appliedSearches) return
        appliedSearches = searches
        if (searches == bar.searches) return
        syncingSearches = true
        while (bar.searches.isNotEmpty()) {
            bar.removeSearch(bar.searches.size - 1)
        }
        searches.forEach { bar.addSearch(it) }
        syncingSearches = false
    }

    /**
     * The back arrow follows the Flutter app's brightness (white on the dark gradient, dark on the pale one): the
     * context theme is fixed at creation and would not follow a later change.
     */
    private fun backArrow(context: Context, dark: Boolean): android.graphics.drawable.Drawable? {
        val icon = ContextCompat.getDrawable(context, androidx.appcompat.R.drawable.abc_ic_ab_back_material) ?: return null
        val wrapped = androidx.core.graphics.drawable.DrawableCompat.wrap(icon.mutate())
        androidx.core.graphics.drawable.DrawableCompat.setTint(wrapped, if (dark) 0xFFFFFFFF.toInt() else 0xDE000000.toInt())
        return wrapped
    }

    private fun tintBackArrow(target: androidx.appcompat.widget.Toolbar, dark: Boolean) {
        val icon = target.navigationIcon ?: return
        val wrapped = androidx.core.graphics.drawable.DrawableCompat.wrap(icon.mutate())
        androidx.core.graphics.drawable.DrawableCompat.setTint(wrapped, if (dark) 0xFFFFFFFF.toInt() else 0xDE000000.toInt())
        target.navigationIcon = wrapped
    }

    private fun apply(arguments: Map<String, Any?>) {
        bar.pageDepth = (arguments["pageDepth"] as? Number)?.toInt()
        bar.focusesOnAppear = arguments["focusesOnAppear"] == true
        toolbar?.let { if (it.navigationIcon != null) tintBackArrow(it, arguments["brightness"] == "dark") }
        if (toolbar != null) {
            val shows = arguments["showsBackButton"] == true
            if (shows != appliedShowsBack) {
                appliedShowsBack = shows
                if (shows) bar.showBackButton(true) else bar.hideBackButton(true)
            }
            bar.onFirstLevelTap = if (arguments["pushesOnTap"] == true) ({ channel.invokeMethod("didTapFirstLevel", null) }) else null
        }
        val mode = if (arguments["mode"] == "multiple") CYLSearchBarMode.Multiple else CYLSearchBarMode.Single
        if (mode != bar.mode) bar.mode = mode
        @Suppress("UNCHECKED_CAST")
        val searches = (arguments["searches"] as? List<String>) ?: emptyList()
        applySearches(searches)
        bar.placeholder = arguments["placeholder"] as? String
        val text = arguments["text"] as? String
        if (bar.isEditingBar) {
            (arguments["actionTitle"] as? String)?.let { bar.cancelButtonTitle = it }
            // A new title to rename: the keyboard rises with it selected (iOS beginRenaming), once per new value.
            if (!text.isNullOrEmpty() && text != appliedText) {
                bar.text = text
                bar.post {
                    bar.showKeyboard()
                    bar.textField.selectAll()
                }
            }
            appliedText = text
            return
        }
        text?.takeIf { it != bar.text }?.let { bar.text = it }
        applyStyle(arguments)
        bar.showsCancelButton = arguments["showsCancelButton"] as? Boolean ?: false
        bar.fieldShadowOpacity = (arguments["fieldShadowOpacity"] as? Number)?.toFloat() ?: 0f
        bar.searchBarStyle = if (arguments["searchBarStyle"] == "bordered") CYLSearchBarStyle.Bordered else CYLSearchBarStyle.Plain
        bar.searchIcon = if (arguments["showsSearchIcon"] as? Boolean != false) ContextCompat.getDrawable(bar.context, com.cyl.search.R.drawable.cyl_search_ic_search) else null
        if (arguments["navigationFieldStyle"] == true) bar.applyNavigationFieldStyle()
        // The core's default search button: shown unless Dart hides it; with a Dart handler a tap goes to Dart (`didTapSearchButton`),
        // else the core submits (`didSubmit`).
        bar.showsSearchButton = arguments["showsSearchButton"] as? Boolean ?: true
        bar.searchButtonStyle = if (arguments["searchButtonStyle"] == "icon") CYLSearchBarSearchButtonStyle.Icon else CYLSearchBarSearchButtonStyle.Text
        if (bar.searchButtonTitle != arguments["searchButtonTitle"]) bar.searchButtonTitle = arguments["searchButtonTitle"] as? String
        bar.searchButtonHandler = if (arguments["hasSearchButtonHandler"] == true) ({ view -> channel.invokeMethod("didTapSearchButton", mapOf("text" to view.text.orEmpty())) }) else null
        @Suppress("UNCHECKED_CAST")
        val items = (arguments["items"] as? List<Map<String, Any?>>) ?: emptyList()
        // Rebuilt only when Dart sends other items, so a rebuild of the widget keeps the native selection; a change of
        // animationLoops or animationSpeed alone keeps the items (the core's setItems).
        if (items != appliedItems) {
            appliedItems = items
            bar.setItems(items)
        }
    }

    private var appliedItems: List<Map<String, Any?>> = emptyList()

    /**
     * The QMUI style options of the bar (iOS `CYLSearchBar` members, here on `CYLSearchBarView`): appearance first, so
     * an option set beside it wins; margins in dp for both states.
     */
    private fun applyStyle(arguments: Map<String, Any?>) {
        (arguments["appearance"] as? Map<*, *>)?.let { bar.appearanceStyle = appearance(it) }
        bar.centersPlaceholder = arguments["centersPlaceholder"] as? Boolean ?: false
        (arguments["placeholderColor"] as? Number)?.let { bar.placeholderColor = it.toInt() }
        (arguments["textColor"] as? Number)?.let { bar.textColor = it.toInt() }
        (arguments["fontSize"] as? Number)?.let { bar.fontSize = it.toFloat() }
        bar.cancelButtonFontSize = (arguments["cancelButtonFontSize"] as? Number)?.toFloat()
        val field = rects(arguments["textFieldMargins"], arguments["activeTextFieldMargins"])
        bar.textFieldMarginsProvider = field?.let { (rest, active) -> { _, isActive -> if (isActive) active else rest } }
        val cancel = rects(arguments["cancelButtonMargins"], arguments["activeCancelButtonMargins"])
        bar.cancelButtonMarginsProvider = cancel?.let { (rest, active) -> { _, isActive -> if (isActive) active else rest } }
    }

    private fun appearance(map: Map<*, *>): CYLSearchBarAppearance = CYLSearchBarAppearance().also {
        it.fieldBackgroundColor = (map["fieldBackgroundColor"] as? Number)?.toInt()
        it.fieldBorderColor = (map["fieldBorderColor"] as? Number)?.toInt()
        (map["fieldCornerRadius"] as? Number)?.let { radius -> it.fieldCornerRadius = radius.toFloat() }
        it.tintColor = (map["tintColor"] as? Number)?.toInt()
        it.barBackgroundColor = (map["barBackgroundColor"] as? Number)?.toInt()
        it.cancelTitle = map["cancelTitle"] as? String
    }

    /**
     * Dart's [left, top, right, bottom] lists as dp rectangles (rest, active), or null when both are zero.
     */
    private fun rects(rest: Any?, active: Any?): Pair<Rect, Rect>? {
        fun rect(value: Any?): Rect {
            val list = (value as? List<*>)?.mapNotNull { (it as? Number)?.toInt() } ?: return Rect()
            return if (list.size == 4) Rect(list[0], list[1], list[2], list[3]) else Rect()
        }
        val pair = rect(rest) to rect(active)
        return if (pair.first == Rect() && pair.second == Rect()) null else pair
    }

    /**
     * The editing bar's `text` as Dart sent it last.
     */
    private var appliedText: String? = null

    override fun searchBarViewDidSelectItem(searchBarView: CYLSearchBarView, item: CYLSearchBarItem) {
        channel.invokeMethod("didSelectItem", mapOf("index" to item.index, "selected" to item.isSelected))
    }

    override fun getView(): View = toolbar ?: bar

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) {
        channel.invokeMethod("textDidChange", mapOf("text" to text))
    }

    override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
        if (searchBarView.isEditingBar) return
        channel.invokeMethod("didSubmit", mapOf("text" to searchBarView.text.orEmpty()))
        searchBarView.hideKeyboard()
    }

    override fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) {
        channel.invokeMethod("didCancel", null)
    }

    override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String, index: Int) {
        channel.invokeMethod("textDidChangeAtIndex", mapOf("text" to text, "index" to index))
    }

    override fun searchBarViewDidCompleteSearch(searchBarView: CYLSearchBarView, text: String, index: Int) {
        channel.invokeMethod("didCompleteSearch", mapOf("text" to text, "index" to index))
    }

    override fun searchBarViewDidRemoveSearchAtIndex(searchBarView: CYLSearchBarView, index: Int) {
        if (syncingSearches) return
        channel.invokeMethod("didRemoveSearch", mapOf("index" to index))
    }

    override fun searchBarViewDidSelectSearch(searchBarView: CYLSearchBarView, text: String, index: Int) {
        channel.invokeMethod("didSelectSearch", mapOf("text" to text, "index" to index))
    }
}

/**
 * CollectionViewClassifyMenu's `CYLTagListView` filling the platform view, one section of tags from Dart: their titles
 * and ids, the selection, the header (title and clear button) and editing mode (crosses, dragging, rename requests).
 * It reports the height its tags need at the view's width (`didChangeHeight`, in dp), again after folding, unfolding
 * and editing.
 */
internal class CYLFlutterTagListView(context: Context, arguments: Map<String, Any?>, private val channel: MethodChannel) :
    PlatformView, CYLMenuDataSource, CYLMenuDelegate {

    private var reportedHeight = -1f
    private var titles: List<String> = emptyList()
    private var ids: List<String> = emptyList()
    private var selected: Set<String> = emptySet()
    private var sectionTitle = ""
    private var showsClearButton = false
    private var showsRefreshButton = false
    private var columns = 0
    private var backgroundStyle = ""
    private var tagImages: List<String> = emptyList()
    // The screen-reader label of each tag image, parallel to tagImages ('' none); param tagImageLabels.
    private var tagImageLabels: List<String> = emptyList()
    // The subtitle of each tag (param tagSubtitles, '' none): a long press shows it in a callout with an arrow.
    private var tagSubtitles: List<String> = emptyList()
    // Param titleMaxLines: 1 single line (the default), 0 no limit, n at most n lines (ClassifyMenu `CYLTagTitleMaxLines`).
    private var titleMaxLines = 1
    private val loadedImages = HashMap<String, android.graphics.drawable.Drawable>()
    private val appContext: Context = context
    private var supportsRenaming = false

    private val tagListView = object : CYLTagListView(context) {
        override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
            super.onSizeChanged(w, h, oldw, oldh)
            reportHeight()
        }
    }

    private val flowingStyle: CYLMenuStyle? = tagListView.style?.copy()

    init {
        tagListView.showsSectionHeaders = false
        // The Flutter page shows through, as around any other widget.
        tagListView.style = tagListView.style?.copy()?.apply { backgroundColor = android.graphics.Color.TRANSPARENT }
        tagListView.menuDataSource = this
        tagListView.menuDelegate = this
        // The host adds tags through its editing bar, as the iOS example does: no add control of the list's own.
        tagListView.showsAddItemViewWhileEditing = false
        // Renaming is the host's: the list asks, Dart renames by id and sends the new titles.
        tagListView.renameRequestHandler = { indexPath, title ->
            channel.invokeMethod("didRequestRename", mapOf("index" to indexPath.item, "id" to idAt(indexPath.item), "title" to title))
        }
        apply(arguments)
        channel.setMethodCallHandler { call, result ->
            @Suppress("UNCHECKED_CAST")
            if (call.method == "update") (call.arguments as? Map<String, Any?>)?.let { apply(it) }
            result.success(null)
        }
    }

    private fun idAt(index: Int): String = ids.getOrNull(index)?.takeIf { it.isNotEmpty() } ?: titles.getOrElse(index) { "" }

    @Suppress("UNCHECKED_CAST")
    private fun apply(arguments: Map<String, Any?>) {
        tagListView.foldControl = cylFoldControl(arguments["foldControlPosition"], arguments["foldControlContent"])
        tagListView.defaultVisibleRows = maxOf(0, (arguments["foldedRowCount"] as? Number)?.toInt() ?: 2)
        tagListView.selectionMode = if (arguments["selectionMode"] == "multiple") {
            CYLMenuSelectionMode.CYLMenuSelectionModeMultiple
        } else {
            CYLMenuSelectionMode.CYLMenuSelectionModeNone
        }
        tagListView.allowsEmptySelection = true
        sectionTitle = arguments["sectionTitle"] as? String ?: ""
        showsClearButton = arguments["showsClearButton"] as? Boolean ?: false
        showsRefreshButton = arguments["showsRefreshButton"] as? Boolean ?: false
        columns = maxOf(0, (arguments["columns"] as? Number)?.toInt() ?: 0)
        backgroundStyle = arguments["backgroundStyle"] as? String ?: ""
        tagImages = (arguments["tagImages"] as? List<String>) ?: emptyList()
        tagImageLabels = (arguments["tagImageLabels"] as? List<String>) ?: emptyList()
        tagSubtitles = (arguments["tagSubtitles"] as? List<String>) ?: emptyList()
        titleMaxLines = (arguments["titleMaxLines"] as? Number)?.toInt() ?: 1
        // A callout for the subtitles; the default (reorder where editable, else report) when no tag has one.
        tagListView.longPressAction = if (tagSubtitles.any { it.isNotEmpty() }) {
            CYLTagLongPressActions.first(listOf(CYLTagLongPressActions.reorder, CYLTagLongPressActions.callout))
        } else {
            CYLTagLongPressActions.makeDefault()
        }
        applyListStyle()
        loadTagImages()
        supportsRenaming = arguments["supportsRenaming"] as? Boolean ?: false
        titles = (arguments["tags"] as? List<String>) ?: emptyList()
        ids = (arguments["tagIds"] as? List<String>) ?: emptyList()
        selected = ((arguments["selectedIds"] as? List<String>) ?: emptyList()).toSet()
        tagListView.showsSectionHeaders = sectionTitle.isNotEmpty() || showsClearButton || showsRefreshButton
        tagListView.reloadMenuData()
        val editing = arguments["editing"] as? Boolean ?: false
        if (editing != tagListView.isEditing) tagListView.setEditing(editing, false)
        applySelection()
        reportHeight()
    }

    /** The list's style for `columns` and `showsRefreshButton` (a style assignment replaces the icon, so it is applied together). */
    private fun applyListStyle() {
        // The search bar core's default tag look (capsule tags, light border, bold header, 16 dp inset), customizable through
        // CYLSearchTagListStyle.
        val base = if (columns > 0) {
            CYLMenuStyle.gridStyleWithNumberOfItemsPerRow(columns).apply { CYLSearchTagListStyle.applyGrid(this, appContext) }
        } else {
            (flowingStyle?.copy() ?: CYLMenuStyle()).apply { CYLSearchTagListStyle.applyDefaults(this, appContext) }
        }
        base.backgroundColor = android.graphics.Color.TRANSPARENT
        base.titleMaxLines = if (titleMaxLines <= 0) CYLTagTitleMaxLines.UNLIMITED else titleMaxLines
        // "liquidGlass" or flat (CYLSearchTagListStyle.applyBackgroundStyle, iOS `applyBackgroundStyle(named:to:)`).
        CYLSearchTagListStyle.applyBackgroundStyle(backgroundStyle, base)
        if (showsRefreshButton) CYLSearchTagListHeader.applyRefreshIcon(appContext, base)
        tagListView.style = base
    }

    /** Loads the tag images (Flutter asset keys, '' none) once; the list reloads when one arrives. */
    private fun loadTagImages() {
        val loader = io.flutter.FlutterInjector.instance().flutterLoader()
        tagImages.filter { it.isNotEmpty() && it !in loadedImages }.distinct().forEach { key ->
            try {
                val lookup = loader.getLookupKeyForAsset(key)
                // Flutter's resolution variants (`2.0x/name.png`, `3.0x/name.png` beside the 1x file): the one for this screen, so a
                // 30 x 18 image is 30 x 18 dp as on iOS, not 30 px (11 dp on a 2.8 density screen).
                val ratio = Math.ceil(appContext.resources.displayMetrics.density.toDouble()).toInt().coerceIn(1, 3)
                val (stream, scale) = openAtDensity(lookup, ratio)
                stream.use {
                    val bitmap = android.graphics.BitmapFactory.decodeStream(it) ?: return@use
                    when {
                        key.contains("@3x") -> bitmap.density = 480
                        key.contains("@2x") -> bitmap.density = 320
                        else -> bitmap.density = 160 * scale
                    }
                    loadedImages[key] = android.graphics.drawable.BitmapDrawable(appContext.resources, bitmap)
                }
            } catch (error: java.io.IOException) {
                // A missing asset leaves the tag without an image.
            }
        }
    }

    /** The asset at `lookup` in its `ratio`x variant, else the nearest other one: the stream and its scale (1 for the 1x file). */
    private fun openAtDensity(lookup: String, ratio: Int): Pair<java.io.InputStream, Int> {
        val slash = lookup.lastIndexOf('/')
        for (candidate in listOf(ratio, 3, 2).distinct().filter { it > 1 }) {
            try {
                return appContext.assets.open(lookup.substring(0, slash + 1) + "${candidate}.0x/" + lookup.substring(slash + 1)) to candidate
            } catch (error: java.io.IOException) {
                // No such variant: the next one.
            }
        }
        return appContext.assets.open(lookup) to 1
    }

    private fun applySelection() {
        if (tagListView.selectionMode != CYLMenuSelectionMode.CYLMenuSelectionModeMultiple) return
        tagListView.selectedIndexPaths = titles.indices.filter { idAt(it) in selected }.map { CYLIndexPath(it, 0) }
    }

    // CYLMenuDataSource

    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = titles.size
    override fun menuTitleForSection(section: Int) = sectionTitle
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = titles.getOrElse(indexPath.item) { "" }
    override fun menuSubtitleForItemAtIndexPath(indexPath: CYLIndexPath): String? =
        tagSubtitles.getOrNull(indexPath.item)?.takeIf { it.isNotEmpty() }
    override fun menuIdentifierForItemAtIndexPath(indexPath: CYLIndexPath): String = idAt(indexPath.item)
    override fun menuShowsClearButtonForSection(section: Int) = showsClearButton && !showsRefreshButton
    override fun menuShowsMoreButtonInSection(section: Int) = showsRefreshButton
    override fun menuAccessibilityLabelForMoreButtonInSection(section: Int) = CYLSearchTagListHeader.refreshLabel(appContext)
    override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath): android.graphics.drawable.Drawable? {
        val image = loadedImages[tagImages.getOrNull(indexPath.item).orEmpty()] ?: return null
        val label = tagImageLabels.getOrNull(indexPath.item).orEmpty()
        // CYLBadgeDrawable is drawn in its own colors and gives TalkBack its label (the hot icon says "Hot").
        return if (label.isNotEmpty() && image is android.graphics.drawable.BitmapDrawable) {
            com.cyl.classifymenu.CYLBadgeDrawable(appContext.resources, image.bitmap, label)
        } else {
            image
        }
    }
    override fun supportsRenamingItems() = supportsRenaming
    override fun menuRenameItemAtIndexPath(indexPath: CYLIndexPath, title: String) = Unit
    override fun supportsMovingItems() = true
    override fun menuMoveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) {
        val from = sourceIndexPath.item
        val to = toIndexPath.item
        titles = titles.toMutableList().apply { add(to, removeAt(from)) }
        if (ids.size == titles.size) ids = ids.toMutableList().apply { add(to, removeAt(from)) }
        channel.invokeMethod("didMoveTag", mapOf("from" to from, "to" to to))
    }
    override fun menuRemoveItemAtIndexPath(indexPath: CYLIndexPath) {
        val index = indexPath.item
        val id = idAt(index)
        titles = titles.filterIndexed { i, _ -> i != index }
        if (ids.size > index) ids = ids.filterIndexed { i, _ -> i != index }
        channel.invokeMethod("didDeleteTag", mapOf("index" to index, "id" to id))
    }

    // CYLMenuDelegate

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        val index = indexPath.item
        val id = idAt(index)
        val nowSelected = tagListView.selectionMode == CYLMenuSelectionMode.CYLMenuSelectionModeMultiple
        if (nowSelected) selected = selected + id
        channel.invokeMethod("didSelectTag", mapOf("index" to index, "title" to titles.getOrElse(index) { "" }, "id" to id, "selected" to nowSelected))
    }

    override fun menuDidDeselectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        val index = indexPath.item
        val id = idAt(index)
        selected = selected - id
        channel.invokeMethod("didSelectTag", mapOf("index" to index, "title" to titles.getOrElse(index) { "" }, "id" to id, "selected" to false))
    }

    override fun menuDidTapClearButtonInSection(menu: Any, section: Int) {
        channel.invokeMethod("didTapClearButton", mapOf("section" to section))
    }
    override fun menuDidTapMoreButtonInSection(menu: Any, section: Int) {
        channel.invokeMethod("didTapRefreshButton", mapOf("section" to section))
    }
    override fun menuDidChangeContentHeight(menu: Any, height: Float) = reportHeight()
    override fun menuDidChangeExpanded(menu: Any, expanded: Boolean, inSection: Int) = reportHeight()
    override fun menuDidChangeEditing(menu: Any, editing: Boolean) = reportHeight()

    // A drag of a tag or a smear selection: Dart claims the pointer in the gesture arena while it lasts (didChangeDragging),
    // so a Flutter scroll view around the list does not scroll with it, as the mini program's content page holds.
    private var reordering = false
    private var smearing = false
    private var reportedDragging = false

    override fun menuDidChangeReordering(menu: Any, reordering: Boolean) {
        this.reordering = reordering
        reportDragging()
    }

    override fun menuDidChangeSmearing(menu: Any, smearing: Boolean) {
        this.smearing = smearing
        reportDragging()
    }

    private fun reportDragging() {
        val dragging = reordering || smearing
        if (dragging == reportedDragging) return
        reportedDragging = dragging
        channel.invokeMethod("didChangeDragging", mapOf("dragging" to dragging))
    }

    private fun reportHeight() {
        val width = tagListView.width / tagListView.resources.displayMetrics.density
        if (width <= 0f) return
        // The list's own content height includes a folded inline row that `heightThatFitsWidth` can leave out.
        val height = kotlin.math.ceil(maxOf(tagListView.heightThatFitsWidth(width), tagListView.contentHeight))
        if (height != reportedHeight) {
            reportedHeight = height
            channel.invokeMethod("didChangeHeight", mapOf("height" to height.toDouble()))
        }
    }

    override fun getView(): View = tagListView

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }
}

/**
 * CYLTableViewPlaceHolder's `CYLPlaceholderView` centred in the platform view: the image of a `CYLPlaceholderStyle`
 * (by name) above a text.
 */
internal class CYLFlutterPlaceholderView(context: Context, arguments: Map<String, Any?>, private val channel: MethodChannel) :
    PlatformView {

    private val container = FrameLayout(context)

    init {
        apply(arguments)
        channel.setMethodCallHandler { call, result ->
            @Suppress("UNCHECKED_CAST")
            if (call.method == "update") (call.arguments as? Map<String, Any?>)?.let { apply(it) }
            result.success(null)
        }
    }

    private fun apply(arguments: Map<String, Any?>) {
        val name = arguments["placeholderStyle"] as? String ?: "empty"
        val style = CYLPlaceholderStyle.entries.firstOrNull { it.name.equals(name, ignoreCase = true) } ?: CYLPlaceholderStyle.Empty
        container.removeAllViews()
        val placeholder = CYLPlaceholderView(container.context, style, arguments["text"] as? String ?: "").apply { reportsContentSize = true }
        container.addView(placeholder, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT, android.view.Gravity.CENTER))
    }

    override fun getView(): View = container

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }
}

/**
 * The fold control for a Dart `CYLTagFoldControlPosition` and `CYLTagFoldControlContent` name; an inline icon by default.
 */
internal fun cylFoldControl(position: Any?, content: Any?) = com.cyl.classifymenu.CYLMenuFoldControl().apply {
    this.position = when (position) {
        "none" -> com.cyl.classifymenu.CYLMenuFoldControlPosition.NONE
        "bottom", "footer" -> com.cyl.classifymenu.CYLMenuFoldControlPosition.FOOTER
        "topTrailing", "headerTrailing" -> com.cyl.classifymenu.CYLMenuFoldControlPosition.HEADER_TRAILING
        "topLeading", "headerLeading" -> com.cyl.classifymenu.CYLMenuFoldControlPosition.HEADER_LEADING
        else -> com.cyl.classifymenu.CYLMenuFoldControlPosition.TAIL
    }
    this.content = when (content) {
        "iconAndTitle" -> com.cyl.classifymenu.CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle
        "title" -> com.cyl.classifymenu.CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle
        else -> com.cyl.classifymenu.CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon
    }
}

