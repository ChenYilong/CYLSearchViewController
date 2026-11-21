package com.cyl.search.example.contacttags

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject
import java.text.Normalizer
import java.util.Locale
import java.util.UUID

/**
 * The example-level bundle of the contact tags demo (iOS `CYLContactTagsLocalization`): a verbatim copy of
 * `CYLSearchExample/CYLContactTags.bundle` in the assets, one `<language>.lproj` per language, each with
 * `CYLContactTags.strings` and `contact-tags.json`.
 */
object CYLContactTagsLocalization {
    private val tables = HashMap<String, Map<String, String>>()

    /**
     * The `.lproj` of the current language: zh-Hans, zh-Hant, ja or en.
     */
    fun language(): String {
        val locale = Locale.getDefault()
        return when (locale.language) {
            "ja" -> "ja"
            "zh" -> if (locale.script == "Hant" || locale.country in setOf("TW", "HK", "MO")) "zh-Hant" else "zh-Hans"
            else -> "en"
        }
    }

    /**
     * The asset path of `file` in the current language's folder.
     */
    fun path(file: String) = "CYLContactTags.bundle/${language()}.lproj/$file"

    /**
     * The strings of the current language (`CYLContactTags.strings`, parsed as on iOS).
     */
    fun table(context: Context): Map<String, String> = tables.getOrPut(language()) {
        val text = runCatching { context.assets.open(path("CYLContactTags.strings")).use { it.readBytes().toString(Charsets.UTF_8) } }.getOrDefault("")
        val entry = Regex("\"((?:[^\"\\\\]|\\\\.)*)\"\\s*=\\s*\"((?:[^\"\\\\]|\\\\.)*)\"\\s*;")
        entry.findAll(text.replace(Regex("/\\*.*?\\*/", RegexOption.DOT_MATCHES_ALL), "")).associate {
            it.groupValues[1].replace("\\\"", "\"") to it.groupValues[2].replace("\\\"", "\"").replace("\\n", "\n")
        }
    }
}

/**
 * A text of the contact tags demo (iOS `cylContactTagsText`): `contactTags.<key>`, formatted with `arguments` (`%@` and
 * `%ld` as on iOS).
 */
fun cylContactTagsText(context: Context, key: String, vararg arguments: Any): String {
    val fullKey = "contactTags.$key"
    val format = CYLContactTagsLocalization.table(context)[fullKey] ?: fullKey
    if (arguments.isEmpty()) return format
    return String.format(format.replace("%@", "%s").replace("%ld", "%d"), *arguments)
}

/**
 * A tag (iOS `CYLContactTag`): its id is its primary key (a reorder or a rename keeps it, and contacts are bound to it);
 * its title is what the lists show.
 */
data class CYLContactTag(val id: String, val title: String)

/**
 * A demo contact (iOS `CYLContactTagData.Contact`): a name and the ids of its tags.
 */
data class CYLContactTagContact(val name: String, val tags: List<String>)

/**
 * The contents of contact-tags.json (iOS `CYLContactTagData`): the demo tags (id and title), the ids of the recently
 * used ones and of the tags the remark screen starts with, and the contacts.
 */
data class CYLContactTagData(
    val version: Int,
    val tags: List<CYLContactTag>,
    val recentTags: List<String>,
    val selectedTags: List<String>,
    val contacts: List<CYLContactTagContact>,
) {
    companion object {
        fun decode(text: String): CYLContactTagData {
            val json = JSONObject(text)
            fun strings(array: JSONArray?) = array?.let { a -> (0 until a.length()).map { a.getString(it) } } ?: emptyList()
            val tags = json.optJSONArray("tags")?.let { a -> (0 until a.length()).map { a.getJSONObject(it).let { t -> CYLContactTag(t.getString("id"), t.getString("title")) } } }
            val contacts = json.optJSONArray("contacts")?.let { a ->
                (0 until a.length()).map { a.getJSONObject(it).let { c -> CYLContactTagContact(c.getString("name"), strings(c.optJSONArray("tags"))) } }
            }
            return CYLContactTagData(json.optInt("version"), tags.orEmpty(), strings(json.optJSONArray("recentTags")),
                strings(json.optJSONArray("selectedTags")), contacts.orEmpty())
        }

        /**
         * contact-tags.json of the current language.
         */
        fun bundled(context: Context): CYLContactTagData =
            decode(context.assets.open(CYLContactTagsLocalization.path("contact-tags.json")).use { it.readBytes().toString(Charsets.UTF_8) })
    }
}

/**
 * Sections of tags as JSON (`{"mine": [{"id", "title"}], "recent": [...]}`): cache A and the server's cache B keep ids
 * with the titles, as iOS's `CYLTagListCacheItem`. (CollectionViewClassifyMenu's Android `CYLTagListStore` keeps titles
 * only, so the demo stores its id items itself until that cache has items.)
 */
object CYLContactTagSections {
    fun encode(sections: Map<String, List<CYLContactTag>>): String = JSONObject().apply {
        for ((key, items) in sections) put(key, JSONArray().apply { items.forEach { put(JSONObject().put("id", it.id).put("title", it.title)) } })
    }.toString()

    fun decode(text: String?): Map<String, List<CYLContactTag>> {
        if (text.isNullOrEmpty()) return emptyMap()
        val json = runCatching { JSONObject(text) }.getOrNull() ?: return emptyMap()
        return json.keys().asSequence().associateWith { key ->
            val array = json.getJSONArray(key)
            (0 until array.length()).map { array.getJSONObject(it).let { t -> CYLContactTag(t.getString("id"), t.getString("title")) } }
        }
    }
}

/**
 * The user's tags (iOS `CYLContactTagStore`), keyed by id: every tag in the user's order, and the recently used ones.
 * Changes are saved to `cache` (cache A) with their ids.
 */
class CYLContactTagStore(tags: List<CYLContactTag>, recentIDs: List<String> = emptyList(), val recentLimit: Int = 8) {
    /** Every tag, in the user's order ("My Tags"). */
    var tags: List<CYLContactTag> = tags.distinctBy { it.id }
        private set

    /** The ids of the recently used tags, the most recent first ("Recent"). */
    var recentIDs: List<String> = recentIDs.filter { id -> this.tags.any { it.id == id } }.distinct().take(recentLimit)
        private set

    /** The demo contacts and the ids of their tags. */
    var contacts: List<CYLContactTagContact> = emptyList()

    /** Where the changes are saved (cache A); null keeps them in memory. */
    var cache: SharedPreferences? = null

    companion object {
        /** The cache keys of "My Tags" and "Recent". */
        const val MINE_CACHE_KEY = "mine"
        const val RECENT_CACHE_KEY = "recent"

        /** The name of the demo's cache A. */
        const val CACHE_NAME = "CYLContactTags"
        private const val SECTIONS_KEY = "sections"

        /** A tag name as stored: without surrounding spaces and new lines. */
        fun normalizedName(name: String) = name.trim()

        /**
         * The demo tags of the current language (contact-tags.json), with cache A's saved order, names and contents on
         * top.
         */
        fun bundled(context: Context): CYLContactTagStore {
            val data = runCatching { CYLContactTagData.bundled(context) }.getOrNull() ?: return CYLContactTagStore(emptyList())
            val cache = context.getSharedPreferences(CACHE_NAME, Context.MODE_PRIVATE)
            val saved = CYLContactTagSections.decode(cache.getString(SECTIONS_KEY, null))
            val store = CYLContactTagStore(saved[MINE_CACHE_KEY] ?: data.tags, saved[RECENT_CACHE_KEY]?.map { it.id } ?: data.recentTags)
            store.contacts = data.contacts
            store.cache = cache
            return store
        }

        /** Forgets the saved edits (cache A). */
        fun resetCache(context: Context) {
            context.getSharedPreferences(CACHE_NAME, Context.MODE_PRIVATE).edit().clear().apply()
        }
    }

    fun tag(id: String): CYLContactTag? = tags.firstOrNull { it.id == id }
    fun title(id: String): String? = tag(id)?.title
    fun id(ofTitle: String): String? = tags.firstOrNull { it.title == ofTitle }?.id
    val tagIDs: List<String> get() = tags.map { it.id }
    fun contains(id: String) = tag(id) != null

    /** The contacts that have the tag with `id` (bound to the id, so a renamed tag keeps them). */
    fun contacts(withTagID: String) = contacts.filter { withTagID in it.tags }

    /** "My Tags" and "Recent" with their ids, for cache A and the server. */
    val cacheSections: Map<String, List<CYLContactTag>>
        get() = mapOf(MINE_CACHE_KEY to tags, RECENT_CACHE_KEY to recentIDs.mapNotNull(::tag))

    /** Saves "My Tags" and "Recent" to cache A. */
    fun save() {
        cache?.edit()?.putString(SECTIONS_KEY, CYLContactTagSections.encode(cacheSections))?.apply()
    }

    /**
     * The ids of the tags whose titles contain `query`, ignoring case, width and accents; those starting with it first.
     */
    fun tagsMatching(query: String): List<String> {
        val q = normalizedName(query)
        if (q.isEmpty()) return emptyList()
        fun fold(text: String) = Normalizer.normalize(text, Normalizer.Form.NFKD).replace(Regex("\\p{M}"), "").lowercase()
        val folded = fold(q)
        val matches = tags.filter { fold(it.title).contains(folded) }
        val prefixed = matches.filter { fold(it.title).startsWith(folded) }
        return (prefixed + matches.filter { it !in prefixed }).map { it.id }
    }

    /** Whether "+ New tag: <name>" is offered: a title that no tag has yet. */
    fun canCreate(name: String) = normalizedName(name).let { it.isNotEmpty() && id(it) == null }

    /** Adds a tag (a new id) at the end of "My Tags" and returns its id; an existing title returns its id. */
    fun createTag(name: String): String? {
        val title = normalizedName(name)
        if (title.isEmpty()) return null
        id(title)?.let { return it }
        val tag = CYLContactTag("u-" + UUID.randomUUID().toString().take(8), title)
        tags = tags + tag
        save()
        return tag.id
    }

    /** Renames the tag with `id` (its id, place and contacts stay); an empty title does nothing. */
    fun renameTag(id: String, title: String) {
        val name = normalizedName(title)
        if (name.isEmpty() || !contains(id)) return
        tags = tags.map { if (it.id == id) it.copy(title = name) else it }
        save()
    }

    /** Moves the tag at `from` to `to` in "My Tags" (a drag in editing mode). */
    fun moveTag(from: Int, to: Int) {
        if (from !in tags.indices || to !in tags.indices || from == to) return
        tags = tags.toMutableList().apply { add(to, removeAt(from)) }
        save()
    }

    /** Takes sections downloaded from the server; returns whether anything changed. */
    fun apply(sections: Map<String, List<CYLContactTag>>): Boolean {
        var changed = false
        sections[MINE_CACHE_KEY]?.distinctBy { it.id }?.let { downloaded ->
            if (downloaded != tags) {
                tags = downloaded
                recentIDs = recentIDs.filter(::contains)
                changed = true
            }
        }
        sections[RECENT_CACHE_KEY]?.map { it.id }?.filter(::contains)?.let { recent ->
            if (recent != recentIDs) {
                recentIDs = recent.take(recentLimit)
                changed = true
            }
        }
        if (changed) save()
        return changed
    }

    /** Empties "Recent". */
    fun clearRecent() {
        recentIDs = emptyList()
        save()
    }

    /** Removes the tag with `id` from "My Tags" and "Recent". */
    fun deleteTag(id: String) {
        tags = tags.filter { it.id != id }
        recentIDs = recentIDs - id
        save()
    }

    /** Moves the `used` ids to the front of "Recent" (when the editor is confirmed). */
    fun markUsed(used: List<String>) {
        val known = used.filter(::contains)
        recentIDs = (known + recentIDs.filter { it !in known }).take(recentLimit)
        save()
    }
}
