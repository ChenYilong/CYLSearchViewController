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
 * The system Back gesture ends the search being typed in a `CYLMultiSearchView`, and only then.
 */
@RunWith(RobolectricTestRunner::class)
class CYLMultiSearchBackTest {
    private val activity: ComponentActivity =
        Robolectric.buildActivity(ComponentActivity::class.java).setup().get()

    @Test
    fun backCompletesTypingOnlyWhileTyping() {
        val view = CYLMultiSearchView(activity)
        activity.setContentView(view)
        assertFalse(activity.onBackPressedDispatcher.hasEnabledCallbacks())
        view.search()
        assertTrue(activity.onBackPressedDispatcher.hasEnabledCallbacks())
        activity.onBackPressedDispatcher.onBackPressed()
        assertFalse(view.isInSearchMode)
        assertFalse(activity.onBackPressedDispatcher.hasEnabledCallbacks())
        assertEquals(-1, view.selectedIndex)
    }
}
