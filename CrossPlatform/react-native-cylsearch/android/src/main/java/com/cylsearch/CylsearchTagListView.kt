package com.cylsearch

import android.graphics.Color
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLTagListView
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper

/**
 * CollectionViewClassifyMenu's CYLTagListView filling the component, one section of tags from JavaScript: their titles
 * and ids, the selection, the header (title and clear button) and editing mode (crosses, dragging, rename requests).
 * It reports the height its tags need at the component's width (`onHeightChange`, in dp), again after folding,
 * unfolding and editing.
 */
class CylsearchTagListView(private val reactContext: ThemedReactContext) : CYLTagListView(reactContext), CYLMenuDataSource, CYLMenuDelegate {

  var foldPosition: String? = null
  var foldContent: String? = null
  private var reportedHeight = -1f

  /** The tags' titles and ids (the titles when no ids are given). */
  var titles: List<String> = emptyList()
    private set
  var ids: List<String> = emptyList()
    private set
  private var selected: Set<String> = emptySet()
  var sectionTitle: String = ""
  var showsClearButton: Boolean = false
  var supportsRenaming: Boolean = false

  init {
    showsSectionHeaders = false
    // The React Native screen shows through, as around any other view.
    style = style?.copy()?.apply { backgroundColor = Color.TRANSPARENT }
    menuDataSource = this
    menuDelegate = this
    // Renaming is the host's: the list asks, the host renames by id and sends the new titles.
    renameRequestHandler = { indexPath, title -> emit("topRenameRequest", "index" to indexPath.item, "id" to idAt(indexPath.item), "title" to title) }
  }

  private fun idAt(index: Int): String = ids.getOrNull(index)?.takeIf { it.isNotEmpty() } ?: titles.getOrElse(index) { "" }

  /** Sets the tags (titles and ids) and shows the selection again. */
  fun setTags(titles: List<String>, ids: List<String>) {
    this.titles = titles
    this.ids = ids
    reload()
  }

  fun setSelectedIds(value: List<String>) {
    selected = value.toSet()
    applySelection()
  }

  fun setSelection(mode: String?) {
    selectionMode = if (mode == "multiple") CYLMenuSelectionMode.CYLMenuSelectionModeMultiple else CYLMenuSelectionMode.CYLMenuSelectionModeNone
    allowsEmptySelection = true
  }

  fun reload() {
    showsSectionHeaders = sectionTitle.isNotEmpty() || showsClearButton
    reloadMenuData()
    applySelection()
    reportHeight()
  }

  private fun applySelection() {
    if (selectionMode != CYLMenuSelectionMode.CYLMenuSelectionModeMultiple) return
    selectedIndexPaths = titles.indices.filter { idAt(it) in selected }.map { CYLIndexPath(it, 0) }
  }

  // CYLMenuDataSource

  override fun numberOfSectionsInMenu() = 1
  override fun menuNumberOfItemsInSection(section: Int) = titles.size
  override fun menuTitleForSection(section: Int) = sectionTitle
  override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = titles.getOrElse(indexPath.item) { "" }
  override fun menuIdentifierForItemAtIndexPath(indexPath: CYLIndexPath): String = idAt(indexPath.item)
  override fun menuShowsClearButtonForSection(section: Int) = showsClearButton
  override fun supportsRenamingItems() = supportsRenaming
  override fun menuRenameItemAtIndexPath(indexPath: CYLIndexPath, title: String) = Unit
  override fun supportsMovingItems() = true
  override fun menuMoveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) {
    val moved = titles.toMutableList().apply { add(toIndexPath.item, removeAt(sourceIndexPath.item)) }
    if (ids.size == titles.size) ids = ids.toMutableList().apply { add(toIndexPath.item, removeAt(sourceIndexPath.item)) }
    titles = moved
    emit("topTagMove", "from" to sourceIndexPath.item, "to" to toIndexPath.item)
  }
  override fun menuRemoveItemAtIndexPath(indexPath: CYLIndexPath) {
    val index = indexPath.item
    val id = idAt(index)
    titles = titles.filterIndexed { i, _ -> i != index }
    if (ids.size > index) ids = ids.filterIndexed { i, _ -> i != index }
    emit("topTagDelete", "index" to index, "id" to id)
  }

  // CYLMenuDelegate

  override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
    val index = indexPath.item
    val id = idAt(index)
    val nowSelected = selectionMode == CYLMenuSelectionMode.CYLMenuSelectionModeMultiple
    if (nowSelected) selected = selected + id
    emit("topTagSelect", "index" to index, "title" to titles.getOrElse(index) { "" }, "id" to id, "selected" to nowSelected)
  }

  override fun menuDidDeselectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
    val index = indexPath.item
    val id = idAt(index)
    selected = selected - id
    emit("topTagSelect", "index" to index, "title" to titles.getOrElse(index) { "" }, "id" to id, "selected" to false)
  }

  override fun menuDidTapClearButtonInSection(menu: Any, section: Int) = emit("topClearButtonTap", "section" to section)
  override fun menuDidChangeContentHeight(menu: Any, height: Float) = reportHeight()
  override fun menuDidChangeExpanded(menu: Any, expanded: Boolean, inSection: Int) = reportHeight()
  override fun menuDidChangeEditing(menu: Any, editing: Boolean) = reportHeight()

  override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
    super.onSizeChanged(w, h, oldw, oldh)
    reportHeight()
  }

  override fun requestLayout() {
    super.requestLayout()
    post(measureAndLayout)
  }

  private val measureAndLayout = Runnable {
    measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
    layout(left, top, right, bottom)
  }

  fun reportHeight() {
    val widthDp = width / resources.displayMetrics.density
    if (widthDp <= 0f) return
    // The list's own content height includes a folded inline row that `heightThatFitsWidth` can leave out.
    val height = kotlin.math.ceil(maxOf(heightThatFitsWidth(widthDp), contentHeight))
    if (height != reportedHeight) {
      reportedHeight = height
      emit("topHeightChange", "height" to height.toDouble())
    }
  }

  private fun emit(name: String, vararg pairs: Pair<String, Any>) {
    UIManagerHelper.getEventDispatcher(reactContext)?.dispatchEvent(
      CylsearchEvent(UIManagerHelper.getSurfaceId(this), id, name, cylEventData(*pairs)))
  }
}
