package com.cyl.search.example

import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.appcompat.app.AppCompatActivity
import com.cyl.classifymenu.CYLTagListView
import java.io.File
import org.junit.Assert.assertFalse
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Example rule 7 on Android: the gradient is a sibling plate behind the lists and every tag list's `backdropSource` is that
 * plate (never an ancestor of the list), so the Liquid Glass can sample the gradient.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLBackdropSourceTest {

    private val activity: AppCompatActivity = Robolectric.buildActivity(AppCompatActivity::class.java).setup().get()

    @Test
    fun everyNestedTagListGetsThePlateAsItsBackdropSource() {
        val first = CYLTagListView(activity)
        val second = CYLTagListView(activity)
        val column = LinearLayout(activity).apply {
            addView(first)
            addView(LinearLayout(activity).apply { addView(second) })
        }
        val plate = cylBackdropPlate(activity)
        val page = FrameLayout(activity).apply {
            addView(plate)
            addView(column)
            cylSetBackdropSource(column, plate)
        }
        assertSame(plate, first.backdropSource)
        assertSame(plate, second.backdropSource)
        // A sibling behind the content, not an ancestor of a list.
        assertSame(page, plate.parent)
        assertTrue(page.indexOfChild(plate) < page.indexOfChild(column))
        var ancestor = first.parent
        while (ancestor != null) {
            assertFalse(ancestor === plate)
            ancestor = ancestor.parent
        }
    }

    @Test
    fun theExamplePagesSetTheBackdropSourceAndDrawTheGradientOnlyOnThePlate() {
        val dir = File("src/main/kotlin/com/cyl/search/example")
        val page = File(dir, "CYLExamplePage.kt").readText()
        val discover = File(dir, "CYLSearchDiscoverFragment.kt").readText()
        assertTrue(page.contains("cylSetBackdropSource(column, plate)"))
        assertTrue(discover.contains("recentList.backdropSource = plate"))
        assertTrue(discover.contains("discoverList.backdropSource = plate"))
        // No page view carries the gradient as its own background (it would be an ancestor of the lists).
        assertFalse(Regex("background = cylGradientPageBackground").containsMatchIn(page + discover))
    }
}
