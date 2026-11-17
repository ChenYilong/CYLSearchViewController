package com.cyl.search

import android.content.ContentValues
import android.content.Context
import android.content.res.Configuration
import android.content.res.Resources
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.graphics.drawable.Drawable
import android.util.Log
import androidx.core.content.ContextCompat
import java.io.File
import java.util.Locale
import org.json.JSONArray

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

/**
 * Where the suggestion cache keeps the submitted queries (iOS `CYLSearchSuggestionCachePolicy`). More policies can be
 * added later; an app can also plug in its own store through [CYLSearchSuggestionCache].
 */
enum class CYLSearchSuggestionCachePolicy {
    /**
     * No cache: the suggestion list shows only `suggestions`.
     */
    None,

    /**
     * A SQLite database in the app's database folder (the local cache, the default).
     */
    Database,

    /**
     * `SharedPreferences` (iOS `NSUserDefaults`).
     */
    UserDefaults,

    /**
     * A JSON file in the app's files folder (the sandbox).
     */
    SandboxFile,
}

/**
 * A store of submitted queries, newest first (iOS `CYLSearchSuggestionCache`).
 */
interface CYLSearchSuggestionCache {
    /**
     * The cached queries, newest first.
     */
    fun cachedQueries(): List<String>

    /**
     * Adds `query` at the front; an equal query already cached moves to the front instead of being repeated.
     */
    fun addQuery(query: String)

    /**
     * Removes `query`.
     */
    fun removeQuery(query: String)

    /**
     * Removes every cached query.
     */
    fun removeAllQueries()
}

/**
 * The built-in caches: a database, `SharedPreferences` or a file, behind one class (the private default store; iOS
 * `CYLSearchView.suggestionCachePolicy` and `suggestionCacheName` create it).
 */
internal class CYLSearchSuggestionStore(context: Context, val policy: CYLSearchSuggestionCachePolicy, name: String) : CYLSearchSuggestionCache {

    /**
     * Separates the caches of different search screens: the database key, the preferences key or the file name.
     */
    val name: String = name.ifEmpty { "CYLSearchView" }

    /**
     * The largest number of queries kept; the oldest go first. 20 by default.
     */
    var maximumCount = 20

    private val appContext = context.applicationContext
    private var memory: List<String> = emptyList()
    private val helper by lazy { Helper(appContext) }

    override fun cachedQueries(): List<String> = when (policy) {
        CYLSearchSuggestionCachePolicy.None -> emptyList()
        CYLSearchSuggestionCachePolicy.Database -> databaseQueries()
        CYLSearchSuggestionCachePolicy.UserDefaults ->
            decode(appContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).getString(name, null))
        CYLSearchSuggestionCachePolicy.SandboxFile -> decode(file().takeIf { it.exists() }?.readText())
    }

    override fun addQuery(query: String) {
        val trimmed = query.trim()
        if (trimmed.isEmpty()) {
            return
        }
        if (policy == CYLSearchSuggestionCachePolicy.Database) {
            val db = helper.writableDatabase
            db.insertWithOnConflict(TABLE, null, ContentValues().apply {
                put("cache", name)
                put("query", trimmed)
                put("time", nextTime())
            }, SQLiteDatabase.CONFLICT_REPLACE)
            db.execSQL(
                "DELETE FROM $TABLE WHERE cache = ? AND query NOT IN (SELECT query FROM $TABLE WHERE cache = ? ORDER BY time DESC LIMIT ${maxOf(1, maximumCount)})",
                arrayOf(name, name),
            )
            return
        }
        save((listOf(trimmed) + cachedQueries().filter { it != trimmed }).take(maxOf(1, maximumCount)))
    }

    override fun removeQuery(query: String) {
        if (policy == CYLSearchSuggestionCachePolicy.Database) {
            helper.writableDatabase.delete(TABLE, "cache = ? AND query = ?", arrayOf(name, query))
            return
        }
        save(cachedQueries().filter { it != query })
    }

    override fun removeAllQueries() {
        if (policy == CYLSearchSuggestionCachePolicy.Database) {
            helper.writableDatabase.delete(TABLE, "cache = ?", arrayOf(name))
            return
        }
        save(emptyList())
    }

    private fun save(queries: List<String>) {
        val json = JSONArray(queries).toString()
        when (policy) {
            CYLSearchSuggestionCachePolicy.UserDefaults ->
                appContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).edit().putString(name, json).apply()
            CYLSearchSuggestionCachePolicy.SandboxFile -> file().apply { parentFile?.mkdirs() }.writeText(json)
            else -> memory = queries
        }
    }

    private fun file() = File(File(appContext.filesDir, "CYLSearchViewController"),
        "suggestions-" + name.map { if (it.isLetterOrDigit()) it else '_' }.joinToString("") + ".json")

    private fun databaseQueries(): List<String> =
        helper.readableDatabase.query(TABLE, arrayOf("query"), "cache = ?", arrayOf(name), null, null, "time DESC").use { cursor ->
            List(cursor.count) { cursor.moveToNext(); cursor.getString(0) }
        }

    private fun decode(text: String?): List<String> = try {
        text?.let { JSONArray(it) }?.let { array -> List(array.length()) { array.getString(it) } } ?: emptyList()
    } catch (_: org.json.JSONException) {
        emptyList()
    }

    private class Helper(context: Context) : SQLiteOpenHelper(context, "cyl_search_suggestions.db", null, 1) {
        override fun onCreate(db: SQLiteDatabase) {
            db.execSQL("CREATE TABLE IF NOT EXISTS $TABLE (cache TEXT NOT NULL, query TEXT NOT NULL, time REAL NOT NULL, PRIMARY KEY (cache, query))")
        }

        override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) = Unit
    }

    companion object {
        private const val TABLE = "queries"
        private const val PREFERENCES = "CYLSearchSuggestionCache"
        private var lastTime = 0.0

        /**
         * Milliseconds since 1970, strictly increasing, so queries added in the same millisecond keep their order.
         */
        private fun nextTime(): Double = synchronized(this) {
            lastTime = maxOf(System.currentTimeMillis().toDouble(), lastTime + 1)
            lastTime
        }

        /**
         * The store for `policy` and `name`; null for [CYLSearchSuggestionCachePolicy.None]
         * (iOS `+cacheWithPolicy:name:`).
         */
        fun cacheWithPolicy(context: Context, policy: CYLSearchSuggestionCachePolicy, name: String): CYLSearchSuggestionStore? =
            if (policy == CYLSearchSuggestionCachePolicy.None) null else CYLSearchSuggestionStore(context, policy, name)
    }
}
