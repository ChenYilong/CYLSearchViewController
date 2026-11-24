package com.cyl.search

import android.graphics.Color
import android.graphics.Typeface
import com.cyl.animateditem.CYLAnimatedItemCornerRadiusCapsule
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagBackgroundStyle

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
     * half the height). The library's constant (`CYLAnimatedItemCornerRadiusCapsule`, CYLTabBarController's cylanimateditem):
     * pass it by name, never the literal 1000. 0 is square corners; no other
     * value has a special meaning.
     */
    const val CAPSULE_CORNER_RADIUS: Float = CYLAnimatedItemCornerRadiusCapsule

    /**
     * The corner radius of every tag, in dp. The default `CAPSULE_CORNER_RADIUS` is a capsule, as in the iOS example's
     * recent searches; 0 is square corners; another value is a rounded rectangle.
     */
    @JvmStatic
    var tagCornerRadius: Float = CAPSULE_CORNER_RADIUS

    /**
     * The background of every tag: flat (the default, a solid color) or Liquid Glass where the platform draws it (else flat).
     * Set on the style by `applyDefaults` and `applyGrid`, as iOS `tagBackgroundStyle` does.
     */
    @JvmStatic
    var backgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat

    /**
     * Called with the style after the defaults are set, to change any value of it. null by default.
     */
    @JvmStatic
    var styleCustomizer: ((CYLMenuStyle) -> Unit)? = null

    /**
     * Sets the defaults on `style`: white tags with a 1 dp light border and `tagCornerRadius`, 17 sp text, 36 dp high, 12 dp
     * apart, a 16 dp section inset and a bold 20 sp section header, then calls `styleCustomizer`. Values the defaults do not
     * name (for example a transparent background) stay as they are.
     */
    @JvmStatic
    fun applyDefaults(style: CYLMenuStyle) {
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            style.appearanceForState(state).apply {
                backgroundColor = Color.WHITE
                borderColor = Color.argb(40, 0, 0, 0)
                borderWidth = 1f
                cornerRadius = tagCornerRadius
                margin = 14f
                font = CYLFont(17f)
                textColor = Color.BLACK
            }
        }
        applyBackgroundStyle(if (backgroundStyle == CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass) "liquidGlass" else "flat", style)
        style.itemHeight = 36f
        style.interitemSpacing = 12f
        style.lineSpacing = 12f
        style.sectionInsets = CYLEdgeInsets(4f, 16f, 24f, 16f)
        applyHeaderLook(style)
        styleCustomizer?.invoke(style)
    }

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
        applyBackgroundStyle(if (backgroundStyle == CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass) "liquidGlass" else "flat", style)
        style.itemHeight = 36f
        style.lineSpacing = 16f
        style.sectionInsets = CYLEdgeInsets(4f, 16f, 16f, 16f)
        applyHeaderLook(style)
        styleCustomizer?.invoke(style)
    }

    /**
     * [EN] Sets the tag background of `style` by name, for the bridges (React Native / Flutter `backgroundStyle`): "liquidGlass"
     *      (any case) is Liquid Glass, "flat", "" or any other name is flat. Call it after `applyDefaults` / `applyGrid`
     *      (iOS `applyBackgroundStyle(named:to:)`). Glass is the background itself: a glass tag gets no fill and no border of
     *      its own, so the fill and border of every state are cleared; flat keeps what the defaults set.
     * [CN] 按名称设置标签背景（供 React Native / Flutter 桥接使用）："liquidGlass"（不分大小写）为液态玻璃，"flat"、空串或其他名称为
     *      纯色。须在 `applyDefaults` / `applyGrid` 之后调用。玻璃本身就是背景：玻璃标签不设自己的填充与边框，故清除各状态的填充与边框。
     */
    @JvmStatic
    fun applyBackgroundStyle(name: String?, style: CYLMenuStyle) {
        val glass = name != null && name.equals("liquidGlass", ignoreCase = true)
        style.backgroundStyle = if (glass) CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass else CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat
        if (!glass) return
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            style.appearanceForState(state).apply {
                backgroundColor = Color.TRANSPARENT
                borderColor = Color.TRANSPARENT
                borderWidth = 0f
            }
        }
    }

    private fun applyHeaderLook(style: CYLMenuStyle) {
        style.headerHeight = 44f
        style.headerFont = CYLFont(20f, Typeface.DEFAULT_BOLD)
        style.headerTextColor = Color.BLACK
        style.headerHorizontalInset = 16f
    }
}
