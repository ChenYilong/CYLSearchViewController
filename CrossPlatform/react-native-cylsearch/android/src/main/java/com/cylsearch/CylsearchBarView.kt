package com.cylsearch

import android.widget.FrameLayout
import com.cyl.search.CYLSearchBarItem
import com.cyl.search.CYLSearchBarMode
import com.cyl.search.CYLSearchBarView
import com.cyl.search.CYLSearchBarViewDelegate
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper
import org.json.JSONArray
import org.json.JSONObject

/**
 * CYLSearchBarView of the `cylsearch` module (a final class), filling the component.
 */
class CylsearchBarView(private val reactContext: ThemedReactContext) : FrameLayout(reactContext), CYLSearchBarViewDelegate {

  val bar = CYLSearchBarView(reactContext)

  init {
    bar.delegate = this
    addView(bar, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
  }

  override fun requestLayout() {
    super.requestLayout()
    post(measureAndLayout)
  }

  private val measureAndLayout = Runnable {
    measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
    layout(left, top, right, bottom)
  }

  private fun emit(name: String, vararg pairs: Pair<String, Any>) {
    UIManagerHelper.getEventDispatcher(reactContext)?.dispatchEvent(
      CylsearchEvent(UIManagerHelper.getSurfaceId(this), id, name, cylEventData(*pairs)))
  }

  override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) =
    emit("topTextChange", "text" to text, "index" to -1)

  override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String, index: Int) =
    emit("topTextChange", "text" to text, "index" to index)

  override fun searchBarViewDidCompleteSearch(searchBarView: CYLSearchBarView, text: String, index: Int) {
    if (!applyingSearches) emit("topCompleteSearch", "text" to text, "index" to index)
  }

  override fun searchBarViewDidRemoveSearchAtIndex(searchBarView: CYLSearchBarView, index: Int) {
    if (!applyingSearches) emit("topRemoveSearch", "index" to index)
  }

  override fun searchBarViewDidSelectSearch(searchBarView: CYLSearchBarView, text: String, index: Int) {
    if (!applyingSearches) emit("topSelectSearch", "text" to text, "index" to index)
  }

  override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
    emit("topSubmit", "text" to searchBarView.text.orEmpty())
    searchBarView.hideKeyboard()
  }

  override fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) = emit("topCancel")

  override fun searchBarViewDidSelectItem(searchBarView: CYLSearchBarView, item: CYLSearchBarItem) =
    emit("topItemSelect", "index" to item.index, "selected" to item.isSelected)

  private var itemsJSON: String = ""

  /**
   * Rebuilds the items when JavaScript sends other ones, so a re-render keeps the native selection.
   */
  fun setItemsJSON(value: String?) {
    val json = value.orEmpty()
    if (json == itemsJSON) return
    itemsJSON = json
    bar.removeAllItems()
    val array = runCatching { JSONArray(json) }.getOrNull() ?: return
    for (i in 0 until array.length()) {
      val objectValue = array.optJSONObject(i) ?: continue
      bar.addItem(CYLSearchBarItem.fromMap(context, objectValue.toMap()))
    }
  }

  private var appliedSearches: List<String>? = null
  private var applyingSearches = false

  /**
   * The `mode` prop: "multiple" shows several searches side by side; turning it on applies the `searches` prop again.
   */
  fun setMode(value: String?) {
    val mode = if (value == "multiple") CYLSearchBarMode.Multiple else CYLSearchBarMode.Single
    if (mode == bar.mode) return
    bar.mode = mode
    appliedSearches?.let { applySearches(it) }
  }

  /**
   * The `searches` prop: replaces the native searches only when JavaScript sends another list, so a re-render keeps
   * the searches typed natively.
   */
  fun setSearches(value: List<String>) {
    if (value == appliedSearches) return
    appliedSearches = value
    applySearches(value)
  }

  private fun applySearches(values: List<String>) {
    // The list JavaScript keeps from the events is already on screen: nothing to rebuild.
    if (bar.mode != CYLSearchBarMode.Multiple || values == bar.searches) return
    applyingSearches = true
    try {
      for (index in bar.searches.indices.reversed()) bar.removeSearch(index)
      values.forEach { bar.addSearch(it) }
    } finally {
      applyingSearches = false
    }
  }

  private fun JSONObject.toMap(): Map<String, Any?> = keys().asSequence().associateWith { key -> opt(key).takeUnless { it == JSONObject.NULL } }
}
