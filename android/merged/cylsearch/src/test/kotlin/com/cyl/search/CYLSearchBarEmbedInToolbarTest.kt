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
}
