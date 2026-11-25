package com.cyl.search.example

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.view.View
import android.view.ViewGroup
import com.cyl.classifymenu.CYLTagListView

/**
 * Debug switch (off by default; `adb shell am start --ez CYLDebugStripes true`): the plate draws 8 hard-edged saturated
 * horizontal stripes instead of the gradient, so the glass blur (API 31+) and refraction (API 33+) show on hard edges.
 */
internal var cylDebugStripes: Boolean = false

private val STRIPE_COLORS = intArrayOf(
    0xFFE53935.toInt(), 0xFFFB8C00.toInt(), 0xFFFDD835.toInt(), 0xFF43A047.toInt(),
    0xFF00ACC1.toInt(), 0xFF1E88E5.toInt(), 0xFF5E35B1.toInt(), 0xFFD81B60.toInt(),
)

private class CYLStripesView(context: Context) : View(context) {
    private val paint = Paint()

    override fun onDraw(canvas: Canvas) {
        val band = height / STRIPE_COLORS.size.toFloat()
        STRIPE_COLORS.forEachIndexed { index, color ->
            paint.color = color
            canvas.drawRect(0f, index * band, width.toFloat(), (index + 1) * band, paint)
        }
    }
}

/**
 * The gradient plate behind an example page (example-demos.md rule 7): a plain view that draws the gradient and sits BEHIND
 * the page's content as its sibling, never as an ancestor of a tag list. A tag list's `backdropSource` is this plate, so the
 * Liquid Glass of its tags, fold control and section boards can blur and refract it (the core forwards the one property to
 * every glass host; with null, or an ancestor, the glass draws tint + rim only; below Android 12 the flat fallback shows).
 */
internal fun cylBackdropPlate(context: Context): View =
    (if (cylDebugStripes) CYLStripesView(context) else View(context).apply { background = cylGradientPageBackground(context) }).apply {
        importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
    }

/** Sets `backdropSource = plate` on every `CYLTagListView` at or below `view`. */
internal fun cylSetBackdropSource(view: View, plate: View) {
    if (view is CYLTagListView) view.backdropSource = plate
    if (view is ViewGroup) {
        for (index in 0 until view.childCount) cylSetBackdropSource(view.getChildAt(index), plate)
    }
}
