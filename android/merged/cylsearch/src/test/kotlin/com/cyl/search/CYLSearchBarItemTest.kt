package com.cyl.search

import android.app.Activity
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.view.View
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * docs/search-bar-view.md, "Mimicking the tab bar's FlatDesign item-appending API": the field stays, the camera, a
 * divider and the Search button are items appended after the text (iOS
 * `testSearchBarItemsAreAppendedLikeFlatDesignTabBarItems`).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchBarItemTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    @Test
    fun itemsAreAppendedLikeFlatDesignTabBarItems() {
        val root = FrameLayout(activity)
        activity.setContentView(root)
        val bar = CYLSearchBarView(activity)
        root.addView(bar, FrameLayout.LayoutParams(1080, FrameLayout.LayoutParams.WRAP_CONTENT))
        val selected = mutableListOf<CYLSearchBarItem>()
        bar.delegate = object : CYLSearchBarViewDelegate {
            override fun searchBarViewDidSelectItem(searchBarView: CYLSearchBarView, item: CYLSearchBarItem) {
                selected.add(item)
            }
        }
        var cameraTaps = 0
        val camera = CYLSearchBarItem.iconItem(ColorDrawable(Color.BLACK), "Camera") { cameraTaps += 1 }
        val divider = CYLSearchBarItem.divider()
        val search = CYLSearchBarItem.textItem("Search", null)
        assertEquals(-1, camera.index)
        assertFalse(bar.hasItem(CYLSearchBarItemStyle.Text))
        bar.addItem(camera)
        bar.addItem(search)
        bar.insertItem(divider, 1)
        assertEquals(listOf(camera, divider, search), bar.items)
        assertEquals(2, search.index)
        assertSame(bar, camera.searchBarView)
        assertTrue(bar.hasItem(CYLSearchBarItemStyle.Text))
        assertEquals(3, bar.itemViews.size)
        assertSame(camera, bar.itemViews[0].item)
        assertSame(camera.itemView, camera.actualBadgeSuperView())

        // Layout: in order after the text, inside the field; a square 36 dp camera; TalkBack skips the divider.
        root.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(400, View.MeasureSpec.AT_MOST))
        root.layout(0, 0, 1080, 400)
        val cameraView = bar.itemViews[0]
        val dividerView = bar.itemViews[1]
        val searchView = bar.itemViews[2]
        fun windowX(view: View): Int = IntArray(2).also { view.getLocationInWindow(it) }[0]
        assertTrue(windowX(bar.textField) + bar.textField.width <= windowX(cameraView))
        assertTrue(windowX(cameraView) + cameraView.width <= windowX(dividerView))
        assertTrue(windowX(dividerView) + dividerView.width <= windowX(searchView))
        assertTrue(windowX(searchView) + searchView.width <= windowX(bar.fieldView) + bar.fieldView.width)
        assertEquals(cameraView.measuredWidth, cameraView.measuredHeight)
        val density = activity.resources.displayMetrics.density
        assertTrue(cameraView.measuredWidth >= (36 * density).toInt())
        assertEquals(View.IMPORTANT_FOR_ACCESSIBILITY_NO, dividerView.importantForAccessibility)
        assertEquals("Camera", cameraView.contentDescription)
        assertEquals("Search", searchView.titleLabel.text.toString())

        // Events: the delegate first, then the handler; a disabled item ignores taps; a selectable item toggles.
        cameraView.performClick()
        assertEquals(1, cameraTaps)
        assertEquals(listOf(camera), selected)
        camera.isEnabled = false
        cameraView.performClick()
        assertEquals(1, cameraTaps)
        camera.isEnabled = true
        camera.isSelectable = true
        assertNull(bar.selectedItem)
        assertEquals(-1, bar.selectedIndex)
        cameraView.performClick()
        assertTrue(camera.isSelected)
        assertSame(camera, bar.selectedItem)
        assertEquals(0, bar.selectedIndex)

        // Badge, text attributes and tint.
        camera.badgeValue = "3"
        assertEquals(View.VISIBLE, cameraView.badgeLabel.visibility)
        assertEquals("3", cameraView.badgeLabel.text.toString())
        camera.badgeValue = null
        assertEquals(View.GONE, cameraView.badgeLabel.visibility)
        search.setTitleTextAttributes(CYLSearchBarItemTextAttributes(color = Color.BLUE), CYLSearchBarItemState.Normal)
        assertEquals(Color.BLUE, search.titleTextAttributes(CYLSearchBarItemState.Normal)?.color)
        assertEquals(Color.BLUE, searchView.titleLabel.currentTextColor)
        bar.itemTintColor = Color.GREEN
        assertEquals(Color.GREEN, cameraView.imageView.imageTintList?.defaultColor)

        // The fixed bordered style, and removal.
        bar.searchBarStyle = CYLSearchBarStyle.Bordered
        assertEquals(1f, bar.fieldBorderWidth)
        assertTrue(bar.fieldBorderColor != null)
        bar.removeItem(divider)
        assertEquals(listOf(camera, search), bar.items)
        assertNull(divider.searchBarView)
        assertNull(dividerView.parent)
        bar.addItem(CYLSearchBarItemStyle.Divider, null, null, 1)
        assertEquals(CYLSearchBarItemStyle.Divider, bar.items[1].style)
        bar.removeAllItems()
        assertTrue(bar.items.isEmpty())

        // Plain values from the cross-platform wrappers (Flutter, React Native).
        val wrapped = CYLSearchBarItem.fromMap(activity, mapOf("style" to "icon", "title" to "Camera", "image" to "camera", "accessibilityIdentifier" to "camera", "isSelectable" to true, "badgeValue" to ""))
        assertEquals(CYLSearchBarItemStyle.Icon, wrapped.style)
        assertTrue(wrapped.image != null)
        assertEquals("camera", wrapped.itemAccessibilityIdentifier)
        assertTrue(wrapped.isSelectable)
        assertEquals("", wrapped.badgeValue)
        assertEquals(CYLSearchBarItemStyle.Divider, CYLSearchBarItem.fromMap(activity, mapOf("style" to "divider")).style)
        assertEquals(CYLSearchBarItemStyle.Text, CYLSearchBarItem.fromMap(activity, mapOf("style" to "text", "title" to "Search")).style)
    }
}
