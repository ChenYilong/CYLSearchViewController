package com.cyl.search.flutter_cylsearch

import android.content.Context
import android.view.ContextThemeWrapper
import android.view.View
import android.widget.FrameLayout
import com.cyl.classifymenu.CYLTagListView
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.search.CYLSearchBarView
import com.cyl.search.CYLSearchBarViewDelegate
import com.cyl.search.CYLSearchSuggestionCachePolicy
import com.cyl.search.CYLSearchSuggestionStyle
import com.cyl.search.CYLSearchView
import com.cyl.search.CYLSearchViewDelegate
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

    init {
        searchView.delegate = this
        // The page stays open after a submit: Dart decides what a submitted query does.
        searchView.closesOnSubmit = false
        apply(arguments)
        searchView.installInView(container)
        searchView.showSearch(false)
        channel.setMethodCallHandler { call, result ->
            @Suppress("UNCHECKED_CAST")
            if (call.method == "update") (call.arguments as? Map<String, Any?>)?.let { apply(it) }
            result.success(null)
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun apply(arguments: Map<String, Any?>) {
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
        searchView.suggestionsFoldControl = cylFoldControl(arguments["suggestionsFoldControlPosition"], arguments["suggestionsFoldControlContent"])
        searchView.suggestionsFoldedRowCount = maxOf(0, (arguments["suggestionsFoldedRowCount"] as? Number)?.toInt() ?: 2)
    }

    override fun getView(): View = container

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun searchViewTextDidChange(searchView: CYLSearchView, text: String) {
        channel.invokeMethod("textDidChange", mapOf("text" to text))
    }

    override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean {
        channel.invokeMethod("didSubmit", mapOf("text" to text))
        return true
    }

    override fun searchViewDidSelectSuggestion(searchView: CYLSearchView, suggestion: String, index: Int) {
        channel.invokeMethod("didSelectSuggestion", mapOf("suggestion" to suggestion, "index" to index))
    }

    override fun searchViewDidClose(searchView: CYLSearchView) {
        channel.invokeMethod("didClose", null)
    }
}

/**
 * `CYLSearchBarView` filling the platform view.
 */
internal class CYLFlutterSearchBarView(context: Context, arguments: Map<String, Any?>, private val channel: MethodChannel) :
    PlatformView, CYLSearchBarViewDelegate {

    private val bar = CYLSearchBarView(context)

    init {
        bar.delegate = this
        apply(arguments)
        channel.setMethodCallHandler { call, result ->
            @Suppress("UNCHECKED_CAST")
            if (call.method == "update") (call.arguments as? Map<String, Any?>)?.let { apply(it) }
            result.success(null)
        }
    }

    private fun apply(arguments: Map<String, Any?>) {
        bar.placeholder = arguments["placeholder"] as? String
        (arguments["text"] as? String)?.takeIf { it != bar.text }?.let { bar.text = it }
        bar.showsCancelButton = arguments["showsCancelButton"] as? Boolean ?: false
        bar.fieldShadowOpacity = (arguments["fieldShadowOpacity"] as? Number)?.toFloat() ?: 0f
    }

    override fun getView(): View = bar

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) {
        channel.invokeMethod("textDidChange", mapOf("text" to text))
    }

    override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
        channel.invokeMethod("didSubmit", mapOf("text" to searchBarView.text.orEmpty()))
        searchBarView.hideKeyboard()
    }

    override fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) {
        channel.invokeMethod("didCancel", null)
    }
}

/**
 * CollectionViewClassifyMenu's `CYLTagListView` filling the platform view; it reports the height its tags need at the
 * view's width (`didChangeHeight`, in dp), so Dart can size it.
 */
internal class CYLFlutterTagListView(context: Context, arguments: Map<String, Any?>, private val channel: MethodChannel) :
    PlatformView {

    private var reportedHeight = -1f

    private val tagListView = object : CYLTagListView(context) {
        override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
            super.onSizeChanged(w, h, oldw, oldh)
            reportHeight()
        }
    }

    init {
        tagListView.showsSectionHeaders = false
        // The Flutter page shows through, as around any other widget.
        tagListView.style = tagListView.style?.copy()?.apply { backgroundColor = android.graphics.Color.TRANSPARENT }
        tagListView.tagClickHandler = { index, tag -> channel.invokeMethod("didSelectTag", mapOf("index" to index, "title" to tag.title)) }
        // Folding and unfolding change the height: report it again.
        tagListView.menuDelegate = object : com.cyl.classifymenu.CYLMenuDelegate {
            override fun menuDidChangeContentHeight(menu: Any, height: Float) = reportHeight()
            override fun menuDidChangeExpanded(menu: Any, expanded: Boolean, inSection: Int) = reportHeight()
        }
        apply(arguments)
        channel.setMethodCallHandler { call, result ->
            @Suppress("UNCHECKED_CAST")
            if (call.method == "update") (call.arguments as? Map<String, Any?>)?.let { apply(it) }
            result.success(null)
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun apply(arguments: Map<String, Any?>) {
        tagListView.foldControl = cylFoldControl(arguments["foldControlPosition"], arguments["foldControlContent"])
        tagListView.defaultVisibleRows = maxOf(0, (arguments["foldedRowCount"] as? Number)?.toInt() ?: 2)
        tagListView.setTagsWithTitles((arguments["tags"] as? List<String>) ?: emptyList())
        reportHeight()
    }

    private fun reportHeight() {
        val width = tagListView.width / tagListView.resources.displayMetrics.density
        if (width <= 0f) return
        val height = kotlin.math.ceil(tagListView.heightThatFitsWidth(width))
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
 * The fold control for a Dart `CYLTagFoldControlPosition` and `CYLTagFoldControlContent` name; an inline icon by default.
 */
internal fun cylFoldControl(position: Any?, content: Any?) = com.cyl.classifymenu.CYLMenuFoldControl().apply {
    this.position = when (position) {
        "none" -> com.cyl.classifymenu.CYLMenuFoldControlPosition.CYLMenuFoldControlPositionNone
        "bottom" -> com.cyl.classifymenu.CYLMenuFoldControlPosition.CYLMenuFoldControlPositionBottom
        "topTrailing" -> com.cyl.classifymenu.CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopTrailing
        "topLeading" -> com.cyl.classifymenu.CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopLeading
        else -> com.cyl.classifymenu.CYLMenuFoldControlPosition.CYLMenuFoldControlPositionInline
    }
    this.content = when (content) {
        "iconAndTitle" -> com.cyl.classifymenu.CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle
        "title" -> com.cyl.classifymenu.CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle
        else -> com.cyl.classifymenu.CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon
    }
}

