package com.cyl.search

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.os.Parcelable
import android.text.TextUtils
import android.util.AttributeSet
import android.util.SparseArray
import android.util.TypedValue
import android.view.Gravity
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.widget.ImageViewCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLTagListView
import androidx.activity.BackEventCompat
import com.cyl.placeholder.CYLPlaceholderAction
import com.cyl.placeholder.CYLPlaceholderActionHandler
import com.cyl.placeholder.CYLPlaceholderButtonStyle
import com.cyl.placeholder.CYLPlaceholderComponent
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.placeholder.CYLPlaceholderStyle
import com.cyl.placeholder.CYLPlaceholderStackView
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.cyl_header
import com.cyl.refresh.layout.CYLRefreshLayout

/**
 * How a long suggestion is cut (iOS `NSLineBreakMode`).
 */
enum class CYLLineBreakMode {
    /**
     * The whole text on several lines, wrapped at word boundaries.
     */
    WordWrapping,

    /**
     * The whole text on several lines, wrapped at any character.
     */
    CharWrapping,

    /**
     * One line, cut off at the edge.
     */
    Clipping,

    /**
     * One line with an ellipsis at the start.
     */
    TruncatingHead,

    /**
     * One line with an ellipsis at the end.
     */
    TruncatingTail,

    /**
     * One line with an ellipsis in the middle.
     */
    TruncatingMiddle,
}

/**
 * How the suggestions are shown under the search bar (`CYLSearchView.suggestionStyle`).
 */
enum class CYLSearchSuggestionStyle {
    /**
     * One suggestion per row with its icon (`suggestionsTableView`; iOS table view).
     */
    List,

    /**
     * Tags that wrap like words (`suggestionsTagView`, CollectionViewClassifyMenu's `CYLTagListView`; iOS collection
     * view).
     */
    Tags,
}

/**
 * Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button. Every method
 * is optional.
 */
interface CYLSearchViewDelegate {

    /**
     * The search view finished opening (MaterialSearchView `onSearchViewShown`).
     */
    fun searchViewDidShow(searchView: CYLSearchView) {}

    /**
     * The search view finished closing (MaterialSearchView `onSearchViewClosed`).
     */
    fun searchViewDidClose(searchView: CYLSearchView) {}

    /**
     * The search view is about to open (iOS `willPresentSearchController`).
     */
    fun searchViewWillShow(searchView: CYLSearchView) {}

    /**
     * The search view is about to close (iOS `willDismissSearchController`).
     */
    fun searchViewWillClose(searchView: CYLSearchView) {}

    /**
     * Update the results for `searchString`: called on every text change, also with "" (the first opening, all text
     * deleted, the clear button, the close with `clearsQueryOnClose`), as UIKit does (iOS `updateResultsFor`).
     */
    fun searchViewUpdateResults(searchView: CYLSearchView, searchString: String) {}

    /**
     * `showEmptyView` is about to put its placeholder under the bar (QMUI `willShowEmptyView`).
     */
    fun searchViewWillShowEmptyView(searchView: CYLSearchView, emptyView: View) {}

    /**
     * The query changed (`onQueryTextChange`).
     */
    fun searchViewTextDidChange(searchView: CYLSearchView, text: String) {}

    /**
     * The query was submitted (`onQueryTextSubmit`). Return true when you handled it and the search view stays open;
     * return false (the default) to let the search view close.
     */
    fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean = false

    /**
     * The field started or stopped editing (lapism `OnFocusChangeListener`).
     */
    fun searchViewDidChangeFocus(searchView: CYLSearchView, focused: Boolean) {}

    /**
     * A suggestion was tapped (MaterialSearchView `setOnItemClickListener`). The field shows it first, and it is
     * submitted when `submitsOnSuggestionSelection` is true.
     */
    fun searchViewDidSelectSuggestion(searchView: CYLSearchView, suggestion: String, index: Int) {}

    /**
     * The voice button was tapped. Start speech recognition and pass the result to `setQuery(query, submit)`.
     */
    fun searchViewVoiceButtonClicked(searchView: CYLSearchView) {}

    /**
     * The navigation button (the back arrow by default) was tapped. By default it closes the search view.
     */
    fun searchViewNavigationButtonClicked(searchView: CYLSearchView) {
        searchView.closeSearch()
    }

    /**
     * A result of `resultsDataSource` was tapped in `resultsTableView`.
     */
    fun searchViewDidSelectResult(searchView: CYLSearchView, result: Any) {}
}

/**
 * Supplies the results a `CYLSearchView` lists in `resultsTableView` and configures their cells (was
 * `CYLSearchResultsDataSource`).
 */
interface CYLSearchViewDataSource {

    /**
     * The results for `query`, the current text of the search bar (never blank: a blank query shows the
     * suggestions).
     */
    fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any>

    /**
     * Shows `result` in `cell`, a row of `resultsTableView` (its icon is hidden by default).
     */
    fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any)
}

/**
 * A suggestion row of a `CYLSearchView`: an icon and a text (iOS `UITableViewCell` with a list content
 * configuration).
 */
class CYLSearchSuggestionCell(context: Context) : LinearLayout(context) {

    /**
     * The icon before the text (`suggestionImage`).
     */
    val imageView: ImageView = ImageView(context)

    /**
     * The suggestion text.
     */
    val textLabel: TextView = TextView(context)

    init {
        val density = resources.displayMetrics.density
        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        minimumHeight = (48 * density).toInt()
        val horizontal = (16 * density).toInt()
        setPaddingRelative(horizontal, (11 * density).toInt(), horizontal, (11 * density).toInt())
        imageView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        addView(imageView, LayoutParams((24 * density).toInt(), (24 * density).toInt()).apply { marginEnd = horizontal })
        textLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
        addView(textLabel, LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f))
        isClickable = true
        isFocusable = true
        // The ripple is the foreground, so a row background color (`suggestionBackgroundColor`) keeps it.
        foreground = ContextCompat.getDrawable(context, TypedValue().also {
            context.theme.resolveAttribute(android.R.attr.selectableItemBackground, it, true)
        }.resourceId)
    }
}

/**
 * A search page that opens over its host view (iOS `CYLSearchView`; MiguelCatalan and lapism
 * `MaterialSearchView`): a `CYLSearchBarView` below the status bar, a divider, a list of suggestions filtered as you
 * type, the results of `resultsDataSource` in `resultsTableView` (with an optional pull-to-refresh), and an optional
 * content view of yours below. The page is opaque, so the bar never covers a view of the host. It replaces the former
 * fragments `CYLSearchController` and `CYLSearchResultsViewController`: `showSearch(activity)` or
 * `showSearch(viewGroup)` installs it over a host and opens it, `closeSearch(animated, completion)` closes it.
 */
class CYLSearchView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(context, attrs, defStyleAttr) {

    private val density = resources.displayMetrics.density
    private val pageView = LinearLayout(context)
    private val bodyView = FrameLayout(context)
    private val scrimView = View(context)
    private val emptyResultsSlot = CYLSearchEmptyViewSlot(bodyView, 0) { keyboardInset }
    private val emptySuggestionsSlot = CYLSearchEmptyViewSlot(bodyView, 0) { keyboardInset }
    private val explicitEmptySlot = CYLSearchEmptyViewSlot(bodyView, -1) { keyboardInset }
    private val adapter = SuggestionAdapter()
    private val resultsAdapter = ResultsAdapter()
    private val resultsRefreshLayout = CYLRefreshContainer(context)
    private var resultsVisible = false
    private var closing = false
    private val closeCompletions = mutableListOf<() -> Unit>()
    private var suggestionsVisible = false
    private var topInset = 0
    private var keyboardInset = 0
    private val backCallback = object : OnBackPressedCallback(false) {
        override fun handleOnBackPressed() {
            if (isCovered()) {
                passBackThrough()
            } else {
                closeSearch()
            }
        }

        override fun handleOnBackStarted(backEvent: BackEventCompat) {
            if (!isCovered()) pageView.animate().cancel()
        }

        override fun handleOnBackProgressed(backEvent: BackEventCompat) {
            if (!supportsSwipeToDismissSearch || isCovered()) return
            val direction = if (backEvent.swipeEdge == BackEventCompat.EDGE_RIGHT) -1 else 1
            pageView.translationX = direction * backEvent.progress * width * SWIPE_TRAVEL
            pageView.alpha = 1f - 0.5f * backEvent.progress
        }

        override fun handleOnBackCancelled() {
            pageView.animate().translationX(0f).alpha(1f).setDuration((animationDuration * 1000).toLong()).start()
        }
    }

    /**
     * Receives the events of the search view.
     */
    var delegate: CYLSearchViewDelegate? = null

    /**
     * The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button).
     */
    val searchBarView: CYLSearchBarView = CYLSearchBarView(context)

    /**
     * The line under the search bar.
     */
    val dividerView: View = View(context)

    /**
     * The list of suggestions (iOS `suggestionsTableView`).
     */
    val suggestionsTableView: RecyclerView = RecyclerView(context)

    /**
     * The tags that show the suggestions when `suggestionStyle` is `Tags` (CollectionViewClassifyMenu's
     * `CYLTagListView`). Style it directly: colors (`colorTheme`), spacing, rows, the tag style.
     */
    val suggestionsTagView: CYLTagListView = CYLTagListView(context)

    /**
     * The fold control of the tag suggestions (CollectionViewClassifyMenu's `CYLMenuFoldControl`; iOS
     * `suggestionsFoldControl`). An inline chevron as the last tag by default: tap it to show every row, again to fold.
     * Position `None` shows every tag without a control.
     */
    var suggestionsFoldControl: CYLMenuFoldControl
        get() = suggestionsTagView.foldControl ?: CYLMenuFoldControl()
        set(value) {
            suggestionsTagView.foldControl = value
            updateSuggestionsVisibility()
        }

    /**
     * The rows of tag suggestions shown while folded (iOS `suggestionsFoldedRowCount`). 2 by default; 0 shows every row.
     */
    var suggestionsFoldedRowCount: Int
        get() = suggestionsTagView.defaultVisibleRows
        set(value) {
            suggestionsTagView.defaultVisibleRows = value
            updateSuggestionsVisibility()
        }

    /**
     * How the suggestions are shown: tags (`Tags`, the default, folded to `suggestionsFoldedRowCount` rows with the
     * fold control as the last tag) or a list (`List`).
     */
    var suggestionStyle: CYLSearchSuggestionStyle = CYLSearchSuggestionStyle.Tags
        set(value) {
            field = value
            updateSuggestionsVisibility()
        }

    /**
     * Shows CYLTableViewPlaceHolder's placeholder for `emptyResultsScenario` under the search bar while a non-empty
     * query matches no suggestion, in both suggestion styles. False by default.
     */
    var showsEmptyResultsPlaceholder: Boolean = false
        set(value) {
            field = value
            refilter()
        }

    /**
     * The CYLTableViewPlaceHolder scenario of that placeholder. `NoSearchResults` (an icon, a title and a hint) by
     * default; `NoContent` shows the plain empty state.
     */
    var emptyResultsScenario: CYLPlaceholderScenario = CYLPlaceholderScenario.NoSearchResults
        set(value) {
            field = value
            emptyResultsSlot.remove()
            refilter()
        }

    /**
     * The placeholder shown for empty results (CYLTableViewPlaceHolder's `CYLPlaceholderStackView`), created the first
     * time it is shown; null before.
     */
    val emptyResultsView: CYLPlaceholderStackView?
        get() = emptyResultsSlot.view

    private var emptyResultsVisible = false

    // Suggestion cache (docs/core-todo.md)

    /**
     * Where submitted queries are cached for the suggestion list (iOS `suggestionCachePolicy`): `Database`, a local
     * SQLite database, by default. While the query is empty the list shows the cached queries, newest first, under a
     * header whose delete button clears them; while typing, matching cached queries come before matching
     * `suggestions`. `None` turns the cache off.
     */
    var suggestionCachePolicy: CYLSearchSuggestionCachePolicy = CYLSearchSuggestionCachePolicy.Database
        set(value) {
            field = value
            rebuildSuggestionCache()
        }

    /**
     * Separates the caches of different search screens. "CYLSearchView" by default.
     */
    var suggestionCacheName: String = "CYLSearchView"
        set(value) {
            field = value
            rebuildSuggestionCache()
        }

    /**
     * The cache in use: the built-in store of `suggestionCachePolicy`, or a store of yours (set it after the policy).
     * Null when the policy is `None`.
     */
    var suggestionCache: CYLSearchSuggestionCache? =
        CYLSearchSuggestionStore.cacheWithPolicy(context, CYLSearchSuggestionCachePolicy.Database, "CYLSearchView")
        set(value) {
            field = value
            if (isAttachedToWindow) {
                observeHistory()
            }
            refilter()
        }

    /**
     * The header above the cached queries: a title and, at its end, `clearSuggestionCacheButton`.
     */
    val suggestionCacheHeaderView = LinearLayout(context)

    /**
     * The title of `suggestionCacheHeaderView` ("Recent searches").
     */
    val suggestionCacheTitleLabel = TextView(context)

    /**
     * Clears the whole cache (a delete icon at the top right of the suggestion list).
     */
    val clearSuggestionCacheButton = ImageButton(context)

    /**
     * Shows CYLTableViewPlaceHolder's placeholder for `emptySuggestionsScenario` while the query is empty and the cache
     * holds nothing. True by default.
     */
    var showsEmptySuggestionsPlaceholder = true
        set(value) {
            field = value
            refilter()
        }

    /**
     * The scenario of that placeholder. `NoContent` by default.
     */
    var emptySuggestionsScenario: CYLPlaceholderScenario = CYLPlaceholderScenario.NoContent
        set(value) {
            field = value
            emptySuggestionsSlot.remove()
            refilter()
        }

    /**
     * The placeholder shown for an empty cache, created the first time it is shown; null before.
     */
    val emptySuggestionsView: CYLPlaceholderStackView?
        get() = emptySuggestionsSlot.view

    /**
     * Focuses the search field when the search opens, which raises the keyboard (iOS `focusesSearchFieldOnShow`). True
     * by default. False opens the search with the suggestion list (or the empty placeholder) and the keyboard down; the
     * field is focused when the person taps it.
     */
    var focusesSearchFieldOnShow = true

    /**
     * Shows `suggestionCacheHeaderView` (the title and `clearSuggestionCacheButton`) above the cached queries (iOS
     * `showsSuggestionCacheHeader`). True by default. False takes the header away, for a host that clears the history with
     * its own control that calls `clearSuggestionCache()`.
     */
    var showsSuggestionCacheHeader = true
        set(value) {
            field = value
            refilter()
        }

    private var showsCachedQueries = false
    private var emptySuggestionsVisible = false

    /**
     * The color of `dividerView` (lapism `setDividerColor`). The theme's divider color when null; transparent hides
     * it.
     */
    var dividerColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * A view of yours shown under the divider, behind the suggestions (lapism `addView`): a results list, a history,
     * anything. Null by default.
     */
    var contentView: View? = null
        set(value) {
            field?.let { bodyView.removeView(it) }
            field = value
            value?.let {
                (it.parent as? ViewGroup)?.removeView(it)
                bodyView.addView(it, 0, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
            }
            applyLayout()
        }

    /**
     * The color behind the page while it is open (lapism `setScrimColor`). Null (none) by default: the page fills the
     * view. With a scrim and no content view, the page is only as tall as the suggestions and the scrim (tapping it
     * closes the search) shows below.
     */
    var scrimColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The page background. The theme's window background when null.
     */
    var pageBackgroundColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    // Suggestions

    /**
     * The suggestions to filter as the text changes (MaterialSearchView `setSuggestions`).
     */
    var suggestions: List<String> = emptyList()
        set(value) {
            field = value
            refilter()
        }

    /**
     * Decides whether a suggestion matches the query: `(suggestion, query) -> Boolean`. Null uses a case- and
     * diacritic-insensitive "contains" test. An empty query matches nothing unless `showsSuggestionsForEmptyQuery`.
     */
    var suggestionFilter: ((String, String) -> Boolean)? = null
        set(value) {
            field = value
            refilter()
        }

    /**
     * Lists every suggestion while the query is empty. False by default.
     */
    var showsSuggestionsForEmptyQuery: Boolean = false
        set(value) {
            field = value
            refilter()
        }

    /**
     * The suggestions that match the current query, in their original order.
     */
    var filteredSuggestions: List<String> = emptyList()
        private set

    /**
     * The icon before each suggestion (MaterialSearchView `setSuggestionIcon`). A magnifier by default; null shows
     * none.
     */
    var suggestionImage: Drawable? = ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_search)
        set(value) {
            field = value
            reloadSuggestions()
        }

    /**
     * The tint of `suggestionImage`. The theme's secondary text color when null.
     */
    var suggestionImageTintColor: Int? = null
        set(value) {
            field = value
            reloadSuggestions()
        }

    /**
     * The background of the suggestion rows (`setSuggestionBackground`). Null keeps the page background.
     */
    var suggestionBackgroundColor: Int? = null
        set(value) {
            field = value
            suggestionsTableView.setBackgroundColor(value ?: Color.TRANSPARENT)
            reloadSuggestions()
        }

    /**
     * The color of the suggestion text. The theme's primary text color when null.
     */
    var suggestionTextColor: Int? = null
        set(value) {
            field = value
            reloadSuggestions()
        }

    /**
     * How a long suggestion is cut (MaterialSearchView `setEllipsize`). `WordWrapping` by default (whole text on
     * several lines); `TruncatingTail` keeps one line with an ellipsis.
     */
    var suggestionLineBreakMode: CYLLineBreakMode = CYLLineBreakMode.WordWrapping
        set(value) {
            field = value
            reloadSuggestions()
        }

    /**
     * Submits a suggestion as soon as it is tapped (`setSubmitOnClick`). False by default: the field shows it and the
     * person can edit it.
     */
    var submitsOnSuggestionSelection: Boolean = false

    /**
     * Configures each suggestion cell after the defaults (a custom adapter's `getView`): `(cell, suggestion, index)`.
     */
    var suggestionCellConfiguration: ((CYLSearchSuggestionCell, String, Int) -> Unit)? = null
        set(value) {
            field = value
            reloadSuggestions()
        }

    // Results

    /**
     * Supplies the results (was `CYLSearchController(searchDataSource:)` and `searchDataSource`). While it is set and
     * the query is not blank, `resultsTableView` lists its results below the bar instead of the suggestions; null (the
     * default) keeps the suggestions only.
     */
    var resultsDataSource: CYLSearchViewDataSource? = null
        set(value) {
            field = value
            refilter()
        }

    /**
     * The list of results (was the results controller's `tableView`). Style it directly; its rows are
     * `CYLSearchSuggestionCell`s configured by `resultsDataSource`.
     */
    val resultsTableView: RecyclerView = RecyclerView(context)

    /**
     * The results of the current query, as `resultsDataSource` returned them; empty while the query is blank.
     */
    var searchResults: List<Any> = emptyList()
        private set

    /**
     * Queries `resultsDataSource` again for the current query and reloads `resultsTableView` (was
     * `reloadSearchResults()` and `reloadResultsTableView()`).
     */
    fun reloadResults() = refilter()

    // Refresh

    /**
     * Non-null adds pull-to-refresh to `resultsTableView` (CYLTableViewPlaceHolder's `CYLRefreshNormalHeader`); null
     * removes it. Call `endRefreshing()` on every
     * completion path, and do not capture the screen that owns the search view strongly.
     */
    var refreshHandler: (() -> Unit)?
        get() = resultsRefreshLayout.refreshAction
        set(value) {
            resultsRefreshLayout.refreshAction = value
        }

    /**
     * True while `resultsTableView` shows its refresh indicator.
     */
    val isRefreshing: Boolean
        get() = resultsRefreshLayout.isHeaderRefreshing

    /**
     * Shows the refresh indicator of `resultsTableView` and calls `refreshHandler`, like a pull.
     */
    fun beginRefreshing() = resultsRefreshLayout.beginHeaderRefreshing()

    /**
     * Hides the refresh indicator of `resultsTableView`.
     */
    fun endRefreshing() = resultsRefreshLayout.endHeaderRefreshing()

    // Opening and closing

    /**
     * True while the search view is open (MaterialSearchView `isSearchOpen`).
     */
    var isSearchOpen: Boolean = false
        private set

    /**
     * The length of the open and close animations, in seconds (`setAnimationDuration`). 0.25 by default.
     */
    var animationDuration: Double = 0.25

    /**
     * A view of yours under the search bar while the query is empty (QMUI `launchView`): recent searches, hot
     * topics. It fills the space under the bar, replaces the cached-query list and the empty placeholders while it
     * shows, and is hidden as soon as the person types. Null by default.
     */
    var launchView: View? = null
        set(value) {
            field?.let { bodyView.removeView(it) }
            field = value
            value?.let {
                (it.parent as? ViewGroup)?.removeView(it)
                bodyView.addView(it, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
            }
            refilter()
        }

    /**
     * The same overlay as `scrimColor` (QMUI `dimmingColor`): one view dims the host below the page for the whole time
     * the search is open, and a tap on it ends the search.
     */
    @Deprecated("One overlay: use scrimColor.", ReplaceWith("scrimColor"))
    var dimmingColor: Int?
        get() = scrimColor
        set(value) {
            scrimColor = value
        }
    private var launchVisible = false

    /**
     * Gives the first match of the query in the text of each result row `resultMatchHighlightColor` (the tint color by
     * default), after `searchViewConfigureResultCell` configured the row (iOS `highlightsResultMatches`). The match ignores
     * case and diacritics, like the suggestion filter. False by default.
     */
    var highlightsResultMatches: Boolean = false
        set(value) {
            field = value
            reloadResultsTableView()
        }

    /**
     * The color of the highlighted match (iOS `resultMatchHighlightColor`). Null uses the tint color of the bar.
     */
    var resultMatchHighlightColor: Int? = null
        set(value) {
            field = value
            reloadResultsTableView()
        }

    /**
     * The text of the "no results" empty view that the search view manages itself (iOS `noResultsText`): after each update
     * of the results it shows the empty view with this text while the query is not empty and nothing is listed, and hides
     * it otherwise. Null (the default) leaves `showEmptyView` and `hideEmptyView` to the delegate.
     */
    var noResultsText: String? = null
        set(value) {
            field = value
            refilter()
        }

    /**
     * Clears the query when the search view closes and reports the empty text to `searchViewUpdateResults`, as
     * `UISearchController` does when Cancel is tapped. False by default.
     */
    var clearsQueryOnClose: Boolean = false

    /**
     * Lets the back swipe (predictive back, API 34 and later with `android:enableOnBackInvokedCallback`) drag the page
     * sideways and ends the search when it is completed (QMUI `supportsSwipeToDismissSearch`); cancelling it springs
     * the page back. The back key and the 3-button navigation always close the search. False by default.
     */
    var supportsSwipeToDismissSearch: Boolean = false

    /**
     * True while the search view is open (iOS `isActive`); the same as `isSearchOpen`.
     */
    val isActive: Boolean
        get() = isSearchOpen

    /**
     * Opens or closes the search view (iOS `setActive(_:animated:)`): `showSearch` and `closeSearch`.
     */
    fun setActive(active: Boolean, animated: Boolean) {
        if (active) showSearch(animated) else closeSearch(animated)
    }

    /**
     * The bottom edge of the search bar in this view, in pixels (iOS `searchBarMaxY`): the content starts here.
     */
    val searchBarMaxY: Int
        get() = pageView.top + searchBarView.bottom

    // The empty view and the history

    private val historyListeners = mutableListOf<(CYLSearchView) -> Unit>()

    /**
     * The placeholder shown by `showEmptyView`, or null (iOS `emptyView`).
     */
    val emptyView: CYLPlaceholderStackView?
        get() = explicitEmptySlot.view

    /**
     * True while `showEmptyView` has put its placeholder under the bar (iOS `isEmptyViewShowing`).
     */
    val isEmptyViewShowing: Boolean
        get() = explicitEmptySlot.view != null

    /**
     * Shows CYLTableViewPlaceHolder's placeholder with a title, an optional detail and an optional button under the
     * bar, over the results (QMUI `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`). Does nothing while
     * the query is empty (the launch view or the dimming is there then). It stays until `hideEmptyView`, the query is
     * emptied or the search view closes.
     */
    @JvmOverloads
    fun showEmptyView(text: String?, detailText: String? = null, buttonTitle: String? = null, buttonAction: (() -> Unit)? = null) {
        if (searchBarView.text.isNullOrEmpty()) {
            return
        }
        present(emptyPlaceholder(context, text, detailText, buttonTitle, buttonAction))
    }

    /**
     * Shows one of CYLTableViewPlaceHolder's scenarios under the bar (the placeholder of `emptyResultsScenario`).
     * Does nothing while the query is empty.
     */
    fun showEmptyView(scenario: CYLPlaceholderScenario) {
        if (searchBarView.text.isNullOrEmpty()) {
            return
        }
        present(CYLPlaceholderStackView(context, scenario))
    }

    /**
     * Removes the placeholder of `showEmptyView` (closing the search view always does).
     */
    fun hideEmptyView() {
        explicitEmptySlot.remove()
    }

    private fun present(view: CYLPlaceholderStackView) {
        delegate?.searchViewWillShowEmptyView(this, view)
        explicitEmptySlot.adopt(view, pageBackgroundColor ?: themeColor(android.R.attr.colorBackground))
        view.bringToFront()
    }

    private var historyObservation: (() -> Unit)? = null
    private var changingHistory = false

    // The one history signal (CYLSearchHistorySignal) reaches the open search view, which lists the history again, and the
    // listeners below; the view's own submit and clear are listed again by the code that made them.
    private fun observeHistory() {
        historyObservation?.invoke()
        historyObservation = suggestionCache?.let { cache -> CYLSearchHistorySignal.observe(cache) { historyChanged() } }
    }

    private fun historyChanged() {
        if (isSearchOpen && !changingHistory) {
            refilter()
        }
        historyListeners.toList().forEach { it(this) }
    }

    private fun changeHistory(change: (CYLSearchSuggestionCache) -> Unit) {
        val cache = suggestionCache ?: return
        changingHistory = true
        try {
            change(cache)
            if (cache !is CYLSearchSuggestionStore) {
                CYLSearchHistorySignal.post(cache)
            }
        } finally {
            changingHistory = false
        }
    }

    /**
     * Calls `listener` after the history changed (iOS `historyDidChangeNotification`): a submitted query went into the
     * suggestion cache, the cache was cleared, or another search view changed the same history (same policy and name). A
     * view that stays on screen while the person searches reads the history again here.
     */
    fun addHistoryDidChangeListener(listener: (CYLSearchView) -> Unit) {
        historyListeners.add(listener)
    }

    /**
     * Stops calling `listener`.
     */
    fun removeHistoryDidChangeListener(listener: (CYLSearchView) -> Unit) {
        historyListeners.remove(listener)
    }

    /**
     * Closes the search view after a submitted query that the delegate did not handle. True by default.
     */
    var closesOnSubmit: Boolean = true

    /**
     * The current query (lapism `getTextQuery`). Setting it does not submit.
     */
    var query: String?
        get() = searchBarView.text
        set(value) = setQuery(value, false)

    /**
     * Sets the page background (iOS `backgroundColor`; the view itself only shows the scrim).
     */
    override fun setBackgroundColor(color: Int) {
        pageBackgroundColor = color
    }

    init {
        visibility = GONE
        isClickable = true
        scrimView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        scrimView.setOnClickListener { closeSearch() }
        addView(scrimView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        pageView.orientation = LinearLayout.VERTICAL
        pageView.isClickable = true
        addView(pageView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT, Gravity.TOP))
        searchBarView.navigationIcon = CYLSearchBarNavigationIcon.Arrow
        searchBarView.fieldBackgroundColor = Color.TRANSPARENT
        searchBarView.delegate = BarDelegate()
        pageView.addView(searchBarView, LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        dividerView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        pageView.addView(dividerView, LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1))
        suggestionCacheHeaderView.orientation = LinearLayout.HORIZONTAL
        suggestionCacheHeaderView.gravity = Gravity.CENTER_VERTICAL
        suggestionCacheHeaderView.minimumHeight = (48 * density).toInt()
        suggestionCacheHeaderView.setPadding((16 * density).toInt(), 0, (4 * density).toInt(), 0)
        suggestionCacheHeaderView.visibility = GONE
        suggestionCacheTitleLabel.text = CYLSearchResources.localizedString(context, "search.recent")
        suggestionCacheTitleLabel.setTextColor(themeColor(android.R.attr.textColorSecondary))
        androidx.core.view.ViewCompat.setAccessibilityHeading(suggestionCacheTitleLabel, true)
        suggestionCacheHeaderView.addView(suggestionCacheTitleLabel, LinearLayout.LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f))
        clearSuggestionCacheButton.setImageResource(android.R.drawable.ic_menu_delete)
        clearSuggestionCacheButton.setBackgroundColor(Color.TRANSPARENT)
        clearSuggestionCacheButton.contentDescription = CYLSearchResources.localizedString(context, "search.clearRecent")
        clearSuggestionCacheButton.setOnClickListener { clearSuggestionCache() }
        suggestionCacheHeaderView.addView(clearSuggestionCacheButton, LinearLayout.LayoutParams((48 * density).toInt(), (48 * density).toInt()))
        pageView.addView(suggestionCacheHeaderView, LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        pageView.addView(bodyView, LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, 0, 1f))
        suggestionsTableView.layoutManager = LinearLayoutManager(context)
        suggestionsTableView.adapter = adapter
        suggestionsTableView.clipToPadding = false
        suggestionsTableView.contentDescription = CYLSearchResources.localizedString(context, "search.suggestions")
        suggestionsTableView.visibility = GONE
        suggestionsTableView.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                if (newState == RecyclerView.SCROLL_STATE_DRAGGING) {
                    searchBarView.hideKeyboard()
                }
            }
        })
        bodyView.addView(suggestionsTableView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        suggestionsTagView.visibility = GONE
        suggestionsTagView.showsSectionHeaders = false
        suggestionsTagView.contentDescription = CYLSearchResources.localizedString(context, "search.suggestions")
        // The last tag is a fold chevron by default (iOS `suggestionsFoldControl`), two rows while folded.
        suggestionsTagView.foldControl = CYLMenuFoldControl().apply {
            position = CYLMenuFoldControlPosition.TAIL
            content = CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon
        }
        suggestionsTagView.defaultVisibleRows = 2
        suggestionsTagView.tagClickHandler = { index, _ -> select(index) }
        val padding = (12 * density).toInt()
        suggestionsTagView.setPadding(padding, padding, padding, padding)
        bodyView.addView(suggestionsTagView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        resultsTableView.layoutManager = LinearLayoutManager(context)
        resultsTableView.adapter = resultsAdapter
        resultsTableView.clipToPadding = false
        resultsTableView.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                if (newState == RecyclerView.SCROLL_STATE_DRAGGING) {
                    searchBarView.hideKeyboard()
                }
            }
        })
        resultsRefreshLayout.setRefreshContent(resultsTableView)
        resultsRefreshLayout.visibility = GONE
        bodyView.addView(resultsRefreshLayout, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        ViewCompat.setOnApplyWindowInsetsListener(this) { _, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout())
            topInset = bars.top
            keyboardInset = maxOf(insets.getInsets(WindowInsetsCompat.Type.ime()).bottom, bars.bottom)
            pageView.setPadding(bars.left, topInset, bars.right, 0)
            suggestionsTableView.setPadding(0, 0, 0, keyboardInset)
            resultsTableView.setPadding(0, 0, 0, keyboardInset)
            // The placeholders are centred in what the keyboard leaves visible, not under it (2026-11-19).
            emptyResultsSlot.refreshPadding()
            emptySuggestionsSlot.refreshPadding()
            explicitEmptySlot.refreshPadding()
            insets
        }
        applyStyle()
    }

    private fun themeColor(attribute: Int): Int {
        val value = TypedValue()
        context.theme.resolveAttribute(attribute, value, true)
        return if (value.resourceId != 0) ContextCompat.getColor(context, value.resourceId) else value.data
    }

    private fun applyStyle() {
        dividerView.setBackgroundColor(dividerColor ?: (themeColor(android.R.attr.textColorPrimary) and 0x00FFFFFF or 0x1F000000))
        scrimView.setBackgroundColor(scrimColor ?: Color.TRANSPARENT)
        pageView.setBackgroundColor(pageBackgroundColor ?: themeColor(android.R.attr.colorBackground))
        applyLayout()
    }

    private fun applyLayout() {
        // With a scrim, the page is only as tall as its content and the host shows through below it.
        val wraps = scrimColor != null && contentView == null
        (pageView.layoutParams as? LayoutParams)?.let {
            it.height = if (wraps) LayoutParams.WRAP_CONTENT else LayoutParams.MATCH_PARENT
            pageView.layoutParams = it
        }
        (bodyView.layoutParams as? LinearLayout.LayoutParams)?.let {
            it.height = if (wraps) LayoutParams.WRAP_CONTENT else 0
            it.weight = if (wraps) 0f else 1f
            bodyView.layoutParams = it
        }
        (suggestionsTableView.layoutParams as? LayoutParams)?.let {
            it.height = if (wraps) LayoutParams.WRAP_CONTENT else LayoutParams.MATCH_PARENT
            suggestionsTableView.layoutParams = it
        }
        scrimView.visibility = if (scrimColor == null) GONE else VISIBLE
    }



    // True while a page of the host lies over this view (a detail page pushed from a result): Back then belongs to that
    // page, not to the search that stays open behind it.
    private fun isCovered(): Boolean {
        val bounds = android.graphics.Rect()
        if (!getGlobalVisibleRect(bounds)) {
            return false
        }
        var child: View = this
        var parent = child.parent
        while (parent is ViewGroup) {
            for (index in parent.indexOfChild(child) + 1 until parent.childCount) {
                val sibling = parent.getChildAt(index)
                val area = android.graphics.Rect()
                if (sibling.visibility == VISIBLE && sibling.width > 0 && sibling.getGlobalVisibleRect(area) && area.contains(bounds)) {
                    return true
                }
            }
            child = parent
            parent = parent.parent
        }
        return false
    }

    // Hands Back to the next callback of the activity (the covering page's) without closing the search.
    private fun passBackThrough() {
        backCallback.isEnabled = false
        try {
            (activity() as? ComponentActivity)?.onBackPressedDispatcher?.onBackPressed()
        } finally {
            backCallback.isEnabled = isSearchOpen
        }
    }

    // Opening and closing

    /**
     * Adds the search view over `view` (filling it) without opening it. `showSearch` calls it with the activity's
     * content view when the search view has no parent.
     */
    fun installInView(view: ViewGroup) {
        if (parent !== view) {
            (parent as? ViewGroup)?.removeView(this)
            view.addView(this, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        }
        bringToFront()
    }

    private fun activity(): Activity? {
        var current: Context? = context
        while (current is ContextWrapper) {
            if (current is Activity) {
                return current
            }
            current = current.baseContext
        }
        return null
    }

    /**
     * Opens the search view with animation and starts editing (`showSearch`).
     */
    fun showSearch() = showSearch(true)

    /**
     * Opens the search view and starts editing (`showSearch(animate)`).
     */
    fun showSearch(animated: Boolean) {
        if (parent == null) {
            val host = activity()?.findViewById<ViewGroup>(android.R.id.content) ?: return
            installInView(host)
        }
        bringToFront()
        if (closing) {
            // Opening again interrupts the close: the close completions run now, without `searchViewDidClose`.
            closing = false
            runCloseCompletions()
        }
        if (isSearchOpen) {
            if (focusesSearchFieldOnShow) searchBarView.showKeyboard()
            return
        }
        isSearchOpen = true
        delegate?.searchViewWillShow(this)
        visibility = VISIBLE
        backCallback.isEnabled = true
        refilter()
        delegate?.searchViewUpdateResults(this, searchBarView.text.orEmpty())
        ViewCompat.requestApplyInsets(this)
        // `focusesSearchFieldOnShow` decides when the keyboard appears: now, or when the person taps the field.
        if (focusesSearchFieldOnShow) searchBarView.showKeyboard()
        val finish = {
            searchBarView.textField.sendAccessibilityEvent(android.view.accessibility.AccessibilityEvent.TYPE_VIEW_FOCUSED)
            delegate?.searchViewDidShow(this)
        }
        animate().cancel()
        if (!animated || animationDuration <= 0) {
            alpha = 1f
            pageView.translationY = 0f
            finish()
            return
        }
        alpha = 0f
        pageView.translationY = -12 * density
        val duration = (animationDuration * 1000).toLong()
        pageView.animate().translationY(0f).setDuration(duration).start()
        animate().alpha(1f).setDuration(duration).withEndAction { finish() }.start()
    }

    /**
     * Installs the search view over the content of `activity` (its `android.R.id.content`, filling it) and opens it
     * (iOS `showSearch(in: UIViewController, animated:)`; was `CYLSearchController.showInViewController`). An
     * activity is the Android host of a whole screen, as a view controller is on iOS.
     */
    @JvmOverloads
    fun showSearch(activity: Activity, animated: Boolean = true) {
        installInView(activity.findViewById(android.R.id.content))
        showSearch(animated)
    }

    /**
     * Installs the search view over `view` (filling it) and opens it: the host for a search inside part of a screen,
     * such as a fragment's root view.
     */
    @JvmOverloads
    fun showSearch(view: ViewGroup, animated: Boolean = true) {
        installInView(view)
        showSearch(animated)
    }

    /**
     * Closes the search view and ends editing; `completion` runs once it is gone, after `searchViewDidClose`, and right
     * away when it is not open (was `CYLSearchController.hide(completion)`).
     */
    @JvmOverloads
    fun closeSearch(animated: Boolean = true, completion: (() -> Unit)? = null) {
        completion?.let { closeCompletions.add(it) }
        if (closing) {
            return
        }
        if (!isSearchOpen) {
            runCloseCompletions()
            return
        }
        isSearchOpen = false
        closing = true
        delegate?.searchViewWillClose(this)
        backCallback.isEnabled = false
        searchBarView.hideKeyboard()
        val finish = {
            visibility = GONE
            alpha = 1f
            pageView.translationY = 0f
            pageView.translationX = 0f
            pageView.alpha = 1f
            closing = false
            hideEmptyView()
            if (clearsQueryOnClose && !searchBarView.text.isNullOrEmpty()) {
                searchBarView.text = ""
                queryChanged("")
            }
            delegate?.searchViewDidClose(this)
            runCloseCompletions()
        }
        animate().cancel()
        if (!animated || animationDuration <= 0) {
            finish()
            return
        }
        val duration = (animationDuration * 1000).toLong()
        pageView.animate().translationY(-12 * density).setDuration(duration).start()
        animate().alpha(0f).setDuration(duration).withEndAction { finish() }.start()
    }

    private fun runCloseCompletions() {
        val completions = closeCompletions.toList()
        closeCompletions.clear()
        completions.forEach { it() }
    }

    /**
     * Makes a toolbar menu item open the search view (`setMenuItem`; iOS `attachToBarButtonItem:`).
     */
    fun attachToMenuItem(item: MenuItem) {
        item.setOnMenuItemClickListener {
            showSearch()
            true
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        (activity() as? ComponentActivity)?.onBackPressedDispatcher?.addCallback(backCallback)
        backCallback.isEnabled = isSearchOpen
        observeHistory()
    }

    override fun onDetachedFromWindow() {
        historyObservation?.invoke()
        historyObservation = null
        backCallback.remove()
        super.onDetachedFromWindow()
    }

    // State restoration

    override fun onSaveInstanceState(): Parcelable = Bundle().apply {
        putParcelable(STATE_SUPER, super.onSaveInstanceState())
        putString(STATE_QUERY, query.orEmpty())
        putBoolean(STATE_OPEN, isSearchOpen)
    }

    @Suppress("DEPRECATION")
    override fun onRestoreInstanceState(state: Parcelable?) {
        if (state !is Bundle) {
            super.onRestoreInstanceState(state)
            return
        }
        super.onRestoreInstanceState(state.getParcelable(STATE_SUPER))
        setQuery(state.getString(STATE_QUERY), false)
        if (state.getBoolean(STATE_OPEN)) {
            post { showSearch(false) }
        }
    }

    override fun dispatchSaveInstanceState(container: SparseArray<Parcelable>) = dispatchFreezeSelfOnly(container)

    override fun dispatchRestoreInstanceState(container: SparseArray<Parcelable>) = dispatchThawSelfOnly(container)

    // Query and suggestions

    /**
     * Sets the query and submits it when `submit` is true (`setQuery`, `setTextQuery`).
     */
    fun setQuery(query: String?, submit: Boolean) {
        searchBarView.text = query
        queryChanged(query.orEmpty())
        if (submit) {
            searchBarView.submit()
        }
    }

    private fun refilter() {
        val query = searchBarView.text.orEmpty()
        val trimmed = query.trim()
        val folded = fold(trimmed)
        val cached = suggestionCache?.cachedQueries().orEmpty()
        // An empty query lists the cached queries, newest first, under the header that clears them.
        showsCachedQueries = trimmed.isEmpty() && cached.isNotEmpty()
        val candidates = if (showsCachedQueries) cached else cached + suggestions.filter { it !in cached }
        filteredSuggestions = candidates.filter { suggestion ->
            when {
                showsCachedQueries -> true
                trimmed.isEmpty() -> showsSuggestionsForEmptyQuery
                suggestionFilter != null -> suggestionFilter!!.invoke(suggestion, query)
                else -> fold(suggestion).contains(folded)
            }
        }
        // With a results data source, a non-blank query lists its results instead of the suggestions.
        val source = resultsDataSource
        resultsVisible = source != null && trimmed.isNotEmpty()
        searchResults = if (source != null && resultsVisible) source.searchViewResultsForQuery(this, query) else emptyList()
        if (resultsVisible) {
            suggestionsVisible = false
            showsCachedQueries = false
            emptyResultsVisible = showsEmptyResultsPlaceholder && searchResults.isEmpty()
            emptySuggestionsVisible = false
        } else {
            suggestionsVisible = filteredSuggestions.isNotEmpty()
            emptyResultsVisible = showsEmptyResultsPlaceholder && trimmed.isNotEmpty() && filteredSuggestions.isEmpty()
            emptySuggestionsVisible = showsEmptySuggestionsPlaceholder && suggestionCache != null && trimmed.isEmpty() && filteredSuggestions.isEmpty()
        }
        // The launch view owns the space under the bar while the query is empty.
        launchVisible = launchView != null && trimmed.isEmpty()
        if (launchVisible) {
            suggestionsVisible = false
            showsCachedQueries = false
            emptyResultsVisible = false
            emptySuggestionsVisible = false
        }
        if (trimmed.isEmpty()) {
            hideEmptyView()
        }
        noResultsText?.let {
            val rows = if (resultsVisible) searchResults.size else filteredSuggestions.size
            if (trimmed.isNotEmpty() && rows == 0) showEmptyView(it) else hideEmptyView()
        }
        updateSuggestionsVisibility()
    }

    /**
     * Lists the suggestions that match the current query (`showSuggestions`).
     */
    fun showSuggestions() = refilter()

    /**
     * Hides the suggestions (`dismissSuggestions`).
     */
    fun dismissSuggestions() {
        suggestionsVisible = false
        // The results of a submitted query stay, with their empty placeholder.
        emptyResultsVisible = emptyResultsVisible && resultsVisible
        emptySuggestionsVisible = false
        showsCachedQueries = false
        updateSuggestionsVisibility()
    }

    private fun updateSuggestionsVisibility() {
        val tags = suggestionStyle == CYLSearchSuggestionStyle.Tags
        suggestionsTableView.visibility = if (suggestionsVisible && !tags) VISIBLE else GONE
        suggestionsTagView.visibility = if (suggestionsVisible && tags) VISIBLE else GONE
        if (tags) {
            suggestionsTagView.setTagsWithTitles(if (suggestionsVisible) filteredSuggestions else emptyList())
        }
        emptyResultsSlot.setShowing(emptyResultsVisible) { CYLPlaceholderStackView(context, emptyResultsScenario) }
        launchView?.visibility = if (launchVisible) VISIBLE else GONE
        emptySuggestionsSlot.setShowing(emptySuggestionsVisible) { CYLPlaceholderStackView(context, emptySuggestionsScenario) }
        suggestionCacheHeaderView.visibility =
            if (suggestionsVisible && showsCachedQueries && showsSuggestionCacheHeader) VISIBLE else GONE
        // The results list sits under the empty results placeholder, so the list (and its pull-to-refresh) stays.
        resultsRefreshLayout.visibility = if (resultsVisible) VISIBLE else GONE
        if (emptyResultsVisible) {
            emptyResultsView?.bringToFront()
        }
        reloadSuggestions()
        reloadResultsTableView()
    }

    @Suppress("NotifyDataSetChanged")
    private fun reloadResultsTableView() = resultsAdapter.notifyDataSetChanged()

    @Suppress("NotifyDataSetChanged")
    private fun reloadSuggestions() = adapter.notifyDataSetChanged()

    private fun rebuildSuggestionCache() {
        suggestionCache = CYLSearchSuggestionStore.cacheWithPolicy(context, suggestionCachePolicy, suggestionCacheName)
    }

    /**
     * Removes every cached query (the delete button of `suggestionCacheHeaderView`) and shows the list again (iOS
     * `clearSuggestionCache`).
     */
    fun clearSuggestionCache() {
        changeHistory { it.removeAllQueries() }
        refilter()
        announceForAccessibility(CYLSearchResources.localizedString(context, "search.recentCleared"))
    }

    private fun queryChanged(text: String) {
        refilter()
        delegate?.searchViewTextDidChange(this, text)
        delegate?.searchViewUpdateResults(this, text)
    }

    private fun select(index: Int) {
        val suggestion = filteredSuggestions.getOrNull(index) ?: return
        searchBarView.text = suggestion
        delegate?.searchViewDidSelectSuggestion(this, suggestion, index)
        // A programmatic text change does not reach the bar's delegate: the results follow the tapped tag either way.
        queryChanged(suggestion)
        if (submitsOnSuggestionSelection) {
            searchBarView.submit()
        }
    }

    private inner class BarDelegate : CYLSearchBarViewDelegate {
        override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) = queryChanged(text)

        override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
            // Every submitted query is cached, so the list shows it the next time.
            val submitted = searchBarView.text.orEmpty().trim()
            if (submitted.isNotEmpty()) {
                changeHistory { it.addQuery(submitted) }
            }
            val handled = delegate?.searchViewDidSubmitText(this@CYLSearchView, searchBarView.text.orEmpty()) ?: false
            if (!handled && closesOnSubmit) closeSearch() else dismissSuggestions()
        }

        override fun searchBarViewNavigationButtonClicked(searchBarView: CYLSearchBarView) {
            delegate?.searchViewNavigationButtonClicked(this@CYLSearchView) ?: closeSearch()
        }

        override fun searchBarViewVoiceButtonClicked(searchBarView: CYLSearchBarView) {
            delegate?.searchViewVoiceButtonClicked(this@CYLSearchView)
        }

        override fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) = closeSearch()

        override fun searchBarViewDidBeginEditing(searchBarView: CYLSearchBarView) {
            delegate?.searchViewDidChangeFocus(this@CYLSearchView, true)
        }

        override fun searchBarViewDidEndEditing(searchBarView: CYLSearchBarView) {
            delegate?.searchViewDidChangeFocus(this@CYLSearchView, false)
        }
    }

    private inner class SuggestionAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount(): Int = if (suggestionsVisible) filteredSuggestions.size else 0

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder =
            object : RecyclerView.ViewHolder(CYLSearchSuggestionCell(parent.context).apply {
                layoutParams = RecyclerView.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
            }) {}

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            val cell = holder.itemView as CYLSearchSuggestionCell
            val suggestion = filteredSuggestions[position]
            cell.textLabel.text = suggestion
            cell.textLabel.setTextColor(suggestionTextColor ?: themeColor(android.R.attr.textColorPrimary))
            val wraps = suggestionLineBreakMode == CYLLineBreakMode.WordWrapping || suggestionLineBreakMode == CYLLineBreakMode.CharWrapping
            cell.textLabel.maxLines = if (wraps) Int.MAX_VALUE else 1
            cell.textLabel.ellipsize = when (suggestionLineBreakMode) {
                CYLLineBreakMode.TruncatingHead -> TextUtils.TruncateAt.START
                CYLLineBreakMode.TruncatingTail -> TextUtils.TruncateAt.END
                CYLLineBreakMode.TruncatingMiddle -> TextUtils.TruncateAt.MIDDLE
                else -> null
            }
            cell.imageView.setImageDrawable(suggestionImage)
            cell.imageView.visibility = if (suggestionImage != null) VISIBLE else GONE
            ImageViewCompat.setImageTintList(
                cell.imageView,
                android.content.res.ColorStateList.valueOf(suggestionImageTintColor ?: themeColor(android.R.attr.textColorSecondary)),
            )
            cell.setBackgroundColor(suggestionBackgroundColor ?: Color.TRANSPARENT)
            cell.setOnClickListener { select(holder.bindingAdapterPosition) }
            suggestionCellConfiguration?.invoke(cell, suggestion, position)
        }
    }

    private inner class ResultsAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount(): Int = if (resultsVisible) searchResults.size else 0

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder =
            object : RecyclerView.ViewHolder(CYLSearchSuggestionCell(parent.context).apply {
                layoutParams = RecyclerView.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
            }) {}

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            val cell = holder.itemView as CYLSearchSuggestionCell
            val result = searchResults[position]
            cell.imageView.visibility = GONE
            cell.textLabel.setTextColor(themeColor(android.R.attr.textColorPrimary))
            resultsDataSource?.searchViewConfigureResultCell(this@CYLSearchView, cell, result)
            if (highlightsResultMatches) {
                val color = resultMatchHighlightColor ?: searchBarView.tintColor ?: themeColor(android.R.attr.colorAccent)
                CYLSearchResultHighlight.apply(cell.textLabel, searchBarView.text.orEmpty(), color)
            }
            cell.setOnClickListener {
                searchResults.getOrNull(holder.bindingAdapterPosition)?.let {
                    delegate?.searchViewDidSelectResult(this@CYLSearchView, it)
                }
            }
        }
    }

    /**
     * The pull-to-refresh around a scroll view (a private helper): CYLTableViewPlaceHolder's `CYLRefreshLayout` with a
     * `CYLRefreshNormalHeader` (its `cyl_header`) while an action is set.
     */
    private class CYLRefreshContainer(context: Context) : CYLRefreshLayout(context) {

        /**
         * Called on each pull and by `beginHeaderRefreshing()`; null removes the header and turns the pull off.
         */
        var refreshAction: (() -> Unit)? = null
            set(value) {
                field = value
                if (value == null) {
                    cyl_header?.endRefreshing()
                    cyl_header = null
                } else if (cyl_header == null) {
                    cyl_header = CYLRefreshNormalHeader(context).apply { refreshingBlock = { refreshAction?.invoke() } }
                }
            }

        /**
         * True when `setRefreshHandler` created this container around a view of the app.
         */
        var wrapsAppView = false

        /**
         * True while the header refreshes (or is about to, before the layout is on screen).
         */
        val isHeaderRefreshing: Boolean
            get() = cyl_header?.isRefreshing == true

        init {
            setEnableRefresh(false)
            setEnableLoadMore(false)
        }

        /**
         * Starts the header's refresh, like a pull; the header then calls the action.
         */
        fun beginHeaderRefreshing() {
            val header = cyl_header ?: return
            if (!header.isRefreshing) {
                header.beginRefreshing()
            }
        }

        /**
         * Ends the header's refresh.
         */
        fun endHeaderRefreshing() {
            cyl_header?.endRefreshing()
        }
    }

    /**
     * The refresh API for any scroll view of the app (iOS `static` methods), and private constants.
     */
    companion object {
        private const val STATE_SUPER = "CYLSearchViewSuper"
        private const val SWIPE_TRAVEL = 0.3f

        /**
         * CYLTableViewPlaceHolder's "no results" placeholder with a title, an optional detail and an optional button: the
         * view of `showEmptyView`, also used by `CYLSearchListView`.
         */
        @JvmStatic
        @JvmOverloads
        fun emptyPlaceholder(context: Context, text: String?, detailText: String? = null, buttonTitle: String? = null, buttonAction: (() -> Unit)? = null): CYLPlaceholderStackView {
            val components = mutableListOf(
                CYLPlaceholderComponent.componentWithBundledAnimation("CYLPlaceholderNoResults.json", CYLPlaceholderStyle.NoResults, text),
            )
            if (!detailText.isNullOrEmpty()) {
                components.add(CYLPlaceholderComponent.hintComponentWithText(detailText))
            }
            val actions = mutableMapOf<String, CYLPlaceholderActionHandler>()
            if (!buttonTitle.isNullOrEmpty()) {
                components.add(CYLPlaceholderComponent.buttonComponentWithTitle(buttonTitle, CYLPlaceholderButtonStyle.Outlined, CYLPlaceholderAction.Retry))
                actions[CYLPlaceholderAction.Retry] = { buttonAction?.invoke() }
            }
            return CYLPlaceholderStackView(context, components, actions)
        }
        private const val STATE_QUERY = "CYLSearchViewQuery"
        private const val STATE_OPEN = "CYLSearchViewOpen"

        private fun fold(text: String): String = CYLSearchResultHighlight.fold(text)

        /**
         * Adds pull-to-refresh to `scrollView` (a `RecyclerView`, `ScrollView`, `ListView` or `NestedScrollView` that
         * already has a parent), calling `handler` on each pull; null removes it. The view moves into a
         * CYLTableViewPlaceHolder `CYLRefreshLayout` (with a `CYLRefreshNormalHeader`) that takes its place and layout
         * parameters in its parent.
         */
        @JvmStatic
        fun setRefreshHandler(handler: (() -> Unit)?, scrollView: View) {
            val existing = scrollView.parent as? CYLRefreshContainer
            if (handler == null) {
                existing ?: return
                existing.refreshAction = null
                val host = existing.parent as? ViewGroup
                if (existing.wrapsAppView && host != null) {
                    val index = host.indexOfChild(existing)
                    val params = existing.layoutParams
                    existing.removeView(scrollView)
                    host.removeView(existing)
                    host.addView(scrollView, index, params)
                }
                return
            }
            if (existing != null) {
                existing.refreshAction = handler
                return
            }
            val host = scrollView.parent as? ViewGroup ?: return
            val index = host.indexOfChild(scrollView)
            val params = scrollView.layoutParams
            val container = CYLRefreshContainer(scrollView.context)
            container.wrapsAppView = true
            container.id = View.generateViewId()
            host.removeView(scrollView)
            container.setRefreshContent(scrollView)
            host.addView(container, index, params)
            container.refreshAction = handler
        }

        /**
         * Shows the refresh indicator of `scrollView` and calls its handler, like a pull.
         */
        @JvmStatic
        fun beginRefreshing(scrollView: View) {
            (scrollView.parent as? CYLRefreshContainer)?.beginHeaderRefreshing()
        }

        /**
         * Hides the refresh indicator of `scrollView`.
         */
        @JvmStatic
        fun endRefreshing(scrollView: View) {
            (scrollView.parent as? CYLRefreshContainer)?.endHeaderRefreshing()
        }

        /**
         * True while `scrollView` shows its refresh indicator.
         */
        @JvmStatic
        fun isRefreshing(scrollView: View): Boolean = (scrollView.parent as? CYLRefreshContainer)?.isHeaderRefreshing == true
    }
}
