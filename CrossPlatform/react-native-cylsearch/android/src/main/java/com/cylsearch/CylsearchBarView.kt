package com.cylsearch

import android.widget.FrameLayout
import com.cyl.search.CYLSearchBarView
import com.cyl.search.CYLSearchBarViewDelegate
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper

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
}
