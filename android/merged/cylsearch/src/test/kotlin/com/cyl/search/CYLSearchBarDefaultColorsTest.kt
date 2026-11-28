package com.cyl.search

import android.app.Activity
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.view.View
import android.view.ViewGroup
import com.cyl.classifymenu.CYLControlState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The bar core's default colors, the same on every platform (iOS `testSearchBarDefaultColorsFollowTheLabelColors`): the placeholder is the
 * secondary label color, an item sets no tint of its own (label color, accent when selected), the divider is the secondary label color
 * 1 x 20 with an 8 gap on each side, and a live light/dark switch re-resolves all of it.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchBarDefaultColorsTest {

    private val secondaryLight = Color.argb(153, 60, 60, 67)
    private val secondaryDark = Color.argb(153, 235, 235, 245)

    /** The page's theme decides light or dark (the luminance of its window background), not the system setting. */
    private fun activity(dark: Boolean): Activity = Robolectric.buildActivity(Activity::class.java).setup().get().also {
        it.setTheme(if (dark) androidx.appcompat.R.style.Theme_AppCompat else androidx.appcompat.R.style.Theme_AppCompat_Light)
    }

    private fun bar(activity: Activity): CYLSearchBarView = CYLSearchBarView(activity).also {
        it.addItem(CYLSearchBarItem.iconItem(ColorDrawable(Color.RED), "Camera", null))
        it.addItem(CYLSearchBarItem.divider())
    }

    private fun dividerColor(itemView: ViewGroup): Int? = (0 until itemView.childCount).map { itemView.getChildAt(it) }
        .mapNotNull { (it.background as? ColorDrawable)?.color }.firstOrNull { it == secondaryLight || it == secondaryDark }

    @Test
    fun lightModeDefaults() {
        val activity = activity(dark = false)
        val bar = bar(activity)
        assertEquals("placeholder: secondary label", secondaryLight, bar.placeholderLabel.currentTextColor)
        assertEquals("also on the field itself", secondaryLight, bar.textField.currentHintTextColor)
        val camera = bar.itemViews[0] as CYLSearchBarItemButton
        assertEquals(Color.BLACK, camera.style!!.iconColorForState(CYLControlState.NORMAL))
        assertEquals(Color.BLACK, camera.style!!.iconColorForState(CYLControlState.DISABLED))
        assertTrue("selected: the accent, not the label color", camera.style!!.iconColorForState(CYLControlState.SELECTED) != Color.BLACK)
        assertEquals(secondaryLight, dividerColor(bar.itemViews[1] as ViewGroup))
    }

    @Test
    fun darkModeDefaults() {
        val activity = activity(dark = true)
        val bar = bar(activity)
        assertEquals(secondaryDark, bar.placeholderLabel.currentTextColor)
        assertEquals(secondaryDark, bar.textField.currentHintTextColor)
        val camera = bar.itemViews[0] as CYLSearchBarItemButton
        assertEquals(Color.WHITE, camera.style!!.iconColorForState(CYLControlState.NORMAL))
        assertEquals(secondaryDark, dividerColor(bar.itemViews[1] as ViewGroup))
    }

    @Test
    fun aHostTintAndPlaceholderColorWin() {
        val activity = activity(dark = false)
        val bar = bar(activity)
        bar.itemTintColor = Color.GREEN
        bar.placeholderColor = Color.MAGENTA
        val camera = bar.itemViews[0] as CYLSearchBarItemButton
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            assertEquals(Color.GREEN, camera.style!!.iconColorForState(state))
        }
        assertEquals(Color.MAGENTA, bar.placeholderLabel.currentTextColor)
    }

    @Test
    fun theDividerIsOneByTwenty() {
        val activity = activity(dark = false)
        val bar = bar(activity)
        val density = activity.resources.displayMetrics.density
        val divider = bar.itemViews[1] as View
        divider.measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
        assertEquals("1 dp wide: the gaps beside it are the trailing group's spacing", Math.round(1 * density), divider.measuredWidth)
        assertEquals("20 dp high", Math.round(20 * density), divider.measuredHeight)
    }

    @Test
    fun aLiveSwitchReResolvesTheColorsAndNothingDisappears() {
        val activity = activity(dark = false)
        val bar = bar(activity)
        val camera = bar.itemViews[0] as CYLSearchBarItemButton
        activity.setTheme(androidx.appcompat.R.style.Theme_AppCompat)
        bar.dispatchConfigurationChanged(activity.resources.configuration)
        assertEquals(secondaryDark, bar.placeholderLabel.currentTextColor)
        assertEquals(Color.WHITE, (bar.itemViews[0] as CYLSearchBarItemButton).style!!.iconColorForState(CYLControlState.NORMAL))
        assertEquals(secondaryDark, dividerColor(bar.itemViews[1] as ViewGroup))
        activity.setTheme(androidx.appcompat.R.style.Theme_AppCompat_Light)
        bar.dispatchConfigurationChanged(activity.resources.configuration)
        assertEquals(secondaryLight, bar.placeholderLabel.currentTextColor)
        assertEquals(Color.BLACK, camera.style!!.iconColorForState(CYLControlState.NORMAL))
        assertEquals(secondaryLight, dividerColor(bar.itemViews[1] as ViewGroup))
    }
}
