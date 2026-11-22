package com.cylsearch

import androidx.core.content.ContextCompat
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

  @ReactProp(name = "showsSearchIcon", defaultBoolean = true)
  override fun setShowsSearchIcon(view: CylsearchBarView, value: Boolean) {
    view.bar.searchIcon = if (value) ContextCompat.getDrawable(view.context, com.cyl.search.R.drawable.cyl_search_ic_search) else null
  }

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

  @ReactProp(name = "leadingAccessoryJSON")
  override fun setLeadingAccessoryJSON(view: CylsearchBarView, value: String?) { view.leadingAccessoryJSON = value }

  @ReactProp(name = "trailingAccessoryJSON")
  override fun setTrailingAccessoryJSON(view: CylsearchBarView, value: String?) { view.trailingAccessoryJSON = value }

  @ReactProp(name = "showsLeadingAccessory")
  override fun setShowsLeadingAccessory(view: CylsearchBarView, value: Boolean) { view.showsLeadingAccessory = value }

  @ReactProp(name = "showsTrailingAccessory")
  override fun setShowsTrailingAccessory(view: CylsearchBarView, value: Boolean) { view.showsTrailingAccessory = value }

  @ReactProp(name = "appearanceJSON")
  override fun setAppearanceJSON(view: CylsearchBarView, value: String?) { view.appearanceJSON = value }

  /** Applies the QMUI options together, after every prop of the update is set. */
  override fun onAfterUpdateTransaction(view: CylsearchBarView) {
    super.onAfterUpdateTransaction(view)
    view.applyQMUIStyle()
  }

  /** The `setActive` command: focus (the keyboard rises) or leave the focus. */
  override fun setActive(view: CylsearchBarView, active: Boolean) {
    if (active) view.bar.showKeyboard() else view.bar.hideKeyboard()
  }

  /**
   * The views use the activity's theme (DayNight), which follows the system like React Native's color scheme.
   */
  @ReactProp(name = "colorScheme")
  override fun setColorScheme(view: CylsearchBarView, value: String?) = Unit

  companion object {
    const val NAME = "CylsearchBarView"
  }
}
