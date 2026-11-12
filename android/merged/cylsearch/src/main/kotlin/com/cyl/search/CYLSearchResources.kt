package com.cyl.search

import android.content.Context
import android.content.res.Configuration
import android.content.res.Resources
import android.graphics.drawable.Drawable
import android.util.Log
import androidx.core.content.ContextCompat
import java.util.Locale

/**
 * Images and localized strings of this library (iOS `CYLSearchResources`, the `CYLSearchViewController.bundle`).
 * The iOS bundle is imported by `scripts/import-ios-resources.py`: `CYLSearchNoResults` becomes the drawable
 * `cyl_search_no_results`, the key `search.cancel` the string `cyl_search_cancel`.
 */
object CYLSearchResources {

    private const val TAG = "CYLSearchViewController"

    /**
     * The resources that hold the images and strings (iOS `resourceBundle`): the app's resources, which include this
     * library's.
     */
    @JvmStatic
    fun resourceBundle(context: Context): Resources = context.resources

    /**
     * An image of this library by its iOS name ("CYLSearchNoResults"), or null (logged) when it is missing.
     */
    @JvmStatic
    fun imageNamed(context: Context, name: String): Drawable? {
        val id = context.resources.getIdentifier(drawableName(name), "drawable", context.packageName)
        val image = if (id != 0) ContextCompat.getDrawable(context, id) else null
        if (image == null) {
            Log.w(TAG, "resource image '$name' not found.")
        }
        return image
    }

    /**
     * The text of `key` in the language the app shows, English when the key has no translation, or the key itself
     * (logged) when it is missing everywhere.
     */
    @JvmStatic
    fun localizedString(context: Context, key: String): String = localizedString(context, key, null)

    /**
     * The text of `key` in `language` (for example "zh-Hans"), or in the app's language when `language` is null or
     * empty.
     */
    @JvmStatic
    fun localizedString(context: Context, key: String, language: String?): String {
        val id = context.resources.getIdentifier("cyl_" + key.replace('.', '_'), "string", context.packageName)
        if (id == 0) {
            Log.w(TAG, "localization key '$key' not found.")
            return key
        }
        if (language.isNullOrEmpty()) {
            return context.getString(id)
        }
        val configuration = Configuration(context.resources.configuration)
        configuration.setLocale(Locale.forLanguageTag(language))
        return context.createConfigurationContext(configuration).getString(id)
    }

    internal fun drawableName(name: String): String =
        "cyl_search_" + name.removePrefix("CYLSearch").replace(Regex("(?<!^)(?=[A-Z])"), "_").lowercase(Locale.ROOT)
}
