package com.cyl.search.example.contacttags

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.ViewGroup
import com.cyl.placeholder.CYLPlaceholderHUD
import java.util.UUID

/**
 * The contact tags demo's simulated server (iOS `CYLContactTagServer`). The local cache, A, is the store's
 * (`CYLContactTagStore.cache`); the server's data, B, is a second file that stands for the server shared by the user's
 * devices. Every request waits `latencySeconds` (5 s) and shows CYLTableViewPlaceHolder's HUD (`CYLPlaceholderHUD`):
 * - uploading copies A's sections to B ("Uploading鈥?, then "Upload finished");
 * - downloading reads B as network data ("Downloading鈥?);
 * - "Sync" simulates an edit on another device (a random new tag, the first two tags swapped, written to B), then
 *   downloads it ("Syncing from other devices鈥?).
 *
 * @param container where the HUD shows (the page).
 */
class CYLContactTagServer(private val context: Context, private val container: () -> ViewGroup?) {

    companion object {
        /** The name of cache B. */
        const val STORAGE_NAME = "CYLContactTagsServer"
        private const val SECTIONS_KEY = "sections"

        /**
         * How long every request takes, in seconds: the `CYLContactTagsServerLatency` intent extra (iOS launch argument), else 5.
         */
        var latencySeconds = 5.0

        /** Forgets B (the demo's reset). */
        fun reset(context: Context) {
            context.getSharedPreferences(STORAGE_NAME, Context.MODE_PRIVATE).edit().clear().apply()
        }
    }

    private val storage = context.getSharedPreferences(STORAGE_NAME, Context.MODE_PRIVATE)
    private val handler = Handler(Looper.getMainLooper())

    /** The HUD status of the next download ("Downloading鈥? by default; "Syncing from other devices鈥? for a sync). */
    private var nextFetchStatus: String? = null

    private fun stored(): Map<String, List<CYLContactTag>> = CYLContactTagSections.decode(storage.getString(SECTIONS_KEY, null))

    private fun store(sections: Map<String, List<CYLContactTag>>) {
        storage.edit().putString(SECTIONS_KEY, CYLContactTagSections.encode(stored() + sections)).apply()
    }

    private fun hud(): CYLPlaceholderHUD? = container()?.let { CYLPlaceholderHUD.sharedHUD(it) }

    private val latencyMillis get() = (latencySeconds * 1000).toLong()

    /**
     * Downloads B's sections with `keys` after the latency, with a HUD; a key B does not have is left out.
     */
    fun fetch(keys: List<String>, completion: (Map<String, List<CYLContactTag>>) -> Unit) {
        val status = nextFetchStatus ?: cylContactTagsText(context, "downloading")
        val finished = cylContactTagsText(context, if (nextFetchStatus == null) "downloaded" else "synced")
        nextFetchStatus = null
        hud()?.showWithStatus(status)
        handler.postDelayed({
            val data = stored()
            val sections = keys.mapNotNull { key -> data[key]?.let { key to it } }.toMap()
            hud()?.showSuccessWithStatus(finished)
            completion(sections)
        }, latencyMillis)
    }

    /**
     * Uploads `sections` (cache A's, after editing): copies them to B after the latency, with a HUD.
     */
    fun upload(sections: Map<String, List<CYLContactTag>>, completion: (() -> Unit)? = null) {
        hud()?.showWithStatus(cylContactTagsText(context, "uploading"))
        handler.postDelayed({
            store(sections)
            hud()?.showSuccessWithStatus(cylContactTagsText(context, "uploaded"))
            completion?.invoke()
        }, latencyMillis)
    }

    /**
     * Simulates an edit on another device, written to B: a random new tag (a new id) at the end of "My Tags" and its
     * first two tags swapped. `localItems` stands in when B has nothing yet. Returns the title added.
     */
    fun simulateOtherDeviceEdit(localItems: List<CYLContactTag>): String {
        val tags = (stored()[CYLContactTagStore.MINE_CACHE_KEY] ?: localItems).toMutableList()
        val titles = tags.map { it.title }.toSet()
        val pool = cylContactTagsText(context, "otherDeviceTags").split(",").filter { it !in titles }
        val added = pool.randomOrNull() ?: (cylContactTagsText(context, "otherDeviceTags") + " ${tags.size}")
        tags.add(CYLContactTag("o-" + UUID.randomUUID().toString().take(8), added))
        if (tags.size > 1) tags[0] = tags[1].also { tags[1] = tags[0] }
        store(mapOf(CYLContactTagStore.MINE_CACHE_KEY to tags))
        nextFetchStatus = cylContactTagsText(context, "syncing")
        return added
    }

    /** Stops the requests still waiting (the page went away). */
    fun cancel() {
        handler.removeCallbacksAndMessages(null)
    }
}
