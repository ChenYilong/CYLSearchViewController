package com.cyl.search

import android.graphics.drawable.ColorDrawable
import android.view.View
import android.widget.FrameLayout
import androidx.activity.ComponentActivity
import androidx.appcompat.widget.Toolbar
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

/**
 * `focusesOnAppear` focuses the field every time the bar appears (first entry, re-attach, becoming visible, Activity resume),
 * only when the bar sits in a toolbar that shows a back button; off by default.
 */
@RunWith(RobolectricTestRunner::class)
class CYLSearchBarFocusesOnAppearTest {
    private val controller = Robolectric.buildActivity(ComponentActivity::class.java).setup()
    private val activity: ComponentActivity = controller.get()
    private val root = FrameLayout(activity).also { activity.setContentView(it) }

    private fun idle() = shadowOf(android.os.Looper.getMainLooper()).idle()

    private fun toolbarOf(bar: CYLSearchBarView, withArrow: Boolean): Toolbar =
        Toolbar(activity).also {
            if (withArrow) it.navigationIcon = ColorDrawable(0)
            bar.embedInToolbar(it)
        }

    @Test
    fun offByDefaultNeverFocuses() {
        val bar = CYLSearchBarView(activity)
        assertFalse(bar.focusesOnAppear)
        root.addView(toolbarOf(bar, true))
        idle()
        assertFalse(bar.textField.hasFocus())
    }

    @Test
    fun focusesOnFirstEntryAndEveryReattach() {
        val bar = CYLSearchBarView(activity)
        bar.focusesOnAppear = true
        val toolbar = toolbarOf(bar, true)
        root.addView(toolbar)
        idle()
        assertTrue(bar.textField.hasFocus())
        bar.hideKeyboard()
        assertFalse(bar.textField.hasFocus())
        root.removeView(toolbar)
        root.addView(toolbar)
        idle()
        assertTrue(bar.textField.hasFocus())
    }

    @Test
    fun withoutBackButtonNeverFocuses() {
        val bar = CYLSearchBarView(activity)
        bar.focusesOnAppear = true
        root.addView(toolbarOf(bar, false))
        idle()
        assertFalse(bar.textField.hasFocus())
        val plain = CYLSearchBarView(activity)
        plain.focusesOnAppear = true
        root.addView(plain)
        idle()
        assertFalse(plain.textField.hasFocus())
    }

    @Test
    fun focusesWhenBecomingVisibleAgain() {
        val bar = CYLSearchBarView(activity)
        bar.focusesOnAppear = true
        root.addView(toolbarOf(bar, true))
        idle()
        bar.hideKeyboard()
        bar.visibility = View.INVISIBLE
        idle()
        assertFalse(bar.textField.hasFocus())
        bar.visibility = View.VISIBLE
        idle()
        assertTrue(bar.textField.hasFocus())
    }

    @Test
    fun focusesWhenTheActivityResumes() {
        val bar = CYLSearchBarView(activity)
        bar.focusesOnAppear = true
        root.addView(toolbarOf(bar, true))
        idle()
        bar.hideKeyboard()
        controller.pause()
        idle()
        assertFalse(bar.textField.hasFocus())
        controller.resume()
        idle()
        assertTrue(bar.textField.hasFocus())
    }

    @Test
    fun turningItOnWhileOnScreenFocusesAtOnce() {
        val bar = CYLSearchBarView(activity)
        root.addView(toolbarOf(bar, true))
        idle()
        bar.focusesOnAppear = true
        idle()
        assertTrue(bar.textField.hasFocus())
    }
}
