package com.cyl.search.example.contacttags

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The contact tags demo (iOS `testContactTagsDemoSearchesCreatesAndKeepsItsStrings`): the bundled data and strings of
 * every language, search, create, rename by id, the server sections, and cache A across launches.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLContactTagStoreTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @Test
    fun bundledDataHasIdsAndEveryLanguageHasTheSameKeys() {
        val data = CYLContactTagData.bundled(context)
        assertEquals(2, data.version)
        assertEquals(47, data.tags.size)
        assertEquals("t01", data.tags.first().id)
        assertEquals(24, data.contacts.size)
        // Contacts, Recent and the selection refer to ids that exist.
        val ids = data.tags.map { it.id }.toSet()
        assertTrue(data.recentTags.all { it in ids } && data.selectedTags.all { it in ids })
        assertTrue(data.contacts.all { contact -> contact.tags.all { it in ids } })
        val english = CYLContactTagsLocalization.table(context).keys
        assertTrue("contactTags.editTags" in english && "contactTags.add" in english && "contactTags.otherDeviceTags" in english)
        for (language in listOf("ja", "zh-Hans", "zh-Hant")) {
            val text = context.assets.open("CYLContactTags.bundle/$language.lproj/CYLContactTags.strings").use { it.readBytes().toString(Charsets.UTF_8) }
            for (key in english) assertTrue("$language misses $key", text.contains("\"$key\""))
        }
    }

    @Test
    fun searchCreateRenameAndDeleteKeepIds() {
        val store = CYLContactTagStore(listOf(CYLContactTag("t01", "Family"), CYLContactTag("t02", "iOS Developers"), CYLContactTag("t03", "Friends")), listOf("t03"))
        // Case- and accent-insensitive, the prefixed matches first.
        assertEquals(listOf("t02"), store.tagsMatching("ios"))
        assertEquals(listOf("t03", "t01"), CYLContactTagStore(listOf(CYLContactTag("t01", "Old Friends"), CYLContactTag("t03", "Friends"))).tagsMatching("fri"))
        assertFalse(store.canCreate(" Family "))
        assertTrue(store.canCreate("Yoga"))
        val id = store.createTag("  Yoga ")!!
        assertTrue(id.startsWith("u-"))
        assertEquals(id, store.createTag("Yoga"))
        // A rename keeps the id (and so the contacts).
        store.contacts = listOf(CYLContactTagContact("Alex", listOf("t01")))
        store.renameTag("t01", "Family Home")
        assertEquals("Family Home", store.title("t01"))
        assertEquals(listOf("Alex"), store.contacts("t01").map { it.name })
        store.moveTag(0, 1)
        assertEquals(listOf("t02", "t01", "t03", id), store.tagIDs)
        store.markUsed(listOf("t02"))
        assertEquals(listOf("t02", "t03"), store.recentIDs)
        store.deleteTag("t03")
        assertEquals(listOf("t02"), store.recentIDs)
        store.clearRecent()
        assertTrue(store.recentIDs.isEmpty())
    }

    @Test
    fun serverSectionsApplyAndCacheASurvivesALaunch() {
        CYLContactTagStore.resetCache(context)
        val store = CYLContactTagStore.bundled(context)
        store.renameTag("t01", "Family Home")
        // Another launch reads cache A: the rename stays.
        assertEquals("Family Home", CYLContactTagStore.bundled(context).title("t01"))
        // A download replaces "My Tags" and keeps only the Recent ids that still exist.
        val downloaded = listOf(CYLContactTag("t02", "Relatives"), CYLContactTag("t01", "Family Home"), CYLContactTag("o-1", "Yoga"))
        assertTrue(store.apply(mapOf(CYLContactTagStore.MINE_CACHE_KEY to downloaded)))
        assertEquals(listOf("t02", "t01", "o-1"), store.tagIDs)
        assertFalse(store.apply(mapOf(CYLContactTagStore.MINE_CACHE_KEY to downloaded)))
        assertNotEquals(emptyList<String>(), store.tagIDs)
        // The sections round-trip with their ids (cache A and B).
        assertEquals(store.cacheSections, CYLContactTagSections.decode(CYLContactTagSections.encode(store.cacheSections)))
        CYLContactTagStore.resetCache(context)
    }
}
