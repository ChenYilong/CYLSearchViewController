package com.cyl.search.example

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.appcompat.app.AlertDialog
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.cyl.search.CYLSearchController
import com.cyl.search.CYLSearchPlaceholderKind
import com.cyl.search.CYLSearchPlaceholderView
import com.cyl.search.CYLSearchResources
import com.cyl.search.CYLSearchResultsDataSource
import com.cyl.search.CYLSearchResultsViewController
import com.cyl.search.CYLSearchSuggestionCell
import com.google.android.material.appbar.MaterialToolbar

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
 * Forty localized sample results, filtered by the query; also the example's refresh provider (iOS
 * `CYLSearchExampleDataSource`).
 */
class CYLSearchExampleDataSource(private val items: List<String>) : CYLSearchResultsDataSource, CYLSearchExampleRefreshing {

    override fun searchResultsViewControllerResultsForQuery(controller: CYLSearchResultsViewController, query: String): List<Any> =
        if (query.isEmpty()) items else items.filter { it.contains(query, ignoreCase = true) }

    override fun searchResultsViewControllerConfigureCell(controller: CYLSearchResultsViewController, cell: CYLSearchSuggestionCell, result: Any) {
        cell.textLabel.text = result as? String
    }

    override fun reload(completion: (Throwable?) -> Unit) {
        Handler(Looper.getMainLooper()).postDelayed({ completion(null) }, 400)
    }

    companion object {
        /**
         * The data source of the example: "Sample result 1" to "Sample result 40" in the app's language.
         */
        fun sample(context: android.content.Context) = CYLSearchExampleDataSource(
            (1..40).map { context.getString(com.cyl.search.R.string.cyl_sample_result, it) },
        )
    }
}

/**
 * The search example (iOS `CYLSearchExampleViewController`): a `CYLSearchResultsViewController` with pull to refresh
 * and an empty state (`CYLSearchPlaceholderView`); "Overlay" opens `CYLSearchController`. The iOS "Repro" button
 * switches a UIKit navigation-item setting of Issue #1317 and has no Android counterpart.
 */
class CYLSearchExampleFragment : CYLSearchResultsViewController() {

    private var overlay: CYLSearchController? = null
    private lateinit var refresh: SwipeRefreshLayout
    private lateinit var placeholder: CYLSearchPlaceholderView

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        if (searchDataSource == null) {
            searchDataSource = CYLSearchExampleDataSource.sample(context)
        }
        val content = super.onCreateView(inflater, container, savedInstanceState) as LinearLayout
        searchController.placeholder = CYLSearchResources.localizedString(context, "search.placeholder")
        // The list and the empty state inside pull to refresh; the list keeps refreshing while the empty state shows.
        val index = content.indexOfChild(tableView)
        val params = tableView.layoutParams
        content.removeView(tableView)
        placeholder = CYLSearchPlaceholderView(context, CYLSearchPlaceholderKind.NoResults)
        placeholder.visibility = View.GONE
        placeholder.contentDescription = "CYLSearchEmptyState"
        val stack = FrameLayout(context).apply {
            addView(tableView, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            addView(placeholder, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        }
        refresh = SwipeRefreshLayout(context).apply {
            addView(stack)
            setOnRefreshListener { reload() }
        }
        content.addView(refresh, index, params)
        val toolbar = MaterialToolbar(context).apply {
            title = CYLSearchResources.localizedString(context, "search.title")
            menu.add(CYLSearchResources.localizedString(context, "action.overlay")).setOnMenuItemClickListener {
                showOverlay()
                true
            }.setShowAsAction(android.view.MenuItem.SHOW_AS_ACTION_ALWAYS)
        }
        content.addView(toolbar, 0, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        content.setBackgroundColor(TypedValue().let {
            context.theme.resolveAttribute(android.R.attr.colorBackground, it, true)
            it.data
        })
        content.id = View.generateViewId()
        return content
    }

    private fun reload() {
        (searchDataSource as? CYLSearchExampleRefreshing)?.reload { error ->
            if (!isAdded) return@reload
            refresh.isRefreshing = false
            if (error != null) {
                AlertDialog.Builder(requireContext())
                    .setTitle(CYLSearchResources.localizedString(requireContext(), "refresh.error"))
                    .setMessage(error.localizedMessage)
                    .setPositiveButton(CYLSearchResources.localizedString(requireContext(), "action.ok"), null)
                    .show()
            } else {
                reloadSearchResults()
            }
        }
    }

    private fun showOverlay() {
        val source = searchDataSource ?: return
        val controller = overlay ?: CYLSearchController(source).also { overlay = it }
        controller.showInViewController(this)
    }

    override fun reloadResultsTableView() {
        super.reloadResultsTableView()
        if (::placeholder.isInitialized) {
            placeholder.visibility = if (searchResults.isEmpty()) View.VISIBLE else View.GONE
        }
    }
}
