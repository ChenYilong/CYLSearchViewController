package com.cylsearch

import android.widget.FrameLayout
import android.graphics.Color
import android.graphics.Rect
import android.graphics.drawable.GradientDrawable
import android.view.View
import com.cyl.search.CYLSearchBarAppearance
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

  var bar = CYLSearchBarView(reactContext)
    private set

  init {
    bar.delegate = this
    addView(bar, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
  }

  /** The editing bar's action title ("Add", "Done"), kept for a bar made later. */
  var actionTitle: String = ""
    set(value) {
      field = value
      if (bar.isEditingBar) bar.cancelButtonTitle = value
    }

  /**
   * `editingBar`: the core's editing bar (CYLSearchBarView.editingBar) in place of the search bar, its submit sent as
   * `onEditingSubmit` (the trimmed text) and the field cleared after it; false brings a search bar back.
   */
  fun setEditingBar(editing: Boolean) {
    if (editing == bar.isEditingBar) return
    val placeholder = bar.placeholder
    removeView(bar)
    bar = if (editing) CYLSearchBarView.editingBar(reactContext, placeholder, actionTitle) else CYLSearchBarView(reactContext).also { it.placeholder = placeholder }
    bar.delegate = this
    if (editing) {
      bar.editingSubmitHandler = { view, text ->
        emit("topEditingSubmit", "text" to text)
        view.text = ""
      }
    }
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
    // An editing bar reports its submit through `onEditingSubmit` and keeps the keyboard up for the next name.
    if (searchBarView.isEditingBar) return
    emit("topSubmit", "text" to searchBarView.text.orEmpty())
    searchBarView.hideKeyboard()
  }

  override fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) = emit("topCancel")

  override fun searchBarViewDidBeginEditing(searchBarView: CYLSearchBarView) = emitActive(true)

  override fun searchBarViewDidEndEditing(searchBarView: CYLSearchBarView) = emitActive(false)

  private fun emitActive(active: Boolean) {
    emit("topActiveChange", "active" to active)
  }

  // The QMUI options (iOS: CYLSearchBar members, Android: CYLSearchBarView members). They are kept here and applied together
  // after each prop update, so the default appearance never overwrites what JavaScript set after it.
  var usesDefaultAppearance = false
  var centersPlaceholder = false
  var placeholderProp: String? = null
  var placeholderColor: String? = null
  var textColor: String? = null
  var fieldMargins: List<Double> = emptyList()
  var searchingFieldMargins: List<Double> = emptyList()
  var cancelMargins: List<Double> = emptyList()
  var searchingCancelMargins: List<Double> = emptyList()
  var animatesChanges = true
  var leadingViewJSON: String? = null
  var trailingAccessoryViewsJSON: String? = null
  var showsLeadingView = false
  var showsTrailingAccessoryViews = false
  var appearanceStyleJSON: String? = null
  var cancelButtonFontJSON: String? = null
  var showsCancel = false
  private var appliedAppearance: Pair<Boolean, String?>? = null
  private var appliedLeading: String? = null
  private var appliedTrailing: String? = null
  private var shownLeading: Boolean? = null
  private var shownTrailing: Boolean? = null
  private var shownCancel: Boolean? = null

  /** Called once per prop update (the manager's onAfterUpdateTransaction). */
  fun applyQMUIStyle() {
    val appearance = usesDefaultAppearance to appearanceStyleJSON
    if (appearance != appliedAppearance) {
      appliedAppearance = appearance
      if (usesDefaultAppearance) bar.applyDefaultAppearance()
      appearanceStyleJSON?.takeIf { it.isNotEmpty() }?.let { runCatching { appearanceFromJSON(JSONObject(it)).applyTo(bar) } }
    }
    placeholderProp?.takeIf { it.isNotEmpty() }?.let { bar.placeholder = it }
    parseColor(placeholderColor)?.let { bar.placeholderColor = it }
    parseColor(textColor)?.let { bar.textColor = it }
    bar.centersPlaceholder = centersPlaceholder
    val field = rect(fieldMargins)
    val fieldActive = rect(searchingFieldMargins)
    val cancel = rect(cancelMargins)
    val cancelActive = rect(searchingCancelMargins)
    bar.textFieldMarginsProvider = if (fieldMargins.isEmpty() && searchingFieldMargins.isEmpty()) null else { b, active -> if (active && searchingFieldMargins.isNotEmpty()) fieldActive else field }
    bar.cancelButtonMarginsProvider = if (cancelMargins.isEmpty() && searchingCancelMargins.isEmpty()) null else { b, active -> if (active && searchingCancelMargins.isNotEmpty()) cancelActive else cancel }
    bar.applyCancelButtonFont(cancelButtonFontJSON)
    // TODO (Android merge): the core still has the accessory slots next to `leadingView` / `trailingAccessoryViews`; the
    // first view of `trailingAccessoryViewsJSON` goes into the slot until the core animates the existing members.
    if (leadingViewJSON != appliedLeading) {
      appliedLeading = leadingViewJSON
      bar.leadingAccessoryView = accessory(leadingViewJSON)
      bar.leadingAccessoryViewMargins = Rect(8, 0, 0, 0)
    }
    if (trailingAccessoryViewsJSON != appliedTrailing) {
      appliedTrailing = trailingAccessoryViewsJSON
      bar.trailingAccessoryView = accessory(runCatching { JSONArray(trailingAccessoryViewsJSON).optJSONObject(0)?.toString() }.getOrNull())
      bar.trailingAccessoryViewMargins = Rect(0, 0, 8, 0)
    }
    // Changes of the shown state animate once the first one is on screen (setShows...(_:animated:)).
    if (shownLeading != showsLeadingView) {
      bar.setShowsLeadingAccessoryView(showsLeadingView, animatesChanges && shownLeading != null)
      shownLeading = showsLeadingView
    }
    if (shownTrailing != showsTrailingAccessoryViews) {
      bar.setShowsTrailingAccessoryView(showsTrailingAccessoryViews, animatesChanges && shownTrailing != null)
      shownTrailing = showsTrailingAccessoryViews
    }
    if (shownCancel != showsCancel) {
      bar.setShowsCancelButton(showsCancel, animatesChanges && shownCancel != null)
      shownCancel = showsCancel
    }
  }

  private fun parseColor(value: String?): Int? = cylParseColor(value)

  /** [top, left, bottom, right] as the Rect(left, top, right, bottom) of the core, in dp. */
  private fun rect(values: List<Double>): Rect =
    if (values.size < 4) Rect() else Rect(values[1].toInt(), values[0].toInt(), values[3].toInt(), values[2].toInt())

  private fun appearanceFromJSON(json: JSONObject) = CYLSearchBarAppearance().also { a ->
    parseColor(json.optString("textColor"))?.let { a.textColor = it }
    parseColor(json.optString("placeholderColor"))?.let { a.placeholderColor = it }
    parseColor(json.optString("tintColor"))?.let { a.tintColor = it }
    parseColor(json.optString("fieldBackgroundColor"))?.let { a.fieldBackgroundColor = it }
    json.optString("cancelTitle").takeIf { it.isNotEmpty() }?.let { a.cancelTitle = it }
    if (json.has("fieldCornerRadius")) a.fieldCornerRadius = json.optDouble("fieldCornerRadius").toFloat()
    if (json.has("fontSize")) a.fontSize = json.optDouble("fontSize").toFloat()
  }

  /** The accessory of a JSON spec: a stroked rounded square (QDSearchBarViewController's 30 x 30 view). */
  private fun accessory(json: String?): View? {
    if (json.isNullOrEmpty()) return null
    val spec = runCatching { JSONObject(json) }.getOrNull() ?: return null
    val density = resources.displayMetrics.density
    val size = (spec.optDouble("size", 30.0) * density).toInt()
    val view = View(context)
    view.background = GradientDrawable().apply {
      cornerRadius = 6 * density
      setStroke((3 * density).toInt(), parseColor(spec.optString("color")) ?: Color.rgb(0, 122, 255))
    }
    view.contentDescription = spec.optString("label")
    view.layoutParams = LayoutParams(size, size)
    return view
  }

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
