package com.cyl.search

import android.content.Context
import androidx.core.content.ContextCompat
import com.cyl.classifymenu.CYLMenuStyle

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
     * Puts the refresh icon on the More button of the header of `style` (`CYLMenuStyle.moreButtonImage`). The data source
     * still decides which sections show the button (`menuShowsMoreButtonInSection`).
     */
    @JvmStatic
    fun applyRefreshIcon(context: Context, style: CYLMenuStyle) {
        style.moreButtonImage = ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_refresh)
    }

    /**
     * The localized accessibility label of the refresh icon, for `menuAccessibilityLabelForMoreButtonInSection`.
     */
    @JvmStatic
    fun refreshLabel(context: Context): String = context.getString(R.string.cyl_search_tagList_refresh)
}
