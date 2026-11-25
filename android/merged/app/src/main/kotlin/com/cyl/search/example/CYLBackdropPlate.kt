package com.cyl.search.example

import android.content.Context
import android.view.View
import android.view.ViewGroup
import com.cyl.classifymenu.CYLTagListView

/**
 * The gradient plate behind an example page (example-demos.md rule 7): a plain view that draws the gradient and sits BEHIND
 * the page's content as its sibling, never as an ancestor of a tag list. A tag list's `backdropSource` is this plate, so the
 * Liquid Glass of its tags, fold control and section boards can blur and refract it (the core forwards the one property to
 * every glass host; with null, or an ancestor, the glass draws tint + rim only; below Android 12 the flat fallback shows).
 */
internal fun cylBackdropPlate(context: Context): View = View(context).apply {
    background = cylGradientPageBackground(context)
    importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
}

/** Sets `backdropSource = plate` on every `CYLTagListView` at or below `view`. */
internal fun cylSetBackdropSource(view: View, plate: View) {
    if (view is CYLTagListView) view.backdropSource = plate
    if (view is ViewGroup) {
        for (index in 0 until view.childCount) cylSetBackdropSource(view.getChildAt(index), plate)
    }
}
