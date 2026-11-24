package com.cyl.search

import android.app.Activity
import android.graphics.Color
import androidx.appcompat.widget.Toolbar
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The bordered search bar of the Discover page has the iOS look (`.systemBackground` fill, `.separator` border) and fits the
 * 44 dp slot of a navigation bar, so its border is not clipped.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchBarFlatLookTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get().also {
        it.setTheme(androidx.appcompat.R.style.Theme_AppCompat_Light)
    }

    @Test
    fun borderedFieldIsWhiteWithTheVisibleSecondaryLabelBorder() {
        val bar = CYLSearchBarView(activity)
        bar.searchBarStyle = CYLSearchBarStyle.Bordered
        assertEquals(Color.WHITE, bar.fieldBackgroundColor)
        assertEquals(Color.argb(153, 60, 60, 67), bar.fieldBorderColor) // iOS secondaryLabel (owner: darker on every platform), not the faint 29% separator
        assertEquals(1f, bar.fieldBorderWidth, 0f)
    }

    @Test
    fun embeddedBarFitsTheFortyFourDpNavigationBarSlot() {
        val bar = CYLSearchBarView(activity)
        bar.embedInToolbar(Toolbar(activity))
        assertEquals(4, bar.contentInsets.top)
        assertEquals(4, bar.contentInsets.bottom)
        val slot = 44 * activity.resources.displayMetrics.density
        bar.measure(
            android.view.View.MeasureSpec.makeMeasureSpec(1080, android.view.View.MeasureSpec.EXACTLY),
            android.view.View.MeasureSpec.makeMeasureSpec(0, android.view.View.MeasureSpec.UNSPECIFIED),
        )
        assertEquals("36 dp field + 4 dp above and below", Math.round(slot), bar.measuredHeight)
    }
}
