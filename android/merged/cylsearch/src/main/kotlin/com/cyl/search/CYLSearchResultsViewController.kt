package com.cyl.search

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

/**
 * Supplies the results of a `CYLSearchResultsViewController` and configures their cells.
 */
interface CYLSearchResultsDataSource {

    /**
     * The results for `query` (an empty string while nothing is typed).
     */
    fun searchResultsViewControllerResultsForQuery(controller: CYLSearchResultsViewController, query: String): List<Any>

    /**
     * Shows `result` in `cell`.
     */
    fun searchResultsViewControllerConfigureCell(controller: CYLSearchResultsViewController, cell: CYLSearchSuggestionCell, result: Any)

    /**
     * A result was tapped. Optional.
     */
    fun searchResultsViewControllerDidSelectResult(controller: CYLSearchResultsViewController, result: Any) {}
}

/**
 * A list of search results under a search bar, driven by a `CYLSearchResultsDataSource` (iOS
 * `CYLSearchResultsViewController`, a `UITableViewController` with a navigation-item search bar). The bar sits above
 * the list, never over it. After the system recreates the fragment, set `searchDataSource` again.
 */
open class CYLSearchResultsViewController() : Fragment() {

    /**
     * Creates the controller with its data source.
     */
    constructor(searchDataSource: CYLSearchResultsDataSource) : this() {
        this.searchDataSource = searchDataSource
    }

    /**
     * The data source given at creation.
     */
    var searchDataSource: CYLSearchResultsDataSource? = null
        set(value) {
            field = value
            if (view != null) {
                reloadSearchResults()
            }
        }

    /**
     * The search bar above the list (iOS `searchController`, the navigation-item search bar). Available once the
     * view is created.
     */
    lateinit var searchController: CYLSearchBarView
        private set

    /**
     * The list of results (iOS `tableView`). Available once the view is created.
     */
    lateinit var tableView: RecyclerView
        private set

    /**
     * The results of the last query.
     */
    var searchResults: List<Any> = emptyList()
        private set

    private val adapter = ResultsAdapter()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        searchController = CYLSearchBarView(context)
        searchController.placeholder = CYLSearchResources.localizedString(context, "search.field")
        searchController.delegate = object : CYLSearchBarViewDelegate {
            override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) = updateSearchResults()
            override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) = searchBarView.hideKeyboard()
        }
        tableView = RecyclerView(context)
        tableView.layoutManager = LinearLayoutManager(context)
        tableView.adapter = adapter
        tableView.clipToPadding = false
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(searchController, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(tableView, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
            ViewCompat.setOnApplyWindowInsetsListener(tableView) { list, insets ->
                val bottom = maxOf(insets.getInsets(WindowInsetsCompat.Type.ime()).bottom, insets.getInsets(WindowInsetsCompat.Type.systemBars()).bottom)
                list.setPadding(0, 0, 0, bottom)
                insets
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        reloadSearchResults()
    }

    /**
     * Requeries the data source using the current search text and reloads the list.
     */
    open fun reloadSearchResults() {
        val query = searchController.text.orEmpty()
        searchResults = searchDataSource?.searchResultsViewControllerResultsForQuery(this, query) ?: emptyList()
        reloadResultsTableView()
    }

    /**
     * Override to integrate a custom list reload, such as an empty-state provider.
     */
    @Suppress("NotifyDataSetChanged")
    open fun reloadResultsTableView() {
        adapter.notifyDataSetChanged()
    }

    /**
     * Requeries the results when the search text changes (iOS `updateSearchResults(for:)`).
     */
    open fun updateSearchResults() = reloadSearchResults()

    private inner class ResultsAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount(): Int = searchResults.size

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder =
            object : RecyclerView.ViewHolder(CYLSearchSuggestionCell(parent.context).apply {
                layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                imageView.visibility = View.GONE
            }) {}

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            val cell = holder.itemView as CYLSearchSuggestionCell
            val result = searchResults[position]
            searchDataSource?.searchResultsViewControllerConfigureCell(this@CYLSearchResultsViewController, cell, result)
            cell.setOnClickListener {
                searchResults.getOrNull(holder.bindingAdapterPosition)?.let {
                    searchDataSource?.searchResultsViewControllerDidSelectResult(this@CYLSearchResultsViewController, it)
                }
            }
        }
    }
}
