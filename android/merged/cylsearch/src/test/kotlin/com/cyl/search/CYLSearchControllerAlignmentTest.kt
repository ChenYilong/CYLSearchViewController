package com.cyl.search

import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.LayerDrawable
import android.widget.FrameLayout
import androidx.activity.ComponentActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
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
 * The members of the iOS `CYLSearchBar`, `CYLSearchController`, `CYLSearchNavigationBar` and `CYLSearchBarAppearance` that
 * `docs/android-api-alignment.md` maps to `CYLSearchBarView`, `CYLSearchView` and `CYLSearchNavigationBar`.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchControllerAlignmentTest {

    private val activity: ComponentActivity = Robolectric.buildActivity(ComponentActivity::class.java).setup().get()
    private val host = FrameLayout(activity)
    private var results = listOf("alpha", "beta")
    private var loaded = 0

    private val source = object : CYLSearchViewDataSource {
        override fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any> =
            results.filter { it.contains(query.trim()) }

        override fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any) {
            cell.textLabel.text = result as String
        }
    }

    @Before
    fun prepare() {
        activity.setContentView(host)
    }

    private fun searchView(): CYLSearchView = CYLSearchView(activity).also {
        host.addView(it, FrameLayout.LayoutParams(-1, -1))
        it.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.None
    }

    // CYLSearchBar

    @Test
    fun aBackgroundImageIsTheColorWithABottomBorder() {
        assertNull(CYLSearchBarView.backgroundImage(null, null))
        assertEquals(Color.RED, (CYLSearchBarView.backgroundImage(Color.RED, null) as ColorDrawable).color)
        val bordered = CYLSearchBarView.backgroundImage(null, Color.BLUE) as LayerDrawable
        assertEquals("white by default", Color.WHITE, (bordered.getDrawable(0) as ColorDrawable).color)
        assertEquals(Color.BLUE, (bordered.getDrawable(1) as ColorDrawable).color)
        assertEquals("one pixel", 1, bordered.getLayerHeight(1))
        assertNull(CYLSearchBarView.textFieldBackgroundImage(null))
        assertEquals(Color.GREEN, (CYLSearchBarView.textFieldBackgroundImage(Color.GREEN) as ColorDrawable).color)
    }

    @Test
    fun theAppearanceDrawsTheBarBackground() {
        val bar = CYLSearchBarView(activity)
        val appearance = CYLSearchBarAppearance()
        appearance.barBackgroundColor = Color.RED
        appearance.barBorderColor = Color.BLUE
        appearance.applyTo(bar)
        assertTrue("color and border: two layers", bar.background is LayerDrawable)

        appearance.barBorderColor = null
        appearance.applyTo(bar)
        assertEquals(Color.RED, (bar.background as ColorDrawable).color)

        val image = ColorDrawable(Color.MAGENTA)
        appearance.barBackgroundImage = image
        appearance.applyTo(bar)
        assertSame("the image wins over the color", image, bar.background)

        val copy = appearance.copy()
        assertSame(image, copy.barBackgroundImage)
        assertEquals(Color.RED, copy.barBackgroundColor)
        assertTrue(copy.hidesBarBackground)
    }

    @Test
    fun aBarWithoutAnyBackgroundIsTransparentUnlessItsStyleSaysOtherwise() {
        val hidden = CYLSearchBarView(activity)
        CYLSearchBarAppearance().applyTo(hidden)
        assertNull(hidden.background)
        val shown = CYLSearchBarView(activity)
        CYLSearchBarAppearance().also { it.hidesBarBackground = false }.applyTo(shown)
        assertNotNull(shown.background)
    }

    @Test
    fun theFieldTakesTheBackgroundImageOfTheStyle() {
        val bar = CYLSearchBarView(activity)
        val image = CYLSearchBarView.textFieldBackgroundImage(Color.CYAN)!!
        CYLSearchBarAppearance().also { it.textFieldBackgroundImage = image }.applyTo(bar)
        assertSame(image, bar.fieldBackgroundImage)
    }

    @Test
    fun theCancelButtonStaysEnabledUnlessTheFieldMustBeEdited() {
        val bar = CYLSearchBarView(activity)
        assertTrue(bar.alwaysEnablesCancelButton)
        assertTrue(bar.cancelButton.isEnabled)
        bar.alwaysEnablesCancelButton = false
        assertFalse("no focus, no Cancel", bar.cancelButton.isEnabled)
        bar.alwaysEnablesCancelButton = true
        assertTrue(bar.cancelButton.isEnabled)
    }

    @Test
    fun scopeTitlesMakeASegmentedControlThatTheBarGrowsFor() {
        val bar = CYLSearchBarView(activity)
        assertNull(bar.segmentedControl)
        val padding = bar.paddingBottom
        bar.scopeButtonTitles = listOf("All", "People", "Places")
        val control = bar.segmentedControl!!
        assertEquals(3, control.childCount)
        assertTrue("the first title is selected", control.checkedRadioButtonId == control.getChildAt(0).id)
        assertTrue("the bar has room for it", bar.paddingBottom > padding)
        bar.scopeButtonTitles = emptyList()
        assertNull(bar.segmentedControl)
        assertEquals(padding, bar.paddingBottom)
    }

    @Test
    fun theBackgroundViewIsTheBarAndTheHeaderFlagIsOffByDefault() {
        val bar = CYLSearchBarView(activity)
        assertSame(bar, bar.backgroundView)
        assertFalse(bar.usedAsTableHeaderView)
    }

    // CYLSearchController

    @Test
    fun theBuiltInLaunchViewShowsTheSuggestionsOfAnEmptyQuery() {
        val view = searchView()
        view.suggestions = listOf("one", "two")
        view.suggestionStyle = CYLSearchSuggestionStyle.List
        view.showsSuggestionsLaunchView = true
        assertEquals(CYLSearchSuggestionStyle.Tags, view.suggestionStyle)
        assertEquals(2, view.suggestionsFoldedRowCount)
        assertTrue(view.showsSuggestionsForEmptyQuery)
        view.showSearch(false)
        assertEquals(listOf("one", "two"), view.filteredSuggestions)
        view.showsSuggestionsLaunchView = false
        assertFalse(view.showsSuggestionsForEmptyQuery)
    }

    @Test
    fun aLaunchViewOfYoursReplacesTheBuiltInOne() {
        val view = searchView()
        view.showsSuggestionsLaunchView = true
        view.launchView = android.view.View(activity)
        assertFalse(view.showsSuggestionsLaunchView)
    }

    @Test
    fun theResultsListEvenForAnEmptyQueryWhenTheyAlwaysShow() {
        val view = searchView()
        view.resultsDataSource = source
        view.showSearch(false)
        assertTrue(view.searchResults.isEmpty())
        view.alwaysShowsSearchResultsController = true
        assertEquals(listOf("alpha", "beta"), view.searchResults)
        view.alwaysShowsSearchResultsController = false
        assertTrue(view.searchResults.isEmpty())
    }

    @Test
    fun alwaysShowingTheResultsClearsTheLaunchViews() {
        val view = searchView()
        view.showsSuggestionsLaunchView = true
        view.alwaysShowsSearchResultsController = true
        assertFalse(view.showsSuggestionsLaunchView)
        assertNull(view.launchView)
    }

    @Test
    fun theResultsHeaderIsOneRowAboveTheResults() {
        val view = searchView()
        view.resultsDataSource = source
        view.showSearch(false)
        view.query = "a"
        assertEquals(listOf("alpha", "beta"), view.searchResults)
        assertEquals(2, view.resultsTableView.adapter!!.itemCount)
        view.resultsHeaderTitleProvider = { "Results for $it" }
        assertEquals("one row more", 3, view.resultsTableView.adapter!!.itemCount)
        val adapter = view.resultsTableView.adapter!!
        val header = adapter.createViewHolder(view.resultsTableView, adapter.getItemViewType(0))
        adapter.bindViewHolder(header, 0)
        assertEquals("Results for a", (header.itemView as android.widget.TextView).text.toString())
        view.resultsHeaderTitleProvider = null
        assertEquals(2, adapter.itemCount)
    }

    @Test
    fun theCacheFooterIsAButtonBelowTheListOfSuggestions() {
        val view = searchView()
        view.suggestionStyle = CYLSearchSuggestionStyle.List
        view.suggestions = listOf("one", "two")
        view.showsSuggestionsForEmptyQuery = true
        view.showSearch(false)
        val before = view.suggestionsTableView.adapter!!.itemCount
        view.suggestionCacheFooterTitle = "Clear history"
        assertEquals(before + 1, view.suggestionsTableView.adapter!!.itemCount)
        view.suggestionCacheFooterTitle = null
        assertEquals(before, view.suggestionsTableView.adapter!!.itemCount)
    }

    @Test
    fun theResultsTableViewIsHandedOverOnce() {
        val view = searchView()
        view.delegate = object : CYLSearchViewDelegate {
            override fun searchViewDidLoadResultsTableView(searchView: CYLSearchView, tableView: RecyclerView) {
                assertSame(searchView.resultsTableView, tableView)
                loaded++
            }
        }
        view.showSearch(false)
        view.closeSearch(false)
        view.showSearch(false)
        assertEquals(1, loaded)
    }

    @Test
    fun theHeaderBarOfAListOpensTheSearchAndSettles() {
        val view = searchView()
        val list = RecyclerView(activity)
        list.layoutManager = LinearLayoutManager(activity)
        list.adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            override fun getItemCount(): Int = 3
            override fun onCreateViewHolder(parent: android.view.ViewGroup, viewType: Int): RecyclerView.ViewHolder =
                object : RecyclerView.ViewHolder(android.view.View(parent.context)) {}
            override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) = Unit
        }
        val bar = view.installSearchBar(list)
        assertTrue(bar.usedAsTableHeaderView)
        assertEquals("the bar is the first item", 4, list.adapter!!.itemCount)
        bar.delegate!!.searchBarViewDidTapWhileNotEditable(bar)
        assertTrue(view.isSearchOpen)
        view.snapsHeaderSearchBar = false
        view.snapsHeaderSearchBar = true
    }

    // CYLSearchNavigationBar

    @Test
    fun aNavigationBarHoldsTheSearchBarAndForwardsTheBackTap() {
        val bar = CYLSearchBarView(activity)
        val navigationBar = CYLSearchNavigationBar.holding(bar, true)
        assertSame(navigationBar, bar.parent)
        assertTrue(bar.embedsInToolbar)
        assertNotNull(navigationBar.navigationIcon)
        var backs = 0
        navigationBar.backHandler = { backs++ }
        navigationBar.performNavigationClick()
        assertEquals(1, backs)
        assertNull(CYLSearchNavigationBar.holding(CYLSearchBarView(activity)).navigationIcon)
    }

    private fun CYLSearchNavigationBar.performNavigationClick() {
        // The navigation button is the toolbar's ImageButton child with the navigation content description.
        (0 until childCount).map { getChildAt(it) }.filterIsInstance<android.widget.ImageButton>().first().performClick()
    }
}
