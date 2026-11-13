package com.cyl.search

import android.app.Activity
import android.view.View
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The suggestion cache and the focus Bool (docs/core-todo.md), as the iOS tests check them.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchSuggestionCacheTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    @Test
    fun everyPolicyKeepsSubmittedQueriesNewestFirst() {
        for (policy in listOf(CYLSearchSuggestionCachePolicy.Database, CYLSearchSuggestionCachePolicy.UserDefaults,
            CYLSearchSuggestionCachePolicy.SandboxFile)) {
            val cache = CYLSearchSuggestionStore.cacheWithPolicy(activity, policy, "CYLTestCache")!!
            val other = CYLSearchSuggestionStore.cacheWithPolicy(activity, policy, "CYLTestOther")!!
            cache.removeAllQueries()
            other.removeAllQueries()
            cache.maximumCount = 3
            cache.addQuery("Swift")
            cache.addQuery("Kotlin")
            cache.addQuery("  ")
            cache.addQuery("Swift")
            assertEquals("$policy", listOf("Swift", "Kotlin"), cache.cachedQueries())
            cache.addQuery("Dart")
            cache.addQuery("Rust")
            assertEquals("the oldest goes, $policy", listOf("Rust", "Dart", "Swift"), cache.cachedQueries())
            assertEquals("names are separate, $policy", emptyList<String>(), other.cachedQueries())
            val reopened = CYLSearchSuggestionStore.cacheWithPolicy(activity, policy, "CYLTestCache")!!
            assertEquals("persisted, $policy", listOf("Rust", "Dart", "Swift"), reopened.cachedQueries())
            cache.removeQuery("Dart")
            assertEquals("$policy", listOf("Rust", "Swift"), cache.cachedQueries())
            cache.removeAllQueries()
            assertTrue("$policy", cache.cachedQueries().isEmpty())
        }
        assertNull(CYLSearchSuggestionStore.cacheWithPolicy(activity, CYLSearchSuggestionCachePolicy.None, "CYLTestCache"))
    }

    @Test
    fun theSearchViewCachesSubmittedQueriesAndClearsThemFromTheHeader() {
        val host = FrameLayout(activity)
        activity.setContentView(host)
        val view = CYLSearchView(activity)
        assertEquals(CYLSearchSuggestionCachePolicy.Database, view.suggestionCachePolicy)
        view.suggestionCacheName = "CYLTestSearchView"
        view.suggestionCache!!.removeAllQueries()
        view.suggestions = listOf("Android", "Kotlin", "Swift")
        view.closesOnSubmit = false
        view.installInView(host)
        view.showSearch(false)
        assertEquals("an empty cache shows the placeholder", View.VISIBLE, view.emptySuggestionsView?.visibility)
        assertEquals(View.GONE, view.suggestionCacheHeaderView.visibility)
        view.setQuery("Flutter", true)
        view.setQuery("Kotlin", true)
        view.setQuery("", false)
        assertEquals("the cache, newest first", listOf("Kotlin", "Flutter"), view.filteredSuggestions)
        assertEquals(View.VISIBLE, view.suggestionCacheHeaderView.visibility)
        assertEquals(View.GONE, view.emptySuggestionsView?.visibility)
        view.setQuery("t", false)
        assertEquals("cached matches first, no repeats", listOf("Kotlin", "Flutter", "Swift"), view.filteredSuggestions)
        view.setQuery("", false)
        view.clearSuggestionCacheButton.performClick()
        assertTrue(view.suggestionCache!!.cachedQueries().isEmpty())
        assertEquals("cleared: the placeholder again", View.VISIBLE, view.emptySuggestionsView?.visibility)
        view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.None
        assertNull(view.suggestionCache)
    }

    @Test
    fun focusesSearchFieldOnShowDecidesWhenTheKeyboardAppears() {
        for (focuses in listOf(true, false)) {
            val host = FrameLayout(activity)
            activity.setContentView(host)
            val view = CYLSearchView(activity)
            assertTrue("true by default", view.focusesSearchFieldOnShow)
            view.focusesSearchFieldOnShow = focuses
            view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.None
            view.installInView(host)
            view.showSearch(false)
            assertEquals("focusesSearchFieldOnShow $focuses", focuses, view.searchBarView.textField.hasFocus())
        }
    }

    @Test
    fun focusAloneChangesNothingBelowTheSearchBar() {
        // docs/core-todo.md, core behavior rule 1.
        for (cached in listOf(listOf("Kotlin", "Swift"), emptyList())) {
            val host = FrameLayout(activity)
            activity.setContentView(host)
            val view = CYLSearchView(activity)
            view.suggestionCacheName = "CYLTestFocus"
            view.suggestionCache!!.removeAllQueries()
            cached.reversed().forEach { view.suggestionCache!!.addQuery(it) }
            view.suggestions = listOf("Android", "Kotlin", "Swift")
            view.focusesSearchFieldOnShow = false
            view.installInView(host)
            view.showSearch(false)
            fun snapshot() = listOf(view.filteredSuggestions, view.suggestionCacheHeaderView.visibility,
                view.emptySuggestionsView?.visibility, view.suggestionsTableView.visibility)
            val before = snapshot()
            view.searchBarView.textField.requestFocus()
            assertTrue(view.searchBarView.textField.hasFocus())
            assertEquals("focus alone, cache $cached", before, snapshot())
            view.searchBarView.textField.clearFocus()
            assertEquals("blur alone, cache $cached", before, snapshot())
            view.suggestionCache!!.removeAllQueries()
        }
    }
}

