package com.cyl.search

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.os.Parcelable
import android.text.TextUtils
import android.util.AttributeSet
import android.util.SparseArray
import android.util.TypedValue
import android.view.Gravity
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.widget.ImageViewCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.classifymenu.CYLTagListView
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.placeholder.CYLPlaceholderStackView
import java.text.Normalizer
import java.util.Locale

/**
 * How a long suggestion is cut (iOS `NSLineBreakMode`).
 */
enum class CYLLineBreakMode {
    /**
     * The whole text on several lines, wrapped at word boundaries.
     */
    WordWrapping,

    /**
     * The whole text on several lines, wrapped at any character.
     */
    CharWrapping,

    /**
     * One line, cut off at the edge.
     */
    Clipping,

    /**
     * One line with an ellipsis at the start.
     */
    TruncatingHead,

    /**
     * One line with an ellipsis at the end.
     */
    TruncatingTail,

    /**
     * One line with an ellipsis in the middle.
     */
    TruncatingMiddle,
}

/**
 * How the suggestions are shown under the search bar (`CYLSearchView.suggestionStyle`).
 */
enum class CYLSearchSuggestionStyle {
    /**
     * One suggestion per row with its icon (`suggestionsTableView`; iOS table view).
     */
    List,

    /**
     * Tags that wrap like words (`suggestionsTagView`, CollectionViewClassifyMenu's `CYLTagListView`; iOS collection
     * view).
     */
    Tags,
}

/**
 * Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button. Every method
 * is optional.
 */
interface CYLSearchViewDelegate {

    /**
     * The search view finished opening (MaterialSearchView `onSearchViewShown`).
     */
    fun searchViewDidShow(searchView: CYLSearchView) {}

    /**
     * The search view finished closing (MaterialSearchView `onSearchViewClosed`).
     */
    fun searchViewDidClose(searchView: CYLSearchView) {}

    /**
     * The query changed (`onQueryTextChange`).
     */
    fun searchViewTextDidChange(searchView: CYLSearchView, text: String) {}

    /**
     * The query was submitted (`onQueryTextSubmit`). Return true when you handled it and the search view stays open;
     * return false (the default) to let the search view close.
     */
    fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean = false

    /**
     * The field started or stopped editing (lapism `OnFocusChangeListener`).
     */
    fun searchViewDidChangeFocus(searchView: CYLSearchView, focused: Boolean) {}

    /**
     * A suggestion was tapped (MaterialSearchView `setOnItemClickListener`). The field shows it first, and it is
     * submitted when `submitsOnSuggestionSelection` is true.
     */
    fun searchViewDidSelectSuggestion(searchView: CYLSearchView, suggestion: String, index: Int) {}

    /**
     * The voice button was tapped. Start speech recognition and pass the result to `setQuery(query, submit)`.
     */
    fun searchViewVoiceButtonClicked(searchView: CYLSearchView) {}

    /**
     * The navigation button (the back arrow by default) was tapped. By default it closes the search view.
     */
    fun searchViewNavigationButtonClicked(searchView: CYLSearchView) {
        searchView.closeSearch()
    }
}

/**
 * A suggestion row of a `CYLSearchView`: an icon and a text (iOS `UITableViewCell` with a list content
 * configuration).
 */
class CYLSearchSuggestionCell(context: Context) : LinearLayout(context) {

    /**
     * The icon before the text (`suggestionImage`).
     */
    val imageView: ImageView = ImageView(context)

    /**
     * The suggestion text.
     */
    val textLabel: TextView = TextView(context)

    init {
        val density = resources.displayMetrics.density
        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        minimumHeight = (48 * density).toInt()
        val horizontal = (16 * density).toInt()
        setPaddingRelative(horizontal, (11 * density).toInt(), horizontal, (11 * density).toInt())
        imageView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        addView(imageView, LayoutParams((24 * density).toInt(), (24 * density).toInt()).apply { marginEnd = horizontal })
        textLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
        addView(textLabel, LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f))
        isClickable = true
        isFocusable = true
        // The ripple is the foreground, so a row background color (`suggestionBackgroundColor`) keeps it.
        foreground = ContextCompat.getDrawable(context, TypedValue().also {
            context.theme.resolveAttribute(android.R.attr.selectableItemBackground, it, true)
        }.resourceId)
    }
}

/**
 * A search page that opens over its host view (iOS `CYLSearchView`; MiguelCatalan and lapism
 * `MaterialSearchView`): a `CYLSearchBarView` below the status bar, a divider, a list of suggestions filtered as you
 * type, and an optional content view of yours below. The page is opaque, so the bar never covers a view of the host.
 */
class CYLSearchView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(context, attrs, defStyleAttr) {

    private val density = resources.displayMetrics.density
    private val pageView = LinearLayout(context)
    private val bodyView = FrameLayout(context)
    private val scrimView = View(context)
    private val adapter = SuggestionAdapter()
    private var suggestionsVisible = false
    private var topInset = 0
    private var keyboardInset = 0
    private val backCallback = object : OnBackPressedCallback(false) {
        override fun handleOnBackPressed() = closeSearch()
    }

    /**
     * Receives the events of the search view.
     */
    var delegate: CYLSearchViewDelegate? = null

    /**
     * The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button).
     */
    val searchBarView: CYLSearchBarView = CYLSearchBarView(context)

    /**
     * The line under the search bar.
     */
    val dividerView: View = View(context)

    /**
     * The list of suggestions (iOS `suggestionsTableView`).
     */
    val suggestionsTableView: RecyclerView = RecyclerView(context)

    /**
     * The tags that show the suggestions when `suggestionStyle` is `Tags` (CollectionViewClassifyMenu's
     * `CYLTagListView`). Style it directly: colors (`colorTheme`), spacing, rows, the tag style.
     */
    val suggestionsTagView: CYLTagListView = CYLTagListView(context)

    /**
     * How the suggestions are shown: a list (`List`, the default) or tags (`Tags`).
     */
    var suggestionStyle: CYLSearchSuggestionStyle = CYLSearchSuggestionStyle.List
        set(value) {
            field = value
            updateSuggestionsVisibility()
        }

    /**
     * Shows CYLTableViewPlaceHolder's placeholder for `emptyResultsScenario` under the search bar while a non-empty
     * query matches no suggestion, in both suggestion styles. False by default.
     */
    var showsEmptyResultsPlaceholder: Boolean = false
        set(value) {
            field = value
            refilter()
        }

    /**
     * The CYLTableViewPlaceHolder scenario of that placeholder. `NoSearchResults` (an icon, a title and a hint) by
     * default; `NoContent` shows the plain empty state.
     */
    var emptyResultsScenario: CYLPlaceholderScenario = CYLPlaceholderScenario.NoSearchResults
        set(value) {
            field = value
            emptyResultsView?.let { bodyView.removeView(it) }
            emptyResultsView = null
            refilter()
        }

    /**
     * The placeholder shown for empty results (CYLTableViewPlaceHolder's `CYLPlaceholderStackView`), created the first
     * time it is shown; null before.
     */
    var emptyResultsView: CYLPlaceholderStackView? = null
        private set

    private var emptyResultsVisible = false

    /**
     * The color of `dividerView` (lapism `setDividerColor`). The theme's divider color when null; transparent hides
     * it.
     */
    var dividerColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * A view of yours shown under the divider, behind the suggestions (lapism `addView`): a results list, a history,
     * anything. Null by default.
     */
    var contentView: View? = null
        set(value) {
            field?.let { bodyView.removeView(it) }
            field = value
            value?.let {
                (it.parent as? ViewGroup)?.removeView(it)
                bodyView.addView(it, 0, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
            }
            applyLayout()
        }

    /**
     * The color behind the page while it is open (lapism `setScrimColor`). Null (none) by default: the page fills the
     * view. With a scrim and no content view, the page is only as tall as the suggestions and the scrim (tapping it
     * closes the search) shows below.
     */
    var scrimColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The page background. The theme's window background when null.
     */
    var pageBackgroundColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    // Suggestions

    /**
     * The suggestions to filter as the text changes (MaterialSearchView `setSuggestions`).
     */
    var suggestions: List<String> = emptyList()
        set(value) {
            field = value
            refilter()
        }

    /**
     * Decides whether a suggestion matches the query: `(suggestion, query) -> Boolean`. Null uses a case- and
     * diacritic-insensitive "contains" test. An empty query matches nothing unless `showsSuggestionsForEmptyQuery`.
     */
    var suggestionFilter: ((String, String) -> Boolean)? = null
        set(value) {
            field = value
            refilter()
        }

    /**
     * Lists every suggestion while the query is empty. False by default.
     */
    var showsSuggestionsForEmptyQuery: Boolean = false
        set(value) {
            field = value
            refilter()
        }

    /**
     * The suggestions that match the current query, in their original order.
     */
    var filteredSuggestions: List<String> = emptyList()
        private set

    /**
     * The icon before each suggestion (MaterialSearchView `setSuggestionIcon`). A magnifier by default; null shows
     * none.
     */
    var suggestionImage: Drawable? = ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_search)
        set(value) {
            field = value
            reloadSuggestions()
        }

    /**
     * The tint of `suggestionImage`. The theme's secondary text color when null.
     */
    var suggestionImageTintColor: Int? = null
        set(value) {
            field = value
            reloadSuggestions()
        }

    /**
     * The background of the suggestion rows (`setSuggestionBackground`). Null keeps the page background.
     */
    var suggestionBackgroundColor: Int? = null
        set(value) {
            field = value
            suggestionsTableView.setBackgroundColor(value ?: Color.TRANSPARENT)
            reloadSuggestions()
        }

    /**
     * The color of the suggestion text. The theme's primary text color when null.
     */
    var suggestionTextColor: Int? = null
        set(value) {
            field = value
            reloadSuggestions()
        }

    /**
     * How a long suggestion is cut (MaterialSearchView `setEllipsize`). `WordWrapping` by default (whole text on
     * several lines); `TruncatingTail` keeps one line with an ellipsis.
     */
    var suggestionLineBreakMode: CYLLineBreakMode = CYLLineBreakMode.WordWrapping
        set(value) {
            field = value
            reloadSuggestions()
        }

    /**
     * Submits a suggestion as soon as it is tapped (`setSubmitOnClick`). False by default: the field shows it and the
     * person can edit it.
     */
    var submitsOnSuggestionSelection: Boolean = false

    /**
     * Configures each suggestion cell after the defaults (a custom adapter's `getView`): `(cell, suggestion, index)`.
     */
    var suggestionCellConfiguration: ((CYLSearchSuggestionCell, String, Int) -> Unit)? = null
        set(value) {
            field = value
            reloadSuggestions()
        }

    // Opening and closing

    /**
     * True while the search view is open (MaterialSearchView `isSearchOpen`).
     */
    var isSearchOpen: Boolean = false
        private set

    /**
     * The length of the open and close animations, in seconds (`setAnimationDuration`). 0.25 by default.
     */
    var animationDuration: Double = 0.25

    /**
     * Closes the search view after a submitted query that the delegate did not handle. True by default.
     */
    var closesOnSubmit: Boolean = true

    /**
     * The current query (lapism `getTextQuery`). Setting it does not submit.
     */
    var query: String?
        get() = searchBarView.text
        set(value) = setQuery(value, false)

    /**
     * Sets the page background (iOS `backgroundColor`; the view itself only shows the scrim).
     */
    override fun setBackgroundColor(color: Int) {
        pageBackgroundColor = color
    }

    init {
        visibility = GONE
        isClickable = true
        scrimView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        scrimView.setOnClickListener { closeSearch() }
        addView(scrimView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        pageView.orientation = LinearLayout.VERTICAL
        pageView.isClickable = true
        addView(pageView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT, Gravity.TOP))
        searchBarView.navigationIcon = CYLSearchBarNavigationIcon.Arrow
        searchBarView.fieldBackgroundColor = Color.TRANSPARENT
        searchBarView.delegate = BarDelegate()
        pageView.addView(searchBarView, LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        dividerView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        pageView.addView(dividerView, LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1))
        pageView.addView(bodyView, LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, 0, 1f))
        suggestionsTableView.layoutManager = LinearLayoutManager(context)
        suggestionsTableView.adapter = adapter
        suggestionsTableView.clipToPadding = false
        suggestionsTableView.contentDescription = CYLSearchResources.localizedString(context, "search.suggestions")
        suggestionsTableView.visibility = GONE
        suggestionsTableView.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                if (newState == RecyclerView.SCROLL_STATE_DRAGGING) {
                    searchBarView.hideKeyboard()
                }
            }
        })
        bodyView.addView(suggestionsTableView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        suggestionsTagView.visibility = GONE
        suggestionsTagView.showsSectionHeaders = false
        suggestionsTagView.contentDescription = CYLSearchResources.localizedString(context, "search.suggestions")
        suggestionsTagView.tagClickHandler = { index, _ -> select(index) }
        val padding = (12 * density).toInt()
        suggestionsTagView.setPadding(padding, padding, padding, padding)
        bodyView.addView(suggestionsTagView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        ViewCompat.setOnApplyWindowInsetsListener(this) { _, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout())
            topInset = bars.top
            keyboardInset = maxOf(insets.getInsets(WindowInsetsCompat.Type.ime()).bottom, bars.bottom)
            pageView.setPadding(bars.left, topInset, bars.right, 0)
            suggestionsTableView.setPadding(0, 0, 0, keyboardInset)
            insets
        }
        applyStyle()
    }

    private fun themeColor(attribute: Int): Int {
        val value = TypedValue()
        context.theme.resolveAttribute(attribute, value, true)
        return if (value.resourceId != 0) ContextCompat.getColor(context, value.resourceId) else value.data
    }

    private fun applyStyle() {
        dividerView.setBackgroundColor(dividerColor ?: (themeColor(android.R.attr.textColorPrimary) and 0x00FFFFFF or 0x1F000000))
        scrimView.setBackgroundColor(scrimColor ?: Color.TRANSPARENT)
        pageView.setBackgroundColor(pageBackgroundColor ?: themeColor(android.R.attr.colorBackground))
        applyLayout()
    }

    private fun applyLayout() {
        // With a scrim, the page is only as tall as its content and the host shows through below it.
        val wraps = scrimColor != null && contentView == null
        (pageView.layoutParams as? LayoutParams)?.let {
            it.height = if (wraps) LayoutParams.WRAP_CONTENT else LayoutParams.MATCH_PARENT
            pageView.layoutParams = it
        }
        (bodyView.layoutParams as? LinearLayout.LayoutParams)?.let {
            it.height = if (wraps) LayoutParams.WRAP_CONTENT else 0
            it.weight = if (wraps) 0f else 1f
            bodyView.layoutParams = it
        }
        (suggestionsTableView.layoutParams as? LayoutParams)?.let {
            it.height = if (wraps) LayoutParams.WRAP_CONTENT else LayoutParams.MATCH_PARENT
            suggestionsTableView.layoutParams = it
        }
        scrimView.visibility = if (scrimColor == null) GONE else VISIBLE
    }

    // Opening and closing

    /**
     * Adds the search view over `view` (filling it) without opening it. `showSearch` calls it with the activity's
     * content view when the search view has no parent.
     */
    fun installInView(view: ViewGroup) {
        if (parent !== view) {
            (parent as? ViewGroup)?.removeView(this)
            view.addView(this, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        }
        bringToFront()
    }

    private fun activity(): Activity? {
        var current: Context? = context
        while (current is ContextWrapper) {
            if (current is Activity) {
                return current
            }
            current = current.baseContext
        }
        return null
    }

    /**
     * Opens the search view with animation and starts editing (`showSearch`).
     */
    fun showSearch() = showSearch(true)

    /**
     * Opens the search view and starts editing (`showSearch(animate)`).
     */
    fun showSearch(animated: Boolean) {
        if (parent == null) {
            val host = activity()?.findViewById<ViewGroup>(android.R.id.content) ?: return
            installInView(host)
        }
        bringToFront()
        if (isSearchOpen) {
            searchBarView.showKeyboard()
            return
        }
        isSearchOpen = true
        visibility = VISIBLE
        backCallback.isEnabled = true
        refilter()
        ViewCompat.requestApplyInsets(this)
        searchBarView.showKeyboard()
        val finish = {
            searchBarView.textField.sendAccessibilityEvent(android.view.accessibility.AccessibilityEvent.TYPE_VIEW_FOCUSED)
            delegate?.searchViewDidShow(this)
        }
        animate().cancel()
        if (!animated || animationDuration <= 0) {
            alpha = 1f
            pageView.translationY = 0f
            finish()
            return
        }
        alpha = 0f
        pageView.translationY = -12 * density
        val duration = (animationDuration * 1000).toLong()
        pageView.animate().translationY(0f).setDuration(duration).start()
        animate().alpha(1f).setDuration(duration).withEndAction { finish() }.start()
    }

    /**
     * Closes the search view with animation and ends editing (`closeSearch`).
     */
    fun closeSearch() = closeSearch(true)

    /**
     * Closes the search view and ends editing.
     */
    fun closeSearch(animated: Boolean) {
        if (!isSearchOpen) {
            return
        }
        isSearchOpen = false
        backCallback.isEnabled = false
        searchBarView.hideKeyboard()
        val finish = {
            visibility = GONE
            alpha = 1f
            pageView.translationY = 0f
            delegate?.searchViewDidClose(this)
        }
        animate().cancel()
        if (!animated || animationDuration <= 0) {
            finish()
            return
        }
        val duration = (animationDuration * 1000).toLong()
        pageView.animate().translationY(-12 * density).setDuration(duration).start()
        animate().alpha(0f).setDuration(duration).withEndAction { finish() }.start()
    }

    /**
     * Makes a toolbar menu item open the search view (`setMenuItem`; iOS `attachToBarButtonItem:`).
     */
    fun attachToMenuItem(item: MenuItem) {
        item.setOnMenuItemClickListener {
            showSearch()
            true
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        (activity() as? ComponentActivity)?.onBackPressedDispatcher?.addCallback(backCallback)
        backCallback.isEnabled = isSearchOpen
    }

    override fun onDetachedFromWindow() {
        backCallback.remove()
        super.onDetachedFromWindow()
    }

    // State restoration

    override fun onSaveInstanceState(): Parcelable = Bundle().apply {
        putParcelable(STATE_SUPER, super.onSaveInstanceState())
        putString(STATE_QUERY, query.orEmpty())
        putBoolean(STATE_OPEN, isSearchOpen)
    }

    @Suppress("DEPRECATION")
    override fun onRestoreInstanceState(state: Parcelable?) {
        if (state !is Bundle) {
            super.onRestoreInstanceState(state)
            return
        }
        super.onRestoreInstanceState(state.getParcelable(STATE_SUPER))
        setQuery(state.getString(STATE_QUERY), false)
        if (state.getBoolean(STATE_OPEN)) {
            post { showSearch(false) }
        }
    }

    override fun dispatchSaveInstanceState(container: SparseArray<Parcelable>) = dispatchFreezeSelfOnly(container)

    override fun dispatchRestoreInstanceState(container: SparseArray<Parcelable>) = dispatchThawSelfOnly(container)

    // Query and suggestions

    /**
     * Sets the query and submits it when `submit` is true (`setQuery`, `setTextQuery`).
     */
    fun setQuery(query: String?, submit: Boolean) {
        searchBarView.text = query
        queryChanged(query.orEmpty())
        if (submit) {
            searchBarView.submit()
        }
    }

    private fun refilter() {
        val query = searchBarView.text.orEmpty()
        val trimmed = query.trim()
        val folded = fold(trimmed)
        filteredSuggestions = suggestions.filter { suggestion ->
            when {
                trimmed.isEmpty() -> showsSuggestionsForEmptyQuery
                suggestionFilter != null -> suggestionFilter!!.invoke(suggestion, query)
                else -> fold(suggestion).contains(folded)
            }
        }
        suggestionsVisible = filteredSuggestions.isNotEmpty()
        emptyResultsVisible = showsEmptyResultsPlaceholder && trimmed.isNotEmpty() && filteredSuggestions.isEmpty()
        updateSuggestionsVisibility()
    }

    /**
     * Lists the suggestions that match the current query (`showSuggestions`).
     */
    fun showSuggestions() = refilter()

    /**
     * Hides the suggestions (`dismissSuggestions`).
     */
    fun dismissSuggestions() {
        suggestionsVisible = false
        emptyResultsVisible = false
        updateSuggestionsVisibility()
    }

    private fun updateSuggestionsVisibility() {
        val tags = suggestionStyle == CYLSearchSuggestionStyle.Tags
        suggestionsTableView.visibility = if (suggestionsVisible && !tags) VISIBLE else GONE
        suggestionsTagView.visibility = if (suggestionsVisible && tags) VISIBLE else GONE
        if (tags) {
            suggestionsTagView.setTagsWithTitles(if (suggestionsVisible) filteredSuggestions else emptyList())
        }
        if (emptyResultsVisible && emptyResultsView == null) {
            emptyResultsView = CYLPlaceholderStackView(context, emptyResultsScenario).also {
                bodyView.addView(it, 0, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
            }
        }
        emptyResultsView?.visibility = if (emptyResultsVisible) VISIBLE else GONE
        reloadSuggestions()
    }

    @Suppress("NotifyDataSetChanged")
    private fun reloadSuggestions() = adapter.notifyDataSetChanged()

    private fun queryChanged(text: String) {
        refilter()
        delegate?.searchViewTextDidChange(this, text)
    }

    private fun select(index: Int) {
        val suggestion = filteredSuggestions.getOrNull(index) ?: return
        searchBarView.text = suggestion
        delegate?.searchViewDidSelectSuggestion(this, suggestion, index)
        if (submitsOnSuggestionSelection) {
            searchBarView.submit()
        } else {
            queryChanged(suggestion)
        }
    }

    private inner class BarDelegate : CYLSearchBarViewDelegate {
        override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) = queryChanged(text)

        override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
            val handled = delegate?.searchViewDidSubmitText(this@CYLSearchView, searchBarView.text.orEmpty()) ?: false
            if (!handled && closesOnSubmit) closeSearch() else dismissSuggestions()
        }

        override fun searchBarViewNavigationButtonClicked(searchBarView: CYLSearchBarView) {
            delegate?.searchViewNavigationButtonClicked(this@CYLSearchView) ?: closeSearch()
        }

        override fun searchBarViewVoiceButtonClicked(searchBarView: CYLSearchBarView) {
            delegate?.searchViewVoiceButtonClicked(this@CYLSearchView)
        }

        override fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) = closeSearch()

        override fun searchBarViewDidBeginEditing(searchBarView: CYLSearchBarView) {
            delegate?.searchViewDidChangeFocus(this@CYLSearchView, true)
        }

        override fun searchBarViewDidEndEditing(searchBarView: CYLSearchBarView) {
            delegate?.searchViewDidChangeFocus(this@CYLSearchView, false)
        }
    }

    private inner class SuggestionAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount(): Int = if (suggestionsVisible) filteredSuggestions.size else 0

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder =
            object : RecyclerView.ViewHolder(CYLSearchSuggestionCell(parent.context).apply {
                layoutParams = RecyclerView.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
            }) {}

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            val cell = holder.itemView as CYLSearchSuggestionCell
            val suggestion = filteredSuggestions[position]
            cell.textLabel.text = suggestion
            cell.textLabel.setTextColor(suggestionTextColor ?: themeColor(android.R.attr.textColorPrimary))
            val wraps = suggestionLineBreakMode == CYLLineBreakMode.WordWrapping || suggestionLineBreakMode == CYLLineBreakMode.CharWrapping
            cell.textLabel.maxLines = if (wraps) Int.MAX_VALUE else 1
            cell.textLabel.ellipsize = when (suggestionLineBreakMode) {
                CYLLineBreakMode.TruncatingHead -> TextUtils.TruncateAt.START
                CYLLineBreakMode.TruncatingTail -> TextUtils.TruncateAt.END
                CYLLineBreakMode.TruncatingMiddle -> TextUtils.TruncateAt.MIDDLE
                else -> null
            }
            cell.imageView.setImageDrawable(suggestionImage)
            cell.imageView.visibility = if (suggestionImage != null) VISIBLE else GONE
            ImageViewCompat.setImageTintList(
                cell.imageView,
                android.content.res.ColorStateList.valueOf(suggestionImageTintColor ?: themeColor(android.R.attr.textColorSecondary)),
            )
            cell.setBackgroundColor(suggestionBackgroundColor ?: Color.TRANSPARENT)
            cell.setOnClickListener { select(holder.bindingAdapterPosition) }
            suggestionCellConfiguration?.invoke(cell, suggestion, position)
        }
    }

    private companion object {
        const val STATE_SUPER = "CYLSearchViewSuper"
        const val STATE_QUERY = "CYLSearchViewQuery"
        const val STATE_OPEN = "CYLSearchViewOpen"

        fun fold(text: String): String =
            Normalizer.normalize(text, Normalizer.Form.NFD).replace(Regex("\\p{Mn}+"), "").lowercase(Locale.ROOT)
    }
}
