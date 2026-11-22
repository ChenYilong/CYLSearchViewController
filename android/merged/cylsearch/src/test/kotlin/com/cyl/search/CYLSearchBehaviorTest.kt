package com.cyl.search

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.recyclerview.widget.RecyclerView
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.cyl_header
import com.cyl.refresh.layout.CYLRefreshLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
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

    /**
     * The suggestion cache persists by design (docs/core-todo.md): every test starts from an empty default cache.
     */
    /**
     * Takes the test's views off the window, so their history observers end (Robolectric keeps the activity alive).
     */
    @org.junit.After
    fun detachTheViews() {
        activity.setContentView(FrameLayout(activity))
    }

    @org.junit.Before
    fun clearTheDefaultSuggestionCache() {
        CYLSearchSuggestionStore.cacheWithPolicy(activity, CYLSearchSuggestionCachePolicy.Database, "CYLSearchView")?.removeAllQueries()
    }

    /**
     * Runs the main looper for the refresh animations (as CYLTableViewPlaceHolder's own refresh tests do).
     */
    private fun idle() = org.robolectric.Shadows.shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(2000))

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
        view.suggestionStyle = CYLSearchSuggestionStyle.List
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
        assertEquals(View.VISIBLE, bar.iconButton.visibility)
        assertEquals(true, lastIconified)
        bar.isIconified = false
        assertEquals(View.GONE, bar.iconButton.visibility)
        assertEquals(false, lastIconified)
    }

    @Test
    fun multipleModeCompletesSelectsAndRemoves() {
        val bar = CYLSearchBarView(activity)
        bar.mode = CYLSearchBarMode.Multiple
        val events = mutableListOf<String>()
        bar.delegate = object : CYLSearchBarViewDelegate {
            override fun searchBarViewDidCompleteSearch(searchBarView: CYLSearchBarView, text: String, index: Int) {
                events += "complete $text $index"
            }
            override fun searchBarViewDidRemoveSearchAtIndex(searchBarView: CYLSearchBarView, index: Int) {
                events += "remove $index"
            }
            override fun searchBarViewDidSelectSearch(searchBarView: CYLSearchBarView, text: String, index: Int) {
                events += "select $text $index"
            }
            override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String, index: Int) {
                events += "change $text $index"
            }
        }
        bar.beginNewSearch()
        assertTrue(bar.isEditingNewSearch)
        bar.completeSearch()
        assertTrue("a search shorter than minimumTextLength is dropped", bar.searches.isEmpty())
        bar.beginNewSearch()
        // The field of the new search: content > scroll view > row of searches > last search > its field.
        val content = bar.newSearchButton.parent as ViewGroup
        val row = (content.getChildAt(0) as ViewGroup).getChildAt(0) as ViewGroup
        val field = (row.getChildAt(row.childCount - 1) as ViewGroup).getChildAt(0) as EditText
        field.setText("boots")
        bar.completeSearch()
        assertEquals(listOf("boots"), bar.searches)
        bar.addSearch("shoes")
        bar.addSearch("hats")
        assertEquals(2, bar.selectedSearchIndex)
        bar.selectSearch(1)
        bar.removeSearch(1)
        assertEquals(listOf("boots", "hats"), bar.searches)
        assertEquals(1, bar.selectedSearchIndex)
        assertEquals(listOf("change boots 0", "complete boots 0", "select shoes 1", "remove 1"), events)
        bar.mode = CYLSearchBarMode.Single
        assertEquals("the searches are kept while single mode shows the field", 2, bar.searches.size)
        assertEquals(View.GONE, content.visibility)
    }

    @Test
    fun multipleModeSharesTheBarProperties() {
        val bar = CYLSearchBarView(activity)
        bar.mode = CYLSearchBarMode.Multiple
        bar.placeholder = "Find"
        bar.maximumTextLength = 4
        bar.addSearch("sneakers")
        assertEquals("maximumTextLength cuts an added search", listOf("snea"), bar.searches)
        bar.beginNewSearch()
        assertTrue(bar.isEditingNewSearch)
        bar.removeSearch(1)
        assertFalse("removing the search being typed ends typing", bar.isEditingNewSearch)
    }

    @Test
    fun resources() {
        assertNotNull(CYLSearchResources.imageNamed(activity, "CYLSearchNoResults"))
        assertEquals("Cancel", CYLSearchResources.localizedString(activity, "search.cancel"))
        assertEquals("取消", CYLSearchResources.localizedString(activity, "search.cancel", "zh-Hans"))
        assertEquals("missing.key", CYLSearchResources.localizedString(activity, "missing.key"))
    }

    private class Source(private val items: List<String>) : CYLSearchViewDataSource {
        var queries = 0

        override fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any> {
            queries += 1
            return items.filter { it.contains(query, ignoreCase = true) }
        }

        override fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any) {
            cell.textLabel.text = result as String
        }
    }

    @Test
    fun resultsDataSourceListsResultsInsteadOfSuggestions() {
        val view = searchView()
        view.suggestionStyle = CYLSearchSuggestionStyle.List
        view.suggestions = listOf("Android", "Kotlin")
        val source = Source(listOf("Apple", "Apricot", "Banana"))
        var selected: Any? = null
        view.delegate = object : CYLSearchViewDelegate {
            override fun searchViewDidSelectResult(searchView: CYLSearchView, result: Any) {
                selected = result
            }
        }
        view.showSearch(false)
        view.query = "a"
        assertEquals("no data source: suggestions only", listOf("Android"), view.filteredSuggestions)
        assertTrue(view.searchResults.isEmpty())
        view.resultsDataSource = source
        view.query = "ap"
        assertEquals(listOf<Any>("Apple", "Apricot"), view.searchResults)
        val results = view.resultsTableView.parent as View
        assertEquals(View.VISIBLE, results.visibility)
        assertEquals(View.GONE, view.suggestionsTableView.visibility)
        view.resultsTableView.measure(0, 0)
        view.resultsTableView.layout(0, 0, 1080, 1920)
        val cell = view.resultsTableView.findViewHolderForAdapterPosition(1)!!.itemView as CYLSearchSuggestionCell
        assertEquals("Apricot", cell.textLabel.text.toString())
        cell.performClick()
        assertEquals("Apricot", selected)

        // An empty query shows the suggestions again; an empty result list shows the empty results placeholder.
        view.query = ""
        assertTrue(view.searchResults.isEmpty())
        assertEquals(View.GONE, results.visibility)
        view.showsEmptyResultsPlaceholder = true
        view.query = "zzz"
        assertEquals(View.VISIBLE, view.emptyResultsView?.visibility)

        // reloadResults() asks the data source again for the current query.
        val before = source.queries
        view.query = "ban"
        view.reloadResults()
        assertEquals(before + 2, source.queries)
        assertEquals(listOf<Any>("Banana"), view.searchResults)
    }

    @Test
    fun focusAloneChangesNothingBelowTheResults() {
        val view = searchView()
        val source = Source(listOf("Apple"))
        view.resultsDataSource = source
        view.showSearch(false)
        view.query = "app"
        val queries = source.queries
        view.searchBarView.textField.requestFocus()
        view.searchBarView.textField.clearFocus()
        assertEquals(queries, source.queries)
        assertEquals(listOf<Any>("Apple"), view.searchResults)
    }

    @Test
    fun refreshApiOfTheResultsList() {
        val view = searchView()
        view.resultsDataSource = Source(listOf("Apple"))
        view.showSearch(false)
        view.query = "app"
        val container = view.resultsTableView.parent as CYLRefreshLayout
        var pulls = 0
        assertNull("no handler: no CYLTableViewPlaceHolder header", container.cyl_header)
        view.beginRefreshing()
        assertFalse("no handler: nothing to refresh", view.isRefreshing)
        view.refreshHandler = { pulls += 1 }
        assertTrue(container.cyl_header is CYLRefreshNormalHeader)
        view.beginRefreshing()
        idle()
        assertTrue(view.isRefreshing)
        assertEquals(1, pulls)
        view.beginRefreshing()
        idle()
        assertEquals("already refreshing", 1, pulls)
        view.endRefreshing()
        idle()
        assertFalse(view.isRefreshing)
        view.refreshHandler = null
        assertNull("removing the handler removes the header", container.cyl_header)
        assertFalse(view.isRefreshing)
    }

    @Test
    fun refreshApiOfAnotherScrollView() {
        val host = LinearLayout(activity)
        activity.setContentView(host)
        val list = RecyclerView(activity)
        val params = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f)
        host.addView(View(activity))
        host.addView(list, params)
        var pulls = 0
        CYLSearchView.setRefreshHandler({ pulls += 1 }, list)
        val container = list.parent as CYLRefreshLayout
        assertEquals("the container takes the list's place", 1, host.indexOfChild(container))
        assertSame(params, container.layoutParams)
        assertTrue(container.cyl_header is CYLRefreshNormalHeader)
        CYLSearchView.beginRefreshing(list)
        idle()
        assertTrue(CYLSearchView.isRefreshing(list))
        assertEquals(1, pulls)
        CYLSearchView.endRefreshing(list)
        idle()
        assertFalse(CYLSearchView.isRefreshing(list))
        CYLSearchView.setRefreshHandler({ pulls += 10 }, list)
        assertSame("the same container is reused", container, list.parent)
        CYLSearchView.setRefreshHandler(null, list)
        assertSame("removing the handler puts the list back", host, list.parent)
        assertEquals(1, host.indexOfChild(list))
        assertSame(params, list.layoutParams)
        CYLSearchView.beginRefreshing(list)
        assertFalse(CYLSearchView.isRefreshing(list))
    }

    @Test
    fun showSearchInAHostAndCloseWithACompletion() {
        val host = FrameLayout(activity)
        activity.setContentView(host)
        val view = CYLSearchView(activity)
        val events = mutableListOf<String>()
        view.delegate = object : CYLSearchViewDelegate {
            override fun searchViewDidClose(searchView: CYLSearchView) {
                events += "close"
            }
        }
        view.showSearch(host, false)
        assertSame(host, view.parent)
        assertTrue(view.isSearchOpen)
        view.closeSearch(false) { events += "completion" }
        assertFalse(view.isSearchOpen)
        assertEquals(listOf("close", "completion"), events)
        view.closeSearch(false) { events += "not open" }
        assertEquals("a completion runs right away when the search is not open", "not open", events.last())
        view.showSearch(activity, false)
        assertSame(activity.findViewById<ViewGroup>(android.R.id.content), view.parent)
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
            assertEquals("no match shows it ($style)", View.VISIBLE, view.emptyResultsView?.visibility)
            assertEquals(com.cyl.placeholder.CYLPlaceholderScenario.NoSearchResults, view.emptyResultsView?.scenario)
            assertEquals("No matching results", view.emptyResultsView?.titleLabel?.text.toString())
            view.query = "swi"
            assertEquals("a match hides it ($style)", View.GONE, view.emptyResultsView?.visibility)
            view.query = ""
            assertEquals("an empty query hides it ($style)", View.GONE, view.emptyResultsView?.visibility)
        }
        view.emptyResultsScenario = com.cyl.placeholder.CYLPlaceholderScenario.NoContent
        view.query = "zzz"
        assertEquals(com.cyl.placeholder.CYLPlaceholderScenario.NoContent, view.emptyResultsView?.scenario)
    }
}
