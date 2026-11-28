package com.iammert.library.ui.multisearchviewlib.helper

import android.app.Activity
import android.content.Context
import android.view.View
import android.view.WindowManager
import android.view.inputmethod.InputMethodManager

object KeyboardHelper {

    // Issue #19: toggleSoftInput does nothing on Android 12+; showSoftInput on the focused field works everywhere.
    fun showKeyboard(view: View) {
        view.requestFocus()
        (view.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager)
            .showSoftInput(view, InputMethodManager.SHOW_IMPLICIT)
    }

    @Deprecated("Pass the field that should receive the text (issue #19)", ReplaceWith("showKeyboard(view)"))
    fun showKeyboard(context: Context) {
        (context as? Activity)?.currentFocus?.let { showKeyboard(it) }
    }

    fun hideKeyboard(context: Context) {
        try {
            (context as Activity).window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN)
            if (context.currentFocus != null && context.currentFocus!!.windowToken != null) {
                (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager).hideSoftInputFromWindow(
                    context.currentFocus!!.windowToken,
                    0
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}