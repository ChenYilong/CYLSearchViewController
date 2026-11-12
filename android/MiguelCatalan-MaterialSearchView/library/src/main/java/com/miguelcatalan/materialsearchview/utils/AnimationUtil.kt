// Kotlin transcription of MiguelCatalan/MaterialSearchView (commit 53e163c), Apache License 2.0, see ../../../../../../../LICENSE.
// Original author: Miguel Catalan Bañuls. Changes: Java to Kotlin, android.support to AndroidX.
package com.miguelcatalan.materialsearchview.utils

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.util.TypedValue
import android.view.View
import android.view.ViewAnimationUtils
import androidx.core.view.ViewCompat
import androidx.core.view.ViewPropertyAnimatorListener

/**
 * Fade and reveal animations used by MaterialSearchView.
 *
 * @author Miguel Catalan Bañuls
 */
object AnimationUtil {

    @JvmField var ANIMATION_DURATION_SHORT = 150
    @JvmField var ANIMATION_DURATION_MEDIUM = 400
    @JvmField var ANIMATION_DURATION_LONG = 800

    interface AnimationListener {
        /**
         * @return true to override parent. Else execute Parent method
         */
        fun onAnimationStart(view: View): Boolean

        fun onAnimationEnd(view: View): Boolean

        fun onAnimationCancel(view: View): Boolean
    }

    @JvmStatic
    @JvmOverloads
    fun crossFadeViews(showView: View, hideView: View, duration: Int = ANIMATION_DURATION_SHORT) {
        fadeInView(showView, duration)
        fadeOutView(hideView, duration)
    }

    @JvmStatic
    @JvmOverloads
    fun fadeInView(view: View, duration: Int = ANIMATION_DURATION_SHORT, listener: AnimationListener? = null) {
        view.visibility = View.VISIBLE
        view.alpha = 0f
        val vpListener = listener?.let {
            object : ViewPropertyAnimatorListener {
                override fun onAnimationStart(view: View) {
                    it.onAnimationStart(view)
                }

                override fun onAnimationEnd(view: View) {
                    it.onAnimationEnd(view)
                }

                override fun onAnimationCancel(view: View) = Unit
            }
        }
        ViewCompat.animate(view).alpha(1f).setDuration(duration.toLong()).setListener(vpListener)
    }

    @JvmStatic
    fun reveal(view: View, listener: AnimationListener) {
        val cx = view.width - TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 24f, view.resources.displayMetrics).toInt()
        val cy = view.height / 2
        val finalRadius = maxOf(view.width, view.height)
        val anim = ViewAnimationUtils.createCircularReveal(view, cx, cy, 0f, finalRadius.toFloat())
        view.visibility = View.VISIBLE
        anim.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationStart(animation: Animator) {
                listener.onAnimationStart(view)
            }

            override fun onAnimationEnd(animation: Animator) {
                listener.onAnimationEnd(view)
            }

            override fun onAnimationCancel(animation: Animator) {
                listener.onAnimationCancel(view)
            }
        })
        anim.start()
    }

    @JvmStatic
    @JvmOverloads
    fun fadeOutView(view: View, duration: Int = ANIMATION_DURATION_SHORT, listener: AnimationListener? = null) {
        ViewCompat.animate(view).alpha(0f).setDuration(duration.toLong()).setListener(object : ViewPropertyAnimatorListener {
            override fun onAnimationStart(view: View) {
                listener?.onAnimationStart(view)
            }

            override fun onAnimationEnd(view: View) {
                if (listener == null || !listener.onAnimationEnd(view)) {
                    view.visibility = View.GONE
                }
            }

            override fun onAnimationCancel(view: View) = Unit
        })
    }
}
