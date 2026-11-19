package com.cyl.search

import android.app.Activity
import android.view.inputmethod.EditorInfo
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * docs/core-todo.md, "the editing bar": the search bar as an edit field (iOS `testEditingBarSubmitsAndRidesOnTheKeyboard`).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchBarEditingBarTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    @Test
    fun editingBarSubmitsTrimmedTextAndPinsToTheContainer() {
        val bar = CYLSearchBarView.editingBar(activity, "Tag name", "Add")
        assertTrue(bar.isEditingBar)
        assertNull("no magnifier", bar.searchIcon)
        assertEquals("Tag name", bar.placeholder)
        assertTrue(bar.showsCancelButton)
        assertEquals("Add", bar.cancelButtonTitle)
        assertEquals(EditorInfo.IME_ACTION_DONE, bar.returnKeyType)
        assertEquals(CYLTextAutocapitalizationType.Words, bar.autocapitalizationType)
        assertEquals(CYLTextAutocorrectionType.No, bar.autocorrectionType)

        val submitted = ArrayList<String>()
        bar.editingSubmitHandler = { _, text -> submitted.add(text) }
        // The trailing button submits (not a cancel), as the action key does; empty text submits nothing.
        bar.text = "  Family  "
        bar.cancelButton.performClick()
        bar.text = "   "
        bar.cancelButton.performClick()
        bar.text = "Friends"
        bar.textField.onEditorAction(EditorInfo.IME_ACTION_DONE)
        assertEquals(listOf("Family", "Friends"), submitted)

        // A delegate that refuses the text stops the submit (iOS -searchBarView:shouldSubmitText:).
        bar.delegate = object : CYLSearchBarViewDelegate {
            override fun searchBarViewShouldSubmitText(searchBarView: CYLSearchBarView, text: String) = false
        }
        bar.text = "Refused"
        bar.cancelButton.performClick()
        assertEquals(2, submitted.size)

        val page = FrameLayout(activity)
        activity.setContentView(page)
        bar.pinToKeyboard(page)
        assertSame(page, bar.parent)
        assertEquals(android.view.Gravity.BOTTOM, (bar.layoutParams as FrameLayout.LayoutParams).gravity)
    }
}
