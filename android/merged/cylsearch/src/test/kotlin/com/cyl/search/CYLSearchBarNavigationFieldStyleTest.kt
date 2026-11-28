package com.cyl.search

import android.app.Activity
import android.graphics.Color
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * `applyNavigationFieldStyle()` is the one look of every search field (iOS `applyNavigationFieldStyle()`): bordered capsule,
 * radius 18, shadow 0.06, no magnifier, 16 sp text and an opaque white fill in light mode.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchBarNavigationFieldStyleTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get().also {
        it.setTheme(androidx.appcompat.R.style.Theme_AppCompat_Light)
    }

    @Test
    fun presetSetsTheDiscoverLook() {
        val bar = CYLSearchBarView(activity)
        bar.applyNavigationFieldStyle()
        assertNull(bar.searchIcon)
        assertEquals(CYLSearchBarStyle.Bordered, bar.searchBarStyle)
        assertEquals(18f, bar.fieldCornerRadius, 0f)
        assertEquals(0.06f, bar.fieldShadowOpacity, 0f)
        assertEquals(16f, bar.fontSize, 0f)
        assertEquals(Color.WHITE, bar.fieldBackgroundColor)
        assertEquals(1f, bar.fieldBorderWidth, 0f)
    }
}
