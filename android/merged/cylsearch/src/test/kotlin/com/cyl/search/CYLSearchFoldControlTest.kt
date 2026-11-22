package com.cyl.search

import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.activity.ComponentActivity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * The fold control of the launch area's tags (docs/qmui-search-controller.md, "Fold control fix (2026-11-22)"): the
 * folded list ends with the fold control (CollectionViewClassifyMenu's `CYLMenuFoldControl` at the tail, 2 rows), it
 * toggles, and a list that fits in 2 rows has nothing to fold and so no control. A 1080 x 2400 px, 420 dpi screen (the
 * example's AVD) and the native text measurement (the legacy one measures text far too narrow, so every tag fits one row).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], qualifiers = "w411dp-h914dp-420dpi")
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLSearchFoldControlTest {

    private val activity: ComponentActivity = Robolectric.buildActivity(ComponentActivity::class.java)
        .also { it.get().setTheme(android.R.style.Theme_Material_NoActionBar) }.setup().get()
    private val column = LinearLayout(activity).apply { orientation = LinearLayout.VERTICAL }

    private fun idle() = org.robolectric.Shadows.shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(2000))

    private fun layoutWindow() {
        val decor = activity.window.decorView
        val metrics = activity.resources.displayMetrics
        decor.measure(View.MeasureSpec.makeMeasureSpec(metrics.widthPixels, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(metrics.heightPixels, View.MeasureSpec.EXACTLY))
        decor.layout(0, 0, metrics.widthPixels, metrics.heightPixels)
    }

    /** The launch area as the Search controller example opens it: no history, only `suggestions`. */
    private fun launchArea(suggestions: List<String>): CYLSearchView {
        val view = CYLSearchView(activity)
        view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.None
        view.suggestions = suggestions
        view.showsSuggestionsForEmptyQuery = true
        activity.setContentView(column)
        column.addView(view, LinearLayout.LayoutParams(-1, -1))
        // Opened while the page has no width yet, then laid out (the first open).
        view.showSearch(false)
        layoutWindow()
        idle()
        layoutWindow()
        idle()
        return view
    }

    private fun cells(view: View, out: MutableList<View> = ArrayList()): List<View> {
        val name = view.javaClass.simpleName
        if (view.visibility == View.VISIBLE && (name == "CYLTagListCell" || name == "CYLTagFoldCell")) out.add(view)
        if (view is ViewGroup) for (index in 0 until view.childCount) cells(view.getChildAt(index), out)
        return out
    }

    /** The laid-out tags in reading order (row, then left to right). */
    private fun shown(view: CYLSearchView): List<View> =
        cells(view.suggestionsTagView).sortedWith(compareBy({ it.top }, { it.left }))

    private fun isFoldControl(view: View) = view.javaClass.simpleName == "CYLTagFoldCell"

    @Test
    fun tenSuggestionsFoldToTwoRowsAndTheLastTagIsTheFoldControl() {
        val view = launchArea(TEN)
        val tags = view.suggestionsTagView
        assertTrue("more than 2 rows at 411 dp (${tags.numberOfRowsInSection(0)})", tags.numberOfRowsInSection(0) > 2)
        assertTrue(tags.canFoldSection(0))
        assertFalse(tags.isSectionExpanded(0))
        val folded = shown(view)
        assertTrue("the last tag is the fold control", isFoldControl(folded.last()))
        assertEquals("one control", 1, folded.count { isFoldControl(it) })
        assertEquals("two rows", 2, folded.map { it.top }.distinct().size)
        assertTrue("some tags are folded away", folded.size - 1 < TEN.size)
        assertEquals(tags.numberOfVisibleItemsInSection(0), folded.size - 1)
        assertTrue("the control is inside the list", folded.last().right <= tags.width && folded.last().bottom <= tags.height)

        // Unfolds: every tag, and the control is still the last one.
        folded.last().performClick()
        layoutWindow()
        idle()
        layoutWindow()
        val unfolded = shown(view)
        assertTrue(tags.isSectionExpanded(0))
        assertEquals("every tag shows", TEN.size, unfolded.count { !isFoldControl(it) })
        assertTrue("the last tag is the fold control", isFoldControl(unfolded.last()))
        assertEquals("one control", 1, unfolded.count { isFoldControl(it) })
        assertTrue("the control is inside the list", unfolded.last().bottom <= tags.height)

        // Folds again.
        unfolded.last().performClick()
        layoutWindow()
        idle()
        layoutWindow()
        val again = shown(view)
        assertFalse(tags.isSectionExpanded(0))
        assertTrue(isFoldControl(again.last()))
        assertEquals(folded.size, again.size)
    }

    @Test
    fun eightSuggestionsFitTwoRowsSoThereIsNothingToFoldAndNoControl() {
        val view = launchArea(TEN.take(8))
        val tags = view.suggestionsTagView
        assertEquals("the example's eight suggestions take 2 rows", 2, tags.numberOfRowsInSection(0))
        assertFalse(tags.canFoldSection(0))
        val all = shown(view)
        assertEquals("every tag shows", 8, all.size)
        assertTrue("no control, nothing is hidden", all.none { isFoldControl(it) })
    }

    private companion object {
        val TEN = listOf("Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat", "Metabolism", "Naturally")
    }
}
