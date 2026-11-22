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
import org.junit.Assert.assertNull
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

    // Binds row `position` of the results list the way the list does, without a window.
    private fun resultCell(search: CYLSearchView, position: Int): com.cyl.search.CYLSearchSuggestionCell {
        val adapter = search.resultsTableView.adapter!!
        val holder = adapter.createViewHolder(search.resultsTableView, 0)
        adapter.bindViewHolder(holder, position)
        return holder.itemView as com.cyl.search.CYLSearchSuggestionCell
    }

    @Test
    fun searchControllerConfiguresTheCoreThroughTheApiOnly() {
        val list = show(CYLSearchControllerDemoFragment())
        // Ten keywords under the bar.
        assertEquals(1 + 10 + 1, list.recyclerView.adapter!!.itemCount)
        val search = list.searchView
        // No view of the example: the launch area is the core's suggestion area, set through properties.
        assertNull(search.launchView)
        assertEquals(CYLSearchControllerDemoFragment.SUGGESTIONS, search.suggestions)
        assertTrue(search.showsSuggestionsForEmptyQuery && search.submitsOnSuggestionSelection && search.highlightsResultMatches)
        assertEquals(activity.cylDemoText("controller.noResults"), search.noResultsText)
        search.showSearch(list, false)
        layout(list)
        // The eight suggestions as CYLTagListView tags, folded to two rows, no history header.
        assertEquals(View.VISIBLE, search.suggestionsTagView.visibility)
        assertEquals(CYLSearchControllerDemoFragment.SUGGESTIONS, search.filteredSuggestions)
        assertEquals(View.GONE, search.suggestionCacheHeaderView.visibility)
        assertEquals(2, search.suggestionsFoldedRowCount)
        // Twenty rows per match: "Hea" matches two keywords.
        search.query = "Hea"
        assertEquals(View.GONE, search.suggestionsTagView.visibility)
        assertEquals(40, search.searchResults.size)
        assertFalse(search.isEmptyViewShowing)
        // The core highlights the match (the example sets no span).
        val cell = resultCell(search, 0)
        assertEquals("Health", cell.textLabel.text.toString())
        val spanned = cell.textLabel.text as android.text.Spanned
        val spans = spanned.getSpans(0, 6, android.text.style.ForegroundColorSpan::class.java)
        assertEquals(1, spans.size)
        assertEquals(0, spanned.getSpanStart(spans[0]))
        assertEquals(3, spanned.getSpanEnd(spans[0]))
        // No match: the core shows "No matching results" (noResultsText).
        search.query = "zzz"
        assertEquals(0, search.searchResults.size)
        assertTrue(search.isEmptyViewShowing)
        assertEquals(activity.cylDemoText("controller.noResults"), search.emptyView?.titleLabel?.text?.toString())
        search.query = "Hea"
        assertFalse("the empty view leaves with the match", search.isEmptyViewShowing)
        // A submitted query is the history: the area (on screen while searching) lists it first, under its header.
        search.query = "Health"
        search.searchBarView.submit()
        assertTrue("the search stays open after the return key", search.isSearchOpen)
        search.query = ""
        assertEquals(listOf("Health"), search.filteredSuggestions)
        assertEquals(View.VISIBLE, search.suggestionCacheHeaderView.visibility)
        search.clearSuggestionCacheButton.performClick()
        assertEquals(CYLSearchControllerDemoFragment.SUGGESTIONS, search.filteredSuggestions)
        // A tapped tag becomes the query and is submitted: the history has it, the results follow.
        search.suggestionsTagView.tagClickHandler!!.invoke(3, com.cyl.classifymenu.CYLTag(3, "Health", null as Int?))
        assertEquals("Health", search.query)
        assertEquals(listOf("Health"), search.suggestionCache!!.cachedQueries())
        assertEquals("the results follow the tapped tag: two keywords, twenty rows each", 40, search.searchResults.size)
        // Cancel clears the text: the area shows again on the next opening.
        search.query = "He"
        search.closeSearch(false)
        assertEquals("", search.query)
    }

    @Test
    fun searchBarStylesRowsDriveTheBar() {
        val list = show(CYLSearchBarStylesFragment())
        val bar = list.searchBarView
        assertFalse(list.opensSearchViewOnTap)
        assertFalse("accessories hidden first", bar.showsLeadingView || bar.showsTrailingAccessoryViews)
        assertNotNull(bar.leadingView)
        assertEquals(1, bar.trailingAccessoryViews.size)
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
        assertTrue(bar.showsLeadingView && bar.showsTrailingAccessoryViews)
        assertEquals(30 * density, (bar.leadingView!!.layoutParams.width).toFloat(), 1f)
        assertEquals(activity.cylDemoText("styles.hide").format(activity.cylDemoText("styles.leading")), (allViews(list).first { it.tag == "CYLSearchBarStylesRow6" } as ViewGroup).contentDescription)
        // The bar covers no view: its children do not overlap along the row (the trailing accessory sits inside the field).
        val trailing = bar.trailingAccessoryViews[0]
        assertTrue("inside the field", generateSequence(trailing.parent) { it.parent }.any { it === bar.fieldView })
        val rects = listOf(bar.leadingView!!.parent as View, bar.fieldView, bar.cancelButton)
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
