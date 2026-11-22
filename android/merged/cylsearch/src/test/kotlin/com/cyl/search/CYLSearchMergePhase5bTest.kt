package com.cyl.search

import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.activity.ComponentActivity
import androidx.core.graphics.Insets
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Merge phase 5b on the Android core (docs/qmui-search-controller.md, "Merge phase 5b log"): the gaps the React Native and
 * Flutter wrappers worked around: the insets of a view that is not at the top of the window, the size of
 * `cancelButtonFont`, the tags filled once the page has a width, the history listener for the trash button, and
 * `textDidChange` before the submit of a tapped tag.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchMergePhase5bTest {

    // No action bar: the content starts at the top of the window.
    private val activity: ComponentActivity = Robolectric.buildActivity(ComponentActivity::class.java)
        .also { it.get().setTheme(android.R.style.Theme_Material_NoActionBar) }.setup().get()
    private val column = LinearLayout(activity).apply { orientation = LinearLayout.VERTICAL }

    @Before
    fun clean() {
        activity.setContentView(column)
        CYLSearchSuggestionStore.cacheWithPolicy(activity, CYLSearchSuggestionCachePolicy.UserDefaults, "P5b")?.removeAllQueries()
    }

    private fun idle() = org.robolectric.Shadows.shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(2000))

    private fun layoutWindow() {
        val decor = activity.window.decorView
        decor.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(2000, View.MeasureSpec.EXACTLY))
        decor.layout(0, 0, 1080, 2000)
    }

    private fun sp(value: Float) = android.util.TypedValue.applyDimension(android.util.TypedValue.COMPLEX_UNIT_SP, value, activity.resources.displayMetrics)

    private fun intField(view: CYLSearchView, name: String): Int {
        val field = CYLSearchView::class.java.getDeclaredField(name)
        field.isAccessible = true
        return field.getInt(view)
    }

    private fun barsOf(top: Int, bottom: Int) = WindowInsetsCompat.Builder()
        .setInsets(WindowInsetsCompat.Type.systemBars(), Insets.of(0, top, 0, bottom))
        .build()

    @Test
    fun theInsetsAreOnlyThePartOfTheBarsThatLiesOverTheView() {
        val header = View(activity)
        column.addView(header, LinearLayout.LayoutParams(1080, 150))
        val view = CYLSearchView(activity)
        column.addView(view, LinearLayout.LayoutParams(-1, 1850))
        view.showSearch(false)
        layoutWindow()
        val place = IntArray(2)
        view.getLocationInWindow(place)
        assertEquals("the view starts below the header", 150, place[1])
        ViewCompat.onApplyWindowInsets(view, barsOf(top = 150, bottom = 0))
        assertEquals("the status bar is the header's, not the page's: no blank band", 0, intField(view, "topInset"))
        ViewCompat.onApplyWindowInsets(view, barsOf(top = 200, bottom = 0))
        assertEquals("only what reaches into the view", 50, intField(view, "topInset"))
        // Two thirds of the bottom bar are already kept clear by the host (the view ends 100 px above the window's end).
        view.layoutParams = LinearLayout.LayoutParams(-1, 1750)
        layoutWindow()
        ViewCompat.onApplyWindowInsets(view, barsOf(top = 0, bottom = 120))
        assertEquals("the bar's part below the view is not the page's", 20, intField(view, "keyboardInset"))
    }

    @Test
    fun aViewAtTheTopOfTheWindowKeepsTheFullInsets() {
        val view = CYLSearchView(activity)
        column.addView(view, LinearLayout.LayoutParams(-1, -1))
        view.showSearch(false)
        layoutWindow()
        ViewCompat.onApplyWindowInsets(view, barsOf(top = 150, bottom = 90))
        assertEquals(150, intField(view, "topInset"))
        assertEquals(90, intField(view, "keyboardInset"))
    }

    @Test
    fun theInsetsAreAppliedAgainWhenTheViewMoves() {
        val header = View(activity)
        column.addView(header, LinearLayout.LayoutParams(1080, 0))
        val view = CYLSearchView(activity)
        column.addView(view, LinearLayout.LayoutParams(-1, 1850))
        view.showSearch(false)
        layoutWindow()
        ViewCompat.onApplyWindowInsets(view, barsOf(top = 150, bottom = 0))
        assertEquals(150, intField(view, "topInset"))
        header.layoutParams = LinearLayout.LayoutParams(1080, 150)
        layoutWindow()
        idle()
        assertEquals("a header that appears takes the band away", 0, intField(view, "topInset"))
    }

    @Test
    fun cancelButtonFontCarriesASize() {
        val bar = CYLSearchBarView(activity)
        bar.showsCancelButton = true
        val sizeBefore = bar.cancelButton.textSize
        bar.cancelButtonFontSize = 13f
        assertEquals(sp(13f), bar.cancelButton.textSize, 0.5f)
        assertNotEquals(sizeBefore, bar.cancelButton.textSize, 0.1f)
        bar.cancelButtonFont = android.graphics.Typeface.DEFAULT_BOLD
        assertEquals("the typeface keeps the size", sp(13f), bar.cancelButton.textSize, 0.5f)
        bar.cancelButtonFontSize = null
        assertEquals("null follows fontSize again", sizeBefore, bar.cancelButton.textSize, 0.1f)
    }

    @Test
    fun theTagsAreFilledAgainOnceThePageHasAWidth() {
        val view = CYLSearchView(activity)
        view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.None
        view.suggestions = listOf("Swift", "Kotlin", "Dart")
        view.showsSuggestionsForEmptyQuery = true
        column.addView(view, LinearLayout.LayoutParams(-1, -1))
        // Opened while the page has no width yet: the tags were filled for width 0.
        view.showSearch(false)
        layoutWindow()
        idle()
        assertTrue("the tag list has its width now", view.suggestionsTagView.width > 0)
        assertEquals("every suggestion is a tag", 3, view.suggestionsTagView.menuDataSource?.menuNumberOfItemsInSection(0) ?: 3)
        assertTrue("and the list needs height for them", view.suggestionsTagView.contentHeight > 0f)
    }

    @Test
    fun theTrashButtonReachesTheHistoryListener() {
        val view = CYLSearchView(activity)
        view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.UserDefaults
        view.suggestionCacheName = "P5b"
        view.closesOnSubmit = false
        column.addView(view, LinearLayout.LayoutParams(-1, -1))
        var heard = 0
        view.addHistoryDidChangeListener { heard++ }
        view.showSearch(false)
        view.query = "swift"
        view.searchBarView.submit()
        assertEquals("a submit", 1, heard)
        view.query = ""
        view.clearSuggestionCacheButton.performClick()
        assertEquals("the trash button", 2, heard)
        assertEquals(emptyList<String>(), view.suggestionCache?.cachedQueries())
        view.removeHistoryDidChangeListener { }
    }

    @Test
    fun noResultsTextIsTheOnlyEmptyViewEvenWithTheScenarioPlaceholderOn() {
        val view = CYLSearchView(activity)
        view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.None
        view.showsEmptyResultsPlaceholder = true
        view.noResultsText = "No matching results"
        view.resultsDataSource = object : CYLSearchViewDataSource {
            override fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any> = emptyList()
            override fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any) = Unit
        }
        column.addView(view, LinearLayout.LayoutParams(-1, -1))
        view.showSearch(false)
        view.query = "zzz"
        assertTrue(view.isEmptyViewShowing)
        assertEquals("No matching results", view.emptyView?.titleLabel?.text?.toString())
        assertEquals("the scenario placeholder is not shown beside it", null, view.emptyResultsView?.takeIf { it.visibility == View.VISIBLE })
    }

    @Test
    fun aTappedTagReportsTextDidChangeBeforeTheSubmit() {
        val view = CYLSearchView(activity)
        view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.None
        view.suggestions = listOf("Fat", "Health")
        view.showsSuggestionsForEmptyQuery = true
        view.submitsOnSuggestionSelection = true
        view.closesOnSubmit = false
        val events = mutableListOf<String>()
        view.delegate = object : CYLSearchViewDelegate {
            override fun searchViewTextDidChange(searchView: CYLSearchView, text: String) { events += "text:$text" }
            override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean {
                events += "submit:$text"
                return true
            }
        }
        column.addView(view, LinearLayout.LayoutParams(-1, -1))
        view.showSearch(false)
        events.clear()
        view.suggestionsTagView.tagClickHandler!!.invoke(1, com.cyl.classifymenu.CYLTag(1, "Health", null as Int?))
        assertEquals(listOf("text:Health", "submit:Health"), events)
    }
}
