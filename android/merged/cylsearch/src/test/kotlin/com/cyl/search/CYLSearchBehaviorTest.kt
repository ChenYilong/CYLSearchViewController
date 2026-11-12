package com.cyl.search

import android.app.Activity
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowLooper

/**
 * The behaviors the iOS library documents, checked on the Kotlin port (docs/android-api-alignment.md).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchBehaviorTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun searchView(): CYLSearchView {
        val host = FrameLayout(activity)
        activity.setContentView(host)
        return CYLSearchView(activity).also { it.installInView(host) }
    }

    @Test
    fun suggestionsFilterIgnoringCaseAndDiacritics() {
        val view = searchView()
        view.suggestions = listOf("Café", "Android", "cafeteria", "Kotlin")
        view.query = "CAFE"
        assertEquals(listOf("Café", "cafeteria"), view.filteredSuggestions)
        view.query = ""
        assertTrue(view.filteredSuggestions.isEmpty())
        view.showsSuggestionsForEmptyQuery = true
        assertEquals(4, view.filteredSuggestions.size)
        view.suggestionFilter = { suggestion, query -> suggestion.startsWith(query) }
        view.query = "K"
        assertEquals(listOf("Kotlin"), view.filteredSuggestions)
    }

    @Test
    fun submitClosesUnlessTheDelegateHandlesIt() {
        val view = searchView()
        var submitted = ""
        var handled = false
        view.delegate = object : CYLSearchViewDelegate {
            override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean {
                submitted = text
                return handled
            }
        }
        view.showSearch(false)
        assertTrue(view.isSearchOpen)
        handled = true
        view.setQuery("kotlin", true)
        assertEquals("kotlin", submitted)
        assertTrue(view.isSearchOpen)
        handled = false
        view.setQuery("swift", true)
        ShadowLooper.idleMainLooper()
        assertFalse(view.isSearchOpen)
    }

    @Test
    fun navigationButtonClosesByDefault() {
        val view = searchView()
        view.showSearch(false)
        view.searchBarView.navigationButton.performClick()
        ShadowLooper.idleMainLooper()
        assertFalse(view.isSearchOpen)
    }

    @Test
    fun selectingASuggestionFillsTheQuery() {
        val view = searchView()
        var selected = -1
        view.delegate = object : CYLSearchViewDelegate {
            override fun searchViewDidSelectSuggestion(searchView: CYLSearchView, suggestion: String, index: Int) {
                selected = index
            }
        }
        view.suggestions = listOf("Android", "Apple")
        view.showSearch(false)
        view.query = "a"
        view.suggestionsTableView.measure(0, 0)
        view.suggestionsTableView.layout(0, 0, 1080, 1920)
        view.suggestionsTableView.findViewHolderForAdapterPosition(1)!!.itemView.performClick()
        assertEquals(1, selected)
        assertEquals("Apple", view.query)
    }

    @Test
    fun searchBarSubmitAsksTheDelegateAndSkipsBlankText() {
        val bar = CYLSearchBarView(activity)
        var clicks = 0
        bar.delegate = object : CYLSearchBarViewDelegate {
            override fun searchBarViewShouldSubmitText(searchBarView: CYLSearchBarView, text: String) = text != "no"
            override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
                clicks++
            }
        }
        bar.text = "   "
        assertFalse(bar.submit())
        bar.text = "no"
        assertFalse(bar.submit())
        bar.setText("yes", true)
        assertEquals(1, clicks)
    }

    @Test
    fun searchBarLimitsTheTextAndReportsTyping() {
        val bar = CYLSearchBarView(activity)
        var reported = ""
        bar.delegate = object : CYLSearchBarViewDelegate {
            override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) {
                reported = text
            }
        }
        bar.text = "programmatic"
        assertEquals("", reported)
        bar.textField.setText("typed")
        assertEquals("typed", reported)
        bar.maximumTextLength = 3
        assertEquals("typ", bar.text)
    }

    @Test
    fun searchBarIconifiedShowsOnlyTheButton() {
        val bar = CYLSearchBarView(activity)
        var lastIconified: Boolean? = null
        bar.delegate = object : CYLSearchBarViewDelegate {
            override fun searchBarViewDidChangeIconified(searchBarView: CYLSearchBarView, iconified: Boolean) {
                lastIconified = iconified
            }
        }
        bar.isIconified = true
        assertTrue(bar.isIconified)
        assertEquals(android.view.View.VISIBLE, bar.iconButton.visibility)
        assertEquals(true, lastIconified)
        bar.isIconified = false
        assertEquals(android.view.View.GONE, bar.iconButton.visibility)
        assertEquals(false, lastIconified)
    }

    @Test
    fun multiSearchCompletesSelectsAndRemoves() {
        val view = CYLMultiSearchView(activity)
        val events = mutableListOf<String>()
        view.delegate = object : CYLMultiSearchViewDelegate {
            override fun multiSearchViewDidCompleteSearch(multiSearchView: CYLMultiSearchView, text: String, index: Int) {
                events += "complete $text $index"
            }
            override fun multiSearchViewDidRemoveItemAtIndex(multiSearchView: CYLMultiSearchView, index: Int) {
                events += "remove $index"
            }
            override fun multiSearchViewDidSelectItem(multiSearchView: CYLMultiSearchView, text: String, index: Int) {
                events += "select $text $index"
            }
        }
        view.search()
        assertTrue(view.isInSearchMode)
        view.completeSearch()
        assertTrue(view.searchTexts.isEmpty())
        view.addSearchText("shoes")
        view.addSearchText("hats")
        assertEquals(1, view.selectedIndex)
        view.selectItemAtIndex(0)
        view.removeItemAtIndex(0)
        assertEquals(listOf("hats"), view.searchTexts)
        assertEquals(0, view.selectedIndex)
        assertEquals(listOf("select shoes 0", "remove 0"), events)
    }

    @Test
    fun placeholdersAndResources() {
        assertEquals("CYLSearchNoResults", CYLSearchPlaceholderView.imageNameForStyle(CYLSearchPlaceholderStyle.NoResults))
        assertNotNull(CYLSearchResources.imageNamed(activity, "CYLSearchNoResults"))
        val placeholder = CYLSearchPlaceholderView(activity, CYLSearchPlaceholderKind.NoResults)
        assertEquals("No matching results", placeholder.textLabel.text.toString())
        assertEquals("Cancel", CYLSearchResources.localizedString(activity, "search.cancel"))
        assertEquals("取消", CYLSearchResources.localizedString(activity, "search.cancel", "zh-Hans"))
        assertEquals("missing.key", CYLSearchResources.localizedString(activity, "missing.key"))
        try {
            CYLSearchPlaceholderView.imageNameForStyle(CYLSearchPlaceholderStyle.Count)
            throw AssertionError("Count has no image")
        } catch (expected: IllegalArgumentException) {
            assertTrue(expected.message!!.startsWith("Unknown placeholder style"))
        }
    }

    @Test
    fun emptyResultsShowTheCYLTableViewPlaceHolderPlaceholder() {
        val view = searchView()
        view.suggestions = listOf("Android", "Kotlin", "Swift")
        view.showSearch(false)
        view.query = "zzz"
        assertEquals("off by default", null, view.emptyResultsView)
        view.showsEmptyResultsPlaceholder = true
        for (style in CYLSearchSuggestionStyle.entries) {
            view.suggestionStyle = style
            view.query = "zzz"
            assertEquals("no match shows it ($style)", android.view.View.VISIBLE, view.emptyResultsView?.visibility)
            assertEquals(com.cyl.placeholder.CYLPlaceholderScenario.NoSearchResults, view.emptyResultsView?.scenario)
            assertEquals("No matching results", view.emptyResultsView?.titleLabel?.text.toString())
            view.query = "swi"
            assertEquals("a match hides it ($style)", android.view.View.GONE, view.emptyResultsView?.visibility)
            view.query = ""
            assertEquals("an empty query hides it ($style)", android.view.View.GONE, view.emptyResultsView?.visibility)
        }
        view.emptyResultsScenario = com.cyl.placeholder.CYLPlaceholderScenario.NoContent
        view.query = "zzz"
        assertEquals(com.cyl.placeholder.CYLPlaceholderScenario.NoContent, view.emptyResultsView?.scenario)
    }
}
