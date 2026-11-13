package com.cylsearch

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.CylsearchTagListViewManagerDelegate
import com.facebook.react.viewmanagers.CylsearchTagListViewManagerInterface

/**
 * The tag list (`CylsearchTagListView` in JavaScript).
 */
@ReactModule(name = CylsearchTagListViewManager.NAME)
class CylsearchTagListViewManager : SimpleViewManager<CylsearchTagListView>(),
  CylsearchTagListViewManagerInterface<CylsearchTagListView> {
  private val delegate = CylsearchTagListViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<CylsearchTagListView> = delegate
  override fun getName() = NAME
  override fun createViewInstance(context: ThemedReactContext) = CylsearchTagListView(context)

  @ReactProp(name = "tags")
  override fun setTags(view: CylsearchTagListView, value: ReadableArray?) {
    view.setTagsWithTitles(value.cylStrings())
    view.reportHeight()
  }

  @ReactProp(name = "foldControlPosition")
  override fun setFoldControlPosition(view: CylsearchTagListView, value: String?) {
    view.foldPosition = value
    view.foldControl = cylFoldControl(value, view.foldContent)
  }

  @ReactProp(name = "foldControlContent")
  override fun setFoldControlContent(view: CylsearchTagListView, value: String?) {
    view.foldContent = value
    view.foldControl = cylFoldControl(view.foldPosition, value)
  }

  @ReactProp(name = "foldedRowCount", defaultInt = 2)
  override fun setFoldedRowCount(view: CylsearchTagListView, value: Int) {
    view.defaultVisibleRows = maxOf(0, value)
  }

  @ReactProp(name = "colorScheme")
  override fun setColorScheme(view: CylsearchTagListView, value: String?) = Unit

  companion object {
    const val NAME = "CylsearchTagListView"
  }
}
