package com.cyl.search

import android.app.Activity
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.util.SizeF
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The trailing group (owner, 2026-11-26; iOS `testTrailingGroupGapsBesideTheDividerAreEqual`): the field is the flexible control, the
 * group's items are spaced only by the group's own spacing, a plain icon or text item hugs its content with a 36 dp touch area, an item
 * with a shape of its own (the icon search capsule) keeps its size.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchBarTrailingGroupTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()
    private val density = activity.resources.displayMetrics.density

    private fun bar(): CYLSearchBarView {
        val bar = CYLSearchBarView(activity)
        val camera = CYLSearchBarItem.iconItem(ColorDrawable(Color.GRAY), "Camera", null)
        camera.imageSize = SizeF(22f, 22f)
        camera.itemAccessibilityIdentifier = "camera"
        bar.addItem(camera)
        val width = (360 * density).toInt()
        val height = (44 * density).toInt()
        bar.measure(View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY))
        bar.layout(0, 0, width, height)
        return bar
    }

    private fun find(view: View, tag: String): View? {
        if (view.tag == tag) return view
        if (view is ViewGroup) for (index in 0 until view.childCount) find(view.getChildAt(index), tag)?.let { return it }
        return null
    }

    private fun dividerOf(group: ViewGroup): View =
        (0 until group.childCount).map { group.getChildAt(it) }.first { (it as? CYLSearchBarItemButton)?.item?.style == CYLSearchBarItemStyle.Divider }

    @Test
    fun gapsBesideTheDividerAreEqual() {
        val bar = bar()
        val camera = find(bar, "camera")!!
        val capsule = find(bar, "CYLSearchBarSearchButton")!!
        val group = camera.parent as ViewGroup
        val divider = dividerOf(group)
        // The glyph is centered in its item; measure from the glyph edge, not from the item's bounds.
        val glyphRight = camera.left + camera.width / 2f + 22f * density / 2f
        val glyphToDivider = divider.left - glyphRight
        val dividerToCapsule = (capsule.left - divider.right).toFloat()
        assertTrue("the gap is not zero", dividerToCapsule > 0f)
        assertEquals("glyph-to-divider equals divider-to-capsule", dividerToCapsule, glyphToDivider, 1f)
    }

    @Test
    fun aPlainIconItemHugsItsGlyphAndTheCapsuleKeepsItsSize() {
        val bar = bar()
        val camera = find(bar, "camera")!!
        val capsule = find(bar, "CYLSearchBarSearchButton")!!
        assertTrue("the plain item is no wider than its glyph plus a pixel", camera.width <= (22f * density).toInt() + 1)
        assertEquals("the capsule is 28 dp high", (28 * density).toInt(), capsule.height)
        assertTrue("the capsule is at least as wide as high", capsule.width >= capsule.height)
    }

    @Test
    fun aTouchBesideTheGlyphWithin36DpReachesTheItem() {
        val bar = bar()
        val camera = find(bar, "camera")!!
        val group = camera.parent as ViewGroup
        var taps = 0
        bar.items.first().let { item -> item.handler = { taps++ } }
        val x = camera.left - 5f * density
        val y = camera.top + camera.height / 2f
        val down = MotionEvent.obtain(0, 0, MotionEvent.ACTION_DOWN, x, y, 0)
        val up = MotionEvent.obtain(0, 50, MotionEvent.ACTION_UP, x, y, 0)
        assertNotNull(group)
        group.dispatchTouchEvent(down)
        group.dispatchTouchEvent(up)
        assertEquals("a touch 5 dp left of the glyph taps the camera", 1, taps)
    }
}
