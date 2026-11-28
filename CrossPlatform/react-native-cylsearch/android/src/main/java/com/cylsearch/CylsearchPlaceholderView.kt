package com.cylsearch

import android.view.Gravity
import android.widget.FrameLayout
import com.cyl.placeholder.CYLPlaceholderStyle
import com.cyl.placeholder.CYLPlaceholderView
import com.facebook.react.uimanager.ThemedReactContext

/**
 * CYLTableViewPlaceHolder's CYLPlaceholderView in the component (`CylsearchPlaceholderView`): the image of a
 * `CYLPlaceholderStyle` above a text, at its content size, centred.
 */
class CylsearchPlaceholderView(reactContext: ThemedReactContext) : FrameLayout(reactContext) {

  var styleName: String = "empty"
  var text: String = ""

  /** Builds the placeholder for the current style and text ("noResults" -> NoResults; unknown -> Empty). */
  fun rebuild() {
    removeAllViews()
    val style = CYLPlaceholderStyle.entries.firstOrNull { it.name.equals(styleName, ignoreCase = true) } ?: CYLPlaceholderStyle.Empty
    val placeholder = CYLPlaceholderView(context, style, text).apply { reportsContentSize = true }
    addView(placeholder, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER))
  }

  override fun requestLayout() {
    super.requestLayout()
    post(measureAndLayout)
  }

  private val measureAndLayout = Runnable {
    measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
    layout(left, top, right, bottom)
  }
}
