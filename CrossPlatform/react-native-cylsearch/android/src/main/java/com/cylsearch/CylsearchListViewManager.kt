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

  private class Pending {
    var placeholder: String? = null
    var suggestions: List<String> = emptyList()
    var launchLabel = ""
    var clearLabel = ""
    var dimming: String? = null
  }

  private val pending = HashMap<Int, Pending>()
  private fun pending(view: CylsearchListView) = pending.getOrPut(view.id) { Pending() }

  override fun getDelegate(): ViewManagerDelegate<CylsearchListView> = delegate
  override fun getName() = NAME
  override fun createViewInstance(context: ThemedReactContext) = CylsearchListView(context)

  @ReactProp(name = "rows")
  override fun setRows(view: CylsearchListView, value: ReadableArray?) { view.rows = value.cylStrings() }

  @ReactProp(name = "placeholder")
  override fun setPlaceholder(view: CylsearchListView, value: String?) { pending(view).placeholder = value }

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

  @ReactProp(name = "emptyViewText")
  override fun setEmptyViewText(view: CylsearchListView, value: String?) { view.emptyViewText = value.orEmpty() }

  @ReactProp(name = "launchTitle")
  override fun setLaunchTitle(view: CylsearchListView, value: String?) { view.launchTitle = value.orEmpty() }

  @ReactProp(name = "launchSuggestions")
  override fun setLaunchSuggestions(view: CylsearchListView, value: ReadableArray?) { pending(view).suggestions = value.cylStrings() }

  @ReactProp(name = "launchLabel")
  override fun setLaunchLabel(view: CylsearchListView, value: String?) { pending(view).launchLabel = value.orEmpty() }

  @ReactProp(name = "clearHistoryLabel")
  override fun setClearHistoryLabel(view: CylsearchListView, value: String?) { pending(view).clearLabel = value.orEmpty() }

  @ReactProp(name = "historyPolicy")
  override fun setHistoryPolicy(view: CylsearchListView, value: String?) { view.historyPolicy = value }

  @ReactProp(name = "historyName")
  override fun setHistoryName(view: CylsearchListView, value: String?) { view.historyName = value }

  @ReactProp(name = "dimmingColor")
  override fun setDimmingColor(view: CylsearchListView, value: String?) { pending(view).dimming = value }

  @ReactProp(name = "supportsSwipeToDismissSearch")
  override fun setSupportsSwipeToDismissSearch(view: CylsearchListView, value: Boolean) { view.searchView.supportsSwipeToDismissSearch = value }

  /** The views use the activity's theme (DayNight), which follows the system like React Native's color scheme. */
  @ReactProp(name = "colorScheme")
  override fun setColorScheme(view: CylsearchListView, value: String?) = Unit

  override fun onAfterUpdateTransaction(view: CylsearchListView) {
    super.onAfterUpdateTransaction(view)
    val p = pending(view)
    view.applyProps(p.placeholder, p.suggestions, p.launchLabel, p.clearLabel, p.dimming)
  }

  override fun setActive(view: CylsearchListView, active: Boolean, animated: Boolean) {
    view.searchView.setActive(active, animated)
  }

  override fun clearHistory(view: CylsearchListView) {
    view.searchView.clearSuggestionCache()
  }

  override fun onDropViewInstance(view: CylsearchListView) {
    pending.remove(view.id)
    super.onDropViewInstance(view)
  }

  companion object {
    const val NAME = "CylsearchListView"
  }
}
