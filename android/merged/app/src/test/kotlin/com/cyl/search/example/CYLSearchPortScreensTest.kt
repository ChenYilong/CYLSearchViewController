package com.cyl.search.example

import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.RecyclerView
import com.cyl.search.CYLSearchListView
import com.cyl.search.CYLSearchSuggestionCachePolicy
import com.cyl.search.CYLSearchView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The two replica screens of QMUI's demo, "Search controller" and "Search bar styles", and the "Short list" screen
 * (docs/qmui-search-controller.md, "Android (Kotlin, android/merged: core module cylsearch, example app): QMUI search
 * port"): keywords, launch view, twenty rows per match with the match highlighted, "No matching results", the history
 * with its clear button, the style rows, and a bar that covers no view.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchPortScreensTest {

    private val activity: AppCompatActivity = Robolectric.buildActivity(AppCompatActivity::class.java).setup().get()

    @Before
    fun cleanHistory() {
        CYLSearchView(activity).apply {
            suggestionCachePolicy = CYLSearchSuggestionCachePolicy.UserDefaults
            suggestionCacheName = CYLSearchControllerDemoFragment.HISTORY_NAME
        }.suggestionCache?.removeAllQueries()
    }

    private fun idle() = org.robolectric.Shadows.shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(2000))

    private fun show(fragment: Fragment): CYLSearchListView {
        // A fixed-size container: the window of a unit test is small and would lay the screen out again at idle.
        val container = android.widget.FrameLayout(activity).apply { id = View.generateViewId() }
        activity.setContentView(container, ViewGroup.LayoutParams(1080, 1920))
        activity.supportFragmentManager.beginTransaction().add(container.id, fragment).commitNow()
        val list = findList(fragment.requireView())!!
        repeat(4) {
            val root = fragment.requireView()
            root.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(1920, View.MeasureSpec.EXACTLY))
            root.layout(0, 0, 1080, 1920)
            idle()
        }
        return list
    }

    private fun findList(view: View): CYLSearchListView? {
        if (view is CYLSearchListView) return view
        if (view is ViewGroup) for (i in 0 until view.childCount) findList(view.getChildAt(i))?.let { return it }
        return null
    }

    private fun layout(list: View) {
        list.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(1920, View.MeasureSpec.EXACTLY))
        list.layout(0, 0, 1080, 1920)
        idle()
    }

    @Test
    fun keywordsAndMatchesAreQMUIs() {
        assertEquals(10, CYLSearchControllerDemoFragment.KEYWORDS.size)
        assertEquals(listOf("Health", "Healthy"), CYLSearchControllerDemoFragment.matches("Hea"))
        assertTrue("case sensitive, as range(of:)", CYLSearchControllerDemoFragment.matches("hea").isEmpty())
        assertTrue(CYLSearchControllerDemoFragment.matches("").isEmpty())
        assertEquals(20, CYLSearchControllerDemoFragment.ROWS_PER_MATCH)
    }

    @Test
    fun searchControllerShowsKeywordsLaunchViewResultsEmptyViewAndHistory() {
        val list = show(CYLSearchControllerDemoFragment())
        // Ten keywords under the bar.
        assertEquals(1 + 10 + 1, list.recyclerView.adapter!!.itemCount)
        val search = list.searchView
        search.showSearch(list, false)
        layout(list)
        // The launch view with the eight suggestions while the text is empty.
        val launch = search.launchView as CYLRecentSearchLaunchView
        assertEquals(View.VISIBLE, launch.visibility)
        assertEquals(CYLRecentSearchLaunchView.SUGGESTIONS, launch.queries)
        assertEquals(View.GONE, launch.clearButton.visibility)
        // Twenty rows per match: "Hea" matches two keywords.
        search.query = "Hea"
        assertEquals(View.GONE, launch.visibility)
        assertEquals(40, search.searchResults.size)
        assertFalse(search.isEmptyViewShowing)
        // The match is highlighted in the tint color in the result rows.
        layout(list)
        val cell = com.cyl.search.CYLSearchSuggestionCell(activity)
        search.resultsDataSource!!.searchViewConfigureResultCell(search, cell, "Health")
        val spans = (cell.textLabel.text as android.text.Spanned).getSpans(0, 6, android.text.style.ForegroundColorSpan::class.java)
        assertEquals(1, spans.size)
        assertEquals(0, (cell.textLabel.text as android.text.Spanned).getSpanStart(spans[0]))
        assertEquals(3, (cell.textLabel.text as android.text.Spanned).getSpanEnd(spans[0]))
        // No match: "No matching results".
        search.query = "zzz"
        assertEquals(0, search.searchResults.size)
        assertTrue(search.isEmptyViewShowing)
        assertEquals(activity.cylDemoText("controller.noResults"), search.emptyView?.titleLabel?.text?.toString())
        // A submitted query is the history: the launch view (on screen while searching) reads it again.
        search.query = "Health"
        search.searchBarView.submit()
        assertFalse("the search stays open after the return key", !search.isSearchOpen)
        search.query = ""
        assertEquals(View.VISIBLE, launch.visibility)
        assertEquals(listOf("Health"), launch.queries)
        assertEquals(View.VISIBLE, launch.clearButton.visibility)
        launch.clearButton.performClick()
        assertEquals(CYLRecentSearchLaunchView.SUGGESTIONS, launch.queries)
        // Cancel clears the text: the launch view shows again on the next opening.
        search.query = "He"
        search.closeSearch(false)
        assertEquals("", search.query)
    }

    @Test
    fun searchBarStylesRowsDriveTheBar() {
        val list = show(CYLSearchBarStylesFragment())
        val bar = list.searchBarView
        assertFalse(list.opensSearchViewOnTap)
        assertFalse("accessories hidden first", bar.showsLeadingAccessoryView || bar.showsTrailingAccessoryView)
        assertNotNull(bar.leadingAccessoryView)
        val rows = (0..7).associateWith { index -> allViews(list).first { it.tag == "CYLSearchBarStylesRow$index" } }
        // Placeholder: the switch centers it; "Change placeholder" sets the long one.
        (rows[0] as ViewGroup).getChildAt(1).performClick()
        assertTrue(bar.centersPlaceholder)
        rows[1]!!.performClick()
        assertEquals(activity.cylDemoText("styles.longPlaceholder"), bar.placeholder)
        // Layout: margins 32 at rest, 0 while editing; Cancel margins (-16) while editing.
        rows[2]!!.performClick()
        val density = activity.resources.displayMetrics.density
        assertEquals((32 * density + 0.5f).toInt(), (bar.fieldView.layoutParams as ViewGroup.MarginLayoutParams).marginStart)
        rows[3]!!.performClick()
        idle()
        assertTrue("Adjust Cancel starts the search", bar.isActive)
        assertEquals(0, (bar.fieldView.layoutParams as ViewGroup.MarginLayoutParams).marginStart)
        assertEquals("Cancel is shown while searching", View.VISIBLE, bar.cancelButton.visibility)
        bar.hideKeyboard()
        // Accessory: the animated switch off, then each toggle takes effect at once.
        (rows[4] as ViewGroup).getChildAt(1).performClick()
        rows[5]!!.performClick()
        assertTrue(bar.showsCancelButton)
        rows[6]!!.performClick()
        rows[7]!!.performClick()
        layout(list)
        assertTrue(bar.showsLeadingAccessoryView && bar.showsTrailingAccessoryView)
        assertEquals(30 * density, (bar.leadingAccessoryView!!.layoutParams.width).toFloat(), 1f)
        assertEquals(activity.cylDemoText("styles.hide").format(activity.cylDemoText("styles.leading")), (allViews(list).first { it.tag == "CYLSearchBarStylesRow6" } as ViewGroup).contentDescription)
        // The bar covers no view: its children do not overlap along the row.
        val rects = listOf(bar.leadingAccessoryView!!.parent as View, bar.fieldView, bar.trailingAccessoryView!!.parent as View, bar.cancelButton)
            .filter { it.visibility == View.VISIBLE && it.width > 0 }.map { android.graphics.Rect(it.left, it.top, it.right, it.bottom) }
        for (i in rects.indices) for (j in i + 1 until rects.size) assertFalse("$i overlaps $j: ${rects[i]} ${rects[j]}", android.graphics.Rect.intersects(rects[i], rects[j]))
        // The first row of the list starts under the bar.
        val first = list.recyclerView.layoutManager!!.findViewByPosition(1)!!
        assertTrue(first.top >= bar.height + (bar.parent as View).top)
    }

    @Test
    fun shortListScrollsTheBarOutAndSnaps() {
        val list = show(CYLSearchShortListFragment())
        val bar = list.searchBarView.height
        assertEquals("hidden at first", bar, list.searchBarHiddenHeight)
        list.recyclerView.scrollBy(0, -bar / 4)
        list.settleSearchBar()
        idle()
        assertEquals("a quarter shown settles hidden", bar, list.searchBarHiddenHeight)
    }

    @Test
    fun menuListsTheNewScreens() {
        val menu = CYLSearchDemoMenuFragment()
        activity.supportFragmentManager.beginTransaction().add(android.R.id.content, menu).commitNow()
        val texts = allViews(menu.requireView()).filterIsInstance<android.widget.TextView>().map { it.text.toString() }
        for (key in listOf("demo.searchController", "demo.searchBarStyles", "demo.shortList")) {
            assertTrue("$key in the menu", activity.cylDemoText(key) in texts)
        }
    }

    @Test
    fun everyTextOfTheScreensExistsInFourLanguages() {
        val keys = listOf("demo.searchController", "demo.searchBarStyles", "demo.shortList", "styles.section.placeholder", "styles.section.layout",
            "styles.section.accessory", "styles.centerPlaceholder", "styles.changePlaceholder", "styles.longPlaceholder", "styles.adjustField",
            "styles.adjustCancel", "styles.animated", "styles.show", "styles.hide", "styles.cancel", "styles.leading", "styles.trailing",
            "styles.accessory.label", "styles.row.hint", "controller.recent", "controller.noResults", "controller.launch.label", "shortList.row")
        val english = keys.associateWith { com.cyl.search.CYLSearchResources.localizedString(activity, it, "en") }
        for (language in listOf("ja", "zh-Hans", "zh-Hant")) {
            for (key in keys) {
                val text = com.cyl.search.CYLSearchResources.localizedString(activity, key, language)
                assertNotEquals("$language misses $key", key, text)
                assertNotEquals("$language is not translated: $key", english[key], text)
            }
        }
    }

    private fun allViews(view: View): List<View> =
        listOf(view) + (if (view is ViewGroup) (0 until view.childCount).flatMap { allViews(view.getChildAt(it)) } else emptyList())
}
