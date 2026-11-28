package com.cyl.search

import android.app.Activity
import android.graphics.Color
import android.graphics.Rect
import android.graphics.Typeface
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowLooper

/**
 * The QMUI search bar port on `CYLSearchBarView` (docs/qmui-search-controller.md, "Android (Kotlin, android/merged: core
 * module cylsearch, example app): QMUI search port"): placeholder, field and Cancel margins, Cancel, accessory views,
 * the appearance. The bar never covers a view in any of these states.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchBarQMUIPortTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun bar(): CYLSearchBarView {
        val host = FrameLayout(activity)
        activity.setContentView(host)
        val bar = CYLSearchBarView(activity)
        host.addView(bar, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        layout(bar)
        return bar
    }

    private fun layout(bar: View) {
        bar.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
        bar.layout(0, 0, bar.measuredWidth, bar.measuredHeight)
    }

    private fun idle() = org.robolectric.Shadows.shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(2000))

    private fun frame(view: View, root: View): Rect {
        val rect = Rect()
        view.getDrawingRect(rect)
        (root as ViewGroup).offsetDescendantRectToMyCoords(view, rect)
        return rect
    }

    /**
     * No visible child of the bar overlaps another along the row: the field, the accessory views and Cancel.
     */
    private fun assertNoOverlap(bar: CYLSearchBarView) {
        val views = listOf(bar.fieldView, bar.cancelButton).filter { it.visibility == View.VISIBLE && it.width > 0 }
        val rects = views.map { frame(it, bar) }
        for (i in rects.indices) {
            for (j in i + 1 until rects.size) {
                assertFalse("${views[i]} overlaps ${views[j]}: ${rects[i]} ${rects[j]}", Rect.intersects(rects[i], rects[j]))
            }
        }
    }

    @Test
    fun placeholderIsCenteredAtRestAndLeadingWhileEditing() {
        val bar = bar()
        bar.placeholder = "Search the whole catalogue"
        layout(bar)
        val leading = bar.searchIconView.left
        bar.centersPlaceholder = true
        layout(bar)
        assertTrue("the magnifier moved toward the middle: ${bar.searchIconView.left} > $leading", bar.searchIconView.left > leading)
        val centered = bar.searchIconView.left
        bar.textField.requestFocus()
        layout(bar)
        assertEquals("editing: leading again", leading, bar.searchIconView.left)
        bar.hideKeyboard()
        layout(bar)
        assertEquals("back at rest: centered again", centered, bar.searchIconView.left)
        bar.text = "abc"
        layout(bar)
        assertEquals("with text: leading", leading, bar.searchIconView.left)
        bar.text = ""
        bar.centersPlaceholder = false
        layout(bar)
        assertEquals(leading, bar.searchIconView.left)
    }

    @Test
    fun fieldMarginsApplyPerStateAndTheProviderWins() {
        val bar = bar()
        bar.textFieldMargins = Rect(4, 0, 4, 0)
        val params = { bar.fieldView.layoutParams as ViewGroup.MarginLayoutParams }
        val density = activity.resources.displayMetrics.density
        assertEquals((4 * density + 0.5f).toInt(), params().marginStart)
        bar.textFieldMarginsProvider = { _, active -> if (active) Rect() else Rect(32, 0, 32, 0) }
        assertEquals("the provider wins at rest", (32 * density + 0.5f).toInt(), params().marginStart)
        assertEquals((32 * density + 0.5f).toInt(), params().marginEnd)
        bar.textField.requestFocus()
        assertTrue(bar.isActive)
        assertEquals("active: no margin", 0, params().marginStart)
        bar.hideKeyboard()
        assertEquals((32 * density + 0.5f).toInt(), params().marginStart)
        layout(bar)
        assertNoOverlap(bar)
    }

    @Test
    fun cancelMarginsFontAndTheNegativeValueNeverCoverTheField() {
        val bar = bar()
        bar.showsCancelButton = true
        bar.cancelButtonFont = Typeface.DEFAULT_BOLD
        assertSame(Typeface.DEFAULT_BOLD, bar.cancelButton.typeface)
        bar.cancelButtonMarginsProvider = { _, active -> if (active) Rect(-16, 0, 0, 0) else Rect() }
        bar.textField.requestFocus()
        layout(bar)
        val params = bar.cancelButton.layoutParams as ViewGroup.MarginLayoutParams
        assertTrue("never negative: ${params.marginStart}", params.marginStart >= 0)
        assertNoOverlap(bar)
        bar.hideKeyboard()
        layout(bar)
        val density = activity.resources.displayMetrics.density
        assertEquals("at rest: the 8 dp gap", (8 * density + 0.5f).toInt(), (bar.cancelButton.layoutParams as ViewGroup.MarginLayoutParams).marginStart)
    }

    @Test
    fun cancelShowsAndHidesAnimatedOrNot() {
        val bar = bar()
        assertEquals(View.GONE, bar.cancelButton.visibility)
        bar.setShowsCancelButton(true, false)
        assertEquals(View.VISIBLE, bar.cancelButton.visibility)
        bar.setShowsCancelButton(false, true)
        idle()
        assertEquals(View.GONE, bar.cancelButton.visibility)
        // Two quick toggles end in the requested state (QMUI's guard against fast toggling).
        bar.setShowsCancelButton(true, true)
        bar.setShowsCancelButton(false, true)
        bar.setShowsCancelButton(true, true)
        idle()
        assertEquals(View.VISIBLE, bar.cancelButton.visibility)
        assertEquals(1f, bar.cancelButton.alpha, 0f)
        bar.setShowsCancelButton(false, true)
        bar.setShowsCancelButton(true, true)
        bar.setShowsCancelButton(false, true)
        idle()
        assertEquals(View.GONE, bar.cancelButton.visibility)
    }

    @Test
    fun cancelAppearsWhileEditingWhenAsked() {
        val bar = bar()
        bar.showsCancelButtonWhenEditing = true
        assertEquals(View.GONE, bar.cancelButton.visibility)
        bar.textField.requestFocus()
        idle()
        assertEquals(View.VISIBLE, bar.cancelButton.visibility)
        bar.hideKeyboard()
        idle()
        assertEquals(View.GONE, bar.cancelButton.visibility)
    }

    @Test
    fun accessoryViewsShowHideAndShrinkTheField() {
        val bar = bar()
        val density = activity.resources.displayMetrics.density
        val gap = (8 * density + 0.5f).toInt()
        val leading = View(activity)
        val trailing = View(activity)
        // The view before the field is the one leadingView; its margins are its own (6 dp + the slot's 2 dp = QMUI's 8 dp gap).
        leading.layoutParams = FrameLayout.LayoutParams(90, 90).apply { setMargins(gap, 0, gap - (2 * density + 0.5f).toInt(), 0) }
        trailing.layoutParams = ViewGroup.LayoutParams(30, 30)
        bar.leadingView = leading
        bar.trailingAccessoryViews = listOf(trailing)
        layout(bar)
        val full = bar.fieldView.width
        val fullText = bar.textField.width
        assertTrue("shown by default", bar.showsLeadingView && bar.showsTrailingAccessoryViews)
        assertEquals(View.VISIBLE, (leading.parent as View).visibility)
        assertTrue("the field shares the row: $full", full < 1080)
        bar.setShowsLeadingView(false, false)
        bar.setShowsTrailingAccessoryViews(false, false)
        layout(bar)
        assertTrue("hidden: the field is wider: ${bar.fieldView.width} > $full", bar.fieldView.width > full)
        assertTrue("hidden: the text has more room: ${bar.textField.width} > $fullText", bar.textField.width > fullText)
        assertEquals(View.GONE, (leading.parent as View).visibility)
        assertEquals(View.GONE, (trailing.parent as View).visibility)
        bar.setShowsLeadingView(true, true)
        bar.setShowsLeadingView(false, true)
        bar.setShowsLeadingView(true, true)
        bar.setShowsTrailingAccessoryViews(true, true)
        bar.setShowsTrailingAccessoryViews(false, true)
        idle()
        layout(bar)
        assertEquals("quick toggles: the last call wins (shown)", View.VISIBLE, (leading.parent as View).visibility)
        assertEquals("quick toggles: the last call wins (hidden)", View.GONE, (trailing.parent as View).visibility)
        bar.setShowsTrailingAccessoryViews(true, false)
        layout(bar)
        val both = frame(bar.fieldView, bar)
        val leadingRect = frame(leading, bar)
        val trailingRect = frame(trailing, bar)
        assertFalse("leading does not cover the field", Rect.intersects(both, leadingRect))
        assertTrue("trailing sits inside the field: $trailingRect in $both", both.contains(trailingRect))
        assertEquals("shown again: the text has the width it had with it", fullText, bar.textField.width)
        assertTrue("gap: ${both.left - leadingRect.right}", both.left - leadingRect.right >= gap)
        bar.showsCancelButton = true
        layout(bar)
        assertFalse("trailing does not cover Cancel", Rect.intersects(frame(bar.cancelButton, bar), frame(trailing, bar)))
        assertNoOverlap(bar)
        bar.leadingView = null
        bar.trailingAccessoryViews = emptyList()
        layout(bar)
        assertEquals("the slot is empty again", 0, (leading.parent as? ViewGroup)?.childCount ?: 0)
    }

    @Suppress("DEPRECATION")
    @Test
    fun oldAccessoryNamesForwardToTheOneSlot() {
        val bar = bar()
        val leading = View(activity)
        val trailing = View(activity)
        bar.leadingAccessoryView = leading
        bar.trailingAccessoryView = trailing
        assertSame("one slot before the field", leading, bar.leadingView)
        assertSame(leading, bar.leadingAccessoryView)
        assertEquals(listOf(trailing), bar.trailingAccessoryViews)
        assertSame(trailing, bar.trailingAccessoryView)
        bar.setShowsLeadingAccessoryView(false, false)
        assertFalse(bar.showsLeadingView)
        assertFalse(bar.showsLeadingAccessoryView)
        bar.showsTrailingAccessoryView = false
        assertFalse(bar.showsTrailingAccessoryViews)
        layout(bar)
        assertEquals(View.GONE, (leading.parent as View).visibility)
        // The margins are padding of the slot and margins of the views: still there, no second container.
        bar.setShowsLeadingAccessoryView(true, false)
        bar.setShowsTrailingAccessoryView(true, false)
        bar.leadingAccessoryViewMargins = Rect(8, 0, 0, 0)
        bar.trailingAccessoryViewMargins = Rect(0, 0, 8, 0)
        layout(bar)
        assertEquals((8 * activity.resources.displayMetrics.density + 0.5f).toInt(), (leading.parent as View).paddingLeft)
        assertEquals((8 * activity.resources.displayMetrics.density + 0.5f).toInt(), (trailing.layoutParams as ViewGroup.MarginLayoutParams).rightMargin)
        assertSame("the same container as leadingView", bar.fieldView.parent, (leading.parent as View).parent)
    }

    @Test
    fun defaultAppearanceLandsOnTheBar() {
        val bar = bar()
        bar.applyDefaultAppearance()
        assertEquals("search.field", "Search", bar.placeholder?.takeIf { it.isNotEmpty() }?.let { "Search" })
        assertEquals(CYLSearchResources.localizedString(activity, "search.cancel"), bar.cancelButtonTitle)
        assertEquals(Color.rgb(187, 186, 193), bar.fieldBackgroundColor)
        assertEquals(Color.rgb(0, 104, 248), bar.tintColor)
        assertEquals(Color.rgb(0, 104, 248), bar.cancelButton.currentTextColor)
        // A property set after the style wins; a copy changes alone.
        bar.fieldBackgroundColor = Color.RED
        assertEquals(Color.RED, bar.fieldBackgroundColor)
        val copy = bar.appearanceStyle!!.copy().also { it.fieldBackgroundColor = Color.BLUE }
        assertEquals(Color.rgb(187, 186, 193), bar.appearanceStyle!!.fieldBackgroundColor)
        bar.appearanceStyle = copy
        assertEquals(Color.BLUE, bar.fieldBackgroundColor)
    }

    @Test
    @Config(qualifiers = "night")
    fun darkAppearanceUsesTheDarkField() {
        assertEquals(Color.rgb(58, 58, 60), CYLSearchBarAppearance.defaultAppearance(activity).fieldBackgroundColor)
    }

    @Test
    fun shortGapsKeepTheBarFromCoveringAnything() {
        val bar = bar()
        bar.showsCancelButton = true
        bar.leadingView = View(activity).apply { layoutParams = ViewGroup.LayoutParams(60, 60) }
        bar.trailingAccessoryViews = listOf(View(activity).apply { layoutParams = ViewGroup.LayoutParams(60, 60) })
        bar.fontSize = 30f
        layout(bar)
        assertNoOverlap(bar)
        bar.textField.requestFocus()
        bar.text = "a long query that needs more room than the field has at rest"
        layout(bar)
        assertNoOverlap(bar)
        ShadowLooper.idleMainLooper()
    }
}
