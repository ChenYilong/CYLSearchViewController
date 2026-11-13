package com.cylsearch

import android.graphics.Color
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLTagListView
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper

/**
 * CollectionViewClassifyMenu's CYLTagListView filling the component; it reports the height its tags need at the
 * component's width (`onHeightChange`, in dp), again after folding and unfolding.
 */
class CylsearchTagListView(private val reactContext: ThemedReactContext) : CYLTagListView(reactContext) {

  var foldPosition: String? = null
  var foldContent: String? = null
  private var reportedHeight = -1f

  init {
    showsSectionHeaders = false
    // The React Native screen shows through, as around any other view.
    style = style?.copy()?.apply { backgroundColor = Color.TRANSPARENT }
    tagClickHandler = { index, tag -> emit("topTagSelect", "index" to index, "title" to tag.title) }
    menuDelegate = object : CYLMenuDelegate {
      override fun menuDidChangeContentHeight(menu: Any, height: Float) = reportHeight()
      override fun menuDidChangeExpanded(menu: Any, expanded: Boolean, inSection: Int) = reportHeight()
    }
  }

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
