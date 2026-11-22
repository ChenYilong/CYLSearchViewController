package com.cyl.search

import android.graphics.Color
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import androidx.activity.ComponentActivity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Merge phase 5 on `CYLSearchView` (docs/qmui-search-controller.md, "Merge phase 5 log: Android"): the one empty-view
 * slot, the match highlight, `noResultsText`, the one history signal and the one life cycle.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchMergePhase5Test {

    private val activity: ComponentActivity = Robolectric.buildActivity(ComponentActivity::class.java).setup().get()
    private val host = FrameLayout(activity)
    private val events = mutableListOf<String>()
    private var resultCalls = 0
    private var results = listOf<String>()

    private val source = object : CYLSearchViewDataSource {
        override fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any> {
            resultCalls++
            return results.filter { CYLSearchResultHighlight.fold(it).contains(CYLSearchResultHighlight.fold(query.trim())) }
        }

        override fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any) {
            cell.textLabel.text = result as String
        }
    }

    private val lifeCycle = object : CYLSearchViewDelegate {
        override fun searchViewWillShow(searchView: CYLSearchView) { events += "willShow" }
        override fun searchViewDidShow(searchView: CYLSearchView) { events += "didShow" }
        override fun searchViewWillClose(searchView: CYLSearchView) { events += "willClose" }
        override fun searchViewDidClose(searchView: CYLSearchView) { events += "didClose" }
    }

    @Before
    fun cleanHistory() {
        activity.setContentView(host)
        listOf("P5", "P5Other").forEach {
            CYLSearchSuggestionStore.cacheWithPolicy(activity, CYLSearchSuggestionCachePolicy.UserDefaults, it)?.removeAllQueries()
        }
    }

    private fun idle() = org.robolectric.Shadows.shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(2000))

    private fun searchView(name: String = "P5"): CYLSearchView = CYLSearchView(activity).also {
        host.addView(it, FrameLayout.LayoutParams(-1, -1))
        it.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.UserDefaults
        it.suggestionCacheName = name
        it.closesOnSubmit = false
    }

    // Binds row `position` of the results list the way the list does, without a window.
    private fun resultCell(view: CYLSearchView, position: Int, holder: androidx.recyclerview.widget.RecyclerView.ViewHolder? = null): CYLSearchSuggestionCell {
        val adapter = view.resultsTableView.adapter!!
        val bound = holder ?: adapter.createViewHolder(view.resultsTableView, 0)
        adapter.bindViewHolder(bound, position)
        return bound.itemView as CYLSearchSuggestionCell
    }

    private fun colored(label: TextView): List<Triple<Int, Int, Int>> {
        val text = label.text as? Spanned ?: return emptyList()
        return text.getSpans(0, text.length, ForegroundColorSpan::class.java).map { Triple(text.getSpanStart(it), text.getSpanEnd(it), it.foregroundColor) }
    }

    // One empty view slot

    @Test
    fun oneSlotHoldsEveryEmptyViewOfTheSearchView() {
        val view = searchView()
        view.showsEmptyResultsPlaceholder = true
        view.suggestions = listOf("alpha")
        view.showSearch(false)
        view.query = "zzz"
        val results = view.emptyResultsView!!
        view.showEmptyView("None")
        val explicit = view.emptyView!!
        // Both are children of the one body, the explicit one on top; neither is held twice.
        assertSame(results.parent, explicit.parent)
        val body = results.parent as FrameLayout
        assertEquals(body.indexOfChild(explicit), body.childCount - 1)
        view.showEmptyView("Again")
        assertEquals("the slot replaces its view", 1, (0 until body.childCount).count { body.getChildAt(it) === view.emptyView })
        view.hideEmptyView()
        assertNull(view.emptyView)
        assertFalse(view.isEmptyViewShowing)
        assertSame("the results placeholder stays in its own slot", results, view.emptyResultsView)
    }

    @Test
    fun theSlotKeepsItsViewInTheHostAndTakesItOut() {
        val container = FrameLayout(activity)
        container.addView(View(activity))
        var padding = 0
        val slot = CYLSearchEmptyViewSlot(container, 1) { padding }
        val first = CYLSearchView.emptyPlaceholder(activity, "one")
        slot.adopt(first, Color.WHITE)
        assertEquals(2, container.childCount)
        assertSame(first, container.getChildAt(1))
        padding = 40
        slot.refreshPadding()
        assertEquals("the part the keyboard covers", 40, first.paddingBottom)
        val second = CYLSearchView.emptyPlaceholder(activity, "two")
        slot.adopt(second)
        assertEquals("replaced, not added", 2, container.childCount)
        slot.setShowing(false) { error("not created again") }
        assertEquals(View.GONE, second.visibility)
        slot.setShowing(true) { error("not created again") }
        assertEquals(View.VISIBLE, second.visibility)
        slot.remove()
        assertEquals(1, container.childCount)
        assertNull(slot.view)
    }

    // The match highlight

    @Test
    fun theMatchIgnoresCaseAndDiacritics() {
        val accented = "Caf\u00e9"
        assertEquals(0..3, CYLSearchResultHighlight.firstMatch(accented, "cafe"))
        assertEquals(0..3, CYLSearchResultHighlight.firstMatch(accented, "CAF\u00c9"))
        assertEquals(0..3, CYLSearchResultHighlight.firstMatch("cafe", "CAF\u00c9"))
        // A decomposed accent is part of the match: the mark is highlighted with its letter.
        assertEquals(0..4, CYLSearchResultHighlight.firstMatch("Cafe\u0301 au lait", "cafe"))
        assertEquals(0..4, CYLSearchResultHighlight.firstMatch("Cafe\u0301 au lait", "caf\u00e9"))
        assertEquals(4..6, CYLSearchResultHighlight.firstMatch(" Health ", " lth "))
        assertEquals("the first match only", 1..2, CYLSearchResultHighlight.firstMatch("aXXaXX", "xx"))
        assertNull(CYLSearchResultHighlight.firstMatch("Health", ""))
        assertNull(CYLSearchResultHighlight.firstMatch("Health", "   "))
        assertNull(CYLSearchResultHighlight.firstMatch("Health", "zzz"))
    }

    @Test
    fun highlightIsOffByDefaultAndTakesTheTintOrYourColor() {
        results = listOf("Caf\u00e9 au lait", "Cappuccino")
        val view = searchView()
        view.resultsDataSource = source
        view.showSearch(false)
        view.query = "CAFE"
        assertEquals(1, view.searchResults.size)
        assertTrue("off by default", colored(resultCell(view, 0).textLabel).isEmpty())
        view.highlightsResultMatches = true
        view.searchBarView.tintColor = Color.GREEN
        assertEquals("the tint color of the bar", listOf(Triple(0, 4, Color.GREEN)), colored(resultCell(view, 0).textLabel))
        view.resultMatchHighlightColor = Color.RED
        assertEquals(listOf(Triple(0, 4, Color.RED)), colored(resultCell(view, 0).textLabel))
        view.highlightsResultMatches = false
        assertTrue(colored(resultCell(view, 0).textLabel).isEmpty())
    }

    @Test
    fun aReusedRowDoesNotKeepTheHighlightOfAnotherQuery() {
        results = listOf("Health", "Healthy", "Fat")
        val view = searchView()
        view.resultsDataSource = source
        view.highlightsResultMatches = true
        view.resultMatchHighlightColor = Color.RED
        view.showSearch(false)
        view.query = "ea"
        val holder = view.resultsTableView.adapter!!.createViewHolder(view.resultsTableView, 0)
        assertEquals(listOf(Triple(1, 3, Color.RED)), colored(resultCell(view, 0, holder).textLabel))
        view.query = "fa"
        assertEquals(listOf("Fat"), view.searchResults)
        assertEquals("Fat", resultCell(view, 0, holder).textLabel.text.toString())
        assertEquals(listOf(Triple(0, 2, Color.RED)), colored(resultCell(view, 0, holder).textLabel))
        view.query = "ea"
        view.query = "he"
        assertEquals("the match moved with the query", listOf(Triple(0, 2, Color.RED)), colored(resultCell(view, 0, holder).textLabel))
    }

    // noResultsText

    @Test
    fun noResultsTextShowsTheEmptyViewWhileNothingIsListed() {
        results = listOf("Health", "Fat")
        val view = searchView()
        view.resultsDataSource = source
        view.noResultsText = "No matching results"
        view.showSearch(false)
        view.query = "zzz"
        assertTrue(view.isEmptyViewShowing)
        assertEquals("No matching results", view.emptyView?.titleLabel?.text?.toString())
        view.query = "fat"
        assertFalse("rows again: the empty view leaves", view.isEmptyViewShowing)
        view.query = "zzz"
        assertTrue(view.isEmptyViewShowing)
        view.query = ""
        assertFalse("an empty query never shows it", view.isEmptyViewShowing)
        view.noResultsText = null
        view.query = "zzz"
        assertFalse("null leaves it to the delegate", view.isEmptyViewShowing)
    }

    // One history signal

    @Test
    fun anotherViewOfTheSameHistoryRefreshesAnOpenViewAndReachesTheListeners() {
        val first = searchView()
        val second = searchView()
        val other = searchView("P5Other")
        var secondNotified = 0
        var otherNotified = 0
        second.addHistoryDidChangeListener { secondNotified++ }
        other.addHistoryDidChangeListener { otherNotified++ }
        second.showsSuggestionsForEmptyQuery = true
        second.showSearch(false)
        first.showSearch(false)
        first.query = "swift"
        first.searchBarView.submit()
        assertEquals("the open view lists the history again", listOf("swift"), second.filteredSuggestions)
        assertEquals(1, secondNotified)
        assertEquals("another name is another history", 0, otherNotified)
        host.removeView(second)
        first.query = "kotlin"
        first.searchBarView.submit()
        assertEquals("a detached view hears nothing", 1, secondNotified)
        // A clear is the same signal.
        host.addView(second, FrameLayout.LayoutParams(-1, -1))
        first.clearSuggestionCache()
        assertEquals(2, secondNotified)
    }

    @Test
    fun aStoreOfYourOwnIsAnnouncedByTheCoreAndMatchedByIdentity() {
        val stored = mutableListOf<String>()
        val custom = object : CYLSearchSuggestionCache {
            override fun cachedQueries(): List<String> = stored.toList()
            override fun addQuery(query: String) { stored.remove(query); stored.add(0, query) }
            override fun removeQuery(query: String) { stored.remove(query) }
            override fun removeAllQueries() { stored.clear() }
        }
        val first = searchView()
        val second = searchView()
        first.suggestionCache = custom
        second.suggestionCache = custom
        var notified = 0
        second.addHistoryDidChangeListener { notified++ }
        first.showSearch(false)
        first.query = "abc"
        first.searchBarView.submit()
        assertEquals(listOf("abc"), stored)
        assertEquals(1, notified)
        first.clearSuggestionCache()
        assertEquals(2, notified)
    }

    @Test
    fun theViewsOwnSubmitIsNotListedAgainBySignal() {
        results = listOf("alpha")
        val view = searchView()
        view.resultsDataSource = source
        view.showSearch(false)
        view.query = "al"
        val before = resultCalls
        view.searchBarView.submit()
        assertEquals("the results are not asked for again", before, resultCalls)
        assertEquals(listOf("al"), view.suggestionCache?.cachedQueries())
    }

    @Test
    fun aTappedSuggestionSubmitsAndTheResultsFollow() {
        results = listOf("Health", "Healthy", "Fat")
        val view = searchView()
        view.resultsDataSource = source
        view.suggestions = listOf("Fat", "Health")
        view.showsSuggestionsForEmptyQuery = true
        view.submitsOnSuggestionSelection = true
        var submitted = ""
        view.delegate = object : CYLSearchViewDelegate {
            override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean {
                submitted = text
                return true
            }
        }
        view.showSearch(false)
        assertEquals(listOf("Fat", "Health"), view.filteredSuggestions)
        view.suggestionsTagView.tagClickHandler!!.invoke(1, com.cyl.classifymenu.CYLTag(1, "Health", null as Int?))
        assertEquals("Health", view.query)
        assertEquals("submitted", "Health", submitted)
        assertEquals(listOf("Health"), view.suggestionCache?.cachedQueries())
        assertEquals("the results follow the tag", listOf("Health", "Healthy"), view.searchResults)
    }

    // One life cycle

    @Test
    fun everyWayToCloseSendsWillAndDidOnce() {
        val view = searchView()
        view.delegate = lifeCycle
        view.scrimColor = Color.argb(100, 0, 0, 0)
        val closes = listOf<Pair<String, () -> Unit>>(
            "Cancel" to { view.searchBarView.cancelButton.performClick() },
            "scrim tap" to { view.getChildAt(0).performClick() },
            "Back" to { activity.onBackPressedDispatcher.onBackPressed() },
            "setActive(false, true)" to { view.setActive(false, true) },
            "setActive(false, false)" to { view.setActive(false, false) },
            "closeSearch" to { view.closeSearch(true) },
        )
        for ((name, close) in closes) {
            events.clear()
            view.setActive(true, true)
            idle()
            assertEquals("$name: shown once", listOf("willShow", "didShow"), events)
            events.clear()
            close()
            idle()
            assertEquals("$name: closed once", listOf("willClose", "didClose"), events)
            assertFalse(name, view.isActive)
        }
        events.clear()
        view.setActive(false, true)
        view.closeSearch(false)
        idle()
        assertTrue("closing a closed view sends nothing: $events", events.isEmpty())
    }
}
