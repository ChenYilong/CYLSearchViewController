package com.cyl.search

import android.content.Context
import android.graphics.drawable.Drawable
import androidx.core.content.ContextCompat
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLTagListView

/**
 * The built-in look of a tag list section header (docs/animated-icon-component.md, "Refresh, hot data and navigation bar
 * contract", A): the refresh action is an icon, never the three dots of ClassifyMenu's More button and never text. The icon
 * is a resource of this library (`cyl_search_ic_refresh`, the Material "refresh" icon) and its label is localized
 * (`cyl_search_tagList_refresh`: Refresh, 更新, 刷新, 重新整理; iOS `CYLSearchTagListHeader.applyRefreshIcon(to:)`).
 *
 * A style assignment replaces the icon: apply it after the list's style is set.
 */
object CYLSearchTagListHeader {

    /**
     * The refresh icon, the Material "refresh" icon of this library (iOS `refreshImage`, the SF Symbol "arrow.clockwise").
     */
    @JvmStatic
    fun refreshImage(context: Context): Drawable? = ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_refresh)

    /**
     * Puts the refresh icon on the More button of the header of `style` (`CYLMenuStyle.moreButtonImage`). The data source
     * still decides which sections show the button (`menuShowsMoreButtonInSection`).
     */
    @JvmStatic
    fun applyRefreshIcon(context: Context, style: CYLMenuStyle) {
        style.moreButtonImage = refreshImage(context)
    }

    /**
     * Sets the refresh icon as the icon of `list`'s header More button, in place of the three dots (iOS
     * `applyRefreshIcon(to:)`); the list's other style values stay.
     */
    @JvmStatic
    fun applyRefreshIcon(list: CYLTagListView) {
        val style = (list.style ?: CYLMenuStyle.defaultStyle()).copy()
        applyRefreshIcon(list.context, style)
        list.style = style
    }

    /**
     * The localized accessibility label of the refresh icon, for `menuAccessibilityLabelForMoreButtonInSection`.
     */
    @JvmStatic
    fun refreshLabel(context: Context): String = context.getString(R.string.cyl_search_tagList_refresh)
}
