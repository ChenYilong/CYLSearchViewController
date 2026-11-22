package com.cylsearch

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.CylsearchListViewManagerDelegate
import com.facebook.react.viewmanagers.CylsearchListViewManagerInterface

/**
 * The list with a search bar and its search (`CylsearchListView` in JavaScript): the core's `CYLSearchListView` and
 * `CYLSearchView`.
 */
@ReactModule(name = CylsearchListViewManager.NAME)
class CylsearchListViewManager : SimpleViewManager<CylsearchListView>(), CylsearchListViewManagerInterface<CylsearchListView> {
  private val delegate = CylsearchListViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<CylsearchListView> = delegate
  override fun getName() = NAME
  override fun createViewInstance(context: ThemedReactContext) = CylsearchListView(context)

  @ReactProp(name = "rows")
  override fun setRows(view: CylsearchListView, value: ReadableArray?) { view.rows = value.cylStrings() }

  @ReactProp(name = "placeholder")
  override fun setPlaceholder(view: CylsearchListView, value: String?) { view.placeholder = value }

  @ReactProp(name = "centersPlaceholder")
  override fun setCentersPlaceholder(view: CylsearchListView, value: Boolean) {
    view.list.searchBarView.centersPlaceholder = value
    view.searchView.searchBarView.centersPlaceholder = value
  }

  @ReactProp(name = "showsSearchBar", defaultBoolean = true)
  override fun setShowsSearchBar(view: CylsearchListView, value: Boolean) { view.list.showsSearchBar = value }

  @ReactProp(name = "hidesSearchBarInitially")
  override fun setHidesSearchBarInitially(view: CylsearchListView, value: Boolean) { view.list.hidesSearchBarInitially = value }

  @ReactProp(name = "hidesSearchBarWhenEmptyViewShowing")
  override fun setHidesSearchBarWhenEmptyViewShowing(view: CylsearchListView, value: Boolean) { view.list.hidesSearchBarWhenEmptyViewShowing = value }

  @ReactProp(name = "snapsHeaderSearchBar", defaultBoolean = true)
  override fun setSnapsHeaderSearchBar(view: CylsearchListView, value: Boolean) { view.list.snapsHeaderSearchBar = value }

  @ReactProp(name = "results")
  override fun setResults(view: CylsearchListView, value: ReadableArray?) { view.results = value.cylStrings() }

  @ReactProp(name = "resultsQuery")
  override fun setResultsQuery(view: CylsearchListView, value: String?) { view.resultsQuery = value.orEmpty() }

  @ReactProp(name = "noResultsText")
  override fun setNoResultsText(view: CylsearchListView, value: String?) { view.noResultsText = value.orEmpty() }

  @ReactProp(name = "suggestions")
  override fun setSuggestions(view: CylsearchListView, value: ReadableArray?) { view.suggestions = value.cylStrings() }

  @ReactProp(name = "submitsOnSuggestionSelection", defaultBoolean = true)
  override fun setSubmitsOnSuggestionSelection(view: CylsearchListView, value: Boolean) { view.searchView.submitsOnSuggestionSelection = value }

  @ReactProp(name = "suggestionCachePolicy")
  override fun setSuggestionCachePolicy(view: CylsearchListView, value: String?) { view.suggestionCachePolicy = value }

  @ReactProp(name = "suggestionCacheName")
  override fun setSuggestionCacheName(view: CylsearchListView, value: String?) { view.suggestionCacheName = value }

  @ReactProp(name = "scrimColor")
  override fun setScrimColor(view: CylsearchListView, value: String?) { view.scrimColor = value }

  @ReactProp(name = "highlightsResultMatches")
  override fun setHighlightsResultMatches(view: CylsearchListView, value: Boolean) { view.searchView.highlightsResultMatches = value }

  @ReactProp(name = "resultMatchHighlightColor")
  override fun setResultMatchHighlightColor(view: CylsearchListView, value: String?) { view.searchView.resultMatchHighlightColor = cylParseColor(value) }

  @ReactProp(name = "supportsSwipeToDismissSearch")
  override fun setSupportsSwipeToDismissSearch(view: CylsearchListView, value: Boolean) { view.searchView.supportsSwipeToDismissSearch = value }

  /** The views use the activity's theme (DayNight), which follows the system like React Native's color scheme. */
  @ReactProp(name = "colorScheme")
  override fun setColorScheme(view: CylsearchListView, value: String?) = Unit

  override fun onAfterUpdateTransaction(view: CylsearchListView) {
    super.onAfterUpdateTransaction(view)
    view.applyProps()
  }

  override fun setActive(view: CylsearchListView, active: Boolean, animated: Boolean) {
    view.searchView.setActive(active, animated)
  }

  override fun clearHistory(view: CylsearchListView) {
    view.searchView.clearSuggestionCache()
  }

  companion object {
    const val NAME = "CylsearchListView"
  }
}
