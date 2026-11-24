package com.cyl.search

import android.graphics.Color
import android.graphics.Typeface
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagBackgroundStyle
import com.cyl.classifymenu.CYLTagListView

/**
 * The search bar core's default style of a tag list, the look of the iOS example's recent searches and discover topics:
 * capsule tags with a light border, a bold section header, one 16 dp inset (docs/animated-icon-component.md, "Default
 * layout contract"). It is set here, in the search bar core, through the public API of ClassifyMenu's `CYLMenuStyle`;
 * the tag list itself is not changed. The Flutter and React Native bridges call it, so no example writes a tag style of
 * its own (iOS `CYLSearchTagListStyle`).
 */
object CYLSearchTagListStyle {

    /**
     * The corner radius of a capsule: the corners are as round as the tag's height allows (ClassifyMenu limits a radius to
     * half the height). The one named constant for it: pass it, never the literal 1000. 0 is square corners; no other
     * value has a special meaning.
     */
    const val CAPSULE_CORNER_RADIUS: Float = 1000f

    /**
     * The border of a flat tag: iOS `UIColor.separator` in light mode (60,60,67 at 29%), visible on a white tag over an off-white
     * page; the earlier 16% black was not.
     */
    internal val BORDER_COLOR: Int = Color.argb(74, 60, 60, 67)

    /**
     * The corner radius of every tag, in dp. The default `CAPSULE_CORNER_RADIUS` is a capsule, as in the iOS example's
     * recent searches; 0 is square corners; another value is a rounded rectangle.
     */
    @JvmStatic
    var tagCornerRadius: Float = CAPSULE_CORNER_RADIUS

    /**
     * Called with the style after the defaults are set, to change any value of it. null by default.
     */
    @JvmStatic
    var styleCustomizer: ((CYLMenuStyle) -> Unit)? = null

    /**
     * The background of every tag, handed to CollectionViewClassifyMenu's `CYLMenuStyle.backgroundStyle`: flat by default
     * (the tag's own colors), Liquid Glass for the glass background (flat below Android 12; iOS `tagBackgroundStyle`).
     */
    @JvmStatic
    var tagBackgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat

    /**
     * The fills of a Liquid Glass tag: transparent, so CYLAnimatedItemView draws the library's default frosted tint, and the
     * iOS tint color (system blue) at 30% for a selected tag (iOS `applyDefaults(to:)`).
     */
    internal val GLASS_TINT_COLOR: Int = Color.TRANSPARENT
    internal val GLASS_SELECTED_TINT_COLOR: Int = Color.argb(77, 0, 122, 255)

    /**
     * Sets the defaults on `style`: white tags with a 1 dp light border and `tagCornerRadius`, 17 sp text, 36 dp high, 12 dp
     * apart, a 16 dp section inset and a bold 20 sp section header, then calls `styleCustomizer`. Values the defaults do not
     * name (for example a transparent background) stay as they are.
     */
    @JvmStatic
    fun applyDefaults(style: CYLMenuStyle) {
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            style.appearanceForState(state).apply {
                // A Liquid Glass tag is a tint on the glass, no border; a flat tag is white with a light border.
                if (tagBackgroundStyle == CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat) {
                    backgroundColor = Color.WHITE
                    borderColor = BORDER_COLOR
                    borderWidth = 1f
                } else {
                    backgroundColor = if (state == CYLControlState.SELECTED) GLASS_SELECTED_TINT_COLOR else GLASS_TINT_COLOR
                    borderWidth = 0f
                }
                cornerRadius = tagCornerRadius
                margin = 14f
                font = CYLFont(17f)
                textColor = Color.BLACK
            }
        }
        style.backgroundStyle = tagBackgroundStyle
        style.itemHeight = 36f
        style.interitemSpacing = 12f
        style.lineSpacing = 12f
        style.sectionInsets = CYLEdgeInsets(4f, 16f, 24f, 16f)
        applyHeaderLook(style)
        styleCustomizer?.invoke(style)
    }

    /**
     * Sets the defaults on `list`'s style (a copy, so the list's other values stay), and the refresh icon of its header
     * (`CYLSearchTagListHeader`; iOS `applyDefaultStyle(to:)`).
     */
    @JvmStatic
    fun applyDefaultStyle(list: CYLTagListView) {
        val style = (list.style ?: CYLMenuStyle.defaultStyle()).copy()
        applyDefaults(style)
        list.style = style
        CYLSearchTagListHeader.applyRefreshIcon(list)
    }

    /**
     * Sets the background of every tag of `list` by name (iOS `applyBackgroundStyle(named:to:)`): "liquidGlass" (any case)
     * is Liquid Glass, any other name, "" and "flat" too, is flat. Where the device draws no glass (below Android 12,
     * `CYLMenuStyle.resolvedBackgroundStyle`) the tags stay flat. The list's other style values stay; the refresh icon of its
     * header is set, as on iOS.
     */
    @JvmStatic
    fun applyBackgroundStyle(name: String, list: CYLTagListView) {
        val style = (list.style ?: CYLMenuStyle.defaultStyle()).copy()
        applyBackgroundStyle(name, style)
        list.style = style
        CYLSearchTagListHeader.applyRefreshIcon(list)
    }

    /** `applyBackgroundStyle(name, list)` on a style: the background style by name and, for glass, the glass fills. */
    @JvmStatic
    fun applyBackgroundStyle(name: String, style: CYLMenuStyle) {
        style.backgroundStyle = backgroundStyleNamed(name)
        if (style.backgroundStyle == CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass) {
            // A white fill under the glass hides it: clear the fill and border so the library's default frosted tint draws;
            // a selected tag keeps a visible tint (iOS).
            for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
                style.appearanceForState(state).apply {
                    backgroundColor = if (state == CYLControlState.SELECTED) GLASS_SELECTED_TINT_COLOR else GLASS_TINT_COLOR
                    borderWidth = 0f
                }
            }
        }
    }

    /** The background style for `name`: Liquid Glass for "liquidGlass" (any case), flat for any other name. */
    @JvmStatic
    fun backgroundStyleNamed(name: String): CYLTagBackgroundStyle =
        if (name.equals("liquidGlass", ignoreCase = true)) CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
        else CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat

    /**
     * Turns `style` (made by `CYLMenuStyle.gridStyleWithNumberOfItemsPerRow(columns)`) into the discover topics' look: 17 sp
     * medium titles, 36 dp rows 16 dp apart, a tag's own image at its own size, and the section header of
     * `applyDefaults`; then calls `styleCustomizer` (iOS `applyGrid(columns:to:)`).
     */
    @JvmStatic
    fun applyGrid(style: CYLMenuStyle) {
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            style.appearanceForState(state).font = CYLFont(17f, Typeface.create("sans-serif-medium", Typeface.NORMAL))
        }
        style.imageSize = CYLSize(0f, 0f)
        style.itemHeight = 36f
        style.lineSpacing = 16f
        style.sectionInsets = CYLEdgeInsets(4f, 16f, 16f, 16f)
        applyHeaderLook(style)
        styleCustomizer?.invoke(style)
    }

    private fun applyHeaderLook(style: CYLMenuStyle) {
        style.headerHeight = 44f
        style.headerFont = CYLFont(20f, Typeface.DEFAULT_BOLD)
        style.headerTextColor = Color.BLACK
        style.headerHorizontalInset = 16f
    }
}
