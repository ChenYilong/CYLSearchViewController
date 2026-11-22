package com.cyl.search

import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.recyclerview.widget.RecyclerView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * `CYLSearchListView` (iOS `CYLSearchTableViewController`, docs/qmui-search-controller.md): the built-in bar, the
 * hidden-initially and empty-view options, and the snapping of the header bar above a short list (row I4, #1160).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchListViewTest {

    private val activity: ComponentActivity = Robolectric.buildActivity(ComponentActivity::class.java).setup().get()

    private class Rows(private val count: Int) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount() = count

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = object : RecyclerView.ViewHolder(TextView(parent.context).apply {
            layoutParams = RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, 100)
            text = "row"
        }) {}

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) = Unit
    }

    private fun idle() = org.robolectric.Shadows.shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(2000))

    private fun layout(list: View) {
        list.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(1920, View.MeasureSpec.EXACTLY))
        list.layout(0, 0, 1080, 1920)
    }

    private fun settled(list: View) {
        repeat(4) {
            layout(list)
            idle()
        }
    }

    private fun list(rows: Int, configure: CYLSearchListView.() -> Unit = {}): CYLSearchListView {
        val host = FrameLayout(activity)
        activity.setContentView(host)
        val list = CYLSearchListView(activity)
        host.addView(list, ViewGroup.LayoutParams(1080, 1920))
        list.configure()
        list.adapter = Rows(rows)
        settled(list)
        return list
    }

    @Test
    fun barIsTheFirstItemAndScrollsWithTheRows() {
        val list = list(30)
        assertEquals(32, list.recyclerView.adapter?.itemCount)
        val bar = list.searchBarView
        assertTrue(bar.height > 0)
        assertEquals("the bar is at the top of the list", 0, list.searchBarHiddenHeight)
        val first = list.recyclerView.layoutManager!!.findViewByPosition(1)!!
        assertTrue("the first row starts under the bar: ${first.top} >= ${bar.height}", first.top >= bar.height)
        list.showsSearchBar = false
        settled(list)
        assertEquals(31, list.recyclerView.adapter?.itemCount)
    }

    @Test
    fun shortListGetsTheRoomToScrollTheBarOutAndSnaps() {
        val list = list(3)
        val bar = list.searchBarView.height
        assertTrue("room below the three rows: ${list.footerHeight}", list.footerHeight > 0)
        assertTrue("a short list can scroll the bar out", list.recyclerView.canScrollVertically(1))
        // A quarter of the bar out: settles fully shown.
        list.recyclerView.scrollBy(0, bar / 4)
        assertEquals(bar / 4, list.searchBarHiddenHeight)
        list.settleSearchBar()
        idle()
        assertEquals("settles fully shown", 0, list.searchBarHiddenHeight)
        // Three quarters out: settles fully hidden.
        list.recyclerView.scrollBy(0, bar * 3 / 4)
        list.settleSearchBar()
        idle()
        assertEquals("settles fully hidden", bar, list.searchBarHiddenHeight)
        // And back again: the bar is never left half hidden.
        list.recyclerView.scrollBy(0, -bar / 3)
        list.settleSearchBar()
        idle()
        assertTrue(list.searchBarHiddenHeight == 0 || list.searchBarHiddenHeight == bar)
    }

    @Test
    fun withoutSnappingAShortListCannotScrollTheBarOut() {
        val list = list(3) { snapsHeaderSearchBar = false }
        assertEquals(0, list.footerHeight)
        assertFalse("the control: a short list does not scroll", list.recyclerView.canScrollVertically(1))
        list.recyclerView.scrollBy(0, 40)
        assertEquals(0, list.searchBarHiddenHeight)
    }

    @Test
    fun hidesSearchBarInitiallyScrollsTheBarOut() {
        val list = list(3) { hidesSearchBarInitially = true }
        assertEquals(list.searchBarView.height, list.searchBarHiddenHeight)
        val long = list(40) { hidesSearchBarInitially = true }
        assertEquals(long.searchBarView.height, long.searchBarHiddenHeight)
    }

    @Test
    fun emptyViewRemovesTheBarAndHidingItPutsItBackHidden() {
        val list = list(5) { hidesSearchBarInitially = true }
        val count = list.recyclerView.adapter!!.itemCount
        list.showEmptyView("No matching results")
        settled(list)
        assertTrue(list.isEmptyViewShowing)
        assertEquals("the bar left the list", count - 1, list.recyclerView.adapter!!.itemCount)
        list.hideEmptyView()
        settled(list)
        assertFalse(list.isEmptyViewShowing)
        assertEquals(count, list.recyclerView.adapter!!.itemCount)
        assertEquals("back, hidden initially", list.searchBarView.height, list.searchBarHiddenHeight)
        list.hidesSearchBarWhenEmptyViewShowing = false
        list.showEmptyView("None")
        settled(list)
        assertEquals("the bar stays when the option is off", count, list.recyclerView.adapter!!.itemCount)
    }

    @Test
    fun aTapOnTheBarOpensTheSearchViewOrEditsInPlace() {
        val list = list(5)
        list.searchBarView.showKeyboard()
        assertTrue("the bar is a button: the search page opens", list.searchView.isActive)
        list.searchView.closeSearch(false)
        list.opensSearchViewOnTap = false
        list.searchBarView.showKeyboard()
        assertFalse(list.searchView.isActive)
        assertTrue("edited in place", list.searchBarView.isActive)
        assertEquals("Cancel appears while editing", View.VISIBLE, list.searchBarView.cancelButton.visibility)
    }
}
