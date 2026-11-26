package com.cyl.search

import android.app.Activity
import android.view.MotionEvent
import androidx.appcompat.widget.Toolbar
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
 * The first-level page's default behaviour of a navigation-embedded bar: the whole bar, back button in and out with the width
 * following, the tap that pushes.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchBarFirstLevelTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get().also {
        it.setTheme(androidx.appcompat.R.style.Theme_AppCompat_Light)
    }

    private fun embedded(): Pair<Toolbar, CYLSearchBarView> {
        val toolbar = Toolbar(activity)
        val bar = CYLSearchBarView(activity)
        bar.embedInToolbar(toolbar)
        return toolbar to bar
    }

    @Test
    fun firstLevelBarFillsTheWholeWidthWithoutBackButton() {
        val (toolbar, bar) = embedded()
        assertNull(toolbar.navigationIcon)
        assertEquals(0f, bar.backButtonProgress, 0f)
        assertFalse(bar.isBackButtonShown)
    }

    @Test
    fun showAndHideBackButtonWithoutAnimationSwitchTheStateAndTheInset() {
        val (toolbar, bar) = embedded()
        bar.showBackButton(false)
        assertNotNull(toolbar.navigationIcon)
        assertTrue(bar.isBackButtonShown)
        assertEquals((56 * activity.resources.displayMetrics.density).toInt(), toolbar.contentInsetStartWithNavigation)

        var done = false
        bar.hideBackButton(false) { done = true }
        assertNull(toolbar.navigationIcon)
        assertFalse(bar.isBackButtonShown)
        assertTrue("the completion runs", done)
    }

    @Test
    fun progressByHandMovesTheNavigationIconAndTheInset() {
        val (toolbar, bar) = embedded()
        bar.setBackButtonProgress(0.5f)
        assertNotNull(toolbar.navigationIcon)
        assertEquals(0.5f, bar.backButtonProgress, 0f)
        val full = (56 * activity.resources.displayMetrics.density).toInt()
        assertEquals(full / 2, toolbar.contentInsetStartWithNavigation)
        bar.setBackButtonProgress(0f)
        assertNull(toolbar.navigationIcon)
    }

    @Test
    fun animatedStateEndsWhereTheUnanimatedOneIs() {
        val (toolbar, bar) = embedded()
        activity.setContentView(android.widget.FrameLayout(activity).also { it.addView(toolbar) })
        bar.showBackButton(true)
        org.robolectric.shadows.ShadowLooper.idleMainLooper(1, java.util.concurrent.TimeUnit.SECONDS)
        assertTrue(bar.isBackButtonShown)
        bar.hideBackButton(true)
        org.robolectric.shadows.ShadowLooper.idleMainLooper(1, java.util.concurrent.TimeUnit.SECONDS)
        assertEquals(0f, bar.backButtonProgress, 0f)
        assertNull(toolbar.navigationIcon)
    }

    @Test
    fun tapOnTheFieldPushesAndShowsTheBackButton() {
        val (toolbar, bar) = embedded()
        var pushed = 0
        bar.onFirstLevelTap = { pushed++ }
        assertTrue(bar.pushesOnTap)
        bar.performFirstLevelTap()
        assertEquals(1, pushed)
        assertNotNull("the back button comes in with the tap", toolbar.navigationIcon)
        assertFalse(bar.pushesOnTap.and(bar.isBackButtonShown))
        bar.performFirstLevelTap()
        assertEquals("with the back button in the tap does not push again", 1, pushed)
    }

    @Test
    fun withoutAHandlerATapDoesNothingSpecial() {
        val (toolbar, bar) = embedded()
        assertFalse(bar.pushesOnTap)
        bar.performFirstLevelTap()
        assertNull(toolbar.navigationIcon)
    }

    @Test
    fun theBackButtonCallsTheHandler() {
        val (toolbar, bar) = embedded()
        var back = 0
        bar.backButtonHandler = { back++ }
        bar.showBackButton(false)
        toolbar.performNavigationClick()
        assertEquals(1, back)
    }

    @Test
    fun interceptingATouchOverTheFieldIsOffWithoutAHandler() {
        val (_, bar) = embedded()
        val down = MotionEvent.obtain(0, 0, MotionEvent.ACTION_DOWN, 1f, 1f, 0)
        assertFalse(bar.onInterceptTouchEvent(down))
        down.recycle()
    }

    @Test
    fun theWholeFieldBesideACenteredPlaceholderIsTheTapTargetButItemsAreNot() {
        val (_, bar) = embedded()
        bar.centersPlaceholder = true
        bar.placeholder = "Search"
        bar.addItem(CYLSearchBarItem.textItem("Go") {})
        bar.onFirstLevelTap = {}
        bar.measure(
            android.view.View.MeasureSpec.makeMeasureSpec(1000, android.view.View.MeasureSpec.EXACTLY),
            android.view.View.MeasureSpec.makeMeasureSpec(200, android.view.View.MeasureSpec.AT_MOST),
        )
        bar.layout(0, 0, bar.measuredWidth, bar.measuredHeight)
        val box = android.graphics.Rect()
        bar.fieldView.getDrawingRect(box)
        bar.offsetDescendantRectToMyCoords(bar.fieldView, box)
        val y = box.centerY().toFloat()
        assertTrue("left end of the field, left of the centered placeholder", bar.isFirstLevelTapTarget(box.left + 4f, y))
        val accessory = android.graphics.Rect()
        val container = bar.fieldView.getChildAt(bar.fieldView.childCount - 2)
        container.getDrawingRect(accessory)
        bar.offsetDescendantRectToMyCoords(container, accessory)
        assertFalse("an item keeps its own tap", bar.isFirstLevelTapTarget(accessory.centerX().toFloat(), y))
        assertFalse("outside the field", bar.isFirstLevelTapTarget(-5f, y))
    }

    private fun Toolbar.performNavigationClick() {
        (0 until childCount).map { getChildAt(it) }.first { it is android.widget.ImageButton }.performClick()
    }
}
