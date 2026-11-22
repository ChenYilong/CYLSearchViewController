package com.cylsearch

import android.util.TypedValue
import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.cyl.search.CYLSearchBarNavigationIcon
import com.cyl.search.CYLSearchListView
import com.cyl.search.CYLSearchSuggestionCachePolicy
import com.cyl.search.CYLSearchView
import com.cyl.search.CYLSearchViewDelegate
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper

/**
 * The core's `CYLSearchListView` (iOS `CYLSearchTableViewController`: a list whose first item is the search bar) with its
 * `CYLSearchView` as the search. The page is the core's own: its suggestion area is the launch area (the history, else
 * `suggestions`, as folded tags, with the title and the clear button), `scrimColor` the dimming, `noResultsText` the
 * empty view, `highlightsResultMatches` the highlight. React Native owns the data; the core owns the bar, the page, the
 * scrolling and the snapping. The results come from the one data source both components use (`CylsearchResults`).
 */
class CylsearchListView(private val reactContext: ThemedReactContext) : FrameLayout(reactContext), CYLSearchViewDelegate {

  val list = CYLSearchListView(reactContext)
  val searchView: CYLSearchView get() = list.searchView
  private val source = CylsearchResults()

  var rows: List<String> = emptyList()
    set(value) {
      field = value
      adapter.notifyDataSetChanged()
    }
  var results: List<String>
    get() = source.results
    set(value) {
      source.results = value
    }
  var resultsQuery: String
    get() = source.resultsQuery.orEmpty()
    set(value) {
      source.resultsQuery = value
    }
  var noResultsText: String = ""
  var suggestions: List<String> = emptyList()
  var suggestionCachePolicy: String? = null
  var suggestionCacheName: String? = null
  var scrimColor: String? = null
  var placeholder: String? = null

  private val adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    override fun getItemCount() = rows.size

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
      val density = parent.resources.displayMetrics.density
      val text = TextView(parent.context).apply {
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
        gravity = Gravity.CENTER_VERTICAL
        minHeight = (56 * density).toInt()
        setPadding((16 * density).toInt(), 0, (16 * density).toInt(), 0)
        layoutParams = RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, RecyclerView.LayoutParams.WRAP_CONTENT)
      }
      return object : RecyclerView.ViewHolder(text) {}
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
      val text = holder.itemView as TextView
      text.text = rows[position]
      text.setOnClickListener { emit("topSelectRow", "row" to rows[position], "index" to position) }
    }
  }

  init {
    list.adapter = adapter
    searchView.apply {
      delegate = this@CylsearchListView
      resultsDataSource = source
      // The bar of the page is Cancel-style, as a UISearchBar that is active.
      searchBarView.navigationIcon = CYLSearchBarNavigationIcon.None
      searchBarView.showsCancelButton = true
      searchBarView.applyDefaultAppearance()
      clearsQueryOnClose = true
      closesOnSubmit = false
      // A tapped tag submits, as the return key does.
      submitsOnSuggestionSelection = true
      showsEmptySuggestionsPlaceholder = false
    }
    searchView.addHistoryDidChangeListener {
      emit("topHistoryChange", "query" to searchView.suggestionCache?.cachedQueries()?.firstOrNull().orEmpty())
    }
    addView(list, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
  }

  /** Applies the props that depend on each other, once per update (the manager's onAfterUpdateTransaction). */
  fun applyProps() {
    if (!placeholder.isNullOrEmpty()) {
      searchView.searchBarView.placeholder = placeholder
      list.searchBarView.placeholder = placeholder
    }
    searchView.applySuggestionCache(suggestionCachePolicy, suggestionCacheName, "CylsearchListView", CYLSearchSuggestionCachePolicy.None)
    searchView.suggestions = suggestions
    // The launch area shows while the text is empty when there is something to launch with: the history or the suggestions.
    searchView.showsSuggestionsForEmptyQuery = suggestions.isNotEmpty() || searchView.suggestionCachePolicy != CYLSearchSuggestionCachePolicy.None
    searchView.scrimColor = cylParseColor(scrimColor)
    searchView.noResultsText = noResultsText.takeIf { it.isNotEmpty() }
    searchView.reloadResults()
  }

  /** The text changed (also ""): JavaScript answers with results of that text. */
  override fun searchViewUpdateResults(searchView: CYLSearchView, searchString: String) {
    emit("topUpdateResults", "text" to searchString)
  }

  override fun searchViewWillShow(searchView: CYLSearchView) = emit("topWillPresent")
  override fun searchViewDidShow(searchView: CYLSearchView) = emit("topDidPresent")
  override fun searchViewWillClose(searchView: CYLSearchView) = emit("topWillDismiss")
  override fun searchViewDidClose(searchView: CYLSearchView) = emit("topDidDismiss")

  override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean {
    emit("topSubmit", "text" to text)
    return true
  }

  override fun searchViewDidSelectResult(searchView: CYLSearchView, result: Any) {
    emit("topSelectResult", "result" to result.toString(), "index" to searchView.searchResults.indexOf(result))
  }

  override fun requestLayout() {
    super.requestLayout()
    post(measureAndLayout)
  }

  private val measureAndLayout = Runnable {
    measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
    layout(left, top, right, bottom)
  }

  private fun emit(name: String, vararg pairs: Pair<String, Any>) {
    UIManagerHelper.getEventDispatcher(reactContext)?.dispatchEvent(
      CylsearchEvent(UIManagerHelper.getSurfaceId(this), id, name, cylEventData(*pairs)))
  }
}
