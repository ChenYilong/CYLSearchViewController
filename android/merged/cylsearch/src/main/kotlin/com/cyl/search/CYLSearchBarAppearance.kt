// Ported from QMUI_iOS (Tencent, MIT): the style values QMUI's qmui_styledAsQMUISearchBar took from its configuration
// table, merged with the defaults of the legacy iOS CYLSearchBar. See META-INF/cylsearch/NOTICE.
package com.cyl.search

import android.content.Context
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.util.TypedValue
import androidx.core.content.ContextCompat

/**
 * The merged default style of a `CYLSearchBarView` (iOS `CYLSearchBarAppearance`): colors, placeholder and Cancel
 * texts, icons and the field's background. Set it as `CYLSearchBarView.appearanceStyle`; a null value leaves the
 * bar's own default for that property.
 */
class CYLSearchBarAppearance {

    /**
     * The typeface of the text, the placeholder and Cancel.
     */
    var font: Typeface? = null

    /**
     * The text size in sp.
     */
    var fontSize: Float? = null

    /**
     * The text color.
     */
    var textColor: Int? = null

    /**
     * The placeholder color.
     */
    var placeholderColor: Int? = null

    /**
     * The placeholder text.
     */
    var placeholder: String? = null

    /**
     * The Cancel button's title.
     */
    var cancelTitle: String? = null

    /**
     * The color of Cancel and of the cursor.
     */
    var tintColor: Int? = null

    /**
     * The magnifier.
     */
    var searchIcon: Drawable? = null

    /**
     * The clear button's icon.
     */
    var clearIcon: Drawable? = null

    /**
     * The field's background color.
     */
    var fieldBackgroundColor: Int? = null

    /**
     * The field's border color.
     */
    var fieldBorderColor: Int? = null

    /**
     * The field's corner radius in dp; negative makes a capsule.
     */
    var fieldCornerRadius: Float = -1f

    /**
     * The background image of the text field (QMUI `SearchBarTextFieldBackgroundImage`); wins over
     * `fieldBackgroundColor`. Build one from a color with `CYLSearchBarView.textFieldBackgroundImage`.
     */
    var textFieldBackgroundImage: Drawable? = null

    /**
     * The background image of the whole bar (QMUI `SearchBarBackgroundImage`); wins over `barBackgroundColor` and
     * `barBorderColor`. Build one from colors with `CYLSearchBarView.backgroundImage`.
     */
    var barBackgroundImage: Drawable? = null

    /**
     * The color behind the whole bar; null leaves it transparent.
     */
    var barBackgroundColor: Int? = null

    /**
     * The color of the bar's bottom border, one pixel wide; null draws none.
     */
    var barBorderColor: Int? = null

    /**
     * Whether a bar without a background image, color or border draws no background at all (the bar stays transparent,
     * as the legacy iOS CYLSearchBar did). False gives it the theme's window background. True by default.
     */
    var hidesBarBackground: Boolean = true

    /**
     * A copy that can change without changing this one (iOS `copy`).
     */
    fun copy(): CYLSearchBarAppearance = CYLSearchBarAppearance().also {
        it.font = font
        it.fontSize = fontSize
        it.textColor = textColor
        it.placeholderColor = placeholderColor
        it.placeholder = placeholder
        it.cancelTitle = cancelTitle
        it.tintColor = tintColor
        it.searchIcon = searchIcon
        it.clearIcon = clearIcon
        it.fieldBackgroundColor = fieldBackgroundColor
        it.fieldBorderColor = fieldBorderColor
        it.fieldCornerRadius = fieldCornerRadius
        it.textFieldBackgroundImage = textFieldBackgroundImage
        it.barBackgroundImage = barBackgroundImage
        it.barBackgroundColor = barBackgroundColor
        it.barBorderColor = barBorderColor
        it.hidesBarBackground = hidesBarBackground
    }

    /**
     * Sets every value that is not null on `bar` (what `CYLSearchBarView.appearanceStyle` calls).
     */
    fun applyTo(bar: CYLSearchBarView) {
        font?.let { bar.font = it }
        fontSize?.let { bar.fontSize = it }
        textColor?.let { bar.textColor = it }
        placeholderColor?.let { bar.placeholderColor = it }
        placeholder?.let { bar.placeholder = it }
        cancelTitle?.let { bar.cancelButtonTitle = it }
        tintColor?.let { bar.tintColor = it }
        searchIcon?.let { bar.searchIcon = it }
        clearIcon?.let { bar.clearImage = it }
        fieldBackgroundColor?.let { bar.fieldBackgroundColor = it }
        fieldBorderColor?.let { bar.fieldBorderColor = it }
        bar.fieldCornerRadius = fieldCornerRadius
        textFieldBackgroundImage?.let { bar.fieldBackgroundImage = it }
        val image = barBackgroundImage
        when {
            image != null -> bar.background = image
            barBackgroundColor != null || barBorderColor != null ->
                bar.background = CYLSearchBarView.backgroundImage(barBackgroundColor, barBorderColor)
            !hidesBarBackground -> bar.setBackgroundColor(windowBackgroundColor(bar.context))
        }
    }

    private fun windowBackgroundColor(context: Context): Int {
        val value = TypedValue()
        context.theme.resolveAttribute(android.R.attr.colorBackground, value, true)
        return if (value.resourceId != 0) ContextCompat.getColor(context, value.resourceId) else value.data
    }

    companion object {
        /**
         * The default style for the night mode of `context`: the legacy field RGB(187, 186, 193), in the dark RGB(58,
         * 58, 60), tint RGB(0, 104, 248), the localized placeholder and Cancel (iOS `CYLSearchBarAppearance.default`).
         */
        @JvmStatic
        fun defaultAppearance(context: Context): CYLSearchBarAppearance {
            val dark = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
            return CYLSearchBarAppearance().also {
                it.placeholder = CYLSearchResources.localizedString(context, "search.field")
                it.cancelTitle = CYLSearchResources.localizedString(context, "search.cancel")
                it.tintColor = Color.rgb(0, 104, 248)
                it.fieldBackgroundColor = if (dark) Color.rgb(58, 58, 60) else Color.rgb(187, 186, 193)
            }
        }
    }
}
