package com.cyl.search

import android.content.Context
import android.graphics.Rect
import android.util.AttributeSet
import androidx.appcompat.widget.Toolbar
import androidx.core.content.ContextCompat

/**
 * A toolbar the core creates for a screen that has none, holding the search bar in the space the navigation icon leaves
 * (iOS `CYLSearchNavigationBar`, a `UINavigationBar` holding the search bar as its title view). `CYLSearchBarView.embedInToolbar`
 * makes one when the activity has no action bar; the cross-platform bridges use `holding` as the content of their native
 * view.
 */
class CYLSearchNavigationBar @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : Toolbar(context, attrs) {

    /**
     * Called when the back button is tapped (a bar made with `showsBackButton`); the bar itself never navigates, the host
     * decides (a Flutter route pops, a React Native screen closes).
     */
    var backHandler: (() -> Unit)? = null

    init {
        minimumHeight = (STANDARD_HEIGHT * resources.displayMetrics.density + 0.5f).toInt()
        setNavigationOnClickListener { backHandler?.invoke() }
    }

    companion object {

        /**
         * The height of a toolbar in dp, 56 (iOS `standardHeight`, 44 pt).
         */
        const val STANDARD_HEIGHT: Int = 56

        /**
         * A toolbar holding `searchBar`, with the bar set up for it (36 dp field, 4 dp above and below, `embedsInToolbar`).
         * The bridges use it as the content of their native view.
         */
        @JvmStatic
        fun holding(searchBar: CYLSearchBarView): CYLSearchNavigationBar = holding(searchBar, false)

        /**
         * As `holding(searchBar)`, and with `showsBackButton` the toolbar has the back arrow of a second-level page at its
         * start (the search bar takes the width that is left). A tap on it calls `backHandler`.
         */
        @JvmStatic
        fun holding(searchBar: CYLSearchBarView, showsBackButton: Boolean): CYLSearchNavigationBar {
            val context = searchBar.context
            val bar = CYLSearchNavigationBar(context)
            searchBar.fieldHeight = 36f
            searchBar.contentInsets = Rect(0, 4, 0, 4)
            searchBar.embedInToolbar(bar)
            if (showsBackButton) {
                bar.setNavigationIcon(ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_arrow_back))
                bar.setNavigationContentDescription(CYLSearchResources.localizedString(context, "navigationBar.back"))
            }
            return bar
        }
    }
}
