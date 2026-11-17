package com.cyl.search.example

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.appcompat.app.AlertDialog
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.placeholder.CYLPlaceholderStackView
import com.cyl.search.CYLSearchBarView
import com.cyl.search.CYLSearchBarViewDelegate
import com.cyl.search.CYLSearchResources
import com.cyl.search.CYLSearchSuggestionCell
import com.cyl.search.CYLSearchView
import com.cyl.search.CYLSearchViewDataSource
import java.lang.ref.WeakReference

/**
 * Reloads the example's data for pull to refresh (iOS `CYLSearchExampleRefreshing`).
 */
interface CYLSearchExampleRefreshing {

    /**
     * Reloads, then calls `completion` with null or the error.
     */
    fun reload(completion: (Throwable?) -> Unit)
}

/**
 * Forty localized sample results, filtered by the query; the results of the overlay's `CYLSearchView` and the
 * example's refresh provider (iOS `CYLSearchExampleDataSource`).
 */
class CYLSearchExampleDataSource(private val items: List<String>) : CYLSearchViewDataSource, CYLSearchExampleRefreshing {

    /**
     * The items that contain `query`, every item for an empty query.
     */
    fun results(query: String): List<String> =
        if (query.isBlank()) items else items.filter { it.contains(query.trim(), ignoreCase = true) }

    override fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any> = results(query)

    override fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any) {
        cell.textLabel.text = result as? String
    }

    override fun reload(completion: (Throwable?) -> Unit) {
        Handler(Looper.getMainLooper()).postDelayed({ completion(null) }, 400)
    }

    companion object {
        /**
         * The data source of the example: "Sample result 1" to "Sample result 40" in the app's language.
         */
        fun sample(context: Context) = CYLSearchExampleDataSource(
            (1..40).map { context.getString(com.cyl.search.R.string.cyl_sample_result, it) },
        )
    }
}

/**
 * The search example (iOS `CYLSearchExampleViewController`, the Issue #1317 page): a search bar above a list with pull
 * to refresh (`CYLSearchView.setRefreshHandler`) and an empty state (CYLTableViewPlaceHolder's no-results scenario);
 * "Overlay" opens a `CYLSearchView` with the same results (`resultsDataSource`) and its own pull to refresh
 * (`refreshHandler`). The iOS "Repro" button switches a UIKit navigation-item setting of Issue #1317 and has no Android
 * counterpart.
 */
class CYLSearchExampleFragment : CYLExamplePage() {

    private val source by lazy { CYLSearchExampleDataSource.sample(requireContext()) }
    private var overlay: CYLSearchView? = null
    private var list: RecyclerView? = null
    private var emptyState: View? = null
    private var query = ""
    private var rows: List<String> = emptyList()
    private val adapter = ResultsAdapter()

    override fun pageTitle(context: Context) = CYLSearchResources.localizedString(context, "search.title")

    override fun onCreateActions(menu: Menu) {
        menu.add(CYLSearchResources.localizedString(requireContext(), "action.overlay")).setOnMenuItemClickListener {
            showOverlay()
            true
        }.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
    }

    override fun createContent(context: Context): View {
        val searchBar = CYLSearchBarView(context).apply {
            placeholder = CYLSearchResources.localizedString(context, "search.placeholder")
            delegate = object : CYLSearchBarViewDelegate {
                override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) = filter(text)
                override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) = searchBarView.hideKeyboard()
            }
        }
        val list = RecyclerView(context).apply {
            layoutManager = LinearLayoutManager(context)
            adapter = this@CYLSearchExampleFragment.adapter
        }
        this.list = list
        // The list keeps refreshing while the empty state shows above it.
        val emptyState = CYLPlaceholderStackView(context, CYLPlaceholderScenario.NoSearchResults).apply {
            visibility = View.GONE
            contentDescription = "CYLSearchEmptyState"
        }
        this.emptyState = emptyState
        val stack = FrameLayout(context).apply {
            addView(list, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            addView(emptyState, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        }
        // The handler holds the page weakly (AGENTS.md, Issue #1317) and always ends the refresh.
        val page = WeakReference(this)
        CYLSearchView.setRefreshHandler({ page.get()?.reloadList() }, list)
        filter(query)
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(searchBar, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(stack, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        }
    }

    override fun onDestroyView() {
        overlay?.let { (it.parent as? ViewGroup)?.removeView(it) }
        overlay = null
        list = null
        emptyState = null
        super.onDestroyView()
    }

    @Suppress("NotifyDataSetChanged")
    private fun filter(text: String) {
        query = text
        rows = source.results(text)
        adapter.notifyDataSetChanged()
        emptyState?.visibility = if (rows.isEmpty()) View.VISIBLE else View.GONE
    }

    private fun reloadList() {
        source.reload { error ->
            val list = list ?: return@reload
            CYLSearchView.endRefreshing(list)
            if (error != null) showError(error) else filter(query)
        }
    }

    private fun reloadOverlay() {
        source.reload { error ->
            val overlay = overlay ?: return@reload
            overlay.endRefreshing()
            if (error != null) showError(error) else overlay.reloadResults()
        }
    }

    private fun showError(error: Throwable) {
        val context = context ?: return
        AlertDialog.Builder(context)
            .setTitle(CYLSearchResources.localizedString(context, "refresh.error"))
            .setMessage(error.localizedMessage)
            .setPositiveButton(CYLSearchResources.localizedString(context, "action.ok"), null)
            .show()
    }

    private fun showOverlay() {
        val searchView = overlay ?: CYLSearchView(requireContext()).also { searchView ->
            val page = WeakReference(this)
            searchView.searchBarView.placeholder = CYLSearchResources.localizedString(requireContext(), "search.placeholder")
            searchView.resultsDataSource = source
            searchView.showsEmptyResultsPlaceholder = true
            searchView.closesOnSubmit = false
            searchView.refreshHandler = { page.get()?.reloadOverlay() }
            overlay = searchView
        }
        searchView.showSearch(requireActivity())
    }

    private inner class ResultsAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount(): Int = rows.size

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder =
            object : RecyclerView.ViewHolder(CYLSearchSuggestionCell(parent.context).apply {
                layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                imageView.visibility = View.GONE
            }) {}

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            (holder.itemView as CYLSearchSuggestionCell).textLabel.text = rows[position]
        }
    }
}
