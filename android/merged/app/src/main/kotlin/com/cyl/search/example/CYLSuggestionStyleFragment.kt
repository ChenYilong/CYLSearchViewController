package com.cyl.search.example

import android.content.Context
import android.os.Bundle
import android.view.Gravity
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.cyl.search.CYLLineBreakMode
import com.cyl.search.CYLSearchSuggestionStyle
import com.cyl.search.CYLSearchView
import com.cyl.search.CYLSearchViewDelegate

/**
 * The suggestion demo of MaterialSearchView's Default sample in one suggestion style (docs/tag-view-suggestions.md):
 * the "List style" tab shows the suggestions as a list, the "Tag style" tab the same suggestions as tags
 * (CollectionViewClassifyMenu's `CYLTagListView`). The page only passes the data and the style to `CYLSearchView`.
 */
class CYLSuggestionStyleFragment : CYLExamplePage(), CYLSearchViewDelegate {

    private lateinit var searchView: CYLSearchView

    private val style: CYLSearchSuggestionStyle
        get() = CYLSearchSuggestionStyle.valueOf(requireArguments().getString(ARG_STYLE) ?: CYLSearchSuggestionStyle.List.name)

    override fun pageTitle(context: Context) = context.getString(
        if (style == CYLSearchSuggestionStyle.Tags) R.string.example_tag_style else R.string.example_list_style,
    )

    override fun onCreateActions(menu: Menu) {
        menu.add(requireContext().cylDemoText("demo.port.open")).apply {
            icon = ContextCompat.getDrawable(requireContext(), com.cyl.search.R.drawable.cyl_search_ic_search)
            setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
            setOnMenuItemClickListener {
                searchView.showSearch()
                true
            }
        }
    }

    override fun createContent(context: Context): View {
        val page = FrameLayout(context)
        page.addView(TextView(context).apply {
            text = context.getString(R.string.example_open_search)
            textSize = 17f
            gravity = Gravity.CENTER
        }, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
        searchView = CYLSearchView(context).apply {
            suggestionStyle = style
            suggestions = CYLMaterialSearchSampleFragment.SUGGESTIONS
            suggestionLineBreakMode = CYLLineBreakMode.WordWrapping
            delegate = this@CYLSuggestionStyleFragment
        }
        searchView.installInView(page)
        return page
    }

    override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean {
        snackbar(requireContext().getString(com.cyl.search.R.string.cyl_demo_port_query, text))
        return false
    }

    companion object {
        private const val ARG_STYLE = "style"

        /**
         * The page for `style`.
         */
        fun newInstance(style: CYLSearchSuggestionStyle) = CYLSuggestionStyleFragment().apply {
            arguments = Bundle().apply { putString(ARG_STYLE, style.name) }
        }
    }
}
