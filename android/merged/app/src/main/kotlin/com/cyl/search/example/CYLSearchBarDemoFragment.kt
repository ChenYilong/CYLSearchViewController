package com.cyl.search.example

import android.content.Context
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.TextView
import com.cyl.search.CYLSearchBarView
import com.cyl.search.CYLSearchBarViewDelegate

/**
 * The search bar example, the plus button's page (iOS `CYLSearchBarDemoViewController`): a bar with Cancel, a shadow
 * and a camera button inside the field; the text below follows typing and searching.
 */
class CYLSearchBarDemoFragment : CYLExamplePage(), CYLSearchBarViewDelegate {

    private lateinit var statusLabel: TextView

    override fun pageTitle(context: Context) = context.cylDemoText("demo.searchBar")

    override fun createContent(context: Context): View {
        val density = context.resources.displayMetrics.density
        val bar = CYLSearchBarView(context).apply {
            placeholder = context.cylDemoText("demo.searchBar.placeholder")
            showsCancelButton = true
            fieldShadowOpacity = 0.12f
            delegate = this@CYLSearchBarDemoFragment
            trailingAccessoryViews = listOf(ImageButton(context).apply {
                setImageResource(android.R.drawable.ic_menu_camera)
                background = null
                contentDescription = context.cylDemoText("demo.searchBar.camera")
            })
        }
        statusLabel = TextView(context).apply {
            textSize = 17f
            setTextColor(Color.GRAY)
        }
        showText("")
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(bar, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(statusLabel, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
                val margin = (16 * density).toInt()
                setMargins(margin, margin, margin, 0)
            })
        }
    }

    private fun showText(text: String) {
        statusLabel.text = requireContext().getString(com.cyl.search.R.string.cyl_demo_searchBar_text, text)
    }

    override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) = showText(text)

    override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
        statusLabel.text = requireContext().getString(com.cyl.search.R.string.cyl_demo_searchBar_searched, searchBarView.text.orEmpty())
        statusLabel.announceForAccessibility(statusLabel.text)
    }

    override fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) {
        searchBarView.text = null
        showText("")
    }
}
