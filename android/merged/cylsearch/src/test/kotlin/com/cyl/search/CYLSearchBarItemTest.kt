package com.cyl.search

import android.app.Activity
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.net.Uri
import android.view.View
import android.widget.FrameLayout
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLTagButton
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

    /**
     * The items' CYLTagButton is CYLTabBarController's CYLAnimatedItemView (docs/animated-icon-component.md): a file
     * whose library is not in the app (no Lottie in the core) shows the static image, the component's placeholder only
     * without one, and a text item never grows an icon (iOS `testSearchBarItemsFollowTheAnimatedItemDisplayPriority`).
     */
    @Test
    fun itemsFollowTheAnimatedItemDisplayPriority() {
        val file = java.io.File.createTempFile("cyl-bar-item", ".json").apply { writeText("{\"v\":\"5.7.0\",\"layers\":[]}") }
        val image = ColorDrawable(Color.RED).apply { setBounds(0, 0, 20, 20) }
        val withImage = CYLSearchBarItem.iconItem(image, "Camera", null)
        withImage.animationURL = Uri.fromFile(file)
        val withImageView = withImage.itemView(activity)
        assertNull("no animation library in the core", withImageView.animationView)
        assertSame("the static image wins over the placeholder", image, withImageView.imageView.drawable)
        assertEquals("Camera", withImageView.contentDescription?.toString())

        val withoutImage = CYLSearchBarItem.iconItem(null, "Camera", null)
        withoutImage.animationURL = Uri.fromFile(file)
        val withoutImageView = withoutImage.itemView(activity)
        if (com.cyl.animateditem.CYLAnimatedItemView.defaultPlaceholderImage(activity) != null) {
            org.junit.Assert.assertNotNull("no static image: the component's placeholder", withoutImageView.imageView.drawable)
        }
        withoutImageView.playAnimation()

        val text = CYLSearchBarItem.textItem("Search", null)
        assertNull("a text item without an icon shows no placeholder", text.itemView(activity).imageView.drawable)
        file.delete()
    }

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
        assertSame(camera, (bar.itemViews[0] as CYLSearchBarItemButton).item)
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
        val density = activity.resources.displayMetrics.density
        // A plain icon item hugs its glyph (its 36 dp touch width comes from the trailing group), and is 36 dp high.
        assertTrue(cameraView.measuredWidth < (36 * density).toInt())
        assertTrue(cameraView.measuredHeight >= (36 * density).toInt())
        assertEquals(View.IMPORTANT_FOR_ACCESSIBILITY_NO, dividerView.importantForAccessibility)
        assertEquals("Camera", cameraView.contentDescription)
        assertEquals("Search", searchView.titleLabel.text.toString())

        // Each item is drawn by CollectionViewClassifyMenu's CYLTagButton: the item's title, icon, badge and animated icon.
        assertTrue(cameraView is CYLTagButton)
        assertEquals("Search", searchView.title)
        assertNull(cameraView.title)
        assertSame(camera.image, cameraView.image)
        camera.badgeValue = "5"
        camera.badgeColor = Color.YELLOW
        assertEquals("5", cameraView.badgeValue)
        assertEquals(Color.YELLOW, cameraView.badgeColor)
        camera.badgeValue = null
        camera.badgeColor = null
        val animationURL = Uri.parse("file:///nonexistent/CYLSearchBarItemIcon.json")
        camera.animationURL = animationURL
        assertEquals(animationURL.toString(), cameraView.animationURL)
        camera.animationURL = null
        assertNull(cameraView.animationURL)

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
        assertEquals(Color.GREEN, cameraView.style!!.iconColorForState(CYLControlState.SELECTED))

        // The fixed bordered style, and removal.
        bar.searchBarStyle = CYLSearchBarStyle.Bordered
        assertEquals(1f, bar.fieldBorderWidth)
        assertTrue(bar.fieldBorderColor != null)
        // A visible line, not the faint separator: 60% alpha of the secondary label color (light mode here), about 3:1 on the page.
        assertEquals(153, Color.alpha(bar.fieldBorderColor!!))
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
