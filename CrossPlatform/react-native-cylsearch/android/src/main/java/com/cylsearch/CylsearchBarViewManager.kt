package com.cylsearch

import androidx.core.content.ContextCompat
import com.cyl.search.CYLSearchBarSearchButtonStyle
import com.cyl.search.CYLSearchBarStyle
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.CylsearchBarViewManagerDelegate
import com.facebook.react.viewmanagers.CylsearchBarViewManagerInterface

/**
 * The search bar (`CylsearchBarView` in JavaScript).
 */
@ReactModule(name = CylsearchBarViewManager.NAME)
class CylsearchBarViewManager : SimpleViewManager<CylsearchBarView>(), CylsearchBarViewManagerInterface<CylsearchBarView> {
  private val delegate = CylsearchBarViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<CylsearchBarView> = delegate
  override fun getName() = NAME
  override fun createViewInstance(context: ThemedReactContext) = CylsearchBarView(context)

  @ReactProp(name = "placeholder")
  override fun setPlaceholder(view: CylsearchBarView, value: String?) {
    view.bar.placeholder = value
    view.placeholderProp = value
  }

  @ReactProp(name = "text")
  override fun setText(view: CylsearchBarView, value: String?) {
    value?.takeIf { it.isNotEmpty() && it != view.bar.text }?.let {
      view.bar.text = it
      // An editing bar given a text is renaming: the keyboard rises with the title selected (iOS beginRenaming).
      if (view.bar.isEditingBar) {
        view.bar.showKeyboard()
        view.bar.textField.selectAll()
      }
    }
  }

  @ReactProp(name = "showsCancelButton")
  override fun setShowsCancelButton(view: CylsearchBarView, value: Boolean) {
    view.showsCancel = value
  }

  @ReactProp(name = "fieldShadowOpacity")
  override fun setFieldShadowOpacity(view: CylsearchBarView, value: Double) {
    view.bar.fieldShadowOpacity = value.toFloat()
  }

  @ReactProp(name = "searchBarStyle")
  override fun setSearchBarStyle(view: CylsearchBarView, value: String?) {
    view.bar.searchBarStyle = if (value == "bordered") CYLSearchBarStyle.Bordered else CYLSearchBarStyle.Plain
  }

  @ReactProp(name = "navigationFieldStyle", defaultBoolean = false)
  override fun setNavigationFieldStyle(view: CylsearchBarView, value: Boolean) { view.navigationFieldStyle = value }

  // The core's default search button (iOS and Android `showsSearchButton`, `searchButtonStyle`, `searchButtonTitle`, `searchButtonHandler`).
  @ReactProp(name = "showsSearchButton", defaultBoolean = true)
  override fun setShowsSearchButton(view: CylsearchBarView, value: Boolean) { view.bar.showsSearchButton = value }

  @ReactProp(name = "searchButtonStyle")
  override fun setSearchButtonStyle(view: CylsearchBarView, value: String?) {
    view.bar.searchButtonStyle = if (value == "text") CYLSearchBarSearchButtonStyle.Text else CYLSearchBarSearchButtonStyle.Icon
  }

  @ReactProp(name = "searchButtonTitle")
  override fun setSearchButtonTitle(view: CylsearchBarView, value: String?) { view.bar.searchButtonTitle = value?.takeIf { it.isNotEmpty() } }

  @ReactProp(name = "hasSearchButtonHandler", defaultBoolean = false)
  override fun setHasSearchButtonHandler(view: CylsearchBarView, value: Boolean) {
    view.bar.searchButtonHandler = if (value) ({ bar -> view.sendSearchButtonTap(bar.text.orEmpty()) }) else null
  }

  @ReactProp(name = "focusesOnAppear", defaultBoolean = false)
  override fun setFocusesOnAppear(view: CylsearchBarView, value: Boolean) { view.bar.focusesOnAppear = value }

  @ReactProp(name = "pageDepth", defaultInt = -1)
  override fun setPageDepth(view: CylsearchBarView, value: Int) { view.bar.pageDepth = value.takeIf { it >= 0 } }

  @ReactProp(name = "showsSearchIcon", defaultBoolean = true)
  override fun setShowsSearchIcon(view: CylsearchBarView, value: Boolean) {
    view.bar.searchIcon = if (value) ContextCompat.getDrawable(view.context, com.cyl.search.R.drawable.cyl_search_ic_search) else null
  }

  @ReactProp(name = "embedsInNavigationBar")
  override fun setEmbedsInNavigationBar(view: CylsearchBarView, value: Boolean) {
    view.embedsInNavigationBar = value
  }

  @ReactProp(name = "showsBackButton")
  override fun setShowsBackButton(view: CylsearchBarView, value: Boolean) {
    view.showsBackButton = value
  }

  @ReactProp(name = "pushesOnTap", defaultBoolean = false)
  override fun setPushesOnTap(view: CylsearchBarView, value: Boolean) { view.pushesOnTap = value }

  @ReactProp(name = "animatesBackButton", defaultBoolean = true)
  override fun setAnimatesBackButton(view: CylsearchBarView, value: Boolean) { view.animatesBackButton = value }

  @ReactProp(name = "editingBar")
  override fun setEditingBar(view: CylsearchBarView, value: Boolean) = view.setEditingBar(value)

  @ReactProp(name = "actionTitle")
  override fun setActionTitle(view: CylsearchBarView, value: String?) {
    view.actionTitle = value.orEmpty()
  }

  @ReactProp(name = "itemsJSON")
  override fun setItemsJSON(view: CylsearchBarView, value: String?) = view.setItemsJSON(value)

  @ReactProp(name = "mode")
  override fun setMode(view: CylsearchBarView, value: String?) = view.setMode(value)

  @ReactProp(name = "searches")
  override fun setSearches(view: CylsearchBarView, value: ReadableArray?) = view.setSearches(value.cylStrings())

  @ReactProp(name = "minimumTextLength", defaultInt = 3)
  override fun setMinimumTextLength(view: CylsearchBarView, value: Int) {
    view.bar.minimumTextLength = maxOf(0, value)
  }

  @ReactProp(name = "usesDefaultAppearance")
  override fun setUsesDefaultAppearance(view: CylsearchBarView, value: Boolean) { view.usesDefaultAppearance = value }

  @ReactProp(name = "centersPlaceholder")
  override fun setCentersPlaceholder(view: CylsearchBarView, value: Boolean) { view.centersPlaceholder = value }

  @ReactProp(name = "placeholderColor")
  override fun setPlaceholderColor(view: CylsearchBarView, value: String?) { view.placeholderColor = value }

  @ReactProp(name = "textColor")
  override fun setTextColor(view: CylsearchBarView, value: String?) { view.textColor = value }

  @ReactProp(name = "fieldMargins")
  override fun setFieldMargins(view: CylsearchBarView, value: ReadableArray?) { view.fieldMargins = value.cylDoubles() }

  @ReactProp(name = "searchingFieldMargins")
  override fun setSearchingFieldMargins(view: CylsearchBarView, value: ReadableArray?) { view.searchingFieldMargins = value.cylDoubles() }

  @ReactProp(name = "cancelMargins")
  override fun setCancelMargins(view: CylsearchBarView, value: ReadableArray?) { view.cancelMargins = value.cylDoubles() }

  @ReactProp(name = "searchingCancelMargins")
  override fun setSearchingCancelMargins(view: CylsearchBarView, value: ReadableArray?) { view.searchingCancelMargins = value.cylDoubles() }

  @ReactProp(name = "animatesChanges", defaultBoolean = true)
  override fun setAnimatesChanges(view: CylsearchBarView, value: Boolean) { view.animatesChanges = value }

  @ReactProp(name = "leadingViewJSON")
  override fun setLeadingViewJSON(view: CylsearchBarView, value: String?) { view.leadingViewJSON = value }

  @ReactProp(name = "trailingAccessoryViewsJSON")
  override fun setTrailingAccessoryViewsJSON(view: CylsearchBarView, value: String?) { view.trailingAccessoryViewsJSON = value }

  @ReactProp(name = "showsLeadingView")
  override fun setShowsLeadingView(view: CylsearchBarView, value: Boolean) { view.showsLeadingView = value }

  @ReactProp(name = "showsTrailingAccessoryViews")
  override fun setShowsTrailingAccessoryViews(view: CylsearchBarView, value: Boolean) { view.showsTrailingAccessoryViews = value }

  @ReactProp(name = "appearanceStyleJSON")
  override fun setAppearanceStyleJSON(view: CylsearchBarView, value: String?) { view.appearanceStyleJSON = value }

  @ReactProp(name = "cancelButtonFontJSON")
  override fun setCancelButtonFontJSON(view: CylsearchBarView, value: String?) { view.cancelButtonFontJSON = value }

  /** Applies the QMUI options together, after every prop of the update is set. */
  override fun onAfterUpdateTransaction(view: CylsearchBarView) {
    super.onAfterUpdateTransaction(view)
    view.applyQMUIStyle()
  }

  /** The `setActive` command: focus (the keyboard rises) or leave the focus. */
  override fun setActive(view: CylsearchBarView, active: Boolean) {
    if (active) view.bar.showKeyboard() else view.bar.hideKeyboard()
  }

  /** The `restartItemAnimation` command: plays that item's animation again from the start. */
  override fun restartItemAnimation(view: CylsearchBarView, index: Int) = view.restartItemAnimation(index)

  /**
   * The views use the activity's theme (DayNight), which follows the system like React Native's color scheme.
   */
  @ReactProp(name = "colorScheme")
  override fun setColorScheme(view: CylsearchBarView, value: String?) = Unit

  companion object {
    const val NAME = "CylsearchBarView"
  }
}
