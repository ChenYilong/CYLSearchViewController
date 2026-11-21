// Ported from QMUI_iOS (Tencent, MIT): QMUICommonTableViewController (Search) and the header snapping of docs/qmui-search-controller.md, row I4.
package com.cyl.search

import android.content.Context
import android.util.AttributeSet
import android.util.TypedValue
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.recyclerview.widget.ConcatAdapter
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.placeholder.CYLPlaceholderStackView
import kotlin.math.max

/**
 * A list screen with a built-in search bar (iOS `CYLSearchTableViewController`; QMUI `QMUICommonTableViewController`
 * with `shouldShowSearchBar`): a `RecyclerView` whose first item is `searchBarView`, so the bar scrolls with the list and
 * never covers a row. By default a tap on the bar opens `searchView` over the list (the bar is a button, as in lapism's
 * `MaterialSearchBar`); `opensSearchViewOnTap = false` edits the bar in place. `hidesSearchBarInitially` scrolls the bar
 * out at first, and `snapsHeaderSearchBar` makes the bar settle fully shown or fully hidden when the scrolling ends,
 * also above a list too short to scroll (QMUI #1160, #1207): the list gets the room it needs below its last row.
 */
class CYLSearchListView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(context, attrs, defStyleAttr) {

    private val headerAdapter = HeaderAdapter()
    private val footerAdapter = FooterAdapter()
    private val layoutManager = LinearLayoutManager(context)
    private var contentAdapter: RecyclerView.Adapter<*>? = null
    private var concatAdapter: ConcatAdapter? = null
    private var emptyPlaceholder: CYLPlaceholderStackView? = null
    private var needsInitialHide = false

    /**
     * The list (iOS `tableView`). Its first item is the search bar and its last item is the room that lets the bar
     * scroll out; `adapter` is what is between them.
     */
    val recyclerView: RecyclerView = RecyclerView(context)

    /**
     * The search bar, the first item of the list (iOS `searchBar`). Style it directly.
     */
    val searchBarView: CYLSearchBarView = CYLSearchBarView(context)

    /**
     * The search page that opens over the list when the bar is tapped (iOS `searchController`).
     */
    val searchView: CYLSearchView = CYLSearchView(context)

    /**
     * The rows between the bar and the room below them. Setting it replaces the previous one.
     */
    var adapter: RecyclerView.Adapter<*>?
        get() = contentAdapter
        set(value) {
            contentAdapter?.unregisterAdapterDataObserver(dataObserver)
            contentAdapter = value
            value?.registerAdapterDataObserver(dataObserver)
            val concat = ConcatAdapter(ConcatAdapter.Config.Builder().setIsolateViewTypes(true).build(), listOfNotNull(headerAdapter, value, footerAdapter))
            concatAdapter = concat
            recyclerView.adapter = concat
            needsInitialHide = hidesSearchBarInitially
            recyclerView.post { updateFooter() }
        }

    /**
     * Shows the bar as the first item of the list (iOS `showsSearchBar`). True by default.
     */
    var showsSearchBar: Boolean = true
        set(value) {
            field = value
            headerAdapter.refresh()
            recyclerView.post { updateFooter() }
        }

    /**
     * Scrolls the bar out when the list first shows rows, and again after `hideEmptyView` (iOS
     * `hidesSearchBarInitially`); a pull down or a drag reveals it. False by default.
     */
    var hidesSearchBarInitially: Boolean = false
        set(value) {
            field = value
            needsInitialHide = value
            recyclerView.post { hideBarIfNeeded() }
        }

    /**
     * Removes the bar from the list while `showEmptyView`'s placeholder shows, and puts it back after (iOS
     * `hidesSearchBarWhenEmptyViewShowing`, QMUI #128). True by default.
     */
    var hidesSearchBarWhenEmptyViewShowing: Boolean = true
        set(value) {
            field = value
            headerAdapter.refresh()
        }

    /**
     * A tap on the bar opens `searchView` instead of editing the bar in place. True by default.
     */
    var opensSearchViewOnTap: Boolean = true

    /**
     * Settles the bar fully shown or fully hidden when scrolling ends, and keeps room below the last row so a short
     * list can scroll the bar out (iOS `snapsHeaderSearchBar`, I4). True by default.
     */
    var snapsHeaderSearchBar: Boolean = true
        set(value) {
            field = value
            recyclerView.post { updateFooter() }
        }

    /**
     * True while `showEmptyView` has its placeholder over the list (iOS `isEmptyViewShowing`).
     */
    val isEmptyViewShowing: Boolean
        get() = emptyPlaceholder != null

    /**
     * The height of the room below the last row, in pixels: the part of the bar that a short list could not scroll out.
     */
    val footerHeight: Int
        get() = footerAdapter.height

    /**
     * The part of the bar that is out of sight above the list, in pixels: 0 fully shown, the bar's height fully hidden.
     */
    val searchBarHiddenHeight: Int
        get() {
            val header = layoutManager.findViewByPosition(0) ?: return if (layoutManager.findFirstVisibleItemPosition() > 0) searchBarView.height else 0
            return (-header.top).coerceIn(0, header.height)
        }

    private val dataObserver = object : RecyclerView.AdapterDataObserver() {
        override fun onChanged() = changed()
        override fun onItemRangeInserted(positionStart: Int, itemCount: Int) = changed()
        override fun onItemRangeRemoved(positionStart: Int, itemCount: Int) = changed()
        override fun onItemRangeChanged(positionStart: Int, itemCount: Int) = changed()

        private fun changed() {
            recyclerView.post {
                updateFooter()
                hideBarIfNeeded()
            }
        }
    }

    init {
        recyclerView.layoutManager = layoutManager
        recyclerView.clipToPadding = false
        recyclerView.setBackgroundColor(themeColor(android.R.attr.colorBackground))
        addView(recyclerView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        searchBarView.applyDefaultAppearance()
        searchBarView.showsCancelButtonWhenEditing = true
        searchBarView.clearsTextOnCancel = true
        searchBarView.delegate = object : CYLSearchBarViewDelegate {
            override fun searchBarViewShouldBeginEditing(searchBarView: CYLSearchBarView): Boolean = !opensSearchViewOnTap

            override fun searchBarViewDidTapWhileNotEditable(searchBarView: CYLSearchBarView) {
                searchView.showSearch(this@CYLSearchListView, true)
            }
        }
        recyclerView.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                    settleSearchBar()
                }
            }
        })
        recyclerView.addOnLayoutChangeListener { _, _, _, _, _, _, _, _, _ ->
            recyclerView.post {
                updateFooter()
                hideBarIfNeeded()
            }
        }
        adapter = null
    }

    private fun themeColor(attribute: Int): Int {
        val value = TypedValue()
        context.theme.resolveAttribute(attribute, value, true)
        return value.data
    }

    /**
     * Settles the bar: when it is half scrolled out, scrolls the list until it is fully shown, or fully hidden once
     * more than half of it is out (QMUI #1160). The list calls it when scrolling ends; `snapsHeaderSearchBar` false
     * turns it off.
     */
    fun settleSearchBar() {
        if (!snapsHeaderSearchBar || !showsSearchBar || isEmptyViewShowing) {
            return
        }
        val header = layoutManager.findViewByPosition(0) ?: return
        val hidden = -header.top
        if (hidden <= 0 || hidden >= header.height) {
            return
        }
        recyclerView.smoothScrollBy(0, if (hidden * 2 >= header.height) header.height - hidden else -hidden)
    }

    /**
     * Puts CYLTableViewPlaceHolder's "no results" placeholder over the list, with a title, an optional detail and an
     * optional button (iOS `showEmptyView`); the bar leaves the list when `hidesSearchBarWhenEmptyViewShowing` is true.
     */
    @JvmOverloads
    fun showEmptyView(text: String?, detailText: String? = null, buttonTitle: String? = null, buttonAction: (() -> Unit)? = null) {
        hideEmptyView()
        val placeholder = CYLSearchView.emptyPlaceholder(context, text, detailText, buttonTitle, buttonAction)
        placeholder.setBackgroundColor(themeColor(android.R.attr.colorBackground))
        emptyPlaceholder = placeholder
        addView(placeholder, 1, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        headerAdapter.refresh()
    }

    /**
     * Removes the placeholder; the bar comes back hidden when `hidesSearchBarInitially` is true.
     */
    fun hideEmptyView() {
        val placeholder = emptyPlaceholder ?: return
        removeView(placeholder)
        emptyPlaceholder = null
        headerAdapter.refresh()
        needsInitialHide = hidesSearchBarInitially
        recyclerView.post { hideBarIfNeeded() }
    }

    private fun hideBarIfNeeded() {
        if (!needsInitialHide || !showsSearchBar || isEmptyViewShowing) {
            return
        }
        val rows = (concatAdapter?.itemCount ?: 0) - headerAdapter.itemCount - footerAdapter.itemCount
        if (rows <= 0 || recyclerView.height == 0) {
            return
        }
        needsInitialHide = false
        updateFooter()
        recyclerView.post { layoutManager.scrollToPositionWithOffset(headerAdapter.itemCount, 0) }
    }

    // The room below the last row: the viewport plus the bar's height, minus the rows and the bar, so that the bar can
    // scroll all the way out (QMUI sets the same through contentInset).
    private fun updateFooter() {
        if (!snapsHeaderSearchBar || !showsSearchBar || isEmptyViewShowing) {
            footerAdapter.update(0)
            return
        }
        val first = layoutManager.findViewByPosition(0)
        val last = layoutManager.findViewByPosition((concatAdapter?.itemCount ?: 1) - 1)
        if (first == null || last == null) {
            return
        }
        val viewport = recyclerView.height - recyclerView.paddingTop - recyclerView.paddingBottom
        val contentHeight = last.top - first.top
        footerAdapter.update(max(0, viewport + first.height - contentHeight))
    }

    private inner class HeaderAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        private var shown = true

        fun refresh() {
            val now = showsSearchBar && !(hidesSearchBarWhenEmptyViewShowing && isEmptyViewShowing)
            if (now == shown) {
                return
            }
            shown = now
            if (now) notifyItemInserted(0) else notifyItemRemoved(0)
        }

        override fun getItemCount(): Int = if (shown) 1 else 0

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
            (searchBarView.parent as? ViewGroup)?.removeView(searchBarView)
            val holder = FrameLayout(parent.context)
            holder.addView(searchBarView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
            holder.layoutParams = RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, RecyclerView.LayoutParams.WRAP_CONTENT)
            return object : RecyclerView.ViewHolder(holder) {}
        }

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) = Unit
    }

    private inner class FooterAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        var height = 0
            private set

        fun update(newHeight: Int) {
            if (newHeight == height) {
                return
            }
            height = newHeight
            if (itemCount > 0) notifyItemChanged(0)
        }

        override fun getItemCount(): Int = 1

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
            val spacer = View(parent.context)
            spacer.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
            spacer.layoutParams = RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, height)
            return object : RecyclerView.ViewHolder(spacer) {}
        }

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            holder.itemView.layoutParams = RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, height)
        }
    }
}
