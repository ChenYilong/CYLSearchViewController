package com.cylsearch

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.CylsearchViewManagerDelegate
import com.facebook.react.viewmanagers.CylsearchViewManagerInterface

/**
 * The search page (`CylsearchView` in JavaScript).
 */
@ReactModule(name = CylsearchViewManager.NAME)
class CylsearchViewManager : SimpleViewManager<CylsearchView>(), CylsearchViewManagerInterface<CylsearchView> {
  private val delegate = CylsearchViewManagerDelegate(this)
  private val cachePolicies = HashMap<Int, Pair<String?, String?>>()

  override fun getDelegate(): ViewManagerDelegate<CylsearchView> = delegate
  override fun getName() = NAME
  override fun createViewInstance(context: ThemedReactContext) = CylsearchView(context)

  @ReactProp(name = "suggestions")
  override fun setSuggestions(view: CylsearchView, value: ReadableArray?) {
    view.searchView.suggestions = value.cylStrings()
  }

  @ReactProp(name = "suggestionStyle")
  override fun setSuggestionStyle(view: CylsearchView, value: String?) = view.setStyle(value)

  @ReactProp(name = "placeholder")
  override fun setPlaceholder(view: CylsearchView, value: String?) {
    view.searchView.searchBarView.placeholder = value
  }

  @ReactProp(name = "query")
  override fun setQuery(view: CylsearchView, value: String?) {
    value?.takeIf { it.isNotEmpty() && it != view.searchView.query }?.let { view.searchView.query = it }
  }

  @ReactProp(name = "showsSuggestionsForEmptyQuery")
  override fun setShowsSuggestionsForEmptyQuery(view: CylsearchView, value: Boolean) {
    view.searchView.showsSuggestionsForEmptyQuery = value
  }

  @ReactProp(name = "submitsOnSuggestionSelection")
  override fun setSubmitsOnSuggestionSelection(view: CylsearchView, value: Boolean) {
    view.searchView.submitsOnSuggestionSelection = value
  }

  @ReactProp(name = "showsEmptyResultsPlaceholder")
  override fun setShowsEmptyResultsPlaceholder(view: CylsearchView, value: Boolean) {
    view.searchView.showsEmptyResultsPlaceholder = value
  }

  @ReactProp(name = "emptyResultsScenario")
  override fun setEmptyResultsScenario(view: CylsearchView, value: String?) = view.setScenario(value)

  @ReactProp(name = "suggestionCachePolicy")
  override fun setSuggestionCachePolicy(view: CylsearchView, value: String?) {
    val current = cachePolicies[view.id]
    cachePolicies[view.id] = value to current?.second
    view.setCachePolicy(value, current?.second)
  }

  @ReactProp(name = "suggestionCacheName")
  override fun setSuggestionCacheName(view: CylsearchView, value: String?) {
    val current = cachePolicies[view.id]
    cachePolicies[view.id] = current?.first to value
    view.setCachePolicy(current?.first, value)
  }

  @ReactProp(name = "focusesSearchFieldOnShow", defaultBoolean = true)
  override fun setFocusesSearchFieldOnShow(view: CylsearchView, value: Boolean) {
    view.searchView.focusesSearchFieldOnShow = value
  }

  @ReactProp(name = "suggestionsFoldControlPosition")
  override fun setSuggestionsFoldControlPosition(view: CylsearchView, value: String?) {
    view.searchView.suggestionsFoldControl = cylFoldControl(value, view.foldContent)
    view.foldPosition = value
  }

  @ReactProp(name = "suggestionsFoldControlContent")
  override fun setSuggestionsFoldControlContent(view: CylsearchView, value: String?) {
    view.searchView.suggestionsFoldControl = cylFoldControl(view.foldPosition, value)
    view.foldContent = value
  }

  @ReactProp(name = "suggestionsFoldedRowCount", defaultInt = 2)
  override fun setSuggestionsFoldedRowCount(view: CylsearchView, value: Int) {
    view.searchView.suggestionsFoldedRowCount = maxOf(0, value)
  }

  /**
   * The views use the activity's theme (DayNight), which follows the system like React Native's color scheme.
   */
  @ReactProp(name = "colorScheme")
  override fun setColorScheme(view: CylsearchView, value: String?) = Unit

  override fun onDropViewInstance(view: CylsearchView) {
    cachePolicies.remove(view.id)
    super.onDropViewInstance(view)
  }

  companion object {
    const val NAME = "CylsearchView"
  }
}
