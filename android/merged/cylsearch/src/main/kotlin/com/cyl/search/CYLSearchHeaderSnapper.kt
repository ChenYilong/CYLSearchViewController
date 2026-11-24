package com.cyl.search

import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView
import kotlin.math.max

/**
 * Keeps a header search bar scrollable and settles it (iOS `CYLSearchHeaderSnapper`). `header` is the first item of
 * `recyclerView`. It adds room below the last item so that the header can scroll out of sight even above a list shorter than
 * the screen (a list of three rows is shorter than the screen), and settles the header fully shown or fully hidden when the
 * scrolling ends (QMUI issues #1160 and #1207). The list's adapter and listeners are not replaced: the snapper adds a scroll
 * listener, an item decoration and a layout listener, and `detach` removes them.
 */
internal class CYLSearchHeaderSnapper(
    private val recyclerView: RecyclerView,
    val header: View,
    private val isSearching: () -> Boolean,
) {

    private var room = 0

    /**
     * False takes the room and the settling away.
     */
    var isEnabled: Boolean = true
        set(value) {
            if (field == value) {
                return
            }
            field = value
            refresh()
        }

    private val scrollListener = object : RecyclerView.OnScrollListener() {
        override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
            if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                settle()
            }
        }
    }

    private val roomDecoration = object : RecyclerView.ItemDecoration() {
        override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
            if (room > 0 && state.itemCount > 1 && parent.getChildAdapterPosition(view) == state.itemCount - 1) {
                outRect.bottom = room
            }
        }
    }

    private val layoutListener = View.OnLayoutChangeListener { _, _, _, _, _, _, _, _, _ -> refresh() }

    init {
        recyclerView.addOnScrollListener(scrollListener)
        recyclerView.addItemDecoration(roomDecoration)
        recyclerView.addOnLayoutChangeListener(layoutListener)
    }

    /**
     * Removes what the snapper added to the list.
     */
    fun detach() {
        recyclerView.removeOnScrollListener(scrollListener)
        recyclerView.removeItemDecoration(roomDecoration)
        recyclerView.removeOnLayoutChangeListener(layoutListener)
        room = 0
        recyclerView.invalidateItemDecorations()
    }

    /**
     * When the header is half scrolled out, scrolls the list until it is fully shown, or fully hidden once more than half of
     * it is out. Does nothing while disabled or while the search is open.
     */
    fun settle() {
        if (!isEnabled || isSearching()) {
            return
        }
        val view = headerView() ?: return
        val hidden = -view.top
        if (hidden <= 0 || hidden >= view.height) {
            return
        }
        recyclerView.smoothScrollBy(0, if (hidden * 2 >= view.height) view.height - hidden else -hidden)
    }

    /**
     * Reads the room below the last item again; the list is laid out again when it changed.
     */
    fun refresh() {
        val needed = neededRoom()
        if (needed != room) {
            room = needed
            recyclerView.post { recyclerView.invalidateItemDecorations() }
        }
    }

    private fun headerView(): View? = recyclerView.findViewHolderForAdapterPosition(0)?.itemView

    // The viewport plus the header's height, minus the content: the room that lets the header scroll all the way out. A list
    // with more items than children is longer than the screen and needs none.
    private fun neededRoom(): Int {
        if (!isEnabled || isSearching()) {
            return 0
        }
        val count = recyclerView.adapter?.itemCount ?: return 0
        if (count < 2 || recyclerView.childCount < count) {
            return 0
        }
        val first = headerView() ?: return 0
        val last = recyclerView.getChildAt(recyclerView.childCount - 1)
        val viewport = recyclerView.height - recyclerView.paddingTop - recyclerView.paddingBottom
        return max(0, viewport + first.height - (last.bottom - first.top))
    }
}
