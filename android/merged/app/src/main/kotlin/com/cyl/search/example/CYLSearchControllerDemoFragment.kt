package com.cyl.search.example

import android.content.Context
import android.graphics.Typeface
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.cyl.search.CYLSearchBarNavigationIcon
import com.cyl.search.CYLSearchListView
import com.cyl.search.CYLSearchResources
import com.cyl.search.CYLSearchSuggestionCachePolicy
import com.cyl.search.CYLSearchSuggestionCell
import com.cyl.search.CYLSearchView
import com.cyl.search.CYLSearchViewDataSource
import com.cyl.search.CYLSearchViewDelegate

/**
 * The "Search controller" screen: a replica of QMUI's `QDSearchViewController` (QMUIDemo_iOS; iOS
 * `CYLSearchControllerDemoViewController`). Ten keywords in a list whose first item is the search bar
 * (`CYLSearchListView`); the search shows the core's suggestion area while the text is empty (the history, or QMUI's
 * eight suggestions, as tags), the matching keywords (twenty rows each) with the match highlighted, "No matching
 * results" when nothing matches, and ends with the back swipe. Everything is set through the core's API: the screen builds
 * no launch view, header, clear button, highlight or empty view.
 */
class CYLSearchControllerDemoFragment : CYLExamplePage(), CYLSearchViewDelegate, CYLSearchViewDataSource {

    override fun pageTitle(context: Context) = context.cylDemoText("demo.searchController")

    override fun createContent(context: Context): View {
        val list = CYLSearchListView(context)
        list.adapter = KeywordAdapter()
        val search = list.searchView
        search.apply {
            delegate = this@CYLSearchControllerDemoFragment
            resultsDataSource = this@CYLSearchControllerDemoFragment
            // The bar of the page is Cancel-style, as a UISearchBar that is active.
            searchBarView.navigationIcon = CYLSearchBarNavigationIcon.None
            searchBarView.showsCancelButton = true
            searchBarView.applyDefaultAppearance()
            searchBarView.placeholder = CYLSearchResources.localizedString(context, "search.field")
            clearsQueryOnClose = true
            closesOnSubmit = false
            supportsSwipeToDismissSearch = true
            // The launch area is the core's suggestion area: the history, newest first, under "Recent searches" with its
            // clear button, or QMUI's eight suggestions; a tapped tag becomes the query and is submitted.
            suggestions = SUGGESTIONS
            showsSuggestionsForEmptyQuery = true
            submitsOnSuggestionSelection = true
            suggestionCachePolicy = CYLSearchSuggestionCachePolicy.UserDefaults
            suggestionCacheName = HISTORY_NAME
            // The results: the match in the tint color, and the empty view when nothing is listed.
            highlightsResultMatches = true
            noResultsText = context.cylDemoText("controller.noResults")
        }
        return list
    }

    private inner class KeywordAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount() = KEYWORDS.size

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
            val density = parent.resources.displayMetrics.density
            val text = TextView(parent.context).apply {
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
                gravity = Gravity.CENTER_VERTICAL
                minHeight = (56 * density).toInt()
                setPadding((16 * density).toInt(), 0, (16 * density).toInt(), 0)
                layoutParams = RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, RecyclerView.LayoutParams.WRAP_CONTENT)
            }
            return object : RecyclerView.ViewHolder(text) {}
        }

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            (holder.itemView as TextView).text = KEYWORDS[position]
        }
    }

    // The matching keywords, twenty rows each (QDSearchViewController's table: matches.count * 20).
    override fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any> =
        matches(query).flatMap { keyword -> List(ROWS_PER_MATCH) { keyword } }

    override fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any) {
        cell.textLabel.text = result as String
        cell.textLabel.setTypeface(null, Typeface.NORMAL)
    }

    override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean = true

    override fun searchViewDidSelectResult(searchView: CYLSearchView, result: Any) {
        // A result opens a detail screen; the search stays behind it.
        val keyword = result as String
        val context = requireContext()
        val label = TextView(context).apply {
            text = keyword
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 28f)
            gravity = Gravity.CENTER
        }
        push(CYLViewPage.newInstance(keyword).also { it.content = FrameLayout(context).apply { addView(label, FrameLayout.LayoutParams(-1, -1)) } })
    }

    companion object {
        /**
         * The keywords of QDSearchViewController.
         */
        val KEYWORDS = listOf("Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat", "Metabolism", "Nuturally")

        /**
         * The suggestions QMUI's demo shows while there is no history.
         */
        val SUGGESTIONS = listOf("Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat")

        /**
         * The rows each matching keyword gets in the results.
         */
        const val ROWS_PER_MATCH = 20

        /**
         * The name of the history (a `SharedPreferences` file of the core).
         */
        const val HISTORY_NAME = "CYLSearchControllerDemo"

        /**
         * The keywords that contain `searchString` (QMUI's `range(of:)`: case sensitive); none for an empty one.
         */
        fun matches(searchString: String): List<String> =
            if (searchString.isEmpty()) emptyList() else KEYWORDS.filter { it.contains(searchString) }
    }
}
