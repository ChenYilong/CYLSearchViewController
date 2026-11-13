package com.cylsearch

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
  }

  @ReactProp(name = "text")
  override fun setText(view: CylsearchBarView, value: String?) {
    value?.takeIf { it.isNotEmpty() && it != view.bar.text }?.let { view.bar.text = it }
  }

  @ReactProp(name = "showsCancelButton")
  override fun setShowsCancelButton(view: CylsearchBarView, value: Boolean) {
    view.bar.showsCancelButton = value
  }

  @ReactProp(name = "fieldShadowOpacity")
  override fun setFieldShadowOpacity(view: CylsearchBarView, value: Double) {
    view.bar.fieldShadowOpacity = value.toFloat()
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
