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
 * The tag list (`CylsearchTagListView` in JavaScript). The titles and ids may arrive in either order: the view gets them
 * together once a batch of props is applied (`onAfterUpdateTransaction`).
 */
@ReactModule(name = CylsearchTagListViewManager.NAME)
class CylsearchTagListViewManager : SimpleViewManager<CylsearchTagListView>(),
  CylsearchTagListViewManagerInterface<CylsearchTagListView> {
  private val delegate = CylsearchTagListViewManagerDelegate(this)
  private val pendingTitles = HashMap<Int, List<String>>()
  private val pendingIds = HashMap<Int, List<String>>()
  private val pendingSelection = HashMap<Int, List<String>>()

  override fun getDelegate(): ViewManagerDelegate<CylsearchTagListView> = delegate
  override fun getName() = NAME
  override fun createViewInstance(context: ThemedReactContext) = CylsearchTagListView(context)

  @ReactProp(name = "tags")
  override fun setTags(view: CylsearchTagListView, value: ReadableArray?) {
    pendingTitles[view.id] = value.cylStrings()
  }

  @ReactProp(name = "tagIds")
  override fun setTagIds(view: CylsearchTagListView, value: ReadableArray?) {
    pendingIds[view.id] = value.cylStrings()
  }

  @ReactProp(name = "selectedIds")
  override fun setSelectedIds(view: CylsearchTagListView, value: ReadableArray?) {
    pendingSelection[view.id] = value.cylStrings()
  }

  @ReactProp(name = "selectionMode")
  override fun setSelectionMode(view: CylsearchTagListView, value: String?) = view.setSelection(value)

  @ReactProp(name = "sectionTitle")
  override fun setSectionTitle(view: CylsearchTagListView, value: String?) {
    view.sectionTitle = value.orEmpty()
  }

  @ReactProp(name = "showsClearButton")
  override fun setShowsClearButton(view: CylsearchTagListView, value: Boolean) {
    view.showsClearButton = value
  }

  @ReactProp(name = "editing")
  override fun setEditing(view: CylsearchTagListView, value: Boolean) {
    if (value != view.isEditing) view.setEditing(value, true)
  }

  @ReactProp(name = "supportsRenaming")
  override fun setSupportsRenaming(view: CylsearchTagListView, value: Boolean) {
    view.supportsRenaming = value
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

  override fun onAfterUpdateTransaction(view: CylsearchTagListView) {
    super.onAfterUpdateTransaction(view)
    val titles = pendingTitles.remove(view.id)
    val ids = pendingIds.remove(view.id)
    if (titles != null || ids != null) view.setTags(titles ?: view.titles, ids ?: view.ids) else view.reload()
    pendingSelection.remove(view.id)?.let { view.setSelectedIds(it) }
  }

  override fun onDropViewInstance(view: CylsearchTagListView) {
    pendingTitles.remove(view.id)
    pendingIds.remove(view.id)
    pendingSelection.remove(view.id)
    super.onDropViewInstance(view)
  }

  companion object {
    const val NAME = "CylsearchTagListView"
  }
}
