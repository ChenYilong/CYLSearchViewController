package com.cyl.search.example

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.text.SpannableString
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLTagListView
import com.cyl.search.CYLSearchBarAppearance
import com.cyl.search.CYLSearchBarNavigationIcon
import com.cyl.search.CYLSearchListView
import com.cyl.search.CYLSearchResources
import com.cyl.search.CYLSearchSuggestionCache
import com.cyl.search.CYLSearchSuggestionCachePolicy
import com.cyl.search.CYLSearchSuggestionCell
import com.cyl.search.CYLSearchView
import com.cyl.search.CYLSearchViewDataSource
import com.cyl.search.CYLSearchViewDelegate

/**
 * The tint color of the example: the tint of `CYLSearchBarAppearance` (iOS: the system blue), also the color of Cancel.
 */
internal fun Context.cylDemoTint(): Int = CYLSearchBarAppearance.defaultAppearance(this).tintColor ?: Color.rgb(0, 104, 248)

/**
 * The recent searches (QMUI's `QDRecentSearchView`, iOS `CYLRecentSearchLaunchView`): a title with a bottom border and a
 * trash button, and the suggestions as tags (`CYLTagListView` in place of QMUI's float layout of ghost buttons). It
 * fills the space under the search bar: 26 dp of padding, 20 dp between the title and the tags. Without a history it
 * shows the eight suggestions, as QMUI's demo does.
 */
class CYLRecentSearchLaunchView(context: Context) : LinearLayout(context) {

    /**
     * The title row.
     */
    val titleLabel = TextView(context)

    /**
     * The tags.
     */
    val tagListView = CYLTagListView(context)

    /**
     * The trash button at the end of the title row: clears the history (hidden while there is none).
     */
    val clearButton = ImageButton(context)

    /**
     * The submitted searches (`CYLSearchView.suggestionCache`): newest first, no duplicates.
     */
    var historyStore: CYLSearchSuggestionCache? = null
        set(value) {
            field = value
            reload()
        }

    /**
     * The tags on show: the history, or the suggestions without one.
     */
    var queries: List<String> = SUGGESTIONS
        private set

    init {
        orientation = VERTICAL
        val density = resources.displayMetrics.density
        val padding = (26 * density).toInt()
        setPadding(padding, padding, padding, padding)
        setBackgroundColor(TypedValue().also { context.theme.resolveAttribute(android.R.attr.colorBackground, it, true) }.data)
        contentDescription = context.cylDemoText("controller.launch.label")
        tag = "CYLRecentSearchLaunchView"
        val row = LinearLayout(context).apply { gravity = Gravity.CENTER_VERTICAL }
        titleLabel.text = context.cylDemoText("controller.recent")
        titleLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
        androidx.core.view.ViewCompat.setAccessibilityHeading(titleLabel, true)
        row.addView(titleLabel, LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
        clearButton.setImageResource(R.drawable.cyl_ic_delete)
        clearButton.setBackgroundColor(Color.TRANSPARENT)
        clearButton.contentDescription = CYLSearchResources.localizedString(context, "search.clearRecent")
        clearButton.visibility = GONE
        clearButton.setOnClickListener {
            historyStore?.removeAllQueries()
            reload()
        }
        row.addView(clearButton, LayoutParams((44 * density).toInt(), (44 * density).toInt()))
        addView(row, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        val border = View(context).apply { setBackgroundColor(0x33888888) }
        addView(border, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, maxOf(1, density.toInt())))
        val tint = context.cylDemoTint()
        tagListView.style = CYLMenuStyle().apply {
            itemHeight = 29f
            interitemSpacing = 10f
            lineSpacing = 10f
            sectionInsets = CYLEdgeInsets(0f, 0f, 0f, 0f)
            backgroundColor = Color.TRANSPARENT
            listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED).forEach { state ->
                appearanceForState(state).apply {
                    font = CYLFont(14f)
                    textColor = tint
                    backgroundColor = Color.TRANSPARENT
                    borderColor = tint
                    borderWidth = 1f
                    cornerRadius = 4f
                    contentInsets = CYLEdgeInsets(0f, 10f, 0f, 10f)
                }
            }
        }
        tagListView.showsSectionHeaders = false
        tagListView.isScrollEnabled = false
        tagListView.allowsTapping = false
        tagListView.contentDescription = context.cylDemoText("controller.launch.label")
        addView(tagListView, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = (20 * density).toInt() })
        reload()
    }

    /**
     * Reads the history again: the tags are the history (newest first) or, without one, the suggestions.
     */
    fun reload() {
        val history = historyStore?.cachedQueries().orEmpty()
        queries = history.ifEmpty { SUGGESTIONS }
        clearButton.visibility = if (history.isEmpty()) GONE else VISIBLE
        tagListView.setTagsWithTitles(queries)
    }

    // The launch view is shown on every activation: the history may have changed since.
    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        reload()
    }

    companion object {
        /**
         * The suggestions QMUI's demo shows.
         */
        val SUGGESTIONS = listOf("Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat")
    }
}

/**
 * The "Search controller" screen: a replica of QMUI's `QDSearchViewController` (QMUIDemo_iOS; iOS
 * `CYLSearchControllerDemoViewController`). Ten keywords in a list whose first item is the search bar
 * (`CYLSearchListView`); the search shows the recent searches while the text is empty, the matching keywords (twenty
 * rows each) with the match in the tint color, "No matching results" when nothing matches, and ends with the back swipe.
 */
class CYLSearchControllerDemoFragment : CYLExamplePage(), CYLSearchViewDelegate, CYLSearchViewDataSource {

    private lateinit var launchView: CYLRecentSearchLaunchView

    override fun pageTitle(context: Context) = context.cylDemoText("demo.searchController")

    override fun createContent(context: Context): View {
        val list = CYLSearchListView(context)
        list.adapter = KeywordAdapter()
        val search = list.searchView
        launchView = CYLRecentSearchLaunchView(context)
        search.apply {
            delegate = this@CYLSearchControllerDemoFragment
            resultsDataSource = this@CYLSearchControllerDemoFragment
            launchView = this@CYLSearchControllerDemoFragment.launchView
            // The bar of the page is Cancel-style, as a UISearchBar that is active.
            searchBarView.navigationIcon = CYLSearchBarNavigationIcon.None
            searchBarView.showsCancelButton = true
            searchBarView.applyDefaultAppearance()
            searchBarView.placeholder = CYLSearchResources.localizedString(context, "search.field")
            clearsQueryOnClose = true
            closesOnSubmit = false
            supportsSwipeToDismissSearch = true
            // The history: the return key submits the query, the launch view lists the newest first and clears it.
            suggestionCachePolicy = CYLSearchSuggestionCachePolicy.UserDefaults
            suggestionCacheName = HISTORY_NAME
            showsSuggestionCacheHeader = false
        }
        launchView.historyStore = search.suggestionCache
        // The launch view stays on screen while the person searches: read the history again after each submitted query.
        search.addHistoryDidChangeListener { launchView.reload() }
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
        val keyword = result as String
        val text = SpannableString(keyword)
        val query = searchView.query.orEmpty()
        val start = if (query.isEmpty()) -1 else keyword.indexOf(query)
        if (start >= 0) {
            text.setSpan(ForegroundColorSpan(cell.context.cylDemoTint()), start, start + query.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        }
        cell.textLabel.text = text
        cell.textLabel.setTypeface(null, Typeface.NORMAL)
    }

    override fun searchViewUpdateResults(searchView: CYLSearchView, searchString: String) {
        if (searchString.isNotEmpty() && matches(searchString).isEmpty()) {
            searchView.showEmptyView(requireContext().cylDemoText("controller.noResults"))
        } else {
            searchView.hideEmptyView()
        }
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
