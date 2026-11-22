package com.cylsearch

import android.content.Context
import android.graphics.Color
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.ViewCompat
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLTagListView
import com.cyl.search.CYLSearchBarAppearance
import com.cyl.search.CYLSearchSuggestionCache

/**
 * The launch view of `CylsearchListView` (the `launchView` of the search page; QMUI's `QDRecentSearchView`): a title with a
 * bottom border and a trash button, and the tags in CollectionViewClassifyMenu's `CYLTagListView` (the tag list the package
 * bridges as `CYLTagListView`, never a layout of its own). Without a history it shows `suggestions`.
 */
internal class CylsearchLaunchView(context: Context) : LinearLayout(context) {

  val titleLabel = TextView(context)
  val tagListView = CYLTagListView(context)
  val clearButton = ImageButton(context)

  var suggestions: List<String> = emptyList()
    set(value) {
      field = value
      reload()
    }

  /** The submitted searches (`CYLSearchView.suggestionCache`): newest first, no duplicates. */
  var historyStore: CYLSearchSuggestionCache? = null
    set(value) {
      field = value
      reload()
    }

  var queries: List<String> = emptyList()
    private set

  init {
    orientation = VERTICAL
    val density = resources.displayMetrics.density
    val padding = (26 * density).toInt()
    setPadding(padding, padding, padding, padding)
    setBackgroundColor(TypedValue().also { context.theme.resolveAttribute(android.R.attr.colorBackground, it, true) }.data)
    tag = "CYLRecentSearchLaunchView"
    val row = LinearLayout(context).apply { gravity = Gravity.CENTER_VERTICAL }
    titleLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
    ViewCompat.setAccessibilityHeading(titleLabel, true)
    row.addView(titleLabel, LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
    clearButton.setImageResource(R.drawable.cylsearch_ic_delete)
    clearButton.setBackgroundColor(Color.TRANSPARENT)
    clearButton.visibility = GONE
    clearButton.setOnClickListener {
      historyStore?.removeAllQueries()
      reload()
      onClear?.invoke()
    }
    row.addView(clearButton, LayoutParams((44 * density).toInt(), (44 * density).toInt()))
    addView(row, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
    addView(View(context).apply { setBackgroundColor(0x33888888) }, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, maxOf(1, density.toInt())))
    val tint = CYLSearchBarAppearance.defaultAppearance(context).tintColor ?: Color.rgb(0, 104, 248)
    tagListView.style = CYLMenuStyle().apply {
      itemHeight = 29f
      interitemSpacing = 10f
      lineSpacing = 10f
      sectionInsets = CYLEdgeInsets(0f, 0f, 0f, 0f)
      backgroundColor = Color.TRANSPARENT
      listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED).forEach { state ->
        appearanceForState(state).apply {
          font = CYLFont(14f)
          textColor = tint
          backgroundColor = Color.TRANSPARENT
          borderColor = tint
          borderWidth = 1f
          cornerRadius = 4f
          contentInsets = CYLEdgeInsets(0f, 10f, 0f, 10f)
        }
      }
    }
    tagListView.showsSectionHeaders = false
    tagListView.isScrollEnabled = false
    tagListView.allowsTapping = false
    addView(tagListView, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = (20 * density).toInt() })
  }

  var onClear: (() -> Unit)? = null

  /** Reads the history again: the tags are the history (newest first) or, without one, the suggestions. */
  fun reload() {
    val history = historyStore?.cachedQueries().orEmpty()
    queries = history.ifEmpty { suggestions }
    clearButton.visibility = if (history.isEmpty()) GONE else VISIBLE
    tagListView.setTagsWithTitles(queries)
  }

  // The launch view is shown on every activation: the history may have changed since.
  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    reload()
  }
}
