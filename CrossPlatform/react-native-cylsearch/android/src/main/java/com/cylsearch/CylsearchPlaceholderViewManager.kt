package com.cylsearch

import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.CylsearchPlaceholderViewManagerDelegate
import com.facebook.react.viewmanagers.CylsearchPlaceholderViewManagerInterface

/**
 * The placeholder (`CylsearchPlaceholderView` in JavaScript): rebuilt once a batch of props is applied.
 */
@ReactModule(name = CylsearchPlaceholderViewManager.NAME)
class CylsearchPlaceholderViewManager : SimpleViewManager<CylsearchPlaceholderView>(),
  CylsearchPlaceholderViewManagerInterface<CylsearchPlaceholderView> {
  private val delegate = CylsearchPlaceholderViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<CylsearchPlaceholderView> = delegate
  override fun getName() = NAME
  override fun createViewInstance(context: ThemedReactContext) = CylsearchPlaceholderView(context)

  @ReactProp(name = "placeholderStyle")
  override fun setPlaceholderStyle(view: CylsearchPlaceholderView, value: String?) {
    view.styleName = value.orEmpty()
  }

  @ReactProp(name = "text")
  override fun setText(view: CylsearchPlaceholderView, value: String?) {
    view.text = value.orEmpty()
  }

  @ReactProp(name = "colorScheme")
  override fun setColorScheme(view: CylsearchPlaceholderView, value: String?) = Unit

  override fun onAfterUpdateTransaction(view: CylsearchPlaceholderView) {
    super.onAfterUpdateTransaction(view)
    view.rebuild()
  }

  companion object {
    const val NAME = "CylsearchPlaceholderView"
  }
}
