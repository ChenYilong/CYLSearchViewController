package com.cylsearch

import android.widget.FrameLayout
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.search.CYLSearchSuggestionCachePolicy
import com.cyl.search.CYLSearchSuggestionStyle
import com.cyl.search.CYLSearchView
import com.cyl.search.CYLSearchViewDelegate
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper

/**
 * CYLSearchView of the `cylsearch` module, open from the start: JavaScript leaves the screen in `onClose`. It is the
 * core's `resultsDataSource` (the `results` prop) and owns its `refreshHandler` (`onRefresh`).
 */
class CylsearchView(private val reactContext: ThemedReactContext) : FrameLayout(reactContext), CYLSearchViewDelegate {

  val searchView = CYLSearchView(reactContext)
  // The one results data source of both components; JavaScript filters, so the results belong to every text.
  private val source = CylsearchResults()

  /**
   * The fold control's last position and content names, combined into one control.
   */
  var foldPosition: String? = null
  var foldContent: String? = null

  init {
    searchView.delegate = this
    // The page stays open after a submit: JavaScript decides what a submitted query does.
    searchView.closesOnSubmit = false
    searchView.installInView(this)
    cylKeepSystemBarsAbove(this)
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    if (!searchView.isSearchOpen) searchView.showSearch(false)
  }

  fun setCachePolicy(policyName: String?, name: String?) =
    searchView.applySuggestionCache(policyName, name, "CYLSearchView", CYLSearchSuggestionCachePolicy.Database)

  fun setStyle(value: String?) {
    searchView.suggestionStyle = if (value == "tags") CYLSearchSuggestionStyle.Tags else CYLSearchSuggestionStyle.List
  }

  fun setScenario(value: String?) {
    searchView.emptyResultsScenario = if (value == "noContent") CYLPlaceholderScenario.NoContent else CYLPlaceholderScenario.NoSearchResults
  }

  private var resultsShown = false
  private var refreshAllowed = false
  private var refreshRequested = false
  private var refreshFromProps = false

  /**
   * The `results` prop: reloads the results list when JavaScript sends other results.
   */
  fun setResults(value: List<String>) {
    if (value == source.results) return
    source.results = value
    if (resultsShown) searchView.reloadResults()
  }

  /**
   * The `showsResults` prop: the view is the core's data source while results are shown.
   */
  fun setShowsResults(value: Boolean) {
    if (value == resultsShown) return
    resultsShown = value
    // Setting the data source queries it again.
    searchView.resultsDataSource = if (value) source else null
  }

  /**
   * The `refreshEnabled` prop: the core's `refreshHandler`.
   */
  fun setRefreshEnabled(value: Boolean) {
    if (value == refreshAllowed) return
    refreshAllowed = value
    if (value) {
      searchView.refreshHandler = { refreshStarted() }
      if (refreshRequested && !searchView.isRefreshing) beginRefreshingFromProps()
    } else {
      searchView.endRefreshing()
      searchView.refreshHandler = null
    }
  }

  /**
   * The `refreshing` prop: `beginRefreshing` when it turns true, `endRefreshing` when it turns false.
   */
  fun setRefreshing(value: Boolean) {
    if (value == refreshRequested) return
    refreshRequested = value
    if (value && refreshAllowed && !searchView.isRefreshing) {
      beginRefreshingFromProps()
    } else if (!value && searchView.isRefreshing) {
      searchView.endRefreshing()
    }
  }

  private fun beginRefreshingFromProps() {
    // Started by JavaScript: the handler does not send `onRefresh` back.
    refreshFromProps = true
    searchView.beginRefreshing()
  }

  private fun refreshStarted() {
    if (refreshFromProps) {
      refreshFromProps = false
      return
    }
    emit("topRefresh")
  }

  override fun searchViewDidSelectResult(searchView: CYLSearchView, result: Any) {
    val text = result as? String ?: return
    emit("topSelectResult", "result" to text, "index" to searchView.searchResults.indexOf(result))
  }

  /**
   * A native view laid out by React Native: measure and lay it out again when its content changes.
   */
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

  override fun searchViewTextDidChange(searchView: CYLSearchView, text: String) = emit("topTextChange", "text" to text)

  override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean {
    emit("topSubmit", "text" to text)
    return true
  }

  override fun searchViewDidSelectSuggestion(searchView: CYLSearchView, suggestion: String, index: Int) =
    emit("topSuggestionSelect", "suggestion" to suggestion, "index" to index)

  override fun searchViewDidShow(searchView: CYLSearchView) {
    // The core fills its tag list while the page is hidden and has no width yet: fill it again now that the page is laid out.
    post { searchView.reloadResults() }
  }

  override fun searchViewDidClose(searchView: CYLSearchView) = emit("topClose")
}
