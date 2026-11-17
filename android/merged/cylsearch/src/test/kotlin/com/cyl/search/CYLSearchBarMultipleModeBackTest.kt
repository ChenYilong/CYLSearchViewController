package com.cyl.search

import androidx.activity.ComponentActivity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner

/**
 * The system Back gesture ends the search being typed in a `CYLSearchBarView` in `Multiple` mode, and only then.
 */
@RunWith(RobolectricTestRunner::class)
class CYLSearchBarMultipleModeBackTest {
    private val activity: ComponentActivity =
        Robolectric.buildActivity(ComponentActivity::class.java).setup().get()

    @Test
    fun backCompletesTypingOnlyWhileTyping() {
        val bar = CYLSearchBarView(activity)
        bar.mode = CYLSearchBarMode.Multiple
        activity.setContentView(bar)
        assertFalse(activity.onBackPressedDispatcher.hasEnabledCallbacks())
        bar.beginNewSearch()
        assertTrue(activity.onBackPressedDispatcher.hasEnabledCallbacks())
        activity.onBackPressedDispatcher.onBackPressed()
        assertFalse(bar.isEditingNewSearch)
        assertFalse(activity.onBackPressedDispatcher.hasEnabledCallbacks())
        assertEquals(-1, bar.selectedSearchIndex)
    }

    @Test
    fun singleModeNeverTakesTheBackGesture() {
        val bar = CYLSearchBarView(activity)
        activity.setContentView(bar)
        bar.beginNewSearch()
        assertFalse(activity.onBackPressedDispatcher.hasEnabledCallbacks())
    }
}
