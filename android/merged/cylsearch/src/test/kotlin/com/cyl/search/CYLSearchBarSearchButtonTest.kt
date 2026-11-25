package com.cyl.search

import android.app.Activity
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The default search button (owner, 2026-11-26; iOS `showsSearchButton`, `searchButtonStyle`, `searchButtonTitle`,
 * `searchButtonHandler`, `searchButtonItem`).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchBarSearchButtonTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private class Counter : CYLSearchBarViewDelegate {
        var clicked = 0
        override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
            clicked++
        }
    }

    private fun find(view: View, tag: String): View? {
        if (view.tag == tag) return view
        if (view is ViewGroup) for (index in 0 until view.childCount) find(view.getChildAt(index), tag)?.let { return it }
        return null
    }

    private fun dividers(view: View): Int =
        (view as? CYLSearchBarItemButton)?.let { if (it.item.style == CYLSearchBarItemStyle.Divider) 1 else 0 }
            ?: ((view as? ViewGroup)?.let { group -> (0 until group.childCount).sumOf { dividers(group.getChildAt(it)) } } ?: 0)

    @Test
    fun theBarKeepsATextButtonNamedSearchThatIsNotAnItem() {
        val bar = CYLSearchBarView(activity)
        assertTrue(bar.showsSearchButton)
        assertEquals(CYLSearchBarSearchButtonStyle.Text, bar.searchButtonStyle)
        assertEquals(CYLSearchBarItemStyle.Text, bar.searchButtonItem.style)
        assertEquals("Search", bar.searchButtonItem.title)
        assertTrue("not in items", bar.items.isEmpty())
        assertNotNull(find(bar, "CYLSearchBarSearchButton"))
        assertEquals("no item precedes it, no divider", 0, dividers(bar))
    }

    @Test
    fun aDividerPrecedesTheButtonOnlyWhenAnItemDoes() {
        val bar = CYLSearchBarView(activity)
        bar.addItem(CYLSearchBarItem.iconItem(null, "Camera", null))
        assertEquals(1, dividers(bar))
        assertEquals("the owner's items stay the only items", 1, bar.items.size)
    }

    @Test
    fun hidingAndTheEditingAndMultipleBarsLeaveNoButton() {
        val bar = CYLSearchBarView(activity)
        bar.showsSearchButton = false
        assertNull(find(bar, "CYLSearchBarSearchButton"))
        bar.showsSearchButton = true
        assertNotNull(find(bar, "CYLSearchBarSearchButton"))
        bar.mode = CYLSearchBarMode.Multiple
        assertNull(find(bar, "CYLSearchBarSearchButton"))
        assertNull(find(CYLSearchBarView.editingBar(activity, "Name", "Add"), "CYLSearchBarSearchButton"))
    }

    @Test
    fun aTapSubmitsTheTextAndTellsTheDelegateAlsoForEmptyText() {
        val bar = CYLSearchBarView(activity)
        val delegate = Counter()
        bar.delegate = delegate
        val button = find(bar, "CYLSearchBarSearchButton")!!
        button.performClick()
        assertEquals("empty text still reaches the delegate", 1, delegate.clicked)
        bar.text = "shoes"
        button.performClick()
        assertEquals(2, delegate.clicked)
    }

    @Test
    fun theHandlerReplacesTheDefaultAction() {
        val bar = CYLSearchBarView(activity)
        val delegate = Counter()
        bar.delegate = delegate
        var handled = 0
        bar.searchButtonHandler = { handled++ }
        find(bar, "CYLSearchBarSearchButton")!!.performClick()
        assertEquals(1, handled)
        assertEquals(0, delegate.clicked)
    }

    @Test
    fun theTitleAndStyleRebuildTheButton() {
        val bar = CYLSearchBarView(activity)
        bar.searchButtonTitle = "Go"
        assertEquals("Go", bar.searchButtonItem.title)
        bar.searchButtonStyle = CYLSearchBarSearchButtonStyle.Icon
        val item = bar.searchButtonItem
        assertEquals(CYLSearchBarItemStyle.Icon, item.style)
        assertEquals("the title stays the TalkBack label", "Go", item.title)
        assertNotNull("the built-in magnifier", item.image)
        assertEquals(CYLSearchBarItem.CAPSULE_CORNER_RADIUS, item.cornerRadius, 0f)
        assertEquals(28f, item.itemHeight, 0f)
        assertEquals("light mode: black capsule, white magnifier", Color.BLACK, item.backgroundColor)
        assertEquals(Color.WHITE, item.tintColor)
        assertEquals("the identifier survives", "CYLSearchBarSearchButton", item.itemAccessibilityIdentifier)
        assertNotNull(find(bar, "CYLSearchBarSearchButton"))
    }

    @Test
    fun theItemGainedCornerRadiusBorderAndHeight() {
        val item = CYLSearchBarItem.iconItem(null, "x", null)
        assertEquals(CYLSearchBarItem.AUTOMATIC_CORNER_RADIUS, item.cornerRadius, 0f)
        assertNull(item.borderColor)
        assertEquals(0f, item.borderWidth, 0f)
        assertEquals(0f, item.itemHeight, 0f)
        assertFalse(item.cornerRadius == CYLSearchBarItem.CAPSULE_CORNER_RADIUS)
    }
}
