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
 * CYLSearchView of the `cylsearch` module, open from the start: JavaScript leaves the screen in `onClose`.
 */
class CylsearchView(private val reactContext: ThemedReactContext) : FrameLayout(reactContext), CYLSearchViewDelegate {

  val searchView = CYLSearchView(reactContext)

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
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    if (!searchView.isSearchOpen) searchView.showSearch(false)
  }

  fun setCachePolicy(policyName: String?, name: String?) {
    val policy = when (policyName) {
      "none" -> CYLSearchSuggestionCachePolicy.None
      "userDefaults" -> CYLSearchSuggestionCachePolicy.UserDefaults
      "sandboxFile" -> CYLSearchSuggestionCachePolicy.SandboxFile
      else -> CYLSearchSuggestionCachePolicy.Database
    }
    val cacheName = name?.takeIf { it.isNotEmpty() } ?: "CYLSearchView"
    if (policy != searchView.suggestionCachePolicy || cacheName != searchView.suggestionCacheName) {
      searchView.suggestionCacheName = cacheName
      searchView.suggestionCachePolicy = policy
    }
  }

  fun setStyle(value: String?) {
    searchView.suggestionStyle = if (value == "tags") CYLSearchSuggestionStyle.Tags else CYLSearchSuggestionStyle.List
  }

  fun setScenario(value: String?) {
    searchView.emptyResultsScenario = if (value == "noContent") CYLPlaceholderScenario.NoContent else CYLPlaceholderScenario.NoSearchResults
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

  override fun searchViewDidClose(searchView: CYLSearchView) = emit("topClose")
}
