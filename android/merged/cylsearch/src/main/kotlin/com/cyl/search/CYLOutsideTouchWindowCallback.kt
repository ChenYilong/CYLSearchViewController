package com.cyl.search

import android.view.MotionEvent
import android.view.Window

/**
 * The activity window's callback while a search field is editing (`CYLSearchBarView.dismissesKeyboardOnOutsideTouch`): it sees
 * every touch before any view does, reports it, and passes everything to the callback it wraps. Inactive, it only passes on.
 */
internal class CYLOutsideTouchWindowCallback(
    val wrapped: Window.Callback,
    private val onTouch: (MotionEvent) -> Unit,
) : Window.Callback by wrapped {

    /** False once the bar stopped observing; a wrapper still above this one keeps passing events through it. */
    var isActive = true

    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        if (isActive) onTouch(event)
        return wrapped.dispatchTouchEvent(event)
    }
}
