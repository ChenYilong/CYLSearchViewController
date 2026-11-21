package com.cylsearch

import android.graphics.Color
import android.graphics.Typeface
import android.text.SpannableString
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.util.TypedValue
import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.cyl.search.CYLSearchBarAppearance
import com.cyl.search.CYLSearchBarNavigationIcon
import com.cyl.search.CYLSearchListView
import com.cyl.search.CYLSearchResources
import com.cyl.search.CYLSearchSuggestionCachePolicy
import com.cyl.search.CYLSearchSuggestionCell
import com.cyl.search.CYLSearchView
import com.cyl.search.CYLSearchViewDataSource
import com.cyl.search.CYLSearchViewDelegate
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper

/**
 * The core's `CYLSearchListView` (iOS `CYLSearchTableViewController`: a list whose first item is the search bar) with its
 * `CYLSearchView` as the search: the rows, the results of the current text (`results` and `resultsQuery`, drawn with the
 * match in the tint color), the launch view, the dimming, the history, the empty view and the presentation events. React
 * Native owns the data; the core owns the bar, the page, the scrolling and the snapping.
 */
class CylsearchListView(private val reactContext: ThemedReactContext) :
  FrameLayout(reactContext), CYLSearchViewDelegate, CYLSearchViewDataSource {

  val list = CYLSearchListView(reactContext)
  val searchView: CYLSearchView get() = list.searchView
  private val launchView = CylsearchLaunchView(reactContext)
  private val tint = CYLSearchBarAppearance.defaultAppearance(reactContext).tintColor ?: Color.rgb(0, 104, 248)

  var rows: List<String> = emptyList()
    set(value) {
      field = value
      adapter.notifyDataSetChanged()
    }
  var results: List<String> = emptyList()
  var resultsQuery: String = ""
  var emptyViewText: String = ""
  var launchTitle: String = ""
  var historyPolicy: String? = null
  var historyName: String? = null
  private var appliedHistory: Pair<String?, String?>? = null

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
      resultsDataSource = this@CylsearchListView
      // The bar of the page is Cancel-style, as a UISearchBar that is active.
      searchBarView.navigationIcon = CYLSearchBarNavigationIcon.None
      searchBarView.showsCancelButton = true
      searchBarView.applyDefaultAppearance()
      clearsQueryOnClose = true
      closesOnSubmit = false
      showsSuggestionCacheHeader = false
      launchView = this@CylsearchListView.launchView
    }
    launchView.onClear = { emit("topHistoryChange", "query" to "") }
    searchView.addHistoryDidChangeListener {
      launchView.reload()
      emit("topHistoryChange", "query" to searchView.suggestionCache?.cachedQueries()?.firstOrNull().orEmpty())
    }
    addView(list, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
  }

  /** Applies the props that depend on each other, once per update (the manager's onAfterUpdateTransaction). */
  fun applyProps(placeholder: String?, launchSuggestions: List<String>, launchLabel: String, clearLabel: String, dimming: String?) {
    if (!placeholder.isNullOrEmpty()) {
      searchView.searchBarView.placeholder = placeholder
      list.searchBarView.placeholder = placeholder
    }
    launchView.titleLabel.text = launchTitle
    launchView.contentDescription = launchLabel
    launchView.tagListView.contentDescription = launchLabel
    launchView.clearButton.contentDescription = clearLabel.ifEmpty { CYLSearchResources.localizedString(context, "search.clearRecent") }
    val history = historyPolicy to historyName
    if (history != appliedHistory) {
      appliedHistory = history
      searchView.suggestionCachePolicy = when (historyPolicy) {
        "userDefaults" -> CYLSearchSuggestionCachePolicy.UserDefaults
        "database" -> CYLSearchSuggestionCachePolicy.Database
        "sandboxFile" -> CYLSearchSuggestionCachePolicy.SandboxFile
        else -> CYLSearchSuggestionCachePolicy.None
      }
      searchView.suggestionCacheName = historyName?.takeIf { it.isNotEmpty() } ?: "CylsearchListView"
      launchView.historyStore = searchView.suggestionCache
    }
    launchView.suggestions = launchSuggestions
    searchView.launchView = if (launchTitle.isEmpty()) null else launchView
    searchView.dimmingColor = dimming?.takeIf { it.isNotEmpty() }?.let { runCatching { Color.parseColor(it) }.getOrNull() }
    searchView.reloadResults()
    updateEmptyView()
  }

  /** The empty view for a text whose results are known to be empty (QDSearchViewController's updateResults). */
  private fun updateEmptyView() {
    val query = searchView.query.orEmpty()
    if (emptyViewText.isNotEmpty() && query.isNotEmpty() && resultsQuery == query && results.isEmpty()) {
      searchView.showEmptyView(emptyViewText)
    } else {
      searchView.hideEmptyView()
    }
  }

  /** The text changed (also ""): JavaScript answers with results of that text. */
  override fun searchViewUpdateResults(searchView: CYLSearchView, searchString: String) {
    emit("topUpdateResults", "text" to searchString)
    updateEmptyView()
  }

  override fun searchViewWillShow(searchView: CYLSearchView) = emit("topWillPresent")
  override fun searchViewDidShow(searchView: CYLSearchView) = emit("topDidPresent")
  override fun searchViewWillClose(searchView: CYLSearchView) = emit("topWillDismiss")
  override fun searchViewDidClose(searchView: CYLSearchView) = emit("topDidDismiss")

  override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean = true

  // Results of another text are not shown: a late answer never fills the list of a newer text.
  override fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any> =
    if (query == resultsQuery) results else emptyList()

  override fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any) {
    val keyword = result.toString()
    val text = SpannableString(keyword)
    val query = searchView.query.orEmpty()
    val start = if (query.isEmpty()) -1 else keyword.indexOf(query)
    if (start >= 0) text.setSpan(ForegroundColorSpan(tint), start, start + query.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
    cell.textLabel.text = text
    cell.textLabel.setTypeface(null, Typeface.NORMAL)
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
