// An independent Kotlin implementation of the behavior shown by android-cjj/MaterialSearchView's sample
// (https://github.com/android-cjj/MaterialSearchView). That project has no license, so none of its code is copied or
// translated here; only the idea is credited: a round search button opens a search card with a circular reveal,
// the magnifier slides across, and a tap on the magnifier closes the card again.
package com.cyl.search.reveal

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.os.Bundle
import android.view.View
import android.view.ViewAnimationUtils
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.ImageView
import androidx.appcompat.app.AppCompatActivity
import androidx.cardview.widget.CardView
import com.google.android.material.floatingactionbutton.FloatingActionButton
import kotlin.math.hypot

/**
 * A floating search button that reveals a search card from its center, and hides it again.
 */
class CYLRevealSearchActivity : AppCompatActivity() {

    private lateinit var card: CardView
    private lateinit var magnifier: ImageView
    private lateinit var button: FloatingActionButton
    private var animating = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.cyl_activity_reveal_search)
        card = findViewById(R.id.cyl_search_card)
        magnifier = findViewById(R.id.cyl_search_magnifier)
        button = findViewById(R.id.cyl_search_button)
        card.visibility = View.INVISIBLE
        button.setOnClickListener { setCardShown(true) }
        magnifier.setOnClickListener { setCardShown(false) }
    }

    private fun setCardShown(shown: Boolean) {
        if (animating) return
        animating = true
        val centerX = card.width / 2
        val centerY = card.height / 2
        val startRadius = button.width / 2f
        val endRadius = hypot(card.width.toDouble(), card.height.toDouble()).toFloat()
        val reveal = ViewAnimationUtils.createCircularReveal(card, centerX, centerY, if (shown) startRadius else endRadius, if (shown) endRadius else startRadius)
        reveal.duration = DURATION
        reveal.interpolator = AccelerateDecelerateInterpolator()
        // The magnifier moves from the middle of the card to its end, and back.
        val endTranslation = (card.width / 2f - magnifier.width)
        magnifier.animate().translationX(if (shown) endTranslation else 0f).setDuration(DURATION).start()
        reveal.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationStart(animation: Animator) {
                if (shown) {
                    card.visibility = View.VISIBLE
                    button.visibility = View.GONE
                }
            }

            override fun onAnimationEnd(animation: Animator) {
                if (!shown) {
                    card.visibility = View.INVISIBLE
                    button.visibility = View.VISIBLE
                }
                animating = false
            }
        })
        reveal.start()
    }

    private companion object {
        const val DURATION = 1000L
    }
}
