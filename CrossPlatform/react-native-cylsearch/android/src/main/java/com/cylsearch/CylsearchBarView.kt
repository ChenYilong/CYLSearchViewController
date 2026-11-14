package com.cylsearch

import android.widget.FrameLayout
import com.cyl.search.CYLSearchBarItem
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

  override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) = emit("topTextChange", "text" to text)

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

  private fun JSONObject.toMap(): Map<String, Any?> = keys().asSequence().associateWith { key -> opt(key).takeUnless { it == JSONObject.NULL } }
}
