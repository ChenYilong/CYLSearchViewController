package com.cyl.search

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * A tap on the default search button with EMPTY text on a search view submits nothing, records nothing, closes nothing and keeps
 * the keyboard; with text it submits as before; a plain bar still tells its delegate (iOS
 * testDefaultSearchButtonWithEmptyTextDoesNothingInASearchView).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchViewEmptySearchButtonTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private class Recorder : CYLSearchViewDelegate {
        val submitted = mutableListOf<String>()
        override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean {
            submitted += text
            return false
        }
    }

    private fun find(view: View, tag: String): View? {
        if (view.tag == tag) return view
        if (view is ViewGroup) for (index in 0 until view.childCount) find(view.getChildAt(index), tag)?.let { return it }
        return null
    }

    private fun openView(): Pair<CYLSearchView, Recorder> {
        val host = FrameLayout(activity)
        activity.setContentView(host)
        val view = CYLSearchView(activity)
        view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.UserDefaults
        view.suggestionCacheName = "CYLTestEmptyButton"
        view.suggestionCache!!.removeAllQueries()
        val recorder = Recorder()
        view.delegate = recorder
        view.installInView(host)
        view.showSearch(false)
        return view to recorder
    }

    @Test
    fun emptyButtonTapDoesNothingInASearchView() {
        val (view, recorder) = openView()
        assertTrue(view.searchBarView.textField.hasFocus())
        find(view.searchBarView, "CYLSearchBarSearchButton")!!.performClick()
        assertTrue("nothing submitted", recorder.submitted.isEmpty())
        assertTrue("nothing recorded", view.suggestionCache!!.cachedQueries().isEmpty())
        assertTrue("not closed", view.isSearchOpen)
        assertTrue("the keyboard stays", view.searchBarView.textField.hasFocus())
    }

    @Test
    fun buttonTapWithTextStillSubmitsAndRecords() {
        val (view, recorder) = openView()
        view.closesOnSubmit = false
        view.searchBarView.text = "kotlin"
        find(view.searchBarView, "CYLSearchBarSearchButton")!!.performClick()
        assertEquals(listOf("kotlin"), recorder.submitted)
        assertEquals(listOf("kotlin"), view.suggestionCache!!.cachedQueries())
    }

    @Test
    fun aPlainBarStillTellsItsDelegateForEmptyText() {
        val bar = CYLSearchBarView(activity)
        var clicks = 0
        bar.delegate = object : CYLSearchBarViewDelegate {
            override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) { clicks++ }
        }
        find(bar, "CYLSearchBarSearchButton")!!.performClick()
        assertEquals(1, clicks)
    }
}
