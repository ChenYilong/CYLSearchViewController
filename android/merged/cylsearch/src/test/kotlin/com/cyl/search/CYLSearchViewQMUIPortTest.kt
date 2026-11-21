package com.cyl.search

import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import androidx.activity.BackEventCompat
import androidx.activity.ComponentActivity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The QMUI search controller port on `CYLSearchView` (docs/qmui-search-controller.md, "Android (Kotlin, android/merged:
 * core module cylsearch, example app): QMUI search port"): the launch view, the dimming, the results callback, the
 * presentation callbacks, `isActive`, the empty view, the history and the swipe to dismiss.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchViewQMUIPortTest {

    private val activity: ComponentActivity = Robolectric.buildActivity(ComponentActivity::class.java).setup().get()

    private val events = mutableListOf<String>()
    private val updates = mutableListOf<String>()

    private val delegate = object : CYLSearchViewDelegate {
        override fun searchViewWillShow(searchView: CYLSearchView) { events += "willShow" }
        override fun searchViewDidShow(searchView: CYLSearchView) { events += "didShow" }
        override fun searchViewWillClose(searchView: CYLSearchView) { events += "willClose" }
        override fun searchViewDidClose(searchView: CYLSearchView) { events += "didClose" }
        override fun searchViewUpdateResults(searchView: CYLSearchView, searchString: String) { updates += searchString }
        override fun searchViewWillShowEmptyView(searchView: CYLSearchView, emptyView: View) { events += "willShowEmpty" }
    }

    @Before
    fun cleanCache() {
        CYLSearchSuggestionStore.cacheWithPolicy(activity, CYLSearchSuggestionCachePolicy.Database, "CYLSearchView")?.removeAllQueries()
        CYLSearchSuggestionStore.cacheWithPolicy(activity, CYLSearchSuggestionCachePolicy.Database, "QMUIPortTest")?.removeAllQueries()
    }

    private fun idle() = org.robolectric.Shadows.shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(2000))

    private fun searchView(): CYLSearchView {
        val host = FrameLayout(activity)
        activity.setContentView(host)
        return CYLSearchView(activity).also {
            it.installInView(host)
            it.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.Database
            it.suggestionCacheName = "QMUIPortTest"
            it.delegate = delegate
        }
    }

    @Test
    fun resultsCallbackAlsoReceivesTheEmptyText() {
        val view = searchView()
        view.showSearch(false)
        assertEquals("the first opening reports the empty text", listOf(""), updates)
        view.query = "ab"
        assertEquals(listOf("", "ab"), updates)
        view.searchBarView.text = "abc"
        view.query = ""
        assertEquals("the empty text after deleting everything", "", updates.last())
        view.clearsQueryOnClose = true
        view.query = "x"
        updates.clear()
        view.closeSearch(false)
        assertEquals("closing with clearsQueryOnClose clears the text and reports it", listOf(""), updates)
        assertEquals("", view.query)
    }

    @Test
    fun presentationCallbacksAndIsActive() {
        val view = searchView()
        assertFalse(view.isActive)
        view.setActive(true, false)
        assertTrue(view.isActive)
        view.setActive(false, false)
        assertFalse(view.isActive)
        assertEquals(listOf("willShow", "didShow", "willClose", "didClose"), events)
        view.setActive(true, true)
        idle()
        assertTrue(view.isActive)
        assertEquals("willShow", events[4])
        view.setActive(false, true)
        idle()
        assertEquals(listOf("willShow", "didShow", "willClose", "didClose", "willShow", "didShow", "willClose", "didClose"), events)
    }

    @Test
    fun launchViewShowsWhileTheQueryIsEmptyAndWinsOverTheHistory() {
        val view = searchView()
        view.suggestionCache?.addQuery("history")
        view.showsSuggestionsForEmptyQuery = true
        val launch = TextView(activity).apply { text = "Recent" }
        view.launchView = launch
        view.showSearch(false)
        assertEquals(View.VISIBLE, launch.visibility)
        assertEquals("the cached queries stay behind the launch view", View.GONE, view.suggestionsTableView.visibility)
        assertEquals(View.GONE, view.suggestionCacheHeaderView.visibility)
        view.query = "his"
        assertEquals(View.GONE, launch.visibility)
        assertEquals(View.VISIBLE, view.suggestionsTableView.visibility)
        view.query = ""
        assertEquals("the launch view is back after deleting the text", View.VISIBLE, launch.visibility)
        view.launchView = null
        assertEquals(View.VISIBLE, view.suggestionsTableView.visibility)
    }

    @Test
    fun dimmingShowsWhileEmptyAndATapEndsTheSearch() {
        val view = searchView()
        view.dimmingColor = Color.argb(128, 0, 0, 0)
        view.showSearch(false)
        val scrim = view.getChildAt(0)
        assertEquals(View.VISIBLE, scrim.visibility)
        assertEquals(Color.argb(128, 0, 0, 0), (scrim.background as android.graphics.drawable.ColorDrawable).color)
        view.query = "a"
        assertEquals("no dimming while there is text", View.GONE, scrim.visibility)
        view.query = ""
        assertEquals(View.VISIBLE, scrim.visibility)
        scrim.performClick()
        idle()
        assertFalse("a tap on the dimming ends the search", view.isActive)
        // A launch view wins: no dimming.
        view.launchView = View(activity)
        view.showSearch(false)
        assertEquals(View.GONE, scrim.visibility)
    }

    @Test
    fun emptyViewShowsOnlyWithTextAndLeavesWithTheSearch() {
        val view = searchView()
        view.showSearch(false)
        view.showEmptyView("No matching results")
        assertFalse("nothing is added while the text is empty", view.isEmptyViewShowing)
        view.query = "zzz"
        view.showEmptyView("No matching results", "Try another word", "Retry") {}
        assertTrue(view.isEmptyViewShowing)
        assertTrue(events.contains("willShowEmpty"))
        assertNotNull(view.emptyView?.button)
        assertEquals("No matching results", view.emptyView?.titleLabel?.text?.toString())
        view.hideEmptyView()
        assertFalse(view.isEmptyViewShowing)
        view.showEmptyView(com.cyl.placeholder.CYLPlaceholderScenario.NoContent)
        assertTrue(view.isEmptyViewShowing)
        view.query = ""
        assertFalse("the launch view or dimming owns the space when the text is empty", view.isEmptyViewShowing)
        view.query = "zzz"
        view.showEmptyView("None")
        view.closeSearch(false)
        assertFalse("closing hides it", view.isEmptyViewShowing)
        assertNull(view.emptyView)
    }

    @Test
    fun submittedQueriesAreTheHistoryAndNotifyTheListeners() {
        val view = searchView()
        var notified = 0
        val listener: (CYLSearchView) -> Unit = { notified++ }
        view.addHistoryDidChangeListener(listener)
        view.closesOnSubmit = false
        view.showSearch(false)
        view.searchBarView.text = "  swift  "
        view.searchBarView.submit()
        assertEquals(1, notified)
        assertEquals("trimmed, newest first", listOf("swift"), view.suggestionCache?.cachedQueries())
        view.searchBarView.text = "   "
        view.searchBarView.submit()
        assertEquals("a blank query is ignored", 1, notified)
        view.searchBarView.text = "kotlin"
        view.searchBarView.submit()
        assertEquals(2, notified)
        assertEquals(listOf("kotlin", "swift"), view.suggestionCache?.cachedQueries())
        view.removeHistoryDidChangeListener(listener)
        view.searchBarView.text = "dart"
        view.searchBarView.submit()
        assertEquals(2, notified)
    }

    @Test
    fun backSwipeDragsThePageAndCompletingEndsTheSearch() {
        val view = searchView()
        view.supportsSwipeToDismissSearch = true
        view.showSearch(false)
        val dispatcher = activity.onBackPressedDispatcher
        dispatcher.dispatchOnBackStarted(BackEventCompat(0f, 100f, 0f, BackEventCompat.EDGE_LEFT))
        dispatcher.dispatchOnBackProgressed(BackEventCompat(100f, 100f, 0.5f, BackEventCompat.EDGE_LEFT))
        val page = view.getChildAt(1)
        assertTrue("the page follows the swipe: ${page.translationX}", page.translationX >= 0f)
        dispatcher.dispatchOnBackCancelled()
        idle()
        assertEquals("cancelled: the page springs back", 0f, page.translationX, 0f)
        assertTrue("cancelled: still searching", view.isActive)
        dispatcher.onBackPressed()
        idle()
        assertFalse("completed: the search ends", view.isActive)
        assertEquals(0f, page.translationX, 0f)
    }

    @Test
    fun withoutTheSwitchTheBackSwipeDoesNotMoveThePage() {
        val view = searchView()
        view.showSearch(false)
        val dispatcher = activity.onBackPressedDispatcher
        dispatcher.dispatchOnBackStarted(BackEventCompat(0f, 100f, 0f, BackEventCompat.EDGE_LEFT))
        dispatcher.dispatchOnBackProgressed(BackEventCompat(100f, 100f, 0.5f, BackEventCompat.EDGE_LEFT))
        assertEquals(0f, view.getChildAt(1).translationX, 0f)
        dispatcher.dispatchOnBackCancelled()
    }

    @Test
    fun backGoesToAPageThatCoversTheOpenSearch() {
        // The detail page pushed from a result lies over the search that stays open behind it: Back pops that page
        // first, then closes the search (a bug found on the emulator).
        val host = FrameLayout(activity)
        activity.setContentView(host, android.view.ViewGroup.LayoutParams(1080, 1920))
        var pagePopped = 0
        val pageCallback = object : androidx.activity.OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                pagePopped++
                host.removeViewAt(host.childCount - 1)
            }
        }
        activity.onBackPressedDispatcher.addCallback(pageCallback)
        val view = CYLSearchView(activity).also {
            host.addView(it, android.view.ViewGroup.LayoutParams(-1, -1))
            it.delegate = delegate
        }
        view.showSearch(false)
        val cover = View(activity)
        host.addView(cover, android.view.ViewGroup.LayoutParams(-1, -1))
        host.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(1920, View.MeasureSpec.EXACTLY))
        host.layout(0, 0, 1080, 1920)
        activity.onBackPressedDispatcher.onBackPressed()
        assertEquals("the covering page took Back", 1, pagePopped)
        assertTrue("the search stays open behind it", view.isActive)
        host.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(1920, View.MeasureSpec.EXACTLY))
        host.layout(0, 0, 1080, 1920)
        activity.onBackPressedDispatcher.onBackPressed()
        idle()
        assertFalse("uncovered: Back closes the search", view.isActive)
        assertEquals(1, pagePopped)
    }

    @Test
    fun searchBarMaxYIsTheBottomOfTheBar() {
        val view = searchView()
        view.showSearch(false)
        view.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(1920, View.MeasureSpec.EXACTLY))
        view.layout(0, 0, 1080, 1920)
        assertTrue(view.searchBarMaxY > 0)
        assertEquals(view.searchBarView.bottom, view.searchBarMaxY)
    }
}
