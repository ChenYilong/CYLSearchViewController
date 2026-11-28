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
        assertTrue("the header shows by default", view.showsSuggestionCacheHeader)
        view.showsSuggestionCacheHeader = false
        assertEquals("no header: the host clears the history itself", View.GONE, view.suggestionCacheHeaderView.visibility)
        assertEquals("the cached queries stay", listOf("Kotlin", "Flutter"), view.filteredSuggestions)
        view.showsSuggestionCacheHeader = true
        assertEquals(View.VISIBLE, view.suggestionCacheHeaderView.visibility)
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
                view.emptySuggestionsView?.visibility, view.suggestionsTableView.visibility, view.suggestionsTagView.visibility)
            val before = snapshot()
            view.searchBarView.textField.requestFocus()
            assertTrue(view.searchBarView.textField.hasFocus())
            assertEquals("focus alone, cache $cached", before, snapshot())
            view.searchBarView.textField.clearFocus()
            assertEquals("blur alone, cache $cached", before, snapshot())
            view.suggestionCache!!.removeAllQueries()
        }
    }

    @Test
    fun tagSuggestionsEndWithTheFoldButtonByDefault() {
        // docs/tag-view-suggestions.md, BUG TODO.
        val view = CYLSearchView(activity)
        assertEquals(com.cyl.classifymenu.CYLMenuFoldControlPosition.TAIL, view.suggestionsFoldControl.position)
        assertEquals(com.cyl.classifymenu.CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon, view.suggestionsFoldControl.content)
        assertEquals(2, view.suggestionsFoldedRowCount)
        view.suggestionsFoldedRowCount = 3
        assertEquals(3, view.suggestionsTagView.defaultVisibleRows)
    }

    private fun idle() = org.robolectric.Shadows.shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(2000))

    private fun openedWithSuggestions(suggestions: List<String>): CYLSearchView {
        val host = FrameLayout(activity)
        activity.setContentView(host, android.view.ViewGroup.LayoutParams(1080, 1920))
        val view = CYLSearchView(activity)
        view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.None
        view.suggestions = suggestions
        view.showsSuggestionsForEmptyQuery = true
        view.focusesSearchFieldOnShow = false
        view.installInView(host)
        view.showSearch(false)
        idle()
        return view
    }

    /**
     * The tags and the fold control of the tag list in layout order, after laying it out at 400 px (400 dp in a unit test).
     */
    private fun laidOutTags(view: CYLSearchView): List<View> {
        val tags = view.suggestionsTagView
        tags.measure(View.MeasureSpec.makeMeasureSpec(400, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
        tags.layout(0, 0, 400, tags.measuredHeight)
        val found = ArrayList<View>()
        fun walk(group: android.view.ViewGroup) {
            for (index in 0 until group.childCount) {
                val child = group.getChildAt(index)
                if (child is com.cyl.classifymenu.CYLTagListCell || child is com.cyl.classifymenu.CYLTagFoldCell) found.add(child)
                else if (child is android.view.ViewGroup) walk(child)
            }
        }
        walk(tags)
        return found
    }

    @Test
    fun suggestionsAreTagsFoldedToTwoRowsByDefaultAndTheLastTagIsTheFoldControl() {
        // docs/task-log.md, "tags as the default suggestion style": folded at start; folded or unfolded the last tag is
        // the fold control and a tap on it toggles the folding.
        val view = openedWithSuggestions((1..60).map { "Suggestion number $it" })
        val tags = view.suggestionsTagView
        assertEquals(CYLSearchSuggestionStyle.Tags, view.suggestionStyle)
        assertEquals(View.VISIBLE, tags.visibility)
        assertEquals("the list is not shown", View.GONE, view.suggestionsTableView.visibility)
        val folded = laidOutTags(view)
        assertEquals("folded at start", false, tags.isSectionExpanded(0))
        assertTrue(tags.canFoldSection(0))
        assertTrue("more rows than the folded two", tags.numberOfRowsInSection(0) > 2)

        assertEquals("two rows while folded", 2, tags.defaultVisibleRows)
        assertEquals("folded: the visible tags and the control", tags.numberOfVisibleItemsInSection(0) + 1, folded.size)
        assertTrue("folded: fewer tags than suggestions", folded.size - 1 < 60)
        assertTrue("folded: the last tag is the fold control", folded.last() is com.cyl.classifymenu.CYLTagFoldCell)
        assertEquals("one fold control", 1, folded.count { it is com.cyl.classifymenu.CYLTagFoldCell })

        folded.last().performClick()
        idle()
        assertTrue("a tap on the last tag unfolds", tags.isSectionExpanded(0))
        val unfolded = laidOutTags(view)
        assertEquals("unfolded: every tag and the control", 60 + 1, unfolded.size)
        assertTrue(unfolded.size > folded.size)
        assertTrue("unfolded: the last tag is still the fold control", unfolded.last() is com.cyl.classifymenu.CYLTagFoldCell)
        assertEquals(1, unfolded.count { it is com.cyl.classifymenu.CYLTagFoldCell })

        unfolded.last().performClick()
        idle()
        assertEquals("a second tap folds again", false, tags.isSectionExpanded(0))
        val again = laidOutTags(view)
        assertEquals(folded.size, again.size)
        assertTrue(again.last() is com.cyl.classifymenu.CYLTagFoldCell)
    }

    @Test
    fun tagSuggestionsThatFitTheFoldedRowsShowNoFoldControl() {
        // CollectionViewClassifyMenu's packaged control hides itself when every tag fits the folded rows
        // (CYLTagListView.canFoldSection); the core adds none. docs/task-log.md, "tags as the default".
        val view = openedWithSuggestions(listOf("Swift", "Kotlin", "Dart"))
        val cells = laidOutTags(view)
        assertEquals(false, view.suggestionsTagView.canFoldSection(0))
        assertEquals(3, cells.size)
        assertTrue(cells.none { it is com.cyl.classifymenu.CYLTagFoldCell })
    }

    @Test
    fun theListStyleStaysAvailable() {
        val view = openedWithSuggestions(listOf("Swift", "Kotlin"))
        view.suggestionStyle = CYLSearchSuggestionStyle.List
        assertEquals(View.VISIBLE, view.suggestionsTableView.visibility)
        assertEquals(View.GONE, view.suggestionsTagView.visibility)
    }
}

