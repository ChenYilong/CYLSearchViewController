package com.cyl.search

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.LinearLayout
import androidx.appcompat.widget.Toolbar
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * docs/animated-icon-component.md, "The adaptive width is the core's job": the core, never the page, makes the embedded search
 * bar take the width that is left beside the back arrow (iOS `testEmbeddedBarAsksForTheWholeWidthAndAPlainBarKeepsItsOwn`).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchBarEmbedInToolbarTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get().also {
        it.setTheme(androidx.appcompat.R.style.Theme_AppCompat_Light)
    }

    private fun exactly(size: Int) = View.MeasureSpec.makeMeasureSpec(size, View.MeasureSpec.EXACTLY)

    private fun layOut(toolbar: Toolbar, width: Int) {
        toolbar.measure(exactly(width), exactly(168))
        toolbar.layout(0, 0, width, 168)
    }

    @Test
    fun embeddedBarAsksForTheWholeWidthLeftBesideTheBackArrow() {
        val toolbar = Toolbar(activity)
        toolbar.setNavigationIcon(R.drawable.cyl_search_ic_arrow_back)
        val bar = CYLSearchBarView(activity)

        assertSame(toolbar, bar.embedInToolbar(toolbar))

        assertSame("the bar is a child of the toolbar", toolbar, bar.parent)
        assertTrue(bar.embedsInToolbar)
        assertEquals("the core asks for match parent", ViewGroup.LayoutParams.MATCH_PARENT, bar.layoutParams.width)
        layOut(toolbar, 1080)
        val backButton = (0 until toolbar.childCount).map { toolbar.getChildAt(it) }.first { it is ImageButton }
        val remaining = toolbar.width - backButton.right - toolbar.paddingRight
        assertTrue("the bar starts after the back arrow", bar.left >= backButton.right)
        assertTrue(
            "the bar fills the rest: ${bar.measuredWidth} of $remaining",
            bar.measuredWidth >= remaining - toolbar.contentInsetEnd - toolbar.contentInsetStartWithNavigation - 2,
        )
    }

    @Test
    fun aPlainBarKeepsItsOwnLayoutParams() {
        val plain = CYLSearchBarView(activity)
        assertNull("a bar that is not embedded asks for nothing", plain.layoutParams)
        assertEquals(false, plain.embedsInToolbar)
    }

    @Test
    fun withoutAToolbarTheCoreCreatesOneAtTheTopOfTheContent() {
        val content = LinearLayout(activity).apply { orientation = LinearLayout.VERTICAL }
        content.addView(View(activity))
        val bar = CYLSearchBarView(activity)

        val toolbar = bar.embedInToolbar(activity, content)

        assertSame("the created toolbar is the first child", toolbar, content.getChildAt(0))
        assertSame(toolbar, bar.parent)
        assertEquals("the content below the toolbar stays", 2, content.childCount)
    }

    @Test
    fun theCapsuleStartsWhereTheToolbarContentStartsAfterABackArrowAndOnTheTagInsetWithout() {
        val density = activity.resources.displayMetrics.density
        val withArrow = Toolbar(activity)
        withArrow.setNavigationIcon(R.drawable.cyl_search_ic_arrow_back)
        val arrowBar = CYLSearchBarView(activity)
        arrowBar.embedInToolbar(withArrow)
        layOut(withArrow, 1080)
        assertEquals("after the back arrow the bar adds no inset of its own (iOS 72 pt: the toolbar keyline)", 0, (arrowBar.fieldView.parent as View).paddingStart)

        val plain = Toolbar(activity)
        val plainBar = CYLSearchBarView(activity)
        plainBar.embedInToolbar(plain)
        layOut(plain, 1080)
        assertEquals("without an arrow: the 16 dp inset of the tag list", Math.round(16 * density), (plainBar.fieldView.parent as View).paddingStart)
        assertEquals("and at the end", Math.round(16 * density), (plainBar.fieldView.parent as View).paddingEnd)
    }

    @Test
    fun aHostShorterThanTheFieldKeepsAllFourEdgesOfTheField() {
        val bar = CYLSearchBarView(activity)
        bar.searchBarStyle = CYLSearchBarStyle.Bordered
        val toolbar = Toolbar(activity)
        bar.embedInToolbar(toolbar)
        // A 44 dp slot (115 px at 2.625) is shorter than the field and the 6 dp insets around it.
        val slot = 115
        toolbar.measure(exactly(1080), exactly(slot))
        toolbar.layout(0, 0, 1080, slot)
        val field = bar.fieldView
        assertTrue("the field (${field.height}) fits the slot ($slot)", field.height in 1..slot)
        assertTrue("the field lies inside the bar", field.top >= 0 && field.bottom <= bar.height)
    }
}
