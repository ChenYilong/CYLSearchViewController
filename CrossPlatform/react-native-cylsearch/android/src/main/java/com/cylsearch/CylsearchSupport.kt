package com.cylsearch

import android.graphics.Color
import android.graphics.Typeface
import android.os.Build
import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.search.CYLSearchSuggestionCachePolicy
import com.cyl.search.CYLSearchSuggestionCell
import com.cyl.search.CYLSearchView
import com.cyl.search.CYLSearchViewDataSource
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

/**
 * The strings of a JavaScript array.
 */
internal fun ReadableArray?.cylStrings(): List<String> = (0 until (this?.size() ?: 0)).map { this?.getString(it).orEmpty() }

/**
 * The numbers of a JavaScript array.
 */
internal fun ReadableArray?.cylDoubles(): List<Double> = (0 until (this?.size() ?: 0)).map { this?.getDouble(it) ?: 0.0 }

/**
 * The fold control for "none", "inline", "bottom", "topTrailing" or "topLeading" and "icon", "title" or "iconAndTitle";
 * an inline icon by default.
 */
internal fun cylFoldControl(position: String?, content: String?) = CYLMenuFoldControl().apply {
  this.position = when (position) {
    "none" -> CYLMenuFoldControlPosition.NONE
    "bottom", "footer" -> CYLMenuFoldControlPosition.FOOTER
    "topTrailing", "headerTrailing" -> CYLMenuFoldControlPosition.HEADER_TRAILING
    "topLeading", "headerLeading" -> CYLMenuFoldControlPosition.HEADER_LEADING
    else -> CYLMenuFoldControlPosition.TAIL
  }
  this.content = when (content) {
    "iconAndTitle" -> CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle
    "title" -> CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle
    else -> CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon
  }
}

/**
 * A direct event with a name ("topTextChange", ...) and its data.
 */
internal class CylsearchEvent(surfaceId: Int, viewId: Int, private val name: String, private val data: WritableMap) :
  Event<CylsearchEvent>(surfaceId, viewId) {
  override fun getEventName() = name
  override fun getEventData(): WritableMap = data
}

/**
 * Builds the data of an event.
 */
internal fun cylEventData(vararg pairs: Pair<String, Any>): WritableMap = Arguments.createMap().apply {
  for ((key, value) in pairs) {
    when (value) {
      is String -> putString(key, value)
      is Int -> putInt(key, value)
      is Double -> putDouble(key, value)
      is Boolean -> putBoolean(key, value)
    }
  }
}

/**
 * A color of "#RRGGBB" or "#AARRGGBB"; null for an empty or unreadable value.
 */
internal fun cylParseColor(value: String?): Int? = value?.takeIf { it.isNotEmpty() }?.let { runCatching { Color.parseColor(it) }.getOrNull() }

/**
 * The core's history of a search view: `policyName` ("none", "userDefaults", "database" or "sandboxFile") and `name`; set
 * only when one of them changed (`defaultPolicy` for an unknown name), so the cache is not rebuilt on every prop update.
 */
internal fun CYLSearchView.applySuggestionCache(
  policyName: String?,
  name: String?,
  defaultName: String,
  defaultPolicy: CYLSearchSuggestionCachePolicy,
) {
  val policy = when (policyName) {
    "none" -> CYLSearchSuggestionCachePolicy.None
    "userDefaults" -> CYLSearchSuggestionCachePolicy.UserDefaults
    "sandboxFile" -> CYLSearchSuggestionCachePolicy.SandboxFile
    "database" -> CYLSearchSuggestionCachePolicy.Database
    else -> defaultPolicy
  }
  val cacheName = name?.takeIf { it.isNotEmpty() } ?: defaultName
  if (policy != suggestionCachePolicy || cacheName != suggestionCacheName) {
    suggestionCacheName = cacheName
    suggestionCachePolicy = policy
  }
}

/**
 * The results data source of both components (`CYLSearchView` and `CYLSearchListView`): the `results` of JavaScript and the
 * rows' text; the match highlight is the core's option (`highlightsResultMatches`, `resultMatchHighlightColor`).
 * `resultsQuery` null lists the results for every text; a text lists only the results that belong to it (a late answer never
 * fills the list of a newer text).
 */
internal class CylsearchResults : CYLSearchViewDataSource {
  var results: List<String> = emptyList()
  var resultsQuery: String? = null

  override fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any> =
    if (resultsQuery == null || query == resultsQuery) results else emptyList()

  override fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any) {
    cell.textLabel.text = result.toString()
    cell.textLabel.setTypeface(null, Typeface.NORMAL)
  }
}

/**
 * Cancel's title in `font` ({"size":17,"weight":"semibold"}): the weight as the core's `cancelButtonFont` typeface and the
 * size as its `cancelButtonFontSize`. Null or empty JSON keeps the bar's font.
 */
internal fun com.cyl.search.CYLSearchBarView.applyCancelButtonFont(json: String?) {
  val spec = json?.takeIf { it.isNotEmpty() }?.let { runCatching { org.json.JSONObject(it) }.getOrNull() }
  if (spec == null) {
    cancelButtonFont = null
    cancelButtonFontSize = null
    return
  }
  val weight = when (spec.optString("weight")) {
    "medium" -> 500
    "semibold" -> 600
    "bold" -> 700
    else -> 400
  }
  cancelButtonFont = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) Typeface.create(Typeface.DEFAULT, weight, false)
  else Typeface.defaultFromStyle(if (weight >= 600) Typeface.BOLD else Typeface.NORMAL)
  cancelButtonFontSize = if (spec.has("size")) spec.optDouble("size").toFloat() else null
}

/**
 * Loads the image of `location` and reports it on the main thread (null when it cannot be read): a URL (the Metro server in
 * debug builds), a file URI, or a drawable resource name (what a release build resolves a required asset to). A "@3x" / "@2x"
 * suffix gives the bitmap the matching density so the image shows at its point size.
 */
fun cylLoadImage(context: android.content.Context, location: String, onLoaded: (android.graphics.drawable.Drawable?) -> Unit) {
  val main = android.os.Handler(android.os.Looper.getMainLooper())
  fun finish(drawable: android.graphics.drawable.Drawable?) { main.post { onLoaded(drawable) } }
  fun bitmapDrawable(bitmap: android.graphics.Bitmap?): android.graphics.drawable.Drawable? {
    if (bitmap == null) return null
    when {
      location.contains("@3x") -> bitmap.density = 480
      location.contains("@2x") -> bitmap.density = 320
    }
    return android.graphics.drawable.BitmapDrawable(context.resources, bitmap)
  }
  when {
    location.startsWith("http") -> Thread {
      val bitmap = try {
        java.net.URL(location).openStream().use { android.graphics.BitmapFactory.decodeStream(it) }
      } catch (error: Exception) {
        null
      }
      finish(bitmapDrawable(bitmap))
    }.start()
    location.startsWith("file://") -> finish(bitmapDrawable(android.graphics.BitmapFactory.decodeFile(android.net.Uri.parse(location).path)))
    else -> {
      val id = context.resources.getIdentifier(location.substringBeforeLast('.'), "drawable", context.packageName)
      finish(if (id != 0) androidx.core.content.ContextCompat.getDrawable(context, id) else bitmapDrawable(android.graphics.BitmapFactory.decodeFile(location)))
    }
  }
}
